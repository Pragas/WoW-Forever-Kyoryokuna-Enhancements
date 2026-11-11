-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Proc alerts: when a proc happens (e.g. Fingers of Frost), the game's own spell alert art shows on the
-- sides of the character, pulsing, like the spell alerts of the newer game. Based on SpellActivationOverlay,
-- by ennvina, used under the MIT License (see LICENSE, "Third-party notices"): which procs, their art,
-- places and sizes, and how to show them in combat, come from it, made again for WoW Forever only.
--
-- Two ways to know a proc is there:
--   - an aura the addon can read: the addon reads it (UNIT_AURA) and shows its own art;
--   - an aura the game hides from addons (in combat, Forever makes many auras secret): the addon can't
--     know, so it asks the game's AuraContainer to show the art itself while the aura is there, with the
--     stacks asked for. The game tells which auras are secret (C_Secrets).
--
-- The art is the game's own (file IDs); nothing is shipped. Phase 1: the mage.

local _, ns = ...
local L = ns.L

local ProcAlerts = {}
ns.ProcAlerts = ProcAlerts

-- The size of the art, as SpellActivationOverlay draws it: a side is 128 x 256, at 80%
local SIZE_SCALE = 0.8
local LONG_SIDE, SHORT_SIDE = 256, 128

-- The game's spell alert art (file IDs)
local ART = {
	ARCANE_MISSILES = 449486,
	BANDITS_GUILE = 1030393,
	DAYBREAK = 459313,
	ECLIPSE_MOON = 450914,
	FROZEN_FINGERS = 449489,
	GENERIC_ARC_05 = 450921,
	GENERIC_TOP_01 = 450923,
	HAND_OF_LIGHT = 459314,
	HOT_STREAK = 449490,
	IMPACT = 457658,
	MAELSTROM_1 = 1028136,
	MAELSTROM_2 = 1028137,
	MAELSTROM_3 = 1028138,
	MAELSTROM_4 = 1028139,
	MAELSTROM_5 = 450927,
	NATURES_GRACE = 450929,
	NIGHTFALL = 449492,
	RAGING_BLOW = 962497,
	SERENDIPITY = 469752,
	WHITE_TIGER = 603339,
}

-- Where the art goes around the middle: on the left; on the right, mirrored; on top; on top, turned a
-- quarter clockwise (art made for a side)
local BOTH_SIDES = {"LEFT", "RIGHT_FLIPPED"}
local TOP = {"TOP"}
local TOP_TURNED = {"TOP_CW"}

