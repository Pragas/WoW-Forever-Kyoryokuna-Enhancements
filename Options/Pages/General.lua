-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("General", function(b)
	b:Header("Language")
	b:Dropdown("general.language", "Language", ns.LANGUAGES, "The language of the addon's texts.")

	b:Header("Minimap")
	b:Check("general.minimapIcon", "Show the minimap button",
		"A click on it opens the options. Drag it to move it around the minimap.")

	-- Modules\GameMenu.lua
	b:Header("Game menu")
	b:Check("general.smallGameMenu", "Smaller game menu",
		"The menu that opens with Escape is much bigger than it used to be: shown at the size below, a little higher on the screen. Turned off, it gets the game's own size back.")
	b:Slider("general.gameMenuSize", "Size", 5, "%",
		"Next to the game's own menu (100%). Press Escape to see it.", W.IsOn("general.smallGameMenu"))
end)
