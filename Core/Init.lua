-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The namespace shared by every file, the version, and a small event bus: any file can listen to a game
-- event without creating its own frame, and several files can listen to the same event.

local addonName, ns = ...

ns.NAME = addonName
ns.TITLE = "|cffffe00aKyoryokuna|r |cff2ecc71Enhancements|r"
ns.SHORT_TITLE = "Kyoryokuna Enhancements"
ns.AUTHOR = "Pragas"
ns.COPYRIGHT = "Copyright (c) 2026 Pragas. All Rights Reserved."
-- The addon's emblem: a KE monogram (white K, E in the green of "Enhancements") over a green bar, on a
-- deep navy rounded square with a soft white outline, like the other Kyoryokuna addons. Made in the sizes
-- it's shown at (64 for the About page, 32 for the game's addon list), so the game never shrinks it.
ns.ICON = "Interface\\AddOns\\" .. addonName .. "\\Media\\Icon"
ns.ICON_SMALL = "Interface\\AddOns\\" .. addonName .. "\\Media\\IconSmall"

local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
ns.VERSION = (GetMetadata and GetMetadata(addonName, "Version")) or "?"

local _, _, _, interfaceVersion = GetBuildInfo()
ns.INTERFACE = interfaceVersion

-- Event bus ----------------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local listeners = {}

-- Each listener runs protected, so an error in one doesn't stop the others (see Errors.lua)
eventFrame:SetScript("OnEvent", function(_, event, ...)
	local list = listeners[event]
	if not list then return end
	for i = 1, #list do
		ns.SafeCall(list[i], event, ...)
	end
end)

function ns.RegisterEvent(event, func)
	local list = listeners[event]
	if not list then
		list = {}
		listeners[event] = list
		eventFrame:RegisterEvent(event)
	end
	list[#list + 1] = func
end

-- Until Errors.lua loads, a call is just a call
function ns.SafeCall(func, ...)
	return func(...)
end

function ns.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage(ns.TITLE .. ": " .. tostring(text))
end
