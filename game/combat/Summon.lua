-- [ts]: Summon.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____DamageSystem = require("game.combat.DamageSystem") -- 5
local DamageSystem = ____DamageSystem.DamageSystem -- 5
local ____Bullet = require("game.combat.Bullet") -- 6
local asEnemy = ____Bullet.asEnemy -- 6
local ____ObjectPool = require("game.utils.ObjectPool") -- 7
local ObjectPool = ____ObjectPool.ObjectPool -- 7
local ____MathUtils = require("game.utils.MathUtils") -- 8
local add = ____MathUtils.add -- 8
local dist = ____MathUtils.dist -- 8
local distSq = ____MathUtils.distSq -- 8
local dirTo = ____MathUtils.dirTo -- 8
local scale = ____MathUtils.scale -- 8
local sub = ____MathUtils.sub -- 8
local withAlpha = ____MathUtils.withAlpha -- 8
____exports.Summon = __TS__Class() -- 10
local Summon = ____exports.Summon -- 10
Summon.name = "Summon" -- 10
function Summon.prototype.____constructor(self) -- 33
	self.active = false -- 18
	self.pos = Vec2.zero -- 19
	self.color = 16777215 -- 20
	self.damage = 0 -- 21
	self.attackInterval = 1 -- 22
	self.attackTimer = 0 -- 23
	self.radius = 14 -- 24
	self.attackRange = 42 -- 25
	self.speed = 230 -- 26
	self.maxHp = 40 -- 27
	self.hp = 40 -- 28
	self.player = nil -- 29
	self.node = DrawNode() -- 30
	self.orbitAngle = 0 -- 31
end -- 33
function Summon.spawn(self, root, player, pos, color, damage, interval, radius, attackRange, speed, orbitAngle) -- 36
	if radius == nil then -- 36
		radius = 14 -- 43
	end -- 43
	if attackRange == nil then -- 43
		attackRange = 42 -- 44
	end -- 44
	if speed == nil then -- 44
		speed = 230 -- 45
	end -- 45
	if orbitAngle == nil then -- 45
		orbitAngle = 0 -- 46
	end -- 46
	local s = ____exports.Summon.summonPool:acquire() -- 48
	s.active = true -- 49
	s.player = player -- 50
	s.pos = pos -- 51
	s.color = color -- 52
	s.damage = damage -- 53
	s.attackInterval = interval -- 54
	s.attackTimer = 0 -- 55
	s.radius = radius -- 56
	s.attackRange = attackRange -- 57
	s.speed = speed -- 58
	s.orbitAngle = orbitAngle -- 59
	s.hp = s.maxHp -- 60
	s.node.position = Vec2(pos.x, pos.y) -- 61
	s.node.visible = true -- 62
	if s.node.parent ~= root then -- 62
		s.node:addTo(root) -- 64
	end -- 64
	return s -- 66
end -- 36
function Summon.prototype.recycle(self) -- 70
	if not self.active then -- 70
		return -- 71
	end -- 71
	____exports.Summon.summonPool:release(self) -- 72
end -- 70
function Summon.prototype.reset(self) -- 75
	self.active = false -- 76
	self.player = nil -- 77
	self.node:clear() -- 78
	self.node.visible = false -- 79
