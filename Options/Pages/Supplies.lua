-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Supplies: which macros of food and drink this character wants (Modules\Supplies.lua), and what each
-- would use now.

local _, ns = ...
local L = ns.L

local GREY = {0.7, 0.7, 0.7}

-- An icon for each macro: bread, water, and a biscuit that is both
local ICON_ITEMS = {FOOD = 4540, DRINK = 159, BOTH = 13724}

local LABELS = {
	FOOD = {"Food only", "Eats the best food in your bags (health)."},
	DRINK = {"Drink only", "Drinks the best drink in your bags (mana)."},
	BOTH = {"Food and drink", "Eats and drinks at once, each the best you have: both bars fill together while you sit."},
}

local function ItemName(id)
	local name = C_Item and C_Item.GetItemNameByID and ns.Known(C_Item.GetItemNameByID(id))
	return type(name) == "string" and name or ("item " .. id)
end

-- "Conjured Crystal Water (12)", or "none"
local function Describe(kind)
	local found = ns.Supplies.GetBest(kind)
	if not found then return L["none in your bags"] end
	if found.count then return string.format("%s (%d)", ItemName(found.id), found.count) end
	return ItemName(found.id)
end

ns.AddOptionsPage("Supplies", function(b)
	local S = ns.Supplies

	b:Header("Food and drink macros")
	b:Text("Macros of this character that eat and drink the best food and drink in your bags, bought, looted or conjured. Tick the ones you want: the addon makes each macro for you. Then click its \"Pick up\" and click an empty slot of an action bar to place it. That's all: the addon keeps it up to date by itself as your bags change (the strongest you can use; when it runs out, the next one).", GREY)
	for _, macro in ipairs(S.MACROS) do
		local label = LABELS[macro.key]
		local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(ICON_ITEMS[macro.key])
		-- Beside it, while ticked: the macro on the mouse, to drop straight on an action bar
		local pickUp = {
			width = 110, text = L["Pick up"], label = L["Pick up"],
			tooltip = L["Puts the macro on your mouse: click an empty slot of an action bar to place it there. No need to open the macros window."],
			onClick = function() S.PickUp(macro.key) end,
		}
		local extras = {pickUp}
		-- The one that eats and drinks: which icon it shows
		if macro.key == "BOTH" then
			table.insert(extras, 1, {
				width = 90, label = L["Icon"], tooltip = L["The icon of this macro on your action bar: the food's or the drink's."],
				get = function() return ns.db.supplies.bothIcon end,
				set = function(value) ns.Set("supplies.bothIcon", value) end,
				options = function() return {{value = "FOOD", text = L["Food"]}, {value = "DRINK", text = L["Drink"]}} end,
			})
		end
		b:IconCheck(string.format("%s  |cff9d9d9d(%s)|r", L[label[1]], L[macro.name]), icon,
			function() return S.IsOn(macro.key) end,
			function(checked) S.SetOn(macro.key, checked) end,
			L[label[2]], nil, extras)
	end
	b:Space(4)
	b:Text("Kept for this character only: a warrior may want only the food, a mage all three. A macro unticked is deleted. With nothing in your bags, a mage's macro conjures more (your highest rank); anyone else's says there's none.", GREY)
	b:Text("(Not in combat: Blizzard's API doesn't let addons change macros during a fight. They follow when it ends, and nobody can eat or drink in combat anyway.)", GREY)

	b:Header("Food with a buff")
	b:Check("supplies.buffFood", "Use food with a buff too",
		"Food that makes you well fed (more stamina, spirit...) is usually kept for raids and dungeons. Off, the macros leave it in your bags.")

	b:Header("Now")
	b:Text("What the macros use now:", GREY)
	local food = b:Text("", nil, true)
	local drink = b:Text("", nil, true)
	b:AddControl({frame = food, Refresh = function()
		food:SetText(string.format("%s: %s", L["Food"], Describe("FOOD")))
		drink:SetText(string.format("%s: %s", L["Drink"], Describe("DRINK")))
	end})
	b:Space(10)
	b:Button("Open the macros window", function()
		if InCombatLockdown and InCombatLockdown() then return end
		if C_AddOns and C_AddOns.LoadAddOn then pcall(C_AddOns.LoadAddOn, "Blizzard_MacroUI") end
		if MacroFrame and ShowUIPanel then ShowUIPanel(MacroFrame) end
	end, "To drag the macros to your action bars (also with /macro).")
end)
