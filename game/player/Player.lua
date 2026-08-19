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
local ____AudioManager = require("game.audio.AudioManager") -- 9
local audio = ____AudioManager.audio -- 9
local Sfx = ____AudioManager.Sfx -- 9
function circleVerts(radius, segments) -- 301
	local verts = {} -- 302
	do -- 302
		local i = 0 -- 303
		while i < segments do -- 303
			local a = i / segments * math.pi * 2 -- 304
			verts[#verts + 1] = Vec2( -- 305
				math.cos(a) * radius, -- 305
				math.sin(a) * radius -- 305
			) -- 305
			i = i + 1 -- 303
		end -- 303
	end -- 303
	return verts -- 307
end -- 307
____exports.Player = __TS__Class() -- 11
local Player = ____exports.Player -- 11
Player.name = "Player" -- 11
function Player.prototype.____constructor(self, character, root) -- 60
	self.hp = 100 -- 13
	self.maxHp = 100 -- 14
	self.level = 1 -- 15
	self.exp = 0 -- 16
	self.expNeed = 1 -- 17
	self.moveSpeed = 240 -- 18
	self.attackSpeed = 1 -- 19
	self.critChance = 0.1 -- 20
	self.critMulti = 1.5 -- 21
	self.damageBonus = 0 -- 22
	self.projectileCount = 1 -- 23
	self.pierce = 0 -- 24
	self.split = 0 -- 25
	self.lifesteal = 0 -- 26
	self.pickupRadius = 0 -- 27
	self.invincible = false -- 28
	self.invincibleTimer = 0 -- 29
	self.regen = 0 -- 30
	self.magnet = 0 -- 31
	self.isAlive = true -- 32
	self.dodge = 0 -- 34
	self.bulletSpeedMulti = 1 -- 35
	self.expMulti = 1 -- 36
	self.goldMulti = 1 -- 37
	self.thorns = 0 -- 38
	self.chain = 0 -- 39
	self.homing = 0 -- 40
	self.ricochet = 0 -- 41
	self.explosion = 0 -- 42
	self.slowAura = 0 -- 43
	self.burn = 0 -- 44
	self.poison = 0 -- 45
	self.freeze = 0 -- 46
	self.facing = 0 -- 49
	self.skillStacks = {} -- 51
	self.posValue = Vec2.zero -- 54
	self.nodeValue = Node() -- 55
	self.body = DrawNode() -- 56
	self.nameLabel = nil -- 57
	self.radius = 16 -- 58
	self.character = character -- 61
	local parent = root ~= nil and root or Director.entry -- 62
	self.nodeValue:addTo(parent) -- 63
	self.body:addTo(self.nodeValue) -- 64
	local label = Label("sarasa-mono-sc-regular", 12) -- 65
	if label ~= nil then -- 65
		label.text = character.name -- 67
		label.anchor = Vec2(0.5, 0.5) -- 68
		label.position = Vec2(0, self.radius + 14) -- 69
		label:addTo(self.nodeValue) -- 70
		self.nameLabel = label -- 71
	end -- 71
	ctx.player = self -- 74
	ctx.onAddExp = function(____, amount, _pos) return self:addExp(amount) end -- 76
	ctx.onPlayerDamaged = function(____, amount, from) return self:takeDamage(amount, from) end -- 77
	self:resetForNewGame() -- 78
end -- 60
function Player.prototype.resetForNewGame(self) -- 82
	self.maxHp = self.character.maxHp -- 83
	self.hp = self.maxHp -- 84
	self.level = 1 -- 85
	self.exp = 0 -- 86
	self.expNeed = self:calcExpNeed(1) -- 87
	self.moveSpeed = self.character.moveSpeed -- 88
	self.attackSpeed = 1 -- 89
	self.critChance = 0.1 -- 90
	self.critMulti = 1.5 -- 91
	self.damageBonus = 0 -- 92
	self.projectileCount = self.character.projectileCount -- 93
	self.pierce = self.character.pierce -- 94
	self.split = 0 -- 95
	self.lifesteal = 0 -- 96
	self.pickupRadius = Config.expPickupRadius -- 97
	self.invincible = false -- 98
	self.invincibleTimer = 0 -- 99
	self.regen = 0 -- 100
	self.magnet = 0 -- 101
	self.isAlive = true -- 102
	self.dodge = 0 -- 103
	self.bulletSpeedMulti = 1 -- 104
	self.expMulti = 1 -- 105
	self.goldMulti = 1 -- 106
	self.thorns = 0 -- 107
	self.chain = 0 -- 108
	self.homing = 0 -- 109
	self.ricochet = 0 -- 110
	self.explosion = 0 -- 111
	self.slowAura = 0 -- 112
	self.burn = 0 -- 113
	self.poison = 0 -- 114
	self.freeze = 0 -- 115
	self.facing = 0 -- 116
	self.posValue = Vec2.zero -- 117
	self.skillStacks = {} -- 118
	self.nodeValue.position = Vec2.zero -- 119
	self.nodeValue.visible = true -- 120
	self:redrawBody() -- 121
