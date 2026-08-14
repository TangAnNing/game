-- [ts]: WaveManager.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__InstanceOf = ____lualib.__TS__InstanceOf -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local pickKind -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Label = ____Dora.Label -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____GameContext = require("game.core.GameContext") -- 3
local ctx = ____GameContext.ctx -- 3
local ____Config = require("game.config.Config") -- 4
local Config = ____Config.Config -- 4
local ____Enemy = require("game.enemy.Enemy") -- 6
local Enemy = ____Enemy.Enemy -- 6
local enemyPool = ____Enemy.enemyPool -- 6
local setEnemyPoolRoot = ____Enemy.setEnemyPoolRoot -- 6
local ____EnemyAI = require("game.enemy.EnemyAI") -- 7
local EnemyBulletManager = ____EnemyAI.EnemyBulletManager -- 7
local ____EnemyTypes = require("game.enemy.EnemyTypes") -- 8
local getEnemyDef = ____EnemyTypes.getEnemyDef -- 8
local eliteKinds = ____EnemyTypes.eliteKinds -- 8
local ____RNG = require("game.utils.RNG") -- 9
local rng = ____RNG.rng -- 9
local ____MathUtils = require("game.utils.MathUtils") -- 10
local clamp = ____MathUtils.clamp -- 10
local distSq = ____MathUtils.distSq -- 10
local ____DamageSystem = require("game.combat.DamageSystem") -- 11
local DamageSystem = ____DamageSystem.DamageSystem -- 11
function pickKind(arr) -- 375
	return arr[rng:int(0, #arr - 1) + 1] -- 376
end -- 376
local WORLD_HALF = 1000 -- 13
local SPAWN_INNER = 120 -- 14
local WAVE_BREAK = 3 -- 15
local SPAWN_PER_FRAME = 8 -- 16
local STREAM_BASE = {"walker", "runner", "tank"} -- 17
local waveDefs = { -- 27
	{index = 1, spawns = {{kind = "walker", count = 8, delay = 0.4}}, streamCount = 4, streamInterval = 2}, -- 28
	{index = 2, spawns = {{kind = "walker", count = 10, delay = 0.4}, {kind = "runner", count = 4, delay = 1.2}}, streamCount = 8, streamInterval = 1.8}, -- 29
	{index = 3, spawns = {{kind = "walker", count = 6, delay = 0.4}, {kind = "runner", count = 6, delay = 0.8}, {kind = "elite", count = 1, delay = 6}}, streamCount = 10, streamInterval = 1.6}, -- 30
	{index = 4, spawns = {{kind = "tank", count = 4, delay = 0.8}, {kind = "ranger", count = 4, delay = 1}}, streamCount = 12, streamInterval = 1.5}, -- 31
	{index = 5, spawns = {{kind = "charger", count = 6, delay = 0.6}, {kind = "walker", count = 10, delay = 0.4}}, streamCount = 14, streamInterval = 1.4}, -- 32
	{index = 6, spawns = {{kind = "shield", count = 5, delay = 0.7}, {kind = "runner", count = 8, delay = 0.5}, {kind = "elite", count = 2, delay = 8}}, streamCount = 16, streamInterval = 1.3}, -- 33
	{index = 7, spawns = {{kind = "exploder", count = 6, delay = 0.6}, {kind = "ranger", count = 6, delay = 0.9}}, streamCount = 18, streamInterval = 1.2}, -- 34
	{index = 8, spawns = {{kind = "tank", count = 6, delay = 0.7}, {kind = "charger", count = 8, delay = 0.5}, {kind = "shield", count = 4, delay = 1}}, streamCount = 20, streamInterval = 1.1}, -- 35
	{index = 9, spawns = {{kind = "exploder", count = 8, delay = 0.5}, {kind = "walker", count = 12, delay = 0.3}, {kind = "runner", count = 10, delay = 0.5}}, streamCount = 24, streamInterval = 1}, -- 36
	{index = 10, spawns = {{kind = "boss", count = 1, delay = 2}, {kind = "elite", count = 2, delay = 10}, {kind = "walker", count = 10, delay = 0.5}}, streamCount = 12, streamInterval = 1.6} -- 37
} -- 37
____exports.WaveManager = __TS__Class() -- 40
local WaveManager = ____exports.WaveManager -- 40
WaveManager.name = "WaveManager" -- 40
function WaveManager.prototype.____constructor(self, root) -- 57
	self.enemies = {} -- 43
	self.entries = {} -- 44
	self.streamCount = 0 -- 45
	self.streamInterval = 1 -- 46
	self.streamTimer = 0 -- 47
	self.waveIndex = 0 -- 48
	self.state = "intermission" -- 49
	self.timer = WAVE_BREAK -- 50
	self.tickIndex = 0 -- 51
	self.started = false -- 52
	self.labelTimer = 0 -- 54
	self.mode = "chapter" -- 55
	self.root = root -- 58
	self.bullets = __TS__New(EnemyBulletManager, root) -- 59
	setEnemyPoolRoot(root) -- 60
	ctx.findEnemiesNear = function(____, pos, radius, limit) -- 62
		return self:findEnemiesNear(pos, radius, limit) -- 63
	end -- 62
	ctx.damageEnemiesInRadius = function(____, pos, radius, info) -- 65
		return self:damageEnemiesInRadius(pos, radius, info) -- 66
	end -- 65
	ctx.onDamageEnemy = function(____, enemy, info) -- 68
		if __TS__InstanceOf(enemy, Enemy) and enemy.isAlive and not enemy.markedDead then -- 68
			enemy:takeDamage(info) -- 70
		end -- 70
	end -- 68
end -- 57
function WaveManager.prototype.start(self, mode) -- 91
	self.mode = mode -- 92
	self.started = true -- 93
	self.waveIndex = 0 -- 94
	self.state = "intermission" -- 95
	self.timer = 1 -- 96
end -- 91
function WaveManager.prototype.update(self, dt) -- 99
	if not self.started then -- 99
		return -- 100
	end -- 100
	self.bullets:update(dt) -- 101
	if self.state == "intermission" then -- 101
		self.timer = self.timer - dt -- 103
		self:cleanupDead() -- 104
		self:updateLabel(dt) -- 105
		if self.timer <= 0 then -- 105
			self:startWave(self.waveIndex + 1) -- 107
		end -- 107
		return -- 109
	end -- 109
	self:spawnFromEntries(dt) -- 111
	self:spawnStream(dt) -- 112
	self:updateEnemies(dt) -- 113
	self:cleanupDead() -- 114
	self:updateLabel(dt) -- 115
	self:checkWaveCleared() -- 116
end -- 99
function WaveManager.prototype.clearAll(self) -- 119
	do -- 119
		local i = #self.enemies - 1 -- 120
		while i >= 0 do -- 120
			enemyPool:release(self.enemies[i + 1]) -- 121
			i = i - 1 -- 120
		end -- 120
	end -- 120
	__TS__ArraySetLength(self.enemies, 0) -- 120
	self.bullets:clear() -- 124
	__TS__ArraySetLength(self.entries, 0) -- 124
	self.streamCount = 0 -- 126
	self.started = false -- 127
	self.state = "intermission" -- 128
	self.timer = WAVE_BREAK -- 129
	self:hideWaveLabel() -- 130
end -- 119
function WaveManager.prototype.startWave(self, n) -- 134
	self.waveIndex = n -- 135
	ctx.stats.wave = n -- 136
	local def = self:buildWaveDef(n) -- 137
	self.entries = __TS__ArrayMap( -- 138
		def.spawns, -- 138
		function(____, s) return {kind = s.kind, remaining = s.count, delay = s.delay, timer = 0} end -- 138
	) -- 138
	self.streamCount = def.streamCount -- 144
	self.streamInterval = def.streamInterval -- 145
	self.streamTimer = def.streamInterval -- 146
	self.state = "active" -- 147
	self:showWaveLabel(n) -- 148
end -- 134
function WaveManager.prototype.buildWaveDef(self, n) -- 151
	if n <= 10 then -- 151
		return waveDefs[n] -- 153
	end -- 153
	local base = waveDefs[10] -- 156
	local boost = (n - 10) * 0.15 -- 157
	local countBoost = (n - 10) * 0.2 -- 158
	return { -- 159
		index = n, -- 160
		spawns = __TS__ArrayMap( -- 161
			base.spawns, -- 161
			function(____, s) return { -- 161
				kind = s.kind, -- 162
				count = math.floor(s.count * (1 + countBoost)), -- 163
				delay = s.delay -- 164
			} end -- 164
		), -- 164
		streamCount = math.floor(base.streamCount * (1 + countBoost)), -- 166
		streamInterval = math.max(0.5, base.streamInterval) -- 167
	} -- 167
end -- 151
function WaveManager.prototype.checkWaveCleared(self) -- 171
	if #self.enemies > 0 then -- 171
		return -- 172
	end -- 172
	local allSpawned = true -- 173
	do -- 173
		local i = 0 -- 174
		while i < #self.entries do -- 174
			if self.entries[i + 1].remaining > 0 then -- 174
				allSpawned = false -- 176
				break -- 177
			end -- 177
			i = i + 1 -- 174
		end -- 174
	end -- 174
	if not allSpawned or self.streamCount > 0 then -- 174
		return -- 180
	end -- 180
	local targetWave = self.mode == "challenge" and 12 or 10 -- 181
	if self.mode ~= "endless" and self.waveIndex == targetWave and ctx.onVictory then -- 181
		ctx:onVictory() -- 183
		return -- 184
	end -- 184
	self.state = "intermission" -- 186
	self.timer = WAVE_BREAK -- 187
	self:hideWaveLabel() -- 188
end -- 171
function WaveManager.prototype.spawnFromEntries(self, dt) -- 192
	local spawned = 0 -- 193
	do -- 193
		local i = 0 -- 194
		while i < #self.entries do -- 194
			do -- 194
				local en = self.entries[i + 1] -- 195
				if en.remaining <= 0 then -- 195
					goto __continue29 -- 196
				end -- 196
				en.timer = en.timer - dt -- 197
				if en.timer <= 0 then -- 197
					if spawned < SPAWN_PER_FRAME and self:aliveCount() < self:enemyCap() then -- 197
						self:spawnEnemy(en.kind) -- 200
						en.remaining = en.remaining - 1 -- 201
						spawned = spawned + 1 -- 202
					end -- 202
					en.timer = en.delay -- 204
				end -- 204
			end -- 204
			::__continue29:: -- 204
			i = i + 1 -- 194
		end -- 194
	end -- 194
end -- 192
function WaveManager.prototype.spawnStream(self, dt) -- 209
	if self.streamCount <= 0 then -- 209
		return -- 210
	end -- 210
	self.streamTimer = self.streamTimer - dt -- 211
	if self.streamTimer <= 0 then -- 211
		if self:aliveCount() < self:enemyCap() then -- 211
			self:spawnEnemy(pickKind(STREAM_BASE)) -- 214
			self.streamCount = self.streamCount - 1 -- 215
		end -- 215
		self.streamTimer = self.streamInterval -- 217
	end -- 217
end -- 209
function WaveManager.prototype.spawnEnemy(self, kind) -- 221
	local def = getEnemyDef(kind) -- 222
	local pos = self:spawnPointNearEdge() -- 223
	local e = enemyPool:acquire() -- 224
	e:resetFromPool(pos, def) -- 225
	local hpMult = 1 -- 226
	if self.waveIndex > 10 then -- 226
		hpMult = hpMult + (self.waveIndex - 10) * 0.15 -- 227
	end -- 227
	if self.mode == "challenge" then -- 227
		hpMult = hpMult * 1.35 -- 228
	end -- 228
	if hpMult > 1 then -- 228
		e:applyWaveBoost(hpMult) -- 230
	end -- 230
	e.bulletManager = self.bullets -- 232
	local ____self_enemies_0 = self.enemies -- 232
	____self_enemies_0[#____self_enemies_0 + 1] = e -- 233
end -- 221
function WaveManager.prototype.spawnPointNearEdge(self) -- 236
	local p = ctx.player ~= nil and ctx.player.pos or Vec2.zero -- 237
	local a = rng:range(0, math.pi * 2) -- 238
	local r = 440 + rng:range(0, 220) -- 239
	local x = clamp( -- 240
		p.x + math.cos(a) * r, -- 240
		-WORLD_HALF + SPAWN_INNER, -- 240
		WORLD_HALF - SPAWN_INNER -- 240
	) -- 240
	local y = clamp( -- 241
		p.y + math.sin(a) * r, -- 241
		-WORLD_HALF + SPAWN_INNER, -- 241
		WORLD_HALF - SPAWN_INNER -- 241
	) -- 241
	return Vec2(x, y) -- 242
end -- 236
function WaveManager.prototype.enemyCap(self) -- 245
	return Config.enemyCap[Config.quality + 1] -- 246
end -- 245
function WaveManager.prototype.aliveCount(self) -- 249
	local c = 0 -- 250
	do -- 250
		local i = 0 -- 251
		while i < #self.enemies do -- 251
			if self.enemies[i + 1].isAlive then -- 251
				c = c + 1 -- 252
			end -- 252
			i = i + 1 -- 251
		end -- 251
	end -- 251
	return c -- 254
end -- 249
function WaveManager.prototype.updateEnemies(self, dt) -- 258
	local divisor = Config.aiTickDivisor -- 259
	self.tickIndex = (self.tickIndex + 1) % divisor -- 260
	local playerPos = ctx.player ~= nil and ctx.player.pos or Vec2.zero -- 261
	local halfW = View.size.width / 2 + Config.cullMargin -- 262
	local halfH = View.size.height / 2 + Config.cullMargin -- 263
	local idx = 0 -- 264
	do -- 264
		local i = 0 -- 265
		while i < #self.enemies do -- 265
			do -- 265
				local e = self.enemies[i + 1] -- 266
				if not e.isAlive then -- 266
					goto __continue49 -- 267
				end -- 267
				local offX = math.abs(e.pos.x - playerPos.x) -- 268
				local offY = math.abs(e.pos.y - playerPos.y) -- 269
				local visible = offX <= halfW and offY <= halfH -- 270
				e.isVisible = visible -- 271
				local aiTick = idx % divisor == self.tickIndex -- 272
				e:update(dt, playerPos, 1, aiTick) -- 273
				local contactRadius = e.radius + 16 -- 274
				if distSq(e.pos, playerPos) <= contactRadius * contactRadius then -- 274
					local ____this_2 -- 274
					____this_2 = ctx -- 276
					local ____opt_1 = ____this_2.onPlayerDamaged -- 276
					if ____opt_1 ~= nil then -- 276
						____opt_1(____this_2, e.def.damage, e.pos) -- 276
					end -- 276
				end -- 276
				idx = idx + 1 -- 278
			end -- 278
			::__continue49:: -- 278
			i = i + 1 -- 265
		end -- 265
	end -- 265
end -- 258
function WaveManager.prototype.cleanupDead(self) -- 282
	do -- 282
		local i = #self.enemies - 1 -- 283
		while i >= 0 do -- 283
			if not self.enemies[i + 1].isAlive then -- 283
				local last = #self.enemies - 1 -- 285
				local e = self.enemies[i + 1] -- 286
				self.enemies[i + 1] = self.enemies[last + 1] -- 287
				table.remove(self.enemies) -- 288
				enemyPool:release(e) -- 289
			end -- 289
			i = i - 1 -- 283
		end -- 283
	end -- 283
end -- 282
function WaveManager.prototype.findEnemiesNear(self, pos, radius, limit) -- 295
	local result = {} -- 296
	local rr = radius * radius -- 297
	do -- 297
		local i = 0 -- 298
		while i < #self.enemies do -- 298
			do -- 298
				local e = self.enemies[i + 1] -- 299
				if not e.isAlive or e.markedDead then -- 299
					goto __continue58 -- 300
				end -- 300
				local dx = e.pos.x - pos.x -- 301
				local dy = e.pos.y - pos.y -- 302
				if dx * dx + dy * dy <= rr then -- 302
					result[#result + 1] = e -- 303
				end -- 303
			end -- 303
			::__continue58:: -- 303
			i = i + 1 -- 298
		end -- 298
	end -- 298
	do -- 298
		local i = 1 -- 306
		while i < #result do -- 306
			local key = result[i + 1] -- 307
			local j = i - 1 -- 308
			while j >= 0 and distSq(pos, result[j + 1].pos) > distSq(pos, key.pos) do -- 308
				result[j + 1 + 1] = result[j + 1] -- 310
				j = j - 1 -- 311
			end -- 311
			result[j + 1 + 1] = key -- 313
			i = i + 1 -- 306
		end -- 306
	end -- 306
	if limit > 0 and #result > limit then -- 306
		__TS__ArraySetLength(result, limit) -- 306
	end -- 306
	return result -- 318
end -- 295
function WaveManager.prototype.damageEnemiesInRadius(self, pos, radius, info) -- 321
	local count = 0 -- 322
	do -- 322
		local i = 0 -- 323
		while i < #self.enemies do -- 323
			do -- 323
				local e = self.enemies[i + 1] -- 324
				if not e.isAlive or e.markedDead then -- 324
					goto __continue67 -- 325
				end -- 325
				local dx = e.pos.x - pos.x -- 326
				local dy = e.pos.y - pos.y -- 327
				local rr = radius + e.radius -- 328
				if dx * dx + dy * dy <= rr * rr then -- 328
					DamageSystem:apply(e, info) -- 330
					count = count + 1 -- 331
				end -- 331
			end -- 331
			::__continue67:: -- 331
			i = i + 1 -- 323
		end -- 323
	end -- 323
	return count -- 334
end -- 321
function WaveManager.prototype.showWaveLabel(self, n) -- 338
	self:hideWaveLabel() -- 339
	local label = Label("sarasa-mono-sc-regular", 48) -- 340
	if label == nil then -- 340
		return -- 341
	end -- 341
	local isBossWave = n == 10 -- 342
	label.text = isBossWave and ("⚠ 第 " .. tostring(n)) .. " 波 · BOSS" or ("第 " .. tostring(n)) .. " 波" -- 343
	label.color = Color(isBossWave and 255 or 230, isBossWave and 120 or 200, 80, 255) -- 344
	label.anchor = Vec2(0.5, 0.5) -- 345
	label.y = View.size.height / 2 - 60 -- 346
	label:addTo(self.root) -- 347
	self.waveLabel = label -- 348
	self.labelTimer = 2.2 -- 349
end -- 338
function WaveManager.prototype.hideWaveLabel(self) -- 352
	if self.waveLabel ~= nil then -- 352
		self.waveLabel:removeFromParent() -- 354
		self.waveLabel = nil -- 355
	end -- 355
end -- 352
function WaveManager.prototype.updateLabel(self, dt) -- 359
	if self.waveLabel == nil then -- 359
		return -- 360
	end -- 360
	self.labelTimer = self.labelTimer - dt -- 361
	if self.labelTimer <= 0 then -- 361
		self.waveLabel:removeFromParent() -- 363
		self.waveLabel = nil -- 364
	end -- 364
end -- 359
__TS__SetDescriptor( -- 359
	WaveManager.prototype, -- 359
	"currentWave", -- 359
	{get = function(self) -- 359
		return self.waveIndex -- 76
	end}, -- 76
	true -- 76
) -- 76
__TS__SetDescriptor( -- 76
	WaveManager.prototype, -- 76
	"isWaveCleared", -- 76
	{get = function(self) -- 76
		return self.state == "intermission" and self.timer <= 0 -- 80
	end}, -- 80
	true -- 80
) -- 80
__TS__SetDescriptor( -- 80
	WaveManager.prototype, -- 80
	"activeEnemies", -- 80
	{get = function(self) -- 80
		return self.enemies -- 84
	end}, -- 84
	true -- 84
) -- 84
__TS__SetDescriptor( -- 84
	WaveManager.prototype, -- 84
	"bulletManager", -- 84
	{get = function(self) -- 84
		return self.bullets -- 88
	end}, -- 88
	true -- 88
) -- 88
function ____exports.randomBaseKind() -- 370
	return pickKind(eliteKinds) -- 371
end -- 370
return ____exports -- 370