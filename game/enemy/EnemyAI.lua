-- [ts]: EnemyAI.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local moveToward, aiChase, fireAtPlayer, aiChaseShoot, aiCharge, aiShield, aiSuicide, aiBoss, PLAYER_RADIUS, SUICIDE_RANGE, SUICIDE_AOE -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____MathUtils = require("game.utils.MathUtils") -- 5
local angleBetween = ____MathUtils.angleBetween -- 5
local dirTo = ____MathUtils.dirTo -- 5
local dist = ____MathUtils.dist -- 5
function moveToward(enemy, playerPos, speed, dt) -- 131
	local dir = dirTo(enemy.pos, playerPos) -- 132
	local d = speed * dt -- 133
	enemy.pos = Vec2(enemy.pos.x + dir.x * d, enemy.pos.y + dir.y * d) -- 134
end -- 134
function aiChase(enemy, playerPos, dt, dtScale) -- 137
	local spd = enemy.def.moveSpeed * enemy.slowMult * dtScale -- 138
	moveToward(enemy, playerPos, spd, dt) -- 139
end -- 139
function fireAtPlayer(enemy, playerPos, speed, dmg) -- 142
	local dir = dirTo(enemy.pos, playerPos) -- 143
	local ____opt_1 = enemy.bulletManager -- 143
	if ____opt_1 ~= nil then -- 143
		____opt_1:spawn( -- 144
			enemy.pos, -- 144
			Vec2(dir.x * speed, dir.y * speed), -- 144
			dmg, -- 144
			5 -- 144
		) -- 144
	end -- 144
end -- 144
function aiChaseShoot(enemy, playerPos, dt, dtScale) -- 147
	local def = enemy.def -- 148
	local spd = def.moveSpeed * enemy.slowMult * dtScale -- 149
	moveToward(enemy, playerPos, spd, dt) -- 150
	enemy.shootTimer = enemy.shootTimer - dt -- 151
	if enemy.shootTimer <= 0 then -- 151
		enemy.shootTimer = def.shootInterval or 2.2 -- 153
		fireAtPlayer(enemy, playerPos, def.shootSpeed or 220, def.damage) -- 154
	end -- 154
end -- 154
function aiCharge(enemy, playerPos, dt, dtScale) -- 158
	local def = enemy.def -- 159
	local cooldown = def.chargeCooldown or 2.6 -- 160
	if enemy.chargeState == 0 then -- 160
		moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt) -- 163
		enemy.chargeTimer = enemy.chargeTimer + dt -- 164
		if enemy.chargeTimer >= cooldown then -- 164
			enemy.chargeState = 1 -- 166
			enemy.chargeTimer = 0 -- 167
		end -- 167
	elseif enemy.chargeState == 1 then -- 167
		enemy.chargeTimer = enemy.chargeTimer + dt -- 171
		if enemy.chargeTimer >= 0.5 then -- 171
			enemy.chargeState = 2 -- 173
			enemy.chargeTimer = 0 -- 174
			enemy.chargeDir = dirTo(enemy.pos, playerPos) -- 175
		end -- 175
	else -- 175
		local spd = (def.chargeSpeed or 340) * enemy.slowMult * dtScale -- 179
		enemy.pos = Vec2(enemy.pos.x + enemy.chargeDir.x * spd * dt, enemy.pos.y + enemy.chargeDir.y * spd * dt) -- 180
		enemy.chargeTimer = enemy.chargeTimer + dt -- 184
		local d = dist(enemy.pos, playerPos) -- 186
		if d < enemy.radius + PLAYER_RADIUS then -- 186
			if ctx.onPlayerDamaged then -- 186
				ctx:onPlayerDamaged(def.damage, enemy.pos) -- 188
			end -- 188
			enemy.chargeState = 0 -- 189
			enemy.chargeTimer = 0 -- 190
		elseif enemy.chargeTimer >= 1.1 then -- 190
			enemy.chargeState = 0 -- 192
			enemy.chargeTimer = 0 -- 193
		end -- 193
	end -- 193
end -- 193
function aiShield(enemy, playerPos, dt, dtScale) -- 198
	local spd = enemy.def.moveSpeed * enemy.slowMult * dtScale -- 200
	moveToward(enemy, playerPos, spd, dt) -- 201
