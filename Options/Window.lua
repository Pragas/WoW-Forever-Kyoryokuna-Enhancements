-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The options window, like the other Kyoryokuna addons': a list of pages on the left and the chosen page
-- on the right, which scrolls when it's taller than the window. It opens with /ke, from the addon button
-- of the minimap (the addon compartment) and from the game's own settings (Options > AddOns). Each page
-- is built the first time it's shown. Also here: the chat commands.

local _, ns = ...
local L = ns.L

local WIDTH, HEIGHT = 780, 580
local NAV_WIDTH = 170
local CONTENT_WIDTH = 540

local pages = {}
local window, selectedPage

-- Pages register themselves (Options\Pages\*.lua) in the order they should appear
function ns.AddOptionsPage(name, build)
	pages[#pages + 1] = {name = name, build = build}
end

local function SelectPage(page)
	if selectedPage and selectedPage.scroll then
		selectedPage.scroll:Hide()
		selectedPage.button:UnlockHighlight()
	end
	selectedPage = page
	page.button:LockHighlight()

	if not page.scroll then
		local scroll = CreateFrame("ScrollFrame", nil, window.body)
		scroll:SetPoint("TOPLEFT", window, "TOPLEFT", NAV_WIDTH + 24, -48)
		scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -16, 16)
		local content = CreateFrame("Frame", nil, scroll)
		content:SetSize(CONTENT_WIDTH, 100)
		scroll:SetScrollChild(content)
		scroll:EnableMouseWheel(true)
		scroll:SetScript("OnMouseWheel", function(self, delta)
			local maxScroll = math.max(0, content:GetHeight() - self:GetHeight())
			self:SetVerticalScroll(math.min(maxScroll, math.max(0, self:GetVerticalScroll() - delta * 40)))
		end)
		local builder = ns.Widgets.NewBuilder(content)
		ns.SafeCall(page.build, builder)
		content:SetHeight(builder:Height())
		page.scroll = scroll
	end
	page.scroll:SetVerticalScroll(0)
	page.scroll:Show()
	ns.Widgets.RefreshAll()
end

-- The buttons of the title bar (X, and minimize beside it): a small dark square with a thin grey border,
-- lighter under the mouse, and the sign drawn in gold bars, so they never depend on a font or on the
-- game's own textures.
local BUTTON_SIZE = 24
local SIGN_COLOR = {1, 0.82, 0, 1}

local function SquareButton(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	local border = button:CreateTexture(nil, "BACKGROUND")
	border:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
	border:SetColorTexture(0.6, 0.6, 0.6, 1)
	local fill = button:CreateTexture(nil, "BORDER")
	fill:SetPoint("TOPLEFT", border, "TOPLEFT", 1, -1)
	fill:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1)
	fill:SetColorTexture(0.12, 0.12, 0.14, 1)
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(fill)
	highlight:SetColorTexture(1, 1, 1, 0.15)
	button.fill = fill
	return button
end

-- One bar of a sign, in the middle of the button, turned by an angle (in degrees)
local function SignBar(button, width, height, angle)
	local bar = button:CreateTexture(nil, "ARTWORK")
	bar:SetSize(width, height)
	bar:SetPoint("CENTER", button.fill, "CENTER", 0, 0)
	bar:SetColorTexture(unpack(SIGN_COLOR))
	if angle and bar.SetRotation then bar:SetRotation(math.rad(angle)) end
	return bar
end

-- The X: two bars crossed
local function CloseButton(parent)
	local button = SquareButton(parent)
	SignBar(button, 12, 2, 45)
	SignBar(button, 12, 2, -45)
	return button
end

-- Minimized: only the title bar with its buttons, to see and drag what's on the screen (e.g. the things
-- the options move), as wide as before. The button beside the X shrinks it (a minus) and brings it back
-- (a plus).
local MINIMIZED_HEIGHT = 44

local function StyleSizeButton(button, minimized)
	if not button.horizontal then
		button.horizontal = SignBar(button, 10, 2)
		button.vertical = SignBar(button, 2, 10)
	end
	-- Minus while whole, plus while minimized
	button.vertical:SetShown(minimized)
