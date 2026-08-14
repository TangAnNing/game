-- [ts]: Scene.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local circleVertsAt, drawRing -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____RNG = require("game.utils.RNG") -- 3
local RNG = ____RNG.RNG -- 3
local ____MathUtils = require("game.utils.MathUtils") -- 4
local clamp = ____MathUtils.clamp -- 4
function circleVertsAt(center, radius, segments) -- 156
	local verts = {} -- 157
	do -- 157
		local i = 0 -- 158
		while i < segments do -- 158
			local a = i / segments * math.pi * 2 -- 159
			verts[#verts + 1] = Vec2( -- 160
				center.x + math.cos(a) * radius, -- 160
				center.y + math.sin(a) * radius -- 160
			) -- 160
			i = i + 1 -- 158
		end -- 158
	end -- 158
	return verts -- 162
end -- 162
function drawRing(draw, center, radius, segments, width, color) -- 165
	do -- 165
		local i = 0 -- 166
		while i < segments do -- 166
			local a1 = i / segments * math.pi * 2 -- 167
			local a2 = (i + 1) / segments * math.pi * 2 -- 168
			draw:drawSegment( -- 169
				Vec2( -- 169
					center.x + math.cos(a1) * radius, -- 169
					center.y + math.sin(a1) * radius -- 169
				), -- 169
				Vec2( -- 169
					center.x + math.cos(a2) * radius, -- 169
					center.y + math.sin(a2) * radius -- 169
				), -- 169
				width, -- 169
				color -- 169
			) -- 169
			i = i + 1 -- 166
		end -- 166
	end -- 166
end -- 166
local WORLD_SIZE = 2000 -- 6
local HALF = WORLD_SIZE / 2 -- 7
local TILE_STEP = 160 -- 8
local DECOR_COUNT = 110 -- 9
local DECOR_SEED = 20240520 -- 10
____exports.Scene = __TS__Class() -- 12
local Scene = ____exports.Scene -- 12
Scene.name = "Scene" -- 12
function Scene.prototype.____constructor(self, root) -- 18
	self.spawnRng = __TS__New(RNG, 2882400001) -- 64
	self.root = root -- 19
	self.background = DrawNode() -- 20
	self.decorDraw = DrawNode() -- 21
	self.boundsDraw = DrawNode() -- 22
	self:drawBackground() -- 23
	self:drawBounds() -- 24
	self:buildDecor() -- 25
	self.background:addTo(self.root) -- 26
	self.decorDraw:addTo(self.root) -- 27
	self.boundsDraw:addTo(self.root) -- 28
end -- 18
function Scene.prototype.getWorldBounds(self) -- 31
	return {minX = -HALF, maxX = HALF, minY = -HALF, maxY = HALF} -- 32
end -- 31
function Scene.prototype.getSpawnPointNearEdge(self, worldCenter, margin) -- 36
	do -- 36
		local attempt = 0 -- 37
		while attempt < 8 do -- 37
			local a = self.spawnRng:range(0, math.pi * 2) -- 38
			local r = self.spawnRng:range(HALF - 160, HALF - 50) -- 39
			local x = math.cos(a) * r -- 40
			local y = math.sin(a) * r -- 41
			local dx = x - worldCenter.x -- 42
			local dy = y - worldCenter.y -- 43
			if dx * dx + dy * dy >= margin * margin then -- 43
				return Vec2(x, y) -- 45
			end -- 45
			attempt = attempt + 1 -- 37
		end -- 37
	end -- 37
	local a2 = self.spawnRng:range(0, math.pi * 2) -- 49
	local x2 = clamp( -- 50
		worldCenter.x + math.cos(a2) * margin, -- 50
		-HALF + 40, -- 50
		HALF - 40 -- 50
	) -- 50
	local y2 = clamp( -- 51
		worldCenter.y + math.sin(a2) * margin, -- 51
		-HALF + 40, -- 51
		HALF - 40 -- 51
	) -- 51
	return Vec2(x2, y2) -- 52
end -- 36
function Scene.prototype.isInside(self, pos) -- 55
	return math.abs(pos.x) <= HALF and math.abs(pos.y) <= HALF -- 56
