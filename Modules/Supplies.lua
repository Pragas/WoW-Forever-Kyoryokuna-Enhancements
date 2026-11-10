-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Supplies: macros of this character, kept up to date by the addon, that eat and drink the best food
-- and drink in the bags. Dragged to an action bar once, they never need to be touched again:
--   KE Food        eats the best food;
--   KE Drink       drinks the best drink;
--   KE Food+Drink  both at once (sitting, both bars fill together).
--
-- Food and drink are told apart by the spell the item casts when used ("Food" or "Drink"), so it works
-- for anything bought, looted or conjured, for every class. The best is the one with the highest level
-- needed (that the character can already use), conjured first when even. Food with a buff ("well
-- fed") is kept for later unless the setting includes it.
--
-- Each character picks which of the three it wants (none at first). With nothing in the bags, a mage's
-- macro conjures more (the highest rank known, through a hidden
-- button that casts that exact rank); for anyone else it only says there's none.
--
-- The game doesn't let addons change macros in combat: they follow when the fight is over (nobody can
-- eat in combat anyway). A macro unticked is deleted.

local _, ns = ...
local L = ns.L

local Supplies = {}
ns.Supplies = Supplies

-- The spells the game casts when food or drink is used: their names, in the game's language, tell the
-- kind of an item
local FOOD_SPELL, DRINK_SPELL, WELL_FED_SPELL = 433, 430, 19705
local QUESTION_MARK = 134400
local DEFAULT_MAX_CHARACTER_MACROS = 18

-- The macros: their names (English and Portuguese, so a language change finds and renames them), what
-- they use, and what a mage conjures when there's nothing
local MACROS = {
	{key = "FOOD", name = "KE Food", uses = {"FOOD"}, conjure = {"FOOD"}},
	{key = "DRINK", name = "KE Drink", uses = {"DRINK"}, conjure = {"WATER"}},
	-- Water first: the mana it gives is what conjuring the rest needs
	{key = "BOTH", name = "KE Food+Drink", uses = {"FOOD", "DRINK"}, conjure = {"WATER", "FOOD"}},
}
Supplies.MACROS = MACROS

-- The hidden buttons a mage's macro clicks to conjure (a macro can't cast an exact rank by itself)
local CLICKER_NAMES = {FOOD = "KyoryokunaEnhancementsSuppliesFood", WATER = "KyoryokunaEnhancementsSuppliesWater"}

local clickers = {}
local pending = false
local warnedFull = false
local waitingForItems = false
-- What's known of each item seen: {kind = "FOOD"/"DRINK"/false, minLevel, buff, conjured}
local itemInfo = {}
-- The best of each kind now: {id, count} or nil (for the options page and the tests)
local best = {}

local function Known(value)
	return ns.Known and ns.Known(value) or value
end

local function SpellName(id)
	if C_Spell and C_Spell.GetSpellName then return Known(C_Spell.GetSpellName(id)) end
	if GetSpellInfo then return Known((GetSpellInfo(id))) end
end

-- Conjured food and drink, from the mage's catalog (Modules\MissingBuffs.lua): first when even
local conjured
local function IsConjured(id)
	if not conjured then
		conjured = {}
		local catalog = ns.MissingBuffs and ns.MissingBuffs.ITEMS and ns.MissingBuffs.ITEMS.MAGE or {}
		for _, family in ipairs(catalog) do
			if family.key == "FOOD" or family.key == "WATER" then
				for _, rank in ipairs(family.ranks) do
					for _, item in ipairs(rank.items) do conjured[item] = true end
				end
			end
		end
	end
	return conjured[id] == true
end

-- Whether the item's tooltip says it makes you well fed (food with a buff)
local function HasBuff(id)
	if not (C_TooltipInfo and C_TooltipInfo.GetItemByID) then return false end
	local ok, data = pcall(C_TooltipInfo.GetItemByID, id)
	if not ok or type(data) ~= "table" or type(data.lines) ~= "table" then return false end
	local wellFed = SpellName(WELL_FED_SPELL)
	wellFed = type(wellFed) == "string" and wellFed:lower() or nil
	for _, line in ipairs(data.lines) do
		local text = Known(line.leftText)
		if type(text) == "string" then
			text = text:lower()
			if text:find("well fed", 1, true) or (wellFed and text:find(wellFed, 1, true)) then return true end
		end
	end
	return false
