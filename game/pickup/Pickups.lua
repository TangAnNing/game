-- [ts]: Pickups.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local drawRectOutline -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 3
local ctx = ____GameContext.ctx -- 3
local ____RNG = require("game.utils.RNG") -- 5
local rng = ____RNG.rng -- 5
local ____MathUtils = require("game.utils.MathUtils") -- 6
local distSq = ____MathUtils.distSq -- 6
function drawRectOutline(draw, w, h, width, color) -- 77
	local x = w / 2 -- 78
	local y = h / 2 -- 79
	draw:drawSegment( -- 80
		Vec2(-x, -y), -- 80
		Vec2(x, -y), -- 80
		width, -- 80
		color -- 80
	) -- 80
	draw:drawSegment( -- 81
		Vec2(x, -y), -- 81
		Vec2(x, y), -- 81
		width, -- 81
		color -- 81
	) -- 81
	draw:drawSegment( -- 82
		Vec2(x, y), -- 82
		Vec2(-x, y), -- 82
		width, -- 82
		color -- 82
	) -- 82
	draw:drawSegment( -- 83
		Vec2(-x, y), -- 83
		Vec2(-x, -y), -- 83
		width, -- 83
		color -- 83
	) -- 83
end -- 83
local PLAYER_RADIUS = 16 -- 8
local PICKUP_DIST = 24 -- 9
local MAGNET_RADIUS = 90 -- 10
local EXP_LIFE = 14 -- 11
local ITEM_LIFE = 25 -- 12
local HEAL_AMOUNT = 20 -- 13
local CHEST_EXP = 30 -- 14
local CRATE_HP = 20 -- 15
local BARREL_HP = 10 -- 16
local BARREL_AOE = 110 -- 17
local BARREL_DAMAGE = 30 -- 18
local function rectVerts(w, h) -- 32
	return { -- 33
		Vec2(-w / 2, -h / 2), -- 34
		Vec2(w / 2, -h / 2), -- 35
		Vec2(w / 2, h / 2), -- 36
		Vec2(-w / 2, h / 2) -- 37
	} -- 37
end -- 32
local function drawPickupVisual(draw, kind, pulse) -- 41
	if pulse == nil then -- 41
		pulse = 0 -- 41
	end -- 41
	draw:clear() -- 42
	repeat -- 42
		local ____switch4 = kind -- 42
		local ____cond4 = ____switch4 == "exp" -- 42
		if ____cond4 then -- 42
			do -- 42
				local r = 5 + math.sin(pulse) * 1.2 -- 45
				draw:drawDot( -- 46
					Vec2.zero, -- 46
					r + 4, -- 46
					Color(90, 160, 255, 70) -- 46
				) -- 46
				draw:drawDot( -- 47
					Vec2.zero, -- 47
					r, -- 47
					Color(120, 190, 255, 255) -- 47
				) -- 47
				break -- 48
			end -- 48
		end -- 48
		____cond4 = ____cond4 or ____switch4 == "chest" -- 48
		if ____cond4 then -- 48
			draw:drawPolygon( -- 51
				rectVerts(22, 16), -- 51
				Color(222, 168, 58, 255) -- 51
			) -- 51
			drawRectOutline( -- 52
				draw, -- 52
				22, -- 52
				16, -- 52
				2, -- 52
				Color(98, 59, 20, 255) -- 52
			) -- 52
			draw:drawSegment( -- 53
				Vec2(-10, 2), -- 53
				Vec2(10, 2), -- 53
				2, -- 53
				Color(255, 219, 116, 255) -- 53
			) -- 53
			draw:drawDot( -- 54
				Vec2(0, -1), -- 54
				3, -- 54
				Color(72, 42, 12, 255) -- 54
			) -- 54
			break -- 55
		end -- 55
		____cond4 = ____cond4 or ____switch4 == "heal" -- 55
		if ____cond4 then -- 55
			draw:drawDot( -- 57
				Vec2.zero, -- 57
				14, -- 57
				Color(40, 105, 69, 110) -- 57
			) -- 57
			draw:drawSegment( -- 58
				Vec2(-8, 0), -- 58
				Vec2(8, 0), -- 58
				4, -- 58
				Color(100, 238, 137, 255) -- 58
			) -- 58
			draw:drawSegment( -- 59
				Vec2(0, -8), -- 59
				Vec2(0, 8), -- 59
				4, -- 59
				Color(100, 238, 137, 255) -- 59
			) -- 59
			break -- 60
		end -- 60
		____cond4 = ____cond4 or ____switch4 == "crate" -- 60
		if ____cond4 then -- 60
			draw:drawPolygon( -- 62
				rectVerts(30, 26), -- 62
				Color(147, 96, 47, 255) -- 62
			) -- 62
			drawRectOutline( -- 63
				draw, -- 63
				30, -- 63
				26, -- 63
				2.5, -- 63
				Color(72, 45, 25, 255) -- 63
			) -- 63
			draw:drawSegment( -- 64
				Vec2(-13, -10), -- 64
				Vec2(13, 10), -- 64
				3, -- 64
				Color(203, 144, 71, 255) -- 64
			) -- 64
			draw:drawSegment( -- 65
				Vec2(-13, 10), -- 65
				Vec2(13, -10), -- 65
				3, -- 65
				Color(203, 144, 71, 255) -- 65
			) -- 65
			break -- 66
		end -- 66
		____cond4 = ____cond4 or ____switch4 == "barrel" -- 66
		if ____cond4 then -- 66
			draw:drawPolygon( -- 68
				rectVerts(24, 30), -- 68
				Color(173, 47, 42, 255) -- 68
			) -- 68
			drawRectOutline( -- 69
				draw, -- 69
				24, -- 69
				30, -- 69
				2.5, -- 69
				Color(57, 35, 38, 255) -- 69
			) -- 69
			draw:drawSegment( -- 70
				Vec2(-11, 8), -- 70
				Vec2(11, 8), -- 70
				3, -- 70
				Color(43, 39, 43, 255) -- 70
			) -- 70
			draw:drawSegment( -- 71
				Vec2(-11, -8), -- 71
				Vec2(11, -8), -- 71
				3, -- 71
				Color(43, 39, 43, 255) -- 71
			) -- 71
			draw:drawDot( -- 72
				Vec2.zero, -- 72
				5, -- 72
				Color(255, 183, 63, 255) -- 72
			) -- 72
			break -- 73
		end -- 73
	until true -- 73
