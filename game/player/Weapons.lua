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
local ____AudioManager = require("game.audio.AudioManager") -- 11
local audio = ____AudioManager.audio -- 11
local Sfx = ____AudioManager.Sfx -- 11
____exports.WeaponSystem = __TS__Class() -- 13
local WeaponSystem = ____exports.WeaponSystem -- 13
WeaponSystem.name = "WeaponSystem" -- 13
function WeaponSystem.prototype.____constructor(self, player, root) -- 21
	self.timer = 0 -- 16
	self.melees = {} -- 17
	self.bullets = {} -- 18
	self.summons = {} -- 19
	self.player = player -- 22
	self.root = root -- 23
end -- 21
function WeaponSystem.prototype.update(self, dt) -- 27
	local player = self.player -- 28
	if not player.isAlive then -- 28
		return -- 30
	end -- 30
	local character = player.characterDef -- 32
	local interval = math.max(0.1, character.attackInterval / player.attackSpeed) -- 33
	self.timer = self.timer - dt -- 34
	if self.timer <= 0 then -- 34
		self.timer = interval -- 36
		self:attack(character) -- 37
	end -- 37
	do -- 37
		local i = #self.melees - 1 -- 40
		while i >= 0 do -- 40
			self.melees[i + 1]:update(dt) -- 41
			if self.melees[i + 1].isDone then -- 41
				__TS__ArraySplice(self.melees, i, 1) -- 43
			end -- 43
			i = i - 1 -- 40
		end -- 40
	end -- 40
	do -- 40
		local i = #self.bullets - 1 -- 47
		while i >= 0 do -- 47
			self.bullets[i + 1]:update(dt, player) -- 48
			if not self.bullets[i + 1].isActive then -- 48
				__TS__ArraySplice(self.bullets, i, 1) -- 50
			end -- 50
			i = i - 1 -- 47
		end -- 47
	end -- 47
	do -- 47
		local i = #self.summons - 1 -- 54
		while i >= 0 do -- 54
			self.summons[i + 1]:update(dt) -- 55
			if not self.summons[i + 1].active then -- 55
				__TS__ArraySplice(self.summons, i, 1) -- 57
			end -- 57
			i = i - 1 -- 54
		end -- 54
	end -- 54
	if character.weaponClass == "summon" then -- 54
		self:refillSummons(character) -- 62
	end -- 62
