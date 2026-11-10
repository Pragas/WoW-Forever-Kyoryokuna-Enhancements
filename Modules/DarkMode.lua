-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Dark mode: the art of the game's interface (frames, borders, bar decorations) loses its color and is
-- darkened, by an amount the player chooses, zone by zone (General page):
--   - unit frames (player, target, focus, pet, party, bosses), action bars (buttons, end caps, bags and
--     menu, experience bar), cast bars, minimap (its ring, buttons and the rings of addon buttons),
--     tooltips (their border and background), the headers of the objectives, the personal resource
--     display (its bars' borders and the class points), the bags (window and slot borders), the game
--     menu (Escape), party and raid frames.
-- How: each piece is desaturated and given a grey (its brightness). The game sometimes paints a piece
-- again (a new target, a new group member...): the addon follows what the game asks for and darkens the
-- piece again right away. Turned off (or a zone turned off), each piece gets back exactly the color and
-- look the game last asked for, not a plain white.
-- Only textures are changed, which the game allows in combat too; protected frames are left alone.

local _, ns = ...

local DarkMode = {}
ns.DarkMode = DarkMode

-- What's darkened now: region -> its brightness (0 black ... 1 the game's own)
local painted = setmetatable({}, {__mode = "k"})

-- "PlayerFrame.PlayerFrameContainer.FrameTexture" -> that region, or nil
local function Resolve(path)
	local object = _G
	for key in path:gmatch("[^.]+") do
		if type(object) ~= "table" then return nil end
		object = object[key]
	end
	return object
end

local function IsUsable(region)
	if type(region) ~= "table" or type(region.SetVertexColor) ~= "function" then return false end
	if region.IsForbidden then
		local ok, forbidden = pcall(region.IsForbidden, region)
		if not ok or forbidden then return false end
	end
	return true
end

-- Paints a region: darkened while it's in the list, else the game's own color and look
local function Paint(region)
	local value = painted[region]
	region.kePainting = true
	pcall(function()
		local game = region.keGameColor or {1, 1, 1, 1}
		if value then
			if region.SetDesaturated then region:SetDesaturated(true) end
			region:SetVertexColor(value, value, value, game[4])
		else
			if region.SetDesaturated then region:SetDesaturated(region.keGameDesaturated or false) end
			region:SetVertexColor(game[1], game[2], game[3], game[4])
		end
	end)
	region.kePainting = nil
end

-- The first time: what the game has now, and a watch on what it asks for from then on
local function Watch(region)
	if region.keWatched then return end
	region.keWatched = true
	local ok, r, g, b, a = pcall(region.GetVertexColor, region)
	r, g, b, a = ns.Known(r), ns.Known(g), ns.Known(b), ns.Known(a)
	if ok and type(r) == "number" then region.keGameColor = {r, g, b, a or 1} end
	if region.IsDesaturated then
		local okDesat, desaturated = pcall(region.IsDesaturated, region)
		region.keGameDesaturated = okDesat and ns.Known(desaturated) or false
	end
	hooksecurefunc(region, "SetVertexColor", function(self, r2, g2, b2, a2)
		if self.kePainting then return end
		self.keGameColor = {ns.Known(r2) or 1, ns.Known(g2) or 1, ns.Known(b2) or 1, ns.Known(a2) or 1}
		if painted[self] then Paint(self) end
	end)
	if region.SetDesaturated then
		hooksecurefunc(region, "SetDesaturated", function(self, desaturated)
			if self.kePainting then return end
			self.keGameDesaturated = ns.Known(desaturated) and true or false
			if painted[self] then Paint(self) end
		end)
	end
end

-- Zones ---------------------------------------------------------------------------------------------
-- Each zone lists its pieces, each with how much lighter than the chosen darkness it stays (so e.g. the
-- end caps of the action bar keep their shape). A piece is a region or the path to one.

local function Regions(frame, add, lighter)
	if type(frame) ~= "table" or not frame.GetRegions then return end
	for _, region in ipairs({frame:GetRegions()}) do
		if region.IsObjectType and region:IsObjectType("Texture") then add(region, lighter) end
	end