end -- 75
function Summon.prototype.update(self, dt) -- 83
	if not self.active then -- 83
		return -- 84
	end -- 84
	local player = self.player -- 85
	if player == nil then -- 85
		self:recycle() -- 87
		return -- 88
	end -- 88
	local nearest = nil -- 91
	local best = math.huge -- 92
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.pos, 320, 4) or ({}) -- 93
	do -- 93
		local i = 0 -- 96
		while i < #candidates do -- 96
			do -- 96
				local e = asEnemy(candidates[i + 1]) -- 97
				if e == nil or not e.isAlive or e.markedDead then -- 97
					goto __continue12 -- 98
				end -- 98
				local d = distSq(self.pos, e.pos) -- 99
				if d < best then -- 99
					best = d -- 101
					nearest = e -- 102
				end -- 102
			end -- 102
			::__continue12:: -- 102
			i = i + 1 -- 96
		end -- 96
	end -- 96
	if nearest ~= nil then -- 96
		local targetDist = dist(self.pos, nearest.pos) -- 107
		local desired = self.attackRange + nearest.radius + 6 -- 108
		if targetDist > desired then -- 108
			local dir = dirTo(self.pos, nearest.pos) -- 110
			self.pos = add( -- 111
				self.pos, -- 111
				scale(dir, self.speed * dt) -- 111
			) -- 111
		end -- 111
	else -- 111
		local d = dist(self.pos, player.pos) -- 114
		if d > 96 then -- 114
			local dir = dirTo(self.pos, player.pos) -- 116
			self.pos = add( -- 117
				self.pos, -- 117
				scale(dir, self.speed * dt) -- 117
			) -- 117
		elseif d < 40 then -- 117
			local dir = dirTo(self.pos, player.pos) -- 119
			self.pos = sub( -- 120
				self.pos, -- 120
				scale(dir, self.speed * dt) -- 120
			) -- 120
		end -- 120
	end -- 120
	self.attackTimer = self.attackTimer - dt -- 124
	if nearest ~= nil and self.attackTimer <= 0 then -- 124
		local d = dist(self.pos, nearest.pos) -- 126
		if d <= self.attackRange + nearest.radius + 8 then -- 126
			self.attackTimer = self.attackInterval -- 128
			local dir = dirTo(self.pos, nearest.pos) -- 129
			local info = DamageSystem:buildInfo( -- 130
				self.damage, -- 130
				player, -- 130
				"summon", -- 130
				dir, -- 130
				"physical" -- 130
			) -- 130
			DamageSystem:apply(nearest, info) -- 131
			local explodeLevel = player.skillStacks.summonExplode or 0 -- 132
			if explodeLevel > 0 then -- 132
				local ____this_1 -- 132
				____this_1 = ctx -- 134
				local ____opt_0 = ____this_1.damageEnemiesInRadius -- 134
				if ____opt_0 ~= nil then -- 134
					____opt_0(____this_1, nearest.pos, 46 + explodeLevel * 8, { -- 134
						amount = self.damage * 0.3 * explodeLevel, -- 135
						kind = "magic", -- 136
						crit = false, -- 136
						knockback = Vec2.zero, -- 136
						hitStop = 0, -- 137
						shake = 1, -- 137
						flash = true, -- 137
						source = "explosion" -- 137
					}) -- 137
				end -- 137
				local ____opt_2 = ctx.vfx -- 137
				if ____opt_2 ~= nil then -- 137
					____opt_2:ring(nearest.pos, self.color, 46 + explodeLevel * 8) -- 139
				end -- 139
			end -- 139
			local ____opt_4 = ctx.vfx -- 139
			if ____opt_4 ~= nil then -- 139
				____opt_4:burst(nearest.pos, self.color, 4, 100) -- 141
			end -- 141
		end -- 141
	end -- 141
	self:redraw() -- 145
end -- 83
function Summon.prototype.takeHit(self, amount) -- 149
	if not self.active then -- 149
		return -- 150
	end -- 150
	self.hp = self.hp - amount -- 151
	if self.hp <= 0 then -- 151
		self:recycle() -- 153
	end -- 153
end -- 149
function Summon.prototype.redraw(self) -- 157
	local node = self.node -- 158
	node:clear() -- 159
	node.position = Vec2(self.pos.x, self.pos.y) -- 160
	local verts = {} -- 162
	do -- 162
		local i = 0 -- 163
		while i < 16 do -- 163
			local a = i / 16 * math.pi * 2 -- 164
			verts[#verts + 1] = Vec2( -- 165
				math.cos(a) * self.radius, -- 165
				math.sin(a) * self.radius -- 165
			) -- 165
			i = i + 1 -- 163
		end -- 163
	end -- 163
	verts[#verts + 1] = Vec2.zero -- 167
	node:drawPolygon( -- 168
		verts, -- 168
		Color(4278190080 | self.color) -- 168
	) -- 168
	node:drawPolygon( -- 169
		verts, -- 169
		Color(4278190080 | self.color), -- 169
		2, -- 169
		Color(withAlpha(16777215, 160)) -- 169
	) -- 169
	local eyeX = self.radius * 0.3 -- 171
	local eyeY = self.radius * 0.35 -- 172
	node:drawDot( -- 173
		Vec2(eyeX, eyeY), -- 173
		self.radius * 0.16, -- 173
		Color(4294967295) -- 173
	) -- 173
	node:drawDot( -- 174
		Vec2(eyeX, -eyeY), -- 174
		self.radius * 0.16, -- 174
		Color(4294967295) -- 174
	) -- 174
	node:drawDot( -- 175
		Vec2(eyeX + self.radius * 0.05, eyeY), -- 175
		self.radius * 0.07, -- 175
		Color(4278190080) -- 175
	) -- 175
	node:drawDot( -- 176
		Vec2(eyeX + self.radius * 0.05, -eyeY), -- 176
		self.radius * 0.07, -- 176
		Color(4278190080) -- 176
	) -- 176
end -- 157
Summon.summonPool = __TS__New( -- 157
	ObjectPool, -- 12
	function() return __TS__New(____exports.Summon) end, -- 13
	function(s) return s:reset() end -- 14
) -- 14
return ____exports -- 14