-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Errors of this addon are caught and kept (the last ones, with the addon's version), so one failing
-- part doesn't break the others. The chat says so once per session, when the first one happens.

local _, ns = ...
local L = ns.L

local MAX_ERRORS = 30

local sessionErrors = {}
local warned = false

local function Store(message)
	local entry = date("%Y-%m-%d %H:%M:%S") .. "  v" .. tostring(ns.VERSION) .. "  " .. tostring(message)
	sessionErrors[#sessionErrors + 1] = entry
	if ns.db then
		local saved = ns.db.errors
		saved[#saved + 1] = entry
		while #saved > MAX_ERRORS do table.remove(saved, 1) end
	end
	if not warned then
		warned = true
		ns.Print(L["An error happened. Type /ke errors to see it."])
	end
end

local function Handler(message)
	local stack = debugstack and debugstack(2, 6, 0) or ""
	return tostring(message) .. "\n" .. stack
end

function ns.SafeCall(func, ...)
	-- Waiting for the game to be restarted (Init.lua): nothing runs
	if ns.NEEDS_RESTART then return end
	local results = {xpcall(func, Handler, ...)}
	if not results[1] then
		Store(results[2])
		return
	end
	return unpack(results, 2)
end

-- Errors kept before the saved settings were loaded go into them as soon as they are
function ns.FlushSessionErrors()
	if not ns.db then return end
	local saved = ns.db.errors
	for _, entry in ipairs(sessionErrors) do saved[#saved + 1] = entry end
	while #saved > MAX_ERRORS do table.remove(saved, 1) end
end

function ns.PrintErrors()
	local saved = ns.db and ns.db.errors or sessionErrors
	if #saved == 0 then
		ns.Print(L["No errors recorded."])
		return
	end
	ns.Print(string.format(L["%d error(s) recorded, newest last:"], #saved))
	for _, entry in ipairs(saved) do
		DEFAULT_CHAT_FRAME:AddMessage("|cffff6060" .. entry .. "|r")
	end
end

-- Diagnostics: what the /ke ...scan commands write in the chat is also kept in the saved data
-- (diagnostics, the newest last), so it can be read from the file the game writes at the next /reload
-- instead of from screenshots. The last 20 are kept.
local MAX_DIAGNOSTICS = 20

function ns.SaveDiagnostic(command, lines)
	if not ns.db then return end
	if type(ns.db.diagnostics) ~= "table" then ns.db.diagnostics = {} end
	local copy = {}
	for _, line in ipairs(lines or {}) do copy[#copy + 1] = tostring(line) end
	table.insert(ns.db.diagnostics, {
		when = date and date("%Y-%m-%d %H:%M:%S") or "?",
		version = ns.VERSION,
		command = command,
		lines = copy,
	})
	while #ns.db.diagnostics > MAX_DIAGNOSTICS do table.remove(ns.db.diagnostics, 1) end
end

-- Adds a line to the newest diagnostic of that command (e.g. each game alert while watching)
function ns.AddToDiagnostic(command, line)
	if not ns.db then return end
	local list = ns.db.diagnostics
	local last = type(list) == "table" and list[#list]
	if not (last and last.command == command) then
		ns.SaveDiagnostic(command, {})
		last = ns.db.diagnostics[#ns.db.diagnostics]
	end
	last.lines[#last.lines + 1] = (date and date("%H:%M:%S ") or "") .. tostring(line)
	while #last.lines > 200 do table.remove(last.lines, 1) end
end
