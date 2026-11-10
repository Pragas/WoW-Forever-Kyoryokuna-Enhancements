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
}

-- {minimum, maximum} of each number, by section
ns.LIMITS = {
	general = {minimapAngle = {0, 360}},
	darkMode = {darkness = {5, 100}},
	actionBars = {cooldownScale = {50, 200}},
}

-- The values a choice can take; anything else goes back to the default
ns.CHOICES = {
	general = {language = {enUS = true, ptPT = true}},
	actionBars = {keyPressStyle = {FLASH = true, BORDER = true}},
	experienceBar = {texture = {FLAT = true, SMOOTH = true, CLASSIC = true, RAID = true}},
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
		if type(db[name]) == "table" and not ns.DEFAULTS[name] and name ~= "errors" and name ~= "backups" then
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