end

local function SetMinimized(minimized)
	minimized = minimized and true or false
	if not window or window.minimized == minimized then return end
	window.minimized = minimized
	ns.Widgets.ClosePopup()
	-- Kept by its top left corner, so the title bar stays where it is
	local left, top = window:GetLeft(), window:GetTop()
	if left and top then
		window:ClearAllPoints()
		window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	end
	window.body:SetShown(not minimized)
	if minimized then
		window:SetSize(WIDTH, MINIMIZED_HEIGHT)
	else
		window:SetSize(WIDTH, HEIGHT)
	end
	StyleSizeButton(window.sizeButton, minimized)
	if GameTooltip:IsOwned(window.sizeButton) then window.sizeButton:GetScript("OnEnter")(window.sizeButton) end
end

function ns.IsOptionsMinimized()
	return window ~= nil and window.minimized == true
end

function ns.SetOptionsMinimized(minimized)
	SetMinimized(minimized)
end

local function CreateWindow()
	window = CreateFrame("Frame", "KyoryokunaEnhancementsOptionsWindow", UIParent, "BackdropTemplate")
	window:SetSize(WIDTH, HEIGHT)
	window:SetPoint("CENTER")
	window:SetFrameStrata("HIGH")
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	window:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
	window:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	window:SetScript("OnHide", function()
		ns.Widgets.ClosePopup()
		-- Moving the missing buffs ends with the options
		if ns.MissingBuffs and ns.MissingBuffs.IsMoving() then ns.MissingBuffs.SetMoving(false) end
		-- And the fixed test of the proc alerts
		if ns.ProcAlerts and ns.ProcAlerts.StopFixedTest then ns.ProcAlerts.StopFixedTest() end
	end)
	-- Escape closes it
	tinsert(UISpecialFrames, "KyoryokunaEnhancementsOptionsWindow")

	local title = window:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", window, "TOPLEFT", 18, -16)
	title:SetText(ns.TITLE)
	local version = window:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	version:SetPoint("LEFT", title, "RIGHT", 8, -1)
	version:SetText("v" .. ns.VERSION)

	local close = CloseButton(window)
	close:SetPoint("TOPRIGHT", window, "TOPRIGHT", -4, -4)
	-- Simply hidden: the game's panel system (HideUIPanel) is blocked for addons in combat
	close:SetScript("OnClick", function() window:Hide() end)

	window.title, window.version = title, version

	-- Beside the X: minimize ("-") and bring the window back ("+")
	local size = SquareButton(window)
	size:SetPoint("RIGHT", close, "LEFT", 2, 0)
	size:SetScript("OnClick", function() SetMinimized(not window.minimized) end)
	size:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if window.minimized then
			GameTooltip:SetText(L["Maximize"])
			GameTooltip:AddLine(L["The window back to its full size."], 1, 1, 1, true)
		else
			GameTooltip:SetText(L["Minimize"])
			GameTooltip:AddLine(L["Only the title bar stays, to see and drag what's on the screen."], 1, 1, 1, true)
		end
		GameTooltip:Show()
	end)
	size:SetScript("OnLeave", function() GameTooltip:Hide() end)
	window.sizeButton = size
	window.minimized = false
	StyleSizeButton(size, false)

	-- What a minimized window hides: the list of pages and the pages
	window.body = CreateFrame("Frame", nil, window)
	window.body:SetAllPoints(window)

	local divider = window.body:CreateTexture(nil, "ARTWORK")
	divider:SetColorTexture(1, 1, 1, 0.12)
	divider:SetWidth(1)
	divider:SetPoint("TOPLEFT", window, "TOPLEFT", NAV_WIDTH + 12, -44)
	divider:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", NAV_WIDTH + 12, 14)

	for i, page in ipairs(pages) do
		local button = CreateFrame("Button", nil, window.body)
		button:SetSize(NAV_WIDTH - 8, 26)
		button:SetPoint("TOPLEFT", window, "TOPLEFT", 12, -46 - (i - 1) * 28)
		button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
		button:GetHighlightTexture():SetVertexColor(0.18, 0.8, 0.44, 0.18)
		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetPoint("LEFT", button, "LEFT", 10, 0)
		text:SetText(L[page.name])
		button:SetScript("OnClick", function() SelectPage(page) end)
		page.button = button
	end

	window:Hide()
