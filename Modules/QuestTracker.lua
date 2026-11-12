-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Hide the quest tracker (General page): the list of the quests followed, on the right of the screen (the
-- game's ObjectiveTrackerFrame, "All Objectives"), stays hidden while the option is on.
-- It's each character's own (one may hide it, another not), kept with it in characters[...] like its
-- missing buffs and supplies (made by Modules\MissingBuffs.lua at login: this file loads after it, so its
-- login comes after that one).
-- The game shows the list again by itself: its update, at each change of a quest it follows, shows it
-- while there's something in it and hides it when it's empty. So it's hidden again each time it shows.
-- The list sits in the game's column of frames on the right of the screen (RightManagedFrameContainer),
-- with the boss and arena frames, which are protected: hiding or showing the list lays that column out
-- again, which the addon may not do in a fight. Shown by the game in a fight, the list is only made
-- invisible (its alpha) until the fight ends, then hidden.
-- Turned off, the list comes back if the game was showing it (it keeps deciding while the list is hidden);
-- in a fight, when the fight ends.

local _, ns = ...

local QuestTracker = {}
ns.QuestTracker = QuestTracker

-- The addon hid the list: shown again when the option is turned off (left alone otherwise, for other addons)
local hidden = false
-- Made invisible by the addon in a fight: its alpha back once it's hidden
local faded = false
-- What the game last wanted: the list shown (it has something in it) or hidden
local gameShows = false
-- The addon hides or shows the list itself: not the game
local busy = false
-- A fight: done when it ends
local waiting = false

local function Tracker()
	local tracker = _G.ObjectiveTrackerFrame
	if type(tracker) == "table" and tracker.Hide and tracker.HookScript then return tracker end
end

-- The character playing's saved choices (none before login)
local function Character()
	return ns.MissingBuffs and ns.MissingBuffs.GetCharacter and ns.MissingBuffs.GetCharacter()
end

-- Whether this character hides the list
function QuestTracker.IsOn()
	local entry = Character()
	return entry ~= nil and entry.hideQuestTracker == true
end

local Wanted = QuestTracker.IsOn

function QuestTracker.SetOn(on)
	local entry = Character()
	if not entry then return end
	entry.hideQuestTracker = on and true or nil
	QuestTracker.Apply()
	if ns.RefreshOptions then ns.RefreshOptions() end
end

-- Out of a fight only
local function SetShown(tracker, shown)
	busy = true
	if shown then tracker:Show() else tracker:Hide() end
	busy = false
end

function QuestTracker.Apply()
	local tracker = Tracker()
	if not tracker then return end
	local wanted = Wanted()
	if InCombatLockdown() then
		if wanted and tracker:IsShown() then
			tracker:SetAlpha(0)
			faded = true
			waiting = true
		elseif not wanted then
			if faded then
				tracker:SetAlpha(1)
				faded = false
			end
			waiting = hidden
		end
		return
	end
	waiting = false
	if wanted then
		if tracker:IsShown() then SetShown(tracker, false) end
		hidden = true
	elseif hidden then
		hidden = false
		if gameShows and not tracker:IsShown() then SetShown(tracker, true) end
	end
	if faded then
		tracker:SetAlpha(1)
		faded = false
	end
end

local function Hook()
	local tracker = Tracker()
	if not tracker or tracker.keQuestTrackerHooked then return end
	tracker.keQuestTrackerHooked = true
	gameShows = tracker:IsShown() and true or false
	-- The game's own calls (also on a list already shown, or already hidden by the addon)
	hooksecurefunc(tracker, "Show", function()
		if not busy then gameShows = true end
	end)
	hooksecurefunc(tracker, "Hide", function()
		if not busy then gameShows = false end
	end)
	tracker:HookScript("OnShow", function()
		if not busy and Wanted() then QuestTracker.Apply() end
	end)
end

-- The character known: its choice
ns.RegisterEvent("PLAYER_LOGIN", function()
	Hook()
	QuestTracker.Apply()
end)

-- The game's list is normally loaded before the addon; in case it comes later
ns.RegisterEvent("ADDON_LOADED", function(_, loadedName)
	if loadedName ~= "Blizzard_ObjectiveTracker" or not ns.db then return end
	Hook()
	QuestTracker.Apply()
end)

ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if waiting then QuestTracker.Apply() end
end)