end -- 201
function aiSuicide(enemy, playerPos, dt, dtScale) -- 204
	local def = enemy.def -- 205
	moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt) -- 206
	local d = dist(enemy.pos, playerPos) -- 207
	if d <= SUICIDE_RANGE + enemy.radius then -- 207
		local dx = playerPos.x - enemy.pos.x -- 210
		local dy = playerPos.y - enemy.pos.y -- 211
		if dx * dx + dy * dy <= SUICIDE_AOE * SUICIDE_AOE then -- 211
			if ctx.onPlayerDamaged then -- 211
				ctx:onPlayerDamaged(def.damage, enemy.pos) -- 213
			end -- 213
		end -- 213
		if ctx.vfx then -- 213
			ctx.vfx:flash(enemy.pos, 16736063, SUICIDE_AOE) -- 216
			ctx.vfx:ring(enemy.pos, 16748383, SUICIDE_AOE) -- 217
		end -- 217
		if ctx.feedback then -- 217
			ctx.feedback:shake(8) -- 219
		end -- 219
		enemy:die() -- 220
	end -- 220
end -- 220
function aiBoss(enemy, playerPos, dt, dtScale) -- 224
	local def = enemy.def -- 225
	moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt) -- 226
	enemy.shootTimer = enemy.shootTimer - dt -- 227
	if enemy.shootTimer <= 0 then -- 227
		enemy.shootTimer = def.shootInterval or 2.5 -- 229
		local speed = def.shootSpeed or 200 -- 230
		local base = angleBetween(enemy.pos, playerPos) -- 232
		local count = 12 -- 233
		do -- 233
			local i = 0 -- 234
			while i < count do -- 234
				local a = base - 1 + 2 * i / (count - 1) -- 235
				local ____opt_3 = enemy.bulletManager -- 235
				if ____opt_3 ~= nil then -- 235
					____opt_3:spawn( -- 236
						enemy.pos, -- 237
						Vec2( -- 238
							math.cos(a) * speed, -- 238
							math.sin(a) * speed -- 238
						), -- 238
						def.damage * 0.6, -- 239
						6 -- 240
					) -- 240
				end -- 240
				i = i + 1 -- 234
			end -- 234
		end -- 234
	end -- 234
end -- 234
PLAYER_RADIUS = 16 -- 8
SUICIDE_RANGE = 40 -- 10
SUICIDE_AOE = 90 -- 12
local WORLD_HALF = 1200 -- 14
local EnemyBullet = __TS__Class() -- 17
EnemyBullet.name = "EnemyBullet" -- 17
function EnemyBullet.prototype.____constructor(self, pos, vel, damage, radius, root) -- 26
	self.alive = true -- 22
	self.pos = pos -- 27
	self.vel = vel -- 28
	self.damage = damage -- 29
	self.radius = radius -- 30
	self.draw = DrawNode() -- 31
	self.draw:drawDot( -- 32
		Vec2.zero, -- 32
		radius + 5, -- 32
		Color(210, 48, 54, 70) -- 32
	) -- 32
	self.draw:drawDot( -- 33
		Vec2.zero, -- 33
		radius, -- 33
		Color(255, 105, 92, 255) -- 33
	) -- 33
	self.draw:drawDot( -- 34
		Vec2.zero, -- 34
		math.max(2, radius * 0.38), -- 34
		Color(255, 226, 184, 255) -- 34
	) -- 34
	self.draw:addTo(root) -- 35
	self.draw.position = self.pos -- 36
end -- 26
function EnemyBullet.prototype.update(self, dt) -- 39
	if not self.alive then -- 39
		return -- 40
	end -- 40
	self.pos = Vec2(self.pos.x + self.vel.x * dt, self.pos.y + self.vel.y * dt) -- 41
	self.draw.position = self.pos -- 42
	local player = ctx.player -- 44
	if player ~= nil and player.isAlive then -- 44
		local dx = player.pos.x - self.pos.x -- 46
		local dy = player.pos.y - self.pos.y -- 47
		local rr = self.radius + PLAYER_RADIUS -- 48
		if dx * dx + dy * dy <= rr * rr then -- 48
			self.alive = false -- 50
			if ctx.onPlayerDamaged then -- 50
				ctx:onPlayerDamaged(self.damage, self.pos) -- 51
			end -- 51
		end -- 51
	end -- 51
	if math.abs(self.pos.x) > WORLD_HALF or math.abs(self.pos.y) > WORLD_HALF then -- 51
		self.alive = false -- 56
	end -- 56