end

local ACTION_BUTTONS = {
	"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
	"MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "PetActionButton", "StanceButton",
}
local MICRO_BUTTONS = {
	"CharacterMicroButton", "ProfessionMicroButton", "SpellbookMicroButton", "TalentMicroButton", "QuestLogMicroButton",
	"GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "HelpMicroButton", "StoreMicroButton", "MainMenuMicroButton",
}
local TOOLTIPS = {
	"GameTooltip", "ShoppingTooltip1", "ShoppingTooltip2", "ItemRefTooltip", "ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2", "EmbeddedItemTooltip",
}
local OBJECTIVE_HEADERS = {
	"ObjectiveTrackerFrame", "QuestObjectiveTracker", "CampaignQuestObjectiveTracker", "WorldQuestObjectiveTracker",
	"BonusObjectiveTracker", "AchievementObjectiveTracker", "ScenarioObjectiveTracker", "ProfessionsRecipeTracker",
	"MonthlyActivitiesObjectiveTracker", "AdventureObjectiveTracker", "UIWidgetObjectiveTracker",
}
local GROUP_BORDERS = {"horizTopBorder", "horizBottomBorder", "vertLeftBorder", "vertRightBorder", "horizDivider"}

-- The art of one of the game's windows (bags, the game menu...): the pieces of its frame and its
-- header, and its background. Windows are built from the same few pieces, whatever their names inside:
-- each one found is darkened, any missing is skipped.
local WINDOW_ART = {"NineSlice", "Border", "Header"}
local WINDOW_BACKGROUND = {"Bg", "Background"}

local function WindowArt(frame, add, lighter)
	if type(frame) ~= "table" then return end
	for _, key in ipairs(WINDOW_ART) do
		local piece = frame[key]
		if type(piece) == "table" then
			if piece.IsObjectType and piece:IsObjectType("Texture") then
				add(piece, lighter)
			else
				Regions(piece, add, lighter)
				if piece.GetChildren then
					for _, child in ipairs({piece:GetChildren()}) do Regions(child, add, lighter) end
				end
			end
		end
	end
	for _, key in ipairs(WINDOW_BACKGROUND) do
		local piece = frame[key]
		if type(piece) == "table" and piece.IsObjectType and piece:IsObjectType("Texture") then add(piece, lighter) end
	end
end

-- The personal resource display (the bars and class points under the character): the border of each
-- bar is the texture with this art; the class points (combo points, runes, chi, essence, holy power...)
-- each have a background under these names, darkened a little lighter so the points still show
local RESOURCE_BAR_BORDER = "UI-HUD-CoolDownManager-Bar-BG"
local RESOURCE_POINT_BACKGROUNDS = {
	BG_Active = 0.1, BG_Inactive = 0.2, BGActive = 0.1, BGInactive = 0.2, Background = 0.1, ActiveTexture = 0.1,
	ChargedFrameActive = 0.1, ArcaneBG = 0.15, Chi_BG = 0.1, Chi_BG_Active = 0.1,
	CircBG = 0.1, CircBGActive = 0, EssenceBG = 0, RimGlow = 0.1,
}

local function ResourcePoints(frame, add, depth)
	if type(frame) ~= "table" or depth > 3 then return end
	for key, lighter in pairs(RESOURCE_POINT_BACKGROUNDS) do
		local piece = frame[key]
		if type(piece) == "table" and piece.IsObjectType and piece:IsObjectType("Texture") then add(piece, lighter) end
	end
	-- Evoker essences keep their backgrounds one level down (filling, full, empty...)
	for _, key in ipairs({"EssenceFillDone", "EssenceFilling", "EssenceEmpty", "EssenceDepleting"}) do
		ResourcePoints(frame[key], add, depth + 1)
	end
	if frame.GetChildren then
		for _, child in ipairs({frame:GetChildren()}) do ResourcePoints(child, add, depth + 1) end
	end
end

