-- [ts]: Player.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local circleVerts -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Director = ____Dora.Director -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____GameContext = require("game.core.GameContext") -- 5
local ctx = ____GameContext.ctx -- 5
local ____Config = require("game.config.Config") -- 6
local Config = ____Config.Config -- 6
local ____MathUtils = require("game.utils.MathUtils") -- 7
local clamp = ____MathUtils.clamp -- 7
local normalize = ____MathUtils.normalize -- 7
local withAlpha = ____MathUtils.withAlpha -- 7
local ____RNG = require("game.utils.RNG") -- 8
local rng = ____RNG.rng -- 8
function circleVerts(radius, segments) -- 299
	local verts = {} -- 300
	do -- 300
		local i = 0 -- 301
		while i < segments do -- 301
			local a = i / segments * math.pi * 2 -- 302
			verts[#verts + 1] = Vec2( -- 303
				math.cos(a) * radius, -- 303
				math.sin(a) * radius -- 303
			) -- 303
			i = i + 1 -- 301
		end -- 301
	end -- 301
	return verts -- 305
end -- 305
____exports.Player = __TS__Class() -- 10
local Player = ____exports.Player -- 10
Player.name = "Player" -- 10
function Player.prototype.____constructor(self, character, root) -- 59
	self.hp = 100 -- 12
	self.maxHp = 100 -- 13
	self.level = 1 -- 14
	self.exp = 0 -- 15
	self.expNeed = 1 -- 16
	self.moveSpeed = 240 -- 17
	self.attackSpeed = 1 -- 18
	self.critChance = 0.1 -- 19
	self.critMulti = 1.5 -- 20
	self.damageBonus = 0 -- 21
	self.projectileCount = 1 -- 22
	self.pierce = 0 -- 23
	self.split = 0 -- 24
	self.lifesteal = 0 -- 25
	self.pickupRadius = 0 -- 26
	self.invincible = false -- 27
	self.invincibleTimer = 0 -- 28
	self.regen = 0 -- 29
	self.magnet = 0 -- 30
	self.isAlive = true -- 31
	self.dodge = 0 -- 33
	self.bulletSpeedMulti = 1 -- 34
	self.expMulti = 1 -- 35
	self.goldMulti = 1 -- 36
	self.thorns = 0 -- 37
	self.chain = 0 -- 38
	self.homing = 0 -- 39
	self.ricochet = 0 -- 40
	self.explosion = 0 -- 41
	self.slowAura = 0 -- 42
	self.burn = 0 -- 43
	self.poison = 0 -- 44
	self.freeze = 0 -- 45
	self.facing = 0 -- 48
	self.skillStacks = {} -- 50
	self.posValue = Vec2.zero -- 53
	self.nodeValue = Node() -- 54
	self.body = DrawNode() -- 55
	self.nameLabel = nil -- 56
	self.radius = 16 -- 57
	self.character = character -- 60
	local parent = root ~= nil and root or Director.entry -- 61
	self.nodeValue:addTo(parent) -- 62
	self.body:addTo(self.nodeValue) -- 63
	local label = Label("sarasa-mono-sc-regular", 12) -- 64
	if label ~= nil then -- 64
		label.text = character.name -- 66
		label.anchor = Vec2(0.5, 0.5) -- 67
		label.position = Vec2(0, self.radius + 14) -- 68
		label:addTo(self.nodeValue) -- 69
		self.nameLabel = label -- 70
	end -- 70
	ctx.player = self -- 73
	ctx.onAddExp = function(____, amount, _pos) return self:addExp(amount) end -- 75
	ctx.onPlayerDamaged = function(____, amount, from) return self:takeDamage(amount, from) end -- 76
	self:resetForNewGame() -- 77