end -- 55
function Scene.prototype.update(self, dt) -- 59
end -- 59
function Scene.prototype.drawBackground(self) -- 66
	self.background:clear() -- 67
	local c = Color(13, 24, 26, 255) -- 68
	self.background:drawPolygon( -- 69
		{ -- 70
			Vec2(-HALF, -HALF), -- 70
			Vec2(HALF, -HALF), -- 70
			Vec2(HALF, HALF), -- 70
			Vec2(-HALF, HALF) -- 70
		}, -- 70
		c -- 71
	) -- 71
	do -- 71
		local gx = -HALF -- 74
		while gx < HALF do -- 74
			do -- 74
				local gy = -HALF -- 75
				while gy < HALF do -- 75
					local odd = (math.floor((gx + HALF) / TILE_STEP) + math.floor((gy + HALF) / TILE_STEP)) % 2 == 0 -- 76
					local pad = 4 -- 77
					self.background:drawPolygon( -- 78
						{ -- 79
							Vec2(gx + pad, gy + pad), -- 79
							Vec2(gx + TILE_STEP - pad, gy + pad), -- 79
							Vec2(gx + TILE_STEP - pad, gy + TILE_STEP - pad), -- 79
							Vec2(gx + pad, gy + TILE_STEP - pad) -- 79
						}, -- 79
						Color(odd and 17 or 15, odd and 31 or 28, odd and 32 or 30, 255) -- 80
					) -- 80
					gy = gy + TILE_STEP -- 75
				end -- 75
			end -- 75
			gx = gx + TILE_STEP -- 74
		end -- 74
	end -- 74
	self.background:drawDot( -- 85
		Vec2.zero, -- 85
		190, -- 85
		Color(23, 52, 48, 255) -- 85
	) -- 85
	drawRing( -- 86
		self.background, -- 86
		Vec2.zero, -- 86
		190, -- 86
		32, -- 86
		4, -- 86
		Color(61, 104, 91, 180) -- 86
	) -- 86
	drawRing( -- 87
		self.background, -- 87
		Vec2.zero, -- 87
		116, -- 87
		24, -- 87
		2, -- 87
		Color(203, 156, 67, 150) -- 87
	) -- 87
	do -- 87
		local i = 0 -- 88
		while i < 8 do -- 88
			local a = i / 8 * math.pi * 2 -- 89
			local p1 = Vec2( -- 90
				math.cos(a) * 126, -- 90
				math.sin(a) * 126 -- 90
			) -- 90
			local p2 = Vec2( -- 91
				math.cos(a) * 176, -- 91
				math.sin(a) * 176 -- 91
			) -- 91
			self.background:drawSegment( -- 92
				p1, -- 92
				p2, -- 92
				5, -- 92
				Color(172, 127, 53, 120) -- 92
			) -- 92
			i = i + 1 -- 88
		end -- 88
	end -- 88
end -- 66
function Scene.prototype.drawBounds(self) -- 96
	self.boundsDraw:clear() -- 97
	local shadow = Color(0, 0, 0, 180) -- 98
	local c = Color(197, 145, 56, 255) -- 99
	self.boundsDraw:drawSegment( -- 100
		Vec2(-HALF, -HALF), -- 100
		Vec2(HALF, -HALF), -- 100
		12, -- 100
		shadow -- 100
	) -- 100
	self.boundsDraw:drawSegment( -- 101
		Vec2(HALF, -HALF), -- 101
		Vec2(HALF, HALF), -- 101
		12, -- 101
		shadow -- 101
	) -- 101
	self.boundsDraw:drawSegment( -- 102
		Vec2(HALF, HALF), -- 102
		Vec2(-HALF, HALF), -- 102
		12, -- 102
		shadow -- 102
	) -- 102
	self.boundsDraw:drawSegment( -- 103
		Vec2(-HALF, HALF), -- 103
		Vec2(-HALF, -HALF), -- 103
		12, -- 103
		shadow -- 103
	) -- 103
	self.boundsDraw:drawSegment( -- 104
		Vec2(-HALF, -HALF), -- 104
		Vec2(HALF, -HALF), -- 104
		4, -- 104
		c -- 104
	) -- 104
	self.boundsDraw:drawSegment( -- 105
		Vec2(HALF, -HALF), -- 105
		Vec2(HALF, HALF), -- 105
		4, -- 105
		c -- 105
	) -- 105
	self.boundsDraw:drawSegment( -- 106
		Vec2(HALF, HALF), -- 106
		Vec2(-HALF, HALF), -- 106
		4, -- 106
		c -- 106
	) -- 106
	self.boundsDraw:drawSegment( -- 107
		Vec2(-HALF, HALF), -- 107
		Vec2(-HALF, -HALF), -- 107
		4, -- 107
		c -- 107
	) -- 107