end -- 82
function Player.prototype.update(self, dt, inputDir) -- 133
	if not self.isAlive then -- 133
		return -- 134
	end -- 134
	if inputDir.length > 0.01 then -- 134
		local dir = normalize(inputDir) -- 137
		self.posValue = Vec2(self.posValue.x + dir.x * self.moveSpeed * dt, self.posValue.y + dir.y * self.moveSpeed * dt) -- 138
		self.facing = math.atan(dir.y, dir.x) -- 142
	end -- 142
	self.posValue = Vec2( -- 145
		clamp(self.posValue.x, -self.halfW, self.halfW), -- 146
		clamp(self.posValue.y, -self.halfH, self.halfH) -- 147
	) -- 147
	if self.invincibleTimer > 0 then -- 147
		self.invincibleTimer = self.invincibleTimer - dt -- 151
		if self.invincibleTimer <= 0 then -- 151
			self.invincibleTimer = 0 -- 153
			self.invincible = false -- 154
		end -- 154
	end -- 154
	if self.regen > 0 and self.hp < self.maxHp then -- 154
		self.hp = math.min(self.maxHp, self.hp + self.regen * dt) -- 159
	end -- 159
	if ctx.magnetPickups ~= nil then -- 159
		ctx:magnetPickups(self.posValue, self.pickupRadius + self.magnet) -- 163
	end -- 163
	self.nodeValue.position = Vec2(self.posValue.x, self.posValue.y) -- 166
	self:redrawBody() -- 167
end -- 133
function Player.prototype.addExp(self, amount) -- 171
	if not self.isAlive then -- 171
		return -- 172
	end -- 172
	self.exp = self.exp + amount * self.expMulti -- 173
	while self.exp >= self.expNeed do -- 173
		self.exp = self.exp - self.expNeed -- 175
		self.level = self.level + 1 -- 176
		self.expNeed = self:calcExpNeed(self.level) -- 177
		ctx.stats.playerLevel = self.level -- 178
		local ____this_1 -- 178
		____this_1 = ctx -- 179
		local ____opt_0 = ____this_1.onPlayerLevelUp -- 179
		if ____opt_0 ~= nil then -- 179
			____opt_0(____this_1) -- 179
		end -- 179
	end -- 179