-- The procs of each class (in WoW Forever, from SpellActivationOverlay): the setting that turns it on,
-- the spell (an aura's ID; for a "counter", an ability that becomes usable, like Victory Rush after a
-- kill), a name for when the game doesn't give one, combatOnly (only shown in combat), and its art:
-- {stacks (nil: any; a number: exactly that many), art, sides, scale, shade (0-255, grey to white) or
-- color ({r, g, b}, 0-255), alpha (0-255), pulse}
local EFFECTS = {
	MAGE = {
		{key = "missileBarrage", spell = 400589, name = "Missile Barrage", overlays = {
			{art = ART.ARCANE_MISSILES, sides = BOTH_SIDES, scale = 1.22},
		}},
		{key = "clearcasting", spell = 12536, name = "Clearcasting", overlays = {
			{art = ART.GENERIC_ARC_05, sides = BOTH_SIDES, scale = 1.5, pulse = false},
		}},
		-- One charge on the left, the second one on the right too
		{key = "fingersOfFrost", spell = 400670, name = "Fingers of Frost", overlays = {
			{art = ART.FROZEN_FINGERS, sides = {"LEFT"}},
			{stacks = 2, art = ART.FROZEN_FINGERS, sides = {"RIGHT_FLIPPED"}},
		}},
		-- Heating Up grows with its stacks; at 3 (Hot Streak) it's whole and pulses
		{key = "heatingUp", spell = 400625, name = "Heating Up", overlays = {
			{stacks = 1, art = ART.HOT_STREAK, sides = BOTH_SIDES, scale = 0.6, shade = 200, pulse = false},
			{stacks = 2, art = ART.HOT_STREAK, sides = BOTH_SIDES, scale = 0.8, shade = 222, pulse = false},
			{stacks = 3, art = ART.HOT_STREAK, sides = BOTH_SIDES, scale = 1.0},
		}},
	},
	DRUID = {
		-- One aura whose stacks tell the eclipse: 1-2 lunar (left), 3-4 solar (right); the second of each
		-- is the full one
		{key = "eclipse", spell = 408255, name = "Eclipse", overlays = {
			{stacks = 1, art = ART.ECLIPSE_MOON, sides = {"LEFT"}, scale = 0.8, alpha = 192, pulse = false},
			{stacks = 2, art = ART.ECLIPSE_MOON, sides = {"LEFT"}, scale = 1.1, pulse = false},
			{stacks = 3, art = ART.ECLIPSE_MOON, sides = {"RIGHT_FLIPPED"}, scale = 0.8, alpha = 192, pulse = false},
			{stacks = 4, art = ART.ECLIPSE_MOON, sides = {"RIGHT_FLIPPED"}, scale = 1.1, pulse = false},
		}},
		{key = "omenOfClarity", spell = 16870, name = "Omen of Clarity", overlays = {
			{art = ART.NATURES_GRACE, sides = BOTH_SIDES},
		}},
		{key = "naturesGrace", spell = 16886, name = "Nature's Grace", overlays = {
			{art = ART.SERENDIPITY, sides = TOP, scale = 0.7},
		}},
	},
	HUNTER = {
		{key = "rapidKilling", spell = 415407, name = "Rapid Killing", overlays = {
			{art = ART.RAGING_BLOW, sides = BOTH_SIDES, scale = 1.2, alpha = 222},
		}},
		{key = "mongooseBite", spell = 1495, name = "Mongoose Bite", kind = "counter", combatOnly = true, overlays = {
			{art = ART.BANDITS_GUILE, sides = TOP_TURNED, scale = 1.1},
		}},
	},
	PALADIN = {
		{key = "infusionOfLight", spell = 53672, also = {437063}, name = "Infusion of Light", overlays = {
			{art = ART.DAYBREAK, sides = BOTH_SIDES},
		}},
	},
	PRIEST = {
		{key = "martyrdom", spell = 27828, name = "Martyrdom", overlays = {
			{art = ART.WHITE_TIGER, sides = BOTH_SIDES, scale = 1.25, color = {32, 192, 255}, pulse = false},
		}},
		{key = "searingLight", spell = 1284536, name = "Searing Light", overlays = {
			{art = ART.HAND_OF_LIGHT, sides = TOP},
		}},
	},
	ROGUE = {
		{key = "remorselessAttacks", spell = 14143, name = "Remorseless Attacks", overlays = {
			{art = ART.RAGING_BLOW, sides = BOTH_SIDES, scale = 1.2, alpha = 222},
		}},
		{key = "cutthroat", spell = 462707, name = "Cutthroat", overlays = {
			{art = ART.WHITE_TIGER, sides = BOTH_SIDES},
		}},
		{key = "riposte", spell = 14251, name = "Riposte", kind = "counter", overlays = {
			{art = ART.BANDITS_GUILE, sides = TOP_TURNED},
		}},
	},
	SHAMAN = {
		-- Grows lighter with each stack; at 5 it's whole
		{key = "maelstromWeapon", spell = 408505, name = "Maelstrom Weapon", overlays = {
			{stacks = 1, art = ART.MAELSTROM_1, sides = TOP, shade = 128, pulse = false},
			{stacks = 2, art = ART.MAELSTROM_2, sides = TOP, shade = 160, pulse = false},
			{stacks = 3, art = ART.MAELSTROM_3, sides = TOP, shade = 192, pulse = false},
			{stacks = 4, art = ART.MAELSTROM_4, sides = TOP, shade = 224, pulse = false},
			{stacks = 5, art = ART.MAELSTROM_5, sides = TOP, pulse = false},
		}},
	},
	WARLOCK = {
		{key = "nightfall", spell = 17941, name = "Nightfall", overlays = {
			{art = ART.NIGHTFALL, sides = BOTH_SIDES},
		}},
		{key = "decimation", spell = 440873, name = "Decimation", overlays = {
			{art = ART.IMPACT, sides = TOP, scale = 0.8},
		}},
		{key = "eyeOfKilrogg", spell = 126, name = "Eye of Kilrogg", overlays = {
			{art = ART.GENERIC_TOP_01, sides = TOP, color = {64, 255, 64}, pulse = false},
		}},
	},
	WARRIOR = {
		{key = "victoryRush", spell = 402927, name = "Victory Rush", kind = "counter", overlays = {
			{art = ART.SERENDIPITY, sides = TOP, scale = 0.9, color = {255, 32, 32}},
		}},
		-- Only their buttons light up
		{key = "overpower", spell = 7384, name = "Overpower", kind = "counter", overlays = {}},
		{key = "execute", spell = 5308, name = "Execute", kind = "counter", overlays = {}},
		{key = "revenge", spell = 6572, name = "Revenge", kind = "counter", overlays = {}},
	},
}
-- Abilities whose button lights up but which have no art (phase 3), added to their classes
local BUTTON_ONLY = {
	MAGE = {{key = "iceBarrier", spell = 11426, name = "Ice Barrier", combatOnly = true}},
	HUNTER = {{key = "counterattack", spell = 19306, name = "Counterattack"}},
	PALADIN = {
		{key = "holyShock", spell = 20473, name = "Holy Shock", combatOnly = true},
		-- Only on a demon or an undead that can be attacked
		{key = "exorcism", spell = 879, name = "Exorcism", combatOnly = true, target = "DEMON_OR_UNDEAD"},
		{key = "hammerOfWrath", spell = 24275, name = "Hammer of Wrath"},
	},
	SHAMAN = {{key = "stormstrike", spell = 17364, name = "Stormstrike", combatOnly = true}},
}
for class, list in pairs(BUTTON_ONLY) do
	EFFECTS[class] = EFFECTS[class] or {}
	for _, effect in ipairs(list) do
		effect.kind, effect.overlays = "counter", {}
		table.insert(EFFECTS[class], effect)
	end
