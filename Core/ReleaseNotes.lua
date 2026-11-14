-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- What's new, for the welcome window (Options\Welcome.lua) and the chat message after an update, as in
-- Kyoryokuna Plates.
--
-- The game can't read CHANGELOG.md, so each release gets short notes here, written for the player (the
-- CHANGELOG stays the detailed record). Newest first; every new version adds its notes at the top, with
-- their Portuguese in Locales\ptPT.lua.
--
-- The window shows:
--   - the first time the addon is used: what the addon is, and how to start;
--   - after an update: the notes of every version since the last one the player saw;
--   - then never again until the next version (the version seen is saved).

local _, ns = ...
local L = ns.L

ns.RELEASE_NOTES = {
	{
		version = "0.20.0",
		new = {
			"Missing buffs: each group, Essential and Utility, can show only in combat (\"Only in combat\" in its settings), so nothing of it shows out of combat.",
		},
	},
	{
		version = "0.19.1",
		fixed = {
			"Error messages: turning \"Silence the voice of the messages\" off turned the game's voice on, even for a player who had it off. It's now put back as it was.",
		},
	},
	{
		version = "0.19.0",
		new = {
			"Proc alerts: mages can see when their target is frozen (Frost Nova, Frostbite...), with the Frozen Fingers art on top, in combat too.",
			"Proc alerts: Overpower and Revenge get art of their own, besides their glowing button; you pick the art, the button or both.",
		},
	},
	{
		version = "0.18.1",
		fixed = {
			"Proc alerts: a lit button (like Stormstrike's) could stay lit in combat through its ability's whole cooldown. It now goes dark while the ability cools down.",
		},
	},
	{
		version = "0.18.0",
		new = {
			"Proc alerts: shamans get Elemental Focus (its Clearcasting), with the art of a mage's Clearcasting.",
		},
	},
	{
		version = "0.17.1",
		fixed = {
			"Missing buffs: when a boss was pulled before you were in combat yourself, buffs you had could show as missing for a couple of seconds. They no longer do.",
		},
	},
	{
		version = "0.17.0",
		new = {
			"Hide the quest tracker (General page): the list of the quests you follow, on the right of the screen, stays hidden, on the characters you choose.",
			"/ke errors clear empties the list of recorded errors (old ones stayed in it for good).",
		},
	},
	{
		version = "0.16.2",
		fixed = {
			"Missing buffs: how the groups look (place, size, animation, glow...) is now each character's own, like what it watches, and \"Copy from\" copies it too. Your characters keep the look they had.",
		},
	},
	{
		version = "0.16.1",
		new = {
			"Missing buffs: the glow's color is white by default (it was gold). If you never changed it, it's white now.",
		},
	},
	{
		version = "0.16.0",
		new = {
			"Missing buffs: each group can move (pulse, breathe, blink or float, with its speed and strength) and glow (the game's glow, its moving outline, both, or a border of a color), in the color you pick.",
		},
	},
	{
		version = "0.15.2",
		fixed = {
			"Missing buffs: on the options page, a family's icon (for example a shaman's weapon imbues) is the one shown on the screen, the one you picked or the one you used last (it always showed its first spell).",
			"Proc alerts: the animation you pick now moves every proc (some always stayed still). Only Heating Up waits for its 3 stacks, its most, as its row on the page says.",
		},
	},
	{
		version = "0.15.1",
		fixed = {
			"Missing buffs: a buff the game hides from addons in combat shows as soon as it goes, in combat too, through the game's own frames (it only showed after the fight).",
		},
	},
	{
		version = "0.15.0",
		new = {
			"Missing buffs: what goes on the weapons (a shaman's imbues, a rogue's poisons, and for the other classes an oil or a stone), shown while a weapon in your hands has none.",
			"The Quest Sparkles page is gone. If you had it on, the game's own setting goes back off (the sparkles already shown go away after restarting the game).",
		},
	},
	{
		version = "0.14.0",
		new = {
			"Trainer: the new spells told in the chat at each level and the spellbook's Trainer tab are gone, with the lists kept for them. Choosing the spells to learn and the new ranks on the action bars stay.",
		},
	},
	{
		version = "0.13.0",
		new = {
			"The buttons and dropdowns of the options in the addon's own style, like its window's buttons: a long text no longer runs out of its button.",
		},
		fixed = {
			"FPS and latency, proc alerts: after Move, the button says Done right away, as in missing buffs (closing the options also ends the moving).",
		},
	},
	{
		version = "0.12.0",
		new = {
			"Smaller game menu (General page): the menu that opens with Escape, at the size you choose.",
		},
	},
	{
		version = "0.11.1",
		fixed = {
			"Trainer: the list shared by the characters of your class was left empty. It's now kept at your next visit to the trainer.",
			"Trainer: a spell could show twice (once without its rank), and Pyroblast could show again for a frost mage.",
			"Trainer: a visit to another trainer (a weapon master, a riding trainer, a mage's portal trainer) replaced the whole list with its spells. Now every trainer's spells are kept and shown together.",
		},
	},
	{
		version = "0.11.0",
		new = {
			"Trainer tab in the spellbook: a box to search a spell (its ranks show by level), and the cost of what you can learn now and of the whole list.",
			"Trainer: the trainer's list is shared by the characters of your class. Another character of that class sees it without going to the trainer first.",
		},
		fixed = {
			"Trainer: a spell you've learned no longer stays in the list until your next visit to the trainer.",
		},
	},
	{
		version = "0.10.2",
		fixed = {
			"Trainer: spells you can't learn (talents you don't have, other specializations' spells, like Pyroblast for a frost mage) no longer show in the list nor in the chat.",
		},
	},
	{
		version = "0.10.1",
		fixed = {
			"Proc alerts: the test of Fingers of Frost shows both sides, as two charges do in the game.",
			"Proc alerts: Heating Up no longer shows three wings of different sizes: it's one that gets stronger with each stack.",
			"Proc alerts: \"Place on the screen\" is now right after turning the alerts on.",
		},
	},
	{
		version = "0.10.0",
		new = {
			"Trainer (new page): tick the spells you want at your class trainer and learn only those. And the chat tells you when you reach the level of new spells.",
			"New ranks on the action bars (Trainer page): a new rank you learn takes the place of the one before on your bars.",
			"A Trainer tab in the spellbook (Trainer page): the spells still to learn at your trainer, by level, with their cost.",
			"FPS and Latency (new page): your FPS and ping on the screen, where you want them, colored by how good they are.",
			"Quest Sparkles (new page): quest items you can loot keep sparkling, even after a change of the graphics.",
		},
	},
	{
		version = "0.9.0",
		new = {
			"Error Messages (new page): hide the game's red messages you don't want, like \"Spell is not ready yet\" (their sound still plays), and silence their voice.",
		},
	},
	{
		version = "0.8.4",
		fixed = {
			"Two diagnostic commands used only once (/ke procscan armor and fof) are gone.",
		},
	},
	{
		version = "0.8.3",
		fixed = {
			"Proc alerts: Fingers of Frost now shows in combat (one charge on the left, two on the right).",
		},
	},
	{
		version = "0.8.2",
		new = {
			"/ke procscan all: finds the spells of every proc of every class, to set them right for WoW Forever.",
		},
	},
	{
		version = "0.8.1",
		fixed = {
			"Missing buffs no longer record an error every time the game hides your auras in combat.",
		},
	},
	{
		version = "0.8.0",
		new = {
			"Proc alerts: animations to pick (pulse, breathe, blink or float), with their speed and strength, and the art can appear softly.",
		},
	},
	{
		version = "0.7.1",
		new = {
			"Proc alerts: a smoother pulse of the art.",
		},
	},
	{
		version = "0.7.0",
		new = {
			"Glowing buttons: an ability's button on your action bars glows while it can be used (Ice Barrier, Overpower, Execute, Revenge, Counterattack, Holy Shock, Exorcism, Hammer of Wrath, Stormstrike). Each ability with art can warn by its art, its button or both. The alerts can be moved anywhere on the screen.",
		},
	},
	{
		version = "0.6.0",
		new = {
			"Proc alerts for every class: druid, hunter, paladin, priest, rogue, shaman, warlock and warrior, and abilities that become usable (Victory Rush, Riposte, Mongoose Bite). \"Test\" beside a proc keeps it on the screen while you set the look.",
		},
	},
	{
		version = "0.5.1",
		new = {
			"Options: the pages in a new order, the simplest first.",
		},
	},
	{
		version = "0.5.0",
		new = {
			"Supplies (new page): macros that eat and drink the best food and drink in your bags, kept up to date by the addon: food only, drink only, or both at once. A mage's conjures more when there's none.",
			"Proc Alerts (new page): the game's spell alert art on the sides of your character when a proc happens, in combat too. For now the mage's: Missile Barrage, Clearcasting, Fingers of Frost and Heating Up.",
		},
	},
	{
		version = "0.4.0",
		new = {
			"A welcome window: the first time you open the addon, and after each update with what's new and what was fixed.",
			"A button beside the X of the options window shrinks it to its title bar, to see and drag what's on the screen, and brings it back.",
			"Missing buffs: the size of the number on a conjured item's icon, and Move and Reset position at the top of the page.",
		},
	},
	{
		version = "0.3.1",
		new = {
			"Missing buffs: click an icon to conjure the item or to cast the buff (options; out of combat, a limit of the game).",
			"Action bars: the cooldown numbers can change color by the time left.",
			"The number on a conjured item's icon: hidden when there are none, and in any corner or in the middle.",
		},
		fixed = {
			"A click on an icon could cast a lower rank of the spell: it now casts the highest one you know.",
			"Missing buffs are no longer in the Import / Export code nor in the backups: they're each character's own.",
		},
	},
	{
		version = "0.3.0",
		new = {
			"Missing buffs: the buffs and conjured items your character should have, read from its spellbook, shown grey and faded on the screen while missing, in two groups (Essential and Utility) with their own place and look.",
		},
	},
	{
		version = "0.2.0",
		new = {
			"Action bars, experience bar, queue timer and dark mode, each on its own page.",
			"Import / Export page: share your settings with a code, and keep backups to put back later.",
		},
	},
}

