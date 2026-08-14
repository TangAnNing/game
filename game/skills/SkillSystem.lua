-- [ts]: SkillSystem.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____SkillDefs = require("game.skills.SkillDefs") -- 6
local getSkillDef = ____SkillDefs.getSkillDef -- 6
local ____DamageSystem = require("game.combat.DamageSystem") -- 7
local DamageSystem = ____DamageSystem.DamageSystem -- 7
local ACTIVE_COOLDOWN = {activeBladeStorm = 8, activeMeteor = 10, activeHeal = 12} -- 30
____exports.SkillSystem = __TS__Class() -- 36
local SkillSystem = ____exports.SkillSystem -- 36
SkillSystem.name = "SkillSystem" -- 36
function SkillSystem.prototype.____constructor(self, player, game) -- 59
	self.learnedSkills = {} -- 39
	self.levels = __TS__New(Map) -- 40
	self.cooldowns = __TS__New(Map) -- 41
	self.mods = { -- 42
		invincibleOnHit = false, -- 43
		soulEater = 0, -- 44
		bloodBlade = 0, -- 45
		combo = 0, -- 46
		manaFlow = 0, -- 47
		arcaneSurge = 0, -- 48
		doubleCast = 0, -- 49
		summonCount = 0, -- 50
		summonExplode = 0 -- 51
	} -- 51
	self.slowTimer = 0 -- 54
	self.burnTimer = 0 -- 55
	self.poisonTimer = 0 -- 56
	self.freezeTimer = 0 -- 57
	self.player = player -- 60
	self.game = game -- 61
end -- 59
function SkillSystem.prototype.getLevel(self, id) -- 70
	return self.levels:get(id) or 0 -- 71
end -- 70
function SkillSystem.prototype.getMods(self) -- 75
	return __TS__ObjectAssign({}, self.mods) -- 76
end -- 75
function SkillSystem.prototype.isReady(self, id) -- 80
	if self:getLevel(id) <= 0 then -- 80
		return false -- 81
	end -- 81
	return (self.cooldowns:get(id) or 0) <= 0 -- 82