end
ProcAlerts.EFFECTS = EFFECTS

local holder, label
local container
local ownFrames = {}
local slots = {}
local testing
local testTimer

local function Known(value)
	return ns.Known and ns.Known(value) or value
end

local function PlayerClass()
	local _, class = UnitClass("player")
	return class
end

function ProcAlerts.GetEffects()
	return EFFECTS[PlayerClass()] or {}
end

function ProcAlerts.SpellName(effect)
	local name = C_Spell and C_Spell.GetSpellName and Known(C_Spell.GetSpellName(effect.spell))
	return type(name) == "string" and name or effect.name
end

local function Settings()
	return ns.db.procAlerts
end

-- Moving the alerts (the page's "Move"): a green frame to drag, over everything; ends with the options
local moving = false

local function Round(value)
	return math.floor(value + 0.5)
end

-- The frame the art goes around: in the middle of the screen (or where it was moved), as wide as the
-- distance asked
local function GetHolder()
	if holder then return holder end
	holder = CreateFrame("Frame", "KyoryokunaEnhancementsProcAlerts", UIParent)
	holder:SetFrameStrata("LOW")
	holder:EnableMouse(false)
	holder:SetMovable(true)
	holder:SetClampedToScreen(true)
	holder:RegisterForDrag("LeftButton")
	holder:SetScript("OnDragStart", function(self)
		if moving then self:StartMoving() end
	end)
	holder:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		-- Kept as a distance from the middle of the screen
		local x, y = self:GetCenter()
		local centerX, centerY = UIParent:GetCenter()
		if x and centerX then
			local settings = ns.db.procAlerts
			settings.x, settings.y = Round(x - centerX), Round(y - centerY)
			ns.ValidateSettings()
		end
		ns.SafeCall(ProcAlerts.Update)
	end)
	holder.mover = holder:CreateTexture(nil, "BACKGROUND")
	holder.mover:SetAllPoints(holder)
	holder.mover:SetColorTexture(0.18, 0.8, 0.44, 0.35)
	holder.mover:Hide()
	holder.hint = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	holder.hint:SetPoint("BOTTOM", holder, "BOTTOM", 0, 8)
	holder.hint:Hide()
	-- The name of the proc shown by the test
	label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	label:SetPoint("CENTER", holder, "CENTER", 0, 0)
	label:Hide()
	return holder
end

-- Sizes for the settings now: the long and short side of the art, and the holder's width
local function Geometry()
	local settings = Settings()
	local scale = SIZE_SCALE * settings.size / 100
	return LONG_SIDE * scale, SHORT_SIDE * scale, LONG_SIDE * scale + settings.distance
end

local function ApplyHolder()
	local settings = Settings()
	local frame = GetHolder()
	local _, _, width = Geometry()
	frame:SetSize(math.max(1, width), math.max(1, width))
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", settings.x, settings.y)
	frame:SetAlpha(settings.opacity / 100)
	-- While moving: the green frame to drag, above the options window
	frame:SetFrameStrata(moving and "DIALOG" or "LOW")
	frame:EnableMouse(moving)
	frame.mover:SetShown(moving)
	frame.hint:SetShown(moving)
	frame.hint:SetText(L["Proc alerts: drag to move"])
end

function ProcAlerts.SetMoving(on)
	moving = on and true or false
	if not moving and label and not fixedKey then label:Hide() end
	ns.SafeCall(ProcAlerts.Update)
end

function ProcAlerts.IsMoving()
	return moving
end

