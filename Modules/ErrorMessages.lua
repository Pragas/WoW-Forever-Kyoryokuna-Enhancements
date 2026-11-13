-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Error messages: the red messages in the middle of the screen ("Spell is not ready yet", "Not enough
-- mana", "Out of range"...) are sent by the game to one frame of its own (UIErrorsFrame), which shows
-- them and plays their sound or voice. With the filter on, the addon takes that event instead and hands on
-- the messages not hidden; of a hidden one only the text is gone: the addon plays its sound itself.
-- Nothing protected is touched, so it works in combat.
--
-- A message is told by its type (LE_GAME_ERR_...) or by its text (the game's own strings, in the game's
-- language): many spell failures share one type, only their text tells them apart.

local _, ns = ...

local ErrorMessages = {}
ns.ErrorMessages = ErrorMessages

-- The kinds that can be hidden: the game's types (without LE_GAME_ERR_) and texts (global strings).
-- Names a version of the game doesn't have are simply skipped.
local KINDS = {
	{key = "cooldown",
		types = {"SPELL_COOLDOWN", "ABILITY_COOLDOWN", "ITEM_COOLDOWN"},
		texts = {"ERR_SPELL_COOLDOWN", "ERR_ABILITY_COOLDOWN", "ERR_ITEM_COOLDOWN", "SPELL_FAILED_NOT_READY",
			"SPELL_FAILED_ITEM_NOT_READY"}},
	{key = "power",
		types = {"OUT_OF_MANA", "OUT_OF_RAGE", "OUT_OF_ENERGY", "OUT_OF_FOCUS", "OUT_OF_COMBO_POINTS"},
		texts = {"ERR_OUT_OF_MANA", "ERR_OUT_OF_RAGE", "ERR_OUT_OF_ENERGY", "ERR_OUT_OF_FOCUS", "ERR_OUT_OF_COMBO_POINTS",
			"SPELL_FAILED_NO_POWER", "SPELL_FAILED_NO_COMBO_POINTS"}},
	{key = "range",
		types = {"OUT_OF_RANGE", "SPELL_OUT_OF_RANGE"},
		texts = {"ERR_OUT_OF_RANGE", "ERR_SPELL_OUT_OF_RANGE", "SPELL_FAILED_OUT_OF_RANGE", "SPELL_FAILED_TOO_CLOSE"}},
	{key = "sight",
		types = {},
		texts = {"SPELL_FAILED_LINE_OF_SIGHT"}},
	{key = "facing",
		types = {"BADATTACKFACING", "BADATTACKPOS"},
		texts = {"ERR_BADATTACKFACING", "ERR_BADATTACKPOS", "SPELL_FAILED_UNIT_NOT_INFRONT", "SPELL_FAILED_UNIT_NOT_BEHIND"}},
	{key = "target",
		types = {"GENERIC_NO_TARGET", "NO_ATTACK_TARGET", "INVALID_ATTACK_TARGET", "GENERIC_NO_VALID_TARGETS"},
		texts = {"ERR_GENERIC_NO_TARGET", "ERR_NO_ATTACK_TARGET", "ERR_INVALID_ATTACK_TARGET", "SPELL_FAILED_BAD_TARGETS",
			"SPELL_FAILED_BAD_IMPLICIT_TARGETS", "SPELL_FAILED_TARGETS_DEAD", "SPELL_FAILED_NO_VALID_TARGETS",
			"SPELL_FAILED_TARGET_FRIENDLY", "SPELL_FAILED_TARGET_ENEMY"}},
	{key = "busy",
		types = {"SPELL_FAILED_ANOTHER_IN_PROGRESS"},
		texts = {"SPELL_FAILED_SPELL_IN_PROGRESS", "ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS", "SPELL_FAILED_NOT_IN_CONTROL"}},
	{key = "moving",
		types = {},
		texts = {"SPELL_FAILED_MOVING", "ERR_SPELL_FAILED_MOVING"}},
}
ErrorMessages.KINDS = KINDS

local function Settings()
	return ns.db.errorMessages
end

-- The kind of a message (its key), or nil
local byType, byText
local function KindOf(messageType, message)
	if not byType then
		byType, byText = {}, {}
		for _, kind in ipairs(KINDS) do
			for _, name in ipairs(kind.types) do
				local value = _G["LE_GAME_ERR_" .. name]
				if value ~= nil then byType[value] = kind.key end
			end
			for _, name in ipairs(kind.texts) do
				local value = _G[name]
				if type(value) == "string" then byText[value] = kind.key end
			end
		end
	end
	return (messageType ~= nil and byType[messageType]) or (message ~= nil and byText[message]) or nil
end

local function InCombat()
	return (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and ns.Known(UnitAffectingCombat("player")) == true) or false
end

-- Whether this message is hidden now
function ErrorMessages.IsHidden(messageType, message)
	local settings = Settings()
	if not settings.enabled then return false end
	if settings.onlyInCombat and not InCombat() then return false end
	if settings.hideAll then return true end
	local kind = KindOf(ns.Known(messageType), ns.Known(message))
	return kind ~= nil and settings[kind] == true
end

-- The game's frame, given back the messages not hidden (shown and spoken as the game does)
local function HandOn(messageType, message)
	local frame = UIErrorsFrame
	if not frame then return end
	if frame.TryDisplayMessage then
		local r, g, b = 1, 0.1, 0.1
		if RED_FONT_COLOR and RED_FONT_COLOR.GetRGB then r, g, b = RED_FONT_COLOR:GetRGB() end
		frame:TryDisplayMessage(messageType, message, r, g, b)
	else
		frame:AddMessage(message, 1, 0.1, 0.1, 1.0)
	end
end

-- The game's setting for the voice of the messages, as "1" (on) or "0" (off); on when it can't be read,
-- as the game has it at first
local function ReadVoice()
	local value = C_CVar.GetCVar and C_CVar.GetCVar("Sound_EnableErrorSpeech")
	if value == "0" or value == "1" then return value end
	if C_CVar.GetCVarBool then
		local on = C_CVar.GetCVarBool("Sound_EnableErrorSpeech")
		if on ~= nil then return on and "1" or "0" end
	end
	return "1"
end

-- The filter on: the addon takes the game's red messages; off: the game's frame has them again
local taking = false
local function Apply()
	if not ns.db then return end
	local frame = UIErrorsFrame
	local wanted = Settings().enabled == true
	if frame and wanted ~= taking then
		if wanted then frame:UnregisterEvent("UI_ERROR_MESSAGE") else frame:RegisterEvent("UI_ERROR_MESSAGE") end
		taking = wanted
	end
	-- The voice of the messages kept (the game's own setting): silenced, or put back as it was. The value
	-- it had before the addon silenced it is kept in the saved data, so turning the option off, another
	-- day too, brings back exactly that: still off for a player who had it off in the game's options.
	-- Versions before 0.19.1 only noted that the addon had silenced it (errorVoiceMuted): the value then
	-- is unknown, so the voice comes back, as they did.
	local settings = Settings()
	if C_CVar and C_CVar.SetCVar then
		if settings.enabled and settings.muteVoice then
			if ns.db.errorVoiceBefore == nil then
				ns.db.errorVoiceBefore = ns.db.errorVoiceMuted and "1" or ReadVoice()
			end
			ns.db.errorVoiceMuted = nil
			C_CVar.SetCVar("Sound_EnableErrorSpeech", "0")
		elseif ns.db.errorVoiceBefore ~= nil or ns.db.errorVoiceMuted then
			local before = ns.db.errorVoiceBefore or "1"
			ns.db.errorVoiceBefore, ns.db.errorVoiceMuted = nil, nil
			C_CVar.SetCVar("Sound_EnableErrorSpeech", before)
		end
	end
end
ErrorMessages.Apply = Apply

-- A hidden message still makes its sound, as the game's frame would: its voice ("Not enough mana"), or
-- else its sound. The voice follows the game's own setting (silenced by "Silence the voice")
local function PlaySoundOf(messageType)
	if not GetGameMessageInfo then return end
	local ok, _, soundKitID, voiceID = pcall(GetGameMessageInfo, messageType)
	if not ok then return end
	if voiceID and C_Sound and C_Sound.PlayVocalErrorSound then
		pcall(C_Sound.PlayVocalErrorSound, voiceID)
	elseif soundKitID and PlaySound then
		pcall(PlaySound, soundKitID)
	end
end

ns.RegisterEvent("UI_ERROR_MESSAGE", function(_, messageType, message)
	if not taking then return end
	if ErrorMessages.IsHidden(messageType, message) then
		-- Only the text is hidden: the sound plays as usual
		PlaySoundOf(messageType)
		return
	end
	HandOn(messageType, message)
end)

ns.RegisterEvent("PLAYER_LOGIN", function() ns.SafeCall(Apply) end)

function ErrorMessages.IsTaking()
	return taking
end
