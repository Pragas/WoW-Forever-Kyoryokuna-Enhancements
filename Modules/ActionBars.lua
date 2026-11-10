-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The game's action bars (Action Bars page):
--   - the key of each button and the name of macros can be hidden (made invisible: the game keeps
--     writing them, so they come back as they were when shown again);
--   - the cooldown numbers on the buttons get a size of their own, a percentage of the game's (the
--     game's option "Show cooldown numbers" has to be on for it to show them at all), and can be
--     colored by the time left (one color while long, another for the last seconds);
--   - pressing a button's key shows a short effect over the button (a flash, or a glowing border), drawn
--     on a frame of the addon's, so the game's buttons are never changed;
--   - the frame and background of the micro menu (the small buttons of the game's menus) can be hidden.

local _, ns = ...

local ActionBars = {}
ns.ActionBars = ActionBars

-- Every bar of the game, and its 12 buttons
local BUTTON_PREFIXES = {
	"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton",
	"MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button", "PetActionButton", "StanceButton",
}

local function ForEachButton(func)
	for _, prefix in ipairs(BUTTON_PREFIXES) do
		for i = 1, 12 do
			local button = _G[prefix .. i]
			if type(button) == "table" then ns.SafeCall(func, button, prefix .. i) end
		end
	end
end

local function SetShown(region, shown)
	if type(region) == "table" and region.SetAlpha then pcall(region.SetAlpha, region, shown and 1 or 0) end
end

-- Cooldown numbers: the game's font of each, kept the first time, and that size times the setting
local function ScaleCooldown(button, name, scale)
	local cooldown = button.cooldown or _G[name .. "Cooldown"]
	if type(cooldown) ~= "table" or not cooldown.GetCountdownFontString then return end
	local text = cooldown:GetCountdownFontString()
	if type(text) ~= "table" or not text.GetFont then return end
	if not text.keFont then
		local path, size, flags = text:GetFont()
		size = ns.Known(size)
		if not path or type(size) ~= "number" then return end
		text.keFont = {path = path, size = size, flags = flags or ""}
	end
	local font = text.keFont
	pcall(text.SetFont, text, font.path, font.size * scale / 100, font.flags)
end

-- Cooldown numbers colored by the time left. The addon never reads the time itself (in combat the game
-- hides it from addons): it gives the game's countdown a formatter, a set of rules by time left, each
-- writing the number with its color, and the game writes the numbers with it. Like the game's own:
-- seconds rounded up, then minutes, then hours.
local MINUTE, HOUR = 60, 3600

local function Hex(color)
	local function Byte(v) return math.floor(math.min(1, math.max(0, v or 1)) * 255 + 0.5) end
	return string.format("ff%02x%02x%02x", Byte(color[1]), Byte(color[2]), Byte(color[3]))
end

-- settings nil: the same numbers without colors (to put back when the game won't take "none")
local function ColoredFormatter(settings)
	if not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Enum and Enum.NumericRuleFormatRounding) then return nil end
	local up = Enum.NumericRuleFormatRounding.Up
	local long, short, close, threshold = "", "", "", 5
	if settings then
		long = "|c" .. Hex(settings.cooldownColorLong)
		short = "|c" .. Hex(settings.cooldownColorShort)
		close = "|r"
		threshold = math.min(settings.cooldownColorThreshold, MINUTE - 1)
	end
	local breakpoints = {
		{threshold = 0, step = 1, rounding = up, format = short .. "%d" .. close},
		{threshold = threshold, step = 1, rounding = up, format = long .. "%d" .. close},
		{threshold = MINUTE, format = long .. "%dm" .. close, components = {{div = MINUTE, rounding = up, step = 1}}},
		{threshold = HOUR, format = long .. "%dh" .. close, components = {{div = HOUR, rounding = up, step = 1}}},
	}
	local ok, formatter = pcall(C_StringUtil.CreateNumericRuleFormatter)
	if not ok or not formatter then return nil end
	if not pcall(formatter.SetBreakpoints, formatter, breakpoints) then return nil end
	return formatter
end

-- The cooldowns given a formatter, to give them back the game's own when it's turned off
local colored = setmetatable({}, {__mode = "k"})

local function ColorCooldown(button, name, formatter)
	local cooldown = button.cooldown or _G[name .. "Cooldown"]
	if type(cooldown) ~= "table" or not cooldown.SetCountdownFormatter then return end
	if formatter then
		if pcall(cooldown.SetCountdownFormatter, cooldown, formatter) then colored[cooldown] = true end
	elseif colored[cooldown] then
		if not pcall(cooldown.SetCountdownFormatter, cooldown, nil) then
			local plain = ColoredFormatter(nil)
			if plain then pcall(cooldown.SetCountdownFormatter, cooldown, plain) end
		end
		colored[cooldown] = nil
	end
end

-- Key press effect -----------------------------------------------------------------------------------

local STYLES = {
	-- A white flash over the whole button, fading out
	FLASH = {texture = "Interface\\Buttons\\WHITE8X8", blend = "ADD", alpha = 0.55, inset = 0, grow = 1},
	-- A golden glowing border around the button, growing a little as it fades
	BORDER = {texture = "Interface\\Buttons\\UI-ActionButton-Border", blend = "ADD", alpha = 1, inset = -14, grow = 1.15},
}
local EFFECT_TIME = 0.25

-- One effect per button, made the first time its key is pressed
local effects = setmetatable({}, {__mode = "k"})

local function GetEffect(button)
	local effect = effects[button]
	if effect then return effect end
	effect = CreateFrame("Frame", nil, UIParent)
	effect:SetFrameStrata("HIGH")
	effect.texture = effect:CreateTexture(nil, "OVERLAY")
	effect.texture:SetAllPoints(effect)
	effect:Hide()
	effect:SetScript("OnUpdate", function(self, elapsed)
		self.left = self.left - elapsed
		if self.left <= 0 then
			self:Hide()
			return
		end
		local progress = 1 - self.left / EFFECT_TIME
		self.texture:SetAlpha(self.style.alpha * (1 - progress))
		self:SetScale(1 + (self.style.grow - 1) * progress)
	end)
	effects[button] = effect
	return effect
end

local function PlayEffect(button)
	local settings = ns.db and ns.db.actionBars
	if not (settings and settings.keyPress) or type(button) ~= "table" then return end
	if not (button.IsVisible and button:IsVisible()) then return end
	local style = STYLES[settings.keyPressStyle] or STYLES.FLASH
	local effect = GetEffect(button)
	effect.style = style
	effect:ClearAllPoints()
	effect:SetPoint("TOPLEFT", button, "TOPLEFT", style.inset, -style.inset)
	effect:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -style.inset, style.inset)
	effect.texture:SetTexture(style.texture)
	effect.texture:SetBlendMode(style.blend)
	effect.texture:SetAlpha(style.alpha)
	effect:SetScale(1)
	effect.left = EFFECT_TIME
	effect:Show()
