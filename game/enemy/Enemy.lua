-- [ts]: Enemy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local circleVerts, drawRing, SEGMENTS -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____Config = require("game.config.Config") -- 5
local Config = ____Config.Config -- 5
local ____ObjectPool = require("game.utils.ObjectPool") -- 6
local ObjectPool = ____ObjectPool.ObjectPool -- 6
local ____EnemyAI = require("game.enemy.EnemyAI") -- 7
local updateEnemyAI = ____EnemyAI.updateEnemyAI -- 7
local ____EnemyTypes = require("game.enemy.EnemyTypes") -- 8
local getEnemyDef = ____EnemyTypes.getEnemyDef -- 8
function circleVerts(radius) -- 12
	local verts = {} -- 13
	do -- 13
		local i = 0 -- 14
		while i < SEGMENTS do -- 14
			local a = i / SEGMENTS * math.pi * 2 -- 15
			verts[#verts + 1] = Vec2( -- 16
				math.cos(a) * radius, -- 16
				math.sin(a) * radius -- 16
			) -- 16
			i = i + 1 -- 14
		end -- 14
	end -- 14
	return verts -- 18
end -- 18
function drawRing(draw, radius, segments, width, color) -- 336
	local points = circleVerts(radius) -- 337
	do -- 337
		local i = 0 -- 338
		while i < segments do -- 338
			local a1 = i / segments * math.pi * 2 -- 339
			local a2 = (i + 1) / segments * math.pi * 2 -- 340
			draw:drawSegment( -- 341
				Vec2( -- 341
					math.cos(a1) * radius, -- 341
					math.sin(a1) * radius -- 341
				), -- 341
				Vec2( -- 341
					math.cos(a2) * radius, -- 341
					math.sin(a2) * radius -- 341
				), -- 341
				width, -- 341
				color -- 341
			) -- 341
			i = i + 1 -- 338
		end -- 338
	end -- 338
end -- 338
SEGMENTS = 14 -- 10
local function splitColor(color) -- 22
	return { -- 23
		r = math.floor(color / 65536) % 256, -- 24
		g = math.floor(color / 256) % 256, -- 25
		b = color % 256 -- 26
	} -- 26
end -- 22
local function colorOf(color, alpha) -- 30
	if alpha == nil then -- 30
		alpha = 255 -- 30
	end -- 30
	local c = splitColor(color) -- 31
	return Color(c.r, c.g, c.b, alpha) -- 32
end -- 30
local nextEnemyId = 1 -- 35
____exports.Enemy = __TS__Class() -- 42
local Enemy = ____exports.Enemy -- 42
Enemy.name = "Enemy" -- 42
function Enemy.prototype.____constructor(self, def, spawnPos, root) -- 85
	self.isAlive = false -- 49
	self.hp = 0 -- 50
	self.markedDead = false -- 52
	self.velocity = Vec2.zero -- 57
	self.facing = 0 -- 58
	self.slowMult = 1 -- 59
	self.slowTimer = 0 -- 60
	self.freezeTimer = 0 -- 61
	self.flashTimer = 0 -- 62
	self.aiTimer = 0 -- 65
	self.shootTimer = 0 -- 66
	self.chargeState = 0 -- 67
	self.chargeTimer = 0 -- 68
	self.chargeDir = Vec2.zero -- 69
	self.suicideArmed = false -- 70
	self.isVisible = true -- 73
	self.showHealthTimer = 0 -- 83
	local ____nextEnemyId_0 = nextEnemyId -- 83
	nextEnemyId = ____nextEnemyId_0 + 1 -- 86
	self.id = ____nextEnemyId_0 -- 86
	self.def = def -- 87
	self.kind = def.kind -- 88
	self.radius = def.radius -- 89
	self.maxHp = def.maxHp -- 90
	self.color = def.color -- 91
	self.isElite = def.isElite -- 92
	self.isBoss = def.isBoss -- 93
	self.pos = spawnPos -- 94
	self.root = root -- 95
	self.nodeRef = Node() -- 96
	self.nodeRef.position = self.pos -- 97
	self.bodyDraw = DrawNode() -- 98
	self.flashDraw = DrawNode() -- 99
	self.healthDraw = DrawNode() -- 100
	self.bodyDraw:addTo(self.nodeRef) -- 101
	self.flashDraw:addTo(self.nodeRef) -- 102
	self.healthDraw:addTo(self.nodeRef) -- 103
	self:resetFromPool(spawnPos, def) -- 104
