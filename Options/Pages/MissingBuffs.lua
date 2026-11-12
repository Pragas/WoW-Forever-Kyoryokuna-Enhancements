-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- What this character watches (buffs and conjured items), the group each goes to, copying another
-- character's choice, and how each group looks (Modules\MissingBuffs.lua). The lists come from the
-- spellbook, so the page is made again when the character learns a spell.

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}
local PAGE = "Missing Buffs"

-- The rest of the spellbook, shown on demand (it can be long)
local showOthers = false

local GROWTH = {
	{value = "CENTER", text = "Centered"},
	{value = "RIGHT", text = "To the right"},
	{value = "LEFT", text = "To the left"},
	{value = "UP", text = "Up"},
	{value = "DOWN", text = "Down"},
}

local COUNT_POSITIONS = {
	{value = "BOTTOMRIGHT", text = "Bottom right corner"},
	{value = "BOTTOMLEFT", text = "Bottom left corner"},
	{value = "CENTER", text = "Centered"},
	{value = "TOPRIGHT", text = "Top right corner"},
	{value = "TOPLEFT", text = "Top left corner"},
}

-- As the proc alerts' (Core\Effects.lua)
local ANIMATIONS = {
	{value = "NONE", text = "None"},
	{value = "PULSE", text = "Pulse"},
	{value = "BREATHE", text = "Breathe"},
	{value = "BLINK", text = "Blink"},
	{value = "FLOAT", text = "Float"},
}

local GLOWS = {
	{value = "NONE", text = "None"},
	{value = "GLOW", text = "The game's glow"},
	{value = "ANTS", text = "Moving outline"},
	{value = "BOTH", text = "Glow and moving outline"},
	{value = "BORDER", text = "Border of a color"},
}

