-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Proc alerts (Modules\ProcAlerts.lua): on or off, which procs of the character's class, the look, and a
-- test.

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}
local WARNING = {1, 0.6, 0.2}

ns.AddOptionsPage("Proc Alerts", function(b)
	local P = ns.ProcAlerts
	local on = W.IsOn("procAlerts.enabled")

	b:Header("Proc alerts")
	b:Text("When one of your procs happens (e.g. Fingers of Frost), the game's spell alert art shows on the sides of your character, as in the newer game. It works in combat too: when the game hides an aura from addons, the game itself shows the art.", GREY)
	b:Check("procAlerts.enabled", "Show proc alerts")

	-- Two of them at once would show everything twice
	if P.GameAlertsOn() then
		b:Text("The game's own spell alerts are on (Options > Combat > Spell Alert Opacity): some procs would show twice.", WARNING)
		b:Button("Turn off the game's spell alerts", function()
			P.TurnOffGameAlerts()
			ns.RebuildOptionsPage("Proc Alerts")
		end, "Sets the game's Spell Alert Opacity to off. It can be turned on again in the game's options.", 260)
	end
	if P.OtherAddonOn() then
		b:Text("The SpellActivationOverlay addon is on: with both, the alerts show twice. Turn one of them off.", WARNING)
	end

	local className = UnitClass("player")
	b:Header(string.format(L["Procs of your class (%s)"], className or ""), true)
	local effects = P.GetEffects()
	if #effects == 0 then
		b:Text("Your class's procs come in a next version: for now, the mage's.", GREY)
	else
		b:Text("Tick the ones to show.", GREY)
		for _, effect in ipairs(effects) do
			local icon = C_Spell and C_Spell.GetSpellTexture and ns.Known(C_Spell.GetSpellTexture(effect.spell))
			b:IconCheck(P.SpellName(effect), icon,
				function() return ns.db.procAlerts[effect.key] == true end,
				function(checked) ns.Set("procAlerts." .. effect.key, checked) end,
				nil, on)
		end
	end

	b:Header("Look")
	b:Slider("procAlerts.size", "Size", 5, "%", "The size of the art, from half to twice the game's.", on)
	b:Slider("procAlerts.distance", "Distance between the sides", 10, " px", "How far apart the left and right art are: more keeps them away from your character.", on)
	b:Slider("procAlerts.y", "Height", 10, " px", "Up or down from the middle of the screen.", on)
	b:Slider("procAlerts.opacity", "Opacity", 5, "%", "How see-through the art is: lower is more faded.", on)
	b:Check("procAlerts.pulse", "Pulse", "The art grows and shrinks slowly while the proc is there (some procs never pulse, as in the game).", on)
	b:Space(6)
	b:Button("Test", function()
		-- The art is around the middle of the screen, under this window: only its title bar stays
		if ns.SetOptionsMinimized then ns.SetOptionsMinimized(true) end
		P.Test()
	end, "Shows each proc of your class in turn, for a few seconds, with its name. The options shrink to their title bar meanwhile (+ brings them back).")
end)