end -- 85
function Enemy.prototype.resetFromPool(self, pos, def) -- 112
	self.def = def -- 113
	self.kind = def.kind -- 114
	self.radius = def.radius -- 115
	self.maxHp = def.maxHp -- 116
	self.color = def.color -- 117
	self.isElite = def.isElite -- 118
	self.isBoss = def.isBoss -- 119
	self.isAlive = true -- 120
	self.markedDead = false -- 121
	self.hp = def.maxHp -- 122
	self.pos = pos -- 123
	self.velocity = Vec2.zero -- 124
	self.facing = 0 -- 125
	self.slowMult = 1 -- 126
	self.slowTimer = 0 -- 127
	self.freezeTimer = 0 -- 128
	self.flashTimer = 0 -- 129
	self.showHealthTimer = 0 -- 130
	self.aiTimer = 0 -- 131
	self.shootTimer = def.shootInterval ~= nil and def.shootInterval * 0.6 or 0 -- 132
	self.chargeState = 0 -- 133
	self.chargeTimer = 0 -- 134
	self.chargeDir = Vec2.zero -- 135
	self.suicideArmed = false -- 136
	self.isVisible = true -- 137
	self.nodeRef.position = self.pos -- 138
	self.nodeRef.visible = true -- 139
	if self.nodeRef.parent ~= self.root then -- 139
		self.nodeRef:addTo(self.root) -- 142
	end -- 142
	self:redrawVisual(def) -- 144
end -- 112
function Enemy.prototype.redrawVisual(self, def) -- 147
	self.bodyDraw:clear() -- 148
	self.flashDraw:clear() -- 149
	self.healthDraw:clear() -- 150
	local body = colorOf(def.color) -- 151
	local bright = Color(246, 232, 190, 255) -- 152
	self.bodyDraw:drawDot( -- 153
		Vec2(3, -4), -- 153
		def.radius + 5, -- 153
		Color(0, 0, 0, 90) -- 153
	) -- 153
	self.bodyDraw:drawPolygon( -- 154
		self:enemyShape(def), -- 154
		body, -- 154
		2.5, -- 154
		colorOf(15784896) -- 154
	) -- 154
	self:drawEnemyFeatures(def, bright) -- 155
	if def.isElite or def.isBoss then -- 155
		drawRing( -- 158
			self.bodyDraw, -- 158
			def.radius + 5, -- 158
			18, -- 158
			2, -- 158
			bright -- 158
		) -- 158
	end -- 158
	if def.isBoss then -- 158
		drawRing( -- 161
			self.bodyDraw, -- 161
			def.radius + 10, -- 161
			20, -- 161
			3, -- 161
			colorOf(7345439) -- 161
		) -- 161
	end -- 161
	if def.kind == "exploder" then -- 161
		drawRing( -- 165
			self.bodyDraw, -- 165
			def.radius * 0.55, -- 165
			12, -- 165
			2, -- 165
			Color(255, 220, 120, 255) -- 165
		) -- 165
	end -- 165
