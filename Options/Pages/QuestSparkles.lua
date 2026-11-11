-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Quest item sparkles (Modules\QuestSparkles.lua).

local _, ns = ...

local GREY = {0.7, 0.7, 0.7}

ns.AddOptionsPage("Quest Sparkles", function(b)
	b:Header("Quest item sparkles")
	b:Text("Quest items you can loot sparkle, so they're easy to spot: on the ground, on objects and on creatures. It's a setting of the game that its graphics presets turn off: the addon keeps it on, at login and after any change of the graphics.", GREY)
	b:Check("questSparkles.enabled", "Make quest items sparkle",
		"Turning this off takes effect after restarting the game (a /reload isn't enough).")
end)