-- A piece of art on its side of the holder, with its size (on the sides tall and narrow, on top wide
-- and low)
local function Place(frame, side, scale)
	local long, short = Geometry()
	frame:ClearAllPoints()
	if side == "TOP" or side == "TOP_CW" then
		frame:SetSize(long * scale, short * scale)
		frame:SetPoint("BOTTOM", GetHolder(), "TOP", 0, 0)
	elseif side == "LEFT" then
		frame:SetSize(short * scale, long * scale)
		frame:SetPoint("RIGHT", GetHolder(), "LEFT", 0, 0)
	else
		frame:SetSize(short * scale, long * scale)
		frame:SetPoint("LEFT", GetHolder(), "RIGHT", 0, 0)
	end
end

local function Paint(texture, overlay, side)
	texture:SetTexture(overlay.art)
	if side == "RIGHT_FLIPPED" then
		texture:SetTexCoord(1, 0, 0, 1)
	elseif side == "TOP_CW" then
		-- A quarter turn clockwise (the corners in the game's order: top left, bottom left, top right,
		-- bottom right)
		texture:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
	else
		texture:SetTexCoord(0, 1, 0, 1)
	end
	local r, g, b
	if overlay.color then
		r, g, b = overlay.color[1] / 255, overlay.color[2] / 255, overlay.color[3] / 255
	else
		local shade = (overlay.shade or 255) / 255
		r, g, b = shade, shade, shade
	end
	texture:SetVertexColor(r, g, b, (overlay.alpha or 255) / 255)
end

local function MustPulse(overlay)
	return Settings().pulse and overlay.pulse ~= false
end

-- The addon's own art ------------------------------------------------------------------------------

local function OwnFrame(id)
	local frame = ownFrames[id]
	if frame then return frame end
	frame = CreateFrame("Frame", nil, GetHolder(), "KyoryokunaEnhancementsProcOverlayTemplate")
	if not frame.art then
		frame.art = frame:CreateTexture(nil, "ARTWORK")
		frame.art:SetAllPoints(frame)
	end
	frame:Hide()
	ownFrames[id] = frame
	return frame
end

-- Shows an overlay's art (each side); wanted collects what's shown. One already shown keeps its pulse
local function ShowOwn(effect, index, overlay, wanted)
	for _, side in ipairs(overlay.sides) do
		local id = effect.key .. ":" .. index .. ":" .. side
		local frame = OwnFrame(id)
		wanted[id] = true
		Paint(frame.art, overlay, side)
		Place(frame, side, overlay.scale or 1)
		if not frame:IsShown() then
			frame:Show()
			if frame.pulse then
				if MustPulse(overlay) then frame.pulse:Play() else frame.pulse:Stop() end
			end
		end
	end
end

-- Hides the art not wanted now (all of it without a list)
local function HideOwn(wanted)
	for id, frame in pairs(ownFrames) do
		if not (wanted and wanted[id]) and frame:IsShown() then
			if frame.pulse then frame.pulse:Stop() end
			frame:Hide()
		end
	end
end

-- Glowing buttons -----------------------------------------------------------------------------------

-- The game's action bars: a button glows while the ability it holds (a spell, or a macro's spell) is
-- ready. The glow is the addon's own frame on the button, with the game's spell alert art (a gold glow
-- and its running "ants"); the button itself is never touched, so it works in combat.
local BAR_BUTTONS = {
	"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
	"MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button",
}
local GLOW_ART = "Interface\\SpellActivationOverlay\\IconAlert"
local ANTS_ART = "Interface\\SpellActivationOverlay\\IconAlertAnts"
-- The ants: 22 pictures of 48 x 48 in a 256 x 256 sheet, 5 to a row
local ANTS_FRAMES, ANTS_SIZE, ANTS_SHEET, ANTS_STEP = 22, 48, 256, 0.03

local glows = {}

local function AnimateAnts(glow, elapsed)
	glow.elapsed = (glow.elapsed or 0) + elapsed
	if glow.elapsed < ANTS_STEP then return end
	glow.elapsed = 0
	glow.step = ((glow.step or 0) + 1) % ANTS_FRAMES
	local column, row = glow.step % 5, math.floor(glow.step / 5)
	local size = ANTS_SIZE / ANTS_SHEET
	glow.ants:SetTexCoord(column * size, (column + 1) * size, row * size, (row + 1) * size)
end

