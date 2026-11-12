-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- The class trainer: choosing the spells to learn (Modules\Trainer.lua), and the new ranks on the action
-- bars (Modules\NewRanks.lua).

local _, ns = ...

local GREY = {0.7, 0.7, 0.7}

ns.AddOptionsPage("Trainer", function(b)
	b:Header("Choose the spells to learn")
	b:Text("At your class trainer, each spell you can learn gets a box. Tick the ones you want and click \"Learn ticked\", at the top of the window: only those are learned, one after another. Nothing is learned without your tick, and the game's Train button works as always.", GREY)
	b:Check("trainer.choose", "Choose the spells to learn")

	b:Header("New ranks on the action bars")
	b:Check("trainer.newRanks", "Put new ranks on the action bars",
		"When you learn a new rank of a spell, it takes the place of the rank before it on your action bars. Lower ranks you keep on purpose stay, and macros aren't touched. Not in combat: then when the fight ends.")
end)