end

function ns.OpenOptions()
	if ns.NEEDS_RESTART then ns.ShowRestartNotice() return end
	if not ns.db then return end
	if not window then CreateWindow() end
	window:Show()
	-- Opened again: always whole
	SetMinimized(false)
	local page = selectedPage or pages[1]
	selectedPage = nil
	SelectPage(page)
	-- The first time, and after an update: the welcome window over it (Options\Welcome.lua)
	if ns.CheckWelcome and not (window.welcome and window.welcome:IsShown()) then
		ns.CheckWelcome(window)
	end
end

function ns.GetOptionsWindow()
	return window
end

-- A page made again (its content depends on something that changed, e.g. the spells of the character);
-- shown again where it was scrolled to if it's the one open, else made the next time it's opened
function ns.RebuildOptionsPage(name)
	if not window then return end
	for _, page in ipairs(pages) do
		if page.name == name and page.scroll then
			local scrolled = page.scroll:GetVerticalScroll()
			page.scroll:Hide()
			page.scroll = nil
			if page == selectedPage and window:IsShown() then
				SelectPage(page)
				page.scroll:SetVerticalScroll(scrolled)
			end
		end
	end
end

-- A page by its place in the list (1 is General) or by its name
function ns.SelectOptionsPage(which)
	if not window then return end
	for i, page in ipairs(pages) do
		if i == which or page.name == which then
			SelectPage(page)
			return
		end
	end
end

function ns.ToggleOptions()
	if window and window:IsShown() then
		window:Hide()
	else
		ns.OpenOptions()
	end
end

function ns.RefreshOptions()
	if window and window:IsShown() then
		ns.Widgets.RefreshAll()
	end
end

-- After a change of language: the window and its pages are made again with the new texts, and it opens
-- again on the same page if it was open
function ns.RebuildOptions()
	if not window then return end
	local wasShown = window:IsShown()
	local pageIndex
	for i, page in ipairs(pages) do
		if page == selectedPage then pageIndex = i end
		page.scroll = nil
		page.button = nil
	end
	window:Hide()
	window = nil
	selectedPage = pages[pageIndex or 1]
	if wasShown then ns.OpenOptions() end
end

-- The game's settings (Options > AddOns): a short page with a button that opens this window -------

local function RegisterSettingsCategory()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
	local panel = CreateFrame("Frame")
	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
	title:SetText(ns.TITLE)
	local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
	text:SetText(L["All options are in the addon's own window. You can also type /ke."])
	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetSize(200, 26)
	button:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -12)
	button:SetText(L["Open options"])
	button:SetScript("OnClick", function()
		if SettingsPanel and SettingsPanel:IsShown() and not InCombatLockdown() then
			HideUIPanel(SettingsPanel)
		end
		ns.OpenOptions()
	end)
	local category = Settings.RegisterCanvasLayoutCategory(panel, ns.SHORT_TITLE)
	Settings.RegisterAddOnCategory(category)
end

ns.RegisterEvent("PLAYER_LOGIN", RegisterSettingsCategory)

-- Addon compartment (the addon button of the minimap) ----------------------------------------------

function KyoryokunaEnhancements_OnAddonCompartmentClick()
	ns.ToggleOptions()
end

function KyoryokunaEnhancements_OnAddonCompartmentEnter(_, button)
	GameTooltip:SetOwner(button or UIParent, "ANCHOR_LEFT")
	GameTooltip:SetText(ns.TITLE)
	GameTooltip:AddLine(L["Click to open the options."], 1, 1, 1)
	GameTooltip:Show()
end

function KyoryokunaEnhancements_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end

-- Chat commands ------------------------------------------------------------------------------------

