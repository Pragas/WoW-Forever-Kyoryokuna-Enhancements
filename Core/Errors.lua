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
