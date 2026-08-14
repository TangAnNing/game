-- [ts]: GameContext.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
____exports.GameContext = __TS__Class() -- 60
local GameContext = ____exports.GameContext -- 60
GameContext.name = "GameContext" -- 60
function GameContext.prototype.____constructor(self) -- 60
	self.character = nil -- 63
	self.stats = { -- 66
		kills = 0, -- 67
		eliteKills = 0, -- 68
		bossKills = 0, -- 69
		damageDealt = 0, -- 70
		damageTaken = 0, -- 71
		wave = 0, -- 72
		timeAlive = 0, -- 73
		playerLevel = 0 -- 74
	} -- 74
	self.phase = "menu" -- 78
	self.mode = "chapter" -- 79
end -- 60
____exports.ctx = __TS__New(____exports.GameContext) -- 117
return ____exports -- 117