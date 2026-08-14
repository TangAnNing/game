-- [ts]: Bullet.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____DamageSystem = require("game.combat.DamageSystem") -- 5
local DamageSystem = ____DamageSystem.DamageSystem -- 5
local ____ObjectPool = require("game.utils.ObjectPool") -- 6
local ObjectPool = ____ObjectPool.ObjectPool -- 6
local ____MathUtils = require("game.utils.MathUtils") -- 7
local distSq = ____MathUtils.distSq -- 7
local normalize = ____MathUtils.normalize -- 7
local scale = ____MathUtils.scale -- 7
local withAlpha = ____MathUtils.withAlpha -- 7
local ____Config = require("game.config.Config") -- 8
local Config = ____Config.Config -- 8
function ____exports.asEnemy(e) -- 11
	if e == nil then -- 11
		return nil -- 12
	end -- 12
	local enemy = e -- 13
	if enemy ~= nil and type(enemy.takeDamage) == "function" and enemy.isAlive then -- 13
		return enemy -- 15
	end -- 15
	return nil -- 17
end -- 11
____exports.Bullet = __TS__Class() -- 20
local Bullet = ____exports.Bullet -- 20
Bullet.name = "Bullet" -- 20
function Bullet.prototype.____constructor(self) -- 44
	self.active = false -- 28
	self.pos = Vec2.zero -- 29
	self.vel = Vec2.zero -- 30
	self.damage = 0 -- 31
	self.pierce = 0 -- 32
	self.split = 0 -- 33
	self.ricochet = 0 -- 34
	self.radius = 5 -- 35
	self.life = 0 -- 36
	self.color = 16777215 -- 37
	self.onSplit = nil -- 39
	self.root = Node() -- 40
	self.hitIds = {} -- 41
	self.node = DrawNode() -- 42
end -- 44
function Bullet.spawn(self, root, pos, vel, damage, range, radius, pierce, split, ricochet, color, onSplit) -- 47
	local b = ____exports.Bullet.bulletPool:acquire() -- 60
	b.active = true -- 61
	b.pos = pos -- 62
	b.vel = vel -- 63
	b.damage = damage -- 64
	b.pierce = pierce -- 65
	b.split = split -- 66
	b.ricochet = ricochet -- 67
	b.radius = radius -- 68
	local speed = vel.length -- 69
	b.life = speed > 0.001 and range / speed or 1 -- 70
	b.color = color -- 71
	b.root = root -- 72
	b.onSplit = onSplit ~= nil and (function(nb) return onSplit(nb) end) or nil -- 73
	__TS__ArraySetLength(b.hitIds, 0) -- 73
	b.node.position = Vec2(pos.x, pos.y) -- 75
	b.node.visible = true -- 76
	if b.node.parent ~= root then -- 76
		b.node:addTo(root) -- 79
	end -- 79
	return b -- 81
end -- 47
function Bullet.prototype.reset(self) -- 85
	self.active = false -- 86
	__TS__ArraySetLength(self.hitIds, 0) -- 86
	self.ricochet = 0 -- 88
	self.onSplit = nil -- 89
	self.node:clear() -- 90
	self.node.visible = false -- 92
end -- 85
function Bullet.prototype.recycle(self) -- 96
	if not self.active then -- 96
		return -- 97
	end -- 97
	____exports.Bullet.bulletPool:release(self) -- 98
