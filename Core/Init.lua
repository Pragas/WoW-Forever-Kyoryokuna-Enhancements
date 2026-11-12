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

-- The version of this code (the tests check it's the TOC's). The game reads the TOC (the list of the
-- addon's files, and its version) only when it starts: after an update, a /reload runs the new code of the
-- files it already knew, but leaves out the new ones. So when the version the game read isn't this one, the
-- addon stays off (no events, no calls: see the event bus and Errors.lua) and asks for the game to be
-- restarted, instead of running with files missing and breaking.
ns.VERSION = "0.16.0"
local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local loadedVersion = GetMetadata and GetMetadata(addonName, "Version")
ns.NEEDS_RESTART = type(loadedVersion) == "string" and loadedVersion ~= ns.VERSION

local _, _, _, interfaceVersion = GetBuildInfo()
ns.INTERFACE = interfaceVersion

-- Event bus ----------------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local listeners = {}

-- Each listener runs protected, so an error in one doesn't stop the others (see Errors.lua)
eventFrame:SetScript("OnEvent", function(_, event, ...)
	if ns.NEEDS_RESTART then return end
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

-- Updated, but the game still has the old list of files: a message in the chat and a window, in the
-- player's language (read straight from the saved settings, which the addon doesn't load while it's off)
local RESTART_POPUP = "KYORYOKUNAENHANCEMENTS_RESTART"

function ns.ShowRestartNotice()
	local text = string.format(ns.L["%s was updated to version %s. Close the game and open it again to use it: a /reload isn't enough, because the game only reads the addon's new files when it starts. Until then the addon is turned off."],
		ns.SHORT_TITLE, ns.VERSION)
	ns.Print(text)
	if StaticPopupDialogs and StaticPopup_Show then
		StaticPopupDialogs[RESTART_POPUP] = {
			text = ns.TITLE .. "\n\n" .. text,
			button1 = OKAY or "OK",
			timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
		}
		StaticPopup_Show(RESTART_POPUP)
	end
end

if ns.NEEDS_RESTART then
	local notice = CreateFrame("Frame")
	notice:RegisterEvent("ADDON_LOADED")
	notice:RegisterEvent("PLAYER_ENTERING_WORLD")
	notice:SetScript("OnEvent", function(self, event, loadedName)
		if event == "ADDON_LOADED" and loadedName == addonName then
			local saved = _G[addonName .. "DB"]
			local language = type(saved) == "table" and type(saved.general) == "table" and saved.general.language
			if ns.LOCALES and ns.LOCALES[language] then ns.language = language end
		elseif event == "PLAYER_ENTERING_WORLD" then
			-- Once, a few seconds after the world shows: what's written while the game is still making its
			-- interface (at login or after a /reload) is lost
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			if C_Timer and C_Timer.After then C_Timer.After(5, ns.ShowRestartNotice) else ns.ShowRestartNotice() end
		end
	end)
end
