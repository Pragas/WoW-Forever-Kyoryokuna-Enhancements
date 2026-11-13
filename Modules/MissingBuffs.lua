-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Missing buffs (Missing Buffs page): what a character should always have on it, read from its
-- spellbook. The player ticks what to watch; while one is missing, its icon shows on the screen, grey and
-- faded, in and out of combat (not while dead).
--
--   - Three kinds: buffs (missing when not on the character), conjured items (missing when the bags
--     hold fewer than a minimum: mana gems, conjured food and water, healthstones...), and what goes on
--     the weapons (a shaman's imbues, a rogue's poisons: missing while a weapon in the character's hands
--     has none). Those aren't auras: they're the weapons' temporary enchants, read from the weapons.
--   - Two groups, each with its own place and look: Essential and Utility. Each thing ticked goes to the
--     group the player picks (buffs start in Essential, items in Utility).
--   - The choice is kept for each character. A new character with nothing chosen can copy the choice of
--     another character of its class (the page offers it, and the chat says so once).
--   - Buffs that can't be on together (the armors of a mage, the aspects of a hunter...) are one
--     "family": one line, one icon, and any of them is enough. Its icon can be picked, or be the one last
--     used. The same buff from someone else counts too, and so do the group versions (Arcane Brilliance
--     for Arcane Intellect...). Every rank counts: buffs are matched by name, items by every rank's item.
--   - In combat the game may hide the auras (or the counts) from addons: then the icons stay as they were
--     last known, instead of guessing. The same under the game's other restrictions, e.g. from a boss
--     pull, before the character is in combat itself. /ke buffscan shows what can be read.

local _, ns = ...
local L = ns.L
-- How the icons move and what surrounds them (shared with the proc alerts)
local Effects = ns.Effects

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
			{spell = 10140, items = {8079}}, {spell = 27090, items = {22018}}, {spell = 37420, items = {30703}},
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
-- What a class puts on its weapons (one family each): any of it is enough on each weapon held. A family of
-- spells is offered once one is known; a rogue's poisons are items (made with its Poisons skill), so their
-- family is offered to every rogue, with a name of its own and the icon of an item. The other classes
-- get the oils and stones anyone can put on a weapon (sharpening stones, weightstones, wizard and mana
-- oils: items too).
local WEAPONS = {
	SHAMAN = {key = "WEAPON_IMBUE", spells = {8017, 8024, 8033, 8232}}, -- Rockbiter, Flametongue, Frostbrand, Windfury Weapon
	ROGUE = {key = "POISONS", labelKey = "Poisons on your weapons", iconItem = 6947}, -- (Instant Poison)
	ANY = {key = "WEAPON_OIL", labelKey = "Oil or stone on your weapon", iconItem = 2862}, -- (Rough Sharpening Stone)
}
MissingBuffs.BUFFS, MissingBuffs.ITEMS, MissingBuffs.WEAPONS = BUFFS, ITEMS, WEAPONS

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

-- The text the game shows under a spell's name ("Rank 4"), and the rank in it; 0 when there's none
local function SpellSubtext(id)
	local subtext
	if C_Spell and C_Spell.GetSpellSubtext then subtext = C_Spell.GetSpellSubtext(id)
	elseif GetSpellSubtext then subtext = GetSpellSubtext(id) end
	subtext = ns.Known(subtext)
	return type(subtext) == "string" and subtext or ""
end

local function RankIn(text)
	text = ns.Known(text)
	return type(text) == "string" and tonumber(text:match("%d+")) or 0
end

-- Whether the character knows this exact spell (this rank)
local function IsKnownSpell(id)
	for _, check in ipairs({C_SpellBook and C_SpellBook.IsSpellKnown, IsPlayerSpell, IsSpellKnown}) do
		local ok, known = pcall(check, id)
		if ok and ns.Known(known) then return true end
	end
	return false
end

