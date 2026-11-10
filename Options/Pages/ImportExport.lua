-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Sharing the settings with a code, and backups to put them back later (Core\Backups.lua)

local _, ns = ...
local L = ns.L
local W = ns.Widgets

local GREY = {0.7, 0.7, 0.7}
local ROW_HEIGHT = 26

ns.AddOptionsPage("Import / Export", function(b)
	b:Header("Export")
	b:Text("A code with all your settings, to share with someone. Click the box (or the button) and press Ctrl+C to copy it. Your language, the minimap button and the missing buffs aren't in it: those are each player's own.", GREY)
	local exportBox = b:EditBox("Your code")
	-- Always the settings as they are now (unless it's being copied)
	b:AddControl({frame = exportBox, Refresh = function()
		if not exportBox:HasFocus() then exportBox:SetText(ns.ExportSettings()) end
	end})
	exportBox:SetScript("OnTextChanged", function(self, typed)
		-- It's there to be copied: typing in it puts the code back
		if typed then self:SetText(ns.ExportSettings()); self:HighlightText() end
	end)
	b:Button("Select the code", function()
		exportBox:SetText(ns.ExportSettings())
		exportBox:SetFocus()
		exportBox:HighlightText()
		ns.Print(L["Press Ctrl+C to copy the code."])
	end)

	b:Header("Import")
	b:Text("Paste a code (Ctrl+V) in the box and click Import. Your current settings are kept as a backup first, so you can go back.", GREY)
	local importBox = b:EditBox("Code to import")
	importBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	b:Button("Import", function()
		local text = importBox:GetText() or ""
		if text:match("^%s*$") then
			ns.Print(L["Paste a code in the box first."])
			return
		end
		local settings, countOrReason = ns.ParseSettings(text)
		if not settings then
			ns.Print(countOrReason)
			return
		end
		W.Confirm("KYORYOKUNAENHANCEMENTS_IMPORT",
			string.format(L["Replace your settings with the %d from this code? Your current settings are kept as a backup."], countOrReason),
			function()
				if ns.ImportSettings(text) then importBox:SetText("") end
			end)
	end)

	b:Header("Backups")
	b:Text("Copies of all your settings (but the missing buffs), to put back if you change something and don't like it. The last 10 are kept; one is also made by itself before an import or a restore.", GREY)
	local nameBox = b:EditBox("Name of the backup (optional)", nil, 300)
	nameBox:SetMaxLetters(ns.MAX_BACKUP_NAME)
	local function Create()
		ns.CreateBackup("Backup", false, nameBox:GetText())
		nameBox:SetText("")
		nameBox:ClearFocus()
	end
	nameBox:SetScript("OnEnterPressed", Create)
	b:Button("Create a backup", Create)

	local area = b:Area(ns.MAX_BACKUPS * ROW_HEIGHT)
	local empty = area:CreateFontString(nil, "ARTWORK", "GameFontDisable")
	empty:SetPoint("TOPLEFT", area, "TOPLEFT", 4, -4)
	empty:SetText(L["No backups yet."])

	local rows = {}
	for i = 1, ns.MAX_BACKUPS do
		local row = CreateFrame("Frame", nil, area)
		row:SetSize(area:GetWidth(), ROW_HEIGHT)
		row:SetPoint("TOPLEFT", area, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
		row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
		row.text:SetJustifyH("LEFT")
		-- A long name is cut with "..." rather than going onto a second line
		row.text:SetWordWrap(false)
		row.delete = W.SmallButton(row, "Delete", "Deletes this backup. Asks first.", function()
			local backup = ns.GetBackups()[i]
			if not backup then return end
			W.Confirm("KYORYOKUNAENHANCEMENTS_DELETE_BACKUP",
				string.format(L["Delete the backup of %s? This can't be undone."], tostring(backup.date)),
				function() ns.DeleteBackup(i) end)
		end)
		row.delete:SetPoint("RIGHT", row, "RIGHT", 0, 0)
		row.restore = W.SmallButton(row, "Restore", "Puts these settings back. Your current ones are kept as a backup first.", function()
			local backup = ns.GetBackups()[i]
			if not backup then return end
			W.Confirm("KYORYOKUNAENHANCEMENTS_RESTORE_BACKUP",
				string.format(L["Put back the settings of %s? Your current settings are kept as a backup."], tostring(backup.date)),
				function() ns.RestoreBackup(i) end)
		end)
		row.restore:SetPoint("RIGHT", row.delete, "LEFT", -6, 0)

		-- Edit: the row's text becomes a box with the name; Enter keeps it, Escape (or a click
		-- elsewhere) leaves it as it was
		local nameEdit = CreateFrame("EditBox", nil, row, "BackdropTemplate")
		nameEdit:SetHeight(20)
		nameEdit:SetAutoFocus(false)
		nameEdit:SetFontObject("GameFontHighlightSmall")
		nameEdit:SetMaxLetters(ns.MAX_BACKUP_NAME)
		nameEdit:SetTextInsets(4, 4, 0, 0)
		nameEdit:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 10, insets = {left = 2, right = 2, top = 2, bottom = 2},
		})
		nameEdit:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
		nameEdit:SetBackdropBorderColor(1, 0.82, 0, 1)
		nameEdit:Hide()
		local function StopEditing()
			nameEdit.editing = nil
			nameEdit:ClearFocus()
			nameEdit:Hide()
			row.text:Show()
		end
		nameEdit:SetScript("OnEnterPressed", function(self)
			local index = self.editing
			local text = self:GetText()
			StopEditing()
			if index then ns.RenameBackup(index, text) end
		end)
		nameEdit:SetScript("OnEscapePressed", StopEditing)
		nameEdit:SetScript("OnEditFocusLost", StopEditing)
		row.nameEdit = nameEdit

		row.edit = W.SmallButton(row, "Edit", "Gives this backup a name of your own. Enter keeps it; an empty name gives it back its first one.", function()
			local backup = ns.GetBackups()[i]
			if not backup then return end
			nameEdit.editing = i
			nameEdit:SetText(ns.GetBackupName(backup))
			row.text:Hide()
			nameEdit:Show()
			nameEdit:SetFocus()
			nameEdit:HighlightText()
		end, 70)
		row.edit:SetPoint("RIGHT", row.restore, "LEFT", -6, 0)
		row.text:SetPoint("RIGHT", row.edit, "LEFT", -8, 0)
		nameEdit:SetPoint("LEFT", row, "LEFT", 0, 0)
		nameEdit:SetPoint("RIGHT", row.edit, "LEFT", -8, 0)
		rows[i] = row
	end

	b:AddControl({frame = area, Refresh = function()
		local backups = ns.GetBackups()
		empty:SetShown(#backups == 0)
		for i, row in ipairs(rows) do
			local backup = backups[i]
			if backup then
				row.text:SetText(string.format("|cffffd100%s|r  %s  |cff999999v%s|r",
					tostring(backup.date), ns.GetBackupName(backup), tostring(backup.version)))
				row:Show()
			else
				row.nameEdit.editing = nil
				row:Hide()
			end
		end
	end})
end)
