-- [ts]: Weapons.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____Melee = require("game.combat.Melee") -- 6
local MeleeAttack = ____Melee.MeleeAttack -- 6
local ____Bullet = require("game.combat.Bullet") -- 7
local Bullet = ____Bullet.Bullet -- 7
local asEnemy = ____Bullet.asEnemy -- 7
local ____Summon = require("game.combat.Summon") -- 8
local Summon = ____Summon.Summon -- 8
local ____MathUtils = require("game.utils.MathUtils") -- 9
local dirTo = ____MathUtils.dirTo -- 9
local ____RNG = require("game.utils.RNG") -- 10
local rng = ____RNG.rng -- 10
____exports.WeaponSystem = __TS__Class() -- 12
local WeaponSystem = ____exports.WeaponSystem -- 12
WeaponSystem.name = "WeaponSystem" -- 12
function WeaponSystem.prototype.____constructor(self, player, root) -- 20
	self.timer = 0 -- 15
	self.melees = {} -- 16
	self.bullets = {} -- 17
	self.summons = {} -- 18
	self.player = player -- 21
	self.root = root -- 22
end -- 20
function WeaponSystem.prototype.update(self, dt) -- 26
	local player = self.player -- 27
	if not player.isAlive then -- 27
		return -- 29
	end -- 29
	local character = player.characterDef -- 31
	local interval = math.max(0.1, character.attackInterval / player.attackSpeed) -- 32
	self.timer = self.timer - dt -- 33
	if self.timer <= 0 then -- 33
		self.timer = interval -- 35
		self:attack(character) -- 36
	end -- 36
	do -- 36
		local i = #self.melees - 1 -- 39
		while i >= 0 do -- 39
			self.melees[i + 1]:update(dt) -- 40
			if self.melees[i + 1].isDone then -- 40
				__TS__ArraySplice(self.melees, i, 1) -- 42
			end -- 42
			i = i - 1 -- 39
		end -- 39
	end -- 39
	do -- 39
		local i = #self.bullets - 1 -- 46
		while i >= 0 do -- 46
			self.bullets[i + 1]:update(dt, player) -- 47
			if not self.bullets[i + 1].isActive then -- 47
				__TS__ArraySplice(self.bullets, i, 1) -- 49
			end -- 49
			i = i - 1 -- 46
		end -- 46
	end -- 46
	do -- 46
		local i = #self.summons - 1 -- 53
		while i >= 0 do -- 53
			self.summons[i + 1]:update(dt) -- 54
			if not self.summons[i + 1].active then -- 54
				__TS__ArraySplice(self.summons, i, 1) -- 56
			end -- 56
			i = i - 1 -- 53
		end -- 53
	end -- 53
	if character.weaponClass == "summon" then -- 53
		self:refillSummons(character) -- 61
	end -- 61
end -- 26
function WeaponSystem.prototype.attack(self, character) -- 66
	local player = self.player -- 67
	local baseDamage = character.baseDamage -- 68
	repeat -- 68
		local ____switch17 = character.weaponClass -- 68
		local ____cond17 = ____switch17 == "melee" -- 68
		if ____cond17 then -- 68
			do -- 68
				local halfAngle = math.pi / 3 -- 72
				local ____self_melees_0 = self.melees -- 72
				____self_melees_0[#____self_melees_0 + 1] = __TS__New( -- 73
					MeleeAttack, -- 74
					player.pos, -- 75
					player.facing, -- 76
					character.range, -- 77
					halfAngle, -- 78
					baseDamage, -- 79
					player, -- 80
					character.color, -- 81
					self.root -- 82
				) -- 82
				break -- 85
			end -- 85
		end -- 85
		____cond17 = ____cond17 or ____switch17 == "ranged" -- 85
		if ____cond17 then -- 85
			do -- 85
				local count = math.max(1, player.projectileCount) -- 88
				local doubleCastLevel = player.skillStacks.doubleCast or 0 -- 89
				if doubleCastLevel > 0 and rng:chance(math.min(0.75, doubleCastLevel * 0.2)) then -- 89
					count = count + 1 -- 90
				end -- 90
				local aim = self:aimDir(character.range) -- 91
				local baseAngle = math.atan(aim.y, aim.x) -- 92
				local spread = count > 1 and 0.16 or 0 -- 93
				do -- 93
					local i = 0 -- 94
					while i < count do -- 94
						local offset = (i - (count - 1) / 2) * spread -- 95
						local a = baseAngle + offset -- 96
						local speed = character.speed * player.bulletSpeedMulti -- 97
						local vel = Vec2( -- 98
							math.cos(a) * speed, -- 98
							math.sin(a) * speed -- 98
						) -- 98
						local b = Bullet:spawn( -- 99
							self.root, -- 100
							player.pos, -- 101
							vel, -- 102
							baseDamage, -- 103
							character.range, -- 104
							5, -- 105
							player.pierce, -- 106
							player.split, -- 107
							player.ricochet, -- 108
							character.color, -- 109
							function(nb) return self:addBullet(nb) end -- 110
						) -- 110
						if #self.bullets < 600 then -- 110
							local ____self_bullets_1 = self.bullets -- 110
							____self_bullets_1[#____self_bullets_1 + 1] = b -- 112
						else -- 112
							b:recycle() -- 113
						end -- 113
						i = i + 1 -- 94
					end -- 94
				end -- 94
				local ____opt_2 = ctx.vfx -- 94
				if ____opt_2 ~= nil then -- 94
					____opt_2:flash(player.pos, character.color, 8) -- 115
				end -- 115
				break -- 116
			end -- 116
		end -- 116
		____cond17 = ____cond17 or ____switch17 == "summon" -- 116
		if ____cond17 then -- 116
			do -- 116
				self:spawnSummon(character) -- 119
				break -- 120
			end -- 120
		end -- 120
	until true -- 120
end -- 66
function WeaponSystem.prototype.aimDir(self, range) -- 126
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.player.pos, range, 1) or ({}) -- 127
	if #candidates > 0 then -- 127
		local e = asEnemy(candidates[1]) -- 131
		if e ~= nil and e.isAlive then -- 131
			return dirTo(self.player.pos, e.pos) -- 133
		end -- 133
	end -- 133
	return Vec2( -- 136
		math.cos(self.player.facing), -- 136
		math.sin(self.player.facing) -- 136
	) -- 136