end -- 171
function Player.prototype.takeDamage(self, amount, from) -- 184
	if not self.isAlive or self.invincible then -- 184
		return -- 185
	end -- 185
	if self.dodge > 0 and rng:chance(math.min(0.75, self.dodge)) then -- 185
		local ____opt_2 = ctx.vfx -- 185
		if ____opt_2 ~= nil then -- 185
			____opt_2:flash(self.posValue, 8444159, 22) -- 187
		end -- 187
		return -- 188
	end -- 188
	self.hp = self.hp - amount -- 190
	local ____ctx_stats_4, ____damageTaken_5 = ctx.stats, "damageTaken" -- 190
	____ctx_stats_4[____damageTaken_5] = ____ctx_stats_4[____damageTaken_5] + amount -- 191
	audio:playSfx(Sfx.PlayerHurt, 0.16) -- 192
	if self.thorns > 0 then -- 192
		local ____this_7 -- 192
		____this_7 = ctx -- 194
		local ____opt_6 = ____this_7.damageEnemiesInRadius -- 194
		if ____opt_6 ~= nil then -- 194
			____opt_6(____this_7, from, 42, { -- 194
				amount = amount * self.thorns, -- 195
				kind = "physical", -- 196
				crit = false, -- 197
				knockback = Vec2.zero, -- 198
				hitStop = 0, -- 199
				shake = 0, -- 200
				flash = true, -- 201
				source = "skill" -- 202
			}) -- 202
		end -- 202
	end -- 202
	if ctx.feedback ~= nil then -- 202
		ctx.feedback:spawnFlash(self.posValue, 16777215) -- 207
		ctx.feedback:shake(Config.shakeMedium) -- 208
		ctx.feedback:hitStop(0.02) -- 209
	end -- 209
	if self.hp <= 0 then -- 209
		self.hp = 0 -- 212
		self.isAlive = false -- 213
		self.nodeValue.visible = false -- 214
		local ____this_9 -- 214
		____this_9 = ctx -- 215
		local ____opt_8 = ____this_9.onGameOver -- 215
		if ____opt_8 ~= nil then -- 215
			____opt_8(____this_9) -- 215
		end -- 215
	else -- 215
		self.invincible = true -- 217
		self.invincibleTimer = self.skillStacks.invincible ~= nil and 1 or 0.45 -- 218
	end -- 218
end -- 184
function Player.prototype.heal(self, amount) -- 223
	if not self.isAlive then -- 223
		return -- 224
	end -- 224
	self.hp = math.min(self.maxHp, self.hp + amount) -- 225
end -- 223
function Player.prototype.calcExpNeed(self, level) -- 228
	return math.floor(Config.expBase * level ^ Config.expCurve) -- 229
end -- 228
function Player.prototype.redrawBody(self) -- 233
	self.body:clear() -- 234
	local color = Color(4278190080 | self.character.color) -- 235
	local outline = Color(withAlpha(16181971, 225)) -- 236
	local dark = Color(20, 28, 31, 255) -- 237
	local forward = Vec2( -- 238
		math.cos(self.facing), -- 238
		math.sin(self.facing) -- 238
	) -- 238
	local side = Vec2(-forward.y, forward.x) -- 239
	self.body:drawDot( -- 241
		Vec2(3, -5), -- 241
		self.radius + 7, -- 241
		Color(0, 0, 0, 90) -- 241
	) -- 241
	self.body:drawPolygon( -- 242
		circleVerts(self.radius, 18), -- 242
		color, -- 242
		3, -- 242
		outline -- 242
	) -- 242
	local face = Vec2(forward.x * 10, forward.y * 10) -- 244
	self.body:drawPolygon( -- 245
		{ -- 245
			Vec2(face.x + side.x * 7, face.y + side.y * 7), -- 246
			Vec2(face.x - side.x * 7, face.y - side.y * 7), -- 247
			Vec2(forward.x * 21, forward.y * 21) -- 248
		}, -- 248
		dark, -- 249
		2, -- 249
		outline -- 249
	) -- 249
	self.body:drawDot( -- 250
		Vec2(-forward.x * 4, -forward.y * 4), -- 250
		5, -- 250
		Color(236, 207, 137, 255) -- 250
	) -- 250
	self:drawClassSilhouette(forward, side, outline) -- 251
	if self.invincibleTimer > 0 and self.invincible then -- 251
		self.nodeValue.opacity = 0.5 -- 254
	else -- 254
		self.nodeValue.opacity = 1 -- 256
	end -- 256
