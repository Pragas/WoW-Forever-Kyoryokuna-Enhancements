-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Helpers shared by every file. On this client some values come back "secret" (in combat and inside
-- instances): the game's widgets can show them, but the addon can't compare them or do maths with them.
-- Everything that needs a real value goes through Known(), which turns a secret into nil.

local _, ns = ...

local issecretvalue = issecretvalue or function() return false end

-- The value if the addon may use it, nil if it's secret
function ns.Known(value)
	if issecretvalue(value) then return nil end
	return value
end

function ns.IsSecret(value)
	return issecretvalue(value)
end

-- A color saved as {r, g, b}
function ns.Unpack(color)
	if type(color) == "table" then
		return color[1] or 1, color[2] or 1, color[3] or 1
	end
	return 1, 1, 1
end
