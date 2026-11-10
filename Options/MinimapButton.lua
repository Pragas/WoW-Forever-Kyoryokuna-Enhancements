-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The button on the edge of the minimap. A click opens or closes the options; dragging it moves it
-- around the minimap, and the place is kept. It can be hidden on the General page.

local _, ns = ...
local L = ns.L

local BUTTON_SIZE = 31
-- How far out from the edge of the minimap the button sits
local EDGE_OFFSET = 10

local button

local function PlaceButton()
	local angle = math.rad(ns.db.general.minimapAngle)
	local radius = (Minimap:GetWidth() / 2) + EDGE_OFFSET
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

-- While dragging, the button follows the cursor around the minimap
local function FollowCursor()
	local centerX, centerY = Minimap:GetCenter()
	local cursorX, cursorY = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	local angle = math.deg(math.atan2(cursorY / scale - centerY, cursorX / scale - centerX)) % 360
	ns.db.general.minimapAngle = angle
	PlaceButton()
end

local function CreateButton()
	button = CreateFrame("Button", "KyoryokunaEnhancementsMinimapButton", Minimap)
	button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetSize(20, 20)
	background:SetPoint("CENTER", button, "CENTER", 0, 1)

	local icon = button:CreateTexture(nil, "ARTWORK")
	-- The addon's emblem, cut round to fit the minimap button's ring
	icon:SetTexture(ns.ICON_SMALL)
	icon:SetSize(20, 20)
	icon:SetPoint("CENTER", button, "CENTER", 0, 1)
	if icon.SetMask then
		pcall(icon.SetMask, icon, "Interface\\CharacterFrame\\TempPortraitAlphaMask")
	end

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(53, 53)
	border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	button:SetScript("OnClick", function()
		ns.ToggleOptions()
	end)
	button:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", FollowCursor)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(ns.TITLE)
		GameTooltip:AddLine(L["Click to open the options."], 1, 1, 1)
		GameTooltip:AddLine(L["Drag to move this button."], 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function ns.UpdateMinimapButton()
	if not ns.db or not Minimap then return end
	if not ns.db.general.minimapIcon then
		if button then button:Hide() end
		return
	end
	if not button then CreateButton() end
	PlaceButton()
	button:Show()
end

ns.RegisterEvent("PLAYER_LOGIN", ns.UpdateMinimapButton)