end -- 233
function Player.prototype.drawClassSilhouette(self, forward, side, outline) -- 260
	local function tip(distance, lateral) -- 261
		if lateral == nil then -- 261
			lateral = 0 -- 261
		end -- 261
		return Vec2(forward.x * distance + side.x * lateral, forward.y * distance + side.y * lateral) -- 261
	end -- 261
	repeat -- 261
		local ____switch32 = self.character.id -- 261
		local ____cond32 = ____switch32 == "swordsman" -- 261
		if ____cond32 then -- 261
			self.body:drawSegment( -- 264
				tip(-3, -8), -- 264
				tip(31, -8), -- 264
				6, -- 264
				Color(211, 221, 220, 255) -- 264
			) -- 264
			self.body:drawSegment( -- 265
				tip(7, -14), -- 265
				tip(7, -2), -- 265
				4, -- 265
				Color(105, 71, 37, 255) -- 265
			) -- 265
			break -- 266
		end -- 266
		____cond32 = ____cond32 or ____switch32 == "mage" -- 266
		if ____cond32 then -- 266
			self.body:drawSegment( -- 268
				tip(-8, -10), -- 268
				tip(25, -10), -- 268
				4, -- 268
				Color(96, 68, 44, 255) -- 268
			) -- 268
			self.body:drawDot( -- 269
				tip(29, -10), -- 269
				7, -- 269
				Color(105, 182, 255, 255) -- 269
			) -- 269
			self.body:drawPolygon( -- 270
				{ -- 270
					tip(-10, 0), -- 270
					tip(-22, 13), -- 270
					tip(-22, -13) -- 270
				}, -- 270
				Color(43, 65, 109, 255), -- 270
				2, -- 270
				outline -- 270
			) -- 270
			break -- 271
		end -- 271
		____cond32 = ____cond32 or ____switch32 == "druid" -- 271
		if ____cond32 then -- 271
			self.body:drawSegment( -- 273
				tip(-4, -11), -- 273
				tip(25, -11), -- 273
				4, -- 273
				Color(93, 66, 38, 255) -- 273
			) -- 273
			self.body:drawSegment( -- 274
				tip(21, -11), -- 274
				tip(30, -17), -- 274
				3, -- 274
				Color(84, 179, 96, 255) -- 274
			) -- 274
			self.body:drawSegment( -- 275
				tip(21, -11), -- 275
				tip(30, -5), -- 275
				3, -- 275
				Color(84, 179, 96, 255) -- 275
			) -- 275
			break -- 276
		end -- 276
		____cond32 = ____cond32 or ____switch32 == "gunner" -- 276
		if ____cond32 then -- 276
			self.body:drawSegment( -- 278
				tip(1, -9), -- 278
				tip(30, -9), -- 278
				7, -- 278
				Color(56, 62, 67, 255) -- 278
			) -- 278
			self.body:drawSegment( -- 279
				tip(24, -13), -- 279
				tip(36, -13), -- 279
				3, -- 279
				Color(237, 191, 80, 255) -- 279
			) -- 279
			break -- 280
		end -- 280
		____cond32 = ____cond32 or ____switch32 == "necromancer" -- 280
		if ____cond32 then -- 280
			self.body:drawPolygon( -- 282
				{ -- 282
					tip(-4, 12), -- 282
					tip(-22, 19), -- 282
					tip(-17, 0) -- 282
				}, -- 282
				Color(73, 33, 84, 255), -- 282
				2, -- 282
				outline -- 282
			) -- 282
			self.body:drawSegment( -- 283
				tip(-5, -10), -- 283
				tip(26, -10), -- 283
				4, -- 283
				Color(79, 61, 45, 255) -- 283
			) -- 283
			self.body:drawDot( -- 284
				tip(29, -10), -- 284
				6, -- 284
				Color(193, 103, 238, 255) -- 284
			) -- 284
			break -- 285
		end -- 285
	until true -- 285
end -- 260
__TS__SetDescriptor( -- 260
	Player.prototype, -- 260
	"halfW", -- 260
	{get = function(self) -- 260
		return 1000 - 24 -- 126
	end}, -- 126
	true -- 126
) -- 126
__TS__SetDescriptor( -- 126
	Player.prototype, -- 126
	"halfH", -- 126
	{get = function(self) -- 126
		return 1000 - 24 -- 129
	end}, -- 129
	true -- 129
) -- 129
__TS__SetDescriptor( -- 129
	Player.prototype, -- 129
	"pos", -- 129
	{get = function(self) -- 129
		return self.posValue -- 291
	end}, -- 291
	true -- 291
) -- 291
__TS__SetDescriptor( -- 291
	Player.prototype, -- 291
	"node", -- 291
	{get = function(self) -- 291
		return self.nodeValue -- 294
	end}, -- 294
	true -- 294
) -- 294
__TS__SetDescriptor( -- 294
	Player.prototype, -- 294
	"characterDef", -- 294
	{get = function(self) -- 294
		return self.character -- 297
	end}, -- 297
	true -- 297
) -- 297
return ____exports -- 297