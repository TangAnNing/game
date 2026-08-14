-- [ts]: LevelUp.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local ____GameContext = require("game.core.GameContext") -- 3
local ctx = ____GameContext.ctx -- 3
local ____Config = require("game.config.Config") -- 4
local Config = ____Config.Config -- 4
local ____SkillDefs = require("game.skills.SkillDefs") -- 5
local getSkillDef = ____SkillDefs.getSkillDef -- 5
local poolForCharacter = ____SkillDefs.poolForCharacter -- 5
____exports.LevelUpSystem = __TS__Class() -- 9
local LevelUpSystem = ____exports.LevelUpSystem -- 9
LevelUpSystem.name = "LevelUpSystem" -- 9
function LevelUpSystem.prototype.____constructor(self, skillSystem, rng) -- 19
	self.currentChoices = {} -- 12
	self.pendingLevels = 0 -- 13
	self.skillSystem = skillSystem -- 20
	self.rng = rng -- 21
	ctx.onPlayerLevelUp = function() return self:beginLevelUp() end -- 23
end -- 19
function LevelUpSystem.prototype.offerChoices(self, characterId) -- 32
	local pool = poolForCharacter(characterId, self.rng) -- 33
	local result = {} -- 34
	do -- 34
		local i = 0 -- 35
		while i < #pool and #result < Config.levelUpChoices do -- 35
			local id = pool[i + 1] -- 36
			if self.skillSystem:getLevel(id) < getSkillDef(id).maxStack then -- 36
				result[#result + 1] = id -- 38
			end -- 38
			i = i + 1 -- 35
		end -- 35
	end -- 35
	return result -- 41
end -- 32
function LevelUpSystem.prototype.beginLevelUp(self) -- 45
	if ctx.phase == "levelup" then -- 45
		self.pendingLevels = self.pendingLevels + 1 -- 47
		return -- 48
	end -- 48
	local ____opt_0 = ctx.character -- 48
	local charId = ____opt_0 and ____opt_0.id -- 50
	if charId == nil then -- 50
		self:finishLevelUp() -- 53
		return -- 54
	end -- 54
	self.currentChoices = self:offerChoices(charId) -- 56
	ctx.phase = "levelup" -- 57
	local ____opt_2 = self.onChoicesReady -- 57
	if ____opt_2 ~= nil then -- 57
		____opt_2( -- 58
			self, -- 58
			__TS__ArrayMap( -- 58
				self.currentChoices, -- 58
				function(____, id) return getSkillDef(id) end -- 58
			) -- 58
		) -- 58
	end -- 58
end -- 45
function LevelUpSystem.prototype.choose(self, index) -- 62
	local id = self.currentChoices[index + 1] -- 63
	if id == nil then -- 63
		return -- 64
	end -- 64
	self.skillSystem:applySkill(id) -- 65
	self:finishLevelUp() -- 66
end -- 62
function LevelUpSystem.prototype.finishLevelUp(self) -- 70
	self.currentChoices = {} -- 71
	if self.pendingLevels > 0 then -- 71
		self.pendingLevels = self.pendingLevels - 1 -- 73
		ctx.phase = "playing" -- 74
		self:beginLevelUp() -- 75
		return -- 76
	end -- 76
	ctx.phase = "playing" -- 78
	local ____opt_4 = self.onLevelUpFinished -- 78
	if ____opt_4 ~= nil then -- 78
		____opt_4(self) -- 79
	end -- 79
end -- 70
function LevelUpSystem.prototype.reset(self) -- 83
	self.currentChoices = {} -- 84
	self.pendingLevels = 0 -- 85
end -- 83
__TS__SetDescriptor( -- 83
	LevelUpSystem.prototype, -- 83
	"choices", -- 83
	{get = function(self) -- 83
		return __TS__ArrayMap( -- 28
			self.currentChoices, -- 28
			function(____, id) return getSkillDef(id) end -- 28
		) -- 28
	end}, -- 28
	true -- 28
) -- 28
return ____exports -- 28