-- [ts]: Config.ts
local ____exports = {} -- 1
____exports.Quality = {Low = 0, Medium = 1, High = 2} -- 2
____exports.Config = { -- 9
	quality = ____exports.Quality.High, -- 11
	enemyCap = {120, 200, 300}, -- 14
	bulletCap = {200, 400, 600}, -- 15
	aiTickDivisor = 4, -- 18
	cullMargin = 120, -- 21
	expBase = 12, -- 24
	expCurve = 1.5, -- 25
	levelUpChoices = 3, -- 28
	viewWidth = 960, -- 31
	viewHeight = 540, -- 32
	playerMoveSpeed = 240, -- 35
	playerMaxHp = 100, -- 36
	playerBaseDamage = 12, -- 37
	playerAttackInterval = 0.7, -- 38
	expPickupRadius = 16, -- 41
	expMagnetRadius = 90, -- 42
	hitStopNormal = 0.03, -- 45
	hitStopCrit = 0.08, -- 46
	shakeSmall = 3, -- 47
	shakeMedium = 6, -- 48
	shakeLarge = 10, -- 49
	saveFile = "reaper_save.json", -- 52
	savePath = "reaper_save.json" -- 53
} -- 53
return ____exports -- 53