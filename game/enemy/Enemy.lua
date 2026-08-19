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
local ____AudioManager = require("game.audio.AudioManager") -- 9
local audio = ____AudioManager.audio -- 9
local Sfx = ____AudioManager.Sfx -- 9
function circleVerts(radius) -- 13
	local verts = {} -- 14
	do -- 14
		local i = 0 -- 15
		while i < SEGMENTS do -- 15
			local a = i / SEGMENTS * math.pi * 2 -- 16
			verts[#verts + 1] = Vec2( -- 17
				math.cos(a) * radius, -- 17
				math.sin(a) * radius -- 17
			) -- 17
			i = i + 1 -- 15
		end -- 15
	end -- 15
	return verts -- 19
end -- 19
function drawRing(draw, radius, segments, width, color) -- 338
	local points = circleVerts(radius) -- 339
	do -- 339
		local i = 0 -- 340
		while i < segments do -- 340
			local a1 = i / segments * math.pi * 2 -- 341
			local a2 = (i + 1) / segments * math.pi * 2 -- 342
			draw:drawSegment( -- 343
				Vec2( -- 343
					math.cos(a1) * radius, -- 343
					math.sin(a1) * radius -- 343
				), -- 343
				Vec2( -- 343
					math.cos(a2) * radius, -- 343
					math.sin(a2) * radius -- 343
				), -- 343
				width, -- 343
				color -- 343
			) -- 343
			i = i + 1 -- 340
		end -- 340
	end -- 340
end -- 340
SEGMENTS = 14 -- 11
local function splitColor(color) -- 23
	return { -- 24
		r = math.floor(color / 65536) % 256, -- 25
		g = math.floor(color / 256) % 256, -- 26
		b = color % 256 -- 27
	} -- 27
end -- 23
local function colorOf(color, alpha) -- 31
	if alpha == nil then -- 31
		alpha = 255 -- 31
	end -- 31
	local c = splitColor(color) -- 32
	return Color(c.r, c.g, c.b, alpha) -- 33
end -- 31
local nextEnemyId = 1 -- 36
____exports.Enemy = __TS__Class() -- 43
local Enemy = ____exports.Enemy -- 43
Enemy.name = "Enemy" -- 43
function Enemy.prototype.____constructor(self, def, spawnPos, root) -- 86
	self.isAlive = false -- 50
	self.hp = 0 -- 51
	self.markedDead = false -- 53
	self.velocity = Vec2.zero -- 58
	self.facing = 0 -- 59
	self.slowMult = 1 -- 60
	self.slowTimer = 0 -- 61
	self.freezeTimer = 0 -- 62
	self.flashTimer = 0 -- 63
	self.aiTimer = 0 -- 66
	self.shootTimer = 0 -- 67
	self.chargeState = 0 -- 68
	self.chargeTimer = 0 -- 69
	self.chargeDir = Vec2.zero -- 70
	self.suicideArmed = false -- 71
	self.isVisible = true -- 74
	self.showHealthTimer = 0 -- 84
	local ____nextEnemyId_0 = nextEnemyId -- 84
	nextEnemyId = ____nextEnemyId_0 + 1 -- 87
	self.id = ____nextEnemyId_0 -- 87
	self.def = def -- 88
	self.kind = def.kind -- 89
	self.radius = def.radius -- 90
	self.maxHp = def.maxHp -- 91
	self.color = def.color -- 92
	self.isElite = def.isElite -- 93
	self.isBoss = def.isBoss -- 94
	self.pos = spawnPos -- 95
	self.root = root -- 96
	self.nodeRef = Node() -- 97
	self.nodeRef.position = self.pos -- 98
	self.bodyDraw = DrawNode() -- 99
	self.flashDraw = DrawNode() -- 100
	self.healthDraw = DrawNode() -- 101
	self.bodyDraw:addTo(self.nodeRef) -- 102
	self.flashDraw:addTo(self.nodeRef) -- 103
	self.healthDraw:addTo(self.nodeRef) -- 104
	self:resetFromPool(spawnPos, def) -- 105
