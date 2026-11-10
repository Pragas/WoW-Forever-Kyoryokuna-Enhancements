-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Missing buffs (Missing Buffs page): what a character should always have on it, read from its
-- spellbook. The player ticks what to watch; while one is missing, its icon shows on the screen, grey and
-- faded, in and out of combat (not while dead).
--
--   - Two kinds: buffs (missing when not on the character) and conjured items (missing when the bags
--     hold fewer than a minimum: mana gems, conjured food and water, healthstones...).
--   - Two groups, each with its own place and look: Essential and Utility. Each thing ticked goes to the
--     group the player picks (buffs start in Essential, items in Utility).
--   - The choice is kept for each character. A new character with nothing chosen can copy the choice of
--     another character of its class (the page offers it, and the chat says so once).
--   - Buffs that can't be on together (the armors of a mage, the aspects of a hunter...) are one
--     "family": one line, one icon, and any of them is enough. Its icon can be picked, or be the one last
--     used. The same buff from someone else counts too, and so do the group versions (Arcane Brilliance
--     for Arcane Intellect...). Every rank counts: buffs are matched by name, items by every rank's item.
--   - In combat the game may hide the auras (or the counts) from addons: then the icons stay as they were
--     last known, instead of guessing. /ke buffscan shows what can be read.

local _, ns = ...
local L = ns.L

local MissingBuffs = {}
ns.MissingBuffs = MissingBuffs

local ESSENTIAL, UTILITY = "ESSENTIAL", "UTILITY"
MissingBuffs.GROUPS = {ESSENTIAL, UTILITY}
-- The settings of each group's look and place
local GROUP_SETTINGS = {[ESSENTIAL] = "missingBuffsEssential", [UTILITY] = "missingBuffsUtility"}
local MAX_MINIMUM = 20

-- The usual buffs of each class: families of spells (one ID each; every rank shares the name), and the
-- buffs that count for them without being in the family (group versions, other sources)
local BUFFS = {
	MAGE = {
		{key = "ARMOR", spells = {168, 7302, 6117, 30482}}, -- Frost, Ice, Mage, Molten Armor
		{key = "INTELLECT", spells = {1459}, also = {23028, 61024, 61316}}, -- Arcane Intellect; Brilliance, Dalaran
		{key = "MAGIC", spells = {604, 1008}}, -- Dampen Magic, Amplify Magic
	},
	PRIEST = {
		{key = "FORTITUDE", spells = {1243}, also = {21562}}, -- Power Word: Fortitude; Prayer of Fortitude
		{key = "INNER_FIRE", spells = {588}},
		{key = "SHADOW_PROTECTION", spells = {976}, also = {27683}},
		{key = "DIVINE_SPIRIT", spells = {14752}, also = {27681}},
		{key = "FEAR_WARD", spells = {6346}},
		{key = "SHADOWFORM", spells = {15473}},
		{key = "TOUCH_OF_WEAKNESS", spells = {2652}},
		{key = "SHADOWGUARD", spells = {18137}},
	},
	DRUID = {
		{key = "WILD", spells = {1126}, also = {21849}}, -- Mark of the Wild; Gift of the Wild
		{key = "THORNS", spells = {467}},
		{key = "OMEN", spells = {16864}}, -- Omen of Clarity
	},
	PALADIN = {
		-- Might, Wisdom, Kings, Salvation, Sanctuary, Light; and their greater versions
		{key = "BLESSING", spells = {19740, 19742, 20217, 1038, 20911, 19977}, also = {25782, 25894, 25898, 25895, 25899, 25890}},
		-- Devotion, Retribution, Concentration, Shadow, Frost and Fire Resistance, Sanctity, Crusader
		{key = "AURA", spells = {465, 7294, 19746, 19876, 19888, 19891, 20218, 32223}},
		{key = "RIGHTEOUS_FURY", spells = {25780}},
	},
	WARLOCK = {
		{key = "ARMOR", spells = {687, 706, 28176}}, -- Demon Skin, Demon Armor, Fel Armor
		{key = "SOUL_LINK", spells = {19028}},
	},
	HUNTER = {
		-- Hawk, Monkey, Cheetah, Pack, Wild, Beast, Viper, Dragonhawk
		{key = "ASPECT", spells = {13165, 13163, 5118, 13159, 20043, 13161, 34074, 61846}},
		{key = "TRUESHOT", spells = {19506}},
	},
	WARRIOR = {
		{key = "BATTLE_SHOUT", spells = {6673}},
		{key = "COMMANDING_SHOUT", spells = {469}},
	},
	SHAMAN = {
		{key = "SHIELD", spells = {324, 24398, 974}}, -- Lightning, Water, Earth Shield
	},
	DEATHKNIGHT = {
		{key = "HORN", spells = {57330}}, -- Horn of Winter
		{key = "BONE_SHIELD", spells = {49222}},
	},
}

