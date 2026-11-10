-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Queue", function(b)
	b:Header("Time left to accept")
	b:Text("When a battleground is ready, the game's window to enter it shows how long is left to accept: green, then yellow from 20 seconds, red from 10.",
		{0.7, 0.7, 0.7})
	b:Check("queueTimer.enabled", "Show the time left")
	b:Check("queueTimer.bar", "With a bar that empties", "Under the game's window.", W.IsOn("queueTimer.enabled"), true)
end)