end -- 80
function SkillSystem.prototype.applySkill(self, id) -- 86
	local def = getSkillDef(id) -- 87
	local level = self:getLevel(id) -- 88
	if level >= def.maxStack then -- 88
		return -- 89
	end -- 89
	self.levels:set(id, level + 1) -- 91
	if level == 0 then -- 91
		local ____self_learnedSkills_0 = self.learnedSkills -- 91
		____self_learnedSkills_0[#____self_learnedSkills_0 + 1] = id -- 92
	end -- 92
	local p = self.player -- 94
	p.skillStacks[id] = (p.skillStacks[id] or 0) + 1 -- 95
	local m = self.mods -- 96
	repeat -- 96
		local ____switch10 = id -- 96
		local ____cond10 = ____switch10 == "damagePlus" -- 96
		if ____cond10 then -- 96
			p.damageBonus = p.damageBonus + 0.15 -- 98
			break -- 98
		end -- 98
		____cond10 = ____cond10 or ____switch10 == "damagePlus2" -- 98
		if ____cond10 then -- 98
			p.damageBonus = p.damageBonus + 0.25 -- 99
			break -- 99
		end -- 99
		____cond10 = ____cond10 or ____switch10 == "attackSpeed" -- 99
		if ____cond10 then -- 99
			p.attackSpeed = p.attackSpeed * 1.12 -- 100
			break -- 100
		end -- 100
		____cond10 = ____cond10 or ____switch10 == "moveSpeed" -- 100
		if ____cond10 then -- 100
			p.moveSpeed = p.moveSpeed * 1.1 -- 101
			break -- 101
		end -- 101
		____cond10 = ____cond10 or ____switch10 == "maxHp" -- 101
		if ____cond10 then -- 101
			p.maxHp = p.maxHp + 20 -- 103
			p.hp = p.hp + 20 -- 104
			break -- 105
		end -- 105
		____cond10 = ____cond10 or ____switch10 == "critChance" -- 105
		if ____cond10 then -- 105
			p.critChance = p.critChance + 0.08 -- 106
			break -- 106
		end -- 106
		____cond10 = ____cond10 or ____switch10 == "critDamage" -- 106
		if ____cond10 then -- 106
			p.critMulti = p.critMulti + 0.3 -- 107
			break -- 107
		end -- 107
		____cond10 = ____cond10 or ____switch10 == "pierce" -- 107
		if ____cond10 then -- 107
			p.pierce = p.pierce + 1 -- 108
			break -- 108
		end -- 108
		____cond10 = ____cond10 or ____switch10 == "split" -- 108
		if ____cond10 then -- 108
			p.split = p.split + 1 -- 109
			break -- 109
		end -- 109
		____cond10 = ____cond10 or ____switch10 == "projectilePlus" -- 109
		if ____cond10 then -- 109
			p.projectileCount = p.projectileCount + 1 -- 110
			break -- 110
		end -- 110
		____cond10 = ____cond10 or ____switch10 == "lifesteal" -- 110
		if ____cond10 then -- 110
			p.lifesteal = p.lifesteal + 0.03 -- 111
			break -- 111
		end -- 111
		____cond10 = ____cond10 or ____switch10 == "pickupRadius" -- 111
		if ____cond10 then -- 111
			p.pickupRadius = p.pickupRadius + 30 -- 112
			break -- 112
		end -- 112
		____cond10 = ____cond10 or ____switch10 == "regen" -- 112
		if ____cond10 then -- 112
			p.regen = p.regen + 1 -- 113
			break -- 113
		end -- 113
		____cond10 = ____cond10 or ____switch10 == "magnet" -- 113
		if ____cond10 then -- 113
			p.magnet = p.magnet + 40 -- 114
			break -- 114
		end -- 114
		____cond10 = ____cond10 or ____switch10 == "dodge" -- 114
		if ____cond10 then -- 114
			p.dodge = p.dodge + 0.05 -- 116
			break -- 116
		end -- 116
		____cond10 = ____cond10 or ____switch10 == "bulletSpeed" -- 116
		if ____cond10 then -- 116
			p.bulletSpeedMulti = p.bulletSpeedMulti + 0.15 -- 117
			break -- 117
		end -- 117
		____cond10 = ____cond10 or ____switch10 == "gold" -- 117
		if ____cond10 then -- 117
			p.goldMulti = p.goldMulti + 0.2 -- 118
			break -- 118
		end -- 118
		____cond10 = ____cond10 or ____switch10 == "experience" -- 118
		if ____cond10 then -- 118
			p.expMulti = p.expMulti + 0.15 -- 119
			break -- 119
		end -- 119
		____cond10 = ____cond10 or ____switch10 == "thorns" -- 119
		if ____cond10 then -- 119
			p.thorns = p.thorns + 0.3 -- 120
			break -- 120
		end -- 120
		____cond10 = ____cond10 or ____switch10 == "chain" -- 120
		if ____cond10 then -- 120
			p.chain = p.chain + 1 -- 121
			break -- 121
		end -- 121
		____cond10 = ____cond10 or ____switch10 == "ricochet" -- 121
		if ____cond10 then -- 121
			p.ricochet = p.ricochet + 1 -- 122
			break -- 122
		end -- 122
		____cond10 = ____cond10 or ____switch10 == "explosion" -- 122
		if ____cond10 then -- 122
			p.explosion = p.explosion + 1 -- 123
			break -- 123
		end -- 123
		____cond10 = ____cond10 or ____switch10 == "slowAura" -- 123
		if ____cond10 then -- 123
			p.slowAura = p.slowAura + 1 -- 124
			break -- 124
		end -- 124
		____cond10 = ____cond10 or ____switch10 == "burn" -- 124
		if ____cond10 then -- 124
			p.burn = p.burn + 1 -- 125
			break -- 125
		end -- 125
		____cond10 = ____cond10 or ____switch10 == "poison" -- 125
		if ____cond10 then -- 125
			p.poison = p.poison + 1 -- 126
			break -- 126
		end -- 126
		____cond10 = ____cond10 or ____switch10 == "freeze" -- 126
		if ____cond10 then -- 126
			p.freeze = p.freeze + 1 -- 127
			break -- 127
		end -- 127
		____cond10 = ____cond10 or ____switch10 == "homing" -- 127
		if ____cond10 then -- 127
			p.homing = p.homing + 1 -- 128
			break -- 128
		end -- 128
		____cond10 = ____cond10 or ____switch10 == "natureGrow" -- 128
		if ____cond10 then -- 128
			p.expMulti = p.expMulti + 0.3 -- 129
			break -- 129
		end -- 129
		____cond10 = ____cond10 or ____switch10 == "invincible" -- 129
		if ____cond10 then -- 129
			m.invincibleOnHit = true -- 131
			break -- 131
		end -- 131
		____cond10 = ____cond10 or ____switch10 == "soulEater" -- 131
		if ____cond10 then -- 131
			p.lifesteal = p.lifesteal + 0.06 -- 132
			m.soulEater = m.soulEater + 0.06 -- 132
			break -- 132
		end -- 132
		____cond10 = ____cond10 or ____switch10 == "bloodBlade" -- 132
		if ____cond10 then -- 132
			p.lifesteal = p.lifesteal + 0.05 -- 133
			m.bloodBlade = m.bloodBlade + 0.05 -- 133
			break -- 133
		end -- 133
		____cond10 = ____cond10 or ____switch10 == "comboHit" -- 133
		if ____cond10 then -- 133
			p.attackSpeed = p.attackSpeed * 1.1 -- 134
			m.combo = m.combo + 1 -- 134
			break -- 134
		end -- 134
		____cond10 = ____cond10 or ____switch10 == "manaFlow" -- 134
		if ____cond10 then -- 134
			m.manaFlow = m.manaFlow + 0.15 -- 135
			break -- 135
		end -- 135
		____cond10 = ____cond10 or ____switch10 == "arcaneSurge" -- 135
		if ____cond10 then -- 135
			p.critChance = p.critChance + 0.12 -- 136
			m.arcaneSurge = m.arcaneSurge + 0.12 -- 136
			break -- 136
		end -- 136
		____cond10 = ____cond10 or ____switch10 == "doubleCast" -- 136
		if ____cond10 then -- 136
			m.doubleCast = m.doubleCast + 0.2 -- 137
			break -- 137
		end -- 137
		____cond10 = ____cond10 or ____switch10 == "summonCount" -- 137
		if ____cond10 then -- 137
			m.summonCount = m.summonCount + 1 -- 138
			break -- 138
		end -- 138
		____cond10 = ____cond10 or ____switch10 == "summonExplode" -- 138
		if ____cond10 then -- 138
			m.summonExplode = m.summonExplode + 1 -- 139
			break -- 139
		end -- 139
		____cond10 = ____cond10 or (____switch10 == "activeBladeStorm" or ____switch10 == "activeMeteor" or ____switch10 == "activeHeal") -- 139
		if ____cond10 then -- 139
			break -- 144
		end -- 144
	until true -- 144
end -- 86
function SkillSystem.prototype.castActive(self, id) -- 149
	if self:getLevel(id) <= 0 then -- 149
		return -- 150
	end -- 150
	if (self.cooldowns:get(id) or 0) > 0 then -- 150
		return -- 151
	end -- 151
	self.cooldowns:set(id, ACTIVE_COOLDOWN[id] or 6) -- 152
	local p = self.player -- 154
	local base = 1 + p.damageBonus -- 155
	repeat -- 155
		local ____switch14 = id -- 155
		local ____cond14 = ____switch14 == "activeBladeStorm" -- 155
		if ____cond14 then -- 155
			do -- 155
				local radius = 140 -- 158
				local info = { -- 159
					amount = math.floor(45 * base + 0.5), -- 160
					kind = "physical", -- 161
					crit = false, -- 162
					knockback = Vec2.zero, -- 163
					hitStop = 0.08, -- 164
					shake = 8, -- 165
					flash = true, -- 166
					source = "skill" -- 167
				} -- 167
				local ____this_2 -- 167
				____this_2 = self.game -- 169
				local ____opt_1 = ____this_2.damageEnemiesInRadius -- 169
				if ____opt_1 ~= nil then -- 169
					____opt_1(____this_2, p.pos, radius, info) -- 169
				end -- 169
				local ____opt_3 = self.game.vfx -- 169
				if ____opt_3 ~= nil then -- 169
					____opt_3:ring(p.pos, 4293436221, radius) -- 170
				end -- 170
				local ____opt_5 = self.game.vfx -- 170
				if ____opt_5 ~= nil then -- 170
					____opt_5:burst(p.pos, 4294296171, 18, 220) -- 171
				end -- 171
				break -- 172
			end -- 172
		end -- 172
		____cond14 = ____cond14 or ____switch14 == "activeMeteor" -- 172
		if ____cond14 then -- 172
			do -- 172
				local target = p.pos -- 176
				local ____this_8 -- 176
				____this_8 = self.game -- 177
				local ____opt_7 = ____this_8.findEnemiesNear -- 177
				local found = ____opt_7 and ____opt_7(____this_8, p.pos, 9999, 1) or ({}) -- 177
				if #found > 0 then -- 177
					local first = found[1] -- 179
					if first ~= nil and first.isAlive then -- 179
						target = first.pos -- 180
					end -- 180
				else -- 180
					target = Vec2(p.pos.x + 180, p.pos.y) -- 182
				end -- 182
				local radius = 110 -- 184
				local info = { -- 185
					amount = math.floor(60 * base + 0.5), -- 186
					kind = "magic", -- 187
					crit = false, -- 188
					knockback = Vec2.zero, -- 189
					hitStop = 0.1, -- 190
					shake = 10, -- 191
					flash = true, -- 192
					source = "skill" -- 193
				} -- 193
				local ____this_10 -- 193
				____this_10 = self.game -- 195
				local ____opt_9 = ____this_10.damageEnemiesInRadius -- 195
				if ____opt_9 ~= nil then -- 195
					____opt_9(____this_10, target, radius, info) -- 195
				end -- 195
				local ____opt_11 = self.game.vfx -- 195
				if ____opt_11 ~= nil then -- 195
					____opt_11:burst(target, 4294942531, 26, 320) -- 196
				end -- 196
				local ____opt_13 = self.game.vfx -- 196
				if ____opt_13 ~= nil then -- 196
					____opt_13:flash(target, 4294955658, radius) -- 197
				end -- 197
				local ____opt_15 = self.game.vfx -- 197
				if ____opt_15 ~= nil then -- 197
					____opt_15:ring(target, 4294942531, radius) -- 198
				end -- 198
				break -- 199
			end -- 199
		end -- 199
		____cond14 = ____cond14 or ____switch14 == "activeHeal" -- 199
		if ____cond14 then -- 199
			do -- 199
				local amount = p.maxHp * 0.3 -- 202
				p.hp = math.min(p.maxHp, p.hp + amount) -- 203
				local ____opt_17 = self.game.vfx -- 203
				if ____opt_17 ~= nil then -- 203
					____opt_17:burst(p.pos, 4284015486, 12, 120) -- 204
				end -- 204
				break -- 205
			end -- 205
		end -- 205
	until true -- 205
end -- 149
function SkillSystem.prototype.update(self, dt) -- 211
	self.cooldowns:forEach(function(____, value, key, map) -- 213
		if value > 0 then -- 213
			map:set(key, value - dt * (1 + self.mods.manaFlow)) -- 214
		end -- 214
	end) -- 213
	local p = self.player -- 217
	if not p.isAlive then -- 217
		return -- 218
	end -- 218
	do -- 218
		local i = 0 -- 220
		while i < #self.learnedSkills do -- 220
			local id = self.learnedSkills[i + 1] -- 221
			if id == "activeHeal" and p.hp / p.maxHp <= 0.55 then -- 221
				self:castActive(id) -- 222
			end -- 222
			if id == "activeBladeStorm" or id == "activeMeteor" then -- 222
				self:castActive(id) -- 223
			end -- 223
			i = i + 1 -- 220
		end -- 220
	end -- 220
	local slowLevel = p.slowAura -- 227
	if slowLevel > 0 then -- 227
		self.slowTimer = self.slowTimer - dt -- 229
		if self.slowTimer <= 0 then -- 229
			self.slowTimer = 0.3 -- 231
			self:applyStatus( -- 232
				p.pos, -- 232
				110, -- 232
				24, -- 232
				function(enemy) -- 232
					if enemy.slowdown ~= nil then -- 232
						enemy:slowdown(0.5, 0.5) -- 233
					end -- 233
				end -- 232
			) -- 232
		end -- 232
	end -- 232
	local burnLevel = p.burn -- 238
	if burnLevel > 0 then -- 238
		self.burnTimer = self.burnTimer - dt -- 240
		if self.burnTimer <= 0 then -- 240
			self.burnTimer = 0.5 -- 242
			self:applyStatus( -- 243
				p.pos, -- 243
				140, -- 243
				24, -- 243
				function(enemy) -- 243
					DamageSystem:apply( -- 244
						enemy, -- 244
						self:dotInfo(2 * burnLevel, "magic") -- 244
					) -- 244
				end -- 243
			) -- 243
		end -- 243
	end -- 243
	local poisonLevel = p.poison -- 249
	if poisonLevel > 0 then -- 249
		self.poisonTimer = self.poisonTimer - dt -- 251
		if self.poisonTimer <= 0 then -- 251
			self.poisonTimer = 0.8 -- 253
			self:applyStatus( -- 254
				p.pos, -- 254
				140, -- 254
				24, -- 254
				function(enemy) -- 254
					DamageSystem:apply( -- 255
						enemy, -- 255
						self:dotInfo(3 * poisonLevel, "poison") -- 255
					) -- 255
				end -- 254
			) -- 254
		end -- 254
	end -- 254
	local freezeLevel = p.freeze -- 260
	if freezeLevel > 0 then -- 260
		self.freezeTimer = self.freezeTimer - dt -- 262
		if self.freezeTimer <= 0 then -- 262
			self.freezeTimer = 2.5 -- 264
			self:applyStatus( -- 265
				p.pos, -- 265
				130, -- 265
				24, -- 265
				function(enemy) -- 265
					if enemy.freeze ~= nil then -- 265
						enemy:freeze(1.2) -- 266
					end -- 266
				end -- 265
			) -- 265
		end -- 265
	end -- 265
end -- 211
function SkillSystem.prototype.dotInfo(self, amount, kind) -- 273
	return { -- 274
		amount = amount, -- 275
		kind = kind, -- 276
		crit = false, -- 277
		knockback = Vec2.zero, -- 278
		hitStop = 0, -- 279
		shake = 0, -- 280
		flash = false, -- 281
		source = "dot" -- 282
	} -- 282
end -- 273
function SkillSystem.prototype.applyStatus(self, pos, radius, limit, fn) -- 287
	local ____this_20 -- 287
	____this_20 = self.game -- 288
	local ____opt_19 = ____this_20.findEnemiesNear -- 288
	local found = ____opt_19 and ____opt_19(____this_20, pos, radius, limit) -- 288
	if found == nil then -- 288
		return -- 289
	end -- 289
	do -- 289
		local i = 0 -- 290
		while i < #found do -- 290
			local enemy = found[i + 1] -- 291
			if enemy ~= nil and enemy.isAlive then -- 291
				fn(enemy) -- 292
			end -- 292
			i = i + 1 -- 290
		end -- 290
	end -- 290
end -- 287
function SkillSystem.prototype.reset(self) -- 297
	__TS__ArraySetLength(self.learnedSkills, 0) -- 297
	self.levels:clear() -- 299
	self.cooldowns:clear() -- 300
	self.slowTimer = 0 -- 301
	self.burnTimer = 0 -- 302
	self.poisonTimer = 0 -- 303
	self.freezeTimer = 0 -- 304
	self.mods = { -- 305
		invincibleOnHit = false, -- 306
		soulEater = 0, -- 307
		bloodBlade = 0, -- 308
		combo = 0, -- 309
		manaFlow = 0, -- 310
		arcaneSurge = 0, -- 311
		doubleCast = 0, -- 312
		summonCount = 0, -- 313
		summonExplode = 0 -- 314
	} -- 314
end -- 297
__TS__SetDescriptor( -- 297
	SkillSystem.prototype, -- 297
	"learned", -- 297
	{get = function(self) -- 297
		return __TS__ArraySlice(self.learnedSkills) -- 66
	end}, -- 66
	true -- 66
) -- 66
return ____exports -- 66