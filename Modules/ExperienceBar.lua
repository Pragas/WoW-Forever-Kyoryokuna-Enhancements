-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The experience bar (and the other bars the game shows there: reputation, honor...) with a texture of
-- the addon instead of the game's (Experience Bar page). Each kind of bar keeps the color the game gives
-- it (experience purple, rested blue, reputation by standing, honor orange). The game sets its own
-- texture again whenever the bar changes: the addon follows what it asks for and puts its texture back;
-- turned off, the game's own texture comes back.

local _, ns = ...

local ExperienceBar = {}
ns.ExperienceBar = ExperienceBar

local TEXTURES = {
	FLAT = "Interface\\Buttons\\WHITE8X8",
	SMOOTH = "Interface\\TargetingFrame\\UI-StatusBar",
	CLASSIC = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill",
	RAID = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
}

-- The color of each kind of bar, by the art the game gives its fill
local COLORS = {
	["UI-HUD-ExperienceBar-Fill-Experience"] = {0.58, 0, 0.55},
	["UI-HUD-ExperienceBar-Fill-Rested"] = {0, 0.39, 0.88},
	["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue"] = {0, 0.39, 0.88},
	["UI-HUD-ExperienceBar-Fill-Honor"] = {1, 0.24, 0},
	["UI-HUD-ExperienceBar-Fill-ArtifactPower"] = {0.9, 0.8, 0.6},
}
-- Reputation by standing: the game's own colors
local STANDING = {
	["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red"] = 2,
	["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Orange"] = 3,
	["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Yellow"] = 4,
	["UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green"] = 5,
}

local function ColorOf(asset)
	if type(asset) ~= "string" then return nil end
	local standing = STANDING[asset]
	if standing and FACTION_BAR_COLORS and FACTION_BAR_COLORS[standing] then
		local color = FACTION_BAR_COLORS[standing]
		return color.r, color.g, color.b
	end
	local color = COLORS[asset]
	if color then return color[1], color[2], color[3] end
end

local bars = setmetatable({}, {__mode = "k"})

local function Paint(bar)
	local settings = ns.db and ns.db.experienceBar
	local game = bars[bar]
	if not game then return end
	bar.keSetting = true
	pcall(function()
		if settings and settings.enabled then
			bar:SetStatusBarTexture(TEXTURES[settings.texture] or TEXTURES.SMOOTH)
			-- The kind of bar's color; a bar of another kind keeps the game's color
			local r, g, b = ColorOf(game.asset)
			if r then bar:SetStatusBarColor(r, g, b) end
		elseif game.asset then
			bar:SetStatusBarTexture(game.asset)
			if game.color then bar:SetStatusBarColor(unpack(game.color)) end
		end
	end)
	bar.keSetting = nil
end

-- The first time: what the game has now, and a watch on what it asks for from then on
local function Watch(bar)
	if bars[bar] or type(bar) ~= "table" or not bar.SetStatusBarTexture then return end
	local game = {}
	local fill = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
	if fill then
		local okAtlas, atlas = pcall(fill.GetAtlas, fill)
		local okFile, file = pcall(fill.GetTexture, fill)
		game.asset = (okAtlas and ns.Known(atlas)) or (okFile and ns.Known(file)) or nil
	end
	if bar.GetStatusBarColor then
		local r, g, b = bar:GetStatusBarColor()
		if ns.Known(r) then game.color = {r, g, b} end
	end
	bars[bar] = game
	hooksecurefunc(bar, "SetStatusBarTexture", function(self, asset)
		if self.keSetting then return end
		bars[self].asset = ns.Known(asset) or bars[self].asset
		if ns.db and ns.db.experienceBar.enabled then Paint(self) end
	end)
	hooksecurefunc(bar, "SetStatusBarColor", function(self, r, g, b)
		if self.keSetting then return end
		if ns.Known(r) then bars[self].color = {r, g, b} end
		if ns.db and ns.db.experienceBar.enabled and ColorOf(bars[self].asset) then Paint(self) end
	end)
end

-- Every bar the game shows there (the modern bar manager, and the classic bars when they exist)
local function ForEachBar(func)
	local manager = _G.StatusTrackingBarManager
	if type(manager) == "table" and type(manager.barContainers) == "table" then
		for _, container in ipairs(manager.barContainers) do
			if type(container.bars) == "table" then
				for _, bar in pairs(container.bars) do
					if type(bar) == "table" and bar.StatusBar then func(bar.StatusBar) end
				end
			end
		end
	end
	if _G.MainMenuExpBar then func(_G.MainMenuExpBar) end
	if _G.ReputationWatchBar and _G.ReputationWatchBar.StatusBar then func(_G.ReputationWatchBar.StatusBar) end
end

function ExperienceBar.Apply()
	if not ns.db then return end
	ForEachBar(function(bar)
		if ns.db.experienceBar.enabled then Watch(bar) end
		if bars[bar] then Paint(bar) end
	end)
end

for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UPDATE_FACTION", "PLAYER_LEVEL_UP", "UPDATE_EXHAUSTION"}) do
	ns.RegisterEvent(event, function() ExperienceBar.Apply() end)
end