end -- 147
function Enemy.prototype.enemyShape(self, def) -- 169
	local r = def.radius -- 170
	repeat -- 170
		local ____switch15 = def.kind -- 170
		local ____cond15 = ____switch15 == "runner" -- 170
		if ____cond15 then -- 170
			return { -- 172
				Vec2(r, 0), -- 172
				Vec2(0, r * 0.8), -- 172
				Vec2(-r, 0), -- 172
				Vec2(0, -r * 0.8) -- 172
			} -- 172
		end -- 172
		____cond15 = ____cond15 or ____switch15 == "tank" -- 172
		if ____cond15 then -- 172
			return { -- 173
				Vec2(r, r * 0.55), -- 173
				Vec2(r * 0.55, r), -- 173
				Vec2(-r * 0.55, r), -- 173
				Vec2(-r, r * 0.55), -- 173
				Vec2(-r, -r * 0.55), -- 173
				Vec2(-r * 0.55, -r), -- 173
				Vec2(r * 0.55, -r), -- 173
				Vec2(r, -r * 0.55) -- 173
			} -- 173
		end -- 173
		____cond15 = ____cond15 or ____switch15 == "ranger" -- 173
		if ____cond15 then -- 173
			return { -- 174
				Vec2(r, 0), -- 174
				Vec2(r * 0.25, r), -- 174
				Vec2(-r * 0.85, r * 0.65), -- 174
				Vec2(-r * 0.85, -r * 0.65), -- 174
				Vec2(r * 0.25, -r) -- 174
			} -- 174
		end -- 174
		____cond15 = ____cond15 or ____switch15 == "charger" -- 174
		if ____cond15 then -- 174
			return { -- 175
				Vec2(r * 1.25, 0), -- 175
				Vec2(r * 0.15, r), -- 175
				Vec2(-r, r * 0.65), -- 175
				Vec2(-r, -r * 0.65), -- 175
				Vec2(r * 0.15, -r) -- 175
			} -- 175
		end -- 175
		____cond15 = ____cond15 or ____switch15 == "shield" -- 175
		if ____cond15 then -- 175
			return { -- 176
				Vec2(r, 0), -- 176
				Vec2(r * 0.55, r), -- 176
				Vec2(-r * 0.8, r), -- 176
				Vec2(-r, 0), -- 176
				Vec2(-r * 0.8, -r), -- 176
				Vec2(r * 0.55, -r) -- 176
			} -- 176
		end -- 176
		____cond15 = ____cond15 or ____switch15 == "exploder" -- 176
		if ____cond15 then -- 176
			return { -- 177
				Vec2(r, 0), -- 177
				Vec2(r * 0.45, r * 0.8), -- 177
				Vec2(-r * 0.45, r * 0.8), -- 177
				Vec2(-r, 0), -- 177
				Vec2(-r * 0.45, -r * 0.8), -- 177
				Vec2(r * 0.45, -r * 0.8) -- 177
			} -- 177
		end -- 177
		____cond15 = ____cond15 or ____switch15 == "elite" -- 177
		if ____cond15 then -- 177
			return { -- 178
				Vec2(r * 1.15, 0), -- 178
				Vec2(r * 0.55, r), -- 178
				Vec2(-r * 0.6, r), -- 178
				Vec2(-r, 0), -- 178
				Vec2(-r * 0.6, -r), -- 178
				Vec2(r * 0.55, -r) -- 178
			} -- 178
		end -- 178
		____cond15 = ____cond15 or ____switch15 == "boss" -- 178
		if ____cond15 then -- 178
			return { -- 179
				Vec2(r * 1.15, 0), -- 179
				Vec2(r * 0.7, r * 0.8), -- 179
				Vec2(0, r), -- 179
				Vec2(-r, r * 0.7), -- 179
				Vec2(-r * 0.85, 0), -- 179
				Vec2(-r, -r * 0.7), -- 179
				Vec2(0, -r), -- 179
				Vec2(r * 0.7, -r * 0.8) -- 179
			} -- 179
		end -- 179
		do -- 179
			return circleVerts(r) -- 180
		end -- 180
	until true -- 180
end -- 169
function Enemy.prototype.drawEnemyFeatures(self, def, bright) -- 184
	local r = def.radius -- 185
	self.bodyDraw:drawDot( -- 186
		Vec2(r * 0.38, r * 0.28), -- 186
		math.max(2, r * 0.14), -- 186
		bright -- 186
	) -- 186
	self.bodyDraw:drawDot( -- 187
		Vec2(r * 0.38, -r * 0.28), -- 187
		math.max(2, r * 0.14), -- 187
		bright -- 187
	) -- 187
	if def.kind == "tank" then -- 187
		self.bodyDraw:drawSegment( -- 189
			Vec2(-r * 0.45, r * 0.7), -- 189
			Vec2(r * 0.35, r * 0.7), -- 189
			5, -- 189
			Color(34, 60, 46, 255) -- 189
		) -- 189
		self.bodyDraw:drawSegment( -- 190
			Vec2(-r * 0.45, -r * 0.7), -- 190
			Vec2(r * 0.35, -r * 0.7), -- 190
			5, -- 190
			Color(34, 60, 46, 255) -- 190
		) -- 190
	elseif def.kind == "ranger" then -- 190
		self.bodyDraw:drawSegment( -- 192
			Vec2(r * 0.65, -r * 0.8), -- 192
			Vec2(r * 0.65, r * 0.8), -- 192
			2.5, -- 192
			Color(111, 232, 219, 255) -- 192
		) -- 192
	elseif def.kind == "charger" then -- 192
		self.bodyDraw:drawSegment( -- 194
			Vec2(r * 0.35, r * 0.75), -- 194
			Vec2(r * 1.35, r * 0.95), -- 194
			3, -- 194
			Color(255, 206, 113, 255) -- 194
		) -- 194
		self.bodyDraw:drawSegment( -- 195
			Vec2(r * 0.35, -r * 0.75), -- 195
			Vec2(r * 1.35, -r * 0.95), -- 195
			3, -- 195
			Color(255, 206, 113, 255) -- 195
		) -- 195
	elseif def.kind == "shield" then -- 195
		self.bodyDraw:drawSegment( -- 197
			Vec2(r * 0.75, -r), -- 197
			Vec2(r * 0.75, r), -- 197
			5, -- 197
			Color(190, 216, 247, 255) -- 197
		) -- 197
	elseif def.isBoss then -- 197
		self.bodyDraw:drawSegment( -- 199
			Vec2(-r * 0.3, r * 0.8), -- 199
			Vec2(-r * 0.55, r * 1.35), -- 199
			5, -- 199
			Color(238, 201, 114, 255) -- 199
		) -- 199
		self.bodyDraw:drawSegment( -- 200
			Vec2(-r * 0.3, -r * 0.8), -- 200
			Vec2(-r * 0.55, -r * 1.35), -- 200
			5, -- 200
			Color(238, 201, 114, 255) -- 200
		) -- 200
	end -- 200
