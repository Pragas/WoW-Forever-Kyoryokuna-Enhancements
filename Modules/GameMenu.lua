-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- A smaller game menu (General page): the menu that opens with Escape is much bigger in WoW Forever
-- than it used to be. Turned on, it's shown at the size chosen (% of the game's own), a little higher,
-- so its top stays about where the game's own menu starts (at 75%: 65 points up in the menu's units).
-- Turned off, the game's own size and place come back.
-- The game never places the menu nor changes its size again after loading (a "center" window that skips
-- the placing: centerFrameSkipAnchoring, and no checkFit), so it's set when the game starts, at each
-- change, and again each time the menu shows, in case something else changed it.

local _, ns = ...

local GameMenu = {}
ns.GameMenu = GameMenu

-- How far up the menu goes for each 1% it's made smaller, in the screen's units
local RISE = 1.95

-- The addon changed the menu: turning the option off puts the game's own size and place back (left alone
-- otherwise, for other addons)
local changed = false
-- In a fight, with the menu protected: done when the fight ends
local waiting = false

function GameMenu.Apply()
	local menu = _G.GameMenuFrame
	if type(menu) ~= "table" or not menu.SetScale then return end
	local settings = ns.db and ns.db.general
	local wanted = settings and settings.smallGameMenu
	if not wanted and not changed then return end
	if InCombatLockdown() and menu.IsProtected and menu:IsProtected() then
		waiting = true
		return
	end
	waiting = false
	menu:ClearAllPoints()
	if wanted then
		local scale = settings.gameMenuSize / 100
		menu:SetScale(scale)
		-- An anchor's offset counts in the menu's own (scaled) units
		menu:SetPoint("CENTER", UIParent, "CENTER", 0, RISE * (100 - settings.gameMenuSize) / scale)
		changed = true
	else
		menu:SetScale(1)
		menu:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		changed = false
	end
end

ns.RegisterEvent("PLAYER_LOGIN", function()
	local menu = _G.GameMenuFrame
	if type(menu) == "table" and menu.HookScript and not menu.keGameMenuHooked then
		menu.keGameMenuHooked = true
		menu:HookScript("OnShow", function()
			if ns.db and ns.db.general.smallGameMenu then GameMenu.Apply() end
		end)
	end
	GameMenu.Apply()
end)

ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if waiting then GameMenu.Apply() end
end)
