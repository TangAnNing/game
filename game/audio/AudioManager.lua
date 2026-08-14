-- [ts]: AudioManager.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Audio = ____Dora.Audio -- 3
____exports.AudioManager = __TS__Class() -- 5
local AudioManager = ____exports.AudioManager -- 5
AudioManager.name = "AudioManager" -- 5
function AudioManager.prototype.____constructor(self) -- 5
	self.muted = false -- 6
end -- 5
function AudioManager.prototype.setMuted(self, muted) -- 9
	self.muted = muted -- 10
	Audio.globalVolume = muted and 0 or 1 -- 11
end -- 9
function AudioManager.prototype.playSfx(self, name) -- 19
	if self.muted or #name == 0 then -- 19
		return -- 20
	end -- 20
	Audio:play(name, false) -- 21
end -- 19
function AudioManager.prototype.playMusic(self, name) -- 25
	if #name == 0 then -- 25
		return -- 26
	end -- 26
	if self.muted then -- 26
		self:stopMusic() -- 28
		return -- 29
	end -- 29
	Audio:playStream(name, true) -- 31
end -- 25
function AudioManager.prototype.stopMusic(self, fade) -- 35
	Audio:stopStream(fade) -- 36
end -- 35
function AudioManager.prototype.stopAll(self) -- 40
	Audio:stopAll() -- 41
end -- 40
__TS__SetDescriptor( -- 40
	AudioManager.prototype, -- 40
	"isMuted", -- 40
	{get = function(self) -- 40
		return self.muted -- 15
	end}, -- 15
	true -- 15
) -- 15
____exports.audio = __TS__New(____exports.AudioManager) -- 46
return ____exports -- 46