end -- 86
function Enemy.prototype.resetFromPool(self, pos, def) -- 113
	self.def = def -- 114
	self.kind = def.kind -- 115
	self.radius = def.radius -- 116
	self.maxHp = def.maxHp -- 117
	self.color = def.color -- 118
	self.isElite = def.isElite -- 119
	self.isBoss = def.isBoss -- 120
	self.isAlive = true -- 121
	self.markedDead = false -- 122
	self.hp = def.maxHp -- 123
	self.pos = pos -- 124
	self.velocity = Vec2.zero -- 125
	self.facing = 0 -- 126
	self.slowMult = 1 -- 127
	self.slowTimer = 0 -- 128
	self.freezeTimer = 0 -- 129
	self.flashTimer = 0 -- 130
	self.showHealthTimer = 0 -- 131
	self.aiTimer = 0 -- 132
	self.shootTimer = def.shootInterval ~= nil and def.shootInterval * 0.6 or 0 -- 133
	self.chargeState = 0 -- 134
	self.chargeTimer = 0 -- 135
	self.chargeDir = Vec2.zero -- 136
	self.suicideArmed = false -- 137
	self.isVisible = true -- 138
	self.nodeRef.position = self.pos -- 139
	self.nodeRef.visible = true -- 140
	if self.nodeRef.parent ~= self.root then -- 140
		self.nodeRef:addTo(self.root) -- 143
	end -- 143
	self:redrawVisual(def) -- 145
end -- 113
function Enemy.prototype.redrawVisual(self, def) -- 148
	self.bodyDraw:clear() -- 149
	self.flashDraw:clear() -- 150
	self.healthDraw:clear() -- 151
	local body = colorOf(def.color) -- 152
	local bright = Color(246, 232, 190, 255) -- 153
	self.bodyDraw:drawDot( -- 154
		Vec2(3, -4), -- 154
		def.radius + 5, -- 154
		Color(0, 0, 0, 90) -- 154
	) -- 154
	self.bodyDraw:drawPolygon( -- 155
		self:enemyShape(def), -- 155
		body, -- 155
		2.5, -- 155
		colorOf(15784896) -- 155
	) -- 155
	self:drawEnemyFeatures(def, bright) -- 156
	if def.isElite or def.isBoss then -- 156
		drawRing( -- 159
			self.bodyDraw, -- 159
			def.radius + 5, -- 159
			18, -- 159
			2, -- 159
			bright -- 159
		) -- 159
	end -- 159
	if def.isBoss then -- 159
		drawRing( -- 162
			self.bodyDraw, -- 162
			def.radius + 10, -- 162
			20, -- 162
			3, -- 162
			colorOf(7345439) -- 162
		) -- 162
	end -- 162
	if def.kind == "exploder" then -- 162
		drawRing( -- 166
			self.bodyDraw, -- 166
			def.radius * 0.55, -- 166
			12, -- 166
			2, -- 166
			Color(255, 220, 120, 255) -- 166
		) -- 166
	end -- 166