end -- 96
function Bullet.prototype.update(self, dt, player) -- 102
	if not self.active then -- 102
		return -- 103
	end -- 103
	if player.homing > 0 then -- 103
		local ____this_1 -- 103
		____this_1 = ctx -- 105
		local ____opt_0 = ____this_1.findEnemiesNear -- 105
		local targets = ____opt_0 and ____opt_0(____this_1, self.pos, 180, 1) or ({}) -- 105
		local ____temp_2 -- 106
		if #targets > 0 then -- 106
			____temp_2 = ____exports.asEnemy(targets[1]) -- 106
		else -- 106
			____temp_2 = nil -- 106
		end -- 106
		local target = ____temp_2 -- 106
		if target ~= nil then -- 106
			local speed = self.vel.length -- 108
			local desired = normalize(Vec2(target.pos.x - self.pos.x, target.pos.y - self.pos.y)) -- 109
			local turn = math.min(1, dt * 7) -- 110
			local blended = normalize(Vec2(self.vel.x / speed * (1 - turn) + desired.x * turn, self.vel.y / speed * (1 - turn) + desired.y * turn)) -- 111
			self.vel = scale(blended, speed) -- 115
		end -- 115
	end -- 115
	self.pos = Vec2(self.pos.x + self.vel.x * dt, self.pos.y + self.vel.y * dt) -- 118
	self.life = self.life - dt -- 119
	local halfW = 1000 + Config.cullMargin -- 121
	local halfH = 1000 + Config.cullMargin -- 122
	if self.life <= 0 or math.abs(self.pos.x) > halfW or math.abs(self.pos.y) > halfH then -- 122
		self:recycle() -- 124
		return -- 125
	end -- 125
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.pos, self.radius + 40, 8) or ({}) -- 128
	do -- 128
		local i = 0 -- 131
		while i < #candidates do -- 131
			do -- 131
				local enemy = ____exports.asEnemy(candidates[i + 1]) -- 132
				if enemy == nil or not enemy.isAlive or enemy.markedDead then -- 132
					goto __continue18 -- 133
				end -- 133
				if __TS__ArrayIndexOf(self.hitIds, enemy.id) >= 0 then -- 133
					goto __continue18 -- 134
				end -- 134
				local rr = self.radius + enemy.radius -- 135
				if distSq(self.pos, enemy.pos) <= rr * rr then -- 135
					local ____self_hitIds_3 = self.hitIds -- 135
					____self_hitIds_3[#____self_hitIds_3 + 1] = enemy.id -- 137
					self:onHit(enemy, player) -- 138
					if not self.active then -- 138
						return -- 139
					end -- 139
				end -- 139
			end -- 139
			::__continue18:: -- 139
			i = i + 1 -- 131
		end -- 131
	end -- 131
	self.node:clear() -- 143
	self.node.position = Vec2(self.pos.x, self.pos.y) -- 144
	self.node:drawDot( -- 145
		Vec2.zero, -- 145
		self.radius, -- 145
		Color(4278190080 | self.color) -- 145
	) -- 145
	local speed = math.sqrt(self.vel.x * self.vel.x + self.vel.y * self.vel.y) -- 146
	if speed > 0.001 then -- 146
		local nx = self.vel.x / speed -- 148
		local ny = self.vel.y / speed -- 149
		self.node:drawSegment( -- 150
			Vec2(-nx * self.radius * 0.5, -ny * self.radius * 0.5), -- 150
			Vec2(-nx * (self.radius + 16), -ny * (self.radius + 16)), -- 150
			math.max(2, self.radius * 0.7), -- 150
			Color(withAlpha(self.color, 105)) -- 150
		) -- 150
	end -- 150
	self.node:drawDot( -- 152
		Vec2.zero, -- 152
		math.max(2, self.radius * 0.42), -- 152
		Color(255, 248, 220, 245) -- 152
	) -- 152
end -- 102
function Bullet.prototype.onHit(self, enemy, player) -- 156
	local dir = normalize(self.vel) -- 157
	local info = DamageSystem:buildInfo( -- 158
		self.damage, -- 158
		player, -- 158
		"bullet", -- 158
		dir, -- 158
		"physical" -- 158
	) -- 158
	DamageSystem:apply(enemy, info) -- 159
	local ____opt_4 = ctx.vfx -- 159
	if ____opt_4 ~= nil then -- 159
		____opt_4:burst(enemy.pos, self.color, 6, 140) -- 160
	end -- 160
	local ____this_7 -- 160
	____this_7 = ctx -- 161
	local ____opt_6 = ____this_7.damageBreakablesInRadius -- 161
	if ____opt_6 ~= nil then -- 161
		____opt_6(____this_7, self.pos, self.radius + 12, info.amount) -- 161
	end -- 161
	if player.explosion > 0 then -- 161
		local ____this_9 -- 161
		____this_9 = ctx -- 163
		local ____opt_8 = ____this_9.damageEnemiesInRadius -- 163
		if ____opt_8 ~= nil then -- 163
			____opt_8(____this_9, enemy.pos, 52 + player.explosion * 8, { -- 163
				amount = self.damage * (0.35 + player.explosion * 0.1), -- 164
				kind = "magic", -- 165
				crit = false, -- 165
				knockback = Vec2.zero, -- 165
				hitStop = 0, -- 166
				shake = 2, -- 166
				flash = true, -- 166
				source = "explosion" -- 166
			}) -- 166
		end -- 166
		local ____opt_10 = ctx.vfx -- 166
		if ____opt_10 ~= nil then -- 166
			____opt_10:ring(enemy.pos, self.color, 52 + player.explosion * 8) -- 168
		end -- 168
	end -- 168
	if player.chain > 0 then -- 168
		local ____this_13 -- 168
		____this_13 = ctx -- 171
		local ____opt_12 = ____this_13.findEnemiesNear -- 171
		local chained = ____opt_12 and ____opt_12(____this_13, enemy.pos, 120, player.chain + 1) or ({}) -- 171
		do -- 171
			local i = 0 -- 172
			while i < #chained do -- 172
				local next = ____exports.asEnemy(chained[i + 1]) -- 173
				if next ~= nil and next.id ~= enemy.id then -- 173
					DamageSystem:apply(next, { -- 175
						amount = self.damage * 0.35, -- 176
						kind = "magic", -- 176
						crit = false, -- 176
						knockback = Vec2.zero, -- 177
						hitStop = 0, -- 177
						shake = 0, -- 177
						flash = true, -- 177
						source = "skill" -- 177
					}) -- 177
				end -- 177
				i = i + 1 -- 172
			end -- 172
		end -- 172
	end -- 172
	if self.ricochet > 0 then -- 172
		local ____this_15 -- 172
		____this_15 = ctx -- 183
		local ____opt_14 = ____this_15.findEnemiesNear -- 183
		local targets = ____opt_14 and ____opt_14(____this_15, enemy.pos, 180, 4) or ({}) -- 183
		do -- 183
			local i = 0 -- 184
			while i < #targets do -- 184
				local target = ____exports.asEnemy(targets[i + 1]) -- 185
				if target ~= nil and target.id ~= enemy.id and __TS__ArrayIndexOf(self.hitIds, target.id) < 0 then -- 185
					local speed = self.vel.length -- 187
					self.vel = scale( -- 188
						normalize(Vec2(target.pos.x - self.pos.x, target.pos.y - self.pos.y)), -- 188
						speed -- 188
					) -- 188
					self.pierce = math.max(self.pierce, 0) -- 189
					self.ricochet = self.ricochet - 1 -- 190
					return -- 191
				end -- 191
				i = i + 1 -- 184
			end -- 184
		end -- 184
	end -- 184
	if self.split > 0 and self.active then -- 184
		local baseAngle = math.atan(self.vel.y, self.vel.x) -- 197
		local speed = self.vel.length -- 198
		do -- 198
			local i = 0 -- 199
			while i < 2 do -- 199
				local a = baseAngle + (i == 0 and 0.45 or -0.45) -- 200
				local sub = ____exports.Bullet:spawn( -- 201
					self.root, -- 202
					self.pos, -- 203
					Vec2( -- 204
						math.cos(a) * speed, -- 204
						math.sin(a) * speed -- 204
					), -- 204
					self.damage, -- 205
					self.life * speed, -- 206
					self.radius * 0.8, -- 207
					self.pierce, -- 208
					self.split - 1, -- 209
					self.ricochet, -- 210
					self.color, -- 211
					self.onSplit -- 212
				) -- 212
				if self.onSplit ~= nil then -- 212
					self.onSplit(sub) -- 215
				end -- 215
				i = i + 1 -- 199
			end -- 199
		end -- 199
	end -- 199
	self.pierce = self.pierce - 1 -- 219
	if self.pierce < 0 then -- 219
		self:recycle() -- 221
	end -- 221
end -- 156
Bullet.bulletPool = __TS__New( -- 156
	ObjectPool, -- 22
	function() return __TS__New(____exports.Bullet) end, -- 23
	function(b) return b:reset() end -- 24
) -- 24
__TS__SetDescriptor( -- 24
	Bullet.prototype, -- 24
	"isActive", -- 24
	{get = function(self) -- 24
		return self.active -- 226
	end}, -- 226
	true -- 226
) -- 226
return ____exports -- 226