-- [ts]: RNG.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
____exports.RNG = __TS__Class() -- 2
local RNG = ____exports.RNG -- 2
RNG.name = "RNG" -- 2
function RNG.prototype.____constructor(self, seed) -- 5
	self.state = seed ~= nil and (seed & 4294967295) >> 0 or 305441741 -- 6
end -- 5
function RNG.prototype.setSeed(self, seed) -- 9
	self.state = (seed & 4294967295) >> 0 -- 10
end -- 9
function RNG.prototype.next(self) -- 14
	self.state = (self.state * 1664525 + 1013904223 & 4294967295) >> 0 -- 16
	return self.state / 4294967296 -- 17
end -- 14
function RNG.prototype.int(self, min, max) -- 21
	if max <= min then -- 21
		return min -- 22
	end -- 22
	return min + math.floor(self:next() * (max - min + 1)) -- 23
end -- 21
function RNG.prototype.range(self, min, max) -- 27
	return min + self:next() * (max - min) -- 28
end -- 27
function RNG.prototype.pick(self, arr) -- 32
	return arr[self:int(0, #arr - 1) + 1] -- 33
end -- 32
function RNG.prototype.pickString(self, arr) -- 37
	local i = self:int(0, #arr - 1) -- 38
	local v = arr[i + 1] -- 39
	return v ~= nil and v or "" -- 40
end -- 37
function RNG.prototype.chance(self, p) -- 44
	return self:next() < p -- 45
end -- 44
function RNG.prototype.gauss(self, mean, std) -- 49
	local sum = 0 -- 50
	do -- 50
		local i = 0 -- 51
		while i < 3 do -- 51
			sum = sum + self:next() -- 51
			i = i + 1 -- 51
		end -- 51
	end -- 51
	return mean + (sum - 1.5) * 2 * std -- 52
end -- 49
____exports.rng = __TS__New(____exports.RNG) -- 57
return ____exports -- 57