-- What isn't fixed: limits of the game itself, shown under the notes
ns.KNOWN_ISSUES = {
	"In combat the game may hide your buffs from addons: the missing buffs icons then stay as they were last known.",
	"In combat the game doesn't let addons change clickable buttons: an icon that shows during a fight becomes clickable when it ends.",
}

-- "1.10.2" as three numbers
local function Parse(version)
	local a, b, c = tostring(version or ""):match("^(%d+)%.?(%d*)%.?(%d*)")
	return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

-- -1, 0 or 1 as version a is older, the same or newer than b
function ns.CompareVersions(a, b)
	local a1, a2, a3 = Parse(a)
	local b1, b2, b3 = Parse(b)
	if a1 ~= b1 then return a1 < b1 and -1 or 1 end
	if a2 ~= b2 then return a2 < b2 and -1 or 1 end
	if a3 ~= b3 then return a3 < b3 and -1 or 1 end
	return 0
end

-- What the welcome window has to show now: "first" (a new install), "update" with the notes of the
-- versions not seen yet (newest first), or nil
function ns.GetWelcomeState()
	if not ns.db or not ns.VERSION or not ns.VERSION:match("^%d") then return nil end
	if ns.db.firstWelcome then return "first", {} end
	local seen = ns.db.seenVersion
	if type(seen) ~= "string" then
		-- Used before this window existed: the notes of this version
		seen = nil
	elseif ns.CompareVersions(seen, ns.VERSION) >= 0 then
		return nil
	end
	local notes = {}
	for _, entry in ipairs(ns.RELEASE_NOTES) do
		local newerThanSeen = not seen and ns.CompareVersions(entry.version, ns.VERSION) == 0
			or seen and ns.CompareVersions(entry.version, seen) > 0
		if newerThanSeen and ns.CompareVersions(entry.version, ns.VERSION) <= 0 then
			notes[#notes + 1] = entry
		end
	end
	return "update", notes
end

-- The OK of the window: not shown again until the next version
function ns.MarkWelcomeSeen()
	if not ns.db then return end
	ns.db.seenVersion = ns.VERSION
	ns.db.firstWelcome = nil
end

-- In the chat once per session, a few seconds after logging in (after the game's own messages)
local told = false
ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
	if told then return end
	told = true
	local function Tell()
		local state = ns.GetWelcomeState()
		if state == "first" then
			ns.Print(L["Thanks for installing! Type /ke to open the options."])
		elseif state == "update" then
			ns.Print(string.format(L["Updated to version %s. Type /ke to see what's new."], ns.VERSION))
		end
	end
	if C_Timer and C_Timer.After then C_Timer.After(5, function() ns.SafeCall(Tell) end) else Tell() end
end)
