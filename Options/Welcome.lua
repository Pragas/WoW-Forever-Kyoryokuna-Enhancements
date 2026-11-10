-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The welcome window: over the options window when it opens, the first time the addon is used (what it
-- is, how to start) and after each update (what's new and what was fixed since the version last seen),
-- with the known issues under it. Its OK shows the General page, and it doesn't come back until the next
-- version. The About page can show it again. What it says comes from Core\ReleaseNotes.lua.

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local CONTENT_WIDTH = 540
local ICON_SIZE = 64
local GREY = {0.75, 0.75, 0.75}
local LABEL = {1, 0.82, 0}
local BULLET_INDENT = 10

local INTRO = "Kyoryokuna Enhancements brings small improvements to the game: the buffs and conjured items you're missing, action bars, the experience bar, the time left to enter a battleground, and a dark mode. Everything starts off, for you to turn on what you want."

local function Bullets(b, list, color)
	for _, item in ipairs(list or {}) do
		b:Text("•  " .. L[item], color, true, BULLET_INDENT)
	end
end

local function Fill(b, state, notes)
	-- The emblem, the name and the version
	local head = b:Area(ICON_SIZE + 4)
	local icon = head:CreateTexture(nil, "ARTWORK")
	icon:SetTexture(ns.ICON)
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("TOPLEFT", head, "TOPLEFT", 0, 0)
	local title = head:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 14, -10)
	title:SetText(ns.TITLE)
	local version = head:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	version:SetText(string.format(L["Version %s"], ns.VERSION))

	b:Text(INTRO, GREY)

	if state == "first" then
		b:Header("Getting started")
		Bullets(b, {
			"Each page on the left is one feature: turn it on at the top of its page, then set it up.",
			"Missing Buffs: tick what your character should always have, then Move to put the icons in place (the button beside the X shrinks this window meanwhile).",
			"Import / Export keeps backups of your settings and shares them with a code.",
		})
	else
		for _, entry in ipairs(notes or {}) do
			b:Header(string.format(L["What's new in %s"], entry.version), true)
			if entry.new and #entry.new > 0 then
				b:Text("New", LABEL)
				Bullets(b, entry.new)
			end
			if entry.fixed and #entry.fixed > 0 then
				b:Text("Fixed", LABEL)
				Bullets(b, entry.fixed)
			end
		end
	end

	if #ns.KNOWN_ISSUES > 0 then
		b:Header("Known issues")
		b:Text("Limits of the game itself, which no addon can get around:", GREY)
		Bullets(b, ns.KNOWN_ISSUES, GREY)
	end
end

-- Shows the window over the options window (made again each time, with what's to show now)
function ns.ShowWelcome(window, state, notes)
	if not window then return end
	if window.welcome then window.welcome:Hide() end

	local panel = CreateFrame("Frame", nil, window.body or window)
	panel:SetPoint("TOPLEFT", window, "TOPLEFT", 6, -40)
	panel:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -6, 6)
	panel:SetFrameLevel(window:GetFrameLevel() + 50)
	-- Over the pages and their buttons, which can't be clicked through it
	panel:EnableMouse(true)
	local background = panel:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints(panel)
	background:SetColorTexture(0.06, 0.06, 0.08, 1)
	window.welcome = panel

	local scroll = CreateFrame("ScrollFrame", nil, panel)
	scroll:SetPoint("TOP", panel, "TOP", 0, -6)
	scroll:SetPoint("BOTTOM", panel, "BOTTOM", 0, 52)
	scroll:SetWidth(CONTENT_WIDTH)
	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(CONTENT_WIDTH, 100)
	scroll:SetScrollChild(content)
	local b = W.NewBuilder(content)
	Fill(b, state, notes)
	content:SetHeight(b:Height())
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		local maxScroll = math.max(0, content:GetHeight() - self:GetHeight())
		self:SetVerticalScroll(math.min(maxScroll, math.max(0, self:GetVerticalScroll() - delta * 40)))
	end)

	local ok = W.SmallButton(panel, "OK", nil, function()
		ns.MarkWelcomeSeen()
		panel:Hide()
		if ns.SelectOptionsPage then ns.SelectOptionsPage(1) end
	end, 140)
	ok:SetHeight(26)
	ok:SetPoint("BOTTOM", panel, "BOTTOM", 0, 14)
	panel.ok = ok
	panel:Show()
	return panel
end

-- When the options window opens: the welcome window over it, if there's something new to show
function ns.CheckWelcome(window)
	local state, notes = ns.GetWelcomeState()
	if state then ns.ShowWelcome(window, state, notes) end
	return state ~= nil
end

-- The About page's button: what's new in every version listed, any time
function ns.ShowWhatsNew()
	ns.OpenOptions()
	local window = ns.GetOptionsWindow and ns.GetOptionsWindow()
	if window and not (window.welcome and window.welcome:IsShown()) then
		ns.ShowWelcome(window, "update", ns.RELEASE_NOTES)
	end
end
