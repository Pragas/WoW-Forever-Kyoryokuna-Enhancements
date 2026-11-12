-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The controls of the options window, built from the game's basic textures so they don't depend on
-- templates that change between game versions: check boxes, sliders, color swatches, dropdowns,
-- buttons, headers and texts. A page is written with a builder that places each control under the
-- previous one, e.g. builder:Check("enemy.classColor", "Class color").
--
-- A control can depend on others (e.g. the arrow color only matters with the arrow on): it's greyed out
-- while the condition isn't met.

local _, ns = ...
local L = ns.L

local Widgets = {}
ns.Widgets = Widgets

local CONTENT_WIDTH = 540
local LEFT = 16
local INDENT = 22

-- The vertical rhythm of a page: how much room each kind of control takes, and the space around the
-- headers of the sections (more above, so a section starts clearly apart from the one before)
local SPACE_ABOVE_HEADER = 22
local HEADER_HEIGHT = 34
local CHECK_HEIGHT = 28
local SLIDER_HEIGHT = 48
local DROPDOWN_HEIGHT = 52
local COLOR_HEIGHT = 32
local BUTTON_HEIGHT = 34
local TEXT_GAP = 10
-- Where the "Default" buttons of the colors start, so they line up whatever the label's length
local COLOR_RESET_X = 300
local WHITE = "Interface\\Buttons\\WHITE8X8"

local allControls = {}

local function ShowTooltip(owner, title, text)
	if not text then return end
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:SetText(title, 1, 0.82, 0)
	GameTooltip:AddLine(text, 1, 1, 1, true)
	GameTooltip:Show()
end

local function HideTooltip()
	GameTooltip:Hide()
end

-- Buttons ------------------------------------------------------------------------------------------

-- The addon's own buttons, like the X of its window: a dark box with a thin grey border, lighter under
-- the mouse, with gold text (a dropdown: its value in white, and a small gold arrow). Made of plain
-- colors, so they never depend on the game's button art (on this client a thin red bar) nor on its
-- size. A text too long for the button is cut with "...", never runs out of it.
local BORDER_COLOR = {0.6, 0.6, 0.6, 1}
local FILL_COLOR = {0.12, 0.12, 0.14, 1}
local ARROW_COLOR = {1, 0.82, 0, 1}

local function NewButton(parent, width, height, font)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width, height)
	local border = button:CreateTexture(nil, "BACKGROUND")
	border:SetAllPoints(button)
	border:SetColorTexture(unpack(BORDER_COLOR))
	local fill = button:CreateTexture(nil, "BORDER")
	fill:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	fill:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	fill:SetColorTexture(unpack(FILL_COLOR))
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(fill)
	highlight:SetColorTexture(1, 1, 1, 0.15)
	local text = button:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
	button:SetFontString(text)
	text:ClearAllPoints()
	text:SetPoint("LEFT", button, "LEFT", 6, 0)
	text:SetPoint("RIGHT", button, "RIGHT", -6, 0)
	text:SetWordWrap(false)
	button:SetPushedTextOffset(1, -1)
	button.label = text
	return button
end
Widgets.NewButton = NewButton

-- A dropdown's button: the value on the left, an arrow pointing down on the right (two gold bars)
local function NewDropdownButton(parent, width, height, font)
	local button = NewButton(parent, width, height, font or "GameFontHighlight")
	local text = button.label
	text:ClearAllPoints()
	text:SetPoint("LEFT", button, "LEFT", 8, 0)
	text:SetPoint("RIGHT", button, "RIGHT", -22, 0)
	text:SetJustifyH("LEFT")
	for _, side in ipairs({-1, 1}) do
		local bar = button:CreateTexture(nil, "ARTWORK")
		bar:SetSize(6, 2)
		bar:SetPoint("CENTER", button, "RIGHT", -11 + side * 2, 0)
		bar:SetColorTexture(unpack(ARROW_COLOR))
		if bar.SetRotation then bar:SetRotation(math.rad(side * 45)) end
	end
	return button
end

local function SetControlEnabled(control, enabled)
	control.frame:SetAlpha(enabled and 1 or 0.4)
	for _, region in ipairs(control.interactive or {}) do
		if region.Enable and region.Disable then
			if enabled then region:Enable() else region:Disable() end
		elseif region.EnableMouse then
			region:EnableMouse(enabled)
		end
	end
end