ns.AddOptionsPage(PAGE, function(b)
	local MB = ns.MissingBuffs
	local on = W.IsOn("missingBuffs.enabled")

	-- The small dropdowns of a row: its group; for a family of buffs, its icon; for an item, its minimum
	local function GroupExtra(choice)
		return {
			width = 92, label = L["Group"], tooltip = L["Where its icon shows: with the essential buffs, or with the utility ones."],
			get = function() local watch = MB.GetWatch(choice.key); return watch and watch.group end,
			set = function(value) MB.SetGroup(choice.key, value) end,
			options = function() return {{value = "ESSENTIAL", text = L["Essential"]}, {value = "UTILITY", text = L["Utility"]}} end,
		}
	end
	local function IconExtra(choice)
		return {
			width = 130, label = L["Icon"], tooltip = L["The icon shown when the family is missing: one of its spells, or the one you used last."],
			get = function() local watch = MB.GetWatch(choice.key); return watch and watch.icon or "" end,
			set = function(value) MB.SetIcon(choice.key, value) end,
			options = function()
				local list = {{value = "", text = L["Last used"]}}
				for _, name in ipairs(choice.members) do list[#list + 1] = {value = name, text = name} end
				return list
			end,
		}
	end
	local function MinimumExtra(choice)
		return {
			width = 72, label = L["Minimum"], tooltip = L["Shown when your bags hold fewer than this. The icon shows how many you have."],
			get = function() local watch = MB.GetWatch(choice.key); return watch and watch.minimum or 1 end,
			set = function(value) MB.SetMinimum(choice.key, value) end,
			options = function()
				local list = {}
				for _, n in ipairs({1, 2, 3, 4, 5, 6, 8, 10, 15, 20}) do
					list[#list + 1] = {value = n, text = string.format(L["Min. %d"], n)}
				end
				return list
			end,
		}
	end
	local function Row(choice)
		local extras = {GroupExtra(choice)}
		if choice.kind == "ITEM" then
			extras[#extras + 1] = MinimumExtra(choice)
		elseif #choice.members > 1 then
			extras[#extras + 1] = IconExtra(choice)
		end
		-- What goes on the weapons: said how it counts; a name of the addon's in the language now
		local tooltip = choice.kind == "WEAPON"
			and L["Shown while a weapon in your hands has none on it (both hands when you hold two weapons)."] or nil
		-- Its icon as on the screen: the one picked for a family, else the one used last
		b:IconCheck(choice.labelKey and L[choice.labelKey] or choice.label, function() return MB.IconFor(choice) end,
			function() return MB.IsWatched(choice.key) end,
			function(checked) MB.SetWatched(choice.key, checked) end,
			tooltip, on, extras)
	end

	b:Header("Missing buffs")
	b:Text("When something you chose is missing, its icon shows on the screen, grey and faded, in and out of combat (not while you're dead). Each thing goes to one of two groups, Essential or Utility, each with its own place and look.", GREY)
	b:Check("missingBuffs.enabled", "Show what's missing")

	-- First, so the groups can be put in place before setting the rest up
	b:Header("Place on the screen")
	local move = b:Button("Move", function()
		MB.SetMoving(not MB.IsMoving())
		-- The button says Done right away while moving
		ns.RefreshOptions()
	end,
		"Shows both groups with a green frame: drag each where you want, then click again (closing the options also ends it).")
	b:AddControl({frame = move, Refresh = function()
		move:SetText(MB.IsMoving() and L["Done"] or L["Move"])
	end})
	b:Button("Reset position", function()
		for _, section in ipairs({"missingBuffsEssential", "missingBuffsUtility"}) do
			ns.Set(section .. ".x", ns.DEFAULTS[section].x)
			ns.Set(section .. ".y", ns.DEFAULTS[section].y)
		end
	end, "Puts both groups back in their first place, above the middle of the screen.")

	local suggested, items, others = MB.GetChoices()
	b:Header(string.format(L["Buffs of %s (%s)"], MB.GetCharacterName(), MB.GetClassName()), true)
	b:Text("Tick the buffs to watch, and pick their group. Buffs that can't be on together, like the armors of a mage, are one line: any of them is enough, and you can pick the icon. The same buff from someone else counts too.", GREY)
	-- (what goes on the weapons is offered to every class: not one of its buffs)
	local buffs = 0
	for _, choice in ipairs(suggested) do
		if choice.kind == "BUFF" then buffs = buffs + 1 end
	end
	if buffs == 0 then
		b:Text("No usual buffs of your class in your spellbook. Any other spell can be chosen at the bottom of the page.", GREY)
	end
	for _, choice in ipairs(suggested) do Row(choice) end
	-- The same note for buffs and items: what Blizzard allows in combat
	local COMBAT_NOTE = "(Not in combat: Blizzard's API doesn't let addons change clickable buttons during a fight. An icon already on the screen when the fight starts still works; one that shows during it becomes clickable when the fight ends.)"
	b:Space(4)
	b:Check("missingBuffs.clickToCast", "Click an icon to cast the buff",
		"A click on the icon of a missing buff casts it on you, whoever you have targeted. For a family, the spell of the icon picked, else the one you used last.", on)
	b:Text(COMBAT_NOTE, GREY, nil, 22)

	if #items > 0 then
		b:Header("Conjured items")
		b:Text("Shown when your bags hold fewer than the minimum (any rank counts).", GREY)
		for _, choice in ipairs(items) do Row(choice) end
		b:Space(4)
		b:Check("missingBuffs.clickToConjure", "Click an icon to conjure the item",
			"A click on the icon of a missing conjured item casts the spell that makes it, with the best rank you know.", on)
		b:Text(COMBAT_NOTE, GREY, nil, 22)
	end

	b:Space(6)
	b:Text("All this is kept for this character only, and read from your spellbook: a spell you learn later shows up then.", GREY)
	-- Another character of the same class already chose: its choice can be copied here
	local sources = MB.GetCopySources()
	if #sources > 0 then
		b:Text("Copy the choice of another character of your class (it replaces this character's):", GREY)
		for _, source in ipairs(sources) do
			local button = b:Button("Copy", function()
				W.Confirm("KYORYOKUNAENHANCEMENTS_COPY_BUFFS",
					string.format(L["Copy the missing buffs of %s to this character? Its own choice is replaced."], source.name),
					function() MB.CopyFrom(source.key) end)
			end, "Puts that character's choice on this one.", 280)
			button:SetText(string.format(L["Copy from %s (%d)"], source.name, source.count))
		end
	end

	-- Each group's look
	local function Look(header, section)
		b:Header(header)
		b:Slider(section .. ".iconSize", "Icon size", 1, " px", nil, on)
		b:Slider(section .. ".alpha", "Opacity", 5, "%", "How see-through the icons are: lower is more faded.", on)
		b:Slider(section .. ".spacing", "Space between icons", 1, " px", nil, on)
		b:Dropdown(section .. ".growth", "Direction", GROWTH, "Where the icons go when more than one is missing. The side they grow from stays in place.", on)
		b:Check(section .. ".showZero", "Show the number when there are none", "The number on a conjured item's icon is how many your bags hold. Off, an item you have none of shows no number.", on)
		b:Dropdown(section .. ".countPosition", "Number position", COUNT_POSITIONS, "Where the number of a conjured item goes on its icon.", on)
		b:Slider(section .. ".countSize", "Number size", 1, nil, "How big the number of a conjured item is on its icon.", on)
		-- How the icons move, as the proc alerts can, and what surrounds them
		b:Dropdown(section .. ".animation", "Animation", ANIMATIONS, "How the icons move while they show.", on)
		local moves = W.All(on, function() return ns.Get(section .. ".animation") ~= "NONE" end)
		b:Slider(section .. ".animTime", "Speed (one cycle)", 0.1, " s", "How long one cycle lasts: less is faster. The game's own spell alerts take 1 second.", moves)
		b:Slider(section .. ".animStrength", "Strength", 1, "%", "How much it changes: how much it grows (Pulse), fades (Breathe, Blink) or rises (Float).", moves)
		b:Dropdown(section .. ".glow", "Glow", GLOWS, "What surrounds the icons: the glow of the game's spell alerts, its moving outline, both, or a border of a color.", on)
		local glows = W.All(on, function() return ns.Get(section .. ".glow") ~= "NONE" end)
		b:Color(section .. ".glowColor", "Glow color", "The color of the glow, the outline or the border.", glows)
		local border = W.All(on, function() return ns.Get(section .. ".glow") == "BORDER" end)
		b:Slider(section .. ".borderSize", "Border size", 1, " px", "How thick the border of a color is.", border)
	end
	Look("Essential group", "missingBuffsEssential")
	Look("Utility group", "missingBuffsUtility")

	b:Header("Other spells")
	b:Text("Every other spell of your spellbook, for a buff that isn't in the lists above.", GREY)
	b:Button(showOthers and "Hide the other spells" or "Show the other spells", function()
		showOthers = not showOthers
		ns.RebuildOptionsPage(PAGE)
	end)
	if showOthers then
		for _, choice in ipairs(others) do Row(choice) end
	end
end)
