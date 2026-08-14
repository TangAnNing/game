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
	local ____opt_0 = ctx.vfx -- 48
	if ____opt_0 ~= nil then -- 48
		____opt_0:slash(origin, facing, color, range) -- 50
	end -- 50
end -- 24
function MeleeAttack.prototype.update(self, dt) -- 53
	self.life = self.life - dt -- 54
	if not self.settled then -- 54
		self:settle() -- 56
	end -- 56
	if self.life > 0 then -- 56
		self:redraw(self.life / self.maxLife) -- 59
	end -- 59
	if self.life <= 0 then -- 59
		self.node:removeFromParent() -- 62
	end -- 62
end -- 53
function MeleeAttack.prototype.dispose(self) -- 71
	self.life = 0 -- 72
	self.node:removeFromParent() -- 73
end -- 71
function MeleeAttack.prototype.settle(self) -- 77
	self.settled = true -- 78
	local ____this_3 -- 78
	____this_3 = ctx -- 79
	local ____opt_2 = ____this_3.damageBreakablesInRadius -- 79
	if ____opt_2 ~= nil then -- 79
		____opt_2(____this_3, self.origin, self.range, self.baseDamage * (1 + self.player.damageBonus)) -- 79
	end -- 79
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.origin, self.range + 40, 16) or ({}) -- 80
	do -- 80
		local i = 0 -- 83
		while i < #candidates do -- 83
			do -- 83
				local enemy = asEnemy(candidates[i + 1]) -- 84
				if enemy == nil or not enemy.isAlive or enemy.markedDead then -- 84
					goto __continue10 -- 85
				end -- 85
				if not inArc( -- 85
					self.origin, -- 86
					enemy.pos, -- 86
					self.facing, -- 86
					self.halfAngle, -- 86
					self.range + enemy.radius -- 86
				) then -- 86
					goto __continue10 -- 87
				end -- 87
				local dir = dirTo(self.origin, enemy.pos) -- 89
				local info = DamageSystem:buildInfo( -- 90
					self.baseDamage, -- 91
					self.player, -- 92
					"melee", -- 93
					dir, -- 94
					"physical", -- 95
					self.crit -- 96
				) -- 96
				DamageSystem:apply(enemy, info) -- 98
				local ____opt_4 = ctx.vfx -- 98
				if ____opt_4 ~= nil then -- 98
					____opt_4:burst(enemy.pos, self.color, 5, 120) -- 99
				end -- 99
			end -- 99
			::__continue10:: -- 99
			i = i + 1 -- 83
		end -- 83
	end -- 83
end -- 77
function MeleeAttack.prototype.redraw(self, alphaT) -- 104
	self.node:clear() -- 105
	local alpha = math.max( -- 106
		0, -- 106
		math.min(1, alphaT) -- 106
	) -- 106
	local segments = 10 -- 107
	local verts = {Vec2.zero} -- 108
	do -- 108
		local i = 0 -- 109
		while i <= segments do -- 109
			local a = self.facing - self.halfAngle + i / segments * self.halfAngle * 2 -- 110
			verts[#verts + 1] = Vec2( -- 111
				math.cos(a) * self.range, -- 111
				math.sin(a) * self.range -- 111
			) -- 111
			i = i + 1 -- 109
		end -- 109
	end -- 109
	self.node:drawPolygon( -- 113
		verts, -- 113
		Color(withAlpha( -- 113
			self.color, -- 113
			math.floor(70 * alpha + 0.5) -- 113
		)) -- 113
	) -- 113
	local a0 = self.facing - self.halfAngle -- 115
	local a1 = self.facing + self.halfAngle -- 116
	self.node:drawSegment( -- 117
		Vec2( -- 118
			math.cos(a0) * self.range, -- 118
			math.sin(a0) * self.range -- 118
		), -- 118
		Vec2( -- 119
			math.cos(a1) * self.range, -- 119
			math.sin(a1) * self.range -- 119
		), -- 119
		2, -- 120
		Color(withAlpha( -- 121
			16777215, -- 121
			math.floor(200 * alpha + 0.5) -- 121
		)) -- 121
	) -- 121
	self.node:drawSegment( -- 124
		Vec2.zero, -- 125
		Vec2( -- 126
			math.cos(self.facing) * self.range, -- 126
			math.sin(self.facing) * self.range -- 126
		), -- 126
		1.5, -- 127
		Color(withAlpha( -- 128
			self.color, -- 128
			math.floor(160 * alpha + 0.5) -- 128
		)) -- 128
	) -- 128
end -- 104
__TS__SetDescriptor( -- 104
	MeleeAttack.prototype, -- 104
	"isDone", -- 104
	{get = function(self) -- 104
		return self.life <= 0 -- 67
	end}, -- 67
	true -- 67
) -- 67
return ____exports -- 67