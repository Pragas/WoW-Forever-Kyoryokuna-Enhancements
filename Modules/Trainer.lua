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
--     The trainer's whole list is also kept for the class, on the account: another character of that class
--     that hasn't been to its trainer yet uses it (less what it knows already).
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

-- One line of the trainer: its name, rank, state (available, unavailable, used), the level it needs, its
-- icon, and the group the trainer's window puts it in (WoW Forever). The game gave these in another order
-- in older versions; both are read.
local function ReadService(index)
	local name, second, third, fourth, fifth, sixth = GetTrainerServiceInfo(index)
	local rank, status, level, icon, category
	if SERVICE_TYPES[second] then
		status, icon, level, rank, category = second, third, fourth, fifth, sixth
	else
		rank, status = second, third
		icon = GetTrainerServiceIcon and GetTrainerServiceIcon(index)
	end
	if (tonumber(level) or 0) == 0 and GetTrainerServiceLevelReq then level = GetTrainerServiceLevelReq(index) end
	if type(name) ~= "string" then return nil end
	return name, type(rank) == "string" and rank or "", status, tonumber(level) or 0, icon,
		type(category) == "string" and category ~= "" and category or nil
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

-- The character's class ("MAGE"), or nil
local function ClassOf()
	local _, class = UnitClass("player")
	return type(class) == "string" and class or nil
end

-- The class's whole list, kept on the account at the last visit of any of its characters:
-- {spells = {key -> {level, cost, icon, id, requires}}, visit = {name, zone, by}}, or nil
local function ClassList(create)
	local class = ClassOf()
	if not (ns.db and class) then return nil end
	if create then
		if type(ns.db.trainerClasses) ~= "table" then ns.db.trainerClasses = {} end
		if type(ns.db.trainerClasses[class]) ~= "table" then ns.db.trainerClasses[class] = {spells = {}} end
	end
	local list = type(ns.db.trainerClasses) == "table" and ns.db.trainerClasses[class]
	if not (type(list) == "table" and type(list.spells) == "table") then return nil end
	-- Not read yet: as if there were none
	if not create and next(list.spells) == nil then return nil end
	return list
end

-- The trainer's list is kept for the new spells told in the chat and for the spellbook's tab
local function Keeping()
	local settings = Settings()
	return settings.notify or settings.spellbookTab
end

-- A spell's name without its rank in brackets ("Pyroblast (Rank 1)" -> "Pyroblast")
local function BaseName(name)
	return (name:gsub("%s*%(.-%)%s*$", ""))
end

-- The number of a rank ("Rank 4" -> 4), or nil
local function RankNumber(rank)
	return tonumber((type(rank) == "string" and rank or ""):match("(%d+)"))
end