local function GetGlow(button)
	local glow = glows[button]
	if glow then return glow end
	glow = CreateFrame("Frame", nil, button)
	glow:SetFrameLevel((button:GetFrameLevel() or 1) + 5)
	glow:EnableMouse(false)
	local width, height = button:GetSize()
	width, height = Known(width) or 36, Known(height) or 36
	glow:SetPoint("TOPLEFT", button, "TOPLEFT", -width * 0.2, height * 0.2)
	glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
	glow.outer = glow:CreateTexture(nil, "ARTWORK")
	glow.outer:SetTexture(GLOW_ART)
	glow.outer:SetTexCoord(0.0078125, 0.5078125, 0.27734375, 0.52734375)
	glow.outer:SetAllPoints(glow)
	glow.ants = glow:CreateTexture(nil, "OVERLAY")
	glow.ants:SetTexture(ANTS_ART)
	glow.ants:SetPoint("CENTER", glow, "CENTER", 0, 0)
	glow.ants:SetSize(width * 1.4 * 0.85, height * 1.4 * 0.85)
	glow:SetScript("OnUpdate", AnimateAnts)
	glow:Hide()
	glows[button] = glow
	return glow
end

-- The spell a bar button holds now (its own, or its macro's), and the button
local function ButtonSpell(button)
	local slot = button.action
	if not slot and button.GetAttribute then slot = button:GetAttribute("action") end
	slot = Known(slot)
	if type(slot) ~= "number" or not (GetActionInfo and HasAction and Known(HasAction(slot))) then return nil end
	local kind, id = GetActionInfo(slot)
	kind, id = Known(kind), Known(id)
	if kind == "spell" then return id end
	if kind == "macro" and GetMacroSpell then return Known(GetMacroSpell(id)) end
	return nil
end

local function SpellNameOf(spell)
	local name = C_Spell and C_Spell.GetSpellName and Known(C_Spell.GetSpellName(spell))
	return type(name) == "string" and name or nil
end

-- Every bar button and the name of the spell it holds (any rank of a spell shares its name)
local function BarButtons()
	local list = {}
	for _, prefix in ipairs(BAR_BUTTONS) do
		for index = 1, 12 do
			local button = _G[prefix .. index]
			if button then
				local spell = ButtonSpell(button)
				list[#list + 1] = {button = button, spell = spell, name = spell and SpellNameOf(spell)}
			end
		end
	end
	return list
end

-- The buttons of these spell names glow; every other one stops
local function SetGlows(names)
	local any = next(names) ~= nil
	for _, entry in ipairs(any and BarButtons() or {}) do
		if entry.name and names[entry.name] then
			local glow = GetGlow(entry.button)
			glow:Show()
		end
	end
	for button, glow in pairs(glows) do
		if glow:IsShown() then
			local spell = ButtonSpell(button)
			local name = spell and SpellNameOf(spell)
			if not (name and names[name]) then glow:Hide() end
		end
	end
end

-- A rank of this ability on a bar (its ID), for what the character knows of it
local function SpellOnBars(effect)
	local name = SpellNameOf(effect.spell) or effect.name
	for _, entry in ipairs(BarButtons()) do
		if entry.name == name then return entry.spell end
	end
end

-- Whether an overlay is for this many stacks
local function Matches(overlay, stacks)
	return overlay.stacks == nil or overlay.stacks == stacks
end

-- The game's art for hidden auras ------------------------------------------------------------------

local function IsSecret(spell)
	if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy and Enum and Enum.SecrecyLevel) then return false end
	local ok, secrecy = pcall(C_Secrets.GetSpellAuraSecrecy, spell)
	return ok and (secrecy == Enum.SecrecyLevel.ContextuallySecret or secrecy == Enum.SecrecyLevel.AlwaysSecret) or false
end

-- The game's AuraContainer, made once (nil when the game has none)
local function GetContainer()
	if container ~= nil then return container or nil end
	container = false
	if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy) then return nil end
	if C_AddOns and C_AddOns.LoadAddOn then pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer") end
	local ok, frame = pcall(CreateFrame, "AuraContainer", "KyoryokunaEnhancementsProcAuraContainer", GetHolder(),
		"CustomAuraContainerTemplate")
	if not ok or not frame then return nil end
	frame:SetAllPoints(GetHolder())
	frame:SetUnit("player")
	frame:SetEnabled(true)
	container = frame
	return frame
end

