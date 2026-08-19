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
local ____AudioManager = require("game.audio.AudioManager") -- 9
local audio = ____AudioManager.audio -- 9
local Sfx = ____AudioManager.Sfx -- 9
____exports.Summon = __TS__Class() -- 11
local Summon = ____exports.Summon -- 11
Summon.name = "Summon" -- 11
function Summon.prototype.____constructor(self) -- 34
	self.active = false -- 19
	self.pos = Vec2.zero -- 20
	self.color = 16777215 -- 21
	self.damage = 0 -- 22
	self.attackInterval = 1 -- 23
	self.attackTimer = 0 -- 24
	self.radius = 14 -- 25
	self.attackRange = 42 -- 26
	self.speed = 230 -- 27
	self.maxHp = 40 -- 28
	self.hp = 40 -- 29
	self.player = nil -- 30
	self.node = DrawNode() -- 31
	self.orbitAngle = 0 -- 32
end -- 34
function Summon.spawn(self, root, player, pos, color, damage, interval, radius, attackRange, speed, orbitAngle) -- 37
	if radius == nil then -- 37
		radius = 14 -- 44
	end -- 44
	if attackRange == nil then -- 44
		attackRange = 42 -- 45
	end -- 45
	if speed == nil then -- 45
		speed = 230 -- 46
	end -- 46
	if orbitAngle == nil then -- 46
		orbitAngle = 0 -- 47
	end -- 47
	local s = ____exports.Summon.summonPool:acquire() -- 49
	s.active = true -- 50
	s.player = player -- 51
	s.pos = pos -- 52
	s.color = color -- 53
	s.damage = damage -- 54
	s.attackInterval = interval -- 55
	s.attackTimer = 0 -- 56
	s.radius = radius -- 57
	s.attackRange = attackRange -- 58
	s.speed = speed -- 59
	s.orbitAngle = orbitAngle -- 60
	s.hp = s.maxHp -- 61
	s.node.position = Vec2(pos.x, pos.y) -- 62
	s.node.visible = true -- 63
	if s.node.parent ~= root then -- 63
		s.node:addTo(root) -- 65
	end -- 65
	return s -- 67
end -- 37
function Summon.prototype.recycle(self) -- 71
	if not self.active then -- 71
		return -- 72
	end -- 72
	____exports.Summon.summonPool:release(self) -- 73
end -- 71
function Summon.prototype.reset(self) -- 76
	self.active = false -- 77
	self.player = nil -- 78
	self.node:clear() -- 79
	self.node.visible = false -- 80
