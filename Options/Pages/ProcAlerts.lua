-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Proc alerts (Modules\ProcAlerts.lua): on or off, which procs of the character's class, the look, and a
-- test.

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}

local ANIMATIONS = {
	{value = "NONE", text = "None"},
	{value = "PULSE", text = "Pulse"},
	{value = "BREATHE", text = "Breathe"},
	{value = "BLINK", text = "Blink"},
	{value = "FLOAT", text = "Float"},
}
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

	-- Second, so the alerts can be put in place before setting the rest up
	b:Header("Place on the screen")
	local move = b:Button("Move", function()
		P.SetMoving(not P.IsMoving())
		-- The button says Done right away while moving
		ns.RefreshOptions()
	end,
		"Shows the alerts with a green frame: drag it where you want, then click again (closing the options also ends it).")
	b:AddControl({frame = move, Refresh = function()
		move:SetText(P.IsMoving() and L["Done"] or L["Move"])
	end})
	b:Button("Reset position", function()
		ns.Set("procAlerts.x", ns.DEFAULTS.procAlerts.x)
		ns.Set("procAlerts.y", ns.DEFAULTS.procAlerts.y)
	end, "Puts the alerts back in the middle of the screen.")

	local className = UnitClass("player")
	b:Header(string.format(L["Procs of your class (%s)"], className or ""), true)
	local effects = P.GetEffects()
	if #effects == 0 then
		b:Text("No proc alerts for your class yet.", GREY)
	else
		b:Text("Tick the ones to show. \"Test\" beside a proc keeps its alert on the screen while you set its look below (drag this window aside to see it): \"Close test\", or closing the options, ends it.", GREY)
		-- A proc whose art waits for its most stacks to move
		local anyWaits = false
		for _, effect in ipairs(effects) do
			local icon = C_Spell and C_Spell.GetSpellTexture and ns.Known(C_Spell.GetSpellTexture(effect.spell))
			-- The fixed test of this proc
			local show = {
				width = 100, label = L["Test"],
				tooltip = L["Keeps this proc's alert on the screen, at its most stacks, to set its look. Click \"Close test\" or close the options to end it."],
				text = function() return P.GetFixedTest() == effect.key and L["Close test"] or L["Test"] end,
				onClick = function()
					P.SetFixedTest(effect.key)
					if ns.RefreshOptions then ns.RefreshOptions() end
				end,
			}
			local label, tooltip = P.SpellName(effect), nil
			if effect.kind == "counter" and #effect.overlays == 0 then
				label = label .. "  |cff9d9d9d(" .. L["button glows"] .. ")|r"
				tooltip = L["Its button on your action bars glows while this ability can be used."]
			elseif effect.kind == "counter" then
				label = label .. "  |cff9d9d9d(" .. L["when usable"] .. ")|r"
				tooltip = L["Shown while this ability can be used (e.g. after a kill, a parry or a dodge)."]
			elseif effect.unit == "target" then
				tooltip = L["Shown while your target is frozen, by you or by someone else."]
			end
			-- Every proc moves as picked below; one whose moving says it's at its most waits for those stacks
			local movesFrom = P.MovesFrom(effect)
			if movesFrom then
				anyWaits = true
				label = label .. "  |cff9d9d9d(" .. string.format(L["animated from %d stacks"], movesFrom) .. ")|r"
				local why = string.format(L["Its art stays still until it has %d stacks, its most: only then it moves as picked below, so you know it's full."], movesFrom)
				tooltip = tooltip and (tooltip .. " " .. why) or why
			end
			local extras = {show}
			-- An ability with art and a button: the art, its button glowing, or both
			if P.AlertKind(effect) then
				local path = "procAlerts." .. effect.key .. "Alert"
				table.insert(extras, 1, {
					width = 90, label = L["Alert"],
					tooltip = L["How this ability warns you when it's ready: its art on the screen, its button glowing on your action bars, or both."],
					get = function() return ns.Get(path) end,
					set = function(value) ns.Set(path, value) end,
					options = function()
						return {{value = "ART", text = L["Art"]}, {value = "BUTTON", text = L["Button"]}, {value = "BOTH", text = L["Both"]}}
					end,
				})
			end
			b:IconCheck(label, icon,
				function() return ns.db.procAlerts[effect.key] == true end,
				function(checked) ns.Set("procAlerts." .. effect.key, checked) end,
				tooltip, on, extras)
		end
		b:Space(4)
		b:Text("\"Button glows\": while the ability is ready, its button on the game's action bars gets a moving gold outline (also a macro that casts it).", GREY)
		if anyWaits then
			b:Text("\"Animated from\": the proc's art stays still until it has that many stacks, its most, so its moving tells you it's full.", GREY)
		end
	end

	b:Header("Look")
	b:Slider("procAlerts.size", "Size", 5, "%", "The size of the art, from half to twice the game's.", on)
	b:Slider("procAlerts.distance", "Distance between the sides", 10, " px", "How far apart the left and right art are: more keeps them away from your character.", on)
	b:Slider("procAlerts.opacity", "Opacity", 5, "%", "How see-through the art is: lower is more faded.", on)

	b:Header("Animation")
	b:Dropdown("procAlerts.animation", "Animation", ANIMATIONS,
		"How the art moves while the proc is there, for every proc (one marked \"animated from\" in the list above only at its most stacks).", on)
	local moves = W.All(on, function() return ns.Get("procAlerts.animation") ~= "NONE" end)
	b:Slider("procAlerts.animTime", "Speed (one cycle)", 0.1, " s", "How long one cycle lasts: less is faster. The game's own spell alerts take 1 second.", moves)
	b:Slider("procAlerts.animStrength", "Strength", 1, "%", "How much it changes: how much it grows (Pulse), fades (Breathe, Blink) or rises (Float).", moves)
	b:Check("procAlerts.fadeIn", "Appear softly", "The art fades in when the proc comes, instead of showing at once.", on)
	b:Space(6)
	b:Button("Test all", function()
		-- The art is around the middle of the screen, under this window: only its title bar stays
		if ns.SetOptionsMinimized then ns.SetOptionsMinimized(true) end
		P.Test()
	end, "Shows each proc of your class in turn, for a few seconds, with its name. The options shrink to their title bar meanwhile (+ brings them back).")
end)
