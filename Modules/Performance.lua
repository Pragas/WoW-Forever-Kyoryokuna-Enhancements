-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- FPS and latency: a small text on the screen with the frames per second (GetFramerate) and the latency
-- of the connection (GetNetStats: home, the realm's chat and friends; world, the game world itself),
-- read once a second. It can be colored by how good each value is, have a dark background, and be moved
-- anywhere (the page's "Move"). The mouse goes through it, except while moving.

local _, ns = ...
local L = ns.L

local Performance = {}
ns.Performance = Performance

local WHITE = "Interface\\Buttons\\WHITE8X8"
-- How often the values are read (seconds)
local INTERVAL = 1

local frame, text
local moving = false
local elapsed = 0

local function Settings()
	return ns.db.performance
end

local function Round(value)
	return math.floor(value + 0.5)
end

-- The color of a value: green when good, yellow when so-so, red when bad
local function ColorOf(kind, value)
	if kind == "fps" then
		if value < 30 then return "ff5555" elseif value < 60 then return "ffcc44" end
	else
		if value > 200 then return "ff5555" elseif value > 100 then return "ffcc44" end
	end
	return "66dd88"
end
Performance.ColorOf = ColorOf

-- The values now: FPS, home latency, world latency (nil for one the game doesn't give)
function Performance.Read()
	local fps = GetFramerate and ns.Known(GetFramerate())
	local home, world
	if GetNetStats then
		local _, _, latencyHome, latencyWorld = GetNetStats()
		home, world = ns.Known(latencyHome), ns.Known(latencyWorld)
	end
	fps = type(fps) == "number" and Round(fps) or nil
	home = type(home) == "number" and Round(home) or nil
	world = type(world) == "number" and Round(world) or nil
	return fps, home, world
end

-- The text shown, for the settings now
function Performance.Format(fps, home, world)
	local settings = Settings()
	local parts = {}
	local function Add(kind, value, label, suffix)
		local shown = value and tostring(value) or "-"
		if settings.colors and value then shown = "|cff" .. ColorOf(kind, value) .. shown .. "|r" end
		parts[#parts + 1] = label .. shown .. suffix
	end
	if settings.show ~= "PING" then Add("fps", fps, "", " FPS") end
	if settings.show ~= "FPS" then
		if settings.ping == "BOTH" then
			Add("ping", home, L["Home"] .. " ", " ms")
			Add("ping", world, L["World"] .. " ", " ms")
		elseif settings.ping == "HOME" then
			Add("ping", home, "", " ms")
		else
			Add("ping", world, "", " ms")
		end
	end
	return table.concat(parts, "  /  ")
end

local function Refresh()
	if not text then return end
	text:SetText(Performance.Format(Performance.Read()))
	local width, height = text:GetStringWidth() or 0, text:GetStringHeight() or 0
	frame:SetSize(math.max(40, width + 16), math.max(18, height + 10))
end

local function GetFrame()
	if frame then return frame end
	frame = CreateFrame("Frame", "KyoryokunaEnhancementsPerformance", UIParent, "BackdropTemplate")
	frame:SetFrameStrata("MEDIUM")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(false)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if moving then self:StartMoving() end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		-- Kept as a distance from the middle of the screen
		local x, y = self:GetCenter()
		local centerX, centerY = UIParent:GetCenter()
		if x and centerX then
			local settings = Settings()
			settings.x, settings.y = Round(x - centerX), Round(y - centerY)
			ns.ValidateSettings()
		end
		ns.SafeCall(Performance.Update)
	end)
	text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.text = text
	-- While moving: a green frame and a hint above it
	frame.mover = frame:CreateTexture(nil, "BACKGROUND")
	frame.mover:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
	frame.mover:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
	frame.mover:SetColorTexture(0.18, 0.8, 0.44, 0.35)
	frame.mover:Hide()
	frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.hint:SetPoint("BOTTOM", frame, "TOP", 0, 8)
	frame.hint:Hide()
	frame:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + (delta or 0)
		if elapsed >= INTERVAL then
			elapsed = 0
			ns.SafeCall(Refresh)
		end
	end)
	frame:Hide()
	return frame
end

-- Shown or hidden, and its look and place, for the settings now
function Performance.Update()
	if not ns.db then return end
	local settings = Settings()
	if not settings.enabled then
		moving = false
		if frame then frame:Hide() end
		return
	end
	local display = GetFrame()
	local path = (GameFontHighlight and GameFontHighlight:GetFont()) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
	-- An outline only without the background, where the text sits on the game's world
	text:SetFont(path, settings.size, settings.background and "" or "OUTLINE")
	text:SetTextColor(ns.Unpack(settings.color))
	if settings.background then
		display:SetBackdrop({
			bgFile = WHITE, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 12, insets = {left = 3, right = 3, top = 3, bottom = 3},
		})
		display:SetBackdropColor(0.04, 0.04, 0.05, 0.8)
		display:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	else
		display:SetBackdrop(nil)
	end
	display:ClearAllPoints()
	display:SetPoint("CENTER", UIParent, "CENTER", settings.x, settings.y)
	-- While moving: above the options window, and the mouse can take it
	display:SetFrameStrata(moving and "DIALOG" or "MEDIUM")
	display:EnableMouse(moving)
	display.mover:SetShown(moving)
	display.hint:SetShown(moving)
	display.hint:SetText(L["FPS and latency: drag to move"])
	display:Show()
	Refresh()
end

-- Moving the text (from the page; ends when the options close)
function Performance.SetMoving(on)
	moving = on and true or false
	ns.SafeCall(Performance.Update)
end

function Performance.IsMoving()
	return moving
end

-- For the tests
function Performance.GetFrame()
	return frame
end

ns.RegisterEvent("PLAYER_LOGIN", function() Performance.Update() end)
