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

-- The game's spell alert art
local ART = {
	ARCANE_MISSILES = 449486,
	FROZEN_FINGERS = 449489,
	GENERIC_ARC_05 = 450921,
	HOT_STREAK = 449490,
}

-- Both sides: the left as it is, the right mirrored
local BOTH_SIDES = {"LEFT", "RIGHT_FLIPPED"}

-- The procs of each class: the setting that turns it on, the aura (spell ID in WoW Forever), a name for
-- when the game doesn't give one, and its art: {stacks (nil: any; a number: exactly that many), art,
-- sides, scale, shade (0-255, grey to white), pulse}
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
}
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

-- The frame the art goes around: in the middle of the screen, as wide as the distance asked
local function GetHolder()
	if holder then return holder end
	holder = CreateFrame("Frame", "KyoryokunaEnhancementsProcAlerts", UIParent)
	holder:SetFrameStrata("LOW")
	holder:EnableMouse(false)
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
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, settings.y)
	frame:SetAlpha(settings.opacity / 100)
end

-- A piece of art on its side of the holder, with its size
local function Place(frame, side, scale)
	local long, short = Geometry()
	frame:ClearAllPoints()
	frame:SetSize(short * scale, long * scale)
	if side == "LEFT" then
		frame:SetPoint("RIGHT", GetHolder(), "LEFT", 0, 0)
	else
		frame:SetPoint("LEFT", GetHolder(), "RIGHT", 0, 0)
	end
end

local function Paint(texture, overlay, side)
	texture:SetTexture(overlay.art)
	if side == "RIGHT_FLIPPED" then texture:SetTexCoord(1, 0, 0, 1) else texture:SetTexCoord(0, 1, 0, 1) end
	local shade = (overlay.shade or 255) / 255
	texture:SetVertexColor(shade, shade, shade, 1)
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
			local ok, button = pcall(frame.AddAuraSlot, frame, slot.key, "HELPFUL", {
				templateNames = {"KyoryokunaEnhancementsProcAuraTemplate"},
				initializeFrame = function(made) slot.button = made; SetUpSlot(made, slot) end,
				candidateFilters = {includeSpellIDs = {[effect.spell] = true}},
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
		effect.byGame = IsSecret(effect.spell) and MakeSlots(effect) or false
	end
end

local function ReadStacks(spell)
	if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return nil end
	local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spell)
	if not ok or type(aura) ~= "table" then return nil end
	local stacks = Known(aura.applications)
	if type(stacks) ~= "number" or stacks < 1 then stacks = 1 end
	return stacks
end

-- The addon's own art, from the auras it can read (on every change of the character's auras)
function ProcAlerts.UpdateAuras()
	if not ns.db or testing then return end
	local settings = Settings()
	local wanted = {}
	if settings.enabled then
		for _, effect in ipairs(ProcAlerts.GetEffects()) do
			if not effect.byGame and settings[effect.key] == true then
				local stacks = ReadStacks(effect.spell)
				if stacks then
					for index, overlay in ipairs(effect.overlays) do
						if Matches(overlay, stacks) then ShowOwn(effect, index, overlay, wanted) end
					end
				end
			end
		end
	end
	HideOwn(wanted)
end

-- Everything as the settings say now (place, size, opacity, which procs), then the auras
function ProcAlerts.Update()
	if not ns.db then return end
	local settings = Settings()
	ApplyHolder()
	if not settings.enabled and not testing then
		GetHolder():Hide()
		HideOwn()
		for _, slot in ipairs(slots) do
			if container and container.SetAuraSlotEnabled then pcall(container.SetAuraSlotEnabled, container, slot.key, false) end
		end
		return
	end
	GetHolder():Show()
	Prepare()
	-- The game's: each one on or off, and fitted to the size (off during the test, which shows them all)
	for _, slot in ipairs(slots) do
		local on = settings.enabled and settings[slot.effect.key] == true and not testing
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
	testing = true
	ProcAlerts.Update()
	local step = 0
	local function Next()
		step = step + 1
		HideOwn()
		local effect = effects[step]
		if not effect then
			testing = false
			label:Hide()
			testTimer = nil
			ProcAlerts.Update()
			return
		end
		local most = 1
		for _, overlay in ipairs(effect.overlays) do most = math.max(most, overlay.stacks or 1) end
		local wanted = {}
		for index, overlay in ipairs(effect.overlays) do
			if Matches(overlay, most) then ShowOwn(effect, index, overlay, wanted) end
		end
		label:SetText(ProcAlerts.SpellName(effect))
		label:Show()
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
