-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Experience Bar", function(b)
	b:Header("Texture")
	b:Text("A cleaner look for the experience bar and the other bars the game shows there (reputation, honor). Each keeps its own color.",
		{0.7, 0.7, 0.7})
	b:Check("experienceBar.enabled", "Use the addon's texture")
	b:Dropdown("experienceBar.texture", "Texture", {
		{value = "SMOOTH", text = "Smooth"},
		{value = "FLAT", text = "Flat"},
		{value = "CLASSIC", text = "Classic"},
		{value = "RAID", text = "Raid"},
	}, "Smooth: a soft shine. Flat: one plain color. Classic: the glossy bars of old. Raid: like the raid frames.",
		W.IsOn("experienceBar.enabled"), true)
end)
