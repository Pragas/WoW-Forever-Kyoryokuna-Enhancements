-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- When a dungeon (dungeon finder) or a battleground is ready, the game's window to enter it gets how
-- long is left to accept (Queue page): the seconds, big, green, then yellow (20 s or less) and red (10 s
-- or less), and a bar under them that empties. The game's own texts stay as they are.
-- How long is left: the game tells it for battlegrounds; a dungeon's offer lasts 40 seconds from when it
-- shows (kept across a /reload or a loading screen).

local _, ns = ...
local L = ns.L

local QueueTimer = {}
ns.QueueTimer = QueueTimer

local DUNGEON_TIME = 40
local BAR_HEIGHT = 4

-- What's being timed now: {dialog, total, ends (GetTime), battleground index}
local current
local ticker

local function ColorFor(left)
	if left > 20 then return 0.2, 1, 0.2 end
	if left > 10 then return 1, 0.85, 0 end
	return 1, 0.2, 0.2
end

-- The addon's texts and bar on a game's window, made the first time
local function GetWidgets(dialog)
	if dialog.keQueue then return dialog.keQueue end
	local widgets = {}
	widgets.label = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	widgets.label:SetPoint("BOTTOM", dialog, "TOP", 0, 34)
	widgets.time = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	widgets.time:SetPoint("TOP", widgets.label, "BOTTOM", 0, -2)
	local path, _, flags = widgets.time:GetFont()
	if path then widgets.time:SetFont(path, 26, "OUTLINE") end
	widgets.bar = CreateFrame("StatusBar", nil, dialog)
	widgets.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	widgets.bar:SetMinMaxValues(0, 1)
	widgets.bar:SetHeight(BAR_HEIGHT)
	widgets.bar:SetPoint("TOPLEFT", dialog, "BOTTOMLEFT", 6, -2)
	widgets.bar:SetPoint("TOPRIGHT", dialog, "BOTTOMRIGHT", -6, -2)
	local background = widgets.bar:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints(widgets.bar)
	background:SetColorTexture(0, 0, 0, 0.6)
	dialog.keQueue = widgets
	return widgets
end

local function HideWidgets(dialog)
	local widgets = type(dialog) == "table" and dialog.keQueue
	if widgets then
		widgets.label:Hide(); widgets.time:Hide(); widgets.bar:Hide()
	end
end

local function Stop()
	if current then HideWidgets(current.dialog) end
	current = nil
	if ticker then ticker:Hide() end
end

-- How long is left now: the game's answer for a battleground, else the time it was given
local function TimeLeft()
	if current.battleground and GetBattlefieldPortExpiration then
		local left = ns.Known(GetBattlefieldPortExpiration(current.battleground))
		if type(left) == "number" then return left end
	end
	return math.max(0, current.ends - GetTime())
end

local function Update()
	if not current then return end
	local dialog = current.dialog
	if not (ns.db and ns.db.queueTimer.enabled) or not (dialog and dialog:IsShown()) then
		Stop()
		return
	end
	local left = TimeLeft()
	local widgets = GetWidgets(dialog)
	local r, g, b = ColorFor(left)
	widgets.label:SetText(L["Expires in"])
	widgets.time:SetText(string.format("%d", math.ceil(left)))
	widgets.time:SetTextColor(r, g, b)
	widgets.label:Show(); widgets.time:Show()
	if ns.db.queueTimer.bar then
		widgets.bar:SetValue(current.total > 0 and math.min(1, left / current.total) or 0)
		widgets.bar:SetStatusBarColor(r, g, b)
		widgets.bar:Show()
	else
		widgets.bar:Hide()
	end
end

local function Start(dialog, total, battleground, ends)
	if type(dialog) ~= "table" or not (ns.db and ns.db.queueTimer.enabled) then return end
	current = {dialog = dialog, total = total, ends = ends or (GetTime() + total), battleground = battleground}
	if not ticker then
		ticker = CreateFrame("Frame")
		ticker.wait = 0
		ticker:SetScript("OnUpdate", function(self, elapsed)
			self.wait = self.wait - elapsed
			if self.wait > 0 then return end
			self.wait = 0.1
			ns.SafeCall(Update)
		end)
	end
	ticker.wait = 0
	ticker:Show()
	Update()
end
QueueTimer.Start = Start

-- A dungeon is ready: 40 seconds from when it showed (also after a /reload: the time it showed is kept)
local function OnDungeonReady()
	if not GetLFGProposal then return end
	local exists, _, _, _, _, _, _, responded = GetLFGProposal()
	if not exists or responded then return end
	local now = GetTime()
	local shown = ns.db.queuePopTime
	if type(shown) ~= "number" or now - shown > DUNGEON_TIME or now < shown then
		shown = now
		ns.db.queuePopTime = now
	end
	Start(_G.LFGDungeonReadyDialog, DUNGEON_TIME, nil, shown + DUNGEON_TIME)
end

-- A battleground is ready: the game tells how long is left
local function OnBattlegroundStatus()
	if not (GetMaxBattlefieldID and GetBattlefieldStatus) then return end
	for i = 1, GetMaxBattlefieldID() do
		if GetBattlefieldStatus(i) == "confirm" then
			local left = ns.Known(GetBattlefieldPortExpiration and GetBattlefieldPortExpiration(i))
			if not (current and current.battleground == i) then
				Start(_G.PVPReadyDialog, type(left) == "number" and left or 90, i)
			end
			return
		end
	end
	if current and current.battleground then Stop() end
end

ns.RegisterEvent("LFG_PROPOSAL_SHOW", function() OnDungeonReady() end)
for _, event in ipairs({"LFG_PROPOSAL_SUCCEEDED", "LFG_PROPOSAL_FAILED", "LFG_PROPOSAL_DONE"}) do
	ns.RegisterEvent(event, function()
		if ns.db then ns.db.queuePopTime = nil end
		if current and not current.battleground then Stop() end
	end)
end
ns.RegisterEvent("UPDATE_BATTLEFIELD_STATUS", function() OnBattlegroundStatus() end)
-- After a /reload or a loading screen, with a dungeon or a battleground still waiting
ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
	OnDungeonReady()
	OnBattlegroundStatus()
end)

-- A change of the options: the timer shows or hides at once (turned on again with a window still open,
-- it comes back)
function QueueTimer.Refresh()
	if current then
		Update()
	elseif ns.db and ns.db.queueTimer.enabled then
		OnDungeonReady()
		OnBattlegroundStatus()
	end
end

-- For the tests
function QueueTimer.Current()
	return current
end