function Widgets.RefreshAll()
	for _, control in ipairs(allControls) do
		if control.frame:IsVisible() or control.alwaysRefresh then
			if control.Refresh then control:Refresh() end
			if control.dependsOn then
				SetControlEnabled(control, control.dependsOn())
			end
		end
	end
end

local function Register(control, dependsOn)
	control.dependsOn = dependsOn
	allControls[#allControls + 1] = control
	return control
end

-- Check box ----------------------------------------------------------------------------------------

local function CreateCheckButton(parent)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetSize(24, 24)
	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	return check
end

-- Slider -------------------------------------------------------------------------------------------

local function Round(value, step)
	return math.floor(value / step + 0.5) * step
end

local function FormatNumber(value, step)
	if step < 1 then return string.format("%.1f", value) end
	return tostring(math.floor(value + 0.5))
end

-- A box to type a slider's value (one shared box), opened with a right click on the slider. Enter keeps
-- the value, rounded to the slider's step and brought inside its limits; Escape or a click elsewhere
-- closes it without a change.
local valueBox

local function CloseValueBox()
	if valueBox then
		valueBox.onAccept = nil
		valueBox:ClearFocus()
		valueBox:Hide()
	end
end

local function CreateValueBox()
	valueBox = CreateFrame("EditBox", nil, UIParent, "BackdropTemplate")
	valueBox:SetFrameStrata("FULLSCREEN_DIALOG")
	valueBox:SetSize(70, 22)
	valueBox:SetAutoFocus(false)
	valueBox:SetFontObject("GameFontHighlight")
	valueBox:SetJustifyH("CENTER")
	valueBox:SetMaxLetters(8)
	valueBox:SetTextInsets(4, 4, 0, 0)
	valueBox:SetBackdrop({
		bgFile = WHITE, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10, insets = {left = 2, right = 2, top = 2, bottom = 2},
	})
	valueBox:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
	valueBox:SetBackdropBorderColor(1, 0.82, 0, 1)
	valueBox.limits = valueBox:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	valueBox.limits:SetPoint("TOP", valueBox, "BOTTOM", 0, -2)
	valueBox:SetScript("OnEnterPressed", function(self)
		local onAccept = self.onAccept
		-- "1,5" works like "1.5", and a typed "%" is ignored
		local value = tonumber((self:GetText():gsub(",", "."):gsub("[%s%%]", "")))
		CloseValueBox()
		if onAccept and value then onAccept(value) end
	end)
	valueBox:SetScript("OnEscapePressed", CloseValueBox)
	valueBox:SetScript("OnEditFocusLost", CloseValueBox)
	-- Closed with the options window (or the page) it was opened from
	valueBox:SetScript("OnUpdate", function(self)
		if self.anchor and not self.anchor:IsVisible() then CloseValueBox() end
	end)
	valueBox:Hide()
end

local function OpenValueBox(anchor, value, minValue, maxValue, step, onAccept)
	if not valueBox then CreateValueBox() end
	valueBox.onAccept = onAccept
	valueBox.anchor = anchor
	valueBox.limits:SetText(FormatNumber(minValue, step) .. " - " .. FormatNumber(maxValue, step))
	valueBox:ClearAllPoints()
	valueBox:SetPoint("LEFT", anchor, "RIGHT", 6, 0)
	valueBox:SetText(FormatNumber(value, step))
	valueBox:Show()
	valueBox:SetFocus()
	valueBox:HighlightText()
end

-- Dropdown list (one shared popup) -----------------------------------------------------------------

local popup, catcher
local POPUP_ROWS = 12
local ROW_HEIGHT = 22

local function ClosePopup()
	if popup then popup:Hide() end
	if catcher then catcher:Hide() end
end

local function CreatePopup()
	catcher = CreateFrame("Button", nil, UIParent)
	catcher:SetAllPoints(UIParent)
	catcher:SetFrameStrata("FULLSCREEN_DIALOG")
	catcher:SetScript("OnClick", ClosePopup)
	catcher:Hide()

	-- In the buttons' style: a dark box with a thin grey border
	popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	popup:SetFrameStrata("FULLSCREEN_DIALOG")
	popup:SetFrameLevel(catcher:GetFrameLevel() + 10)
	popup:SetBackdrop({bgFile = WHITE, edgeFile = WHITE, edgeSize = 1})
	popup:SetBackdropColor(0.08, 0.08, 0.1, 0.97)
	popup:SetBackdropBorderColor(unpack(BORDER_COLOR))
	popup:EnableMouseWheel(true)
	popup.rows = {}
	for i = 1, POPUP_ROWS do
		local row = CreateFrame("Button", nil, popup)
		row:SetHeight(ROW_HEIGHT)
		row:SetPoint("TOPLEFT", popup, "TOPLEFT", 4, -4 - (i - 1) * ROW_HEIGHT)
		row:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -4, -4 - (i - 1) * ROW_HEIGHT)
		row:SetHighlightTexture(WHITE)
		row:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.15)
		row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		row.text:SetWordWrap(false)
		row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
		row.text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
		row.text:SetJustifyH("LEFT")
		popup.rows[i] = row
	end
	popup:Hide()