end -- 59
function Player.prototype.resetForNewGame(self) -- 81
	self.maxHp = self.character.maxHp -- 82
	self.hp = self.maxHp -- 83
	self.level = 1 -- 84
	self.exp = 0 -- 85
	self.expNeed = self:calcExpNeed(1) -- 86
	self.moveSpeed = self.character.moveSpeed -- 87
	self.attackSpeed = 1 -- 88
	self.critChance = 0.1 -- 89
	self.critMulti = 1.5 -- 90
	self.damageBonus = 0 -- 91
	self.projectileCount = self.character.projectileCount -- 92
	self.pierce = self.character.pierce -- 93
	self.split = 0 -- 94
	self.lifesteal = 0 -- 95
	self.pickupRadius = Config.expPickupRadius -- 96
	self.invincible = false -- 97
	self.invincibleTimer = 0 -- 98
	self.regen = 0 -- 99
	self.magnet = 0 -- 100
	self.isAlive = true -- 101
	self.dodge = 0 -- 102
	self.bulletSpeedMulti = 1 -- 103
	self.expMulti = 1 -- 104
	self.goldMulti = 1 -- 105
	self.thorns = 0 -- 106
	self.chain = 0 -- 107
	self.homing = 0 -- 108
	self.ricochet = 0 -- 109
	self.explosion = 0 -- 110
	self.slowAura = 0 -- 111
	self.burn = 0 -- 112
	self.poison = 0 -- 113
	self.freeze = 0 -- 114
	self.facing = 0 -- 115
	self.posValue = Vec2.zero -- 116
	self.skillStacks = {} -- 117
	self.nodeValue.position = Vec2.zero -- 118
	self.nodeValue.visible = true -- 119
	self:redrawBody() -- 120
end -- 81
function Player.prototype.update(self, dt, inputDir) -- 132
	if not self.isAlive then -- 132
		return -- 133
	end -- 133
	if inputDir.length > 0.01 then -- 133
		local dir = normalize(inputDir) -- 136
		self.posValue = Vec2(self.posValue.x + dir.x * self.moveSpeed * dt, self.posValue.y + dir.y * self.moveSpeed * dt) -- 137
		self.facing = math.atan(dir.y, dir.x) -- 141
	end -- 141
	self.posValue = Vec2( -- 144
		clamp(self.posValue.x, -self.halfW, self.halfW), -- 145
		clamp(self.posValue.y, -self.halfH, self.halfH) -- 146
	) -- 146
	if self.invincibleTimer > 0 then -- 146
		self.invincibleTimer = self.invincibleTimer - dt -- 150
		if self.invincibleTimer <= 0 then -- 150
			self.invincibleTimer = 0 -- 152
			self.invincible = false -- 153
		end -- 153
	end -- 153
	if self.regen > 0 and self.hp < self.maxHp then -- 153
		self.hp = math.min(self.maxHp, self.hp + self.regen * dt) -- 158
	end -- 158
	if ctx.magnetPickups ~= nil then -- 158
		ctx:magnetPickups(self.posValue, self.pickupRadius + self.magnet) -- 162
	end -- 162
	self.nodeValue.position = Vec2(self.posValue.x, self.posValue.y) -- 165
	self:redrawBody() -- 166
end -- 132
function Player.prototype.addExp(self, amount) -- 170
	if not self.isAlive then -- 170
		return -- 171
	end -- 171
	self.exp = self.exp + amount * self.expMulti -- 172
	while self.exp >= self.expNeed do -- 172
		self.exp = self.exp - self.expNeed -- 174
		self.level = self.level + 1 -- 175
		self.expNeed = self:calcExpNeed(self.level) -- 176
		ctx.stats.playerLevel = self.level -- 177
		local ____this_1 -- 177
		____this_1 = ctx -- 178
		local ____opt_0 = ____this_1.onPlayerLevelUp -- 178
		if ____opt_0 ~= nil then -- 178
			____opt_0(____this_1) -- 178
		end -- 178
	end -- 178
