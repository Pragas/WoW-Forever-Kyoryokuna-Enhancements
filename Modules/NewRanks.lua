-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- New ranks on the action bars (Trainer page): the game keeps each rank of a spell on its own, so a button
-- with Frostbolt (Rank 3) stays Rank 3 after Rank 4 is learned. When a new rank is learned
-- (LEARNED_SPELL_IN_SKILL_LINE), the buttons with the highest lower rank of that spell get the new one.
-- Lower ranks kept on purpose (e.g. a Rank 1 next to the best one) stay, and macros aren't touched.
--
-- Buttons can't be changed in combat (then once the fight ends), nor while the cursor holds something
-- (then a little later).

local _, ns = ...
local L = ns.L

local NewRanks = {}
ns.NewRanks = NewRanks

-- The action bar slots looked at (the game's bars use up to 180)
local MAX_SLOTS = 180
-- How long after learning a spell its text (with the rank) is read, and how often a busy cursor is waited
local DELAY = 0.5
local RETRIES = 10

-- Spells learned but not put yet (combat, cursor busy, rank text not loaded): spell ID -> tries left
local pending = {}

local function Settings()
	return ns.db.trainer
end

local function After(seconds, func)
	if C_Timer and C_Timer.After then
		C_Timer.After(seconds, function() ns.SafeCall(func) end)
	else
		func()
	end
end

-- A spell's name and rank number (nil when it has none, or the game hasn't loaded its text yet)
local function NameAndRank(spellID)
	local name = C_Spell and C_Spell.GetSpellName and ns.Known(C_Spell.GetSpellName(spellID))
	local text = C_Spell and C_Spell.GetSpellSubtext and ns.Known(C_Spell.GetSpellSubtext(spellID))
	local rank = type(text) == "string" and tonumber(text:match("(%d+)"))
	return type(name) == "string" and name or nil, rank
end

-- The slots with a spell of this name and a lower rank than this one, and the highest such rank
local function OlderSlots(name, newRank, newID)
	local found, best = {}, nil
	for slot = 1, MAX_SLOTS do
		local ok, has = pcall(HasAction, slot)
		if ok and has then
			local kind, id = GetActionInfo(slot)
			if kind == "spell" and type(id) == "number" and id ~= newID then
				local otherName, otherRank = NameAndRank(id)
				if otherName == name and otherRank and otherRank < newRank then
					found[#found + 1] = {slot = slot, id = id, rank = otherRank}
					if not best or otherRank > best then best = otherRank end
				end
			end
		end
	end
	local slots = {}
	for _, entry in ipairs(found) do
		if entry.rank == best then slots[#slots + 1] = entry.slot end
	end
	return slots, best
end

local Pickup = function(spellID)
	if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(spellID) else PickupSpell(spellID) end
end

-- One spell learned: its new rank put in place of the one before. false when it has to wait.
local function Put(spellID)
	local name, rank = NameAndRank(spellID)
	-- No rank text yet: tried again later; a spell without ranks has nothing to replace
	if not name then return false end
	if not rank then
		local text = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)
		return text ~= nil and text ~= "" or false
	end
	if rank < 2 then return true end
	local slots, older = OlderSlots(name, rank, spellID)
	if #slots == 0 then return true end
	if InCombatLockdown() or (GetCursorInfo and GetCursorInfo()) then return false end
	for _, slot in ipairs(slots) do
		Pickup(spellID)
		PlaceAction(slot)
		-- The rank that was there comes onto the cursor: let go
		ClearCursor()
	end
	ns.Print(string.format(L["%s (Rank %d) put on your action bars in place of Rank %d."], name, rank, older))
	return true
end

local function Process()
	if not (ns.db and Settings().newRanks) then
		wipe(pending)
		return
	end
	local waiting = false
	for spellID, tries in pairs(pending) do
		if Put(spellID) or tries <= 1 then
			pending[spellID] = nil
		else
			pending[spellID] = tries - 1
			waiting = true
		end
	end
	-- In combat, the end of the fight brings it back; otherwise a little later
	if waiting and not InCombatLockdown() then After(1, Process) end
end
NewRanks.Process = Process

function NewRanks.OnLearned(spellID)
	if not (ns.db and Settings().newRanks) or type(spellID) ~= "number" then return end
	pending[spellID] = RETRIES
	After(DELAY, Process)
end

ns.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if next(pending) then Process() end
end)

-- The event of a spell learned: on a frame of its own, as its name changed between versions of the game
local learnedFrame = CreateFrame("Frame")
pcall(learnedFrame.RegisterEvent, learnedFrame, "LEARNED_SPELL_IN_SKILL_LINE")
pcall(learnedFrame.RegisterEvent, learnedFrame, "LEARNED_SPELL_IN_TAB")
learnedFrame:SetScript("OnEvent", function(_, _, spellID)
	if ns.NEEDS_RESTART then return end
	ns.SafeCall(NewRanks.OnLearned, spellID)
end)