end

-- What an item is: nil while the game hasn't loaded it yet (asked for, and read again when it comes)
local function ReadItem(id)
	local known = itemInfo[id]
	if known then return known end
	local spellName = C_Item and C_Item.GetItemSpell and Known((C_Item.GetItemSpell(id)))
	local kind = false
	if spellName then
		if spellName == (SpellName(FOOD_SPELL) or "Food") then kind = "FOOD"
		elseif spellName == (SpellName(DRINK_SPELL) or "Drink") then kind = "DRINK" end
	end
	if not kind then
		-- Not food nor drink (or not loaded yet: its spell comes with it)
		if C_Item and C_Item.IsItemDataCachedByID and not C_Item.IsItemDataCachedByID(id) then
			waitingForItems = true
			if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
			return nil
		end
		itemInfo[id] = {kind = false}
		return itemInfo[id]
	end
	local minLevel = C_Item.GetItemInfo and select(5, C_Item.GetItemInfo(id))
	minLevel = Known(minLevel)
	if type(minLevel) ~= "number" then
		waitingForItems = true
		if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
		return nil
	end
	itemInfo[id] = {kind = kind, minLevel = minLevel, buff = HasBuff(id), conjured = IsConjured(id)}
	return itemInfo[id]
end

local function BagSlots(bag)
	if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
	return 0
end

local function BagItem(bag, slot)
	if C_Container and C_Container.GetContainerItemID then return Known(C_Container.GetContainerItemID(bag, slot)) end
end

-- The best food and drink in the bags: {FOOD = {id, count}, DRINK = {id, count}}
function Supplies.FindBest()
	local settings = ns.db.supplies
	local level = UnitLevel and Known(UnitLevel("player")) or 1
	if type(level) ~= "number" then level = 1 end
	local counts = {}
	for bag = 0, NUM_BAG_SLOTS or 4 do
		for slot = 1, BagSlots(bag) do
			local id = BagItem(bag, slot)
			if type(id) == "number" then counts[id] = true end
		end
	end
	local found = {}
	for id in pairs(counts) do
		local info = ReadItem(id)
		if info and info.kind and info.minLevel <= level and (settings.buffFood or not info.buff) then
			local current = found[info.kind]
			local currentInfo = current and itemInfo[current.id]
			local better = not current or info.minLevel > currentInfo.minLevel
				or info.minLevel == currentInfo.minLevel and info.conjured and not currentInfo.conjured
				or info.minLevel == currentInfo.minLevel and info.conjured == currentInfo.conjured and id > current.id
			if better then found[info.kind] = {id = id} end
		end
	end
	for _, entry in pairs(found) do
		local count = C_Item and C_Item.GetItemCount and Known(C_Item.GetItemCount(entry.id))
		entry.count = type(count) == "number" and count or nil
	end
	return found
end

function Supplies.GetBest(kind)
	return best[kind]
end

-- The hidden button that conjures a family (only changed out of combat)
local function GetClicker(family, spell)
	local button = clickers[family]
	if not button then
		button = CreateFrame("Button", CLICKER_NAMES[family], UIParent, "SecureActionButtonTemplate")
		button:Hide()
		button:RegisterForClicks("AnyUp", "AnyDown")
		-- A macro's /click comes as a release: acted on then, whatever the key-down setting
		button:SetAttribute("useOnKeyDown", false)
		button:SetAttribute("type", "spell")
		clickers[family] = button
	end
	button:SetAttribute("spell", spell)
	return button
end

