-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- What the proc alerts (Modules\ProcAlerts.lua) and the missing buffs (Modules\MissingBuffs.lua) share:
-- the way their art moves (each player picks) and the game's glow around an icon or a button.

local _, ns = ...

local Effects = {}
ns.Effects = Effects

-- Animations ---------------------------------------------------------------------------------------
-- One cycle lasts the time asked, and the strength (a part of 1: 0.08 is 8%) is how much it changes:
--   PULSE    grows and comes back (by the strength; 8% in 1 second is the game's own spell alerts)
--   BREATHE  fades a little and comes back, its size never changes (3 times the strength)
--   BLINK    fades out fast and comes back, then waits (4 times the strength)
--   FLOAT    rises and comes back down (1.5 pixels per % of strength)
Effects.ANIMATIONS = {NONE = true, PULSE = true, BREATHE = true, BLINK = true, FLOAT = true}

local function Step(group, kind, duration, order, a, b)
	local step = group:CreateAnimation(kind)
	step:SetDuration(duration)
	step:SetSmoothing("IN_OUT")
	step:SetOrder(order)
	if kind == "Scale" then
		-- From one size to another (the game's older way: a size relative to the last)
		if step.SetScale then
			step:SetScale(b / a, b / a)
		else
			step:SetScaleFrom(a, a)
			step:SetScaleTo(b, b)
		end
	elseif kind == "Alpha" then
		step:SetFromAlpha(a)
		step:SetToAlpha(b)
	elseif kind == "Translation" then
		step:SetOffset(0, b - a)
	end
	return step
end

-- The animation for these settings, looping (nil for none): on mover for a size or a place, on light for
-- its light (the same frame, or a part of it). An animation can't be changed once made: one each.
function Effects.MakeAnimation(mover, light, kind, time, strength)
	local half = time / 2
	local group
	if kind == "PULSE" then
		group = mover:CreateAnimationGroup()
		Step(group, "Scale", half, 1, 1, 1 + strength)
		Step(group, "Scale", half, 2, 1 + strength, 1)
	elseif kind == "BREATHE" then
		local low = math.max(0.1, 1 - strength * 3)
		group = light:CreateAnimationGroup()
		Step(group, "Alpha", half, 1, 1, low)
		Step(group, "Alpha", half, 2, low, 1)
	elseif kind == "BLINK" then
		local low = math.max(0.1, 1 - strength * 4)
		group = light:CreateAnimationGroup()
		Step(group, "Alpha", time * 0.15, 1, 1, low)
		Step(group, "Alpha", time * 0.15, 2, low, 1)
		Step(group, "Alpha", time * 0.7, 3, 1, 1)
	elseif kind == "FLOAT" then
		local height = strength * 100 * 1.5
		group = mover:CreateAnimationGroup()
		Step(group, "Translation", half, 1, 0, height)
		Step(group, "Translation", half, 2, height, 0)
	end
	if group then group:SetLooping("REPEAT") end
	return group
end

-- Stops what owner's art did, and plays what's asked now (nothing for none). The animations are kept on
-- owner, one for each kind, time and strength; owner.animation is the one playing.
function Effects.Play(owner, mover, light, kind, time, strength)
	if owner.animation then owner.animation:Stop() end
	owner.animation = nil
	if not kind or kind == "NONE" then return end
	owner.animations = owner.animations or {}
	local key = kind .. ":" .. time .. ":" .. strength
	if not owner.animations[key] then
		local group = Effects.MakeAnimation(mover, light, kind, time, strength)
		if not group then return end
		owner.animations[key] = group
	end
	owner.animation = owner.animations[key]
	owner.animation:Play()
end

-- The game's glow ------------------------------------------------------------------------------------
-- The spell alert art of the action bars: a soft glow around a button, and its running "ants"

Effects.GLOW_ART = "Interface\\SpellActivationOverlay\\IconAlert"
Effects.GLOW_COORDS = {0.0078125, 0.5078125, 0.27734375, 0.52734375}
Effects.ANTS_ART = "Interface\\SpellActivationOverlay\\IconAlertAnts"
-- How far the glow reaches out of what it surrounds, a part of its size on each side; the ants' size
Effects.GLOW_REACH = 0.2
Effects.ANTS_SCALE = 1.4 * 0.85
-- The ants: 22 pictures of 48 x 48 in a 256 x 256 sheet, 5 to a row, one every 0.03 seconds
Effects.ANTS_FRAMES, Effects.ANTS_STEP = 22, 0.03
local ANTS_SIZE, ANTS_SHEET = 48, 256

-- The part of the sheet for one picture of the ants (0 to ANTS_FRAMES - 1)
function Effects.AntsCoords(step)
	local column, row = step % 5, math.floor(step / 5)
	local size = ANTS_SIZE / ANTS_SHEET
	return column * size, (column + 1) * size, row * size, (row + 1) * size
end