end -- 148
function Enemy.prototype.enemyShape(self, def) -- 170
	local r = def.radius -- 171
	repeat -- 171
		local ____switch15 = def.kind -- 171
		local ____cond15 = ____switch15 == "runner" -- 171
		if ____cond15 then -- 171
			return { -- 173
				Vec2(r, 0), -- 173
				Vec2(0, r * 0.8), -- 173
				Vec2(-r, 0), -- 173
				Vec2(0, -r * 0.8) -- 173
			} -- 173
		end -- 173
		____cond15 = ____cond15 or ____switch15 == "tank" -- 173
		if ____cond15 then -- 173
			return { -- 174
				Vec2(r, r * 0.55), -- 174
				Vec2(r * 0.55, r), -- 174
				Vec2(-r * 0.55, r), -- 174
				Vec2(-r, r * 0.55), -- 174
				Vec2(-r, -r * 0.55), -- 174
				Vec2(-r * 0.55, -r), -- 174
				Vec2(r * 0.55, -r), -- 174
				Vec2(r, -r * 0.55) -- 174
			} -- 174
		end -- 174
		____cond15 = ____cond15 or ____switch15 == "ranger" -- 174
		if ____cond15 then -- 174
			return { -- 175
				Vec2(r, 0), -- 175
				Vec2(r * 0.25, r), -- 175
				Vec2(-r * 0.85, r * 0.65), -- 175
				Vec2(-r * 0.85, -r * 0.65), -- 175
				Vec2(r * 0.25, -r) -- 175
			} -- 175
		end -- 175
		____cond15 = ____cond15 or ____switch15 == "charger" -- 175
		if ____cond15 then -- 175
			return { -- 176
				Vec2(r * 1.25, 0), -- 176
				Vec2(r * 0.15, r), -- 176
				Vec2(-r, r * 0.65), -- 176
				Vec2(-r, -r * 0.65), -- 176
				Vec2(r * 0.15, -r) -- 176
			} -- 176
		end -- 176
		____cond15 = ____cond15 or ____switch15 == "shield" -- 176
		if ____cond15 then -- 176
			return { -- 177
				Vec2(r, 0), -- 177
				Vec2(r * 0.55, r), -- 177
				Vec2(-r * 0.8, r), -- 177
				Vec2(-r, 0), -- 177
				Vec2(-r * 0.8, -r), -- 177
				Vec2(r * 0.55, -r) -- 177
			} -- 177
		end -- 177
		____cond15 = ____cond15 or ____switch15 == "exploder" -- 177
		if ____cond15 then -- 177
			return { -- 178
				Vec2(r, 0), -- 178
				Vec2(r * 0.45, r * 0.8), -- 178
				Vec2(-r * 0.45, r * 0.8), -- 178
				Vec2(-r, 0), -- 178
				Vec2(-r * 0.45, -r * 0.8), -- 178
				Vec2(r * 0.45, -r * 0.8) -- 178
			} -- 178
		end -- 178
		____cond15 = ____cond15 or ____switch15 == "elite" -- 178
		if ____cond15 then -- 178
			return { -- 179
				Vec2(r * 1.15, 0), -- 179
				Vec2(r * 0.55, r), -- 179
				Vec2(-r * 0.6, r), -- 179
				Vec2(-r, 0), -- 179
				Vec2(-r * 0.6, -r), -- 179
				Vec2(r * 0.55, -r) -- 179
			} -- 179
		end -- 179
		____cond15 = ____cond15 or ____switch15 == "boss" -- 179
		if ____cond15 then -- 179
			return { -- 180
				Vec2(r * 1.15, 0), -- 180
				Vec2(r * 0.7, r * 0.8), -- 180
				Vec2(0, r), -- 180
				Vec2(-r, r * 0.7), -- 180
				Vec2(-r * 0.85, 0), -- 180
				Vec2(-r, -r * 0.7), -- 180
				Vec2(0, -r), -- 180
				Vec2(r * 0.7, -r * 0.8) -- 180
			} -- 180
		end -- 180
		do -- 180
			return circleVerts(r) -- 181
		end -- 181
	until true -- 181
end -- 170
function Enemy.prototype.drawEnemyFeatures(self, def, bright) -- 185
	local r = def.radius -- 186
	self.bodyDraw:drawDot( -- 187
		Vec2(r * 0.38, r * 0.28), -- 187
		math.max(2, r * 0.14), -- 187
		bright -- 187
	) -- 187
	self.bodyDraw:drawDot( -- 188
		Vec2(r * 0.38, -r * 0.28), -- 188
		math.max(2, r * 0.14), -- 188
		bright -- 188
	) -- 188
	if def.kind == "tank" then -- 188
		self.bodyDraw:drawSegment( -- 190
			Vec2(-r * 0.45, r * 0.7), -- 190
			Vec2(r * 0.35, r * 0.7), -- 190
			5, -- 190
			Color(34, 60, 46, 255) -- 190
		) -- 190
		self.bodyDraw:drawSegment( -- 191
			Vec2(-r * 0.45, -r * 0.7), -- 191
			Vec2(r * 0.35, -r * 0.7), -- 191
			5, -- 191
			Color(34, 60, 46, 255) -- 191
		) -- 191
	elseif def.kind == "ranger" then -- 191
		self.bodyDraw:drawSegment( -- 193
			Vec2(r * 0.65, -r * 0.8), -- 193
			Vec2(r * 0.65, r * 0.8), -- 193
			2.5, -- 193
			Color(111, 232, 219, 255) -- 193
		) -- 193
	elseif def.kind == "charger" then -- 193
		self.bodyDraw:drawSegment( -- 195
			Vec2(r * 0.35, r * 0.75), -- 195
			Vec2(r * 1.35, r * 0.95), -- 195
			3, -- 195
			Color(255, 206, 113, 255) -- 195
		) -- 195
		self.bodyDraw:drawSegment( -- 196
			Vec2(r * 0.35, -r * 0.75), -- 196
			Vec2(r * 1.35, -r * 0.95), -- 196
			3, -- 196
			Color(255, 206, 113, 255) -- 196
		) -- 196
	elseif def.kind == "shield" then -- 196
		self.bodyDraw:drawSegment( -- 198
			Vec2(r * 0.75, -r), -- 198
			Vec2(r * 0.75, r), -- 198
			5, -- 198
			Color(190, 216, 247, 255) -- 198
		) -- 198
	elseif def.isBoss then -- 198
		self.bodyDraw:drawSegment( -- 200
			Vec2(-r * 0.3, r * 0.8), -- 200
			Vec2(-r * 0.55, r * 1.35), -- 200
			5, -- 200
			Color(238, 201, 114, 255) -- 200
		) -- 200
		self.bodyDraw:drawSegment( -- 201
			Vec2(-r * 0.3, -r * 0.8), -- 201
			Vec2(-r * 0.55, -r * 1.35), -- 201
			5, -- 201
			Color(238, 201, 114, 255) -- 201
		) -- 201
	end -- 201
