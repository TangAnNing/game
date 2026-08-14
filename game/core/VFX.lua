-- [ts]: VFX.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local easeOut -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____ObjectPool = require("game.utils.ObjectPool") -- 4
local ObjectPool = ____ObjectPool.ObjectPool -- 4
local ____RNG = require("game.utils.RNG") -- 5
local rng = ____RNG.rng -- 5
local ____GameContext = require("game.core.GameContext") -- 6
local ctx = ____GameContext.ctx -- 6
local ____MathUtils = require("game.utils.MathUtils") -- 7
local withAlpha = ____MathUtils.withAlpha -- 7
function easeOut(t) -- 233
	local u = 1 - t -- 234
	return 1 - u * u * u -- 235
end -- 235
local function circleVerts(radius, segments) -- 31
	local verts = {} -- 32
	do -- 32
		local i = 0 -- 33
		while i < segments do -- 33
			local a = i / segments * math.pi * 2 -- 34
			verts[#verts + 1] = Vec2( -- 35
				math.cos(a) * radius, -- 35
				math.sin(a) * radius -- 35
			) -- 35
			i = i + 1 -- 33
		end -- 33
	end -- 33
	return verts -- 37
end -- 31
local ITEM_POOL = __TS__New( -- 40
	ObjectPool, -- 40
	function() return { -- 41
		node = DrawNode(), -- 42
		kind = "burst", -- 43
		life = 0, -- 44
		maxLife = 0, -- 45
		color = 16777215, -- 46
		angle = 0, -- 47
		radius = 0, -- 48
		particles = {} -- 49
	} end, -- 49
	function(item) -- 51
		item.node:clear() -- 52
		item.node.visible = false -- 54
		__TS__ArraySetLength(item.particles, 0) -- 54
	end -- 51
) -- 51
____exports.VFX = __TS__Class() -- 59
local VFX = ____exports.VFX -- 59
VFX.name = "VFX" -- 59
function VFX.prototype.____constructor(self, root) -- 64
	self.active = {} -- 61
	self.maxActive = 256 -- 62
	self.root = root -- 65
	self:bind() -- 66
end -- 64
function VFX.prototype.bind(self) -- 70
	ctx.vfx = { -- 71
		burst = function(____, pos, color, count, speed) return self:burst(pos, color, count, speed) end, -- 72
		ring = function(____, pos, color, radius) return self:ring(pos, color, radius) end, -- 73
		flash = function(____, pos, color, radius) return self:flash(pos, color, radius) end, -- 74
		slash = function(____, pos, angle, color, radius) return self:slash(pos, angle, color, radius) end -- 75
	} -- 75
end -- 70
function VFX.prototype.burst(self, pos, color, count, speed) -- 80
	local item = self:obtain( -- 81
		"burst", -- 81
		pos, -- 81
		color, -- 81
		0.35, -- 81
		0, -- 81
		0 -- 81
	) -- 81
	local n = math.max( -- 82
		2, -- 82
		math.min(24, count) -- 82
	) -- 82
	do -- 82
		local i = 0 -- 83
		while i < n do -- 83
			local a = rng:range(0, math.pi * 2) -- 84
			local sp = rng:range(0.3, 1) * speed -- 85
			local ____item_particles_0 = item.particles -- 85
			____item_particles_0[#____item_particles_0 + 1] = { -- 86
				dx = 0, -- 87
				dy = 0, -- 88
				vx = math.cos(a) * sp, -- 89
				vy = math.sin(a) * sp, -- 90
				size = rng:range(2, 4.5) -- 91
			} -- 91
			i = i + 1 -- 83
		end -- 83
	end -- 83
end -- 80
function VFX.prototype.ring(self, pos, color, radius) -- 97
	self:obtain( -- 98
		"ring", -- 98
		pos, -- 98
		color, -- 98
		0.3, -- 98
		0, -- 98
		radius -- 98
	) -- 98
end -- 97
function VFX.prototype.flash(self, pos, color, radius) -- 102
	self:obtain( -- 103
		"flash", -- 103
		pos, -- 103
		color, -- 103
		0.14, -- 103
		0, -- 103
		radius -- 103
	) -- 103
end -- 102
function VFX.prototype.slash(self, pos, angle, color, radius) -- 107
	self:obtain( -- 108
		"slash", -- 108
		pos, -- 108
		color, -- 108
		0.12, -- 108
		angle, -- 108
		radius -- 108
	) -- 108