end -- 96
function Scene.prototype.buildDecor(self) -- 111
	self.decorDraw:clear() -- 112
	local rng = __TS__New(RNG, DECOR_SEED) -- 113
	do -- 113
		local i = 0 -- 114
		while i < DECOR_COUNT do -- 114
			local x = rng:range(-HALF + 30, HALF - 30) -- 115
			local y = rng:range(-HALF + 30, HALF - 30) -- 116
			if rng:chance(0.45) then -- 116
				local r = rng:range(2, 5) -- 119
				self.decorDraw:drawDot( -- 120
					Vec2(x, y), -- 120
					r + 4, -- 120
					Color(45, 136, 105, 24) -- 120
				) -- 120
				self.decorDraw:drawDot( -- 121
					Vec2(x, y), -- 121
					r, -- 121
					Color( -- 121
						64, -- 121
						rng:int(120, 185), -- 121
						122, -- 121
						185 -- 121
					) -- 121
				) -- 121
			elseif rng:chance(0.62) then -- 121
				local a = rng:range(0, math.pi * 2) -- 124
				local len = rng:range(12, 30) -- 125
				local mid = Vec2( -- 126
					x + math.cos(a) * len * 0.5, -- 126
					y + math.sin(a) * len * 0.5 -- 126
				) -- 126
				self.decorDraw:drawSegment( -- 127
					Vec2(x, y), -- 127
					mid, -- 127
					1.5, -- 127
					Color(58, 73, 70, 170) -- 127
				) -- 127
				self.decorDraw:drawSegment( -- 128
					mid, -- 128
					Vec2( -- 128
						mid.x + math.cos(a + 0.7) * len * 0.45, -- 128
						mid.y + math.sin(a + 0.7) * len * 0.45 -- 128
					), -- 128
					1.2, -- 128
					Color(58, 73, 70, 130) -- 128
				) -- 128
			else -- 128
				local r = rng:range(5, 11) -- 131
				self.decorDraw:drawPolygon( -- 132
					{ -- 132
						Vec2(x - r, y - r * 0.4), -- 132
						Vec2(x + r * 0.7, y - r), -- 132
						Vec2(x + r, y + r * 0.5), -- 132
						Vec2(x - r * 0.5, y + r) -- 132
					}, -- 132
					Color(53, 65, 65, 220) -- 132
				) -- 132
			end -- 132
			i = i + 1 -- 114
		end -- 114
	end -- 114
	local sites = { -- 136
		Vec2(-560, 420), -- 136
		Vec2(620, 500), -- 136
		Vec2(-610, -520), -- 136
		Vec2(560, -470) -- 136
	} -- 136
	for ____, p in ipairs(sites) do -- 137
		self:drawRuin(p) -- 137
	end -- 137
end -- 111
function Scene.prototype.drawRuin(self, p) -- 140
	drawRing( -- 141
		self.decorDraw, -- 141
		p, -- 141
		72, -- 141
		16, -- 141
		5, -- 141
		Color(79, 91, 83, 210) -- 141
	) -- 141
	drawRing( -- 142
		self.decorDraw, -- 142
		p, -- 142
		48, -- 142
		12, -- 142
		2, -- 142
		Color(172, 127, 53, 140) -- 142
	) -- 142
	do -- 142
		local i = 0 -- 143
		while i < 4 do -- 143
			local a = i * math.pi / 2 + 0.25 -- 144
			local base = Vec2( -- 145
				p.x + math.cos(a) * 78, -- 145
				p.y + math.sin(a) * 78 -- 145
			) -- 145
			self.decorDraw:drawSegment( -- 146
				base, -- 146
				Vec2(base.x, base.y + 42), -- 146
				9, -- 146
				Color(64, 75, 71, 255) -- 146
			) -- 146
			self.decorDraw:drawDot( -- 147
				Vec2(base.x, base.y + 43), -- 147
				8, -- 147
				Color(89, 99, 90, 255) -- 147
			) -- 147
			i = i + 1 -- 143
		end -- 143
	end -- 143
end -- 140
local function circleVerts(radius, segments) -- 152
	return circleVertsAt(Vec2.zero, radius, segments) -- 153
end -- 152
return ____exports -- 152