end

local function FillPopup()
	local options = popup.options
	for i, row in ipairs(popup.rows) do
		local option = options[i + popup.offset]
		if option then
			local selected = option.value == popup.current
			row.text:SetText((selected and "|cffffd100" or "") .. option.text)
			row:SetScript("OnClick", function()
				ClosePopup()
				popup.onSelect(option.value)
			end)
			row:Show()
		else
			row:Hide()
		end
	end
end

local function OpenPopup(anchor, options, current, onSelect)
	if not popup then CreatePopup() end
	popup.options = options
	popup.current = current
	popup.onSelect = onSelect
	popup.offset = 0
	local rows = math.min(#options, POPUP_ROWS)
	popup:SetSize(math.max(anchor:GetWidth(), 160), rows * ROW_HEIGHT + 8)
	popup:ClearAllPoints()
	popup:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
	popup:SetScript("OnMouseWheel", function(self, delta)
		local maxOffset = math.max(0, #self.options - POPUP_ROWS)
		self.offset = math.min(maxOffset, math.max(0, self.offset - delta))
		FillPopup()
	end)
	FillPopup()
	catcher:Show()
	popup:Show()
end

-- Builder ------------------------------------------------------------------------------------------

local Builder = {}
Builder.__index = Builder

function Widgets.NewBuilder(content)
	return setmetatable({content = content, y = -12}, Builder)
end

function Builder:Space(height)
	self.y = self.y - (height or 8)
end

function Builder:Height()
	return -self.y + 16
end

-- raw: the text is shown as given (already translated, or built with numbers), not looked up
function Builder:Header(text, raw)
	-- The first header of a page sits at the top; the others leave room above them
	self:Space(self.hasContent and SPACE_ABOVE_HEADER or 2)
	self.hasContent = true
	local header = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	header:SetPoint("TOPLEFT", self.content, "TOPLEFT", LEFT, self.y)
	header:SetText(raw and text or L[text])
	local line = self.content:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(1, 0.82, 0, 0.35)
	line:SetHeight(1)
	line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
	line:SetWidth(CONTENT_WIDTH - LEFT * 2)
	self.y = self.y - HEADER_HEIGHT
end

function Builder:Text(text, color, raw, indent)
	local fontString = self.content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	local x = LEFT + (indent or 0)
	fontString:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, self.y)
	fontString:SetWidth(CONTENT_WIDTH - LEFT - x)
	fontString:SetJustifyH("LEFT")
	fontString:SetText(raw and text or L[text])
	if color then fontString:SetTextColor(unpack(color)) end
	self.y = self.y - math.max(14, fontString:GetStringHeight()) - TEXT_GAP
	self.hasContent = true
	return fontString
end

-- A check box bound to a setting
function Builder:Check(path, label, tooltip, dependsOn, indent)
	local x = LEFT + (indent and INDENT or 0)
	local check = CreateCheckButton(self.content)
	check:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, self.y)
	local text = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("LEFT", check, "RIGHT", 2, 0)
	text:SetText(L[label])
	check:SetHitRectInsets(0, -text:GetStringWidth() - 4, 0, 0)

	local control = {frame = check, interactive = {check}}
	function control:Refresh()
		check:SetChecked(ns.Get(path) and true or false)
	end
	check:SetScript("OnClick", function(self)
		ns.Set(path, self:GetChecked() and true or false)
	end)
	check:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	check:SetScript("OnLeave", HideTooltip)

	self.y = self.y - CHECK_HEIGHT
	self.hasContent = true
	return Register(control, dependsOn)
end