end -- 185
function Enemy.prototype.update(self, dt, playerPos, dtScale, aiTick) -- 206
	if not self.isAlive or self.markedDead then -- 206
		return -- 207
	end -- 207
	if self.slowTimer > 0 then -- 207
		self.slowTimer = self.slowTimer - dt -- 210
		if self.slowTimer <= 0 then -- 210
			self.slowMult = 1 -- 211
		end -- 211
	end -- 211
	if self.freezeTimer > 0 then -- 211
		self.freezeTimer = self.freezeTimer - dt -- 215
		return -- 216
	end -- 216
	if self.flashTimer > 0 then -- 216
		self.flashTimer = self.flashTimer - dt -- 220
		if self.flashTimer <= 0 then -- 220
			self.flashDraw:clear() -- 221
		end -- 221
	end -- 221
	if self.showHealthTimer > 0 then -- 221
		self.showHealthTimer = self.showHealthTimer - dt -- 224
		self:redrawHealth() -- 225
	elseif not self.isBoss and not self.isElite then -- 225
		self.healthDraw:clear() -- 227
	end -- 227
	if aiTick then -- 227
		updateEnemyAI(self, playerPos, dt * Config.aiTickDivisor, dtScale) -- 230
	end -- 230
	self:applyKnockback(dt) -- 232
end -- 206
function Enemy.prototype.applyKnockback(self, dt) -- 236
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then -- 236
		self.pos = Vec2(self.pos.x + self.velocity.x * dt, self.pos.y + self.velocity.y * dt) -- 238
		self.velocity = Vec2(self.velocity.x * 0.86, self.velocity.y * 0.86) -- 239
	end -- 239
	self.nodeRef.position = self.pos -- 241
end -- 236
function Enemy.prototype.takeDamage(self, info) -- 244
	if not self.isAlive or self.markedDead then -- 244
		return -- 245
	end -- 245
	local amount = info.amount -- 246
	if self.def.ai == "shield" then -- 246
		local fdot = info.knockback.x * math.cos(self.facing) + info.knockback.y * math.sin(self.facing) -- 250
		if fdot <= 0.001 then -- 250
			amount = amount * 0.5 -- 251
		end -- 251
	end -- 251
	self.hp = self.hp - amount -- 253
	self.showHealthTimer = 1.8 -- 254
	self:redrawHealth() -- 255
	if info.flash then -- 255
		self.flashTimer = 0.08 -- 258
		self.flashDraw:clear() -- 259
		self.flashDraw:drawPolygon( -- 260
			circleVerts(self.radius + 1), -- 260
			Color(255, 255, 255, 220) -- 260
		) -- 260
	end -- 260
	if info.knockback.x ~= 0 or info.knockback.y ~= 0 then -- 260
		self.velocity = Vec2(self.velocity.x + info.knockback.x, self.velocity.y + info.knockback.y) -- 264
	end -- 264
	if self.hp <= 0 then -- 264
		self:die() -- 267
	end -- 267
end -- 244
function Enemy.prototype.redrawHealth(self) -- 271
	self.healthDraw:clear() -- 272
	if self.hp >= self.maxHp and not self.isBoss and not self.isElite then -- 272
		return -- 273
	end -- 273
	local w = self.isBoss and 92 or (self.isElite and 58 or 42) -- 274
	local y = self.radius + (self.isBoss and 24 or 15) -- 275
	local ratio = math.max( -- 276
		0, -- 276
		math.min(1, self.hp / self.maxHp) -- 276
	) -- 276
	self.healthDraw:drawPolygon( -- 277
		{ -- 277
			Vec2(-w / 2, y), -- 277
			Vec2(w / 2, y), -- 277
			Vec2(w / 2, y + 6), -- 277
			Vec2(-w / 2, y + 6) -- 277
		}, -- 277
		Color(15, 18, 20, 230) -- 277
	) -- 277
	self.healthDraw:drawPolygon( -- 278
		{ -- 278
			Vec2(-w / 2 + 1, y + 1), -- 278
			Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 1), -- 278
			Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 5), -- 278
			Vec2(-w / 2 + 1, y + 5) -- 278
		}, -- 278
		Color(self.isBoss and 215 or 224, self.isBoss and 54 or 75, self.isBoss and 65 or 82, 255) -- 278
	) -- 278
