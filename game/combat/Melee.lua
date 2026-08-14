-- [ts]: Melee.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
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
local ____MathUtils = require("game.utils.MathUtils") -- 7
local dirTo = ____MathUtils.dirTo -- 7
local inArc = ____MathUtils.inArc -- 7
local withAlpha = ____MathUtils.withAlpha -- 7
local ____RNG = require("game.utils.RNG") -- 8
local rng = ____RNG.rng -- 8
____exports.MeleeAttack = __TS__Class() -- 10
local MeleeAttack = ____exports.MeleeAttack -- 10
MeleeAttack.name = "MeleeAttack" -- 10
function MeleeAttack.prototype.____constructor(self, origin, facing, range, halfAngle, baseDamage, player, color, root, duration) -- 24
	if duration == nil then -- 24
		duration = 0.13 -- 33
	end -- 33
	self.settled = false -- 21
	self.node = DrawNode() -- 22
	self.origin = origin -- 35
	self.facing = facing -- 36
	self.range = range -- 37
	self.halfAngle = halfAngle -- 38
	self.baseDamage = baseDamage -- 39
	self.player = player -- 40
	self.color = color -- 41
	self.crit = rng:chance(player.critChance) -- 42
	self.maxLife = duration -- 43
	self.life = duration -- 44
	self.node.position = Vec2(origin.x, origin.y) -- 46
	self.node:addTo(root) -- 47
	self:redraw(1) -- 48
	if self.isFullCircle then -- 48
		local ____opt_0 = ctx.vfx -- 48
		if ____opt_0 ~= nil then -- 48
			____opt_0:ring(origin, color, range) -- 50
		end -- 50
	else -- 50
		local ____opt_2 = ctx.vfx -- 50
		if ____opt_2 ~= nil then -- 50
			____opt_2:slash(origin, facing, color, range) -- 51
		end -- 51
	end -- 51
end -- 24
function MeleeAttack.prototype.update(self, dt) -- 54
	self.life = self.life - dt -- 55
	if not self.settled then -- 55
		self:settle() -- 57
	end -- 57
	if self.life > 0 then -- 57
		self:redraw(self.life / self.maxLife) -- 60
	end -- 60
	if self.life <= 0 then -- 60
		self.node:removeFromParent() -- 63
	end -- 63
end -- 54
function MeleeAttack.prototype.dispose(self) -- 76
	self.life = 0 -- 77
	self.node:removeFromParent() -- 78
end -- 76
function MeleeAttack.prototype.settle(self) -- 82
	self.settled = true -- 83
	local ____this_5 -- 83
	____this_5 = ctx -- 84
	local ____opt_4 = ____this_5.damageBreakablesInRadius -- 84
	if ____opt_4 ~= nil then -- 84
		____opt_4(____this_5, self.origin, self.range, self.baseDamage * (1 + self.player.damageBonus)) -- 84
	end -- 84
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.origin, self.range + 40, self.isFullCircle and 0 or 16) or ({}) -- 85
	do -- 85
		local i = 0 -- 88
		while i < #candidates do -- 88
			do -- 88
				local enemy = asEnemy(candidates[i + 1]) -- 89
				if enemy == nil or not enemy.isAlive or enemy.markedDead then -- 89
					goto __continue12 -- 90
				end -- 90
				if not inArc( -- 90
					self.origin, -- 91
					enemy.pos, -- 91
					self.facing, -- 91
					self.halfAngle, -- 91
					self.range + enemy.radius -- 91
				) then -- 91
					goto __continue12 -- 92
				end -- 92
				local dir = dirTo(self.origin, enemy.pos) -- 94
				local info = DamageSystem:buildInfo( -- 95
					self.baseDamage, -- 96
					self.player, -- 97
					"melee", -- 98
					dir, -- 99
					"physical", -- 100
					self.crit -- 101
				) -- 101
				DamageSystem:apply(enemy, info) -- 103
				local ____opt_6 = ctx.vfx -- 103
				if ____opt_6 ~= nil then -- 103
					____opt_6:burst(enemy.pos, self.color, 5, 120) -- 104
				end -- 104
			end -- 104
			::__continue12:: -- 104
			i = i + 1 -- 88
		end -- 88
	end -- 88
end -- 82
function MeleeAttack.prototype.redraw(self, alphaT) -- 109
	self.node:clear() -- 110
	local alpha = math.max( -- 111
		0, -- 111
		math.min(1, alphaT) -- 111
	) -- 111
	local segments = self.isFullCircle and 32 or 10 -- 112
	local verts = {Vec2.zero} -- 113
	do -- 113
		local i = 0 -- 114
		while i <= segments do -- 114
			local a = self.facing - self.halfAngle + i / segments * self.halfAngle * 2 -- 115
			verts[#verts + 1] = Vec2( -- 116
				math.cos(a) * self.range, -- 116
				math.sin(a) * self.range -- 116
			) -- 116
			i = i + 1 -- 114
		end -- 114
	end -- 114
	self.node:drawPolygon( -- 118
		verts, -- 118
		Color(withAlpha( -- 118
			self.color, -- 118
			math.floor(70 * alpha + 0.5) -- 118
		)) -- 118
	) -- 118
	if self.isFullCircle then -- 118
		do -- 118
			local i = 0 -- 120
			while i < segments do -- 120
				local a0 = i / segments * math.pi * 2 -- 121
				local a1 = (i + 1) / segments * math.pi * 2 -- 122
				self.node:drawSegment( -- 123
					Vec2( -- 124
						math.cos(a0) * self.range, -- 124
						math.sin(a0) * self.range -- 124
					), -- 124
					Vec2( -- 125
						math.cos(a1) * self.range, -- 125
						math.sin(a1) * self.range -- 125
					), -- 125
					3, -- 126
					Color(withAlpha( -- 127
						16777215, -- 127
						math.floor(210 * alpha + 0.5) -- 127
					)) -- 127
				) -- 127
				i = i + 1 -- 120
			end -- 120
		end -- 120
		return -- 130
	end -- 130
	local a0 = self.facing - self.halfAngle -- 133
	local a1 = self.facing + self.halfAngle -- 134
	self.node:drawSegment( -- 135
		Vec2( -- 136
			math.cos(a0) * self.range, -- 136
			math.sin(a0) * self.range -- 136
		), -- 136
		Vec2( -- 137
			math.cos(a1) * self.range, -- 137
			math.sin(a1) * self.range -- 137
		), -- 137
		2, -- 138
		Color(withAlpha( -- 139
			16777215, -- 139
			math.floor(200 * alpha + 0.5) -- 139
		)) -- 139
	) -- 139
	self.node:drawSegment( -- 142
		Vec2.zero, -- 143
		Vec2( -- 144
			math.cos(self.facing) * self.range, -- 144
			math.sin(self.facing) * self.range -- 144
		), -- 144
		1.5, -- 145
		Color(withAlpha( -- 146
			self.color, -- 146
			math.floor(160 * alpha + 0.5) -- 146
		)) -- 146
	) -- 146
end -- 109
__TS__SetDescriptor( -- 109
	MeleeAttack.prototype, -- 109
	"isDone", -- 109
	{get = function(self) -- 109
		return self.life <= 0 -- 68
	end}, -- 68
	true -- 68
) -- 68
__TS__SetDescriptor( -- 68
	MeleeAttack.prototype, -- 68
	"isFullCircle", -- 68
	{get = function(self) -- 68
		return self.halfAngle >= math.pi - 0.001 -- 72
	end}, -- 72
	true -- 72
) -- 72
return ____exports -- 72