end -- 184
function Enemy.prototype.update(self, dt, playerPos, dtScale, aiTick) -- 205
	if not self.isAlive or self.markedDead then -- 205
		return -- 206
	end -- 206
	if self.slowTimer > 0 then -- 206
		self.slowTimer = self.slowTimer - dt -- 209
		if self.slowTimer <= 0 then -- 209
			self.slowMult = 1 -- 210
		end -- 210
	end -- 210
	if self.freezeTimer > 0 then -- 210
		self.freezeTimer = self.freezeTimer - dt -- 214
		return -- 215
	end -- 215
	if self.flashTimer > 0 then -- 215
		self.flashTimer = self.flashTimer - dt -- 219
		if self.flashTimer <= 0 then -- 219
			self.flashDraw:clear() -- 220
		end -- 220
	end -- 220
	if self.showHealthTimer > 0 then -- 220
		self.showHealthTimer = self.showHealthTimer - dt -- 223
		self:redrawHealth() -- 224
	elseif not self.isBoss and not self.isElite then -- 224
		self.healthDraw:clear() -- 226
	end -- 226
	if aiTick then -- 226
		updateEnemyAI(self, playerPos, dt * Config.aiTickDivisor, dtScale) -- 229
	end -- 229
	self:applyKnockback(dt) -- 231
end -- 205
function Enemy.prototype.applyKnockback(self, dt) -- 235
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then -- 235
		self.pos = Vec2(self.pos.x + self.velocity.x * dt, self.pos.y + self.velocity.y * dt) -- 237
		self.velocity = Vec2(self.velocity.x * 0.86, self.velocity.y * 0.86) -- 238
	end -- 238
	self.nodeRef.position = self.pos -- 240
end -- 235
function Enemy.prototype.takeDamage(self, info) -- 243
	if not self.isAlive or self.markedDead then -- 243
		return -- 244
	end -- 244
	local amount = info.amount -- 245
	if self.def.ai == "shield" then -- 245
		local fdot = info.knockback.x * math.cos(self.facing) + info.knockback.y * math.sin(self.facing) -- 249
		if fdot <= 0.001 then -- 249
			amount = amount * 0.5 -- 250
		end -- 250
	end -- 250
	self.hp = self.hp - amount -- 252
	self.showHealthTimer = 1.8 -- 253
	self:redrawHealth() -- 254
	if info.flash then -- 254
		self.flashTimer = 0.08 -- 257
		self.flashDraw:clear() -- 258
		self.flashDraw:drawPolygon( -- 259
			circleVerts(self.radius + 1), -- 259
			Color(255, 255, 255, 220) -- 259
		) -- 259
	end -- 259
	if info.knockback.x ~= 0 or info.knockback.y ~= 0 then -- 259
		self.velocity = Vec2(self.velocity.x + info.knockback.x, self.velocity.y + info.knockback.y) -- 263
	end -- 263
	if self.hp <= 0 then -- 263
		self:die() -- 266
	end -- 266