end -- 271
function Enemy.prototype.knockback(self, force) -- 281
	if not self.isAlive then -- 281
		return -- 282
	end -- 282
	self.velocity = Vec2(self.velocity.x + force.x, self.velocity.y + force.y) -- 283
end -- 281
function Enemy.prototype.slowdown(self, mult, duration) -- 286
	self.slowMult = math.min(self.slowMult, mult) -- 287
	self.slowTimer = math.max(self.slowTimer, duration) -- 288
end -- 286
function Enemy.prototype.freeze(self, duration) -- 291
	self.freezeTimer = math.max(self.freezeTimer, duration) -- 292
end -- 291
function Enemy.prototype.applyWaveBoost(self, hpMult) -- 296
	self.hp = self.maxHp * hpMult -- 297
end -- 296
function Enemy.prototype.die(self) -- 301
	if not self.isAlive or self.markedDead then -- 301
		return -- 302
	end -- 302
	self.isAlive = false -- 303
	self.markedDead = true -- 304
	local ____ctx_stats_1, ____kills_2 = ctx.stats, "kills" -- 304
	____ctx_stats_1[____kills_2] = ____ctx_stats_1[____kills_2] + 1 -- 305
	if self.isElite then -- 305
		local ____ctx_stats_3, ____eliteKills_4 = ctx.stats, "eliteKills" -- 305
		____ctx_stats_3[____eliteKills_4] = ____ctx_stats_3[____eliteKills_4] + 1 -- 306
	end -- 306
	if self.isBoss then -- 306
		local ____ctx_stats_5, ____bossKills_6 = ctx.stats, "bossKills" -- 306
		____ctx_stats_5[____bossKills_6] = ____ctx_stats_5[____bossKills_6] + 1 -- 307
	end -- 307
	if self.isElite or self.isBoss then -- 307
		audio:playSfx(Sfx.EliteDown, 0.2) -- 308
	end -- 308
	if ctx.vfx then -- 308
		ctx.vfx:burst(self.pos, self.color, self.isBoss and 26 or (self.isElite and 16 or 8), self.isBoss and 240 or 140) -- 311
		ctx.vfx:ring(self.pos, self.color, self.isBoss and 90 or 40) -- 312
	end -- 312
	if ctx.feedback then -- 312
		ctx.feedback:spawnDamageText(self.pos, self.def.exp, false) -- 315
		if self.isBoss then -- 315
			ctx.feedback:shake(10) -- 316
		elseif self.isElite then -- 316
			ctx.feedback:shake(6) -- 317
		else -- 317
			ctx.feedback:shake(3) -- 318
		end -- 318
	end -- 318
	if ctx.onEnemyDied then -- 318
		ctx:onEnemyDied(self, self.def.exp, self.pos, self.kind) -- 321
	end -- 321
	self.nodeRef.visible = false -- 323
end -- 301
function Enemy.prototype.clearForPool(self) -- 327
	self.isAlive = false -- 328
	self.markedDead = true -- 329
	self.bodyDraw:clear() -- 330
	self.flashDraw:clear() -- 331
	self.healthDraw:clear() -- 332
	self.nodeRef.visible = false -- 333
	self.bulletManager = nil -- 334
end -- 327
__TS__SetDescriptor( -- 327
	Enemy.prototype, -- 327
	"node", -- 327
	{get = function(self) -- 327
		return self.nodeRef -- 109
	end}, -- 109
	true -- 109
) -- 109
local enemyRoot -- 348
function ____exports.setEnemyPoolRoot(root) -- 349
	enemyRoot = root -- 350
end -- 349
____exports.enemyPool = __TS__New( -- 353
	ObjectPool, -- 353
	function() return __TS__New( -- 354
		____exports.Enemy, -- 354
		getEnemyDef("walker"), -- 354
		Vec2.zero, -- 354
		enemyRoot or Node() -- 354
	) end, -- 354
	function(item) -- 355
		item:clearForPool() -- 356
	end -- 355
) -- 355
return ____exports -- 355