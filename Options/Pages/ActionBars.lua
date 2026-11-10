-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...
local W = ns.Widgets

ns.AddOptionsPage("Action Bars", function(b)
	b:Header("Texts on the buttons")
	b:Check("actionBars.hideKeybinds", "Hide the keys", "The key each button is bound to, on every action bar.")
	b:Check("actionBars.hideMacroNames", "Hide the names of macros", "The name of a macro, written on its button.")

	b:Header("Cooldown numbers")
	b:Text("The seconds left on a button whose spell is on cooldown. They show when the game's option \"Show cooldown numbers\" is on (Options > Action Bars).",
		{0.7, 0.7, 0.7})
	b:Slider("actionBars.cooldownScale", "Size", 5, "%", "100% is the game's own size.")
	b:Check("actionBars.cooldownColors", "Color the numbers by the time left",
		"One color while the cooldown is long, another for its last seconds, so you see at a glance what's about to be ready.")
	local colors = W.IsOn("actionBars.cooldownColors")
	b:Color("actionBars.cooldownColorLong", "Long cooldown", "The color of the numbers until the last seconds.", colors, true)
	b:Color("actionBars.cooldownColorShort", "Last seconds", "The color of the numbers in the last seconds.", colors, true)
	b:Slider("actionBars.cooldownColorThreshold", "Last seconds from", 1, " s",
		"How many seconds before the end the color changes.", colors, true)

	b:Header("Key press")
	b:Check("actionBars.keyPress", "Show when a button's key is pressed",
		"A short effect over the button whenever you press its key, so you see which button you used.")
	b:Dropdown("actionBars.keyPressStyle", "Effect", {
		{value = "FLASH", text = "Flash"},
		{value = "BORDER", text = "Glowing border"},
	}, "Flash: the button lights up for a moment. Glowing border: a golden border around it, growing as it fades.",
		W.IsOn("actionBars.keyPress"), true)

	b:Header("Micro menu")
	b:Check("actionBars.hideMicroMenuBorder", "Hide the micro menu's frame",
		"The frame and background around the small buttons of the game's menus (character, spellbook, talents...). The buttons stay.")
end)