end -- 41
____exports.PickupSystem = __TS__Class() -- 86
local PickupSystem = ____exports.PickupSystem -- 86
PickupSystem.name = "PickupSystem" -- 86
function PickupSystem.prototype.____constructor(self, root) -- 90
	self.pickups = {} -- 88
	self.root = root -- 91
	ctx.onEnemyDied = function(____, enemy, exp, pos, kind) -- 93
		self:spawn("exp", pos, exp) -- 94
		if kind == "elite" and rng:chance(0.3) then -- 94
			self:spawn("chest", pos) -- 95
		end -- 95
		if kind == "boss" then -- 95
			self:spawn("chest", pos) -- 96
		end -- 96
	end -- 93
	ctx.onSpawnPickup = function(____, kind, pos, value) -- 99
		self:spawn(kind, pos, value) -- 100
	end -- 99
	ctx.magnetPickups = function(____, pos, radius) -- 103
		do -- 103
			local i = 0 -- 104
			while i < #self.pickups do -- 104
				local p = self.pickups[i + 1] -- 105
				if p.kind == "exp" and distSq(p.pos, pos) <= radius * radius then -- 105
					p.magnetized = true -- 107
				end -- 107
				i = i + 1 -- 104
			end -- 104
		end -- 104
	end -- 103
	ctx.damageBreakablesInRadius = function(____, pos, radius, damage) -- 111
		return self:damageInRadius(pos, radius, damage) -- 112
	end -- 111
end -- 90
function PickupSystem.prototype.seedArena(self) -- 116
	do -- 116
		local i = 0 -- 117
		while i < 12 do -- 117
			local angle = rng:range(0, math.pi * 2) -- 118
			local distance = rng:range(180, 820) -- 119
			self:spawn( -- 120
				i % 4 == 0 and "barrel" or "crate", -- 120
				Vec2( -- 120
					math.cos(angle) * distance, -- 120
					math.sin(angle) * distance -- 120
				) -- 120
			) -- 120
			i = i + 1 -- 117
		end -- 117
	end -- 117