end -- 76
function Summon.prototype.update(self, dt) -- 84
	if not self.active then -- 84
		return -- 85
	end -- 85
	local player = self.player -- 86
	if player == nil then -- 86
		self:recycle() -- 88
		return -- 89
	end -- 89
	local nearest = nil -- 92
	local best = math.huge -- 93
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.pos, 320, 4) or ({}) -- 94
	do -- 94
		local i = 0 -- 97
		while i < #candidates do -- 97
			do -- 97
				local e = asEnemy(candidates[i + 1]) -- 98
				if e == nil or not e.isAlive or e.markedDead then -- 98
					goto __continue12 -- 99
				end -- 99
				local d = distSq(self.pos, e.pos) -- 100
				if d < best then -- 100
					best = d -- 102
					nearest = e -- 103
				end -- 103
			end -- 103
			::__continue12:: -- 103
			i = i + 1 -- 97
		end -- 97
	end -- 97
	if nearest ~= nil then -- 97
		local targetDist = dist(self.pos, nearest.pos) -- 108
		local desired = self.attackRange + nearest.radius + 6 -- 109
		if targetDist > desired then -- 109
			local dir = dirTo(self.pos, nearest.pos) -- 111
			self.pos = add( -- 112
				self.pos, -- 112
				scale(dir, self.speed * dt) -- 112
			) -- 112
		end -- 112
	else -- 112
		local d = dist(self.pos, player.pos) -- 115
		if d > 96 then -- 115
			local dir = dirTo(self.pos, player.pos) -- 117
			self.pos = add( -- 118
				self.pos, -- 118
				scale(dir, self.speed * dt) -- 118
			) -- 118
		elseif d < 40 then -- 118
			local dir = dirTo(self.pos, player.pos) -- 120
			self.pos = sub( -- 121
				self.pos, -- 121
				scale(dir, self.speed * dt) -- 121
			) -- 121
		end -- 121
	end -- 121
	self.attackTimer = self.attackTimer - dt -- 125
	if nearest ~= nil and self.attackTimer <= 0 then -- 125
		local d = dist(self.pos, nearest.pos) -- 127
		if d <= self.attackRange + nearest.radius + 8 then -- 127
			self.attackTimer = self.attackInterval -- 129
			local dir = dirTo(self.pos, nearest.pos) -- 130
			local info = DamageSystem:buildInfo( -- 131
				self.damage, -- 131
				player, -- 131
				"summon", -- 131
				dir, -- 131
				"physical" -- 131
			) -- 131
			DamageSystem:apply(nearest, info) -- 132
			audio:playSfx(Sfx.SummonImpact, 0.08) -- 133
			local explodeLevel = player.skillStacks.summonExplode or 0 -- 134
			if explodeLevel > 0 then -- 134
				local ____this_1 -- 134
				____this_1 = ctx -- 136
				local ____opt_0 = ____this_1.damageEnemiesInRadius -- 136
				if ____opt_0 ~= nil then -- 136
					____opt_0(____this_1, nearest.pos, 46 + explodeLevel * 8, { -- 136
						amount = self.damage * 0.3 * explodeLevel, -- 137
						kind = "magic", -- 138
						crit = false, -- 138
						knockback = Vec2.zero, -- 138
						hitStop = 0, -- 139
						shake = 1, -- 139
						flash = true, -- 139
						source = "explosion" -- 139
					}) -- 139
				end -- 139
				local ____opt_2 = ctx.vfx -- 139
				if ____opt_2 ~= nil then -- 139
					____opt_2:ring(nearest.pos, self.color, 46 + explodeLevel * 8) -- 141
				end -- 141
			end -- 141
			local ____opt_4 = ctx.vfx -- 141
			if ____opt_4 ~= nil then -- 141
				____opt_4:burst(nearest.pos, self.color, 4, 100) -- 143
			end -- 143
		end -- 143
	end -- 143
	self:redraw() -- 147
end -- 84
function Summon.prototype.takeHit(self, amount) -- 151
	if not self.active then -- 151
		return -- 152
	end -- 152
	self.hp = self.hp - amount -- 153
	if self.hp <= 0 then -- 153
		self:recycle() -- 155
	end -- 155
end -- 151
function Summon.prototype.redraw(self) -- 159
	local node = self.node -- 160
	node:clear() -- 161
	node.position = Vec2(self.pos.x, self.pos.y) -- 162
	local verts = {} -- 164
	do -- 164
		local i = 0 -- 165
		while i < 16 do -- 165
			local a = i / 16 * math.pi * 2 -- 166
			verts[#verts + 1] = Vec2( -- 167
				math.cos(a) * self.radius, -- 167
				math.sin(a) * self.radius -- 167
			) -- 167
			i = i + 1 -- 165
		end -- 165
	end -- 165
	verts[#verts + 1] = Vec2.zero -- 169
	node:drawPolygon( -- 170
		verts, -- 170
		Color(4278190080 | self.color) -- 170
	) -- 170
	node:drawPolygon( -- 171
		verts, -- 171
		Color(4278190080 | self.color), -- 171
		2, -- 171
		Color(withAlpha(16777215, 160)) -- 171
	) -- 171
	local eyeX = self.radius * 0.3 -- 173
	local eyeY = self.radius * 0.35 -- 174
	node:drawDot( -- 175
		Vec2(eyeX, eyeY), -- 175
		self.radius * 0.16, -- 175
		Color(4294967295) -- 175
	) -- 175
	node:drawDot( -- 176
		Vec2(eyeX, -eyeY), -- 176
		self.radius * 0.16, -- 176
		Color(4294967295) -- 176
	) -- 176
	node:drawDot( -- 177
		Vec2(eyeX + self.radius * 0.05, eyeY), -- 177
		self.radius * 0.07, -- 177
		Color(4278190080) -- 177
	) -- 177
	node:drawDot( -- 178
		Vec2(eyeX + self.radius * 0.05, -eyeY), -- 178
		self.radius * 0.07, -- 178
		Color(4278190080) -- 178
	) -- 178
end -- 159
Summon.summonPool = __TS__New( -- 159
	ObjectPool, -- 13
	function() return __TS__New(____exports.Summon) end, -- 14
	function(s) return s:reset() end -- 15
) -- 15
return ____exports -- 15