-- The spells this character has learned (not passive, not of another specialization), by name:
-- {ids = {every rank's ID}, icon, best = the ID of the highest rank}. The spellbook doesn't always list
-- the ranks in order, so the best is found by its rank (a click casts that exact one).
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
							local entry = found[name] or {ids = {}, icon = item.iconID or SpellIcon(item.spellID), bestRank = -1}
							entry.ids[#entry.ids + 1] = item.spellID
							-- The rank the spellbook gives with it, else the one under the spell's name
							local rank = RankIn(item.subName)
							if rank == 0 then rank = RankIn(SpellSubtext(item.spellID)) end
							if rank > entry.bestRank or (rank == 0 and entry.bestRank == 0) then
								entry.best, entry.bestRank = item.spellID, rank
							end
							found[name] = entry
						end
					end
				end
			end
		end
	end
	-- Every spell and rank: a new rank of a spell already known (same name) counts as a change too
	local names = {}
	for name, entry in pairs(found) do names[#names + 1] = name .. "=" .. table.concat(entry.ids, ",") end
	table.sort(names)
	local signature = table.concat(names, "\n")
	local changed = signature ~= spellbookSignature
	spellbook, spellbookSignature = found, signature
	return changed
end

-- The choices of this character. Each: {key, kind = "BUFF", "WEAPON" or "ITEM", label, icon, group (where
-- it starts)}; a buff also has members (names known, with memberIcons) and counts (names that count); what
-- goes on the weapons has members too (its spells known, none for poisons) and maybe a labelKey (its name,
-- translated when shown); an item has items (every rank's item IDs).
--   suggested: the buff families of its class it knows a spell of, and what goes on its weapons
--   items: the items of its class it knows a spell to make
--   others: every other spell of its spellbook, as a buff
local suggested, items, others

-- Whether the game may hide an aura from addons (in combat, or always): C_Secrets says so
local function CanBeHidden(id)
	if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy and Enum and Enum.SecrecyLevel) then return false end
	local ok, secrecy = pcall(C_Secrets.GetSpellAuraSecrecy, id)
	return ok and (secrecy == Enum.SecrecyLevel.ContextuallySecret or secrecy == Enum.SecrecyLevel.AlwaysSecret) or false
end

-- A buff's spells (spellIDs: every rank known, and the family's own and group versions), and whether the
-- game may hide it (hidable)
local function SetSpells(choice, ids)
	choice.spellIDs = choice.spellIDs or {}
	for _, id in ipairs(ids) do choice.spellIDs[id] = true end
end

-- (asked once, when it's first needed: the other spells are many, and few are watched)
local function Hidable(choice)
	if choice.hidable == nil then
		choice.hidable = false
		for id in pairs(choice.spellIDs or {}) do
			if CanBeHidden(id) then
				choice.hidable = true
				break
			end
		end
	end
	return choice.hidable
end

local function BuildChoices()
	suggested, items, others = {}, {}, {}
	local inCatalog = {}
	for _, family in ipairs(BUFFS[playerClass] or {}) do
		local choice = {key = family.key, kind = "BUFF", group = ESSENTIAL, members = {}, memberIcons = {}, counts = {}}
		SetSpells(choice, family.spells)
		SetSpells(choice, family.also or {})
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
					SetSpells(choice, known.ids)
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
	local weapon = WEAPONS[playerClass] or WEAPONS.ANY
	if weapon then
		local choice = {key = weapon.key, kind = "WEAPON", group = ESSENTIAL, members = {}, memberIcons = {}, counts = {}}
		for _, id in ipairs(weapon.spells or {}) do
			local name = SpellName(id)
			if name then
				inCatalog[name] = true
				local known = spellbook[name]
				if known then
					choice.members[#choice.members + 1] = name
					choice.memberIcons[name] = known.icon or SpellIcon(id)
					choice.icon = choice.icon or choice.memberIcons[name]
				end
			end
		end
		if weapon.labelKey then
			choice.labelKey, choice.label = weapon.labelKey, L[weapon.labelKey]
			choice.icon = choice.icon or ItemIcon(weapon.iconItem) or PLACEHOLDER_ICON
			suggested[#suggested + 1] = choice
		elseif #choice.members > 0 then
			choice.label = table.concat(choice.members, " / ")
			suggested[#suggested + 1] = choice
		end
	end
	for _, family in ipairs(ITEMS[playerClass] or {}) do
		local choice = {key = family.key, kind = "ITEM", group = UTILITY, items = {}}
		local inBook
		for _, rank in ipairs(family.ranks) do
			local name = SpellName(rank.spell)
			if name then
				inCatalog[name] = true
				if spellbook[name] then inBook = name end
			end
			for _, item in ipairs(rank.items) do choice.items[#choice.items + 1] = item end
		end
		-- The best rank known, from the highest down (the ranks are in order, checked on Wowhead): named,
		-- shown and cast after it (e.g. Create Healthstone (Major), Conjure Water rank 4)
		local best
		for i = #family.ranks, 1, -1 do
			if IsKnownSpell(family.ranks[i].spell) then best = family.ranks[i] break end
		end
		if best then
			choice.label = SpellName(best.spell) or inBook
			choice.icon = ItemIcon(best.items[1]) or SpellIcon(best.spell)
			choice.castName, choice.castID = choice.label, best.spell
		elseif inBook then
			-- The game didn't say which ranks are known: the best one the spellbook lists
			choice.label = inBook
			choice.icon = spellbook[inBook].icon
			choice.castName, choice.castID = inBook, spellbook[inBook].best
		end
		if choice.label then items[#items + 1] = choice end
	end
	for name, known in pairs(spellbook) do
		if not inCatalog[name] then
			local choice = {key = "spell:" .. name, kind = "BUFF", group = ESSENTIAL, label = name, icon = known.icon,
				members = {name}, memberIcons = {[name] = known.icon}, counts = {[name] = true}}
			SetSpells(choice, known.ids)
			others[#others + 1] = choice
		end
	end
	table.sort(others, function(a, b) return a.label < b.label end)
end

-- The highest rank this character knows of the spell that conjures an item family of its class (e.g.
-- "WATER"): its ID and name, or nil (also for Modules\Supplies.lua)
function MissingBuffs.BestConjure(key)
	local _, class = UnitClass("player")
	for _, family in ipairs(ITEMS[class] or {}) do
		if family.key == key then
			for i = #family.ranks, 1, -1 do
				local spell = family.ranks[i].spell
				if IsKnownSpell(spell) then return spell, SpellName(spell) end
			end
		end
	end
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

-- How the groups look (their sections of the settings: place, size, opacity, number, animation, glow) is
-- each character's own too, kept with its choice: look = {section = {...}}. The settings hold the look
-- of the character playing: put there at login, kept back at each change. A new character starts with
-- the first look; one from before it was its own, with the one the account had (Core\Database.lua).
local LOOK_SECTIONS = {"missingBuffsEssential", "missingBuffsUtility"}

local function NewLook()
	local look = {}
	for _, section in ipairs(LOOK_SECTIONS) do look[section] = ns.CopyValue(ns.DEFAULTS[section]) end
	return look
end

-- This character's saved choice: {class, buffs = {key = {group, icon, minimum}}, lastSeen = {key = name},
-- look}
function MissingBuffs.GetCharacter()
	if not (ns.db and characterKey) then return nil end
	local entry = ns.db.characters[characterKey]
	if type(entry) ~= "table" then
		entry = {class = playerClass, buffs = {}, lastSeen = {}, look = NewLook()}
		ns.db.characters[characterKey] = entry
	end
	return entry
end

-- The look in the settings kept as this character's (after each change)
function MissingBuffs.SaveLook()
	local entry = MissingBuffs.GetCharacter()
	if not entry then return end
	if type(entry.look) ~= "table" then entry.look = {} end
	for _, section in ipairs(LOOK_SECTIONS) do entry.look[section] = ns.CopyValue(ns.db[section]) end
end

-- This character's look put in the settings (at login, or copied from another); one without a look yet
-- keeps the one there
local function LoadLook(entry)
	if type(entry.look) ~= "table" then
		MissingBuffs.SaveLook()
		return
	end
	for _, section in ipairs(LOOK_SECTIONS) do
		local saved = entry.look[section]
		if type(saved) == "table" then
			local live = ns.db[section]
			for key in pairs(live) do live[key] = nil end
			for key, value in pairs(saved) do live[key] = ns.CopyValue(value) end
		end
	end
	ns.ValidateSettings()
	MissingBuffs.SaveLook()
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
	-- And how its groups look (one from before it was its own has none to give)
	if type(source.look) == "table" then
		entry.look = ns.CopyValue(source.look)
		LoadLook(entry)
	end
	ns.Print(string.format(L["Missing buffs copied from %s."], DisplayName(sourceKey)))
	Changed()
	return true
end

-- What's on the character ------------------------------------------------------------------------------

-- The names of the buffs on the character and how many; nil when the game hides some of them (in combat
-- it may make auras secret, or refuse them with an error). An empty list is an empty list: the game
-- never hides auras by leaving them out (a buff that was the only one, like a shaman's Lightning Shield at
-- low level, shows as missing as soon as it goes, in combat too).
local function ReadActiveNames()
	if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return nil end
	local names, count = {}, 0
	for i = 1, 255 do
		-- In combat WoW Forever may refuse (an error, not a hidden value): then the auras are hidden
		local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
		if not ok then return nil end
		if not aura then break end
		local name = ns.Known(aura.name)
		if not name then return nil end
		names[name] = true
		count = count + 1
	end
	return names, count
end

-- One buff asked for by its name, when the game hides some of the others: true (on), false (not on), or
-- nil when the game hides that one too
local function ReadByName(name)
	if not (C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName) then return nil end
	local ok, aura = pcall(C_UnitAuras.GetAuraDataBySpellName, "player", name, "HELPFUL")
	if not ok or ns.IsSecret(aura) then return nil end
	return aura ~= nil
end

-- The names of the buffs this character watches (any that counts for each of its families)
local function WatchedNames(entry)
	local names = {}
	local families, _, spells = MissingBuffs.GetChoices()
	for _, list in ipairs({families, spells}) do
		for _, choice in ipairs(list) do
			if choice.kind == "BUFF" and entry.buffs[choice.key] then
				for name in pairs(choice.counts) do names[name] = true end
			end
		end
	end
	return names
end

-- The buffs on the character when the game hides some of them: each one watched asked for by its name;
-- the ones the game hides too stay as they were (before: the last names known)
local function ReadWatched(entry, before)
	local active = {}
	for name, on in pairs(before) do active[name] = on end
	for name in pairs(WatchedNames(entry)) do
		local on = ReadByName(name)
		if on ~= nil then active[name] = on or nil end
	end
	return active
end

local function InCombat()
	return (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player")) or false
end

-- The game hides auras from addons not only in the character's own fight: also while one of its addon
-- restrictions is on (C_RestrictedActions): a boss encounter (from the pull, maybe before the character
-- is in combat itself: its buffs then looked gone for a moment), a keystone dungeon, a PvP match, some
-- maps. ADDON_RESTRICTION_STATE_CHANGED says so before one becomes active ("Activating", the auras still
-- readable) and after one ends; while it's being sent, IsAddOnRestrictionActive answers false, so the
-- state it gives is kept.
local RESTRICTIONS = {"Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map"}
local restrictionStates = {}

-- The restrictions on now, by name ({} when none)
local function ActiveRestrictions()
	local list = {}
	local types = Enum and Enum.AddOnRestrictionType
	if not types then return list end
	local inactive = Enum.AddOnRestrictionState and Enum.AddOnRestrictionState.Inactive or 0
	local isActive = C_RestrictedActions and C_RestrictedActions.IsAddOnRestrictionActive
	for _, name in ipairs(RESTRICTIONS) do
		local value = types[name]
		if value ~= nil then
			local state = restrictionStates[value]
			local on = state ~= nil and state ~= inactive
			if not on and isActive then
				local ok, active = pcall(isActive, value)
				on = ok and not ns.IsSecret(active) and active == true
			end
			if on then list[#list + 1] = name end
		end
	end
	return list
end

-- Whether the game may hide auras from addons now: in a fight, or under one of its restrictions
local function AurasHidden()
	return InCombat() or #ActiveRestrictions() > 0
end

local MAIN_HAND, OFF_HAND = 16, 17
local WEAPON_CLASS = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or 2

-- Whether a hand holds a weapon (a shield, or an item held in the off hand, isn't one)
local function HoldsWeapon(slot)
	local id = GetInventoryItemID and ns.Known(GetInventoryItemID("player", slot))
	if not id then return false end
	local info = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	local classID = info and select(6, info(id))
	if classID == nil then return slot == MAIN_HAND end
	return classID == WEAPON_CLASS
end

-- The weapons' temporary enchants (imbues, poisons): {mainHand, offHand} each "on", "off" (a weapon
-- without one) or "none" (no weapon in that hand), missing (a weapon without one), and the seconds until
-- the first one ends (nil if unknown); nil when the game hides them
local function ReadWeapons()
	if not GetWeaponEnchantInfo then return nil end
	local ok, hasMain, mainLeft, _, _, hasOff, offLeft = pcall(GetWeaponEnchantInfo)
	if not ok or ns.IsSecret(hasMain) or ns.IsSecret(hasOff) then return nil end
	local function State(slot, has)
		if not HoldsWeapon(slot) then return "none" end
		return has and "on" or "off"
	end
	local weapons = {mainHand = State(MAIN_HAND, hasMain), offHand = State(OFF_HAND, hasOff)}
	weapons.missing = weapons.mainHand == "off" or weapons.offHand == "off"
	for _, left in ipairs({hasMain and ns.Known(mainLeft), hasOff and ns.Known(offLeft)}) do
		if type(left) == "number" and left > 0 and (not weapons.ends or left / 1000 < weapons.ends) then weapons.ends = left / 1000 end
	end
	return weapons
end

-- What the addon can read now, for /ke buffscan: {inCombat, readable, count, names = {sorted}, weapons}
-- and watched: each buff watched asked for by its name ({name, answer = "on", "off" or "hidden", secrecy:
-- how secret the game says its aura is, "?" when it can't tell})
function MissingBuffs.Scan()
	local names, count = ReadActiveNames()
	local list = {}
	for name in pairs(names or {}) do list[#list + 1] = name end
	table.sort(list)
	local watched = {}
	local entry = MissingBuffs.GetCharacter()
	for name in pairs(entry and WatchedNames(entry) or {}) do
		local on = ReadByName(name)
		local secrecy = "?"
		local known = spellbook[name]
		if known and C_Secrets and C_Secrets.GetSpellAuraSecrecy then
			local ok, value = pcall(C_Secrets.GetSpellAuraSecrecy, known.best)
			secrecy = ok and tostring(value) or "?"
		end
		watched[#watched + 1] = {name = name, answer = on == nil and "hidden" or (on and "on" or "off"), secrecy = secrecy}
	end
	table.sort(watched, function(a, b) return a.name < b.name end)
	local restrictions = ActiveRestrictions()
	return {inCombat = InCombat(), readable = names ~= nil, count = count or 0, names = list, weapons = ReadWeapons(),
		watched = watched, restrictions = #restrictions > 0 and table.concat(restrictions, ", ") or "none"}
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

-- An icon of the groups: its frame, a thin black border, the spell's icon (grey), a number (items), and
-- what may surround it (its group's choice, hidden until then): the game's glow, its moving outline, a
-- border of a color. Only textures and text in it (no frames), so it can be made with a template that
-- keeps scripts away
local function MakeIcon(parent, template)
	local icon = CreateFrame("Frame", nil, parent, template)
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
	-- The game's glow and its moving outline (Core\Effects.lua), grey so the color asked tints them
	icon.glow = icon:CreateTexture(nil, "OVERLAY")
	icon.glow:SetTexture(Effects.GLOW_ART)
	icon.glow:SetTexCoord(unpack(Effects.GLOW_COORDS))
	icon.glow:SetDesaturated(true)
	icon.glow:Hide()
	icon.ants = icon:CreateTexture(nil, "OVERLAY", nil, 1)
	icon.ants:SetTexture(Effects.ANTS_ART)
	icon.ants:SetTexCoord(Effects.AntsCoords(0))
	icon.ants:SetDesaturated(true)
	icon.ants:SetPoint("CENTER", icon, "CENTER", 0, 0)
	icon.ants:Hide()
	-- A border of a color: four edges over the icon's own edge (top, bottom, left, right)
	icon.edges = {}
	for i = 1, 4 do
		icon.edges[i] = icon:CreateTexture(nil, "OVERLAY", nil, 2)
		icon.edges[i]:Hide()
	end
	-- How many of an item there are (over everything)
	icon.count = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	icon.count:SetDrawLayer("OVERLAY", 7)
	icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
	-- The game's number font and its outline, kept to give it the size of the settings
	icon.countFont, _, icon.countFlags = icon.count:GetFont()
	-- Its textures, fitted to the screen's pixels as the game does unless it moves (see SetSmooth)
	icon.textures = {icon.border, icon.texture, icon.glow, icon.ants, unpack(icon.edges)}
	icon.snapBias = icon.texture.GetTexelSnappingBias and icon.texture:GetTexelSnappingBias()
	return icon
end

-- While an icon grows or floats, its textures aren't fitted to the screen's pixels (as the game does for
-- its own health bars): fitted, an icon this small grows in jumps of a whole pixel, not smoothly. Still
-- (or only fading), they're fitted again, sharp.
local function SetSmooth(icon, smooth)
	if icon.smooth == smooth then return end
	icon.smooth = smooth
	for _, texture in ipairs(icon.textures) do
		if texture.SetSnapToPixelGrid then
			if smooth then texture:SetTexelSnappingBias(0) elseif icon.snapBias then texture:SetTexelSnappingBias(icon.snapBias) end
			texture:SetSnapToPixelGrid(not smooth)
		end
	end
end

-- What surrounds an icon, as its group's settings say, at its size: the game's glow (reaching out of the
-- icon), its moving outline, both, or a border of a color over the icon's edge. True when its outline
-- moves (the ants: moved all together, see MoveAnts)
local function SetGlow(icon, settings, size)
	local style = settings.glow
	local r, g, b = ns.Unpack(settings.glowColor)
	local reach = size * Effects.GLOW_REACH
	icon.glow:ClearAllPoints()
	icon.glow:SetPoint("TOPLEFT", icon, "TOPLEFT", -reach, reach)
	icon.glow:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", reach, -reach)
	icon.glow:SetVertexColor(r, g, b)
	icon.glow:SetShown(style == "GLOW" or style == "BOTH")
	local ants = style == "ANTS" or style == "BOTH"
	icon.ants:SetSize(size * Effects.ANTS_SCALE, size * Effects.ANTS_SCALE)
	icon.ants:SetVertexColor(r, g, b)
	icon.ants:SetShown(ants)
	local thickness = settings.borderSize
	local top, bottom, left, right = icon.edges[1], icon.edges[2], icon.edges[3], icon.edges[4]
	for _, edge in ipairs(icon.edges) do
		edge:ClearAllPoints()
		edge:SetColorTexture(r, g, b, 1)
		edge:SetShown(style == "BORDER")
	end
	top:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	top:SetPoint("BOTTOMRIGHT", icon, "TOPRIGHT", 0, -thickness)
	bottom:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, thickness)
	bottom:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
	left:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	left:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT", thickness, 0)
	right:SetPoint("TOPLEFT", icon, "TOPRIGHT", -thickness, 0)
	right:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
	return ants
end

-- Buffs the game hides in combat ---------------------------------------------------------------------
--
-- In combat WoW Forever hides many auras from addons by leaving them out of what they read (no error, no
-- secret value): "not there" can't be believed for a buff the game says it may hide (C_Secrets), so in
-- combat such a buff stays as it was when the fight began. And so its icon still shows as soon as it
-- goes, the game itself moves it, without the addon ever knowing:
--   - each such buff gets one of the game's own AuraContainers (made out of combat, once), with a group
--     for that buff alone; the game sizes the container by what's in it: 1 wide while the buff is gone,
--     FAR wide while it's on (the width given to the group's frame). The game's code says addons may tie
--     their own frames to such a container, if they're made with DisableUntrustedLayoutScriptsTemplate
--     (their layout scripts then never run, so they can't learn its size);
--   - the buff's own icon is such a frame, tied to the container's right side, inside a "window" of its
--     group (in it, a frame that only shows what's within it, a little larger for the icon's glow, and
--     that moves as the group's animation asks), where the container starts too;
--   - while the buff is on, the container is wide and pushes the icon far out of its window: unseen;
--     when it goes, the container is 1 wide and the icon sits in its window: seen at once.
--   The container is never seen (no alpha): the game's frames in it, never touched, show the buff's icon.
-- In combat that window stays in its group, after the others. (A first try, a mask in the game's frame,
-- didn't work: the game's frames, and so anything in them, can't be read by addons, and it seems a hidden
-- mask still cuts.) Nothing is read or listened to: the game moves the icon itself.

-- Why the game's containers can't be made (or "made"), for /ke buffscan
local gameNote = "not needed yet"
-- For each buff (its choice's key): {signature (its spells), window (in its group), face (the icon, in the
-- window, tied to the container), container, note (why there's none)}
local gameIcons = {}
-- The width of the game's frame for a buff that's on: far more than any icon, so the icon is far out
local FAR = 1000
local GROUP_KEY = "KE_MB"

local function Signature(ids)
	local list = {}
	for id in pairs(ids) do list[#list + 1] = id end
	table.sort(list)
	return table.concat(list, ",")
end

-- One of the game's containers, sized by the buff's spells; nil and why when it can't be made
local function MakeContainer(spells)
	if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy) then return nil, "the game has no C_Secrets" end
	if C_AddOns and C_AddOns.LoadAddOn then pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer") end
	local ok, container = pcall(CreateFrame, "AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
	if not ok or not container then return nil, "not made: " .. tostring(container) end
	local okSetup, problem = pcall(function()
		container:SetSize(1, 1)
		-- Never seen: the game's frames in it show the buff's own icon
		container:SetAlpha(0)
		container:SetUnit("player")
		container:SetEnabled(true)
		container:AddAuraGroup(GROUP_KEY, "HELPFUL", {
			candidateFilters = {includeSpellIDs = spells},
			maxFrameCount = 1,
			layout = {elementWidth = FAR, elementHeight = 1},
		})
	end)
	if not okSetup then
		container:Hide()
		return nil, "not set up: " .. tostring(problem)
	end
	return container
end

-- The room around a buff's own icon in its window, for its glow (what reaches out of an icon of this
-- size): what's seen of it starts that much before the window and ends that much after
local function SetPad(window, size)
	local pad = math.ceil(size * Effects.GLOW_REACH) + 2
	local clip = window.clip
	clip:ClearAllPoints()
	clip:SetPoint("TOPLEFT", window, "TOPLEFT", -pad, pad)
	clip:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", pad, -pad)
	clip.pad = pad
end

-- A buff's own icon, moved by the game: its window (what the groups place), made the first time out of
-- combat (its spells changed when a new rank is learned); nil without one
local function GameIcon(choice, texture, parent)
	local signature = Signature(choice.spellIDs or {})
	local known = gameIcons[choice.key]
	if known and known.signature == signature then return known.window end
	-- The game's containers are only made or changed out of combat
	if InCombatLockdown and InCombatLockdown() then return known and known.window or nil end
	local spells = {}
	for id in pairs(choice.spellIDs or {}) do spells[id] = true end
	-- A new rank learned: the same container, with the spells known now
	if known and known.container then
		local ok, problem = pcall(known.container.SetAuraGroupCandidateFilters, known.container, GROUP_KEY,
			{includeSpellIDs = spells})
		known.signature = signature
		if ok then return known.window end
		known.window:Hide()
		gameIcons[choice.key] = {signature = signature, note = "not changed: " .. tostring(problem)}
		return nil
	end
	local container, why = MakeContainer(spells)
	if not container then
		-- (each buff says why it has none; this says it of all, until one is made)
		if gameNote ~= "made" then gameNote = why end
		gameIcons[choice.key] = {signature = signature, note = why}
		return nil
	end
	gameNote = "made"
	-- The window, in its group (the place of an icon)
	local window = CreateFrame("Frame", nil, parent or UIParent)
	window:SetSize(40, 40)
	window:Hide()
	-- In it, what's seen: only what's within this frame, a little larger than the window so the icon's
	-- glow shows; it's what moves (its group's animation), the icon with it
	local clip = CreateFrame("Frame", nil, window)
	clip:SetClipsChildren(true)
	window.clip, window.inner = clip, clip
	SetPad(window, 40)
	-- The icon, made so the game lets it be tied to its container
	local face = MakeIcon(clip, "DisableUntrustedLayoutScriptsTemplate")
	face:SetSize(40, 40)
	face.texture:SetTexture(texture)
	local ok, problem = pcall(function()
		-- The container starts where the window does; the icon starts where the container ends
		container:SetPoint("TOPLEFT", window, "TOPLEFT", 0, 0)
		face:SetPoint("TOPLEFT", container, "TOPRIGHT", -1, 0)
	end)
	if not ok then
		container:Hide()
		gameIcons[choice.key] = {signature = signature, note = "not tied: " .. tostring(problem)}
		return nil
	end
	-- What the groups change on an icon, on the window's icon
	window.face, window.texture, window.count = face, face.texture, face.count
	window.countFont, window.countFlags = face.countFont, face.countFlags
	gameIcons[choice.key] = {signature = signature, window = window, face = face, container = container}
	return window
end

-- A question to the game's container or the icon tied to it: its answer, or why there's none
local function Ask(object, method)
	if not object then return "none" end
	local ok, answer = pcall(object[method], object)
	if not ok then return "forbidden" end
	if ns.IsSecret(answer) then return "secret" end
	if type(answer) == "number" then return string.format("%.0f", answer) end
	return tostring(answer)
end

-- How far the icon is from the start of its window (0: seen; FAR: unseen), or why it can't be told
local function Offset(known)
	local ok, faceLeft, windowLeft = pcall(function() return known.face:GetLeft(), known.window:GetLeft() end)
	if not ok then return "forbidden" end
	if ns.IsSecret(faceLeft) or ns.IsSecret(windowLeft) then return "secret" end
	if not (faceLeft and windowLeft) then return "unknown" end
	return string.format("%.0f", faceLeft - windowLeft)
end

-- What there is for a buff the game may hide, for /ke buffscan: "ready" (its own icon tied to the
-- game's container) with the container's width and where the icon is, or why there's none
local function GameIconState(choice)
	local known = gameIcons[choice.key]
	if not (known and known.window) then return known and known.note or gameNote end
	return string.format("ready (game's width %s; icon %s from its window; window shown %s, visible %s)",
		Ask(known.container, "GetWidth"), Offset(known), tostring(known.window:IsShown()),
		tostring(known.window:IsVisible()))
end

-- Every buff's own icon not in use (all without a list): never hidden and shown again in one go, which
-- would stop its animation
local function HideGameIcons(inUse)
	for _, known in pairs(gameIcons) do
		if known.window and not (inUse and inUse[known.window]) then known.window:Hide() end
	end
end

-- For /ke buffscan: what happened to the game's containers, and each buff watched the game may hide
-- ({label, state})
function MissingBuffs.ScanGame()
	local list = {}
	local entry = MissingBuffs.GetCharacter()
	local families, _, spells = MissingBuffs.GetChoices()
	for _, choices in ipairs({families, spells}) do
		for _, choice in ipairs(choices) do
			if choice.kind == "BUFF" and entry and entry.buffs[choice.key] and Hidable(choice) then
				list[#list + 1] = {label = choice.label, state = GameIconState(choice)}
			end
		end
	end
	return gameNote, list
end

-- The screen -----------------------------------------------------------------------------------------

-- Where a group is held, by the way it grows: the side it grows from stays in place
local ANCHORS = {CENTER = "CENTER", RIGHT = "LEFT", LEFT = "RIGHT", UP = "BOTTOM", DOWN = "TOP"}
local HINTS = {[ESSENTIAL] = "Essential: drag to move", [UTILITY] = "Utility: drag to move"}
local FRAME_NAMES = {[ESSENTIAL] = "KyoryokunaEnhancementsMissingBuffsEssential", [UTILITY] = "KyoryokunaEnhancementsMissingBuffsUtility"}

-- Where the number of an item sits on its icon: a corner (a little inside the border) or the middle
local COUNT_OFFSETS = {
	BOTTOMRIGHT = {-2, 2}, BOTTOMLEFT = {2, 2}, CENTER = {0, 0}, TOPRIGHT = {-2, -2}, TOPLEFT = {2, -2},
}

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
			-- (the place is part of the character's look)
			MissingBuffs.SaveLook()
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

-- An icon of a group: its place (and the group's opacity), and in it what's seen, which moves as the
-- group's animation asks (its inner part, as a buff's own icon has)
local function GetIcon(group, index)
	local list = icons[group]
	local icon = list[index]
	if icon then return icon end
	icon = CreateFrame("Frame", nil, GetHolder(group))
	local face = MakeIcon(icon)
	face:SetAllPoints(icon)
	icon.face, icon.inner = face, face
	icon.texture, icon.count, icon.countFont, icon.countFlags = face.texture, face.count, face.countFont, face.countFlags
	list[index] = icon
	return icon
end

-- The moving outlines shown, by group: one clock moves them all, in step, while there are any
local antsShown = {}
local antsClock

local function MoveAnts(group, list)
	antsShown[group] = list
	local any = false
	for _, shown in pairs(antsShown) do
		if #shown > 0 then any = true end
	end
	if any and not antsClock then
		antsClock = CreateFrame("Frame")
		antsClock:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed < Effects.ANTS_STEP then return end
			self.elapsed = 0
			self.step = ((self.step or 0) + 1) % Effects.ANTS_FRAMES
			local left, right, top, bottom = Effects.AntsCoords(self.step)
			for _, shown in pairs(antsShown) do
				for _, ants in ipairs(shown) do ants:SetTexCoord(left, right, top, bottom) end
			end
		end)
	end
	if antsClock then antsClock:SetShown(any) end
end

-- The animation of a group's icons (its settings), on each one's inner part. When one starts (an icon
-- newly shown, or the settings changed), all of the group's start again, so they move in step; the ones
-- gone stop. playing: by group, {icon = what it plays}
local playing = {}

local function AnimateGroup(group, list, settings)
	local kind, time, strength = settings.animation, settings.animTime, settings.animStrength / 100
	local key = kind .. ":" .. time .. ":" .. strength
	local before, now, restart = playing[group] or {}, {}, false
	for _, icon in ipairs(list) do
		now[icon] = key
		if before[icon] ~= key or (kind ~= "NONE" and not (icon.animation and icon.animation:IsPlaying())) then
			restart = true
		end
	end
	-- (an icon gone to the other group is that group's now)
	for icon in pairs(before) do
		if not now[icon] and icon.animGroup == group then
			Effects.Play(icon, icon.inner, icon.inner, "NONE")
			icon.animGroup = nil
		end
	end
	if restart then
		for _, icon in ipairs(list) do
			Effects.Play(icon, icon.inner, icon.inner, kind, time, strength)
			icon.animGroup = group
		end
	end
	playing[group] = now
end

-- Every icon still, and no outline moving (nothing shown)
local function StopEffects()
	for group, list in pairs(playing) do
		for icon in pairs(list) do
			if icon.animGroup == group then Effects.Play(icon, icon.inner, icon.inner, "NONE") end
			icon.animGroup = nil
		end
	end
	playing = {}
	for group in pairs(antsShown) do MoveAnts(group, {}) end
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
	-- The icons shown (their animation) and their moving outlines
	local placed, ants = {}, {}
	for i, info in ipairs(shown) do
		-- A buff's own icon (its window, the icon in it moved by the game) in place of the group's
		local icon = info.own or GetIcon(group, i)
		if info.own then
			if icon:GetParent() ~= frame then icon:SetParent(frame) end
			if icons[group][i] then icons[group][i]:Hide() end
			-- Room in its window for its glow
			SetPad(icon, size)
		end
		local face = icon.face
		local offset = (i - 1) * (size + gap)
		icon:SetSize(size, size)
		face:SetSize(size, size)
		if SetGlow(face, settings, size) then ants[#ants + 1] = face.ants end
		SetSmooth(face, settings.animation == "PULSE" or settings.animation == "FLOAT")
		placed[#placed + 1] = icon
		icon:ClearAllPoints()
		if growth == "LEFT" then icon:SetPoint("RIGHT", frame, "RIGHT", -offset, 0)
		elseif growth == "UP" then icon:SetPoint("BOTTOM", frame, "BOTTOM", 0, offset)
		elseif growth == "DOWN" then icon:SetPoint("TOP", frame, "TOP", 0, -offset)
		else icon:SetPoint("LEFT", frame, "LEFT", offset, 0) end
		icon.texture:SetTexture(info.texture)
		info.frame = icon
		-- How many of an item: none shows no number unless asked
		local count = info.count
		icon.count:SetText((count and (count > 0 or settings.showZero)) and tostring(count) or "")
		icon.count:ClearAllPoints()
		local point = COUNT_OFFSETS[settings.countPosition] and settings.countPosition or "BOTTOMRIGHT"
		local offset = COUNT_OFFSETS[point]
		icon.count:SetPoint(point, face, point, offset[1], offset[2])
		icon.count:SetFont(icon.countFont or STANDARD_TEXT_FONT or "Fonts\\ARIALN.TTF", settings.countSize, icon.countFlags or "OUTLINE")
		icon:SetAlpha(settings.alpha / 100)
		icon:Show()
	end
	for i = total + 1, #icons[group] do icons[group][i]:Hide() end
	MoveAnts(group, ants)
	AnimateGroup(group, placed, settings)
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

-- The icon of a choice on the page, the same as on the screen (for one not ticked, the one it would have)
function MissingBuffs.IconFor(choice)
	local entry = MissingBuffs.GetCharacter()
	if not entry then return choice.icon or PLACEHOLDER_ICON end
	return IconOf(choice, entry.buffs[choice.key] or {}, entry)
end

-- The spell of a family last seen on the character (or put on the weapons): true when it changed, so
-- the page shows its icon too
local function SetLastSeen(entry, key, name)
	if entry.lastSeen[key] == name then return false end
	entry.lastSeen[key] = name
	return true
end

-- Click to cast ------------------------------------------------------------------------------------
-- A click on the icon of a missing conjured item casts the spell that makes it; on a missing buff's,
-- the buff (on the character). Each is an option of its own. Casting needs the game's
-- "secure" buttons, which addons can't make, show, hide, move or change in combat: so they're kept apart
-- from the icons (placed over them, on the screen itself, never anchored to them, so the icons stay
-- free to change in combat), and only set out of combat. In combat they stay as they were: one already
-- there still works, one for an icon that shows in the fight comes when it ends.

local clickers = {}

local function GetClicker(index)
	local clicker = clickers[index]
	if clicker then return clicker end
	clicker = CreateFrame("Button", "KyoryokunaEnhancementsConjure" .. index, UIParent, "SecureActionButtonTemplate")
	clicker:RegisterForClicks("AnyUp", "AnyDown")
	clicker:SetFrameStrata("MEDIUM")
	clicker:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	clicker:SetAttribute("type", "spell")
	clicker:SetScript("OnEnter", function(self)
		if self.spellID and GameTooltip.SetSpellByID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		end
	end)
	clicker:SetScript("OnLeave", function() GameTooltip:Hide() end)
	clicker:Hide()
	clickers[index] = clicker
	return clicker
end

-- targets: the icons that cast on a click, with what to cast and on whom
local function SyncClickers(targets)
	if InCombatLockdown and InCombatLockdown() then return end
	local settings = ns.db.missingBuffs
	local count = 0
	if settings.enabled and not moving then
		for _, target in ipairs(targets) do
			local x, y = target.frame:GetCenter()
			local size = target.frame:GetWidth()
			if x and y and size then
				count = count + 1
				local clicker = GetClicker(count)
				clicker:ClearAllPoints()
				clicker:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
				clicker:SetSize(size, size)
				-- By its ID, so it's that exact rank (by its name the game may pick another)
				clicker:SetAttribute("spell", target.castID or target.castName)
				-- A buff on the character itself, whoever is targeted
				clicker:SetAttribute("unit", target.unit)
				clicker.spellID = target.castID
				clicker:Show()
			end
		end
	end
	for i = count + 1, #clickers do clickers[i]:Hide() end
end

-- The spell a click on a buff's icon casts: the one of the icon picked, else the one last seen on the
-- character, else the first one known
local function CastOf(choice, watch, entry)
	if watch and watch.icon and choice.memberIcons[watch.icon] then return watch.icon end
	local last = entry.lastSeen[choice.key]
	if last and choice.memberIcons[last] then return last end
	return choice.members[1]
end

-- What a click on each icon watched would cast, for /ke buffscan: {{label, spell, id, rank text}}
function MissingBuffs.CastInfo()
	local list = {}
	local entry = MissingBuffs.GetCharacter()
	if not entry then return list end
	for _, choices in ipairs({MissingBuffs.GetChoices()}) do
		for _, choice in ipairs(choices) do
			local watch = entry.buffs[choice.key]
			if watch then
				local name, id = choice.castName, choice.castID
				if choice.kind == "BUFF" or choice.kind == "WEAPON" then
					name = CastOf(choice, watch, entry)
					id = name and spellbook[name] and spellbook[name].best
				end
				list[#list + 1] = {label = choice.label, spell = name, id = id, rank = id and SpellSubtext(id) or ""}
			end
		end
	end
	return list
end

local function HideAll()
	for _, holder in pairs(holders) do holder:Hide() end
	SyncClickers({})
	HideGameIcons()
	StopEffects()
end

-- The weapons as last read (kept while the game hides them), and the check when the first enchant ends
-- (the game says nothing then)
local lastWeapons
local endTimer, endsAt

local function WatchEnd(seconds)
	if not (seconds and C_Timer and C_Timer.NewTimer and GetTime) then
		if endTimer then endTimer:Cancel() end
		endTimer, endsAt = nil, nil
		return
	end
	local at = GetTime() + seconds
	-- The same end already watched (each update reads it again)
	if endTimer and endsAt and math.abs(endsAt - at) < 1 then return end
	if endTimer then endTimer:Cancel() end
	endsAt = at
	endTimer = C_Timer.NewTimer(seconds + 0.5, function()
		endTimer, endsAt = nil, nil
		ns.SafeCall(MissingBuffs.Update)
	end)
end

function MissingBuffs.Update()
	if not (ns.db and characterKey) then return end
	local entry = MissingBuffs.GetCharacter()
	if not ns.db.missingBuffs.enabled and not moving then
		HideAll()
		WatchEnd(nil)
		return
	end
	-- All the buffs; when the game hides some (in combat), each one watched asked for by its name
	local before = lastActive or {}
	local active = ReadActiveNames() or ReadWatched(entry, before)
	-- In a fight, or under a restriction of the game (a boss pulled, before the character's own fight):
	-- the auras may be hidden
	local fighting = AurasHidden()
	local weapons = ReadWeapons()
	if weapons then lastWeapons = weapons else weapons = lastWeapons end
	local watchesWeapons, seenChanged = false, false
	local dead = UnitIsDeadOrGhost and UnitIsDeadOrGhost("player")
	local shown = {[ESSENTIAL] = {}, [UTILITY] = {}}
	-- The buffs' own icons the game shows or not (in combat), after the others of their group
	local byGame = {[ESSENTIAL] = {}, [UTILITY] = {}}
	local lists = {MissingBuffs.GetChoices()}
	for _, list in ipairs(lists) do
		for _, choice in ipairs(list) do
			local watch = entry.buffs[choice.key]
			if watch then
				local missing, itemCount, own = false, nil, nil
				if choice.kind == "ITEM" then
					itemCount = CountItems(choice)
					if itemCount then lastCounts[choice.key] = itemCount else itemCount = lastCounts[choice.key] end
					missing = itemCount ~= nil and itemCount < (watch.minimum or 1)
				elseif choice.kind == "WEAPON" then
					-- Nothing known yet (the game hiding the weapons from the start): not shown
					watchesWeapons = true
					missing = weapons ~= nil and weapons.missing
				else
					-- A buff the game may hide: in combat, as it was when the fight began (the game leaves
					-- it out of what's read), and its own icon is there, in its window only when the game
					-- shrinks its container (the buff gone); out of combat, that icon made for the next fight
					local hidden = Hidable(choice)
					if hidden and fighting then
						for name in pairs(choice.counts) do active[name] = before[name] end
					end
					local on = false
					for name in pairs(choice.counts) do
						if active[name] then
							on = true
							if spellbook[name] and not (hidden and fighting) then
								seenChanged = SetLastSeen(entry, choice.key, name) or seenChanged
							end
							break
						end
					end
					missing = not on
					if hidden then
						own = GameIcon(choice, IconOf(choice, watch, entry), GetHolder(GROUP_SETTINGS[watch.group] and watch.group or ESSENTIAL))
						if own and fighting and not moving then missing = true else own = nil end
					end
				end
				-- While moving, everything chosen shows, so the groups can be placed as they will look
				if moving or (missing and not dead) then
					local groups = own and byGame or shown
					local group = groups[watch.group] or groups[ESSENTIAL]
					group[#group + 1] = {texture = IconOf(choice, watch, entry), count = itemCount, choice = choice, own = own}
				end
			end
		end
	end
	lastActive = active
	local settings = ns.db.missingBuffs
	local targets = {}
	-- The buffs' own icons in use now; the others put away
	local inUse = {}
	for _, list in pairs(byGame) do
		for _, info in ipairs(list) do inUse[info.own] = true end
	end
	HideGameIcons(inUse)
	for group, list in pairs(shown) do
		for _, info in ipairs(byGame[group]) do list[#list + 1] = info end
		if moving and #list == 0 then list[1] = {texture = PLACEHOLDER_ICON} end
		Layout(group, list)
		for _, info in ipairs(list) do
			local choice = info.choice
			-- (no click on a buff's own icon: it may be there unseen, with the buff on)
			if choice and info.frame and not info.own then
				if choice.kind == "ITEM" and settings.clickToConjure and choice.castName then
					targets[#targets + 1] = {frame = info.frame, castName = choice.castName, castID = choice.castID}
				elseif (choice.kind == "BUFF" or choice.kind == "WEAPON") and settings.clickToCast then
					local name = CastOf(choice, entry.buffs[choice.key], entry)
					local known = name and spellbook[name]
					if known then
						targets[#targets + 1] = {frame = info.frame, castName = name, castID = known.best, unit = "player"}
					end
				end
			end
		end
	end
	SyncClickers(targets)
	-- An enchant on the weapons watched: looked at again when it ends
	WatchEnd(watchesWeapons and weapons and weapons.ends or nil)
	-- A family's "last used" changed: its icon on the page too, if it's open
	if seenChanged and ns.RefreshOptions then ns.RefreshOptions() end
end

-- /ke bufftest (out of combat): each buff's own icon (the ones the game may hide) shown in its group for
-- a few seconds as in a fight, with "KE test" over it: it should be seen while the buff is gone and
-- unseen while it's on (pushed out of its window by the game's container). The container's width and
-- where the icon is then are given back to be kept. Nil in combat, false with nothing to test.
local testLabel
function MissingBuffs.TestGameIcons(seconds)
	if InCombatLockdown and InCombatLockdown() then return nil end
	local entry = MissingBuffs.GetCharacter()
	local lines = {}
	local families, _, spells = MissingBuffs.GetChoices()
	for _, choices in ipairs({families, spells}) do
		for _, choice in ipairs(choices) do
			local watch = entry and entry.buffs[choice.key]
			local known = gameIcons[choice.key]
			if watch and known and known.window then
				local holder = GetHolder(GROUP_SETTINGS[watch.group] and watch.group or ESSENTIAL)
				holder:Show()
				local window = known.window
				window:ClearAllPoints()
				window:SetPoint("CENTER", holder, "CENTER", 0, 0)
				window:SetSize(40, 40)
				known.face:SetSize(40, 40)
				SetPad(window, 40)
				window:SetAlpha(1)
				window:Show()
				testLabel = testLabel or UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				testLabel:ClearAllPoints()
				testLabel:SetPoint("BOTTOM", window, "TOP", 0, 6)
				testLabel:SetText("KE test")
				testLabel:Show()
				lines[#lines + 1] = string.format("%s: %s; on now: %s", choice.label, GameIconState(choice),
					tostring(lastActive and next(choice.counts) and (function()
						for name in pairs(choice.counts) do if lastActive[name] then return true end end
						return false
					end)()))
			end
		end
	end
	if #lines == 0 then return false end
	if C_Timer and C_Timer.After then
		C_Timer.After(seconds, function()
			if testLabel then testLabel:Hide() end
			ns.SafeCall(MissingBuffs.Update)
		end)
	end
	return lines
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
	-- Its groups' look in the settings
	LoadLook(entry)
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
-- PLAYER_REGEN_ENABLED: the fight is over, the click buttons can follow the icons again
-- PLAYER_REGEN_DISABLED: the fight starts, the buffs the game may hide follow its frames
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST", "BAG_UPDATE_DELAYED",
	"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UI_SCALE_CHANGED"}) do
	ns.RegisterEvent(event, function() MissingBuffs.Update() end)
end
-- A restriction of the game about to start (the auras still readable) or just ended: e.g. a boss pulled
-- before the character is in combat itself (see AurasHidden)
ns.RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", function(_, restriction, state)
	if restriction == nil then return end
	restrictionStates[restriction] = state
	MissingBuffs.Update()
end)

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

-- The weapons: an enchant put on or gone, a weapon changed. And the last of a family cast on them (an
-- imbue), for the family's icon when it's the one last used.
ns.RegisterEvent("UNIT_INVENTORY_CHANGED", function(_, unit)
	if unit == "player" then MissingBuffs.Update() end
end)
ns.RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function() MissingBuffs.Update() end)
ns.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
	if unit ~= "player" or not characterKey then return end
	local weapon = WEAPONS[playerClass]
	if not weapon then return end
	local choice = FindChoice(weapon.key)
	local name = SpellName(ns.Known(spellID))
	if choice and name and choice.memberIcons[name] then
		local changed = SetLastSeen(MissingBuffs.GetCharacter(), choice.key, name)
		MissingBuffs.Update()
		if changed and ns.RefreshOptions then ns.RefreshOptions() end
	end
end)
-- On a frame of its own: older versions of the game don't have this event
local weaponFrame = CreateFrame("Frame")
pcall(weaponFrame.RegisterEvent, weaponFrame, "WEAPON_ENCHANT_CHANGED")
weaponFrame:SetScript("OnEvent", function()
	if ns.NEEDS_RESTART then return end
	ns.SafeCall(MissingBuffs.Update)
end)

-- For the tests
function MissingBuffs.GetHolder(group)
	return holders[group or ESSENTIAL]
end

function MissingBuffs.GetAntsClock()
	return antsClock
end
