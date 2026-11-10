-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

local _, ns = ...

local LABEL = {1, 0.82, 0}
local GREY = {0.75, 0.75, 0.75}

local EMBLEM_SIZE = 64

ns.AddOptionsPage("About", function(b)
	-- The addon's emblem, at the right of the version and author
	local emblem = b.content:CreateTexture(nil, "ARTWORK")
	emblem:SetTexture(ns.ICON)
	emblem:SetSize(EMBLEM_SIZE, EMBLEM_SIZE)
	emblem:SetPoint("TOPRIGHT", b.content, "TOPRIGHT", -24, b.y - 28)

	b:Header(ns.SHORT_TITLE, true)
	b:Text("Version", LABEL)
	b:Text(ns.VERSION, nil, true)
	b:Text("Author", LABEL)
	b:Text(ns.AUTHOR, nil, true)
	b:Button("See what's new", function() ns.ShowWhatsNew() end,
		"The window of what's new in each version, and the known issues.")

	b:Header("What it is")
	b:Text("Kyoryokuna Enhancements brings small improvements to the game: the buffs and conjured items you're missing, action bars, the experience bar, the time left to enter a battleground, and a dark mode. Everything starts off, for you to turn on what you want.", GREY)

	b:Header("Credits")
	b:Text("The proc alerts are based on SpellActivationOverlay, by ennvina, used under the MIT License (see the LICENSE file).", GREY)

	b:Header("Copyright")
	b:Text(ns.COPYRIGHT, nil, true)
	b:Text("This addon may be used freely for personal use. Copying, modifying or redistributing its code, in whole or in part, is not allowed without written permission from the author. See the LICENSE file for the full terms.", GREY)
	b:Text("World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment.", GREY)
end)
