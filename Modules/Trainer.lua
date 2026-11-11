-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The class trainer (Trainer page), two things:
--   - Choosing the spells to learn: at a class trainer, a box on each spell that can be learned. The
--     player ticks the ones wanted and clicks "Learn ticked" (next to the trainer's filter): only those
--     are learned, one after another (the next once the game has taught the one before). Nothing is ever
--     learned without a tick, and the game's own Train button works as always.
--   - New spells: at each visit, the trainer's list (the spells not learned yet and the level each needs)
--     is kept for the character; when it levels up, the chat says which of them that level brings.
--
-- The game's trainer window (Blizzard_TrainerUI, loaded the first time a trainer is opened) makes each
-- row with ClassTrainerFrame_InitServiceButton: a hook on it adds the box. Profession and pet trainers are
-- left as they are.

local _, ns = ...
local L = ns.L

local Trainer = {}
ns.Trainer = Trainer

-- Between a spell's name and its rank in the keys ("Frostbolt\tRank 4")
local SEPARATOR = "\t"
-- How long a spell may take to be taught before the next one is tried (seconds)
local WAIT = 3

-- What's ticked on this visit (by key), and the learning in progress
local chosen = {}
local learning
local hooked = false
local button

local function Settings()
	return ns.db.trainer
end

local SERVICE_TYPES = {available = true, unavailable = true, used = true}

-- One line of the trainer: its name, rank, state (available, unavailable, used), the level it needs and its
-- icon. The game gave these in another order in older versions; both are read.
local function ReadService(index)
	local name, second, third, fourth, fifth = GetTrainerServiceInfo(index)
	local rank, status, level, icon
	if SERVICE_TYPES[second] then
		status, icon, level, rank = second, third, fourth, fifth
	else
		rank, status = second, third
		icon = GetTrainerServiceIcon and GetTrainerServiceIcon(index)
	end
	if (tonumber(level) or 0) == 0 and GetTrainerServiceLevelReq then level = GetTrainerServiceLevelReq(index) end
	if type(name) ~= "string" then return nil end
	return name, type(rank) == "string" and rank or "", status, tonumber(level) or 0, icon
end

local function KeyOf(name, rank)
	return name .. SEPARATOR .. (rank or "")
end

-- "Frostbolt (Rank 4)" from a key
function Trainer.Label(key)
	local name, rank = key:match("^(.-)\t(.*)$")
	if not name then return key end
	if rank ~= "" then return name .. " (" .. rank .. ")" end
	return name
end

-- A class trainer: not a profession's, nor the hunter's pet trainer
local function IsClassTrainer()
	if IsTradeskillTrainer and IsTradeskillTrainer() then return false end
	if C_Trainer and C_Trainer.GetTrainerType and Enum and Enum.TrainerType and Enum.TrainerType.Pet ~= nil
		and C_Trainer.GetTrainerType() == Enum.TrainerType.Pet then
		return false
	end
	return true
end

local function TrainerOpen()
	return ClassTrainerFrame and ClassTrainerFrame:IsShown() and IsClassTrainer()
end

-- A line that can be ticked (available, not a profession): its key and cost
local function Choosable(index)
	local name, rank, status = ReadService(index)
	if not name or status ~= "available" then return nil end
	local cost, isProfession = GetTrainerServiceCost(index)
	if isProfession then return nil end
	return KeyOf(name, rank), tonumber(cost) or 0
end

-- What's ticked and can still be learned: how many, the total cost, their keys. Ticks on lines no longer
-- available (learned meanwhile) are dropped.
local function Ticked()
	local count, total, list, seen = 0, 0, {}, {}
	for index = 1, GetNumTrainerServices() do
		local key, cost = Choosable(index)
		if key then
			seen[key] = true
			if chosen[key] then
				count, total = count + 1, total + cost
				list[#list + 1] = key
			end
		end
	end
	for key in pairs(chosen) do
		if not seen[key] then chosen[key] = nil end
	end
	return count, total, list
end

local function Money(amount)
	if GetMoneyString then return GetMoneyString(amount, true) end
	if GetCoinTextureString then return GetCoinTextureString(amount) end
	return tostring(amount)
end

Trainer.Money = Money

local function Character()
	return ns.MissingBuffs and ns.MissingBuffs.GetCharacter and ns.MissingBuffs.GetCharacter()
end

-- The character's saved list (the spells not learned yet: key -> {level, cost, icon, id}), or nil
local function SavedSpells(create)
	local entry = Character()
	if not entry then return nil end
	if create and type(entry.trainer) ~= "table" then entry.trainer = {} end
	return entry.trainer
end

-- The trainer's list is kept for the new spells told in the chat and for the spellbook's tab
local function Keeping()
	local settings = Settings()
	return settings.notify or settings.spellbookTab
end

-- What's kept of a line: the level it needs, its cost, its icon, and its spell (for its tooltip)
local function Describe(index, level, icon)
	local spellID
	if C_TooltipInfo and C_TooltipInfo.GetTrainerService then
		local ok, data = pcall(C_TooltipInfo.GetTrainerService, index)
		if ok and type(data) == "table" and type(data.id) == "number" then spellID = data.id end
	end
	local cost = GetTrainerServiceCost(index)
	return {level = level, cost = tonumber(cost) or 0, icon = tonumber(icon) or icon, id = spellID}
end

-- After a change of the list: the page and the spellbook's tab show it again
local function ListChanged()
	if ns.RebuildOptionsPage then ns.RebuildOptionsPage("Trainer") end
	if ns.SpellbookTab then ns.SpellbookTab.Refresh() end
end

-- The trainer's whole list kept, at the start of a visit, with the trainer's name and place. The spells for
-- later levels only show with the trainer's "Unavailable" filter: it's turned on for the reading, and put
-- back as it was.
local function Record()
	if not (Keeping() and IsClassTrainer()) then return end
	local spells = SavedSpells(true)
	if not spells then return end
	local turnedOn = {}
	if GetTrainerServiceTypeFilter and SetTrainerServiceTypeFilter then
		for _, filter in ipairs({"available", "unavailable"}) do
			if not GetTrainerServiceTypeFilter(filter) then
				SetTrainerServiceTypeFilter(filter, true)
				turnedOn[#turnedOn + 1] = filter
			end
		end
	end
	wipe(spells)
	for index = 1, GetNumTrainerServices() do
		local name, rank, status, level, icon = ReadService(index)
		local _, isProfession = GetTrainerServiceCost(index)
		if name and not isProfession and (status == "available" or status == "unavailable") then
			spells[KeyOf(name, rank)] = Describe(index, level, icon)
		end
	end
	for _, filter in ipairs(turnedOn) do SetTrainerServiceTypeFilter(filter, false) end
	local trainerName = UnitName and ns.Known(UnitName("npc"))
	local zone = GetZoneText and ns.Known(GetZoneText())
	Character().trainerVisit = {name = type(trainerName) == "string" and trainerName or nil, zone = type(zone) == "string" and zone or nil}
	ListChanged()
end

-- During a visit, after a change (a spell learned): what's learned leaves the list. The filters aren't
-- touched here (each change of them makes the game update the list again).
local function RecordChanges()
	if not (Keeping() and IsClassTrainer()) then return end
	local spells = SavedSpells(false)
	if not spells then return end
	for index = 1, GetNumTrainerServices() do
		local name, rank, status, level, icon = ReadService(index)
		if name then
			local key = KeyOf(name, rank)
			if status == "used" then
				spells[key] = nil
			elseif status == "available" or status == "unavailable" then
				spells[key] = Describe(index, level, icon)
			end
		end
	end
	ListChanged()
end

-- The "Learn ticked" button --------------------------------------------------------------------------

local function ShowButtonTooltip(self)
	local count, total, list = Ticked()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(L["Learn ticked"], 1, 0.82, 0)
	if count == 0 then
		GameTooltip:AddLine(L["Tick the spells you want to learn, then click here: they're learned one after another."], 1, 1, 1, true)
	else
		for _, key in ipairs(list) do GameTooltip:AddLine(Trainer.Label(key), 1, 1, 1) end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(string.format(L["Total: %s"], Money(total)), 1, 1, 1)
		if total > (GetMoney() or 0) then
			GameTooltip:AddLine(L["Not enough money for all of them: those you can't pay are left ticked."], 1, 0.3, 0.3, true)
		end
	end
	GameTooltip:Show()
end

local function GetButton()
	if button then return button end
	if not ClassTrainerFrame then return nil end
	button = CreateFrame("Button", "KyoryokunaEnhancementsTrainerLearn", ClassTrainerFrame, "UIPanelButtonTemplate")
	button:SetSize(130, 22)
	local filter = ClassTrainerFrame.FilterDropdown
	if filter then
		button:SetPoint("RIGHT", filter, "LEFT", -6, 0)
	else
		button:SetPoint("TOPRIGHT", ClassTrainerFrame, "TOPRIGHT", -120, -35)
	end
	button:SetScript("OnClick", function() ns.SafeCall(Trainer.LearnTicked) end)
	button:SetScript("OnEnter", function(self) ns.SafeCall(ShowButtonTooltip, self) end)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return button
end

function Trainer.RefreshButton()
	if not (ns.db and Settings().choose and TrainerOpen()) then
		if button then button:Hide() end
		return
	end
	local learn = GetButton()
	if not learn then return end
	local count = Ticked()
	learn:SetText(learning and L["Learning..."] or string.format(L["Learn ticked (%d)"], count))
	-- As wide as its text
	local label = learn.GetFontString and learn:GetFontString()
	local width = label and label.GetStringWidth and label:GetStringWidth()
	if type(width) == "number" and width > 0 then learn:SetWidth(math.max(110, width + 28)) end
	if learning or count == 0 then learn:Disable() else learn:Enable() end
	learn:Show()
end

-- The boxes on the rows ------------------------------------------------------------------------------

local function GetCheck(row)
	if row.keChoose then return row.keChoose end
	local check = CreateFrame("CheckButton", nil, row)
	check:SetSize(22, 22)
	check:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -3, 3)
	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetScript("OnClick", function(self)
		if self.key then chosen[self.key] = self:GetChecked() and true or nil end
		ns.SafeCall(Trainer.RefreshButton)
	end)
	check:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Learn this spell"], 1, 0.82, 0)
		GameTooltip:AddLine(L["Ticked spells are learned with the \"Learn ticked\" button, at the top of the window."], 1, 1, 1, true)
		GameTooltip:Show()
	end)
	check:SetScript("OnLeave", function() GameTooltip:Hide() end)
	row.keChoose = check
	return check
end

-- A row made (or made again) by the game: its box, if it can be ticked
local function UpdateRow(row, elementData)
	if type(row) ~= "table" or (ClassTrainerFrame and row == ClassTrainerFrame.skillStepButton) then return end
	local data = type(elementData) == "table" and (elementData.data or elementData)
	local index = type(data) == "table" and data.skillIndex
	local key
	if index and ns.db and Settings().choose and IsClassTrainer() then key = Choosable(index) end
	if not key then
		if row.keChoose then row.keChoose:Hide() end
		return
	end
	local check = GetCheck(row)
	check.key = key
	check:SetChecked(chosen[key] == true)
	if learning then check:Disable() else check:Enable() end
	check:Show()
end
Trainer.UpdateRow = UpdateRow

-- Every row on view, and the button
local function RefreshAll()
	local scrollBox = ClassTrainerFrame and ClassTrainerFrame.ScrollBox
	if scrollBox and scrollBox.ForEachFrame then
		scrollBox:ForEachFrame(function(row)
			UpdateRow(row, row.GetElementData and row:GetElementData())
		end)
	end
	Trainer.RefreshButton()
end
Trainer.Refresh = RefreshAll

local function Install()
	if hooked or not ClassTrainerFrame_InitServiceButton then return end
	hooked = true
	hooksecurefunc("ClassTrainerFrame_InitServiceButton", function(row, elementData)
		ns.SafeCall(UpdateRow, row, elementData)
	end)
end

-- Learning what's ticked -------------------------------------------------------------------------------

local function FindKey(key)
	for index = 1, GetNumTrainerServices() do
		local name, rank, status = ReadService(index)
		if name and KeyOf(name, rank) == key then return index, status end
	end
end

local function After(seconds, func)
	if C_Timer and C_Timer.After then
		C_Timer.After(seconds, function() ns.SafeCall(func) end)
	else
		func()
	end
end

-- One step: wait for the spell asked to be taught, then ask for the next ticked one that can be paid
local function Step()
	if not learning then return end
	if not TrainerOpen() then
		learning = nil
		return
	end
	local pending = learning.pending
	if pending then
		local _, status = FindKey(pending)
		if status == "available" then
			if GetTime() < learning.deadline then
				After(0.1, Step)
				return
			end
			-- Not taught: left ticked, not asked again this time
			learning.tried[pending] = true
		else
			chosen[pending] = nil
			local spells = SavedSpells(false)
			if spells then spells[pending] = nil end
		end
		learning.pending = nil
	end
	local money = GetMoney() or 0
	for index = 1, GetNumTrainerServices() do
		local key, cost = Choosable(index)
		if key and chosen[key] and not learning.tried[key] and cost <= money then
			learning.pending, learning.deadline = key, GetTime() + WAIT
			BuyTrainerService(index)
			After(0.1, Step)
			return
		end
	end
	learning = nil
	RefreshAll()
end

function Trainer.LearnTicked()
	if learning or not (ns.db and Settings().choose and TrainerOpen()) then return end
	if Ticked() == 0 then return end
	learning = {tried = {}}
	RefreshAll()
	Step()
end

function Trainer.IsLearning()
	return learning ~= nil
end

-- The setting changed: the boxes and the button follow at once
function Trainer.Apply()
	if ClassTrainerFrame then RefreshAll() end
end

-- New spells at a new level ----------------------------------------------------------------------------

-- The saved spells by level, lowest first: {{level, spells = {{key, label, level, cost, icon, id}}}}, the
-- spells of a level sorted by name; nil when nothing is kept yet
function Trainer.List()
	local spells = SavedSpells(false)
	if type(spells) ~= "table" then return nil end
	local byLevel, levels = {}, {}
	for key, data in pairs(spells) do
		local level = data.level or 0
		if not byLevel[level] then
			byLevel[level] = {level = level, spells = {}}
			levels[#levels + 1] = byLevel[level]
		end
		table.insert(byLevel[level].spells, {key = key, label = Trainer.Label(key), level = level, cost = data.cost or 0,
			icon = data.icon, id = data.id})
	end
	table.sort(levels, function(a, b) return a.level < b.level end)
	for _, group in ipairs(levels) do
		table.sort(group.spells, function(a, b) return a.label < b.label end)
	end
	return levels
end

-- The trainer of the last visit: its name and place (either may be nil)
function Trainer.LastVisit()
	local entry = Character()
	local visit = entry and entry.trainerVisit
	if type(visit) ~= "table" then return nil end
	return visit.name, visit.zone
end

-- The saved spells: the ones the character can learn now (level reached), and the next levels', as
-- {level, labels} sorted by level
function Trainer.Waiting()
	local levels = Trainer.List()
	if not levels then return nil end
	local level = UnitLevel("player") or 0
	local now, upcoming = {}, {}
	for _, group in ipairs(levels) do
		local labels = {}
		for _, spell in ipairs(group.spells) do labels[#labels + 1] = spell.label end
		if group.level <= level then
			for _, label in ipairs(labels) do now[#now + 1] = label end
		else
			upcoming[#upcoming + 1] = {level = group.level, labels = labels}
		end
	end
	table.sort(now)
	return now, upcoming
end

ns.RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	if not (ns.db and Settings().notify) then return end
	level = tonumber(level)
	local spells = SavedSpells(false)
	if not level or type(spells) ~= "table" then return end
	local list = {}
	for key, data in pairs(spells) do
		if data.level == level then list[#list + 1] = Trainer.Label(key) end
	end
	if #list == 0 then return end
	table.sort(list)
	ns.Print(string.format(L["New at your trainer (level %d): %s."], level, table.concat(list, ", ")))
end)
ns.RegisterEvent("PLAYER_LEVEL_UP", function()
	-- The spells now in reach change color in the spellbook's tab
	if ns.SpellbookTab then ns.SpellbookTab.Refresh() end
end)

-- Events ---------------------------------------------------------------------------------------------

ns.RegisterEvent("ADDON_LOADED", function(_, name)
	if name == "Blizzard_TrainerUI" then Install() end
end)
ns.RegisterEvent("PLAYER_LOGIN", Install)
ns.RegisterEvent("TRAINER_SHOW", function()
	Install()
	wipe(chosen)
	learning = nil
	Record()
	RefreshAll()
	-- The game may show its window just after this event: once more when it's there
	After(0.1, RefreshAll)
end)
ns.RegisterEvent("TRAINER_UPDATE", function()
	RecordChanges()
	Trainer.RefreshButton()
end)
ns.RegisterEvent("TRAINER_CLOSED", function()
	wipe(chosen)
	learning = nil
	if button then button:Hide() end
end)
