-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- FPS and latency (Modules\Performance.lua): what's shown, its place and its look.

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}

local SHOW = {
	{value = "BOTH", text = "FPS and latency"},
	{value = "FPS", text = "FPS only"},
	{value = "PING", text = "Latency only"},
}

local PING = {
	{value = "WORLD", text = "World"},
	{value = "HOME", text = "Home"},
	{value = "BOTH", text = "Home and world"},
}

ns.AddOptionsPage("FPS and Latency", function(b)
	local P = ns.Performance
	local on = W.IsOn("performance.enabled")

	b:Header("FPS and latency")
	b:Text("A small text on the screen with your frames per second and the latency (ping) of your connection, updated every second. The mouse goes through it.", GREY)
	b:Check("performance.enabled", "Show the FPS and latency")

	-- First, so it can be put in place before setting the rest up
	b:Header("Place on the screen")
	local move = b:Button("Move", function()
		P.SetMoving(not P.IsMoving())
		-- The button says Done right away while moving
		ns.RefreshOptions()
	end,
		"Shows the text with a green frame: drag it where you want, then click again (closing the options also ends it).")
	b:AddControl({frame = move, interactive = {move}, Refresh = function()
		move:SetText(P.IsMoving() and L["Done"] or L["Move"])
	end}, on)
	local reset = b:Button("Reset position", function()
		ns.Set("performance.x", ns.DEFAULTS.performance.x)
		ns.Set("performance.y", ns.DEFAULTS.performance.y)
	end, "Puts the text back in its first place, near the top of the screen.")
	b:AddControl({frame = reset, interactive = {reset}}, on)

	b:Header("What to show")
	b:Dropdown("performance.show", "Show", SHOW, nil, on)
	b:Dropdown("performance.ping", "Latency", PING,
		"World: your connection to the game world, where fights happen (the one that matters most). Home: your connection to the realm, for the chat, friends and guild.", on)
	b:Check("performance.colors", "Color by value",
		"Green when good, yellow when so-so, red when bad: FPS under 60 and under 30, latency over 100 and over 200 ms.", on)

	b:Header("Look")
	b:Slider("performance.size", "Text size", 1, nil, nil, on)
	b:Color("performance.color", "Text color", nil, on)
	b:Check("performance.background", "Dark background with a border", nil, on)
end)
