-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Dark Mode", function(b)
	b:Header("Dark mode")
	b:Text("Darkens the art of the game's interface: frames, borders and bar decorations. Turned off, everything gets its own colors back.",
		{0.7, 0.7, 0.7})
	local on = W.IsOn("darkMode.enabled")
	b:Check("darkMode.enabled", "Dark mode")
	b:Slider("darkMode.darkness", "Darkness", 1, "%",
		"How dark the art gets, from barely darker (5%) to black (100%). Changes show at once, while you drag. The end caps of the action bar, the buttons and the level circles stay a little lighter, so their shapes still show.",
		on, true)

	b:Header("Parts")
	b:Check("darkMode.unitFrames", "Unit frames", "Player, target, focus, pet, party and boss frames.", on)
	b:Check("darkMode.actionBars", "Action bars", "The buttons' borders, the bar's decoration, the bags, the menu and the experience bar.", on)
	b:Check("darkMode.castBars", "Cast bars", "The borders of the player's, target's and focus's cast bars.", on)
	b:Check("darkMode.minimap", "Minimap", "Its ring, its buttons and the rings of the addon buttons around it.", on)
	b:Check("darkMode.tooltips", "Tooltips", "Their border, and a darker background.", on)
	b:Check("darkMode.objectives", "Objectives", "The headers of the quest and objective list.", on)
	b:Check("darkMode.personalResource", "Personal resource display",
		"The bars and class points under your character: the borders of the bars and the backgrounds of the points (combo points, runes, chi, essence...).",
		on)
	b:Check("darkMode.bags", "Bags", "The bag windows and the borders of their slots (the items stay as they are).", on)
	b:Check("darkMode.gameMenu", "Game menu", "The menu that opens with Escape.", on)
	b:Check("darkMode.groupFrames", "Party and raid frames", "The borders of the party and raid frames.", on)
end)