end -- 243
function Enemy.prototype.redrawHealth(self) -- 270
	self.healthDraw:clear() -- 271
	if self.hp >= self.maxHp and not self.isBoss and not self.isElite then -- 271
		return -- 272
	end -- 272
	local w = self.isBoss and 92 or (self.isElite and 58 or 42) -- 273
	local y = self.radius + (self.isBoss and 24 or 15) -- 274
	local ratio = math.max( -- 275
		0, -- 275
		math.min(1, self.hp / self.maxHp) -- 275
	) -- 275
	self.healthDraw:drawPolygon( -- 276
		{ -- 276
			Vec2(-w / 2, y), -- 276
			Vec2(w / 2, y), -- 276
			Vec2(w / 2, y + 6), -- 276
			Vec2(-w / 2, y + 6) -- 276
		}, -- 276
		Color(15, 18, 20, 230) -- 276
	) -- 276
	self.healthDraw:drawPolygon( -- 277
		{ -- 277
			Vec2(-w / 2 + 1, y + 1), -- 277
			Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 1), -- 277
			Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 5), -- 277
			Vec2(-w / 2 + 1, y + 5) -- 277
		}, -- 277
		Color(self.isBoss and 215 or 224, self.isBoss and 54 or 75, self.isBoss and 65 or 82, 255) -- 277
	) -- 277
end -- 270
function Enemy.prototype.knockback(self, force) -- 280
	if not self.isAlive then -- 280
		return -- 281
	end -- 281
	self.velocity = Vec2(self.velocity.x + force.x, self.velocity.y + force.y) -- 282
end -- 280
function Enemy.prototype.slowdown(self, mult, duration) -- 285
	self.slowMult = math.min(self.slowMult, mult) -- 286
	self.slowTimer = math.max(self.slowTimer, duration) -- 287
end -- 285
function Enemy.prototype.freeze(self, duration) -- 290
	self.freezeTimer = math.max(self.freezeTimer, duration) -- 291
end -- 290
function Enemy.prototype.applyWaveBoost(self, hpMult) -- 295
	self.hp = self.maxHp * hpMult -- 296
end -- 295
function Enemy.prototype.die(self) -- 300
	if not self.isAlive or self.markedDead then -- 300
		return -- 301
	end -- 301
	self.isAlive = false -- 302
	self.markedDead = true -- 303
	local ____ctx_stats_1, ____kills_2 = ctx.stats, "kills" -- 303
	____ctx_stats_1[____kills_2] = ____ctx_stats_1[____kills_2] + 1 -- 304
	if self.isElite then -- 304
		local ____ctx_stats_3, ____eliteKills_4 = ctx.stats, "eliteKills" -- 304
		____ctx_stats_3[____eliteKills_4] = ____ctx_stats_3[____eliteKills_4] + 1 -- 305
	end -- 305
	if self.isBoss then -- 305
		local ____ctx_stats_5, ____bossKills_6 = ctx.stats, "bossKills" -- 305
		____ctx_stats_5[____bossKills_6] = ____ctx_stats_5[____bossKills_6] + 1 -- 306
	end -- 306
	if ctx.vfx then -- 306
		ctx.vfx:burst(self.pos, self.color, self.isBoss and 26 or (self.isElite and 16 or 8), self.isBoss and 240 or 140) -- 309
		ctx.vfx:ring(self.pos, self.color, self.isBoss and 90 or 40) -- 310
	end -- 310
	if ctx.feedback then -- 310
		ctx.feedback:spawnDamageText(self.pos, self.def.exp, false) -- 313
		if self.isBoss then -- 313
			ctx.feedback:shake(10) -- 314
		elseif self.isElite then -- 314
			ctx.feedback:shake(6) -- 315
		else -- 315
			ctx.feedback:shake(3) -- 316
		end -- 316
	end -- 316
	if ctx.onEnemyDied then -- 316
		ctx:onEnemyDied(self, self.def.exp, self.pos, self.kind) -- 319
	end -- 319
	self.nodeRef.visible = false -- 321
end -- 300
function Enemy.prototype.clearForPool(self) -- 325
	self.isAlive = false -- 326
	self.markedDead = true -- 327
	self.bodyDraw:clear() -- 328
	self.flashDraw:clear() -- 329
	self.healthDraw:clear() -- 330
	self.nodeRef.visible = false -- 331
	self.bulletManager = nil -- 332
end -- 325
__TS__SetDescriptor( -- 325
	Enemy.prototype, -- 325
	"node", -- 325
	{get = function(self) -- 325
		return self.nodeRef -- 108
	end}, -- 108
	true -- 108
) -- 108
local enemyRoot -- 346
function ____exports.setEnemyPoolRoot(root) -- 347
	enemyRoot = root -- 348
end -- 347
____exports.enemyPool = __TS__New( -- 351
	ObjectPool, -- 351
	function() return __TS__New( -- 352
		____exports.Enemy, -- 352
		getEnemyDef("walker"), -- 352
		Vec2.zero, -- 352
		enemyRoot or Node() -- 352
	) end, -- 352
	function(item) -- 353
		item:clearForPool() -- 354
	end -- 353
) -- 353
return ____exports -- 353