-- A check box with an icon, for a choice that isn't one setting (e.g. a spell of the character): get()
-- tells whether it's ticked, set(checked) keeps it. The label is shown as given (e.g. a spell's name,
-- already in the game's language). extras: small dropdowns on the right of the row, shown while it's
-- ticked: {{width, label, get, set, options = function() return {{value, text}} end}} (texts as given),
-- or a plain button {width, label, tooltip, text (or a function giving it), onClick}. The icon may be a
-- function giving it (asked again whenever the page is refreshed, e.g. the icon picked for a family).
function Builder:IconCheck(label, icon, get, set, tooltip, dependsOn, extras)
	local check = CreateCheckButton(self.content)
	check:SetPoint("TOPLEFT", self.content, "TOPLEFT", LEFT, self.y)
	local texture = check:CreateTexture(nil, "ARTWORK")
	texture:SetSize(20, 20)
	texture:SetPoint("LEFT", check, "RIGHT", 2, 0)
	texture:SetTexture(type(icon) == "function" and icon() or icon)
	texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	local text = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("LEFT", texture, "RIGHT", 6, 0)
	text:SetJustifyH("LEFT")
	text:SetText(label)

	local control = {frame = check, interactive = {check}, extras = {}}
	-- The dropdowns, from the right edge of the page to the left
	local right = CONTENT_WIDTH - LEFT
	for i = #(extras or {}), 1, -1 do
		local extra = extras[i]
		right = right - extra.width
		-- A plain button, or a dropdown (with its arrow)
		local button = extra.onClick and NewButton(self.content, extra.width, 20, "GameFontNormalSmall")
			or NewDropdownButton(self.content, extra.width, 20, "GameFontHighlightSmall")
		button:SetPoint("TOPLEFT", self.content, "TOPLEFT", right, self.y - 2)
		button:SetScript("OnClick", function(self)
			-- A plain button (a fixed text and an action), or a dropdown
			if extra.onClick then extra.onClick() return end
			OpenPopup(self, extra.options(), extra.get(), function(value) extra.set(value) end)
		end)
		button:SetScript("OnEnter", function(self) ShowTooltip(self, extra.label, extra.tooltip) end)
		button:SetScript("OnLeave", HideTooltip)
		button.extra = extra
		control.extras[#control.extras + 1] = button
		control.interactive[#control.interactive + 1] = button
		right = right - 6
	end
	-- A long name is cut rather than running under the dropdowns
	local labelX = LEFT + 24 + 2 + 20 + 6
	text:SetWidth(math.max(60, right - labelX - 4))
	text:SetWordWrap(false)
	check:SetHitRectInsets(0, -math.min(text:GetStringWidth(), right - labelX) - 32, 0, 0)

	function control:Refresh()
		local checked = get() and true or false
		check:SetChecked(checked)
		if type(icon) == "function" then texture:SetTexture(icon()) end
		for _, button in ipairs(self.extras) do
			local shown = button.extra.text
			if type(shown) == "function" then shown = shown() end
			if not shown then
				local current = button.extra.get()
				shown = tostring(current)
				for _, option in ipairs(button.extra.options()) do
					if option.value == current then shown = option.text break end
				end
			end
			button:SetText(shown)
			button:SetShown(checked)
		end
	end
	check:SetScript("OnClick", function(self)
		set(self:GetChecked() and true or false)
	end)
	check:SetScript("OnEnter", function(self) ShowTooltip(self, label, tooltip) end)
	check:SetScript("OnLeave", HideTooltip)

	self.y = self.y - CHECK_HEIGHT
	self.hasContent = true
	return Register(control, dependsOn)
end

-- A slider bound to a number setting; its limits come from the database
function Builder:Slider(path, label, step, suffix, tooltip, dependsOn, indent)
	local x = LEFT + 4 + (indent and INDENT or 0)
	local minValue, maxValue = ns.GetLimits(path)
	step = step or 1
	suffix = suffix or ""

	local holder = CreateFrame("Frame", nil, self.content)
	holder:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, self.y)
	holder:SetSize(320, 40)

	local title = holder:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	title:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	title:SetText(L[label])

	local slider = CreateFrame("Slider", nil, holder, "BackdropTemplate")
	slider:SetOrientation("HORIZONTAL")
	slider:SetSize(240, 16)
	slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
	slider:SetHitRectInsets(0, 0, -6, -6)
	slider:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = {left = 3, right = 3, top = 6, bottom = 6},
	})
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)
	-- The mouse wheel doesn't change the value: over a slider it scrolls the page, like everywhere else
	-- in the window, so scrolling down the options never changes a setting by accident
	slider:EnableMouseWheel(false)

	local valueText = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	valueText:SetPoint("LEFT", slider, "RIGHT", 10, 0)

	local control = {frame = holder, interactive = {slider}}
	local updating = false
	function control:Refresh()
		updating = true
		local value = ns.Get(path)
		slider:SetValue(value)
		valueText:SetText(FormatNumber(value, step) .. suffix)
		updating = false
	end
	slider:SetScript("OnValueChanged", function(_, value)
		value = Round(value, step)
		valueText:SetText(FormatNumber(value, step) .. suffix)
		if not updating and value ~= ns.Get(path) then
			ns.Set(path, value)
		end
	end)
	-- A right click opens a box to type the value, over the number shown next to the slider
	local function TypeValue()
		if not slider:IsEnabled() then return end
		HideTooltip()
		OpenValueBox(slider, ns.Get(path), minValue, maxValue, step, function(value)
			value = math.min(maxValue, math.max(minValue, Round(value, step)))
			ns.Set(path, value)
			control:Refresh()
		end)
	end
	slider:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" then TypeValue() end
	end)
	local hint = L["Right-click to type a value."]
	slider:SetScript("OnEnter", function(self)
		ShowTooltip(self, L[label], tooltip and (L[tooltip] .. "\n\n|cff999999" .. hint .. "|r") or ("|cff999999" .. hint .. "|r"))
	end)
	slider:SetScript("OnLeave", HideTooltip)

	self.y = self.y - SLIDER_HEIGHT
	self.hasContent = true
	return Register(control, dependsOn)