end
ActionBars.PlayEffect = PlayEffect

-- The game calls these when a bar's key is pressed down
local hooked = false
local function HookKeyPresses()
	if hooked then return end
	hooked = true
	if ActionButtonDown and GetActionButtonForID then
		hooksecurefunc("ActionButtonDown", function(id)
			ns.SafeCall(PlayEffect, GetActionButtonForID(id))
		end)
	end
	if MultiActionButtonDown then
		hooksecurefunc("MultiActionButtonDown", function(bar, id)
			ns.SafeCall(PlayEffect, _G[tostring(bar) .. "Button" .. tostring(id)])
		end)
	end
	if PetActionButtonDown then
		hooksecurefunc("PetActionButtonDown", function(id)
			ns.SafeCall(PlayEffect, _G["PetActionButton" .. tostring(id)])
		end)
	end
end

-- Applying -------------------------------------------------------------------------------------------

function ActionBars.Apply()
	if not ns.db then return end
	local settings = ns.db.actionBars
	local formatter = settings.cooldownColors and ColoredFormatter(settings) or nil
	ForEachButton(function(button, name)
		SetShown(button.HotKey or _G[name .. "HotKey"], not settings.hideKeybinds)
		SetShown(button.Name or _G[name .. "Name"], not settings.hideMacroNames)
		-- The formatter first: the game may make the number's text again when it gets one
		ColorCooldown(button, name, formatter)
		ScaleCooldown(button, name, settings.cooldownScale)
	end)
	local microMenu = _G.MicroMenu
	if type(microMenu) == "table" then
		SetShown(microMenu.BorderArt, not settings.hideMicroMenuBorder)
		SetShown(microMenu.BackgroundArt, not settings.hideMicroMenuBorder)
	end
	if settings.keyPress then HookKeyPresses() end
end

-- After the game made its bars, and again when the bars change (a new page, a vehicle, a form)
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UPDATE_BONUS_ACTIONBAR", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BINDINGS"}) do
	ns.RegisterEvent(event, function() ActionBars.Apply() end)
end
