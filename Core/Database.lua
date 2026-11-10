-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The saved settings: their defaults, the limits of the numbers, and the checks done when they load.
-- A missing setting gets its default, a setting of the wrong kind goes back to it, and a number outside
-- its limits is brought back inside them. Settings are shared by every character of the account.

local addonName, ns = ...

local DB_VERSION = 1

ns.DEFAULTS = {
	general = {
		language = "enUS",
		-- The button on the edge of the minimap, and where it sits (degrees; away from the other
		-- Kyoryokuna addons' buttons by default)
		minimapIcon = true,
		minimapAngle = 250,
	},

	-- Dark mode (Modules\DarkMode.lua): off by default; how dark (%), and which parts of the interface
	darkMode = {
		enabled = false,
		darkness = 80,
		unitFrames = true,
		actionBars = true,
		castBars = true,
		minimap = true,
		tooltips = true,
		objectives = true,
		personalResource = true,
		bags = true,
		gameMenu = true,
		groupFrames = true,
	},

	-- Action bars (Modules\ActionBars.lua): texts on the buttons, the size of the cooldown numbers (% of
	-- the game's), an effect when a button's key is pressed, and the micro menu's frame
	actionBars = {
		hideKeybinds = false,
		hideMacroNames = false,
		cooldownScale = 100,
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
		enabled = true,
		bar = true,
	},

	-- Missing buffs (Modules\MissingBuffs.lua), in two groups with a look and a place each (from the center
	-- of the screen; the side they grow from stays there). What's watched is kept for each character, in
	-- characters (see Validate).
	missingBuffs = {
		enabled = true,
	},
	missingBuffsEssential = {
		iconSize = 40,
		alpha = 50,
		spacing = 4,
		growth = "CENTER",
		x = 0,
		y = 180,
	},
	missingBuffsUtility = {
		iconSize = 32,
		alpha = 50,
		spacing = 4,
		growth = "CENTER",
		x = 0,
		y = 130,
	},
}

local GROUP_LIMITS = {iconSize = {20, 80}, alpha = {10, 100}, spacing = {0, 20}, x = {-1500, 1500}, y = {-1000, 1000}}
local GROWTH = {CENTER = true, RIGHT = true, LEFT = true, UP = true, DOWN = true}

-- {minimum, maximum} of each number, by section
ns.LIMITS = {
	general = {minimapAngle = {0, 360}},
	darkMode = {darkness = {5, 100}},
	actionBars = {cooldownScale = {50, 200}},
	missingBuffsEssential = GROUP_LIMITS,
	missingBuffsUtility = GROUP_LIMITS,
}

-- The values a choice can take; anything else goes back to the default
ns.CHOICES = {
	general = {language = {enUS = true, ptPT = true}},
	actionBars = {keyPressStyle = {FLASH = true, BORDER = true}},
	experienceBar = {texture = {FLAT = true, SMOOTH = true, CLASSIC = true, RAID = true}},
	missingBuffsEssential = {growth = GROWTH},
	missingBuffsUtility = {growth = GROWTH},
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
		if type(db[name]) == "table" and not ns.DEFAULTS[name] and name ~= "errors" and name ~= "backups" and name ~= "characters" then
			db[name] = nil
		end
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
	-- missingBuffs, missingBuffsEssential, missingBuffsUtility
	if path:find("^missingBuffs") and ns.MissingBuffs then ns.MissingBuffs.Update() end
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
	if ns.MissingBuffs then ns.MissingBuffs.Update() end
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Loading ------------------------------------------------------------------------------------------

ns.RegisterEvent("ADDON_LOADED", function(_, loadedName)
	if loadedName ~= addonName then return end
	if type(KyoryokunaEnhancementsDB) ~= "table" then
		KyoryokunaEnhancementsDB = {}
	end
	Validate(KyoryokunaEnhancementsDB)
	ns.db = KyoryokunaEnhancementsDB
	ns.language = ns.db.general.language
	ns.FlushSessionErrors()
end)
