-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The class trainer (Modules\Trainer.lua): choosing the spells to learn, being told of new ones, and the
-- spells waiting at the trainer (from the last visit).

local _, ns = ...
local L = ns.L

local GREY = {0.7, 0.7, 0.7}

ns.AddOptionsPage("Trainer", function(b)
	b:Header("Choose the spells to learn")
	b:Text("At your class trainer, each spell you can learn gets a box. Tick the ones you want and click \"Learn ticked\", at the top of the window: only those are learned, one after another. Nothing is learned without your tick, and the game's Train button works as always.", GREY)
	b:Check("trainer.choose", "Choose the spells to learn")

	b:Header("New ranks on the action bars")
	b:Check("trainer.newRanks", "Put new ranks on the action bars",
		"When you learn a new rank of a spell, it takes the place of the rank before it on your action bars. Lower ranks you keep on purpose stay, and macros aren't touched. Not in combat: then when the fight ends.")

	b:Header("New spells")
	b:Check("trainer.notify", "Tell me when I reach the level of new spells",
		"When you level up, the chat lists the spells waiting at your trainer for that level. They're read at each visit to your trainer, for every character of your class: visit it once, with any of them, after turning this on.")
	b:Check("trainer.spellbookTab", "Show a Trainer tab in the spellbook",
		"One more tab in your spellbook, after the game's: a click on it shows the spells still to learn at your class trainer and the other trainers you go to (weapon masters, riding...), by level, with their cost, and a box to search them. They're read at each visit to your trainer, for every character of your class: visit it once, with any of them, after turning this on.")

	-- What the last visit left: the spells to learn now, and the next levels'
	if not (ns.Get("trainer.notify") or ns.Get("trainer.spellbookTab")) then return end
	local now, upcoming = ns.Trainer.Waiting()
	b:Header("Waiting at your trainer")
	if not now then
		b:Text("Nothing known yet: visit your class trainer once, with any character of this class.", GREY)
		return
	end
	if #now > 0 then
		b:Text(string.format(L["You can learn now: %s."], table.concat(now, ", ")), nil, true)
	else
		b:Text("Nothing to learn at your level.", GREY)
	end
	for i = 1, math.min(3, #upcoming) do
		local entry = upcoming[i]
		b:Text(string.format(L["Level %d: %s."], entry.level, table.concat(entry.labels, ", ")), GREY, true)
	end
	local _, _, by = ns.Trainer.LastVisit()
	if by then
		b:Text(string.format(L["(From %s's last visit to the class trainer.)"], by), GREY)
	else
		b:Text("(From your last visit to your trainer.)", GREY)
	end
end)
