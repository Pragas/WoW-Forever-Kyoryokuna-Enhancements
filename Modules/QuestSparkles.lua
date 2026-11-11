-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Quest sparkles: quest items that can be looted sparkle in the world. It's a setting of the game
-- (outlineModeShowLootEffectWhenDisabled) that its graphics presets turn off, so the addon turns it on at
-- login, again a few seconds later (settings synced with the account can arrive late), and after any
-- change of the graphics quality or of the setting itself. Not in combat: then once the fight ends.
--
-- Turned off, the setting goes back off (only if the addon had turned it on: kept in the saved data). The
-- sparkles already shown stay until the game is restarted: the chat says so.

local _, ns = ...
local L = ns.L

local QuestSparkles = {}
ns.QuestSparkles = QuestSparkles

local CVAR = "outlineModeShowLootEffectWhenDisabled"
-- The game's settings whose change may turn it off (lower case, as compared)
local WATCHED = {graphicsquality = true, raidgraphicsquality = true, [CVAR:lower()] = true}

-- In combat: turned on when the fight ends
local pending = false
-- The addon's own change, not to be answered
local applying = false
-- Whether the sparkles were on at some point since the game started (they stay until a restart)
local shownThisSession = false

local function Settings()
	return ns.db.questSparkles
end

local function SetValue(value)
	if not (C_CVar and C_CVar.SetCVar) then return end
	applying = true
	pcall(C_CVar.SetCVar, CVAR, value)
	applying = false
end

function QuestSparkles.Apply()
	if not ns.db then return end
	if Settings().enabled then
		if InCombatLockdown() then
			pending = true
			return
		end
		pending = false
		local current = C_CVar and C_CVar.GetCVar and C_CVar.GetCVar(CVAR)
		if current ~= "1" then SetValue("1") end
		ns.db.questSparklesSet = true
		shownThisSession = true
	elseif ns.db.questSparklesSet then
		pending = false
		SetValue("0")
		ns.db.questSparklesSet = nil
		if shownThisSession then
			shownThisSession = false
			ns.Print(L["Quest item sparkles: restart the game to remove the ones already shown (a /reload isn't enough)."])
		end
	end
end

local function After(seconds, func)
	if C_Timer and C_Timer.After then
		C_Timer.After(seconds, function() ns.SafeCall(func) end)
	else
		func()
	end
end

-- A setting of the game changed: if it's one that can turn the sparkles off, they're turned on again
function QuestSparkles.OnSettingChanged(name)
	if applying or not (ns.db and Settings().enabled) or type(name) ~= "string" then return end
	if WATCHED[name:lower()] then After(1, QuestSparkles.Apply) end
end

ns.RegisterEvent("PLAYER_LOGIN", function()
	QuestSparkles.Apply()
	After(5, QuestSparkles.Apply)
end)
ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if pending then QuestSparkles.Apply() end
end)

-- The game's settings: on a frame of its own, as some versions of the game don't have this event
local settingsFrame = CreateFrame("Frame")
pcall(settingsFrame.RegisterEvent, settingsFrame, "CVAR_UPDATE")
settingsFrame:SetScript("OnEvent", function(_, _, name)
	if ns.NEEDS_RESTART then return end
	ns.SafeCall(QuestSparkles.OnSettingChanged, name)
end)
