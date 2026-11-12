-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Proc alerts: when a proc happens (e.g. Fingers of Frost), the game's own spell alert art shows around
-- the character, pulsing, like the spell alerts of the newer game; abilities that become usable can also
-- light their button on the action bars.
--
-- Two ways to know a proc is there:
--   - an aura the addon can read: the addon reads it (UNIT_AURA) and shows its own art;
--   - an aura the game hides from addons (in combat, Forever makes many auras secret): the addon can't
--     know, so it asks the game's AuraContainer to show the art itself while the aura is there, with the
--     stacks asked for. The game tells which auras are secret (C_Secrets).
--
-- The art is the game's own (file IDs); nothing is shipped.

local _, ns = ...
local L = ns.L

local ProcAlerts = {}
ns.ProcAlerts = ProcAlerts

-- The size of the art: a side is 128 x 256, at 80%
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

-- The procs of each class in WoW Forever: the setting that turns it on,
-- the spell (an aura's ID; for a "counter", an ability that becomes usable, like Victory Rush after a
-- kill), also (other IDs of the same aura; only the ones known to be the proc: other spells of the same
-- name can be auras always on, whose art would never go away), a name for when the game doesn't give
-- one, combatOnly (only shown in combat), test (the stacks its test shows; else its most), and its art:
-- {stacks (nil: any; a number: that many; the game shows it from that many up), art, sides,
-- scale, shade (0-255, grey to white) or color ({r, g, b}, 0-255), alpha (0-255), pulse (false: stays still
-- whatever animation is picked; only for the first stacks of a proc whose moving says it's at its most)}
local EFFECTS = {
	MAGE = {
		{key = "missileBarrage", spell = 400589, name = "Missile Barrage", overlays = {
			{art = ART.ARCANE_MISSILES, sides = BOTH_SIDES, scale = 1.22},
		}},
		{key = "clearcasting", spell = 12536, name = "Clearcasting", overlays = {
			{art = ART.GENERIC_ARC_05, sides = BOTH_SIDES, scale = 1.5},
		}},
		-- One charge on the left, two on the right: each place asks the game for its number of stacks, and
		-- the game shows it from there up, so two charges light both sides (a place for "any" number never
		-- shows an aura that has stacks). Its test shows both, as SpellActivationOverlay's does.
		{key = "fingersOfFrost", spell = 400670, name = "Fingers of Frost", test = {1, 2}, overlays = {
			{stacks = 1, art = ART.FROZEN_FINGERS, sides = {"LEFT"}},
			{stacks = 2, art = ART.FROZEN_FINGERS, sides = {"RIGHT_FLIPPED"}},
		}},
		-- Heating Up gets stronger with its stacks: one faint, two stronger, three (Hot Streak) whole and
		-- moving (the only proc that waits to move: its moving says it's at its most; every other proc moves
		-- at any stacks). The game shows each piece from its stacks up (at 3, all three at once), so they're
		-- the same art at the same size and place: on top of each other they look like one, never three of
		-- different sizes. Its test shows the three, as the game does at 3 stacks.
		{key = "heatingUp", spell = 400625, name = "Heating Up", test = {1, 2, 3}, overlays = {
			{stacks = 1, art = ART.HOT_STREAK, sides = BOTH_SIDES, shade = 200, alpha = 100, pulse = false},
			{stacks = 2, art = ART.HOT_STREAK, sides = BOTH_SIDES, shade = 222, alpha = 100, pulse = false},
			{stacks = 3, art = ART.HOT_STREAK, sides = BOTH_SIDES},
		}},
	},
	DRUID = {
		-- One aura whose stacks tell the eclipse: 1-2 lunar (left), 3-4 solar (right); the second of each
		-- is the full one
		{key = "eclipse", spell = 408255, also = {441260}, name = "Eclipse", overlays = {
			{stacks = 1, art = ART.ECLIPSE_MOON, sides = {"LEFT"}, scale = 0.8, alpha = 192},
			{stacks = 2, art = ART.ECLIPSE_MOON, sides = {"LEFT"}, scale = 1.1},
			{stacks = 3, art = ART.ECLIPSE_MOON, sides = {"RIGHT_FLIPPED"}, scale = 0.8, alpha = 192},
			{stacks = 4, art = ART.ECLIPSE_MOON, sides = {"RIGHT_FLIPPED"}, scale = 1.1},
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
			{art = ART.WHITE_TIGER, sides = BOTH_SIDES, scale = 1.25, color = {32, 192, 255}},
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
			{stacks = 1, art = ART.MAELSTROM_1, sides = TOP, shade = 128},
			{stacks = 2, art = ART.MAELSTROM_2, sides = TOP, shade = 160},
			{stacks = 3, art = ART.MAELSTROM_3, sides = TOP, shade = 192},
			{stacks = 4, art = ART.MAELSTROM_4, sides = TOP, shade = 224},
			{stacks = 5, art = ART.MAELSTROM_5, sides = TOP},
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
			{art = ART.GENERIC_TOP_01, sides = TOP, color = {64, 255, 64}},
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

-- Every proc's art follows the animation picked, at any stacks; a proc whose first stacks stay still (its
-- moving says it's at its most, e.g. Heating Up): the fewest stacks it moves from, else nil
function ProcAlerts.MovesFrom(effect)
	local still, movesFrom = false, nil
	for _, overlay in ipairs(effect.overlays or {}) do
		if overlay.pulse == false then
			still = true
		elseif overlay.stacks then
			movesFrom = math.min(movesFrom or overlay.stacks, overlay.stacks)
		else
			return nil
		end
	end
	return still and movesFrom or nil
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

-- Animations ---------------------------------------------------------------------------------------

-- While a proc is there its art can move (each player picks, for every proc; only a proc whose moving says
-- it's at its most waits for those stacks), as Core\Effects.lua says: on the frame for a size or a place,
-- on the art for its light. And it can appear softly (a fade-in) instead of at once.
local FADE_IN_TIME = 0.25

local function AnimationSettings(overlay)
	local settings = Settings()
	if overlay.pulse == false then return "NONE" end
	return settings.animation or "NONE", settings.animTime or 1, (settings.animStrength or 8) / 100
end

-- Stops what the art did, and starts what it must do now (nothing when it stays still)
local function Animate(frame, art, overlay, playing)
	if not playing then
		ns.Effects.Play(frame, frame, art, "NONE")
		return
	end
	ns.Effects.Play(frame, frame, art, AnimationSettings(overlay))
end

-- The soft appearance: from nothing to whole, quickly (when asked)
local function FadeIn(frame)
	if not Settings().fadeIn then return end
	if not frame.fadeIn then
		frame.fadeIn = frame:CreateAnimationGroup()
		local fade = frame.fadeIn:CreateAnimation("Alpha")
		fade:SetFromAlpha(0)
		fade:SetToAlpha(1)
		fade:SetDuration(FADE_IN_TIME)
	end
	frame.fadeIn:Play()
end

-- The addon's own art ------------------------------------------------------------------------------

local function OwnFrame(id)
	local frame = ownFrames[id]
	if frame then return frame end
	frame = CreateFrame("Frame", nil, GetHolder())
	frame.art = frame:CreateTexture(nil, "ARTWORK")
	frame.art:SetAllPoints(frame)
	frame:Hide()
	ownFrames[id] = frame
	return frame
end

-- Shows an overlay's art (each side); wanted collects what's shown. One already shown keeps moving
local function ShowOwn(effect, index, overlay, wanted)
	for _, side in ipairs(overlay.sides) do
		local id = effect.key .. ":" .. index .. ":" .. side
		local frame = OwnFrame(id)
		wanted[id] = true
		Paint(frame.art, overlay, side)
		Place(frame, side, overlay.scale or 1)
		if not frame:IsShown() then
			frame:Show()
			FadeIn(frame)
			Animate(frame, frame.art, overlay, true)
		end
	end
end

-- Hides the art not wanted now (all of it without a list)
local function HideOwn(wanted)
	for id, frame in pairs(ownFrames) do
		if not (wanted and wanted[id]) and frame:IsShown() then
			Animate(frame, frame.art, nil, false)
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
-- (the art and its ants: Core\Effects.lua)
local Effects = ns.Effects

local glows = {}

local function AnimateAnts(glow, elapsed)
	glow.elapsed = (glow.elapsed or 0) + elapsed
	if glow.elapsed < Effects.ANTS_STEP then return end
	glow.elapsed = 0
	glow.step = ((glow.step or 0) + 1) % Effects.ANTS_FRAMES
	glow.ants:SetTexCoord(Effects.AntsCoords(glow.step))
end

local function GetGlow(button)
	local glow = glows[button]
	if glow then return glow end
	glow = CreateFrame("Frame", nil, button)
	glow:SetFrameLevel((button:GetFrameLevel() or 1) + 5)
	glow:EnableMouse(false)
	local width, height = button:GetSize()
	width, height = Known(width) or 36, Known(height) or 36
	local reach = Effects.GLOW_REACH
	glow:SetPoint("TOPLEFT", button, "TOPLEFT", -width * reach, height * reach)
	glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * reach, -height * reach)
	glow.outer = glow:CreateTexture(nil, "ARTWORK")
	glow.outer:SetTexture(Effects.GLOW_ART)
	glow.outer:SetTexCoord(unpack(Effects.GLOW_COORDS))
	glow.outer:SetAllPoints(glow)
	glow.ants = glow:CreateTexture(nil, "OVERLAY")
	glow.ants:SetTexture(Effects.ANTS_ART)
	glow.ants:SetPoint("CENTER", glow, "CENTER", 0, 0)
	glow.ants:SetSize(width * Effects.ANTS_SCALE, height * Effects.ANTS_SCALE)
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

-- Whether an overlay is for this many stacks (the addon's own art). The game's frames (AuraContainer)
-- show each place from its stacks up instead (Blizzard_CustomAuraButton: applications >= minApplications).
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
-- What happened when the container was made, for /ke procscan
local containerNote = "not tried yet"

local function GetContainer()
	if container ~= nil then return container or nil end
	container = false
	if not (C_Secrets and C_Secrets.GetSpellAuraSecrecy) then
		containerNote = "the game has no C_Secrets"
		return nil
	end
	if C_AddOns and C_AddOns.LoadAddOn then
		local okLoad, loaded, reason = pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer")
		if not okLoad or (not loaded and reason ~= "ALREADY_LOADED") then
			containerNote = "Blizzard_AuraContainer not loaded: " .. tostring(okLoad and reason or loaded)
		end
	end
	local ok, frame = pcall(CreateFrame, "AuraContainer", "KyoryokunaEnhancementsProcAuraContainer", GetHolder(),
		"CustomAuraContainerTemplate")
	if not ok or not frame then
		containerNote = "not made: " .. tostring(frame)
		return nil
	end
	containerNote = "made"
	frame:SetAllPoints(GetHolder())
	frame:SetUnit("player")
	frame:SetEnabled(true)
	container = frame
	return frame
end

-- One side of an overlay, shown by the game while the aura has those stacks
-- The parts of a frame the game made from the template: a frame that pulses, and on it the bar the game
-- shows only while the aura has the stacks asked for (hidden until then), with the art on the bar
local function MakeSlotParts(button)
	local item = CreateFrame("Frame", nil, button)
	item:SetAllPoints(button)
	local bar = CreateFrame("StatusBar", nil, item)
	bar:SetAllPoints(item)
	bar:Hide()
	bar.art = bar:CreateTexture(nil, "OVERLAY")
	bar.art:SetAllPoints(bar)
	-- The game also follows the aura's time on a cooldown: one that draws nothing
	local okCooldown, cooldown = pcall(CreateFrame, "Cooldown", nil, bar, "CooldownFrameTemplate")
	if okCooldown and cooldown then
		cooldown:SetAllPoints(bar)
		if cooldown.SetDrawSwipe then cooldown:SetDrawSwipe(false) end
		if cooldown.SetDrawEdge then cooldown:SetDrawEdge(false) end
		if cooldown.SetDrawBling then cooldown:SetDrawBling(false) end
		if cooldown.SetHideCountdownNumbers then cooldown:SetHideCountdownNumbers(true) end
		if cooldown.SetReverse then cooldown:SetReverse(true) end
		bar.cooldown = cooldown
	end
	item.applicationBar = bar
	button.pulsableItem = item
end

local function SetUpSlot(button, slot)
	local overlay = slot.overlay
	button:EnableMouse(false)
	-- The parts come with the template (Modules\ProcAlerts.xml); made here only if the game gave none
	if not button.pulsableItem then MakeSlotParts(button) end
	-- Never a script on the game's frames or their parts (no OnShow, no hooks): the game refuses to
	-- show or hide a frame with secret values once an addon listens to it, and the art never shows
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
	-- Given to the game once, when it makes the frame (what happens is kept for /ke procscan)
	if not slot.setUp then
		if button.SetApplicationBar then
			local ok, problem = pcall(button.SetApplicationBar, button, bar, {minApplications = fewest, maxApplications = most})
			slot.setUp = ok and true or ("error: " .. tostring(problem))
		else
			slot.setUp = "the game's frame has no SetApplicationBar"
		end
		if button.SetDurationCooldown and bar.cooldown then pcall(button.SetDurationCooldown, button, bar.cooldown) end
		button:SetFrameLevel(GetHolder():GetFrameLevel() + 3)
	end
	Place(button, slot.side, overlay.scale or 1)
	-- It moves all the time (unseen while the game hides the bar), as the settings say
	Animate(button.pulsableItem, bar.art, overlay, true)
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
			if not ok then
				effect.slotNote = tostring(button)
				return false
			end
			slot.button = slot.button or button
			-- A new place is on: never turned on again (that can make the game stop giving it new auras);
			-- only turned off and back on when its proc is unticked and ticked again
			slot.enabled = true
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

-- Abilities that become usable ("counter": Victory Rush after a kill, Riposte after a parry...): they show while
-- known, not on cooldown (the global one aside), and usable, or only
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

-- One proc shown as a test, with its name in the middle: the art of its most stacks, or of the stacks its
-- test asks for (as SpellActivationOverlay's tests: Fingers of Frost shows one and two charges, both sides)
local function ShowTestEffect(effect)
	local wanted = {}
	if ProcAlerts.ShowsArt(effect) then
		for _, stacks in ipairs(effect.test or {MostStacks(effect)}) do
			for index, overlay in ipairs(effect.overlays) do
				if Matches(overlay, stacks) then ShowOwn(effect, index, overlay, wanted) end
			end
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
			if slot.enabled ~= false and container and container.SetAuraSlotEnabled then
				pcall(container.SetAuraSlotEnabled, container, slot.key, false)
				slot.enabled = false
			end
		end
		return
	end
	GetHolder():Show()
	Prepare()
	-- The game's: each one on or off, and fitted to the size (off during a test, which shows its own)
	for _, slot in ipairs(slots) do
		local on = settings.enabled and settings[slot.effect.key] == true and not showingTest
		-- Only when something changed: turning a place on again, or setting it up again, may make the game
		-- lose it
		if slot.enabled ~= on and container and container.SetAuraSlotEnabled then
			pcall(container.SetAuraSlotEnabled, container, slot.key, on)
			slot.enabled = on
		end
		local look = settings.size .. ":" .. settings.distance .. ":" .. tostring(settings.animation) .. ":" .. tostring(settings.animTime)
			.. ":" .. tostring(settings.animStrength)
		if slot.button and slot.look ~= look then
			SetUpSlot(slot.button, slot)
			slot.look = look
		end
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

-- What the addon knows about the alerts now, for /ke procscan: lines of text
function ProcAlerts.Scan()
	local lines = {}
	local settings = Settings()
	local _, class = UnitClass("player")
	lines[#lines + 1] = string.format("on: %s, class: %s, in combat: %s, test: %s", tostring(settings.enabled), tostring(class),
		tostring(InCombat()), tostring(fixedKey or testing or false))
	lines[#lines + 1] = "AuraContainer: " .. containerNote .. ", slots: " .. #slots
	-- What the game itself said about its spell alerts lately (newest first)
	local said = ProcAlerts.NativeAlerts and ProcAlerts.NativeAlerts() or {}
	lines[#lines + 1] = "game alerts lately: " .. (#said > 0 and "" or "none")
	for _, line in ipairs(said) do lines[#lines + 1] = "    " .. line end
	for _, effect in ipairs(ProcAlerts.GetEffects()) do
		-- Each proc on its own: one that breaks says so, the others still show
		local okEffect, problem = pcall(function()
		if settings[effect.key] ~= true then return end
			local secrecy = "?"
			if C_Secrets and C_Secrets.GetSpellAuraSecrecy then
				local ok, value = pcall(C_Secrets.GetSpellAuraSecrecy, effect.spell)
				secrecy = ok and tostring(value) or ("error: " .. tostring(value))
			end
			local read
			if effect.kind == "counter" then
				read = "ready: " .. tostring(CounterReady(effect))
			elseif C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
				local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, effect.spell)
				if not ok then
					read = "aura: refused (" .. tostring(aura):sub(1, 60) .. ")"
				elseif type(aura) == "table" then
					read = "aura: on, stacks " .. tostring(Known(aura.applications))
				else
					read = "aura: off"
				end
			end
			lines[#lines + 1] = string.format("%s (%d): secrecy %s, by the game: %s%s, %s", ProcAlerts.SpellName(effect), effect.spell,
				secrecy, tostring(effect.byGame), effect.slotNote and (" (" .. effect.slotNote .. ")") or "", tostring(read))
			-- Its places in the game's container, by count only: what the game does with them is hidden from addons
			local places = 0
			for _, slot in ipairs(slots) do
				if slot.effect == effect then places = places + 1 end
			end
			lines[#lines + 1] = "    places in the game's container: " .. places
		end)
		if not okEffect then
			-- The error itself may be a value the game hides
			local text = Known(problem)
			lines[#lines + 1] = tostring(effect.name) .. ": " .. (text ~= nil and tostring(text) or "an error the game hides")
		end
	end
	return lines
end

-- The game's own spell alerts: it says when it would show one (and its spell), even when its display is
-- off. The last ones are kept for /ke procscan, to learn the spell IDs the game uses in WoW Forever.
local nativeAlerts = {}
local nativeFrame = CreateFrame("Frame")
for _, event in ipairs({"SPELL_ACTIVATION_OVERLAY_SHOW", "SPELL_ACTIVATION_OVERLAY_HIDE",
	"SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE"}) do
	pcall(nativeFrame.RegisterEvent, nativeFrame, event)
end
-- Watching (/ke procscan watch): each one written in the chat as it comes
local watching = false
nativeFrame:SetScript("OnEvent", function(_, event, spell, art)
	local short = event:gsub("SPELL_ACTIVATION_OVERLAY_", "")
	local name = type(Known(spell)) == "number" and SpellNameOf(spell) or nil
	local line = string.format("%s %s %s%s", short, tostring(Known(spell) or "hidden"), name or "",
		Known(art) and (" art " .. tostring(art)) or "")
	table.insert(nativeAlerts, 1, line)
	while #nativeAlerts > 8 do table.remove(nativeAlerts) end
	if watching then
		ns.Print("game alert: " .. line)
		ns.AddToDiagnostic("procscan watch", "game alert: " .. line)
	end
end)

function ProcAlerts.NativeAlerts()
	return nativeAlerts
end

function ProcAlerts.ToggleWatch()
	watching = not watching
	ProcAlerts.watchingOn = watching
	return watching
end

-- Every spell ID with a name (/ke procscan find Fingers of Frost): the game is asked the name of each
-- number, a slice at a time so the game never freezes; written in the chat at the end. A version of
-- the game may give a proc an ID of its own.
local FIND_LAST, FIND_SLICE = 1500000, 20000
local finding

function ProcAlerts.FindSpells(name)
	if finding then return false end
	if not (C_Spell and C_Spell.GetSpellName and C_Timer and C_Timer.After) then return false end
	local wanted = name:lower()
	local found, from = {}, 1
	finding = true
	local function Slice()
		local last = math.min(FIND_LAST, from + FIND_SLICE - 1)
		for id = from, last do
			local spellName = C_Spell.GetSpellName(id)
			if type(spellName) == "string" and spellName:lower() == wanted then found[#found + 1] = id end
		end
		from = last + 1
		if from <= FIND_LAST then
			C_Timer.After(0, function() ns.SafeCall(Slice) end)
			return
		end
		finding = nil
		local list = {}
		for _, id in ipairs(found) do
			local sub = C_Spell.GetSpellSubtext and Known(C_Spell.GetSpellSubtext(id))
			list[#list + 1] = tostring(id) .. ((type(sub) == "string" and sub ~= "") and (" (" .. sub .. ")") or "")
		end
		ns.Print(string.format("\"%s\": %s", name, #list > 0 and table.concat(list, ", ") or "no spell with that name"))
		ns.SaveDiagnostic("procscan find " .. name, list)
	end
	Slice()
	return true
end

-- Whether a spell is passive (a talent always on): its aura would always be there
local function IsPassive(id)
	for _, check in ipairs({C_Spell and C_Spell.IsSpellPassive, IsPassiveSpell}) do
		local ok, passive = pcall(check, id)
		if ok and Known(passive) ~= nil then return Known(passive) == true end
	end
	return nil
end

-- Every proc of every class at once (/ke procscan all): one pass over the spell IDs, asking the game the
-- name of each, keeping those named like a proc (its English name, or its name in the game's language),
-- each with whether it's passive. Kept in the saved data (procScan, written at the next /reload) and
-- summed up in the chat. Works on any character: the game knows every class's spells.
function ProcAlerts.FindAll()
	if finding then return false end
	if not (C_Spell and C_Spell.GetSpellName and C_Timer and C_Timer.After) then return false end
	-- The names asked for, and which procs each one belongs to
	local wanted, order = {}, {}
	for class, effects in pairs(EFFECTS) do
		for _, effect in ipairs(effects) do
			local entry = {class = class, key = effect.key, name = effect.name, ids = {}}
			order[#order + 1] = entry
			for _, name in ipairs({effect.name, SpellNameOf(effect.spell)}) do
				if type(name) == "string" then
					local lower = name:lower()
					wanted[lower] = wanted[lower] or {}
					table.insert(wanted[lower], entry)
				end
			end
		end
	end
	table.sort(order, function(a, b) return a.class .. a.key < b.class .. b.key end)
	local from = 1
	finding = true
	local function Slice()
		local last = math.min(FIND_LAST, from + FIND_SLICE - 1)
		for id = from, last do
			local spellName = C_Spell.GetSpellName(id)
			local entries = type(spellName) == "string" and wanted[spellName:lower()]
			if entries then
				for _, entry in ipairs(entries) do
					if not entry.ids[id] then entry.ids[id] = {passive = IsPassive(id)} end
				end
			end
		end
		from = last + 1
		if from <= FIND_LAST then
			C_Timer.After(0, function() ns.SafeCall(Slice) end)
			return
		end
		finding = nil
		-- Kept for the author (saved data), and summed up in the chat
		local build = GetBuildInfo and table.concat({GetBuildInfo()}, " ", 1, 2) or "?"
		local saved = {build = build, when = date and date("%Y-%m-%d %H:%M") or "?", procs = {}}
		for _, entry in ipairs(order) do
			local ids, text = {}, {}
			for id, info in pairs(entry.ids) do ids[#ids + 1] = {id = id, passive = info.passive} end
			table.sort(ids, function(a, b) return a.id < b.id end)
			for _, info in ipairs(ids) do
				text[#text + 1] = tostring(info.id) .. (info.passive and "p" or "")
			end
			saved.procs[#saved.procs + 1] = {class = entry.class, key = entry.key, name = entry.name, ids = ids}
			ns.Print(string.format("%s %s: %s", entry.class, entry.name, #text > 0 and table.concat(text, ", ") or "none"))
		end
		ns.db.procScan = saved
		ns.Print("done: kept in the addon's saved data (p = passive). Type /reload so the game writes it down.")
	end
	Slice()
	return true
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