-- One side of an overlay, shown by the game while the aura has those stacks
local function SetUpSlot(button, slot)
	local overlay = slot.overlay
	button:EnableMouse(false)
	local bar = button.pulsableItem and button.pulsableItem.applicationBar
	if not bar then return end
	Paint(bar.art, overlay, slot.side)
	local fewest, most = 0, 1
	if overlay.stacks then
		fewest, most = overlay.stacks, overlay.stacks
		if Enum.StatusBarFillStyle and Enum.StatusBarFillStyle.StandardNoRangeFill then
			bar:SetFillStyle(Enum.StatusBarFillStyle.StandardNoRangeFill)
		end
	end
	if button.SetApplicationBar then button:SetApplicationBar(bar, {minApplications = fewest, maxApplications = most}) end
	if button.SetDurationCooldown and bar.cooldown then button:SetDurationCooldown(bar.cooldown) end
	Place(button, slot.side, overlay.scale or 1)
	if MustPulse(overlay) then button.pulsableItem.pulse:Play() else button.pulsableItem.pulse:Stop() end
	if button.GetIcon and button:GetIcon() then button:GetIcon():Hide() end
end

local function MakeSlots(effect)
	local frame = GetContainer()
	if not frame then return false end
	for index, overlay in ipairs(effect.overlays) do
		for _, side in ipairs(overlay.sides) do
			local slot = {effect = effect, overlay = overlay, side = side, key = "KE_" .. effect.key .. "_" .. index .. "_" .. side}
			-- The aura, and the other IDs the game gives the same proc
			local spells = {[effect.spell] = true}
			for _, other in ipairs(effect.also or {}) do spells[other] = true end
			local ok, button = pcall(frame.AddAuraSlot, frame, slot.key, "HELPFUL", {
				templateNames = {"KyoryokunaEnhancementsProcAuraTemplate"},
				initializeFrame = function(made) slot.button = made; SetUpSlot(made, slot) end,
				candidateFilters = {includeSpellIDs = spells},
			})
			if not ok then return false end
			slot.button = slot.button or button
			slots[#slots + 1] = slot
		end
	end
	return true
end

-- Showing ----------------------------------------------------------------------------------------

-- Effects whose aura the game hides go to the AuraContainer, once (from login, out of combat)
local prepared = false
local function Prepare()
	if prepared then return end
	prepared = true
	for _, effect in ipairs(ProcAlerts.GetEffects()) do
		effect.byGame = effect.kind ~= "counter" and IsSecret(effect.spell) and MakeSlots(effect) or false
	end
end

-- The stacks of a proc on the character (its aura, or one of the other IDs of the same proc), nil
-- without it
local function ReadStacks(effect)
	if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return nil end
	local spells = {effect.spell}
	for _, other in ipairs(effect.also or {}) do spells[#spells + 1] = other end
	for _, spell in ipairs(spells) do
		local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spell)
		if ok and type(aura) == "table" then
			local stacks = Known(aura.applications)
			if type(stacks) ~= "number" or stacks < 1 then stacks = 1 end
			return stacks
		end
	end
	return nil
end

-- Abilities that become usable ("counter": Victory Rush after a kill, Riposte after a parry...), as
-- SpellActivationOverlay tells them: known, not on cooldown (the global one aside), and usable, or only
-- short of rage or energy. What the game hides keeps the last answer.
local lastReady = {}
local retryAt = {}

local function InCombat()
	return (UnitAffectingCombat and Known(UnitAffectingCombat("player")) == true) or (InCombatLockdown and InCombatLockdown()) or false
end

local function KnowsSpell(spell)
	for _, check in ipairs({IsPlayerSpell, C_SpellBook and C_SpellBook.IsSpellKnown, IsSpellKnown}) do
		local ok, known = pcall(check, spell)
		if ok and Known(known) == true then return true end
	end
	return false
end

local function CostsMana(spell)
	if not (C_Spell and C_Spell.GetSpellPowerCost) then return false end
	local ok, costs = pcall(C_Spell.GetSpellPowerCost, spell)
	if not ok or type(costs) ~= "table" then return false end
	for _, cost in ipairs(costs) do
		if Known(cost.name) == "MANA" then return true end
	end
	return false
end

-- What the target must be (Exorcism: a demon or an undead that can be attacked, alive); what the game
-- hides counts as not
local function TargetFits(effect)
	if effect.target ~= "DEMON_OR_UNDEAD" then return true end
	if not UnitExists or not Known(UnitExists("target")) then return false end
	if UnitCanAttack and Known(UnitCanAttack("player", "target")) == false then return false end
	if UnitIsDead and Known(UnitIsDead("target")) == true then return false end
	local creature = UnitCreatureType and Known(select(2, UnitCreatureType("target")))
	return creature == 3 or creature == 6
end

local function CounterReady(effect)
	-- The rank known: the effect's own, or the one on a bar (a higher rank has another ID)
	local spell = effect.spell
	if not KnowsSpell(spell) then
		spell = SpellOnBars(effect)
		if not spell then return false end
	end
	if effect.combatOnly and not InCombat() then return false end
	if not TargetFits(effect) then return false end
	if not (C_Spell and C_Spell.IsSpellUsable) then return false end
	local ok, usable, noPower = pcall(C_Spell.IsSpellUsable, spell)
	if not ok then return lastReady[spell] or false end
	usable, noPower = Known(usable), Known(noPower)
	if usable == nil and noPower == nil then return lastReady[spell] or false end
	local onCooldown = false
	if C_Spell.GetSpellCooldown then
		local okCooldown, info = pcall(C_Spell.GetSpellCooldown, spell)
		if okCooldown and type(info) == "table" then
			onCooldown = Known(info.isActive) == true and Known(info.isOnGCD) ~= true
			-- Usable but cooling down: looked at again when it's done (the game may not say)
			local start, duration = Known(info.startTime), Known(info.duration)
			if usable and onCooldown and type(start) == "number" and type(duration) == "number" and C_Timer and C_Timer.After then
				local doneAt = start + duration
				if retryAt[spell] ~= doneAt then
					retryAt[spell] = doneAt
					C_Timer.After(math.max(0.05, doneAt - GetTime() + 0.05), function() ns.SafeCall(ProcAlerts.UpdateAuras) end)
				end
			end
		end
	end
	local ready = not onCooldown and (usable == true or (noPower == true and not CostsMana(spell)))
	lastReady[spell] = ready
	return ready
end

-- The test that stays (the options' "Show" beside a proc): that proc at its most stacks, until hidden
local fixedKey

local function MostStacks(effect)
	local most = 1
	for _, overlay in ipairs(effect.overlays) do most = math.max(most, overlay.stacks or 1) end
	return most
end

-- One proc shown as a test (its most stacks), with its name in the middle
local function ShowTestEffect(effect)
	local wanted = {}
	local most = MostStacks(effect)
	if ProcAlerts.ShowsArt(effect) then
		for index, overlay in ipairs(effect.overlays) do
			if Matches(overlay, most) then ShowOwn(effect, index, overlay, wanted) end
		end
	end
	HideOwn(wanted)
	-- Its buttons glow too, when it lights them
	local names = {}
	if ProcAlerts.LightsButtons(effect) then names[SpellNameOf(effect.spell) or effect.name] = true end
	SetGlows(names)
	label:SetText(ProcAlerts.SpellName(effect))
	label:Show()
end

-- An ability with art and a button: how it warns, as each player picks ("ART", "BUTTON" or "BOTH");
-- nil for the others
function ProcAlerts.AlertKind(effect)
	if effect.kind ~= "counter" or #effect.overlays == 0 then return nil end
	return Settings()[effect.key .. "Alert"] or "ART"
end

-- Whether a ready ability lights its buttons: always when it has no art; for one with art, as picked
local function LightsButtons(effect)
	if effect.kind ~= "counter" then return false end
	local kind = ProcAlerts.AlertKind(effect)
	return kind == nil or kind == "BUTTON" or kind == "BOTH"
end
ProcAlerts.LightsButtons = LightsButtons

-- Whether its art shows (not for one set to its button only)
local function ShowsArt(effect)
	return ProcAlerts.AlertKind(effect) ~= "BUTTON"
end
ProcAlerts.ShowsArt = ShowsArt

local function FindEffect(key)
	for _, effect in ipairs(ProcAlerts.GetEffects()) do
		if effect.key == key then return effect end
	end
end

-- The addon's own art: the auras it can read and the abilities that became usable (on every change of
-- the character's auras, of what's usable, of combat)
function ProcAlerts.UpdateAuras()
	if not ns.db or testing then return end
	local fixed = fixedKey and FindEffect(fixedKey)
	-- While moving, a proc with art shows, to see where it goes
	if not fixed and moving then
		for _, effect in ipairs(ProcAlerts.GetEffects()) do
			if #effect.overlays > 0 then fixed = effect break end
		end
	end
	if fixed then
		ShowTestEffect(fixed)
		return
	end
	local settings = Settings()
	local wanted, glowNames = {}, {}
	if settings.enabled then
		for _, effect in ipairs(ProcAlerts.GetEffects()) do
			if not effect.byGame and settings[effect.key] == true then
				local stacks
				if effect.kind == "counter" then
					stacks = CounterReady(effect) and 1 or nil
				else
					stacks = ReadStacks(effect)
				end
				if stacks then
					if ShowsArt(effect) then
						for index, overlay in ipairs(effect.overlays) do
							if Matches(overlay, stacks) then ShowOwn(effect, index, overlay, wanted) end
						end
					end
					if LightsButtons(effect) then glowNames[SpellNameOf(effect.spell) or effect.name] = true end
				end
			end
		end
	end
	HideOwn(wanted)
	SetGlows(glowNames)
end

-- The fixed test: on for a proc (another one replaces it), off with nil or the same proc again
function ProcAlerts.SetFixedTest(key)
	if key and key == fixedKey then key = nil end
	fixedKey = key
	if not key and label then label:Hide() end
	ProcAlerts.Update()
end

function ProcAlerts.GetFixedTest()
	return fixedKey
end

-- Everything as the settings say now (place, size, opacity, which procs), then the auras
function ProcAlerts.Update()
	if not ns.db then return end
	local settings = Settings()
	ApplyHolder()
	local showingTest = testing or fixedKey ~= nil or moving
	if not settings.enabled and not showingTest then
		GetHolder():Hide()
		HideOwn()
		SetGlows({})
		for _, slot in ipairs(slots) do
			if container and container.SetAuraSlotEnabled then pcall(container.SetAuraSlotEnabled, container, slot.key, false) end
		end
		return
	end
	GetHolder():Show()
	Prepare()
	-- The game's: each one on or off, and fitted to the size (off during a test, which shows its own)
	for _, slot in ipairs(slots) do
		local on = settings.enabled and settings[slot.effect.key] == true and not showingTest
		if container and container.SetAuraSlotEnabled then pcall(container.SetAuraSlotEnabled, container, slot.key, on) end
		if slot.button then SetUpSlot(slot.button, slot) end
	end
	-- The addon's own: shown again at the new size
	HideOwn()
	ProcAlerts.UpdateAuras()
end

-- The test: each proc of the class in turn, at its most stacks, with its name
function ProcAlerts.Test()
	local effects = ProcAlerts.GetEffects()
	if #effects == 0 then
		ns.Print(L["Proc alerts: none for your class yet."])
		return
	end
	if testTimer then testTimer:Cancel() end
	-- The turning test replaces the fixed one
	fixedKey = nil
	testing = true
	ProcAlerts.Update()
	local step = 0
	local function Next()
		step = step + 1
		local effect = effects[step]
		if not effect then
			testing = false
			label:Hide()
			testTimer = nil
			ProcAlerts.Update()
			return
		end
		ShowTestEffect(effect)
		if C_Timer and C_Timer.NewTimer then testTimer = C_Timer.NewTimer(2.5, function() ns.SafeCall(Next) end) end
	end
	Next()
end

function ProcAlerts.IsTesting()
	return testing == true
end

-- The game's own spell alerts (Options > Combat), which would show twice with these
function ProcAlerts.GameAlertsOn()
	return C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool("displaySpellActivationOverlays") or false
end

function ProcAlerts.TurnOffGameAlerts()
	if C_CVar and C_CVar.SetCVar then C_CVar.SetCVar("displaySpellActivationOverlays", "0") end
end

-- SpellActivationOverlay itself, which would show them twice too
function ProcAlerts.OtherAddonOn()
	local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("SpellActivationOverlay")
	return loaded and true or false
end

local function Changed()
	ns.SafeCall(ProcAlerts.Update)
end

ns.RegisterEvent("PLAYER_ENTERING_WORLD", Changed)

-- The character's own auras only
local auraFrame = CreateFrame("Frame")
if auraFrame.RegisterUnitEvent then
	auraFrame:RegisterUnitEvent("UNIT_AURA", "player")
else
	auraFrame:RegisterEvent("UNIT_AURA")
end
auraFrame:SetScript("OnEvent", function(_, _, unit)
	if unit == "player" and ns.db and Settings().enabled and not testing then ns.SafeCall(ProcAlerts.UpdateAuras) end
end)

-- What's usable (Victory Rush, Riposte, Mongoose Bite), and combat (some only show in it)
local function UsableChanged()
	if ns.db and Settings().enabled and not testing then ns.SafeCall(ProcAlerts.UpdateAuras) end
end
for _, event in ipairs({"SPELL_UPDATE_USABLE", "SPELL_UPDATE_COOLDOWN", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED", "ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR"}) do
	ns.RegisterEvent(event, UsableChanged)
end

-- The fixed test ends with the options (Options\Window.lua)
function ProcAlerts.StopFixedTest()
	if fixedKey then ProcAlerts.SetFixedTest(nil) end
	-- And the moving
	if moving then ProcAlerts.SetMoving(false) end
end

-- For the tests
function ProcAlerts.ResetForTests()
	prepared, container, slots = false, nil, {}
	for _, effect in ipairs(ProcAlerts.GetEffects()) do effect.byGame = nil end
end

function ProcAlerts.OwnFrames()
	return ownFrames
end

function ProcAlerts.Slots()
	return slots
end