-- The spells taught from their first rank (by name), among {name, rank} lines: a "Rank 1", or a spell
-- without ranks. Higher ranks alone don't count (a talent's spell has those too), nor a line without its
-- rank while other ranks of that spell are there (read before the game had its rank's text).
local function FirstRanks(lines)
	local first, ranked, unranked = {}, {}, {}
	for _, line in ipairs(lines) do
		local name, number = line[1], RankNumber(line[2])
		if number then
			ranked[name] = true
			if number <= 1 then first[name] = true end
		else
			unranked[name] = true
		end
	end
	for name in pairs(unranked) do
		if not ranked[name] then first[name] = true end
	end
	return first
end

-- The {name, rank} lines of a kept list (keys "Name\tRank"), less the keys left out
local function LinesOf(spells, leftOut, lines)
	lines = lines or {}
	for key in pairs(spells) do
		local name, rank = key:match("^(.-)\t(.*)$")
		if name and not (leftOut and leftOut[key]) then lines[#lines + 1] = {name, rank} end
	end
	return lines
end

-- The keys of a kept list without a rank whose spell has ranks there too: the same spell as its highest
-- rank, read before the game had its rank's text ("Mage Armor" beside "Mage Armor Rank 3")
local function Duplicates(spells)
	local ranked, duplicates = {}, {}
	for key in pairs(spells) do
		local name, rank = key:match("^(.-)\t(.*)$")
		if name and RankNumber(rank) then ranked[name] = true end
	end
	for key in pairs(spells) do
		local name, rank = key:match("^(.-)\t(.*)$")
		if name and not RankNumber(rank) and ranked[name] then duplicates[key] = true end
	end
	return duplicates
end

-- The ability a line needs that this trainer doesn't teach (offered: the names on its list), or nil: a
-- talent, or a spell of another specialization (Pyroblast Rank 2 needs Pyroblast, which only its talent
-- gives). Only one the character doesn't have, or (anyone) whoever has it, for the class's list.
local function MissingAbility(index, offered, anyone)
	if not (GetTrainerServiceNumAbilityReq and GetTrainerServiceAbilityReq) then return nil end
	for i = 1, tonumber(GetTrainerServiceNumAbilityReq(index)) or 0 do
		local ability, has = GetTrainerServiceAbilityReq(index, i)
		if type(ability) == "string" and (anyone or not has) then
			local name = BaseName(ability)
			if not offered[name] then return name end
		end
	end
end

-- The spells the trainer teaches from their first rank (by name): on its list now, and in the class's list
-- of this visit (the learned ones are on the trainer's list only while its "Used" filter is on)
local function Offered(classSpells)
	local lines = classSpells and LinesOf(classSpells, Duplicates(classSpells)) or {}
	for index = 1, GetNumTrainerServices() do
		local name, rank = ReadService(index)
		if name then lines[#lines + 1] = {name, rank} end
	end
	return FirstRanks(lines)
end

-- The spell of a line, or nil
local function SpellOf(index)
	if not (C_TooltipInfo and C_TooltipInfo.GetTrainerService) then return nil end
	local ok, data = pcall(C_TooltipInfo.GetTrainerService, index)
	if ok and type(data) == "table" and type(data.id) == "number" then return data.id end
end

-- The level a spell is learned at, as the game says (the trainer gives none for a spell learned), or nil
local function LevelOf(spellID)
	if not (spellID and C_Spell and C_Spell.GetSpellLevelLearned) then return nil end
	local ok, level = pcall(C_Spell.GetSpellLevelLearned, spellID)
	level = ok and tonumber(ns.Known(level)) or nil
	return level and level > 0 and level or nil
end

-- What's kept of a line: the level it needs, its cost, its icon, its spell (for its tooltip), an ability
-- it needs that the trainer doesn't teach, the trainer that teaches it, and its group on that trainer
local function Describe(index, level, icon, offered, anyone, spellID, from, category)
	local cost = GetTrainerServiceCost(index)
	return {level = level, cost = tonumber(cost) or 0, icon = tonumber(icon) or icon, id = spellID,
		requires = MissingAbility(index, offered, anyone), from = from, category = category}
end

-- A trainer's spells taken out of a kept list (at the start of a new visit to it); the other trainers'
-- stay. Spells kept before trainers were told apart go too.
local function Forget(spells, from)
	for key, data in pairs(spells) do
		if data.from == nil or data.from == from then spells[key] = nil end
	end
end

-- After a change of the list: the page and the spellbook's tab show it again
local function ListChanged()
	if ns.RebuildOptionsPage then ns.RebuildOptionsPage("Trainer") end
	if ns.SpellbookTab then ns.SpellbookTab.Refresh() end
end

-- Reading the trainer's list -----------------------------------------------------------------------------
--
-- Every trainer that opens the class trainer's window counts: the class trainer, and in WoW Forever also the
-- mage's portal trainer, the weapon masters and the riding trainers. Each kept spell says which trainer
-- teaches it ("from"): a visit to a trainer starts its own spells again and leaves the others' alone, and the
-- lists shown put all of them together.
--
-- The game sends the trainer's list a little after the visit starts, and again after each change (a spell
-- learned, a filter changed: TRAINER_UPDATE), never at once. So the list is read each time it comes: the
-- first reading of a visit starts that trainer's spells again, the next ones add to them. The spells for
-- later levels only show with the trainer's "Unavailable" filter, the ones learned with its "Used" filter:
-- those that are off are turned on at the start of the visit, and put back as they were as soon as the list
-- has come with their spells (or half a second later, if it has none of them).
--
-- The learned spells are only wanted once for the class, from each trainer: its list keeps them, and the
-- ones learned later were on the trainer's list before. Once it has them from a trainer ("complete"),
-- "Used" is never turned on again there, and that trainer's spells in the class's list are added to, not
-- started again, so the learned spells don't flash on the trainer's window at each visit.

-- This visit: the trainer's name and place, who went, the filters turned on (to put back), the kinds of
-- spells read (available, unavailable, used), whether the character's list is still the last visit's, and
-- whether the class's list is kept and added to
local visit

local function After(seconds, func)
	if C_Timer and C_Timer.After then
		C_Timer.After(seconds, function() ns.SafeCall(func) end)
	else
		func()
	end
end

local function RestoreFilters()
	local turnedOn = visit and visit.turnedOn
	if not turnedOn then return end
	visit.turnedOn, visit.restoring = nil, nil
	if SetTrainerServiceTypeFilter then
		for _, filter in ipairs(turnedOn) do SetTrainerServiceTypeFilter(filter, false) end
	end
end

-- What the trainer shows now, kept: for the character, the spells not learned yet (the learned ones leave
-- its list); for its class, every spell. False while there's nothing to read yet.
local function Read()
	if not (visit and Keeping() and IsClassTrainer()) then return false end
	local count = GetNumTrainerServices() or 0
	local spells = SavedSpells(true)
	if count == 0 or not spells then return false end
	local classList = ClassList(true)
	local from = visit.name
	if visit.fresh then
		visit.fresh = false
		Forget(spells, from)
		if classList and not visit.keepClass then
			Forget(classList.spells, from)
			if type(classList.complete) == "table" then classList.complete[from] = nil end
		end
	end
	local offered = Offered(classList and classList.spells)
	for index = 1, count do
		local name, rank, status, level, icon, category = ReadService(index)
		local _, isProfession = GetTrainerServiceCost(index)
		if name and not isProfession and SERVICE_TYPES[status] then
			visit.seen[status] = true
			local spellID = SpellOf(index)
			-- Its rank's text not loaded yet on the trainer's list: the spell's own
			if not RankNumber(rank) and spellID and C_Spell and C_Spell.GetSpellSubtext then
				local text = ns.Known(C_Spell.GetSpellSubtext(spellID))
				if RankNumber(text) then rank = text end
			end
			local key = KeyOf(name, rank)
			-- A spell learned: the trainer gives no level
			if level == 0 then
				local before = spells[key] or (classList and classList.spells[key])
				level = LevelOf(spellID) or (before and before.level) or 0
			end
			if status == "used" then
				spells[key] = nil
			else
				spells[key] = Describe(index, level, icon, offered, false, spellID, from, category)
			end
			if classList then classList.spells[key] = Describe(index, level, icon, offered, true, spellID, from, category) end
		end
	end
	-- A spell read without its rank, then with it: once
	for key in pairs(Duplicates(spells)) do spells[key] = nil end
	if classList then
		for key in pairs(Duplicates(classList.spells)) do classList.spells[key] = nil end
	end
	-- The trainers visited, and where
	local entry = Character()
	if type(entry.trainerVisits) ~= "table" then entry.trainerVisits = {} end
	entry.trainerVisits[from] = visit.zone or ""
	if classList and next(classList.spells) then
		if type(classList.visits) ~= "table" then classList.visits = {} end
		classList.visits[from] = {zone = visit.zone, by = visit.by}
		-- The learned spells read: the class's list has them from this trainer for good
		if visit.seen.used then
			if type(classList.complete) ~= "table" then classList.complete = {} end
			classList.complete[from] = true
		end
	end
	ListChanged()
	return true
end

-- The list came (or changed): read. The filters turned on are put back as soon as their spells have come;
-- if they don't (none of that kind), half a second after the first reading, after one more.
local function OnList()
	if not Read() then return end
	if not visit.turnedOn then return end
	local allCame = true
	for _, filter in ipairs(visit.turnedOn) do
		if not visit.seen[filter] then allCame = false end
	end
	if allCame then
		RestoreFilters()
	elseif not visit.restoring then
		visit.restoring = true
		After(0.5, function()
			if not (visit and visit.restoring) then return end
			Read()
			RestoreFilters()
		end)
	end
end

-- The class's list already has the learned spells of this trainer
local function ClassComplete(from)
	local class = ClassOf()
	local list = class and type(ns.db.trainerClasses) == "table" and ns.db.trainerClasses[class]
	return type(list) == "table" and type(list.complete) == "table" and list.complete[from] == true
		and type(list.spells) == "table" and next(list.spells) ~= nil
end

local function StartVisit()
	visit = nil
	if not (Keeping() and IsClassTrainer()) then return end
	local trainerName = UnitName and ns.Known(UnitName("npc"))
	trainerName = type(trainerName) == "string" and trainerName or "?"
	local zone = GetZoneText and ns.Known(GetZoneText())
	local by = UnitName and ns.Known(UnitName("player"))
	local complete = ClassComplete(trainerName)
	visit = {fresh = true, seen = {}, keepClass = complete, name = trainerName,
		zone = type(zone) == "string" and zone or nil, by = type(by) == "string" and by or nil}
	if GetTrainerServiceTypeFilter and SetTrainerServiceTypeFilter then
		local turnedOn = {}
		for _, filter in ipairs({"available", "unavailable", "used"}) do
			-- The learned spells only while the class's list doesn't have them
			if not GetTrainerServiceTypeFilter(filter) and not (filter == "used" and complete) then
				SetTrainerServiceTypeFilter(filter, true)
				turnedOn[#turnedOn + 1] = filter
			end
		end
		if #turnedOn > 0 then visit.turnedOn = turnedOn end
	end
	OnList()
end

local function EndVisit()
	RestoreFilters()
	visit = nil
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

-- The spells the character has in its spellbook (its own specialization's, not the ones shown for others
-- nor the ones still to come): their names, and the highest rank of each
local function Book()
	local names, ranks = {}, {}
	local book = C_SpellBook
	if not (book and book.GetNumSpellBookSkillLines and book.GetSpellBookSkillLineInfo and book.GetSpellBookItemInfo) then
		return names, ranks
	end
	local bank = (Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player) or 0
	local spellType = (Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.Spell) or 1
	for line = 1, book.GetNumSpellBookSkillLines() or 0 do
		local info = book.GetSpellBookSkillLineInfo(line)
		if info and not info.offSpecID and info.itemIndexOffset and info.numSpellBookItems then
			for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
				local item = book.GetSpellBookItemInfo(slot, bank)
				local name = item and ns.Known(item.name)
				if not name and item and item.spellID and C_Spell and C_Spell.GetSpellName then
					name = ns.Known(C_Spell.GetSpellName(item.spellID))
				end
				if item and item.itemType == spellType and not item.isOffSpec and type(name) == "string" then
					names[name] = true
					local sub = ns.Known(item.subName)
					if (type(sub) ~= "string" or sub == "") and item.spellID and C_Spell and C_Spell.GetSpellSubtext then
						sub = ns.Known(C_Spell.GetSpellSubtext(item.spellID))
					end
					local rank = RankNumber(sub)
					if rank and rank > (ranks[name] or 0) then ranks[name] = rank end
				end
			end
		end
	end
	return names, ranks
end

-- A kept spell the character has learned already: its spell known, or in the spellbook (a spell without
-- ranks by its name; a rank, when the book has that rank or a higher one)
local function Learned(key, data, names, ranks)
	if type(data.id) == "number" and C_SpellBook and C_SpellBook.IsSpellKnown then
		local ok, known = pcall(C_SpellBook.IsSpellKnown, data.id)
		if ok and known == true then return true end
	end
	local name, rank = key:match("^(.-)\t(.*)$")
	if not (name and names[name]) then return false end
	local number = RankNumber(rank)
	if not number then return true end
	return ranks[name] ~= nil and number <= ranks[name]
end

-- The kept spells the character can really learn, by key. Left out: what it has learned already, a spell
-- needing an ability it doesn't have and the trainer doesn't teach (as the trainer says), and a higher
-- rank of a spell it doesn't have whose first rank the trainer doesn't teach (a talent, or another
-- specialization's spell: Pyroblast Rank 2 for a frost mage). Once the character has that spell, its ranks
-- show again.
local function Reachable(spells)
	local known, ranks = Book()
	-- A spell read without its rank beside its ranks (kept before this was seen): left out
	local duplicates = Duplicates(spells)
	-- The spells the trainer teaches from their first rank
	local startable = FirstRanks(LinesOf(spells, duplicates))
	local reachable = {}
	for key, data in pairs(spells) do
		local name, rank = key:match("^(.-)\t(.*)$")
		local ok = not duplicates[key] and not Learned(key, data, known, ranks)
		-- An ability it needs that it doesn't have, and the trainer doesn't teach from its first rank
		if ok and type(data.requires) == "string" and not known[data.requires] and not startable[data.requires] then ok = false end
		if ok and name and (RankNumber(rank) or 1) > 1 and not known[name] and not startable[name] then ok = false end
		if ok then reachable[key] = data end
	end
	return reachable
end

-- The trainers the character has been to (name -> place, "" when unknown)
local function Visited()
	local entry = Character()
	return entry and type(entry.trainerVisits) == "table" and entry.trainerVisits or {}
end

-- The list to show, every trainer's together: the character's own spells from the trainers it has been to,
-- and its class's from the others (another character's visits); and the class's list when some come from
-- it. Nil when nothing is kept yet.
local function Source()
	local own = SavedSpells(false)
	local classList = ClassList(false)
	if type(own) ~= "table" and not classList then return nil end
	local visited = Visited()
	local spells, shared = {}, nil
	if classList then
		for key, data in pairs(classList.spells) do
			if not (data.from and visited[data.from]) then
				spells[key] = data
				shared = classList
			end
		end
	end
	if type(own) == "table" then
		for key, data in pairs(own) do spells[key] = data end
	end
	return spells, shared
end

-- The spells it can learn by level, lowest first: {{level, spells = {{key, label, level, cost, icon, id}}}},
-- the spells of a level sorted by name; nil when nothing is kept yet
function Trainer.List()
	local spells = Source()
	if type(spells) ~= "table" then return nil end
	spells = Reachable(spells)
	local byLevel, levels = {}, {}
	for key, data in pairs(spells) do
		-- A spell learned by the one who went whose level the game didn't say: from the start
		local level = math.max(1, data.level or 0)
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

-- Where the list comes from: the trainer with the most spells in it, its place (either may be nil), the
-- character who went there when it's another's of the class (nil when it's the character's own), and the
-- other trainers with spells in it (their names, sorted)
function Trainer.LastVisit()
	local spells, shared = Source()
	if not spells then return nil end
	local counts = {}
	for _, data in pairs(spells) do
		if data.from then counts[data.from] = (counts[data.from] or 0) + 1 end
	end
	local main
	for name, count in pairs(counts) do
		if not main or count > counts[main] or (count == counts[main] and name < main) then main = name end
	end
	if not main then return nil end
	local others = {}
	for name in pairs(counts) do
		if name ~= main then others[#others + 1] = name end
	end
	table.sort(others)
	local zone = Visited()[main]
	if zone ~= nil then return main, zone ~= "" and zone or nil, nil, others end
	local info = shared and type(shared.visits) == "table" and shared.visits[main] or {}
	local own = UnitName and ns.Known(UnitName("player"))
	return main, info.zone, (info.by ~= own) and info.by or nil, others
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
	local levels = Trainer.List()
	if not level or not levels then return end
	local list = {}
	for _, group in ipairs(levels) do
		if group.level == level then
			for _, spell in ipairs(group.spells) do list[#list + 1] = spell.label end
		end
	end
	if #list == 0 then return end
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
	StartVisit()
	RefreshAll()
	-- The game may show its window just after this event: once more when it's there
	After(0.1, RefreshAll)
end)
ns.RegisterEvent("TRAINER_UPDATE", function()
	OnList()
	Trainer.RefreshButton()
end)
-- The names and ranks of the trainer's list loaded meanwhile (one event each): read again once, a moment
-- after the last
local readSoon = false
ns.RegisterEvent("TRAINER_SERVICE_INFO_NAME_UPDATE", function()
	if readSoon or not visit then return end
	readSoon = true
	After(0.3, function()
		readSoon = false
		OnList()
	end)
end)
ns.RegisterEvent("TRAINER_CLOSED", function()
	EndVisit()
	wipe(chosen)
	learning = nil
	if button then button:Hide() end
end)