end -- 39
function EnemyBullet.prototype.remove(self) -- 60
	self.draw:removeFromParent() -- 61
end -- 60
____exports.EnemyBulletManager = __TS__Class() -- 66
local EnemyBulletManager = ____exports.EnemyBulletManager -- 66
EnemyBulletManager.name = "EnemyBulletManager" -- 66
function EnemyBulletManager.prototype.____constructor(self, root) -- 70
	self.bullets = {} -- 67
	self.root = root -- 71
end -- 70
function EnemyBulletManager.prototype.spawn(self, pos, vel, damage, radius) -- 74
	if radius == nil then -- 74
		radius = 5 -- 74
	end -- 74
	if #self.bullets >= 400 then -- 74
		return -- 75
	end -- 75
	local ____self_bullets_0 = self.bullets -- 75
	____self_bullets_0[#____self_bullets_0 + 1] = __TS__New( -- 76
		EnemyBullet, -- 76
		pos, -- 76
		vel, -- 76
		damage, -- 76
		radius, -- 76
		self.root -- 76
	) -- 76
end -- 74
function EnemyBulletManager.prototype.update(self, dt) -- 79
	do -- 79
		local i = #self.bullets - 1 -- 80
		while i >= 0 do -- 80
			local b = self.bullets[i + 1] -- 81
			b:update(dt) -- 82
			if not b.alive then -- 82
				b:remove() -- 84
				local last = #self.bullets - 1 -- 85
				self.bullets[i + 1] = self.bullets[last + 1] -- 86
				table.remove(self.bullets) -- 87
			end -- 87
			i = i - 1 -- 80
		end -- 80
	end -- 80
end -- 79
function EnemyBulletManager.prototype.clear(self) -- 92
	do -- 92
		local i = 0 -- 93
		while i < #self.bullets do -- 93
			self.bullets[i + 1]:remove() -- 94
			i = i + 1 -- 93
		end -- 93
	end -- 93
	__TS__ArraySetLength(self.bullets, 0) -- 93
end -- 92
__TS__SetDescriptor( -- 92
	EnemyBulletManager.prototype, -- 92
	"count", -- 92
	{get = function(self) -- 92
		return #self.bullets -- 100
	end}, -- 100
	true -- 100
) -- 100
function ____exports.updateEnemyAI(enemy, playerPos, dt, dtScale) -- 105
	if dtScale == nil then -- 105
		dtScale = 1 -- 105
	end -- 105
	if not enemy.isAlive or enemy.markedDead then -- 105
		return -- 106
	end -- 106
	if enemy.freezeTimer > 0 then -- 106
		return -- 107
	end -- 107
	repeat -- 107
		local ____switch24 = enemy.def.ai -- 107
		local ____cond24 = ____switch24 == "chase" -- 107
		if ____cond24 then -- 107
			aiChase(enemy, playerPos, dt, dtScale) -- 110
			break -- 111
		end -- 111
		____cond24 = ____cond24 or ____switch24 == "chaseShoot" -- 111
		if ____cond24 then -- 111
			aiChaseShoot(enemy, playerPos, dt, dtScale) -- 113
			break -- 114
		end -- 114
		____cond24 = ____cond24 or ____switch24 == "charge" -- 114
		if ____cond24 then -- 114
			aiCharge(enemy, playerPos, dt, dtScale) -- 116
			break -- 117
		end -- 117
		____cond24 = ____cond24 or ____switch24 == "shield" -- 117
		if ____cond24 then -- 117
			aiShield(enemy, playerPos, dt, dtScale) -- 119
			break -- 120
		end -- 120
		____cond24 = ____cond24 or ____switch24 == "suicide" -- 120
		if ____cond24 then -- 120
			aiSuicide(enemy, playerPos, dt, dtScale) -- 122
			break -- 123
		end -- 123
		____cond24 = ____cond24 or ____switch24 == "boss" -- 123
		if ____cond24 then -- 123
			aiBoss(enemy, playerPos, dt, dtScale) -- 125
			break -- 126
		end -- 126
	until true -- 126
	enemy.facing = angleBetween(enemy.pos, playerPos) -- 128
end -- 105
return ____exports -- 105