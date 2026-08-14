-- [ts]: Save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local ____Config = require("game.config.Config") -- 3
local Config = ____Config.Config -- 3
local function decodeJson(text) -- 7
	local value = json.decode(text) -- 8
	return value -- 9
end -- 7
local function encodeJson(obj) -- 12
	local value = json.encode(obj) -- 13
	if type(value) == "string" then -- 13
		return value -- 14
	end -- 14
	return "" -- 15
end -- 12
local ALL_CHARACTERS = { -- 18
	"swordsman", -- 18
	"mage", -- 18
	"druid", -- 18
	"gunner", -- 18
	"necromancer" -- 18
} -- 18
local function isValidCharacter(v) -- 20
	return v == "swordsman" or v == "mage" or v == "druid" or v == "gunner" or v == "necromancer" -- 21
end -- 20
local function defaultSave() -- 26
	return { -- 27
		version = 1, -- 28
		gold = 0, -- 29
		unlockedCharacters = {"swordsman", "druid"}, -- 30
		permanent = {damage = 0, maxHp = 0, moveSpeed = 0}, -- 31
		bestWave = 0, -- 32
		totalKills = 0, -- 33
		settings = {quality = 1, sfxVolume = 1, musicVolume = 1, muted = false}, -- 34
		stats = {totalGames = 0, totalTime = 0, maxKills = 0} -- 35
	} -- 35
end -- 26
____exports.SaveSystem = __TS__Class() -- 39
local SaveSystem = ____exports.SaveSystem -- 39
SaveSystem.name = "SaveSystem" -- 39
function SaveSystem.prototype.____constructor(self, path) -- 44
	self.kv = {} -- 42
	self.savePath = path -- 45
end -- 44
function SaveSystem.prototype.load(self) -- 48
	local out = defaultSave() -- 49
	if not Content:exist(self.savePath) then -- 49
		return out -- 50
	end -- 50
	local text = Content:load(self.savePath) -- 51
	local raw = decodeJson(text) -- 52
	if type(raw) ~= "table" or raw == nil then -- 52
		return out -- 53
	end -- 53
	local obj = raw -- 54
	if type(obj.gold) == "number" then -- 54
		out.gold = obj.gold -- 56
	end -- 56
	if type(obj.bestWave) == "number" then -- 56
		out.bestWave = obj.bestWave -- 57
	end -- 57
	if type(obj.totalKills) == "number" then -- 57
		out.totalKills = obj.totalKills -- 58
	end -- 58
	if type(obj.unlockedCharacters) == "table" and obj.unlockedCharacters ~= nil then -- 58
		local src = obj.unlockedCharacters -- 61
		local chars = {} -- 62
		for ____, c in ipairs(src) do -- 63
			if isValidCharacter(c) then -- 63
				chars[#chars + 1] = c -- 64
			end -- 64
		end -- 64
		if #chars > 0 then -- 64
			out.unlockedCharacters = chars -- 66
		end -- 66
	end -- 66
	if type(obj.permanent) == "table" and obj.permanent ~= nil then -- 66
		local p = obj.permanent -- 70
		out.permanent = { -- 71
			damage = type(p.damage) == "number" and p.damage or 0, -- 72
			maxHp = type(p.maxHp) == "number" and p.maxHp or 0, -- 73
			moveSpeed = type(p.moveSpeed) == "number" and p.moveSpeed or 0 -- 74
		} -- 74
	end -- 74
	if type(obj.settings) == "table" and obj.settings ~= nil then -- 74
		local s = obj.settings -- 79
		local ____temp_1 = type(s.quality) == "number" and s.quality or 1 -- 81
		local ____temp_2 = type(s.sfxVolume) == "number" and s.sfxVolume or 1 -- 82
		local ____temp_3 = type(s.musicVolume) == "number" and s.musicVolume or 1 -- 83
		local ____temp_0 -- 84
		if type(s.muted) == "boolean" then -- 84
			____temp_0 = s.muted -- 84
		else -- 84
			____temp_0 = false -- 84
		end -- 84
		out.settings = {quality = ____temp_1, sfxVolume = ____temp_2, musicVolume = ____temp_3, muted = ____temp_0} -- 80
	end -- 80
	if type(obj.stats) == "table" and obj.stats ~= nil then -- 80
		local st = obj.stats -- 89
		out.stats = { -- 90
			totalGames = type(st.totalGames) == "number" and st.totalGames or 0, -- 91
			totalTime = type(st.totalTime) == "number" and st.totalTime or 0, -- 92
			maxKills = type(st.maxKills) == "number" and st.maxKills or 0 -- 93
		} -- 93
	end -- 93
	for ____, id in ipairs(ALL_CHARACTERS) do -- 98
		if id == "swordsman" or id == "druid" then -- 98
			if __TS__ArrayIndexOf(out.unlockedCharacters, id) < 0 then -- 98
				local ____out_unlockedCharacters_4 = out.unlockedCharacters -- 98
				____out_unlockedCharacters_4[#____out_unlockedCharacters_4 + 1] = id -- 100
			end -- 100
		end -- 100
	end -- 100
	return out -- 103
end -- 48
function SaveSystem.prototype.save(self, data) -- 106
	Content:save( -- 107
		self.savePath, -- 107
		encodeJson(data) -- 107
	) -- 107
end -- 106
function SaveSystem.prototype.hasKey(self, key) -- 110
	return self.kv[key] ~= nil -- 111
end -- 110
function SaveSystem.prototype.setKey(self, key, value) -- 114
	self.kv[key] = value -- 115
end -- 114
function SaveSystem.prototype.getKey(self, key) -- 118
	return self.kv[key] -- 119
end -- 118
____exports.saveSystem = __TS__New(____exports.SaveSystem, Config.saveFile) -- 124
return ____exports -- 124