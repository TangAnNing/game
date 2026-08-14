-- [ts]: ObjectPool.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
____exports.ObjectPool = __TS__Class() -- 2
local ObjectPool = ____exports.ObjectPool -- 2
ObjectPool.name = "ObjectPool" -- 2
function ObjectPool.prototype.____constructor(self, factory, resetFn) -- 7
	self.free = {} -- 3
	self.factory = function() return factory() end -- 8
	self.resetFn = function(____, item) return resetFn(item) end -- 9
end -- 7
function ObjectPool.prototype.prewarm(self, count) -- 13
	do -- 13
		local i = 0 -- 14
		while i < count do -- 14
			local ____self_free_0 = self.free -- 14
			____self_free_0[#____self_free_0 + 1] = self:factory() -- 15
			i = i + 1 -- 14
		end -- 14
	end -- 14
end -- 13
function ObjectPool.prototype.acquire(self) -- 20
	local item = table.remove(self.free) -- 21
	if item ~= nil then -- 21
		return item -- 22
	end -- 22
	return self:factory() -- 23
end -- 20
function ObjectPool.prototype.release(self, item) -- 27
	self:resetFn(item) -- 28
	local ____self_free_1 = self.free -- 28
	____self_free_1[#____self_free_1 + 1] = item -- 29
end -- 27
function ObjectPool.prototype.clear(self) -- 38
	__TS__ArraySetLength(self.free, 0) -- 38
end -- 38
__TS__SetDescriptor( -- 38
	ObjectPool.prototype, -- 38
	"freeCount", -- 38
	{get = function(self) -- 38
		return #self.free -- 34
	end}, -- 34
	true -- 34
) -- 34
return ____exports -- 34