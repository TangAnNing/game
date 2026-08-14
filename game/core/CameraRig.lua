-- [ts]: CameraRig.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____MathUtils = require("game.utils.MathUtils") -- 3
local damp = ____MathUtils.damp -- 3
local ____RNG = require("game.utils.RNG") -- 4
local rng = ____RNG.rng -- 4
____exports.CameraRig = __TS__Class() -- 6
local CameraRig = ____exports.CameraRig -- 6
CameraRig.name = "CameraRig" -- 6
function CameraRig.prototype.____constructor(self) -- 6
	self.camera = nil -- 7
	self.target = Vec2.zero -- 8
	self.current = Vec2.zero -- 9
	self.shakeStrength = 0 -- 10
	self.shakeOffset = Vec2.zero -- 11
	self.followLambda = 8 -- 12
end -- 6
function CameraRig.prototype.setup(self, camera, initialPos) -- 15
	self.camera = camera -- 16
	local start = initialPos ~= nil and initialPos or Vec2.zero -- 17
	self.target = start -- 18
	self.current = start -- 19
	self.shakeStrength = 0 -- 20
	self.shakeOffset = Vec2.zero -- 21
	camera.position = Vec2(start.x, start.y) -- 22
end -- 15
function CameraRig.prototype.setFollowLambda(self, lambda) -- 26
	self.followLambda = lambda -- 27
end -- 26
function CameraRig.prototype.follow(self, pos) -- 31
	self.target = pos -- 32
end -- 31
function CameraRig.prototype.snap(self, pos) -- 36
	self.target = pos -- 37
	self.current = pos -- 38
	if self.camera ~= nil then -- 38
		self.camera.position = Vec2(pos.x, pos.y) -- 40
	end -- 40
end -- 36
function CameraRig.prototype.shake(self, strength) -- 45
	self.shakeStrength = math.max(self.shakeStrength, strength) -- 46
end -- 45
function CameraRig.prototype.update(self, dt) -- 50
	self.current = Vec2( -- 51
		damp(self.current.x, self.target.x, self.followLambda, dt), -- 52
		damp(self.current.y, self.target.y, self.followLambda, dt) -- 53
	) -- 53
	self.shakeStrength = self.shakeStrength * math.exp(-6 * dt) -- 56
	if self.shakeStrength < 0.05 then -- 56
		self.shakeStrength = 0 -- 58
	end -- 58
	local ox = 0 -- 60
	local oy = 0 -- 61
	if self.shakeStrength > 0 then -- 61
		ox = rng:range(-1, 1) * self.shakeStrength -- 63
		oy = rng:range(-1, 1) * self.shakeStrength -- 64
		self.shakeOffset = Vec2(ox, oy) -- 65
	else -- 65
		self.shakeOffset = Vec2.zero -- 67
	end -- 67
	if self.camera ~= nil then -- 67
		self.camera.position = Vec2(self.current.x + ox, self.current.y + oy) -- 70
	end -- 70
end -- 50
__TS__SetDescriptor( -- 50
	CameraRig.prototype, -- 50
	"position", -- 50
	{get = function(self) -- 50
		return self.current -- 75
	end}, -- 75
	true -- 75
) -- 75
return ____exports -- 75