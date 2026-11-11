-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The saved settings: their defaults, the limits of the numbers, and the checks done when they load.
-- A missing setting gets its default, a setting of the wrong kind goes back to it, and a number outside
-- its limits is brought back inside them. Settings are shared by every character of the account.

local addonName, ns = ...

local DB_VERSION = 1

-- A new install starts with nothing turned on but the minimap button, in English: each player sets up
-- what they want (settings already saved never change)
ns.DEFAULTS = {
	general = {
		language = "enUS",
		-- The button on the edge of the minimap, and where it sits (degrees; away from the other
		-- Kyoryokuna addons' buttons by default)
		minimapIcon = true,
		minimapAngle = 250,
	},

	-- Dark mode (Modules\DarkMode.lua): how dark (%), and which parts of the interface
	darkMode = {
		enabled = false,
		darkness = 80,
		unitFrames = false,
		actionBars = false,
		castBars = false,
		minimap = false,
		tooltips = false,
		objectives = false,
		personalResource = false,
		bags = false,
		gameMenu = false,
		groupFrames = false,
	},

	-- Action bars (Modules\ActionBars.lua): texts on the buttons, the size of the cooldown numbers (% of
	-- the game's), an effect when a button's key is pressed, and the micro menu's frame
	actionBars = {
		hideKeybinds = false,
		hideMacroNames = false,
		cooldownScale = 100,
		-- The numbers colored by the time left: red while long, a toasted yellow in the last seconds
		cooldownColors = false,
		cooldownColorLong = {1, 0.2, 0.2},
		cooldownColorShort = {0.85, 0.65, 0.13},
		cooldownColorThreshold = 5,
		keyPress = false,
		keyPressStyle = "FLASH",
		hideMicroMenuBorder = false,
	},

	-- The experience bar (Modules\ExperienceBar.lua): a texture of the addon instead of the game's
	experienceBar = {
		enabled = false,
		texture = "SMOOTH",
	},

	-- How long is left to accept a dungeon or battleground that's ready (Modules\QueueTimer.lua)
	queueTimer = {
		enabled = false,
		bar = false,
	},

	-- The game's red error messages (Modules\ErrorMessages.lua): which kinds are hidden, only in combat or
	-- always, all of them, and the voice of the ones kept
	errorMessages = {
		enabled = false,
		onlyInCombat = false,
		hideAll = false,
		cooldown = false,
		power = false,
		range = false,
		sight = false,
		facing = false,
		target = false,
		busy = false,
		moving = false,
		muteVoice = false,
	},

	-- The class trainer (Modules\Trainer.lua): a box on each spell to choose the ones learned, and the new
	-- spells told at each level. The trainer's list is kept for each character, in characters. A new rank
	-- learned takes the place of the one before on the action bars (Modules\NewRanks.lua).
	trainer = {
		choose = false,
		notify = false,
		newRanks = false,
		-- A tab in the spellbook with the spells still to learn (Modules\SpellbookTab.lua)
		spellbookTab = false,
	},

	-- Quest items sparkling in the world (Modules\QuestSparkles.lua)
	questSparkles = {
		enabled = false,
	},

	-- FPS and latency on the screen (Modules\Performance.lua): what's shown (BOTH, FPS, PING), which
	-- latency (WORLD, HOME, BOTH), colored by value, the text's size and color, a dark background, and its
	-- place from the middle of the screen
	performance = {
		enabled = false,
		show = "BOTH",
		ping = "WORLD",
		colors = false,
		size = 12,
		color = {1, 0.82, 0},
		background = false,
		x = 0,
		y = 330,
	},

	-- Missing buffs (Modules\MissingBuffs.lua), in two groups with a look and a place each (from the center
	-- of the screen; the side they grow from stays there). What's watched is kept for each character, in
	-- characters (see Validate).
	missingBuffs = {
		enabled = false,
		-- A click on a conjured item's icon casts the spell that makes it; on a buff's, the buff
		clickToConjure = false,
		clickToCast = false,
	},
	-- Supplies (Modules\Supplies.lua): which macros each character wants is kept with it, in characters;
	-- whether food with a buff counts is shared
	supplies = {
		buffFood = false,
		-- The icon of the macro that eats and drinks: the food's or the drink's
		bothIcon = "FOOD",
	},
	-- Proc alerts (Modules\ProcAlerts.lua): the art's size (%), the distance between the sides, its place
	-- from the middle of the screen (x, y), its opacity (%), the pulse, and each proc on or off
	procAlerts = {
		enabled = false,
		size = 100,
		distance = 0,
		x = 0,
		y = 0,
		opacity = 80,
		-- How the art moves while the proc is there (NONE, PULSE, BREATHE, BLINK, FLOAT), how long a cycle
		-- lasts (seconds), how strong it is (%), and whether it appears softly
		animation = "NONE",
		animTime = 1,
		animStrength = 8,
		fadeIn = false,
		missileBarrage = false,
		clearcasting = false,
		fingersOfFrost = false,
		heatingUp = false,
		-- The other classes' (each character only sees its own class')
		eclipse = false,
		omenOfClarity = false,
		naturesGrace = false,
		rapidKilling = false,
		mongooseBite = false,
		infusionOfLight = false,
		martyrdom = false,
		searingLight = false,
		remorselessAttacks = false,
		cutthroat = false,
		riposte = false,
		maelstromWeapon = false,
		nightfall = false,
		decimation = false,
		eyeOfKilrogg = false,
		victoryRush = false,
		-- Abilities that only light their button
		iceBarrier = false,
		overpower = false,
		execute = false,
		revenge = false,
		counterattack = false,
		holyShock = false,
		exorcism = false,
		hammerOfWrath = false,
		stormstrike = false,
		-- Abilities with art that can also light their button: the art, the button, or both
		victoryRushAlert = "ART",
		riposteAlert = "ART",
		mongooseBiteAlert = "ART",
	},
	-- The number on an item's icon (how many the bags hold): hidden at 0 unless asked, in a corner or in
	-- the middle, with a size of its own
	missingBuffsEssential = {
		iconSize = 40,
		alpha = 50,
		spacing = 4,
		growth = "CENTER",
		x = 0,
		y = 180,
		showZero = false,
		countPosition = "BOTTOMRIGHT",
		countSize = 14,
	},
	missingBuffsUtility = {
		iconSize = 32,
		alpha = 50,
		spacing = 4,
		growth = "CENTER",
		x = 0,
		y = 130,
		showZero = false,
		countPosition = "BOTTOMRIGHT",
		countSize = 14,
	},
}

local GROUP_LIMITS = {iconSize = {20, 80}, alpha = {10, 100}, spacing = {0, 20}, countSize = {8, 40}, x = {-1500, 1500}, y = {-1000, 1000}}
local GROWTH = {CENTER = true, RIGHT = true, LEFT = true, UP = true, DOWN = true}
local COUNT_POSITIONS = {BOTTOMRIGHT = true, BOTTOMLEFT = true, CENTER = true, TOPRIGHT = true, TOPLEFT = true}
-- How an ability with art warns: its art, its button glowing, or both
local ALERT_KINDS = {ART = true, BUTTON = true, BOTH = true}

-- {minimum, maximum} of each number, by section
ns.LIMITS = {
	general = {minimapAngle = {0, 360}},
	darkMode = {darkness = {5, 100}},
	actionBars = {cooldownScale = {50, 200}, cooldownColorThreshold = {1, 30}},
	procAlerts = {size = {50, 200}, distance = {-100, 400}, x = {-1500, 1500}, y = {-1000, 1000}, opacity = {10, 100},
		animTime = {0.5, 3}, animStrength = {2, 20}},
	missingBuffsEssential = GROUP_LIMITS,
	missingBuffsUtility = GROUP_LIMITS,
	performance = {size = {8, 32}, x = {-1500, 1500}, y = {-1000, 1000}},
}

-- The values a choice can take; anything else goes back to the default
ns.CHOICES = {
	general = {language = {enUS = true, ptPT = true}},
	actionBars = {keyPressStyle = {FLASH = true, BORDER = true}},
	experienceBar = {texture = {FLAT = true, SMOOTH = true, CLASSIC = true, RAID = true}},
	missingBuffsEssential = {growth = GROWTH, countPosition = COUNT_POSITIONS},
	missingBuffsUtility = {growth = GROWTH, countPosition = COUNT_POSITIONS},
	supplies = {bothIcon = {FOOD = true, DRINK = true}},
	procAlerts = {victoryRushAlert = ALERT_KINDS, riposteAlert = ALERT_KINDS, mongooseBiteAlert = ALERT_KINDS,
		animation = {NONE = true, PULSE = true, BREATHE = true, BLINK = true, FLOAT = true}},
	performance = {show = {BOTH = true, FPS = true, PING = true}, ping = {WORLD = true, HOME = true, BOTH = true}},
}

local function CopyValue(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do copy[k] = CopyValue(v) end
	return copy
end
ns.CopyValue = CopyValue

local function ValidateSection(name, saved, defaults)
	local limits = ns.LIMITS[name] or {}
	local choices = ns.CHOICES[name] or {}
	for key, default in pairs(defaults) do
		local value = saved[key]
		if type(value) ~= type(default) then
			saved[key] = CopyValue(default)
		elseif type(default) == "number" and limits[key] then
			saved[key] = math.min(limits[key][2], math.max(limits[key][1], value))
		elseif type(default) == "string" and choices[key] and not choices[key][value] then
			saved[key] = default
		end
	end
	-- Settings that no longer exist are removed
	for key in pairs(saved) do
		if defaults[key] == nil then saved[key] = nil end
	end
end

local function Validate(db)
	for name in pairs(db) do
		if type(db[name]) == "table" and not ns.DEFAULTS[name] and name ~= "errors" and name ~= "backups" and name ~= "characters"
			and name ~= "procScan" and name ~= "diagnostics" then
			db[name] = nil
		end
	end
	-- Before the choice of animations, the proc alerts had a "Pulse" check: on, it's the pulse now
	if type(db.procAlerts) == "table" and db.procAlerts.pulse ~= nil then
		if db.procAlerts.pulse == true and db.procAlerts.animation == nil then db.procAlerts.animation = "PULSE" end
		db.procAlerts.pulse = nil
	end
	for name, defaults in pairs(ns.DEFAULTS) do
		if type(db[name]) ~= "table" then db[name] = {} end
		ValidateSection(name, db[name], defaults)
	end
	if type(db.errors) ~= "table" then db.errors = {} end
	-- Backups of the settings (Core\Backups.lua): only whole ones are kept
	if type(db.backups) ~= "table" then db.backups = {} end
	for i = #db.backups, 1, -1 do
		local backup = db.backups[i]
		if type(backup) ~= "table" or type(backup.settings) ~= "table" then table.remove(db.backups, i) end
	end
	-- What each character keeps for itself, by "Name-Realm": its class, what it watches (by key: the
	-- group, the icon picked, the minimum of an item), and the spell of each family last seen on it
	if type(db.characters) ~= "table" then db.characters = {} end
	for key, entry in pairs(db.characters) do
		if type(key) ~= "string" or type(entry) ~= "table" or type(entry.class) ~= "string" then
			db.characters[key] = nil
		else
			if type(entry.buffs) ~= "table" then entry.buffs = {} end
			for buff, watch in pairs(entry.buffs) do
				-- Before the groups, a buff watched was just "true"
				if watch == true then
					watch = {group = "ESSENTIAL"}
					entry.buffs[buff] = watch
				end
				if type(buff) ~= "string" or type(watch) ~= "table" then
					entry.buffs[buff] = nil
				else
					if watch.group ~= "ESSENTIAL" and watch.group ~= "UTILITY" then watch.group = "ESSENTIAL" end
					if type(watch.icon) ~= "string" then watch.icon = nil end
					if type(watch.minimum) == "number" then
						watch.minimum = math.min(20, math.max(1, math.floor(watch.minimum)))
					else
						watch.minimum = nil
					end
				end
			end
			if type(entry.lastSeen) ~= "table" then entry.lastSeen = {} end
			for buff, name in pairs(entry.lastSeen) do
				if type(buff) ~= "string" or type(name) ~= "string" then entry.lastSeen[buff] = nil end
			end
			if entry.copyOffered ~= true then entry.copyOffered = nil end
			-- The macros of food and drink it wants (Modules\Supplies.lua)
			if type(entry.supplies) ~= "table" then entry.supplies = {} end
			for key, on in pairs(entry.supplies) do
				if (key ~= "FOOD" and key ~= "DRINK" and key ~= "BOTH") or on ~= true then entry.supplies[key] = nil end
			end
			-- Its trainer's list from the last visit: each spell not learned yet ("Name\tRank") with the
			-- level it needs, its cost, icon and spell; and that trainer's name and place (Modules\Trainer.lua)
			if type(entry.trainer) ~= "table" then
				entry.trainer = nil
			else
				for key, data in pairs(entry.trainer) do
					-- At first only the level was kept
					if type(data) == "number" then
						data = {level = data}
						entry.trainer[key] = data
					end
					if type(key) ~= "string" or type(data) ~= "table" or type(data.level) ~= "number" then
						entry.trainer[key] = nil
					else
						if type(data.cost) ~= "number" then data.cost = 0 end
						if type(data.icon) ~= "number" and type(data.icon) ~= "string" then data.icon = nil end
						if type(data.id) ~= "number" then data.id = nil end
						-- An ability it needs that the trainer doesn't teach (a talent's spell)
						if type(data.requires) ~= "string" then data.requires = nil end
					end
				end
			end
			if type(entry.trainerVisit) ~= "table" then
				entry.trainerVisit = nil
			else
				if type(entry.trainerVisit.name) ~= "string" then entry.trainerVisit.name = nil end
				if type(entry.trainerVisit.zone) ~= "string" then entry.trainerVisit.zone = nil end
			end
		end
	end
	db.version = DB_VERSION
end

-- Every setting checked again (after an import or a restore put many in place at once)
function ns.ValidateSettings()
	for name, defaults in pairs(ns.DEFAULTS) do
		if type(ns.db[name]) ~= "table" then ns.db[name] = {} end
		ValidateSection(name, ns.db[name], defaults)
	end
end

-- Reading and writing by path, e.g. "general.language" ----------------------------------------------

local function Split(path)
	return path:match("^([^.]+)%.(.+)$")
end

function ns.Get(path)
	local section, key = Split(path)
	return ns.db[section][key]
end

function ns.GetLimits(path)
	local section, key = Split(path)
	local limits = ns.LIMITS[section] and ns.LIMITS[section][key]
	if limits then return limits[1], limits[2] end
end

function ns.Set(path, value)
	local section, key = Split(path)
	local default = ns.DEFAULTS[section][key]
	if type(value) == "number" and ns.LIMITS[section] and ns.LIMITS[section][key] then
		local limits = ns.LIMITS[section][key]
		value = math.min(limits[2], math.max(limits[1], value))
	end
	if type(value) ~= type(default) then return end
	-- A choice only takes one of its values
	local choices = ns.CHOICES[section] and ns.CHOICES[section][key]
	if choices and not choices[value] then return end
	ns.db[section][key] = CopyValue(value)
	if ns.OnSettingChanged then ns.OnSettingChanged(path) end
end

-- A change: a new language makes the options again; the minimap button and the options follow
function ns.OnSettingChanged(path)
	if path == "general.language" then
		ns.language = ns.db.general.language
		if ns.RebuildOptions then ns.RebuildOptions() end
	end
	if ns.UpdateMinimapButton then ns.UpdateMinimapButton() end
	-- Each feature follows at once
	if path:find("^darkMode%.") and ns.DarkMode then ns.DarkMode.Apply() end
	if path:find("^actionBars%.") and ns.ActionBars then ns.ActionBars.Apply() end
	if path:find("^experienceBar%.") and ns.ExperienceBar then ns.ExperienceBar.Apply() end
	if path:find("^queueTimer%.") and ns.QueueTimer then ns.QueueTimer.Refresh() end
	if path:find("^errorMessages%.") and ns.ErrorMessages then ns.ErrorMessages.Apply() end
	if path:find("^trainer%.") and ns.Trainer then ns.Trainer.Apply() end
	-- The trainer's page shows the spells waiting only while they're kept
	if (path == "trainer.notify" or path == "trainer.spellbookTab") and ns.RebuildOptionsPage then ns.RebuildOptionsPage("Trainer") end
	if path == "trainer.spellbookTab" and ns.SpellbookTab then ns.SpellbookTab.Apply() end
	if path:find("^questSparkles%.") and ns.QuestSparkles then ns.QuestSparkles.Apply() end
	if path:find("^performance%.") and ns.Performance then ns.Performance.Update() end
	-- missingBuffs, missingBuffsEssential, missingBuffsUtility
	if path:find("^missingBuffs") and ns.MissingBuffs then ns.MissingBuffs.Update() end
	if path:find("^procAlerts%.") and ns.ProcAlerts then ns.ProcAlerts.Update() end
	-- A new language renames the macros
	if (path:find("^supplies%.") or path == "general.language") and ns.Supplies then ns.Supplies.Update() end
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Many settings changed at once (an import, or a backup put back): everything follows
function ns.OnAllSettingsChanged()
	if ns.language ~= ns.db.general.language then
		ns.language = ns.db.general.language
		if ns.RebuildOptions then ns.RebuildOptions() end
	end
	if ns.UpdateMinimapButton then ns.UpdateMinimapButton() end
	if ns.DarkMode then ns.DarkMode.Apply() end
	if ns.ActionBars then ns.ActionBars.Apply() end
	if ns.ExperienceBar then ns.ExperienceBar.Apply() end
	if ns.QueueTimer then ns.QueueTimer.Refresh() end
	if ns.ErrorMessages then ns.ErrorMessages.Apply() end
	if ns.Trainer then ns.Trainer.Apply() end
	if ns.SpellbookTab then ns.SpellbookTab.Apply() end
	if ns.QuestSparkles then ns.QuestSparkles.Apply() end
	if ns.Performance then ns.Performance.Update() end
	if ns.MissingBuffs then ns.MissingBuffs.Update() end
	if ns.Supplies then ns.Supplies.Update() end
	if ns.ProcAlerts then ns.ProcAlerts.Update() end
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Loading ------------------------------------------------------------------------------------------

ns.RegisterEvent("ADDON_LOADED", function(_, loadedName)
	if loadedName ~= addonName then return end
	if type(KyoryokunaEnhancementsDB) ~= "table" then
		KyoryokunaEnhancementsDB = {}
	end
	-- Nothing saved yet: the addon's first use. The welcome window then says what the addon is, until
	-- its OK is clicked (Core\ReleaseNotes.lua)
	if KyoryokunaEnhancementsDB.version == nil then KyoryokunaEnhancementsDB.firstWelcome = true end
	Validate(KyoryokunaEnhancementsDB)
	ns.db = KyoryokunaEnhancementsDB
	ns.language = ns.db.general.language
	ns.FlushSessionErrors()
end)