end -- 116
function PickupSystem.prototype.spawn(self, kind, pos, value) -- 124
	local p = { -- 125
		kind = kind, -- 126
		pos = Vec2(pos.x, pos.y), -- 127
		value = value ~= nil and value or 1, -- 128
		hp = kind == "crate" and CRATE_HP or (kind == "barrel" and BARREL_HP or 0), -- 129
		alive = true, -- 130
		magnetized = false, -- 131
		timer = kind == "exp" and EXP_LIFE or ITEM_LIFE, -- 132
		pulse = rng:range(0, math.pi * 2), -- 133
		draw = DrawNode() -- 134
	} -- 134
	drawPickupVisual(p.draw, kind, p.pulse) -- 136
	p.draw:addTo(self.root) -- 137
	p.draw.position = p.pos -- 138
	local ____self_pickups_0 = self.pickups -- 138
	____self_pickups_0[#____self_pickups_0 + 1] = p -- 139
end -- 124
function PickupSystem.prototype.update(self, dt) -- 142
	local player = ctx.player -- 143
	do -- 143
		local i = #self.pickups - 1 -- 144
		while i >= 0 do -- 144
			do -- 144
				local p = self.pickups[i + 1] -- 145
				if not p.alive then -- 145
					self:removeAt(i) -- 147
					goto __continue23 -- 148
				end -- 148
				p.timer = p.timer - dt -- 150
				if p.timer <= 0 then -- 150
					self:removeAt(i) -- 152
					goto __continue23 -- 153
				end -- 153
				p.pulse = p.pulse + dt * 5 -- 155
				if player ~= nil and player.isAlive and p.kind ~= "crate" and p.kind ~= "barrel" then -- 155
					local dx = player.pos.x - p.pos.x -- 158
					local dy = player.pos.y - p.pos.y -- 159
					local d2 = dx * dx + dy * dy -- 160
					local magnetR = p.kind == "exp" and MAGNET_RADIUS + player.magnet or 0 -- 161
					if not p.magnetized and p.kind == "exp" and d2 <= magnetR * magnetR then -- 161
						p.magnetized = true -- 163
					end -- 163
					if p.magnetized then -- 163
						local dist = math.sqrt(d2) -- 166
						if dist > 0.001 then -- 166
							local step = 460 * dt -- 168
							p.pos = Vec2(p.pos.x + dx / dist * step, p.pos.y + dy / dist * step) -- 169
						end -- 169
						p.draw.position = p.pos -- 171
						if d2 <= (PICKUP_DIST + PLAYER_RADIUS) * (PICKUP_DIST + PLAYER_RADIUS) then -- 171
							self:collect(p) -- 173
							self:removeAt(i) -- 174
							goto __continue23 -- 175
						end -- 175
					elseif d2 <= (PICKUP_DIST + PLAYER_RADIUS) * (PICKUP_DIST + PLAYER_RADIUS) then -- 175
						self:collect(p) -- 178
						self:removeAt(i) -- 179
						goto __continue23 -- 180
					end -- 180
				end -- 180
				if p.kind == "exp" then -- 180
					drawPickupVisual(p.draw, p.kind, p.pulse) -- 184
				end -- 184
				p.draw.position = p.pos -- 186
			end -- 186
			::__continue23:: -- 186
			i = i - 1 -- 144
		end -- 144
	end -- 144
end -- 142
function PickupSystem.prototype.damage(self, kind, pos, dmg) -- 191
	do -- 191
		local i = 0 -- 192
		while i < #self.pickups do -- 192
			do -- 192
				local p = self.pickups[i + 1] -- 193
				if not p.alive or p.kind ~= kind then -- 193
					goto __continue35 -- 194
				end -- 194
				if distSq(p.pos, pos) > 50 * 50 then -- 194
					goto __continue35 -- 195
				end -- 195
				p.hp = p.hp - dmg -- 196
				if p.hp <= 0 then -- 196
					self:breakPickup(p, i) -- 198
					return true -- 199
				end -- 199
			end -- 199
			::__continue35:: -- 199
			i = i + 1 -- 192
		end -- 192
	end -- 192
	return false -- 202
end -- 191
function PickupSystem.prototype.damageInRadius(self, pos, radius, damage) -- 205
	local hits = 0 -- 206
	do -- 206
		local i = #self.pickups - 1 -- 207
		while i >= 0 do -- 207
			do -- 207
				local p = self.pickups[i + 1] -- 208
				if not p.alive or p.kind ~= "crate" and p.kind ~= "barrel" then -- 208
					goto __continue41 -- 209
				end -- 209
				if distSq(p.pos, pos) > radius * radius then -- 209
					goto __continue41 -- 210
				end -- 210
				p.hp = p.hp - damage -- 211
				hits = hits + 1 -- 212
				if p.hp <= 0 then -- 212
					self:breakPickup(p, i) -- 213
				end -- 213
			end -- 213
			::__continue41:: -- 213
			i = i - 1 -- 207
		end -- 207
	end -- 207
	return hits -- 215
end -- 205
function PickupSystem.prototype.clearAll(self) -- 218
	do -- 218
		local i = 0 -- 219
		while i < #self.pickups do -- 219
			self.pickups[i + 1].draw:removeFromParent() -- 220
			i = i + 1 -- 219
		end -- 219
	end -- 219
	__TS__ArraySetLength(self.pickups, 0) -- 219
end -- 218
function PickupSystem.prototype.collect(self, p) -- 226
	local player = ctx.player -- 227
	repeat -- 227
		local ____switch49 = p.kind -- 227
		local ____cond49 = ____switch49 == "exp" -- 227
		if ____cond49 then -- 227
			if ctx.onAddExp then -- 227
				ctx:onAddExp(p.value, p.pos) -- 230
			end -- 230
			break -- 231
		end -- 231
		____cond49 = ____cond49 or ____switch49 == "heal" -- 231
		if ____cond49 then -- 231
			if player ~= nil then -- 231
				player.hp = math.min(player.maxHp, player.hp + HEAL_AMOUNT) -- 234
			end -- 234
			break -- 236
		end -- 236
		____cond49 = ____cond49 or ____switch49 == "chest" -- 236
		if ____cond49 then -- 236
			self:openChest(p.pos) -- 238
			break -- 239
		end -- 239
		do -- 239
			break -- 241
		end -- 241
	until true -- 241
	if p.kind ~= "exp" and ctx.vfx then -- 241
		ctx.vfx:burst(p.pos, p.kind == "heal" and 5300336 or 16765514, 6, 80) -- 244
	end -- 244
end -- 226
function PickupSystem.prototype.openChest(self, pos) -- 248
	local player = ctx.player -- 249
	if rng:chance(0.5) then -- 249
		if ctx.onAddExp then -- 249
			ctx:onAddExp(CHEST_EXP, pos) -- 251
		end -- 251
	elseif player ~= nil then -- 251
		player.hp = math.min(player.maxHp, player.hp + HEAL_AMOUNT) -- 253
	end -- 253
end -- 248
function PickupSystem.prototype.breakPickup(self, p, index) -- 257
	if p.kind == "barrel" then -- 257
		local info = { -- 260
			amount = BARREL_DAMAGE, -- 261
			kind = "magic", -- 262
			crit = false, -- 263
			knockback = Vec2.zero, -- 264
			hitStop = 0.03, -- 265
			shake = 4, -- 266
			flash = true, -- 267
			source = "explosion" -- 268
		} -- 268
		if ctx.damageEnemiesInRadius then -- 268
			ctx:damageEnemiesInRadius(p.pos, BARREL_AOE, info) -- 271
		end -- 271
		if ctx.vfx then -- 271
			ctx.vfx:burst(p.pos, 16732208, 14, 180) -- 274
			ctx.vfx:ring(p.pos, 16732208, BARREL_AOE) -- 275
		end -- 275
		if ctx.feedback then -- 275
			ctx.feedback:shake(5) -- 277
		end -- 277
		self:spawn("exp", p.pos, 3) -- 278
	else -- 278
		self:spawn("exp", p.pos, 2) -- 281
		if rng:chance(0.25) then -- 281
			self:spawn("exp", p.pos, 2) -- 282
		end -- 282
	end -- 282
	self:removeAt(index) -- 284
end -- 257
function PickupSystem.prototype.removeAt(self, index) -- 287
	local p = self.pickups[index + 1] -- 288
	p.alive = false -- 289
	p.draw:removeFromParent() -- 290
	local last = #self.pickups - 1 -- 291
	self.pickups[index + 1] = self.pickups[last + 1] -- 292
	table.remove(self.pickups) -- 293
end -- 287
return ____exports -- 287