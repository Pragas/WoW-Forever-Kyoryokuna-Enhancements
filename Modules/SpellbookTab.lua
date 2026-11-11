-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The trainer's tab in the spellbook (Trainer page): one more tab after the game's (General, then the
-- class's), with the look of theirs. A click on it shows, in place of the book's pages, the spells still to
-- learn at the class trainer, by level: the ones in reach now, then the next levels', each with its icon,
-- rank and cost, and its tooltip under the mouse. The list is the one kept at the last visit to the trainer
-- (Modules\Trainer.lua). A search box beside it keeps only the spells whose name has what's typed, and
-- under it are the costs of what's listed: what can be learned now, and all of it.
--
-- The game's spellbook (Blizzard_PlayerSpells, loaded the first time it's opened) is only looked at, never
-- changed: while the tab is open its pages are only made invisible (their alpha) and covered, so the mouse
-- can't reach them; another tab, or the book closing, brings them back. The game's tabs only lose their
-- selected look meanwhile (their textures), not their state. Casting from the book is never touched.

local _, ns = ...
local L = ns.L

local SpellbookTab = {}
ns.SpellbookTab = SpellbookTab

local ICON = "Interface\\Icons\\INV_Misc_Book_09"
local ROW_HEIGHT = 26
local HEADER_HEIGHT = 28
local GREEN = {0.4, 0.9, 0.4}
local GREY = {0.65, 0.65, 0.65}

local book, tabSystem, container, tab, panel, searchCover
local scroll, content
local rows, headers = {}, {}
-- What's typed in the search box, in lower case ("" shows everything)
local query = ""
-- The alpha of the book's parts made invisible, to put back
local hidden = {}

local function Settings()
	return ns.db.trainer
end

-- The game's tabs: their selected look shown or not, as their own SetTabSelected does it, without changing
-- their state. While the addon's tab is open, the game's selected tab can be clicked to go back to it.
local function NativeTabsLook(showSelection)
	if not (tabSystem and tabSystem.tabs) then return end
	for _, button in ipairs(tabSystem.tabs) do
		local selected = showSelection and button.isSelected and true or false
		if button.squareMode then
			if button.SquareBackground then button.SquareBackground:SetShown(not selected) end
			if button.SquareBackgroundActive then button.SquareBackgroundActive:SetShown(selected) end
			if button.SquareBackgroundActiveGlow then button.SquareBackgroundActiveGlow:SetShown(selected) end
		else
			for _, key in ipairs({"Left", "Middle", "Right"}) do
				if button[key] then button[key]:SetShown(not selected) end
			end
			for _, key in ipairs({"LeftActive", "MiddleActive", "RightActive"}) do
				if button[key] then button[key]:SetShown(selected) end
			end
		end
		local forced = button.IsForceDisabled and button:IsForceDisabled()
		button:SetEnabled(not selected and not forced)
	end
end

-- The highest frame level among a frame and everything in it
local function TopLevel(frame, depth)
	local level = frame:GetFrameLevel() or 0
	if (depth or 0) > 6 then return level end
	for _, child in ipairs({frame:GetChildren()}) do
		level = math.max(level, TopLevel(child, (depth or 0) + 1))
	end
	return level
end

-- The list ---------------------------------------------------------------------------------------------

local function GetHeader(index)
	local header = headers[index]
	if header then return header end
	header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	header:SetJustifyH("LEFT")
	headers[index] = header
	return header
end

local function ShowSpellTooltip(row)
	local spell = row.spell
	if not spell then return end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	if spell.id and GameTooltip.SetSpellByID then
		GameTooltip:SetSpellByID(spell.id)
	else
		GameTooltip:SetText(spell.label, 1, 0.82, 0)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(string.format(L["Level %d, at your class trainer: %s"], spell.level, ns.Trainer.Money(spell.cost)), 1, 1, 1, true)
	GameTooltip:Show()
end

local function GetRow(index)
	local row = rows[index]
	if row then return row end
	row = CreateFrame("Frame", nil, content)
	row:SetHeight(ROW_HEIGHT)
	row:EnableMouse(true)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(22, 22)
	row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)
	row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.cost = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	row.cost:SetPoint("RIGHT", row, "RIGHT", -6, 0)
	row.cost:SetJustifyH("RIGHT")
	row.name:SetPoint("RIGHT", row.cost, "LEFT", -8, 0)
	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints(row)
	row.highlight:SetColorTexture(1, 1, 1, 0.08)
	row:SetScript("OnEnter", function(self) ns.SafeCall(ShowSpellTooltip, self) end)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)
	rows[index] = row
	return row
