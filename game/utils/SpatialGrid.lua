-- [ts]: SpatialGrid.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
____exports.SpatialGrid = __TS__Class() -- 10
local SpatialGrid = ____exports.SpatialGrid -- 10
SpatialGrid.name = "SpatialGrid" -- 10
function SpatialGrid.prototype.____constructor(self, cellSize) -- 15
	if cellSize == nil then -- 15
		cellSize = 64 -- 15
	end -- 15
	self.cells = __TS__New(Map) -- 12
	self.items = {} -- 13
	self.cellSize = cellSize -- 16
end -- 15
function SpatialGrid.prototype.key(self, cx, cy) -- 19
	return (cx + 4096) * 8192 + (cy + 4096) -- 21
end -- 19
function SpatialGrid.prototype.clear(self) -- 24
	self.cells:clear() -- 25
	__TS__ArraySetLength(self.items, 0) -- 25
end -- 24
function SpatialGrid.prototype.add(self, item) -- 29
	local ____self_items_0 = self.items -- 29
	____self_items_0[#____self_items_0 + 1] = item -- 30
	local cx = math.floor(item.pos.x / self.cellSize) -- 31
	local cy = math.floor(item.pos.y / self.cellSize) -- 32
	local k = self:key(cx, cy) -- 33
	local cell = self.cells:get(k) -- 34
	if cell ~= nil then -- 34
		cell[#cell + 1] = #self.items - 1 -- 36
	else -- 36
		self.cells:set(k, {#self.items - 1}) -- 38
	end -- 38
end -- 29
function SpatialGrid.prototype.cellIndices(self, cx, cy) -- 43
	local k = self:key(cx, cy) -- 44
	local cell = self.cells:get(k) -- 45
	return cell ~= nil and cell or ({}) -- 46
end -- 43
function SpatialGrid.prototype.query(self, pos, radius) -- 50
	local minX = math.floor((pos.x - radius) / self.cellSize) -- 51
	local maxX = math.floor((pos.x + radius) / self.cellSize) -- 52
	local minY = math.floor((pos.y - radius) / self.cellSize) -- 53
	local maxY = math.floor((pos.y + radius) / self.cellSize) -- 54
	local result = {} -- 55
	do -- 55
		local cx = minX -- 56
		while cx <= maxX do -- 56
			do -- 56
				local cy = minY -- 57
				while cy <= maxY do -- 57
					local cell = self:cellIndices(cx, cy) -- 58
					do -- 58
						local i = 0 -- 59
						while i < #cell do -- 59
							result[#result + 1] = cell[i + 1] -- 60
							i = i + 1 -- 59
						end -- 59
					end -- 59
					cy = cy + 1 -- 57
				end -- 57
			end -- 57
			cx = cx + 1 -- 56
		end -- 56
	end -- 56
	return result -- 64
end -- 50
function SpatialGrid.prototype.queryHit(self, pos, radius, out) -- 68
	__TS__ArraySetLength(out, 0) -- 68
	local idxs = self:query(pos, radius) -- 70
	local rr = radius + 0.001 -- 71
	do -- 71
		local i = 0 -- 72
		while i < #idxs do -- 72
			local item = self.items[idxs[i + 1] + 1] -- 73
			local dx = item.pos.x - pos.x -- 74
			local dy = item.pos.y - pos.y -- 75
			local r = item.radius + rr -- 76
			if dx * dx + dy * dy <= r * r then -- 76
				out[#out + 1] = item -- 78
			end -- 78
			i = i + 1 -- 72
		end -- 72
	end -- 72
end -- 68
function SpatialGrid.prototype.itemAt(self, index) -- 88
	return self.items[index + 1] -- 89
end -- 88
__TS__SetDescriptor( -- 88
	SpatialGrid.prototype, -- 88
	"itemCount", -- 88
	{get = function(self) -- 88
		return #self.items -- 84
	end}, -- 84
	true -- 84
) -- 84
return ____exports -- 84