-- The items a class conjures: the ranks of the spell, each with the items it makes (checked on Wowhead,
-- Classic and TBC). Any rank's item counts.
local ITEMS = {
	MAGE = {
		{key = "MANA_AGATE", ranks = {{spell = 759, items = {5514}}}},
		{key = "MANA_JADE", ranks = {{spell = 3552, items = {5513}}}},
		{key = "MANA_CITRINE", ranks = {{spell = 10053, items = {8007}}}},
		{key = "MANA_RUBY", ranks = {{spell = 10054, items = {8008}}}},
		{key = "MANA_EMERALD", ranks = {{spell = 27101, items = {22044}}}},
		{key = "FOOD", ranks = {
			{spell = 587, items = {5349}}, {spell = 597, items = {1113}}, {spell = 990, items = {1114}},
			{spell = 6129, items = {1487}}, {spell = 10144, items = {8075}}, {spell = 10145, items = {8076}},
			{spell = 28612, items = {22895}}, {spell = 33717, items = {22019}},
		}},
		{key = "WATER", ranks = {
			{spell = 5504, items = {5350}}, {spell = 5505, items = {2288}}, {spell = 5506, items = {2136}},
			{spell = 6127, items = {3772}}, {spell = 10138, items = {8077}}, {spell = 10139, items = {8078}},
			{spell = 10140, items = {8079}}, {spell = 37420, items = {30703}}, {spell = 27090, items = {22018}},
		}},
	},
	WARLOCK = {
		-- With the talent that improves them, the same stones have items of their own
		{key = "HEALTHSTONE", ranks = {
			{spell = 6201, items = {5512, 19004, 19005}}, {spell = 6202, items = {5511, 19006, 19007}},
			{spell = 5699, items = {5509, 19008, 19009}}, {spell = 11729, items = {5510, 19010, 19011}},
			{spell = 11730, items = {9421, 19012, 19013}},
		}},
		{key = "SOULSTONE", ranks = {
			{spell = 693, items = {5232}}, {spell = 20752, items = {16892}}, {spell = 20755, items = {16893}},
			{spell = 20756, items = {16895}}, {spell = 20757, items = {16896}},
		}},
		{key = "SPELLSTONE", ranks = {{spell = 2362, items = {5522}}, {spell = 17727, items = {13602}}, {spell = 17728, items = {13603}}}},
		{key = "FIRESTONE", ranks = {
			{spell = 6366, items = {1254}}, {spell = 17951, items = {13699}}, {spell = 17952, items = {13700}},
			{spell = 17953, items = {13701}},
		}},
	},
}
MissingBuffs.BUFFS, MissingBuffs.ITEMS = BUFFS, ITEMS

-- The icon shown when nothing is chosen yet, while moving the icons
local PLACEHOLDER_ICON = 134400

local characterKey, playerClass, className

-- Spells and items ------------------------------------------------------------------------------------

local function SpellName(id)
	if C_Spell and C_Spell.GetSpellName then return ns.Known(C_Spell.GetSpellName(id)) end
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(id)
		return info and ns.Known(info.name)
	end
	if GetSpellInfo then return ns.Known((GetSpellInfo(id))) end
