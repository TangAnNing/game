-- [ts]: AudioManager.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Audio = ____Dora.Audio -- 2
____exports.Sfx = { -- 4
	MeleeSwing = "Audio/sfx_sword_sweep.wav", -- 5
	MeleeImpact = "Audio/sfx_sword_impact.wav", -- 6
	MagicCast = "Audio/sfx_magic_cast.wav", -- 7
	GunShot = "Audio/sfx_gun_shot.wav", -- 8
	NatureSummon = "Audio/sfx_nature_summon.wav", -- 9
	NecroSummon = "Audio/sfx_necro_summon.wav", -- 10
	SummonImpact = "Audio/sfx_familiar_hit.wav", -- 11
	PlayerHurt = "Audio/sfx_player_hurt.wav", -- 12
	Critical = "Audio/sfx_critical.wav", -- 13
	EliteDown = "Audio/sfx_elite_down.wav" -- 14
} -- 14
____exports.AudioManager = __TS__Class() -- 17
local AudioManager = ____exports.AudioManager -- 17
AudioManager.name = "AudioManager" -- 17
function AudioManager.prototype.____constructor(self) -- 17
	self.muted = false -- 18
	self.cooldowns = {} -- 19
end -- 17
function AudioManager.prototype.setMuted(self, muted) -- 22
	self.muted = muted -- 23
	Audio.globalVolume = muted and 0 or 1 -- 24
end -- 22
function AudioManager.prototype.playSfx(self, name, cooldown) -- 32
	if cooldown == nil then -- 32
		cooldown = 0 -- 32
	end -- 32
	if self.muted or #name == 0 then -- 32
		return false -- 33
	end -- 33
	if (self.cooldowns[name] or 0) > 0 then -- 33
		return false -- 34
	end -- 34
	Audio:play(name, false) -- 35
	if cooldown > 0 then -- 35
		self.cooldowns[name] = cooldown -- 36
	end -- 36
	return true -- 37
end -- 32
function AudioManager.prototype.update(self, dt) -- 40
	for name in pairs(self.cooldowns) do -- 41
		local next = self.cooldowns[name] - dt -- 42
		self.cooldowns[name] = next > 0 and next or 0 -- 43
	end -- 43
end -- 40
function AudioManager.prototype.playMusic(self, name) -- 48
	if #name == 0 then -- 48
		return -- 49
	end -- 49
	if self.muted then -- 49
		self:stopMusic() -- 51
		return -- 52
	end -- 52
	Audio:playStream(name, true) -- 54
end -- 48
function AudioManager.prototype.stopMusic(self, fade) -- 58
	Audio:stopStream(fade) -- 59
end -- 58
function AudioManager.prototype.stopAll(self) -- 63
	Audio:stopAll() -- 64
	self.cooldowns = {} -- 65
end -- 63
__TS__SetDescriptor( -- 63
	AudioManager.prototype, -- 63
	"isMuted", -- 63
	{get = function(self) -- 63
		return self.muted -- 28
	end}, -- 28
	true -- 28
) -- 28
____exports.audio = __TS__New(____exports.AudioManager) -- 70
return ____exports -- 70