end -- 126
function WeaponSystem.prototype.spawnSummon(self, character) -- 140
	local player = self.player -- 141
	local maxSummon = character.id == "necromancer" and 3 or 2 -- 142
	local extra = player.skillStacks.summonCount ~= nil and player.skillStacks.summonCount or 0 -- 143
	if #self.summons >= maxSummon + extra then -- 143
		return -- 144
	end -- 144
	local angle = rng:range(0, math.pi * 2) -- 145
	local radius = rng:range(50, 80) -- 146
	local pos = Vec2( -- 147
		player.pos.x + math.cos(angle) * radius, -- 147
		player.pos.y + math.sin(angle) * radius -- 147
	) -- 147
	local s = Summon:spawn( -- 148
		self.root, -- 149
		player, -- 150
		pos, -- 151
		character.color, -- 152
		character.baseDamage, -- 153
		math.max(0.4, character.attackInterval * 0.85), -- 154
		13, -- 155
		42, -- 156
		math.max(150, character.speed * 0.6), -- 157
		angle -- 158
	) -- 158
	local ____self_summons_4 = self.summons -- 158
	____self_summons_4[#____self_summons_4 + 1] = s -- 160
end -- 140
function WeaponSystem.prototype.refillSummons(self, character) -- 164
	local maxSummon = character.id == "necromancer" and 3 or 2 -- 165
	local extra = self.player.skillStacks.summonCount ~= nil and self.player.skillStacks.summonCount or 0 -- 166
	if #self.summons < maxSummon + extra then -- 166
		self:spawnSummon(character) -- 168
	end -- 168
end -- 164
function WeaponSystem.prototype.addBullet(self, b) -- 173
	local ____self_bullets_5 = self.bullets -- 173
	____self_bullets_5[#____self_bullets_5 + 1] = b -- 174
end -- 173
function WeaponSystem.prototype.onSkillChanged(self) -- 178
	self.timer = 0 -- 179
end -- 178
function WeaponSystem.prototype.clear(self) -- 183
	do -- 183
		local i = #self.melees - 1 -- 184
		while i >= 0 do -- 184
			self.melees[i + 1]:dispose() -- 185
			__TS__ArraySplice(self.melees, i, 1) -- 186
			i = i - 1 -- 184
		end -- 184
	end -- 184
	do -- 184
		local i = #self.bullets - 1 -- 188
		while i >= 0 do -- 188
			self.bullets[i + 1]:recycle() -- 189
			__TS__ArraySplice(self.bullets, i, 1) -- 190
			i = i - 1 -- 188
		end -- 188
	end -- 188
	do -- 188
		local i = #self.summons - 1 -- 192
		while i >= 0 do -- 192
			self.summons[i + 1]:recycle() -- 193
			__TS__ArraySplice(self.summons, i, 1) -- 194
			i = i - 1 -- 192
		end -- 192
	end -- 192
end -- 183
return ____exports -- 183