end

local function SpellIcon(id)
	if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(id) end
	if GetSpellTexture then return GetSpellTexture(id) end
end

local function ItemIcon(id)
	if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
	if GetItemIcon then return GetItemIcon(id) end
end

-- How many of an item the bags hold; nil when the game hides it
local function ItemCount(id)
	local count
	if C_Item and C_Item.GetItemCount then count = C_Item.GetItemCount(id)
	elseif GetItemCount then count = GetItemCount(id) end
	count = ns.Known(count)
	return type(count) == "number" and count or nil
end

-- The spells this character has learned (not passive, not of another specialization), by name:
-- {ids = {every rank's ID}, icon}
local spellbook = {}
local spellbookSignature = ""

local function ReadSpellbook()
	local found = {}
	local book = C_SpellBook
	if book and book.GetNumSpellBookSkillLines and book.GetSpellBookSkillLineInfo and book.GetSpellBookItemInfo then
		local bank = (Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player) or 0
		local spellType = (Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.Spell) or 1
		for line = 1, book.GetNumSpellBookSkillLines() or 0 do
			local lineInfo = book.GetSpellBookSkillLineInfo(line)
			if lineInfo and not lineInfo.offSpecID and lineInfo.itemIndexOffset and lineInfo.numSpellBookItems then
				for index = lineInfo.itemIndexOffset + 1, lineInfo.itemIndexOffset + lineInfo.numSpellBookItems do
					local item = book.GetSpellBookItemInfo(index, bank)
					if item and item.itemType == spellType and item.spellID and not item.isPassive and not item.isOffSpec then
						local name = ns.Known(item.name) or SpellName(item.spellID)
						if name then
							local entry = found[name] or {ids = {}, icon = item.iconID or SpellIcon(item.spellID)}
							entry.ids[#entry.ids + 1] = item.spellID
							found[name] = entry
						end
					end
				end
			end
		end
	end
	local names = {}
	for name in pairs(found) do names[#names + 1] = name end
	table.sort(names)
	local signature = table.concat(names, "\n")
	local changed = signature ~= spellbookSignature
	spellbook, spellbookSignature = found, signature
	return changed
end

-- The choices of this character. Each: {key, kind = "BUFF" or "ITEM", label, icon, group (where it
-- starts)}; a buff also has members (names known, with memberIcons) and counts (names that count); an
-- item has items (every rank's item IDs).
--   suggested: the buff families of its class it knows a spell of
--   items: the items of its class it knows a spell to make
--   others: every other spell of its spellbook, as a buff
local suggested, items, others

local function BuildChoices()
	suggested, items, others = {}, {}, {}
	local inCatalog = {}
	for _, family in ipairs(BUFFS[playerClass] or {}) do
		local choice = {key = family.key, kind = "BUFF", group = ESSENTIAL, members = {}, memberIcons = {}, counts = {}}
		for _, id in ipairs(family.spells) do
			local name = SpellName(id)
			if name then
				inCatalog[name] = true
				choice.counts[name] = true
				local known = spellbook[name]
				if known then
					choice.members[#choice.members + 1] = name
					choice.memberIcons[name] = known.icon or SpellIcon(id)
					choice.icon = choice.icon or choice.memberIcons[name]
				end
			end
		end
		for _, id in ipairs(family.also or {}) do
			local name = SpellName(id)
			if name then
				inCatalog[name] = true
				choice.counts[name] = true
			end
		end
		if #choice.members > 0 then
			choice.label = table.concat(choice.members, " / ")
			suggested[#suggested + 1] = choice
		end
	end
	for _, family in ipairs(ITEMS[playerClass] or {}) do
		local choice = {key = family.key, kind = "ITEM", group = UTILITY, items = {}}
		for _, rank in ipairs(family.ranks) do
			local name = SpellName(rank.spell)
			if name then
				inCatalog[name] = true
				-- Named and shown after the best rank known (e.g. Create Healthstone (Major))
				if spellbook[name] then
					choice.label = name
					choice.icon = ItemIcon(rank.items[1]) or spellbook[name].icon
				end
			end
			for _, item in ipairs(rank.items) do choice.items[#choice.items + 1] = item end
		end
		if choice.label then items[#items + 1] = choice end
	end
	for name, known in pairs(spellbook) do
		if not inCatalog[name] then
			others[#others + 1] = {key = "spell:" .. name, kind = "BUFF", group = ESSENTIAL, label = name, icon = known.icon,
				members = {name}, memberIcons = {[name] = known.icon}, counts = {[name] = true}}
		end
	end
	table.sort(others, function(a, b) return a.label < b.label end)
end

function MissingBuffs.GetChoices()
	if not suggested then BuildChoices() end
	return suggested, items, others
end

local function FindChoice(key)
	MissingBuffs.GetChoices()
	for _, list in ipairs({suggested, items, others}) do
		for _, choice in ipairs(list) do
			if choice.key == key then return choice end
		end
	end
end

-- Characters -----------------------------------------------------------------------------------------

-- This character's saved choice: {class, buffs = {key = {group, icon, minimum}}, lastSeen = {key = name}}
function MissingBuffs.GetCharacter()
	if not (ns.db and characterKey) then return nil end
	local entry = ns.db.characters[characterKey]
	if type(entry) ~= "table" then
		entry = {class = playerClass, buffs = {}, lastSeen = {}}
		ns.db.characters[characterKey] = entry
	end
	return entry
end

local function DisplayName(key)
	local name, realm = key:match("^(.-)%-(.+)$")
	if not name then return key end
	local ownRealm = GetRealmName and GetRealmName()
	if realm == ownRealm then return name end
	return name .. " - " .. realm
end

function MissingBuffs.GetCharacterName()
	return characterKey and DisplayName(characterKey) or "?"
end

function MissingBuffs.GetClassName()
	return className or "?"
end

local function CountBuffs(entry)
	local count = 0
	for _ in pairs(entry.buffs) do count = count + 1 end
	return count
end

-- The other characters of this class with a choice made, to copy from: {key, name, count}
function MissingBuffs.GetCopySources()
	local list = {}
	if not (ns.db and characterKey) then return list end
	for key, entry in pairs(ns.db.characters) do
		if key ~= characterKey and entry.class == playerClass then
			local count = CountBuffs(entry)
			if count > 0 then list[#list + 1] = {key = key, name = DisplayName(key), count = count} end
		end
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	return list
end

-- What's kept for a thing watched ({group, icon, minimum}), nil when it isn't watched
function MissingBuffs.GetWatch(key)
	local entry = MissingBuffs.GetCharacter()
	return entry and entry.buffs[key]
end

function MissingBuffs.IsWatched(key)
	return MissingBuffs.GetWatch(key) ~= nil
end

local function Changed()
	MissingBuffs.Update()
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Ticked: in the group it starts in (buffs Essential, items Utility), an item missing when there's none
function MissingBuffs.SetWatched(key, watched)
	local entry = MissingBuffs.GetCharacter()
	if not entry then return end
	if watched then
		if not entry.buffs[key] then
			local choice = FindChoice(key)
			local watch = {group = choice and choice.group or ESSENTIAL}
			if choice and choice.kind == "ITEM" then watch.minimum = 1 end
			entry.buffs[key] = watch
		end
	else
		entry.buffs[key] = nil
	end
	Changed()
end

-- The group (ESSENTIAL, UTILITY), the icon (a spell of the family; "" for the one last used) or the
-- minimum (items) of a thing watched
function MissingBuffs.SetGroup(key, group)
	local watch = MissingBuffs.GetWatch(key)
	if watch and GROUP_SETTINGS[group] then watch.group = group; Changed() end
end

function MissingBuffs.SetIcon(key, name)
	local watch = MissingBuffs.GetWatch(key)
	if watch then watch.icon = (type(name) == "string" and name ~= "") and name or nil; Changed() end
end

function MissingBuffs.SetMinimum(key, minimum)
	local watch = MissingBuffs.GetWatch(key)
	if watch and type(minimum) == "number" then
		watch.minimum = math.min(MAX_MINIMUM, math.max(1, math.floor(minimum)))
		Changed()
	end
end
MissingBuffs.MAX_MINIMUM = MAX_MINIMUM

-- This character's choice replaced by another's (of the same class)
function MissingBuffs.CopyFrom(sourceKey)
	local entry = MissingBuffs.GetCharacter()
	local source = ns.db and ns.db.characters[sourceKey]
	if not (entry and type(source) == "table" and source.class == playerClass and sourceKey ~= characterKey) then return false end
	entry.buffs = ns.CopyValue(source.buffs)
	entry.lastSeen = ns.CopyValue(source.lastSeen or {})
	ns.Print(string.format(L["Missing buffs copied from %s."], DisplayName(sourceKey)))
	Changed()
	return true
end

-- What's on the character ------------------------------------------------------------------------------

-- The names of the buffs on the character and how many; nil when the game hides them (in combat, the
-- game may make auras secret, or not list them at all)
local function ReadActiveNames()
	if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return nil end
	local names, count = {}, 0
	for i = 1, 255 do
		local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
		if not aura then break end
		local name = ns.Known(aura.name)
		if not name then return nil end
		names[name] = true
		count = count + 1
	end
	return names, count
end

local function InCombat()
	return (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player")) or false
end

-- What the addon can read now, for /ke buffscan: {inCombat, readable, count, names = {sorted}}
function MissingBuffs.Scan()
	local names, count = ReadActiveNames()
	local list = {}
	for name in pairs(names or {}) do list[#list + 1] = name end
	table.sort(list)
	return {inCombat = InCombat(), readable = names ~= nil, count = count or 0, names = list}
end

-- How many of an item family the bags hold (every rank); nil when the game hides it
local function CountItems(choice)
	local total = 0
	for _, id in ipairs(choice.items) do
		local count = ItemCount(id)
		if not count then return nil end
		total = total + count
	end
	return total
end

-- The screen -----------------------------------------------------------------------------------------

-- Where a group is held, by the way it grows: the side it grows from stays in place
local ANCHORS = {CENTER = "CENTER", RIGHT = "LEFT", LEFT = "RIGHT", UP = "BOTTOM", DOWN = "TOP"}
local HINTS = {[ESSENTIAL] = "Essential: drag to move", [UTILITY] = "Utility: drag to move"}
local FRAME_NAMES = {[ESSENTIAL] = "KyoryokunaEnhancementsMissingBuffsEssential", [UTILITY] = "KyoryokunaEnhancementsMissingBuffsUtility"}

local holders, icons = {}, {}
local moving = false
local lastActive
local lastCounts = {}

local function Round(value)
	return math.floor(value + 0.5)
end

-- The place of a group's anchor point, from the center of the screen
local function AnchorOffset(frame, point)
	local left, bottom, width, height = frame:GetRect()
	local centerX, centerY = UIParent:GetCenter()
	if not (left and centerX) then return nil end
	local x, y = left + width / 2, bottom + height / 2
	if point == "LEFT" then x = left
	elseif point == "RIGHT" then x = left + width
	elseif point == "BOTTOM" then y = bottom
	elseif point == "TOP" then y = bottom + height end
	return Round(x - centerX), Round(y - centerY)
end

local function GetHolder(group)
	if holders[group] then return holders[group] end
	local holder = CreateFrame("Frame", FRAME_NAMES[group], UIParent)
	holder:SetFrameStrata("MEDIUM")
	holder:SetClampedToScreen(true)
	holder:SetMovable(true)
	holder:RegisterForDrag("LeftButton")
	holder:SetScript("OnDragStart", function(self)
		if moving then self:StartMoving() end
	end)
	holder:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local settings = ns.db[GROUP_SETTINGS[group]]
		local x, y = AnchorOffset(self, ANCHORS[settings.growth] or "CENTER")
		if x then
			settings.x, settings.y = x, y
			ns.ValidateSettings()
		end
		Changed()
	end)
	-- While moving: a green frame and a hint over the icons
	holder.mover = holder:CreateTexture(nil, "BACKGROUND")
	holder.mover:SetPoint("TOPLEFT", holder, "TOPLEFT", -4, 4)
	holder.mover:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 4, -4)
	holder.mover:SetColorTexture(0.18, 0.8, 0.44, 0.35)
	holder.hint = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	holder.hint:SetPoint("BOTTOM", holder, "TOP", 0, 8)
	holder:Hide()
	holders[group] = holder
	icons[group] = {}
	return holder
end

local function GetIcon(group, index)
	local list = icons[group]
	local icon = list[index]
	if icon then return icon end
	icon = CreateFrame("Frame", nil, GetHolder(group))
	-- A thin black border around the icon, cut a little so the game's own edge doesn't show
	icon.border = icon:CreateTexture(nil, "BACKGROUND")
	icon.border:SetAllPoints(icon)
	icon.border:SetColorTexture(0, 0, 0, 1)
	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1)
	icon.texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
	icon.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	-- Grey, so it never looks like something that's there: it's something to do
	icon.texture:SetDesaturated(true)
	-- How many of an item there are
	icon.count = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
	list[index] = icon
	return icon
end

-- shown: {{texture, count}} in order
local function Layout(group, shown)
	local settings = ns.db[GROUP_SETTINGS[group]]
	local frame = GetHolder(group)
	local size, gap, growth = settings.iconSize, settings.spacing, settings.growth
	local total = #shown
	local length = math.max(1, total) * size + math.max(0, total - 1) * gap
	if growth == "UP" or growth == "DOWN" then frame:SetSize(size, length) else frame:SetSize(length, size) end
	frame:ClearAllPoints()
	frame:SetPoint(ANCHORS[growth] or "CENTER", UIParent, "CENTER", settings.x, settings.y)
	for i, info in ipairs(shown) do
		local icon = GetIcon(group, i)
		local offset = (i - 1) * (size + gap)
		icon:SetSize(size, size)
		icon:ClearAllPoints()
		if growth == "LEFT" then icon:SetPoint("RIGHT", frame, "RIGHT", -offset, 0)
		elseif growth == "UP" then icon:SetPoint("BOTTOM", frame, "BOTTOM", 0, offset)
		elseif growth == "DOWN" then icon:SetPoint("TOP", frame, "TOP", 0, -offset)
		else icon:SetPoint("LEFT", frame, "LEFT", offset, 0) end
		icon.texture:SetTexture(info.texture)
		icon.count:SetText(info.count and tostring(info.count) or "")
		icon:SetAlpha(settings.alpha / 100)
		icon:Show()
	end
	for i = total + 1, #icons[group] do icons[group][i]:Hide() end
	frame.mover:SetShown(moving)
	frame.hint:SetShown(moving)
	frame.hint:SetText(L[HINTS[group]])
	frame:EnableMouse(moving)
	frame:SetShown(total > 0)
end

-- The icon of a buff: the one picked, else the spell of the family last seen on the character, else the
-- first one known
local function IconOf(choice, watch, entry)
	if choice.kind == "ITEM" then return choice.icon or PLACEHOLDER_ICON end
	local picked = watch.icon and choice.memberIcons[watch.icon]
	if picked then return picked end
	local last = entry.lastSeen[choice.key]
	return (last and choice.memberIcons[last]) or choice.icon or PLACEHOLDER_ICON
end

local function HideAll()
	for _, holder in pairs(holders) do holder:Hide() end
end

function MissingBuffs.Update()
	if not (ns.db and characterKey) then return end
	local entry = MissingBuffs.GetCharacter()
	if not ns.db.missingBuffs.enabled and not moving then
		HideAll()
		return
	end
	local active, count = ReadActiveNames()
	-- In combat, an empty list when there were buffs before is the game hiding them, not every buff gone
	if active and count == 0 and InCombat() and lastActive and next(lastActive) then active = nil end
	if active then lastActive = active else active = lastActive or {} end
	local dead = UnitIsDeadOrGhost and UnitIsDeadOrGhost("player")
	local shown = {[ESSENTIAL] = {}, [UTILITY] = {}}
	local lists = {MissingBuffs.GetChoices()}
	for _, list in ipairs(lists) do
		for _, choice in ipairs(list) do
			local watch = entry.buffs[choice.key]
			if watch then
				local missing, itemCount = false, nil
				if choice.kind == "ITEM" then
					itemCount = CountItems(choice)
					if itemCount then lastCounts[choice.key] = itemCount else itemCount = lastCounts[choice.key] end
					missing = itemCount ~= nil and itemCount < (watch.minimum or 1)
				else
					local on = false
					for name in pairs(choice.counts) do
						if active[name] then
							on = true
							if spellbook[name] then entry.lastSeen[choice.key] = name end
							break
						end
					end
					missing = not on
				end
				-- While moving, everything chosen shows, so the groups can be placed as they will look
				if moving or (missing and not dead) then
					local group = shown[watch.group] or shown[ESSENTIAL]
					group[#group + 1] = {texture = IconOf(choice, watch, entry), count = itemCount}
				end
			end
		end
	end
	for group, list in pairs(shown) do
		if moving and #list == 0 then list[1] = {texture = PLACEHOLDER_ICON} end
		Layout(group, list)
	end
end

-- Moving the icons (from the page; ends when the options close)
function MissingBuffs.SetMoving(on)
	moving = on and true or false
	Changed()
end

function MissingBuffs.IsMoving()
	return moving
end

-- Events ---------------------------------------------------------------------------------------------

local function OnSpellsChanged()
	if ReadSpellbook() then
		suggested, items, others = nil, nil, nil
		if ns.RebuildOptionsPage then ns.RebuildOptionsPage("Missing Buffs") end
	end
	MissingBuffs.Update()
end

ns.RegisterEvent("PLAYER_LOGIN", function()
	local name = UnitName("player")
	local realm = GetRealmName and GetRealmName()
	if not name then return end
	characterKey = realm and realm ~= "" and (name .. "-" .. realm) or name
	className, playerClass = UnitClass("player")
	local entry = MissingBuffs.GetCharacter()
	entry.class = playerClass
	ReadSpellbook()
	suggested, items, others = nil, nil, nil
	-- A character with nothing chosen, and another of its class with a choice: said once
	if next(entry.buffs) == nil and not entry.copyOffered then
		local sources = MissingBuffs.GetCopySources()
		if #sources > 0 then
			entry.copyOffered = true
			ns.Print(string.format(L["Your %s %s has missing buffs chosen. To copy them to this character: /ke, Missing Buffs page."],
				className or "", sources[1].name))
		end
	end
	MissingBuffs.Update()
end)
ns.RegisterEvent("SPELLS_CHANGED", OnSpellsChanged)
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST", "BAG_UPDATE_DELAYED"}) do
	ns.RegisterEvent(event, function() MissingBuffs.Update() end)
end

-- The character's own auras only (the bus would get every unit's)
local auraFrame = CreateFrame("Frame")
if auraFrame.RegisterUnitEvent then
	auraFrame:RegisterUnitEvent("UNIT_AURA", "player")
else
	auraFrame:RegisterEvent("UNIT_AURA")
end
auraFrame:SetScript("OnEvent", function(_, _, unit)
	if unit == "player" then ns.SafeCall(MissingBuffs.Update) end
end)

-- For the tests
function MissingBuffs.GetHolder(group)
	return holders[group or ESSENTIAL]
end
