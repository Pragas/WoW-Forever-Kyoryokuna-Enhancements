-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- English is the base language. Every text in the addon is written in English and used as its own key.
-- Other languages are tables in their own files (e.g. ptPT.lua) that give each English text its
-- translation; a text missing there falls back to English. The language is chosen on the General page
-- (ns.language), and every text is looked up again each time it's shown.

local _, ns = ...

ns.LOCALES = {}
ns.language = "enUS"

-- The languages offered on the General page, each in its own language
ns.LANGUAGES = {
	{value = "enUS", text = "English"},
	{value = "ptPT", text = "Português"},
}

ns.L = setmetatable({}, {
	__index = function(_, key)
		local translations = ns.LOCALES[ns.language]
		return (translations and translations[key]) or key
	end,
})