end -- 170
function Player.prototype.takeDamage(self, amount, from) -- 183
	if not self.isAlive or self.invincible then -- 183
		return -- 184
	end -- 184
	if self.dodge > 0 and rng:chance(math.min(0.75, self.dodge)) then -- 184
		local ____opt_2 = ctx.vfx -- 184
		if ____opt_2 ~= nil then -- 184
			____opt_2:flash(self.posValue, 8444159, 22) -- 186
		end -- 186
		return -- 187
	end -- 187
	self.hp = self.hp - amount -- 189
	local ____ctx_stats_4, ____damageTaken_5 = ctx.stats, "damageTaken" -- 189
	____ctx_stats_4[____damageTaken_5] = ____ctx_stats_4[____damageTaken_5] + amount -- 190
	if self.thorns > 0 then -- 190
		local ____this_7 -- 190
		____this_7 = ctx -- 192
		local ____opt_6 = ____this_7.damageEnemiesInRadius -- 192
		if ____opt_6 ~= nil then -- 192
			____opt_6(____this_7, from, 42, { -- 192
				amount = amount * self.thorns, -- 193
				kind = "physical", -- 194
				crit = false, -- 195
				knockback = Vec2.zero, -- 196
				hitStop = 0, -- 197
				shake = 0, -- 198
				flash = true, -- 199
				source = "skill" -- 200
			}) -- 200
		end -- 200
	end -- 200
	if ctx.feedback ~= nil then -- 200
		ctx.feedback:spawnFlash(self.posValue, 16777215) -- 205
		ctx.feedback:shake(Config.shakeMedium) -- 206
		ctx.feedback:hitStop(0.02) -- 207
	end -- 207
	if self.hp <= 0 then -- 207
		self.hp = 0 -- 210
		self.isAlive = false -- 211
		self.nodeValue.visible = false -- 212
		local ____this_9 -- 212
		____this_9 = ctx -- 213
		local ____opt_8 = ____this_9.onGameOver -- 213
		if ____opt_8 ~= nil then -- 213
			____opt_8(____this_9) -- 213
		end -- 213
	else -- 213
		self.invincible = true -- 215
		self.invincibleTimer = self.skillStacks.invincible ~= nil and 1 or 0.45 -- 216
	end -- 216
end -- 183
function Player.prototype.heal(self, amount) -- 221
	if not self.isAlive then -- 221
		return -- 222
	end -- 222
	self.hp = math.min(self.maxHp, self.hp + amount) -- 223
end -- 221
function Player.prototype.calcExpNeed(self, level) -- 226
	return math.floor(Config.expBase * level ^ Config.expCurve) -- 227
end -- 226
function Player.prototype.redrawBody(self) -- 231
	self.body:clear() -- 232
	local color = Color(4278190080 | self.character.color) -- 233
	local outline = Color(withAlpha(16181971, 225)) -- 234
	local dark = Color(20, 28, 31, 255) -- 235
	local forward = Vec2( -- 236
		math.cos(self.facing), -- 236
		math.sin(self.facing) -- 236
	) -- 236
	local side = Vec2(-forward.y, forward.x) -- 237
	self.body:drawDot( -- 239
		Vec2(3, -5), -- 239
		self.radius + 7, -- 239
		Color(0, 0, 0, 90) -- 239
	) -- 239
	self.body:drawPolygon( -- 240
		circleVerts(self.radius, 18), -- 240
		color, -- 240
		3, -- 240
		outline -- 240
	) -- 240
	local face = Vec2(forward.x * 10, forward.y * 10) -- 242
	self.body:drawPolygon( -- 243
		{ -- 243
			Vec2(face.x + side.x * 7, face.y + side.y * 7), -- 244
			Vec2(face.x - side.x * 7, face.y - side.y * 7), -- 245
			Vec2(forward.x * 21, forward.y * 21) -- 246
		}, -- 246
		dark, -- 247
		2, -- 247
		outline -- 247
	) -- 247
	self.body:drawDot( -- 248
		Vec2(-forward.x * 4, -forward.y * 4), -- 248
		5, -- 248
		Color(236, 207, 137, 255) -- 248
	) -- 248
	self:drawClassSilhouette(forward, side, outline) -- 249
	if self.invincibleTimer > 0 and self.invincible then -- 249
		self.nodeValue.opacity = 0.5 -- 252
	else -- 252
		self.nodeValue.opacity = 1 -- 254
	end -- 254