-- What a macro says now: its text, or nil when there's nothing it could do
local function MacroBody(macro, found)
	local lines = {}
	for _, kind in ipairs(macro.uses) do
		if found[kind] then lines[#lines + 1] = "/use item:" .. found[kind].id end
	end
	if #lines > 0 then
		-- The macro that does both shows the icon picked (the food's or the drink's) while it's there;
		-- otherwise the game shows the first item used
		local tooltip = "#showtooltip"
		local iconKind = #macro.uses > 1 and ns.db.supplies.bothIcon
		if iconKind and found[iconKind] then tooltip = "#showtooltip item:" .. found[iconKind].id end
		return tooltip .. "\n" .. table.concat(lines, "\n")
	end
	-- Nothing to eat or drink: a mage conjures the first family it knows
	local MB = ns.MissingBuffs
	for _, family in ipairs(macro.conjure) do
		local spell, name
		if MB and MB.BestConjure then spell, name = MB.BestConjure(family) end
		if spell then
			GetClicker(family, spell)
			return "#showtooltip " .. (name or "") .. "\n/click " .. CLICKER_NAMES[family]
		end
	end
	return "/run KyoryokunaEnhancements_SuppliesEmpty(\"" .. macro.key .. "\")"
end

-- A click with nothing in the bags
function KyoryokunaEnhancements_SuppliesEmpty(key)
	if key == "DRINK" then ns.Print(L["No drink in your bags."])
	elseif key == "BOTH" then ns.Print(L["No food or drink in your bags."])
	else ns.Print(L["No food in your bags."]) end
end

-- Where a macro of the addon is: found by its name in either language
local function FindMacro(macro)
	if not GetMacroIndexByName then return 0 end
	for _, name in ipairs({L[macro.name], macro.name, ns.LOCALES and ns.LOCALES.ptPT and ns.LOCALES.ptPT[macro.name]}) do
		if type(name) == "string" then
			local index = GetMacroIndexByName(name)
			if index and index > 0 then return index end
		end
	end
	return 0
end

local function HasRoom()
	if not GetNumMacros then return false end
	local _, perCharacter = GetNumMacros()
	return (perCharacter or 0) < (MAX_CHARACTER_MACROS or DEFAULT_MAX_CHARACTER_MACROS)
end

local function Changed()
	ns.SafeCall(Supplies.Update)
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Which macros this character wants (kept for each character, with its missing buffs): a warrior may
-- want only the food one, a mage all three
local function Choices()
	local entry = ns.MissingBuffs and ns.MissingBuffs.GetCharacter and ns.MissingBuffs.GetCharacter()
	if not entry then return nil end
	if type(entry.supplies) ~= "table" then entry.supplies = {} end
	return entry.supplies
end

function Supplies.IsOn(key)
	local choices = Choices()
	return choices ~= nil and choices[key] == true
end

function Supplies.SetOn(key, on)
	local choices = Choices()
	if not choices then return end
	choices[key] = on and true or nil
	Changed()
end

function Supplies.AnyOn()
	for _, macro in ipairs(MACROS) do
		if Supplies.IsOn(macro.key) then return true end
	end
	return false
end

-- Every macro written as it should be now (out of combat only); the ones not wanted are deleted
function Supplies.Update()
	if not ns.db then return end
	if InCombatLockdown and InCombatLockdown() then
		pending = true
		return
	end
	if not Choices() then return end
	pending = false
	waitingForItems = false
	best = Supplies.FindBest()
	for _, macro in ipairs(MACROS) do
		local name = L[macro.name]
		local index = FindMacro(macro)
		if not Supplies.IsOn(macro.key) then
			if index > 0 and DeleteMacro then DeleteMacro(index) end
		elseif index > 0 then
			local body = MacroBody(macro, best)
			local oldName, _, oldBody = GetMacroInfo(index)
			if oldName ~= name or oldBody ~= body then EditMacro(index, name, QUESTION_MARK, body) end
		elseif HasRoom() then
			CreateMacro(name, QUESTION_MARK, MacroBody(macro, best), true)
		elseif not warnedFull then
			warnedFull = true
			ns.Print(L["Supplies: no room for its macros. Free a slot in this character's macros (/macro), then type /reload."])
		end
	end
end

-- The macro on the mouse cursor, to drop on an action bar (the options page's "Pick up")
function Supplies.PickUp(key)
	for _, macro in ipairs(MACROS) do
		if macro.key == key then
			local index = FindMacro(macro)
			if index > 0 and PickupMacro then PickupMacro(index) end
			return index > 0
		end
	end
	return false
end

-- The bags, the level (better food can be used), the spells (a new rank to conjure), the end of a fight
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "BAG_UPDATE_DELAYED", "PLAYER_LEVEL_UP", "SPELLS_CHANGED"}) do
	ns.RegisterEvent(event, Changed)
end
ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if pending then Changed() end
end)
-- An item the game had to load first
ns.RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
	if waitingForItems and ns.db and Supplies.AnyOn() then Changed() end
end)

-- For the tests
function Supplies.ForgetItems()
	itemInfo, conjured, warnedFull = {}, nil, false
end