end -- 107
function VFX.prototype.obtain(self, kind, pos, color, life, angle, radius) -- 111
	local item -- 112
	if #self.active >= self.maxActive then -- 112
		local oldest = table.remove(self.active, 1) -- 115
		if oldest ~= nil then -- 115
			ITEM_POOL:release(oldest) -- 117
		end -- 117
	end -- 117
	item = ITEM_POOL:acquire() -- 120
	item.node.position = Vec2(pos.x, pos.y) -- 121
	item.node.visible = true -- 122
	if item.node.parent ~= self.root then -- 122
		item.node:addTo(self.root) -- 125
	end -- 125
	item.kind = kind -- 127
	item.life = life -- 128
	item.maxLife = life -- 129
	item.color = color -- 130
	item.angle = angle -- 131
	item.radius = radius -- 132
	local ____self_active_1 = self.active -- 132
	____self_active_1[#____self_active_1 + 1] = item -- 133
	return item -- 134
end -- 111
function VFX.prototype.update(self, dt) -- 138
	do -- 138
		local i = #self.active - 1 -- 139
		while i >= 0 do -- 139
			do -- 139
				local item = self.active[i + 1] -- 140
				item.life = item.life - dt -- 141
				if item.life <= 0 then -- 141
					__TS__ArraySplice(self.active, i, 1) -- 143
					ITEM_POOL:release(item) -- 144
					goto __continue25 -- 145
				end -- 145
				self:redraw(item) -- 147
			end -- 147
			::__continue25:: -- 147
			i = i - 1 -- 139
		end -- 139
	end -- 139
end -- 138
function VFX.prototype.redraw(self, item) -- 151
	local node = item.node -- 152
	node:clear() -- 153
	local t = 1 - item.life / item.maxLife -- 154
	local alpha = (1 - t) * 255 -- 155
	local color = Color(withAlpha( -- 156
		item.color, -- 156
		math.floor(alpha + 0.5) -- 156
	)) -- 156
	local bright = Color(withAlpha( -- 157
		item.color, -- 157
		math.floor(math.min(255, alpha * 1.6) + 0.5) -- 157
	)) -- 157
	repeat -- 157
		local ____switch28 = item.kind -- 157
		local ____cond28 = ____switch28 == "burst" -- 157
		if ____cond28 then -- 157
			do -- 157
				local dtScale = 0.016 -- 160
				do -- 160
					local i = 0 -- 161
					while i < #item.particles do -- 161
						local p = item.particles[i + 1] -- 162
						p.dx = p.dx + p.vx * dtScale -- 163
						p.dy = p.dy + p.vy * dtScale -- 164
						p.vx = p.vx * 0.92 -- 165
						p.vy = p.vy * 0.92 -- 166
						node:drawDot( -- 167
							Vec2(p.dx, p.dy), -- 167
							p.size, -- 167
							color -- 167
						) -- 167
						i = i + 1 -- 161
					end -- 161
				end -- 161
				break -- 169
			end -- 169
		end -- 169
		____cond28 = ____cond28 or ____switch28 == "ring" -- 169
		if ____cond28 then -- 169
			do -- 169
				local r = item.radius * easeOut(t) -- 172
				local verts = circleVerts(r, 20) -- 173
				verts[#verts + 1] = Vec2.zero -- 174
				node:drawPolygon( -- 175
					verts, -- 175
					Color(withAlpha( -- 175
						item.color, -- 175
						math.floor(alpha * 0.25 + 0.5) -- 175
					)) -- 175
				) -- 175
				do -- 175
					local i = 0 -- 177
					while i < 20 do -- 177
						local a1 = i / 20 * math.pi * 2 -- 178
						local a2 = (i + 1) / 20 * math.pi * 2 -- 179
						node:drawSegment( -- 180
							Vec2( -- 181
								math.cos(a1) * r, -- 181
								math.sin(a1) * r -- 181
							), -- 181
							Vec2( -- 182
								math.cos(a2) * r, -- 182
								math.sin(a2) * r -- 182
							), -- 182
							1.5, -- 183
							bright -- 184
						) -- 184
						i = i + 1 -- 177
					end -- 177
				end -- 177
				break -- 187
			end -- 187
		end -- 187
		____cond28 = ____cond28 or ____switch28 == "flash" -- 187
		if ____cond28 then -- 187
			do -- 187
				local r = item.radius * (1 - t * 0.4) -- 190
				local verts = circleVerts(r, 16) -- 191
				verts[#verts + 1] = Vec2.zero -- 192
				node:drawPolygon( -- 193
					verts, -- 193
					Color(withAlpha( -- 193
						16777215, -- 193
						math.floor(alpha + 0.5) -- 193
					)) -- 193
				) -- 193
				node:drawDot(Vec2.zero, r * 0.5, bright) -- 194
				break -- 195
			end -- 195
		end -- 195
		____cond28 = ____cond28 or ____switch28 == "slash" -- 195
		if ____cond28 then -- 195
			do -- 195
				local r = item.radius * (0.4 + 0.6 * easeOut(t)) -- 198
				local half = 0.6 -- 199
				local segments = 8 -- 200
				local verts = {Vec2.zero} -- 201
				do -- 201
					local i = 0 -- 202
					while i <= segments do -- 202
						local a = item.angle - half + i / segments * half * 2 -- 203
						verts[#verts + 1] = Vec2( -- 204
							math.cos(a) * r, -- 204
							math.sin(a) * r -- 204
						) -- 204
						i = i + 1 -- 202
					end -- 202
				end -- 202
				node:drawPolygon( -- 206
					verts, -- 206
					Color(withAlpha( -- 206
						item.color, -- 206
						math.floor(alpha * 0.55 + 0.5) -- 206
					)) -- 206
				) -- 206
				node:drawSegment( -- 207
					Vec2( -- 208
						math.cos(item.angle - half) * r, -- 208
						math.sin(item.angle - half) * r -- 208
					), -- 208
					Vec2( -- 209
						math.cos(item.angle) * r * 0.7, -- 209
						math.sin(item.angle) * r * 0.7 -- 209
					), -- 209
					2, -- 210
					bright -- 211
				) -- 211
				break -- 213
			end -- 213
		end -- 213
	until true -- 213
end -- 151
function VFX.prototype.clear(self) -- 219
	do -- 219
		local i = #self.active - 1 -- 220
		while i >= 0 do -- 220
			local item = self.active[i + 1] -- 221
			__TS__ArraySplice(self.active, i, 1) -- 222
			ITEM_POOL:release(item) -- 223
			i = i - 1 -- 220
		end -- 220
	end -- 220
end -- 219
function VFX.prototype.init(self) -- 228
	self:bind() -- 229
end -- 228
return ____exports -- 228