end -- 231
function Player.prototype.drawClassSilhouette(self, forward, side, outline) -- 258
	local function tip(distance, lateral) -- 259
		if lateral == nil then -- 259
			lateral = 0 -- 259
		end -- 259
		return Vec2(forward.x * distance + side.x * lateral, forward.y * distance + side.y * lateral) -- 259
	end -- 259
	repeat -- 259
		local ____switch32 = self.character.id -- 259
		local ____cond32 = ____switch32 == "swordsman" -- 259
		if ____cond32 then -- 259
			self.body:drawSegment( -- 262
				tip(-3, -8), -- 262
				tip(31, -8), -- 262
				6, -- 262
				Color(211, 221, 220, 255) -- 262
			) -- 262
			self.body:drawSegment( -- 263
				tip(7, -14), -- 263
				tip(7, -2), -- 263
				4, -- 263
				Color(105, 71, 37, 255) -- 263
			) -- 263
			break -- 264
		end -- 264
		____cond32 = ____cond32 or ____switch32 == "mage" -- 264
		if ____cond32 then -- 264
			self.body:drawSegment( -- 266
				tip(-8, -10), -- 266
				tip(25, -10), -- 266
				4, -- 266
				Color(96, 68, 44, 255) -- 266
			) -- 266
			self.body:drawDot( -- 267
				tip(29, -10), -- 267
				7, -- 267
				Color(105, 182, 255, 255) -- 267
			) -- 267
			self.body:drawPolygon( -- 268
				{ -- 268
					tip(-10, 0), -- 268
					tip(-22, 13), -- 268
					tip(-22, -13) -- 268
				}, -- 268
				Color(43, 65, 109, 255), -- 268
				2, -- 268
				outline -- 268
			) -- 268
			break -- 269
		end -- 269
		____cond32 = ____cond32 or ____switch32 == "druid" -- 269
		if ____cond32 then -- 269
			self.body:drawSegment( -- 271
				tip(-4, -11), -- 271
				tip(25, -11), -- 271
				4, -- 271
				Color(93, 66, 38, 255) -- 271
			) -- 271
			self.body:drawSegment( -- 272
				tip(21, -11), -- 272
				tip(30, -17), -- 272
				3, -- 272
				Color(84, 179, 96, 255) -- 272
			) -- 272
			self.body:drawSegment( -- 273
				tip(21, -11), -- 273
				tip(30, -5), -- 273
				3, -- 273
				Color(84, 179, 96, 255) -- 273
			) -- 273
			break -- 274
		end -- 274
		____cond32 = ____cond32 or ____switch32 == "gunner" -- 274
		if ____cond32 then -- 274
			self.body:drawSegment( -- 276
				tip(1, -9), -- 276
				tip(30, -9), -- 276
				7, -- 276
				Color(56, 62, 67, 255) -- 276
			) -- 276
			self.body:drawSegment( -- 277
				tip(24, -13), -- 277
				tip(36, -13), -- 277
				3, -- 277
				Color(237, 191, 80, 255) -- 277
			) -- 277
			break -- 278
		end -- 278
		____cond32 = ____cond32 or ____switch32 == "necromancer" -- 278
		if ____cond32 then -- 278
			self.body:drawPolygon( -- 280
				{ -- 280
					tip(-4, 12), -- 280
					tip(-22, 19), -- 280
					tip(-17, 0) -- 280
				}, -- 280
				Color(73, 33, 84, 255), -- 280
				2, -- 280
				outline -- 280
			) -- 280
			self.body:drawSegment( -- 281
				tip(-5, -10), -- 281
				tip(26, -10), -- 281
				4, -- 281
				Color(79, 61, 45, 255) -- 281
			) -- 281
			self.body:drawDot( -- 282
				tip(29, -10), -- 282
				6, -- 282
				Color(193, 103, 238, 255) -- 282
			) -- 282
			break -- 283
		end -- 283
	until true -- 283
end -- 258
__TS__SetDescriptor( -- 258
	Player.prototype, -- 258
	"halfW", -- 258
	{get = function(self) -- 258
		return 1000 - 24 -- 125
	end}, -- 125
	true -- 125
) -- 125
__TS__SetDescriptor( -- 125
	Player.prototype, -- 125
	"halfH", -- 125
	{get = function(self) -- 125
		return 1000 - 24 -- 128
	end}, -- 128
	true -- 128
) -- 128
__TS__SetDescriptor( -- 128
	Player.prototype, -- 128
	"pos", -- 128
	{get = function(self) -- 128
		return self.posValue -- 289
	end}, -- 289
	true -- 289
) -- 289
__TS__SetDescriptor( -- 289
	Player.prototype, -- 289
	"node", -- 289
	{get = function(self) -- 289
		return self.nodeValue -- 292
	end}, -- 292
	true -- 292
) -- 292
__TS__SetDescriptor( -- 292
	Player.prototype, -- 292
	"characterDef", -- 292
	{get = function(self) -- 292
		return self.character -- 295
	end}, -- 295
	true -- 295
) -- 295
return ____exports -- 295