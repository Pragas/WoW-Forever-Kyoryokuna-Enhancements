-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Error messages (Modules\ErrorMessages.lua): which of the game's red messages are hidden.

local _, ns = ...
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}

-- The kinds, in the order shown, with an example of each
local KINDS = {
	{key = "cooldown", label = "Not ready yet", tip = "\"Spell is not ready yet\", \"Ability is not ready yet\", an item still cooling down."},
	{key = "power", label = "Not enough mana, rage or energy", tip = "\"Not enough mana\", \"Not enough rage\", \"Not enough energy\", combo points."},
	{key = "range", label = "Out of range", tip = "\"Out of range\", \"Target too close\"."},
	{key = "sight", label = "Not in line of sight", tip = "\"Target not in line of sight\"."},
	{key = "facing", label = "Facing the wrong way", tip = "\"You are facing the wrong way!\", \"Target needs to be in front of you\"."},
	{key = "target", label = "No target or wrong target", tip = "\"You have no target\", \"Invalid target\", \"Your target is dead\"."},
	{key = "busy", label = "Another action in progress", tip = "\"Another action is in progress\", \"You can't do that right now\"."},
	{key = "moving", label = "Can't do that while moving", tip = "\"Can't do that while moving\"."},
}

ns.AddOptionsPage("Error Messages", function(b)
	local on = W.IsOn("errorMessages.enabled")
	local kinds = W.All(on, function() return not ns.Get("errorMessages.hideAll") end)

	b:Header("Error messages")
	b:Text("The red messages the game shows in the middle of the screen, like \"Spell is not ready yet\" when a button is pressed again and again. Pick the ones to hide: only the text is hidden, the game's sound still plays. Useful messages, like a full bag, always show.", GREY)
	b:Check("errorMessages.enabled", "Filter the error messages")

	b:Header("Messages to hide")
	for _, kind in ipairs(KINDS) do
		b:Check("errorMessages." .. kind.key, kind.label, kind.tip, kinds)
	end
	b:Space(4)
	b:Check("errorMessages.hideAll", "Hide every error message", "Every red message of the game, the useful ones too.", on)

	b:Header("When and how")
	b:Check("errorMessages.onlyInCombat", "Only in combat", "Out of combat every message shows, as in the game.", on)
	b:Check("errorMessages.muteVoice", "Silence the voice of the messages", "Your character no longer says \"Not enough mana\" and the like, for every message, hidden or not. (The game's own setting: turned back on when this is off.)", on)
end)
