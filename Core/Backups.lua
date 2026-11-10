-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Sharing and keeping the settings (Import / Export page):
--   - export: all the settings in one line of text, to copy and give to someone. What's personal stays
--     out (language, minimap button);
--   - import: such a line read back. It's only ever read as text, never run: each "section.key=value"
--     must be a setting that exists, of the right kind, and the usual checks (limits, choices) follow.
--     Settings the line doesn't have (e.g. from an older version) keep their value;
--   - backups: copies of all the settings, kept with the date and the version, to put back later. One
--     is made by itself before an import or a restore, so those can be undone too.

local _, ns = ...
local L = ns.L

local PREFIX = "KE1"
local MAX_BACKUPS = 10

-- Not shared: they belong to the player, not to the look
local PERSONAL = {
	["general.language"] = true,
	["general.minimapIcon"] = true,
	["general.minimapAngle"] = true,
}

local function SortedKeys(t)
	local keys = {}
	for key in pairs(t) do keys[#keys + 1] = key end
	table.sort(keys)
	return keys
end

local function FormatNumber(value)
	-- Short, without trailing zeros: 144, 1.25, 0.17
	local text = string.format("%.3f", value):gsub("0+$", ""):gsub("%.$", "")
	return text
end

local function EncodeValue(value)
	local kind = type(value)
	if kind == "boolean" then return value and "t" or "f" end
	if kind == "number" then return FormatNumber(value) end
	if kind == "table" then
		return FormatNumber(value[1]) .. "," .. FormatNumber(value[2]) .. "," .. FormatNumber(value[3])
	end
	return tostring(value)
end

-- A value read back as the kind its default has; nil when it isn't one
local function DecodeValue(text, default)
	local kind = type(default)
	if kind == "boolean" then
		if text == "t" then return true elseif text == "f" then return false end
		return nil
	end
	if kind == "number" then return tonumber(text) end
	if kind == "table" then
		local r, g, b = text:match("^([%d%.]+),([%d%.]+),([%d%.]+)$")
		r, g, b = tonumber(r), tonumber(g), tonumber(b)
		if not (r and g and b) then return nil end
		local function Clamp(v) return math.min(1, math.max(0, v)) end
		return {Clamp(r), Clamp(g), Clamp(b)}
	end
	if kind == "string" then
		-- Only plain words (every text setting is a choice like "INSIDE_RIGHT")
		if text:match("^[%w_]+$") then return text end
		return nil
	end
end

-- Export ---------------------------------------------------------------------------------------------

function ns.ExportSettings()
	local parts = {PREFIX}
	for _, section in ipairs(SortedKeys(ns.DEFAULTS)) do
		for _, key in ipairs(SortedKeys(ns.DEFAULTS[section])) do
			local path = section .. "." .. key
			if not PERSONAL[path] then
				parts[#parts + 1] = path .. "=" .. EncodeValue(ns.db[section][key])
			end
		end
	end
	return table.concat(parts, ";")
end

-- Import ---------------------------------------------------------------------------------------------

-- The settings a line of text holds, as {section = {key = value}}, and how many; nil and a reason when
-- it isn't a code of this addon
function ns.ParseSettings(text)
	if type(text) ~= "string" then return nil, L["That isn't a Kyoryokuna Enhancements code."] end
	-- Spaces and line breaks picked up when copying don't matter
	text = text:gsub("%s+", "")
	local parts = {}
	for part in text:gmatch("[^;]+") do parts[#parts + 1] = part end
	if parts[1] ~= PREFIX then return nil, L["That isn't a Kyoryokuna Enhancements code."] end
	local settings, count = {}, 0
	for i = 2, #parts do
		local section, key, value = parts[i]:match("^([%a]+)%.([%w]+)=(.+)$")
		local defaults = section and ns.DEFAULTS[section]
		local default = defaults and defaults[key]
		if default ~= nil and not PERSONAL[section .. "." .. key] then
			local decoded = DecodeValue(value, default)
			if decoded ~= nil then
				settings[section] = settings[section] or {}
				settings[section][key] = decoded
				count = count + 1
			end
		end
	end
	if count == 0 then return nil, L["That code has no settings this version knows."] end
	return settings, count
end

-- Puts settings in place ({section = {key = value}}), then checks them all (limits, choices) and
-- refreshes everything that depends on them
local function ApplySettings(settings)
	for section, values in pairs(settings) do
		if ns.DEFAULTS[section] and type(values) == "table" then
			for key, value in pairs(values) do
				if ns.DEFAULTS[section][key] ~= nil then
					ns.db[section][key] = ns.CopyValue(value)
				end
			end
		end
	end
	ns.ValidateSettings()
	if ns.OnAllSettingsChanged then ns.OnAllSettingsChanged() end
end

function ns.ImportSettings(text)
	local settings, countOrReason = ns.ParseSettings(text)
	if not settings then
		ns.Print(countOrReason)
		return false
	end
	ns.CreateBackup("Before import", true)
	ApplySettings(settings)
	ns.Print(string.format(L["%d settings imported. Your previous settings were kept as a backup."], countOrReason))
	return true
end

-- Backups --------------------------------------------------------------------------------------------

function ns.GetBackups()
	return ns.db.backups
end

-- A name given by the player: one line, without the "|" of the game's color and texture codes; nil when
-- nothing is left. The boxes take at most MAX_NAME letters; here it's only kept from growing past what
-- that many letters can take, without cutting an accented letter in half.
local MAX_NAME = 40

local function CutText(text, maxBytes)
	if #text <= maxBytes then return text end
	text = text:sub(1, maxBytes)
	-- A letter of more than one byte cut in half is dropped
	local last = #text
	local i = last
	while i > 0 and text:byte(i) >= 128 and text:byte(i) < 192 do i = i - 1 end
	if i > 0 and text:byte(i) >= 192 then
		local lead = text:byte(i)
		local size = lead >= 240 and 4 or lead >= 224 and 3 or 2
		if last - i + 1 < size then text = text:sub(1, i - 1) end
	end
	return text
end

local function CleanName(name)
	if type(name) ~= "string" then return nil end
	name = name:gsub("|", ""):gsub("%c", " "):gsub("^%s+", ""):gsub("%s+$", "")
	name = CutText(name, MAX_NAME * 3)
	if name == "" then return nil end
	return name
end

-- What a backup is called: the player's name for it, or its label in the language of the moment
function ns.GetBackupName(backup)
	return CleanName(backup.name) or L[backup.label or "Backup"]
end

-- A copy of all the settings, newest first; the oldest go when there are more than MAX_BACKUPS. The
-- label is kept in English and shown in the language of the moment ("Backup", "Before import"...); the
-- player can give it a name of their own, now or later.
function ns.CreateBackup(label, quiet, name)
	local settings = {}
	for section in pairs(ns.DEFAULTS) do
		settings[section] = ns.CopyValue(ns.db[section])
	end
	local backups = ns.db.backups
	table.insert(backups, 1, {
		date = date and date("%Y-%m-%d %H:%M") or "",
		version = ns.VERSION,
		label = label,
		name = CleanName(name),
		settings = settings,
	})
	while #backups > MAX_BACKUPS do table.remove(backups) end
	if not quiet then ns.Print(L["Backup created."]) end
	if ns.RefreshOptions then ns.RefreshOptions() end
end

function ns.RestoreBackup(index)
	local backup = ns.db.backups[index]
	if not backup or type(backup.settings) ~= "table" then return false end
	-- The settings as they are now, so the restore can be undone; the one restored moves down by one
	ns.CreateBackup("Before restore", true)
	ApplySettings(backup.settings)
	ns.Print(string.format(L["Backup of %s restored."], tostring(backup.date)))
	return true
end

-- A new name for a backup; an empty one gives it back its label
function ns.RenameBackup(index, name)
	local backup = ns.db.backups[index]
	if not backup then return end
	backup.name = CleanName(name)
	if ns.RefreshOptions then ns.RefreshOptions() end
end

ns.MAX_BACKUP_NAME = MAX_NAME

function ns.DeleteBackup(index)
	if not ns.db.backups[index] then return end
	table.remove(ns.db.backups, index)
	if ns.RefreshOptions then ns.RefreshOptions() end
end

ns.MAX_BACKUPS = MAX_BACKUPS
ns.CutText = CutText
