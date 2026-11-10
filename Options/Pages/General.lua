-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...

ns.AddOptionsPage("General", function(b)
	b:Header("Language")
	b:Dropdown("general.language", "Language", ns.LANGUAGES, "The language of the addon's texts.")

	b:Header("Minimap")
	b:Check("general.minimapIcon", "Show the minimap button",
		"A click on it opens the options. Drag it to move it around the minimap.")
end)