end

-- The list made again from what's kept
local function Fill()
	if not content then return end
	local width = math.max(200, (scroll:GetWidth() or 400) - 8)
	content:SetWidth(width)
	for _, row in ipairs(rows) do row:Hide() end
	for _, header in ipairs(headers) do header:Hide() end
	local y, rowIndex, headerIndex = -4, 0, 0
	local function Header(text, color)
		headerIndex = headerIndex + 1
		local header = GetHeader(headerIndex)
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", content, "TOPLEFT", 4, y - 6)
		header:SetWidth(width - 8)
		header:SetText(text)
		header:SetTextColor(color[1], color[2], color[3])
		header:Show()
		y = y - HEADER_HEIGHT
	end
	local levels = ns.Trainer.List()
	local trainerName, zone, by = ns.Trainer.LastVisit()
	local where = {}
	if trainerName then where[#where + 1] = trainerName end
	if zone then where[#where + 1] = zone end
	if by then
		-- Another character of the class went there
		if #where > 0 then
			panel.subtitle:SetText(string.format(L["From %s's last visit to the class trainer: %s."], by, table.concat(where, ", ")))
		else
			panel.subtitle:SetText(string.format(L["From %s's last visit to the class trainer."], by))
		end
	elseif #where > 0 then
		panel.subtitle:SetText(string.format(L["From your last visit to your trainer: %s."], table.concat(where, ", ")))
	else
		panel.subtitle:SetText(L["From your last visit to your trainer."])
	end
	local now, all = 0, 0
	if not levels then
		panel.empty:SetText(L["Nothing known yet: visit your class trainer once, with any character of this class, and its spells show here."])
		panel.empty:Show()
	elseif #levels == 0 then
		panel.empty:SetText(L["Nothing left to learn at your trainer."])
		panel.empty:Show()
	else
		panel.empty:Hide()
		local playerLevel = UnitLevel("player") or 0
		for _, group in ipairs(levels) do
			-- Only the spells with what's searched in their name (and rank)
			local shown = {}
			for _, spell in ipairs(group.spells) do
				if query == "" or spell.label:lower():find(query, 1, true) then shown[#shown + 1] = spell end
			end
			local inReach = group.level <= playerLevel
			if #shown > 0 then
				Header(inReach and string.format(L["Level %d: you can learn these now"], group.level)
					or string.format(L["Level %d"], group.level), inReach and GREEN or {1, 0.82, 0})
			end
			for _, spell in ipairs(shown) do
				rowIndex = rowIndex + 1
				local row = GetRow(rowIndex)
				row.spell = spell
				row:ClearAllPoints()
				row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
				row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
				row.icon:SetTexture(spell.icon or 134400)
				row.icon:SetDesaturated(not inReach)
				row.name:SetText(spell.label)
				local color = inReach and {1, 1, 1} or GREY
				row.name:SetTextColor(color[1], color[2], color[3])
				row.cost:SetText(spell.cost > 0 and ns.Trainer.Money(spell.cost) or "")
				row:Show()
				y = y - ROW_HEIGHT
				all = all + spell.cost
				if inReach then now = now + spell.cost end
			end
			if #shown > 0 then y = y - 6 end
		end
		if rowIndex == 0 then
			panel.empty:SetText(string.format(L["No spell has \"%s\" in its name."], panel.search:GetText() or ""))
			panel.empty:Show()
		end
	end
	-- The costs of what's listed
	panel.totalNow:SetText(string.format(L["You can learn now: %s"], ns.Trainer.Money(now)))
	panel.totalAll:SetText(string.format(L["All of the list: %s"], ns.Trainer.Money(all)))
	panel.totalNow:SetShown(levels ~= nil)
	panel.totalAll:SetShown(levels ~= nil)
	panel.totalLine:SetShown(levels ~= nil)
	content:SetHeight(math.max(1, -y + 8))
	scroll:SetVerticalScroll(0)
end

-- Something typed in the search box: the list again, with only the spells that have it
local function OnSearch(box)
	local text = box:GetText() or ""
	local wanted = text:gsub("^%s+", ""):gsub("%s+$", ""):lower()
	if wanted == query then return end
	query = wanted
	if panel and panel:IsShown() then Fill() end
end

-- Opening and closing ------------------------------------------------------------------------------------

local function Hide(frame)
	if frame and hidden[frame] == nil then
		hidden[frame] = frame:GetAlpha()
		frame:SetAlpha(0)
	end
end

local function Open()
	if not (book and panel) then return end
	local paged = book.PagedSpellsFrame
	-- Over the book's pages (and their spells), which are only made invisible meanwhile
	if paged then
		panel:ClearAllPoints()
		panel:SetAllPoints(paged)
	end
	panel:SetFrameStrata(book:GetFrameStrata())
	panel:SetFrameLevel(TopLevel(book) + 5)
	Hide(paged)
	Hide(book.SearchBox)
	if book.SearchBox and searchCover then
		searchCover:ClearAllPoints()
		searchCover:SetAllPoints(book.SearchBox)
		searchCover:SetFrameLevel(panel:GetFrameLevel())
		searchCover:Show()
	end
	panel:Show()
	Fill()
	tab:SetTabSelected(true)
	NativeTabsLook(false)
end

local function Close()
	if panel and panel:IsShown() then panel:Hide() end
end
SpellbookTab.Close = Close

-- Closed (by another tab, the book closing, or the option): the book as it was. When the book closes, the
-- list is hidden with it but would come back with it: it's closed for good.
local closing = false
local function OnPanelHidden()
	if closing then return end
	closing = true
	panel:Hide()
	-- Opened again, the whole list
	query = ""
	panel.search:ClearFocus()
	panel.search:SetText("")
	if searchCover then searchCover:Hide() end
	for frame, alpha in pairs(hidden) do frame:SetAlpha(alpha) end
	wipe(hidden)
	if tab then tab:SetTabSelected(false) end
	NativeTabsLook(true)
	closing = false
end

function SpellbookTab.IsOpen()
	return panel ~= nil and panel:IsShown()
end

-- Made once, the first time the spellbook is there ------------------------------------------------------

-- The search box, with the look of the game's (a magnifier, "Search" while empty, an X to clear it), or a
-- plain one if this version lacks it. Enter or Escape leaves it.
local function CreateSearchBox(parent)
	local box
	for _, template in ipairs({"SearchBoxTemplate", "InputBoxTemplate"}) do
		local ok, made = pcall(CreateFrame, "EditBox", nil, parent, template)
		if ok and made then
			box = made
			break
		end
	end
	box = box or CreateFrame("EditBox", nil, parent)
	box:SetSize(160, 20)
	box:SetAutoFocus(false)
	if box.SetMaxLetters then box:SetMaxLetters(40) end
	if type(box.Instructions) == "table" and box.Instructions.SetText then box.Instructions:SetText(L["Search a spell"]) end
	local function Leave(self) self:ClearFocus() end
	if not box:GetScript("OnEscapePressed") then box:SetScript("OnEscapePressed", Leave) end
	if not box:GetScript("OnEnterPressed") then box:SetScript("OnEnterPressed", Leave) end
	box:HookScript("OnTextChanged", function(self) ns.SafeCall(OnSearch, self) end)
	return box
end

local function CreateTab()
	container = CreateFrame("Frame", nil, book)
	container:SetSize(44, 40)
	container:SetPoint("LEFT", tabSystem, "RIGHT", 8, 0)
	-- With the look of the game's tabs (their template), or a plain one if this version lacks it
	for _, template in ipairs({"SpellBookCategoryTabTemplate", "TabSystemButtonTemplate"}) do
		local ok, button = pcall(CreateFrame, "Button", nil, container, template)
		if ok and button then
			tab = button
			break
		end
	end
	if not tab then return false end
	-- Its sizes come from the game's tabs
	tab.GetTabSystem = function() return tabSystem end
	if tab.Init then tab:Init(0, nil, ICON) end
	tab:SetPoint("LEFT", container, "LEFT", 0, 0)
	if tab.SetTooltipText then tab:SetTooltipText(L["Trainer: the spells still to learn"]) end
	tab:SetScript("OnClick", function() ns.SafeCall(Open) end)
	return true
end

local function CreatePanel()
	panel = CreateFrame("Frame", nil, book)
	panel:EnableMouse(true)
	-- The wheel scrolls the list, never the book's pages under it
	panel:EnableMouseWheel(true)
	panel:Hide()
	panel:SetScript("OnHide", function() ns.SafeCall(OnPanelHidden) end)
	-- On the left page
	local page = book.PagedSpellsFrame and book.PagedSpellsFrame.ViewFrames and book.PagedSpellsFrame.ViewFrames[1]
	local area = CreateFrame("Frame", nil, panel)
	if page then
		area:SetPoint("TOPLEFT", page, "TOPLEFT", -20, 10)
		area:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
	else
		area:SetPoint("TOPLEFT", panel, "TOPLEFT", 60, -30)
		area:SetPoint("BOTTOMRIGHT", panel, "BOTTOM", -20, 30)
	end
	panel.title = area:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	panel.title:SetPoint("TOPLEFT", area, "TOPLEFT", 4, 0)
	panel.title:SetText(L["Spells to learn"])
	-- Under the title: where the list comes from, and the search box beside it
	local bar = CreateFrame("Frame", nil, area)
	bar:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("RIGHT", area, "RIGHT", -6, 0)
	bar:SetHeight(30)
	panel.search = CreateSearchBox(bar)
	panel.search:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	panel.subtitle = bar:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	panel.subtitle:SetPoint("LEFT", bar, "LEFT", 0, 0)
	panel.subtitle:SetPoint("RIGHT", panel.search, "LEFT", -14, 0)
	panel.subtitle:SetJustifyH("LEFT")
	panel.subtitle:SetWordWrap(true)
	if panel.subtitle.SetMaxLines then panel.subtitle:SetMaxLines(2) end
	panel.empty = area:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	panel.empty:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -20)
	panel.empty:SetPoint("RIGHT", area, "RIGHT", -4, 0)
	panel.empty:SetJustifyH("LEFT")
	-- At the bottom: the costs of what's listed, under a thin line
	panel.totalNow = area:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	panel.totalNow:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 4, 6)
	panel.totalNow:SetJustifyH("LEFT")
	panel.totalAll = area:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	panel.totalAll:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", -6, 6)
	panel.totalAll:SetJustifyH("RIGHT")
	panel.totalLine = area:CreateTexture(nil, "ARTWORK")
	panel.totalLine:SetColorTexture(1, 0.82, 0, 0.25)
	panel.totalLine:SetHeight(1)
	panel.totalLine:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 4, 26)
	panel.totalLine:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", -6, 26)
	scroll = CreateFrame("ScrollFrame", nil, area)
	scroll:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", -4, -8)
	scroll:SetPoint("BOTTOMRIGHT", area, "BOTTOMRIGHT", 0, 32)
	content = CreateFrame("Frame", nil, scroll)
	content:SetSize(400, 1)
	scroll:SetScrollChild(content)
	panel:SetScript("OnMouseWheel", function(_, delta)
		local maxScroll = math.max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
		scroll:SetVerticalScroll(math.min(maxScroll, math.max(0, (scroll:GetVerticalScroll() or 0) - delta * ROW_HEIGHT * 3)))
	end)
	-- The search box can't be used while the list is there
	searchCover = CreateFrame("Frame", nil, book)
	searchCover:EnableMouse(true)
	searchCover:Hide()
