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
	},
}

-- {minimum, maximum} of each number, by section
ns.LIMITS = {}

-- The values a choice can take; anything else goes back to the default
ns.CHOICES = {
	general = {language = {enUS = true, ptPT = true}},
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
		if type(db[name]) == "table" and not ns.DEFAULTS[name] and name ~= "errors" then
			db[name] = nil
		end
	end
	for name, defaults in pairs(ns.DEFAULTS) do
		if type(db[name]) ~= "table" then db[name] = {} end
		ValidateSection(name, db[name], defaults)
	end
	if type(db.errors) ~= "table" then db.errors = {} end
	db.version = DB_VERSION
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

-- A change: a new language makes the options again; the options show the new values
function ns.OnSettingChanged(path)
	if path == "general.language" then
		ns.language = ns.db.general.language
		if ns.RebuildOptions then ns.RebuildOptions() end
	end
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