end

-- A color swatch bound to a {r, g, b} setting
function Builder:Color(path, label, tooltip, dependsOn, indent)
	local x = LEFT + 4 + (indent and INDENT or 0)
	local swatch = CreateFrame("Button", nil, self.content, "BackdropTemplate")
	swatch:SetSize(18, 18)
	swatch:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, self.y - 2)
	swatch:SetBackdrop({bgFile = WHITE, edgeFile = WHITE, edgeSize = 1})
	swatch:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
	local text = swatch:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
	text:SetText(L[label])
	swatch:SetHitRectInsets(0, -text:GetStringWidth() - 6, 0, 0)

	local control = {frame = swatch, interactive = {swatch}}
	function control:Refresh()
		swatch:SetBackdropColor(ns.Unpack(ns.Get(path)))
	end
	swatch:SetScript("OnClick", function()
		local r, g, b = ns.Unpack(ns.Get(path))
		local function OnChanged()
			local newR, newG, newB = ColorPickerFrame:GetColorRGB()
			ns.Set(path, {newR, newG, newB})
		end
		local function OnCancel(previous)
			if type(previous) == "table" and previous.r then
				ns.Set(path, {previous.r, previous.g, previous.b})
			else
				ns.Set(path, {r, g, b})
			end
		end
		if ColorPickerFrame.SetupColorPickerAndShow then
			ColorPickerFrame:SetupColorPickerAndShow({
				r = r, g = g, b = b, hasOpacity = false,
				swatchFunc = OnChanged, cancelFunc = OnCancel,
			})
		else
			ColorPickerFrame.func = OnChanged
			ColorPickerFrame.cancelFunc = OnCancel
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = {r = r, g = g, b = b}
			ColorPickerFrame:SetColorRGB(r, g, b)
			ColorPickerFrame:Show()
		end
	end)
	swatch:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	swatch:SetScript("OnLeave", HideTooltip)

	-- A button that puts the color back to its default, in a column of its own so they line up
	local section, key = path:match("^([^.]+)%.(.+)$")
	local default = ns.DEFAULTS[section] and ns.DEFAULTS[section][key]
	local reset = NewButton(self.content, 80, 20, "GameFontNormalSmall")
	reset:SetPoint("TOPLEFT", self.content, "TOPLEFT", COLOR_RESET_X, self.y)
	reset:SetText(L["Default"])
	reset:SetScript("OnClick", function()
		if default then ns.Set(path, {default[1], default[2], default[3]}) end
	end)
	reset:SetScript("OnEnter", function(self)
		ShowTooltip(self, L["Default"], L["Puts this color back to its default."])
	end)
	reset:SetScript("OnLeave", HideTooltip)
	control.interactive[#control.interactive + 1] = reset
	control.reset = reset

	self.y = self.y - COLOR_HEIGHT
	self.hasContent = true
	return Register(control, dependsOn)
end

-- A dropdown bound to a setting. options: {{value = ..., text = ...}, ...} or a function returning it.
function Builder:Dropdown(path, label, options, tooltip, dependsOn, indent)
	local x = LEFT + 4 + (indent and INDENT or 0)
	local holder = CreateFrame("Frame", nil, self.content)
	holder:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, self.y)
	holder:SetSize(320, 44)

	local title = holder:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	title:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	title:SetText(L[label])

	local button = NewDropdownButton(holder, 280, 24)
	button:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)

	local function GetOptions()
		return type(options) == "function" and options() or options
	end

	local control = {frame = holder, interactive = {button}}
	function control:Refresh()
		local value = ns.Get(path)
		local text = tostring(value)
		for _, option in ipairs(GetOptions()) do
			if option.value == value then text = option.text break end
		end
		button:SetText(L[text])
	end
	button:SetScript("OnClick", function(self)
		local list = {}
		for _, option in ipairs(GetOptions()) do
			list[#list + 1] = {value = option.value, text = L[option.text]}
		end
		OpenPopup(self, list, ns.Get(path), function(value)
			ns.Set(path, value)
		end)
	end)
	button:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	button:SetScript("OnLeave", HideTooltip)

	self.y = self.y - DROPDOWN_HEIGHT
	self.hasContent = true
	return Register(control, dependsOn)
end

-- A plain button that runs an action
function Builder:Button(label, onClick, tooltip, width)
	local button = NewButton(self.content, width or 200, 24)
	button:SetPoint("TOPLEFT", self.content, "TOPLEFT", LEFT + 4, self.y)
	button:SetText(L[label])
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	button:SetScript("OnLeave", HideTooltip)
	self.y = self.y - BUTTON_HEIGHT
	self.hasContent = true
	return button
end

-- A one-line text box (e.g. a code to copy or paste); a click selects all its text, for Ctrl+C
function Builder:EditBox(label, tooltip, width)
	local title = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	title:SetPoint("TOPLEFT", self.content, "TOPLEFT", LEFT + 4, self.y)
	title:SetText(L[label])

	local box = CreateFrame("EditBox", nil, self.content, "BackdropTemplate")
	box:SetSize(width or (CONTENT_WIDTH - LEFT * 2 - 8), 24)
	box:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
	box:SetAutoFocus(false)
	box:SetFontObject("GameFontHighlightSmall")
	box:SetMaxLetters(0)
	box:SetTextInsets(6, 6, 0, 0)
	box:SetBackdrop({
		bgFile = WHITE, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10, insets = {left = 2, right = 2, top = 2, bottom = 2},
	})
	box:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
	box:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
	box:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	box:SetScript("OnLeave", HideTooltip)

	self.y = self.y - DROPDOWN_HEIGHT
	self.hasContent = true
	return box
end

-- An empty area of this height, for a page to fill itself (e.g. a list), and a way to have its own
-- refresh called with the other controls
function Builder:Area(height)
	local area = CreateFrame("Frame", nil, self.content)
	area:SetPoint("TOPLEFT", self.content, "TOPLEFT", LEFT, self.y)
	area:SetSize(CONTENT_WIDTH - LEFT * 2, height)
	self.y = self.y - height - TEXT_GAP
	self.hasContent = true
	return area
end

function Builder:AddControl(control, dependsOn)
	return Register(control, dependsOn)
end

-- A plain button placed by the caller (e.g. in a row of a list)
function Widgets.SmallButton(parent, label, tooltip, onClick, width)
	local button = NewButton(parent, width or 80, 20, "GameFontNormalSmall")
	button:SetText(L[label])
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", function(self) ShowTooltip(self, L[label], tooltip and L[tooltip]) end)
	button:SetScript("OnLeave", HideTooltip)
	return button
end

-- Asks with the game's own confirmation window, then runs onAccept; without it, runs it straight away
function Widgets.Confirm(key, text, onAccept)
	if not (StaticPopupDialogs and StaticPopup_Show) then
		onAccept()
		return
	end
	StaticPopupDialogs[key] = {
		-- The game formats the text, so a "%" in it must be doubled
		text = (text:gsub("%%", "%%%%")),
		button1 = YES or L["Yes"],
		button2 = NO or L["No"],
		OnAccept = function() onAccept() end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show(key)
end

-- Helpers for "depends on" -------------------------------------------------------------------------

function Widgets.IsOn(path)
	return function() return ns.Get(path) and true or false end
end

function Widgets.All(...)
	local conditions = {...}
	return function()
		for _, condition in ipairs(conditions) do
			if not condition() then return false end
		end
		return true
	end
end

function Widgets.ClosePopup()
	ClosePopup()
end