end -- 27
function WeaponSystem.prototype.attack(self, character) -- 67
	local player = self.player -- 68
	local baseDamage = character.baseDamage -- 69
	repeat -- 69
		local ____switch17 = character.weaponClass -- 69
		local ____cond17 = ____switch17 == "melee" -- 69
		if ____cond17 then -- 69
			do -- 69
				local halfAngle = math.pi -- 73
				local ____self_melees_0 = self.melees -- 73
				____self_melees_0[#____self_melees_0 + 1] = __TS__New( -- 74
					MeleeAttack, -- 75
					player.pos, -- 76
					player.facing, -- 77
					character.range, -- 78
					halfAngle, -- 79
					baseDamage, -- 80
					player, -- 81
					character.color, -- 82
					self.root -- 83
				) -- 83
				audio:playSfx(Sfx.MeleeSwing, 0.12) -- 86
				break -- 87
			end -- 87
		end -- 87
		____cond17 = ____cond17 or ____switch17 == "ranged" -- 87
		if ____cond17 then -- 87
			do -- 87
				local count = math.max(1, player.projectileCount) -- 90
				local doubleCastLevel = player.skillStacks.doubleCast or 0 -- 91
				if doubleCastLevel > 0 and rng:chance(math.min(0.75, doubleCastLevel * 0.2)) then -- 91
					count = count + 1 -- 92
				end -- 92
				local aim = self:aimDir(character.range) -- 93
				local baseAngle = math.atan(aim.y, aim.x) -- 94
				local spread = count > 1 and 0.16 or 0 -- 95
				do -- 95
					local i = 0 -- 96
					while i < count do -- 96
						local offset = (i - (count - 1) / 2) * spread -- 97
						local a = baseAngle + offset -- 98
						local speed = character.speed * player.bulletSpeedMulti -- 99
						local vel = Vec2( -- 100
							math.cos(a) * speed, -- 100
							math.sin(a) * speed -- 100
						) -- 100
						local b = Bullet:spawn( -- 101
							self.root, -- 102
							player.pos, -- 103
							vel, -- 104
							baseDamage, -- 105
							character.range, -- 106
							5, -- 107
							player.pierce, -- 108
							player.split, -- 109
							player.ricochet, -- 110
							character.color, -- 111
							function(nb) return self:addBullet(nb) end -- 112
						) -- 112
						if #self.bullets < 600 then -- 112
							local ____self_bullets_1 = self.bullets -- 112
							____self_bullets_1[#____self_bullets_1 + 1] = b -- 114
						else -- 114
							b:recycle() -- 115
						end -- 115
						i = i + 1 -- 96
					end -- 96
				end -- 96
				audio:playSfx(character.id == "gunner" and Sfx.GunShot or Sfx.MagicCast, 0.06) -- 117
				local ____opt_2 = ctx.vfx -- 117
				if ____opt_2 ~= nil then -- 117
					____opt_2:flash(player.pos, character.color, 8) -- 118
				end -- 118
				break -- 119
			end -- 119
		end -- 119
		____cond17 = ____cond17 or ____switch17 == "summon" -- 119
		if ____cond17 then -- 119
			do -- 119
				if self:spawnSummon(character) then -- 119
					audio:playSfx(character.id == "druid" and Sfx.NatureSummon or Sfx.NecroSummon, 0.18) -- 123
				end -- 123
				break -- 125
			end -- 125
		end -- 125
	until true -- 125
end -- 67
function WeaponSystem.prototype.aimDir(self, range) -- 131
	local candidates = ctx.findEnemiesNear ~= nil and ctx:findEnemiesNear(self.player.pos, range, 1) or ({}) -- 132
	if #candidates > 0 then -- 132
		local e = asEnemy(candidates[1]) -- 136
		if e ~= nil and e.isAlive then -- 136
			return dirTo(self.player.pos, e.pos) -- 138
		end -- 138
	end -- 138
	return Vec2( -- 141
		math.cos(self.player.facing), -- 141
		math.sin(self.player.facing) -- 141
	) -- 141
end -- 131
function WeaponSystem.prototype.spawnSummon(self, character) -- 145
	local player = self.player -- 146
	local maxSummon = math.max(1, character.projectileCount) -- 147
	local extra = player.skillStacks.summonCount ~= nil and player.skillStacks.summonCount or 0 -- 148
	if #self.summons >= maxSummon + extra then -- 148
		return false -- 149
	end -- 149
	local angle = rng:range(0, math.pi * 2) -- 150
	local radius = rng:range(50, 80) -- 151
	local pos = Vec2( -- 152
		player.pos.x + math.cos(angle) * radius, -- 152
		player.pos.y + math.sin(angle) * radius -- 152
	) -- 152
	local s = Summon:spawn( -- 153
		self.root, -- 154
		player, -- 155
		pos, -- 156
		character.color, -- 157
		character.baseDamage, -- 158
		math.max(0.4, character.attackInterval * 0.85), -- 159
		13, -- 160
		42, -- 161
		math.max(150, character.speed * 0.6), -- 162
		angle -- 163
	) -- 163
	local ____self_summons_4 = self.summons -- 163
	____self_summons_4[#____self_summons_4 + 1] = s -- 165
	return true -- 166
end -- 145
function WeaponSystem.prototype.refillSummons(self, character) -- 170
	local maxSummon = math.max(1, character.projectileCount) -- 171
	local extra = self.player.skillStacks.summonCount ~= nil and self.player.skillStacks.summonCount or 0 -- 172
	if #self.summons < maxSummon + extra then -- 172
		self:spawnSummon(character) -- 174
	end -- 174
end -- 170
function WeaponSystem.prototype.addBullet(self, b) -- 179
	local ____self_bullets_5 = self.bullets -- 179
	____self_bullets_5[#____self_bullets_5 + 1] = b -- 180
end -- 179
function WeaponSystem.prototype.onSkillChanged(self) -- 184
	self.timer = 0 -- 185
end -- 184
function WeaponSystem.prototype.clear(self) -- 189
	do -- 189
		local i = #self.melees - 1 -- 190
		while i >= 0 do -- 190
			self.melees[i + 1]:dispose() -- 191
			__TS__ArraySplice(self.melees, i, 1) -- 192
			i = i - 1 -- 190
		end -- 190
	end -- 190
	do -- 190
		local i = #self.bullets - 1 -- 194
		while i >= 0 do -- 194
			self.bullets[i + 1]:recycle() -- 195
			__TS__ArraySplice(self.bullets, i, 1) -- 196
			i = i - 1 -- 194
		end -- 194
	end -- 194
	do -- 194
		local i = #self.summons - 1 -- 198
		while i >= 0 do -- 198
			self.summons[i + 1]:recycle() -- 199
			__TS__ArraySplice(self.summons, i, 1) -- 200
			i = i - 1 -- 198
		end -- 198
	end -- 198
end -- 189
return ____exports -- 189