local function ResourceBarBorder(bar, add)
	if type(bar) ~= "table" or not bar.GetRegions then return end
	for _, region in ipairs({bar:GetRegions()}) do
		if region.IsObjectType and region:IsObjectType("Texture") then
			local ok, atlas = pcall(region.GetAtlas, region)
			if region.blizzBgBorderTexture or (ok and ns.Known(atlas) == RESOURCE_BAR_BORDER) then add(region, 0) end
		end
	end
end

-- The bag windows (each bag apart, or all in one)
local function BagFrames()
	local frames = {_G.ContainerFrameCombinedBags}
	for i = 1, 13 do frames[#frames + 1] = _G["ContainerFrame" .. i] end
	return frames
end
-- The ring of the minimap's buttons (also addon buttons), by its file
local BUTTON_RING = {[136430] = true, ["interface\\minimap\\minimap-trackingborder"] = true}

local ZONES = {
	{key = "unitFrames", collect = function(add)
		for _, path in ipairs({
			"PlayerFrame.PlayerFrameContainer.FrameTexture", "PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture",
			"PlayerFrame.PlayerFrameContainer.VehicleFrameTexture", "TargetFrame.TargetFrameContainer.FrameTexture",
			"FocusFrame.TargetFrameContainer.FrameTexture", "TargetFrame.totFrame.FrameTexture", "FocusFrameToT.FrameTexture",
			"PetFrameTexture", "PlayerFrameGroupIndicatorLeft", "PlayerFrameGroupIndicatorRight", "PlayerFrameGroupIndicatorMiddle",
		}) do add(path, 0) end
		-- The level's circle a little lighter, so the number stays readable
		for _, path in ipairs({
			"PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle",
			"TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle",
			"FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle",
		}) do add(path, 0.15) end
		for i = 1, 4 do
			add("PartyFrame.MemberFrame" .. i .. ".Texture", 0)
			add("PartyFrame.MemberFrame" .. i .. ".PetFrame.Texture", 0)
		end
		for i = 1, 5 do add("Boss" .. i .. "TargetFrame.TargetFrameContainer.FrameTexture", 0) end
	end},
	{key = "actionBars", collect = function(add)
		local bar = _G.MainActionBar or _G.MainMenuBar
		if type(bar) == "table" then
			if bar.GetChildren then
				for _, child in ipairs({bar:GetChildren()}) do
					add(child.TopEdge, 0.15); add(child.BottomEdge, 0.15); add(child.Center, 0.15)
				end
			end
			add(bar.BorderArt, 0.15)
			-- The end caps (gryphons) lighter, so their shape still shows
			if bar.EndCaps then
				add(bar.EndCaps.LeftEndCap and bar.EndCaps.LeftEndCap.Texture, 0.25)
				add(bar.EndCaps.RightEndCap and bar.EndCaps.RightEndCap.Texture, 0.25)
			end
		end
		for _, prefix in ipairs(ACTION_BUTTONS) do
			for i = 1, 12 do
				local button = _G[prefix .. i]
				add(_G[prefix .. i .. "NormalTexture"] or (button and button.GetNormalTexture and button:GetNormalTexture()), 0.15)
				if prefix == "ActionButton" and button then add(button.RightDivider, 0.15) end
			end
		end
		add("StatusTrackingBarManager.MainStatusTrackingBarContainer.BarFrameTexture", 0.15)
		add("StatusTrackingBarManager.SecondaryStatusTrackingBarContainer.BarFrameTexture", 0.15)
		add("MicroMenu.BorderArt", 0.15)
		for _, name in ipairs(MICRO_BUTTONS) do
			local button = _G[name]
			if type(button) == "table" then add(button.Background, 0.15); add(button.PushedBackground, 0.15) end
		end
		add("BagsBar.BorderArt", 0.15)
		for _, name in ipairs({"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot",
			"CharacterBag3Slot", "CharacterReagentBag0Slot", "KeyRingButton"}) do
			local button = _G[name]
			if type(button) == "table" and button.GetNormalTexture then add(button:GetNormalTexture(), 0.15) end
		end
	end},
	{key = "castBars", collect = function(add)
		local bars = {_G.PlayerCastingBarFrame, Resolve("TargetFrame.spellbar"), Resolve("FocusFrame.spellbar"), _G.PetSpellBar}
		for i = 1, 5 do bars[#bars + 1] = Resolve("Boss" .. i .. "TargetFrame.spellbar") end
		for _, castBar in pairs(bars) do
			if type(castBar) == "table" then
				add(castBar.Border, 0.1); add(castBar.TextBorder, 0.1); add(castBar.Background, 0.3)
			end
		end
	end},
	{key = "minimap", collect = function(add)
		add("MinimapCompassTexture", 0)
		add("MinimapCluster.BorderTop", 0)
		local minimap = Resolve("MinimapCluster.MinimapContainer.Minimap") or _G.Minimap
		if type(minimap) == "table" then
			Regions(minimap.ZoomIn, add, 0); Regions(minimap.ZoomOut, add, 0)
		end
		-- The rings around the minimap's buttons, the game's and the addons'
		if _G.Minimap and _G.Minimap.GetChildren then
			local function Rings(frame, depth)
				if depth > 2 or not frame.GetRegions then return end
				for _, region in ipairs({frame:GetRegions()}) do
					if region.IsObjectType and region:IsObjectType("Texture") then
						local ok, file = pcall(region.GetTexture, region)
						file = ok and ns.Known(file)
						if file and BUTTON_RING[type(file) == "string" and file:lower() or file] then add(region, 0) end
					end
				end
				if frame.GetChildren then
					for _, child in ipairs({frame:GetChildren()}) do Rings(child, depth + 1) end
				end
			end
			Rings(_G.Minimap, 0)
		end
	end},
	{key = "tooltips", collect = function(add)
		for _, name in ipairs(TOOLTIPS) do
			local tip = _G[name]
			local nineSlice = type(tip) == "table" and tip.NineSlice
			if type(nineSlice) == "table" then
				for key, region in pairs(nineSlice) do
					-- The border darkened, the background almost black
					if type(region) == "table" and region.SetVertexColor then add(region, key == "Center" and -1 or 0) end
				end
			end
		end
	end},
	{key = "objectives", collect = function(add)
		for _, name in ipairs(OBJECTIVE_HEADERS) do add(name .. ".Header.Background", 0) end
	end},
	{key = "personalResource", collect = function(add)
		local display = _G.PersonalResourceDisplayFrame
		if type(display) ~= "table" then return end
		local healthBars = display.HealthBarsContainer
		ResourceBarBorder(healthBars and healthBars.healthBar, add)
		ResourceBarBorder(display.PowerBar, add)
		ResourceBarBorder(display.AlternatePowerBar, add)
		ResourcePoints(display.classFrame, add, 0)
	end},
	{key = "bags", collect = function(add)
		for _, frame in pairs(BagFrames()) do
			WindowArt(frame, add, 0)
			-- The border of each slot, a little lighter (the items' icons are left alone)
			if type(frame) == "table" and type(frame.Items) == "table" then
				for _, item in pairs(frame.Items) do
					if type(item) == "table" and item.GetNormalTexture then add(item:GetNormalTexture(), 0.15) end
				end
			end
		end
	end},
	{key = "gameMenu", collect = function(add)
		WindowArt(_G.GameMenuFrame, add, 0)
	end},
	{key = "groupFrames", collect = function(add)
		Regions(_G.CompactPartyFrameBorderFrame, add, 0)
		Regions(_G.CompactRaidFrameContainerBorderFrame, add, 0)
		local function Borders(frame)
			if type(frame) ~= "table" then return end
			for _, key in ipairs(GROUP_BORDERS) do add(frame[key], 0) end
		end
		for i = 1, 5 do Borders(_G["CompactPartyFrameMember" .. i]) end
		for i = 1, 40 do Borders(_G["CompactRaidFrame" .. i]) end
		for group = 1, 8 do
			Regions(_G["CompactRaidGroup" .. group .. "BorderFrame"], add, 0)
			for member = 1, 5 do Borders(_G["CompactRaidGroup" .. group .. "Member" .. member]) end
		end
	end},
}
DarkMode.ZONES = ZONES

-- Applying -------------------------------------------------------------------------------------------

-- Every piece of every zone turned on gets the chosen darkness; the others go back to the game's own
function DarkMode.Apply()
	if not ns.db then return end
	local settings = ns.db.darkMode
	local base = 1 - settings.darkness / 100
	local wanted = {}
	if settings.enabled then
		local function add(piece, lighter)
			local region = type(piece) == "string" and Resolve(piece) or piece
			if IsUsable(region) then
				wanted[region] = math.max(0, math.min(1, base + (lighter or 0)))
			end
		end
		for _, zone in ipairs(ZONES) do
			if settings[zone.key] then ns.SafeCall(zone.collect, add) end
		end
	end
	-- Back to the game's own: what's no longer wanted
	for region in pairs(painted) do
		if wanted[region] == nil then
			painted[region] = nil
			Paint(region)
		end
	end
	for region, value in pairs(wanted) do
		Watch(region)
		if painted[region] ~= value then
			painted[region] = value
			Paint(region)
		end
	end
end

-- How many pieces are darkened now (for the tests and the diagnostics)
function DarkMode.CountPainted()
	local count = 0
	for _ in pairs(painted) do count = count + 1 end
	return count
end

-- /ke darkscan: how many pieces each part finds in the game now, whether it's on or not, so a part
-- that doesn't darken in the game can be told apart from one whose pieces have other names
function DarkMode.Scan()
	local counts = {}
	for _, zone in ipairs(ZONES) do
		local found = 0
		local function add(piece)
			local region = type(piece) == "string" and Resolve(piece) or piece
			if IsUsable(region) then found = found + 1 end
		end
		ns.SafeCall(zone.collect, add)
		counts[#counts + 1] = {key = zone.key, found = found}
	end
	return counts
end

-- The game makes some pieces later (a target, a group member, a tooltip shown for the first time...):
-- they're looked for again when that happens
local REAPPLY_EVENTS = {
	"PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "GROUP_ROSTER_UPDATE", "UNIT_PET",
	"UPDATE_BONUS_ACTIONBAR", "UPDATE_SHAPESHIFT_FORMS", "UPDATE_SHAPESHIFT_FORM", "PLAYER_REGEN_ENABLED",
	"PLAYER_SPECIALIZATION_CHANGED",
}
for _, event in ipairs(REAPPLY_EVENTS) do
	ns.RegisterEvent(event, function()
		if ns.db and (ns.db.darkMode.enabled or next(painted)) then DarkMode.Apply() end
	end)
end

-- The personal resource display comes with the player's own nameplate, and its power bar changes with
-- the kind of power (a druid's forms)
ns.RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit)
	if ns.db and ns.db.darkMode.enabled and unit and ns.Known(UnitIsUnit(unit, "player")) then DarkMode.Apply() end
end)
ns.RegisterEvent("UNIT_DISPLAYPOWER", function(_, unit)
	if ns.db and ns.db.darkMode.enabled and unit == "player" then DarkMode.Apply() end
end)

-- Some windows build their art the first time they're shown (a tooltip, the bags, the game menu): each
-- is looked at again when it shows. The bags and the game menu every time, as their slots and buttons
-- can change.
ns.RegisterEvent("PLAYER_LOGIN", function()
	local tip = _G.GameTooltip
	if tip and tip.HookScript then
		local looked = false
		tip:HookScript("OnShow", function()
			if looked or not (ns.db and ns.db.darkMode.enabled) then return end
			looked = true
			DarkMode.Apply()
		end)
	end
	local windows = BagFrames()
	windows[#windows + 1] = _G.GameMenuFrame
	for _, frame in pairs(windows) do
		if type(frame) == "table" and frame.HookScript then
			frame:HookScript("OnShow", function()
				if ns.db and ns.db.darkMode.enabled then DarkMode.Apply() end
			end)
		end
	end
	DarkMode.Apply()
end)