SLASH_KYORYOKUNAENHANCEMENTS1 = "/ke"
SLASH_KYORYOKUNAENHANCEMENTS2 = "/kyoryokunaenhancements"
SlashCmdList.KYORYOKUNAENHANCEMENTS = function(message)
	-- Waiting for the game to be restarted (Init.lua): every command says so
	if ns.NEEDS_RESTART then ns.ShowRestartNotice() return end
	local command = strtrim and strtrim(message or ""):lower() or (message or ""):lower()
	if command == "errors" then
		ns.PrintErrors()
	elseif command == "darkscan" then
		-- How many pieces each part of the dark mode finds in the game now
		ns.Print(L["Dark mode: pieces found by part"])
		for _, part in ipairs(ns.DarkMode.Scan()) do
			DEFAULT_CHAT_FRAME:AddMessage("  " .. part.key .. ": " .. part.found)
		end
	elseif command == "buffscan" then
		-- The buffs the addon can read on the character now (in combat the game may hide them)
		local scan = ns.MissingBuffs.Scan()
		ns.Print(string.format(L["Buffs read: %d. In combat: %s. Readable: %s."], scan.count,
			scan.inCombat and L["Yes"] or L["No"], scan.readable and L["Yes"] or L["No"]))
		for _, name in ipairs(scan.names) do
			DEFAULT_CHAT_FRAME:AddMessage("  " .. name)
		end
		-- What a click on each icon casts: the spell and its exact ID (rank)
		local casts = ns.MissingBuffs.CastInfo()
		if #casts > 0 then
			ns.Print(L["A click on each icon casts:"])
			for _, cast in ipairs(casts) do
				DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: %s (ID %s) %s", tostring(cast.label), tostring(cast.spell),
					tostring(cast.id), cast.rank))
			end
		end
	elseif command == "procscan all" then
		-- Every proc of every class: the spell IDs the game has with its name (out of combat is best)
		if ns.ProcAlerts.FindAll() then
			ns.Print("looking for the spells of every proc of every class (10 to 20 seconds)...")
		end
	elseif command:find("^procscan find ") then
		-- Every spell ID with that name (as the player typed it)
		local name = strtrim and strtrim((message or ""):sub(#"procscan find " + 1)) or (message or ""):sub(15)
		if ns.ProcAlerts.FindSpells(name) then
			ns.Print("looking for every spell named \"" .. name .. "\" (a few seconds)...")
		end
	elseif command == "procscan watch" then
		-- Each spell alert of the game written in the chat as it comes (again: off)
		local on = ns.ProcAlerts.ToggleWatch()
		ns.Print(on and "watching the game's spell alerts: on (/ke procscan watch again to stop)"
			or "watching the game's spell alerts: off")
		-- What comes while watching is also kept (each alert added as it comes)
		ns.AddToDiagnostic("procscan watch", on and "watching: on" or "watching: off")
	elseif command == "procscan" then
		-- What the proc alerts know now: the game's container, and each proc ticked (as the game gives
		-- it: not translated)
		ns.Print(L["Proc alerts now:"])
		-- Whatever breaks, it says so instead of stopping in silence
		local ok, lines = pcall(ns.ProcAlerts.Scan)
		if not ok then lines = {"the scan broke: " .. tostring(lines)} end
		for _, line in ipairs(lines) do
			DEFAULT_CHAT_FRAME:AddMessage("  " .. line)
		end
		-- Also in the saved data, read from the file at the next /reload (no screenshots needed)
		ns.SaveDiagnostic(command, lines)
		ns.Print(L["Kept in the addon's saved data: type /reload so the game writes it down."])
	elseif command == "help" then
		ns.Print(L["Commands:"])
		DEFAULT_CHAT_FRAME:AddMessage("  /ke - " .. L["open the options"])
		DEFAULT_CHAT_FRAME:AddMessage("  /ke buffscan - " .. L["the buffs the addon can read on you now"])
		DEFAULT_CHAT_FRAME:AddMessage("  /ke darkscan - " .. L["what the dark mode finds of each part"])
		DEFAULT_CHAT_FRAME:AddMessage("  /ke procscan - " .. L["what the proc alerts know now"])
		DEFAULT_CHAT_FRAME:AddMessage("  /ke errors - " .. L["show recorded errors"])
	else
		ns.ToggleOptions()
	end
end