end

local function Install()
	if book or not (ns.db and Settings().spellbookTab) then return end
	local spells = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
	if not (spells and spells.CategoryTabSystem) then return end
	book, tabSystem = spells, spells.CategoryTabSystem
	if not CreateTab() then
		container:Hide()
		return
	end
	CreatePanel()
	-- Another of the game's tabs chosen (with the mouse or a gamepad): the list goes
	hooksecurefunc(tabSystem, "SetTab", Close)
	if book.OnActiveCategoryChanged then hooksecurefunc(book, "OnActiveCategoryChanged", Close) end
end

-- Shown or not, for the setting now
function SpellbookTab.Apply()
	if not ns.db then return end
	Install()
	if not container then return end
	local on = Settings().spellbookTab and true or false
	container:SetShown(on)
	if not on then Close() end
end

-- The list changed (a visit to the trainer, a level up): shown again if it's open
function SpellbookTab.Refresh()
	if SpellbookTab.IsOpen() then Fill() end
end

-- For the tests
function SpellbookTab.GetParts()
	return tab, panel, rows, headers, container
end

ns.RegisterEvent("ADDON_LOADED", function(_, name)
	if name == "Blizzard_PlayerSpells" then SpellbookTab.Apply() end
end)
ns.RegisterEvent("PLAYER_LOGIN", function() SpellbookTab.Apply() end)
