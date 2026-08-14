-- [ts]: Game.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 4
local Camera2D = ____Dora.Camera2D -- 4
local Director = ____Dora.Director -- 4
local Node = ____Dora.Node -- 4
local Vec2 = ____Dora.Vec2 -- 4
local ____GameContext = require("game.core.GameContext") -- 5
local ctx = ____GameContext.ctx -- 5
local ____Characters = require("game.player.Characters") -- 6
local getCharacter = ____Characters.getCharacter -- 6
local ____Player = require("game.player.Player") -- 8
local Player = ____Player.Player -- 8
local ____Weapons = require("game.player.Weapons") -- 9
local WeaponSystem = ____Weapons.WeaponSystem -- 9
local ____CameraRig = require("game.core.CameraRig") -- 10
local CameraRig = ____CameraRig.CameraRig -- 10
local ____VFX = require("game.core.VFX") -- 11
local VFX = ____VFX.VFX -- 11
local ____Feedback = require("game.core.Feedback") -- 12
local Feedback = ____Feedback.Feedback -- 12
local ____Scene = require("game.scene.Scene") -- 13
local Scene = ____Scene.Scene -- 13
local ____WaveManager = require("game.enemy.WaveManager") -- 14
local WaveManager = ____WaveManager.WaveManager -- 14
local ____Pickups = require("game.pickup.Pickups") -- 15
local PickupSystem = ____Pickups.PickupSystem -- 15
local ____SkillSystem = require("game.skills.SkillSystem") -- 16
local SkillSystem = ____SkillSystem.SkillSystem -- 16
local ____LevelUp = require("game.skills.LevelUp") -- 17
local LevelUpSystem = ____LevelUp.LevelUpSystem -- 17
local ____RNG = require("game.utils.RNG") -- 18
local rng = ____RNG.rng -- 18
local ____HUD = require("game.ui.HUD") -- 19
local HUD = ____HUD.HUD -- 19
local ____LevelUpPanel = require("game.ui.LevelUpPanel") -- 20
local LevelUpPanel = ____LevelUpPanel.LevelUpPanel -- 20
local ____MainMenu = require("game.ui.MainMenu") -- 21
local MainMenu = ____MainMenu.MainMenu -- 21
local ____PauseMenu = require("game.ui.PauseMenu") -- 22
local PauseMenu = ____PauseMenu.PauseMenu -- 22
local ____VirtualJoystick = require("game.ui.VirtualJoystick") -- 23
local VirtualJoystick = ____VirtualJoystick.VirtualJoystick -- 23
local ____Input = require("game.input.Input") -- 24
local inputSystem = ____Input.inputSystem -- 24
local ____AudioManager = require("game.audio.AudioManager") -- 25
local audio = ____AudioManager.audio -- 25
local ____DebugPanel = require("game.debug.DebugPanel") -- 26
local debugPanel = ____DebugPanel.debugPanel -- 26
local ____Save = require("game.save.Save") -- 27
local saveSystem = ____Save.saveSystem -- 27
local ____Config = require("game.config.Config") -- 28
local Config = ____Config.Config -- 28
____exports.Game = __TS__Class() -- 35
local Game = ____exports.Game -- 35
Game.name = "Game" -- 35
function Game.prototype.____constructor(self) -- 63
	self.worldRoot = Node() -- 36
	self.uiRoot = Node() -- 37
	self.logicNode = Node() -- 38
	self.cameraRig = __TS__New(CameraRig) -- 41
	self.weaponSystem = nil -- 47
	self.player = nil -- 57
	self.currentMode = "chapter" -- 58
	self.elapsed = 0 -- 59
	self.saveGoldReward = 0 -- 60
	self.runPersisted = true -- 61
	self.worldRoot:addTo(Director.entry) -- 64
	self.uiRoot:addTo(Director.ui) -- 65
	self:setupCamera() -- 68
	self.vfx = __TS__New(VFX, self.worldRoot) -- 71
	self.feedback = __TS__New(Feedback, self.cameraRig, self.worldRoot) -- 72
	self.scene = __TS__New(Scene, self.worldRoot) -- 75
	self.waveManager = __TS__New(WaveManager, self.worldRoot) -- 78
	self.pickups = __TS__New(PickupSystem, self.worldRoot) -- 79
	self.skillSystem = __TS__New( -- 84
		SkillSystem, -- 84
		ctx.player or self:dummyPlayerView(), -- 84
		ctx -- 84
	) -- 84
	self.levelUp = __TS__New(LevelUpSystem, self.skillSystem, rng) -- 85
	self.hud = __TS__New(HUD, self.worldRoot, self.uiRoot) -- 86
	self.levelUpPanel = __TS__New(LevelUpPanel, self.uiRoot) -- 87
	self.joystick = __TS__New(VirtualJoystick, self.uiRoot) -- 88
	self.joystick:setVisible(false) -- 89
	self.mainMenu = __TS__New( -- 90
		MainMenu, -- 90
		{onStart = function(____, charId, mode) return self:startRun(charId, mode) end} -- 90
	) -- 90
	self.pauseMenu = __TS__New( -- 91
		PauseMenu, -- 91
		{ -- 91
			onResume = function() return self:resumeFromPause() end, -- 92
			onRestart = function() return self:restartRun() end, -- 93
			onQuit = function() return self:quitToMenu() end -- 94
		} -- 94
	) -- 94
	self.levelUp.onChoicesReady = function(____, choices) -- 98
		self.joystick:setVisible(false) -- 99
		self.levelUpPanel:show(choices) -- 100
	end -- 98
	self.levelUp.onLevelUpFinished = function() -- 102
		self.levelUpPanel:hide() -- 103
		self.joystick:setVisible(true) -- 104
	end -- 102
	self.levelUpPanel.onPick = function(____, index) return self.levelUp:choose(index) end -- 107
	ctx.onPauseToggle = function() return self:togglePause() end -- 110
	ctx.onGameOver = function() return self:onGameOver() end -- 113
	ctx.onVictory = function() return self:onVictory() end -- 114
	inputSystem:attachJoystick(self.joystick) -- 117
	self.logicNode:addTo(Director.entry) -- 120
	self.logicNode:schedule(function(dt) -- 121
		self:update(dt) -- 122
		return false -- 123
	end) -- 121
	ctx.phase = "menu" -- 127
	self.mainMenu:show() -- 128
end -- 63
function Game.prototype.dummyPlayerView(self) -- 132
	local base = { -- 134
		pos = Vec2.zero, -- 135
		hp = 100, -- 135
		maxHp = 100, -- 135
		level = 1, -- 135
		exp = 0, -- 135
		expNeed = 1, -- 135
		moveSpeed = 240, -- 136
		attackSpeed = 1, -- 136
		critChance = 0.1, -- 136
		critMulti = 1.5, -- 136
		damageBonus = 0, -- 137
		projectileCount = 1, -- 137
		pierce = 0, -- 137
		split = 0, -- 137
		lifesteal = 0, -- 138
		pickupRadius = 16, -- 138
		invincible = false, -- 138
		invincibleTimer = 0, -- 138
		regen = 0, -- 139
		magnet = 0, -- 139
		dodge = 0, -- 139
		bulletSpeedMulti = 1, -- 139
		expMulti = 1, -- 139
		goldMulti = 1, -- 139
		thorns = 0, -- 140
		chain = 0, -- 140
		homing = 0, -- 140
		ricochet = 0, -- 140
		explosion = 0, -- 140
		slowAura = 0, -- 141
		burn = 0, -- 141
		poison = 0, -- 141
		freeze = 0, -- 141
		skillStacks = {}, -- 141
		isAlive = true -- 141
	} -- 141
	return base -- 143
end -- 132
function Game.prototype.setupCamera(self) -- 146
	local camera = Camera2D() -- 147
	Director:pushCamera(camera) -- 148
	self.cameraRig:setup(camera, Vec2.zero) -- 149
end -- 146
function Game.prototype.update(self, dt) -- 153
	inputSystem:update() -- 154
	debugPanel:update(dt) -- 155
	local phase = ctx.phase -- 157
	if phase == "playing" then -- 157
		self.elapsed = self.elapsed + dt -- 160
		ctx.stats.timeAlive = self.elapsed -- 161
		if ctx.player ~= nil and ctx.player.isAlive then -- 161
			local p = self.player -- 164
			if p ~= nil then -- 164
				p:update(dt, inputSystem.moveDir) -- 166
			end -- 166
			if self.weaponSystem ~= nil then -- 166
				self.weaponSystem:update(dt) -- 169
			end -- 169
			self.skillSystem:update(dt) -- 171
			self.waveManager:update(dt) -- 172
			self.pickups:update(dt) -- 173
			self.scene:update(dt) -- 174
		end -- 174
		if self.cameraRig ~= nil and ctx.player ~= nil then -- 174
			self.cameraRig:follow(ctx.player.pos) -- 179
		end -- 179
	end -- 179
	self.cameraRig:update(dt) -- 184
	self.feedback:update(dt) -- 185
	self.vfx:update(dt) -- 186
	self.hud:update(dt) -- 189
	if inputSystem.pausePressed and (phase == "playing" or phase == "paused") then -- 189
		self:togglePause() -- 193
	end -- 193
end -- 153
function Game.prototype.startRun(self, charId, mode) -- 198
	self.currentMode = mode -- 199
	ctx.mode = mode -- 200
	if mode == "daily" then -- 200
		rng:setSeed(tonumber(os.date("%Y%m%d")) or 20260813) -- 201
	end -- 201
	self:cleanupRun() -- 204
	ctx.stats = { -- 207
		kills = 0, -- 208
		eliteKills = 0, -- 208
		bossKills = 0, -- 208
		damageDealt = 0, -- 209
		damageTaken = 0, -- 209
		wave = 0, -- 210
		timeAlive = 0, -- 210
		playerLevel = 1 -- 210
	} -- 210
	self.elapsed = 0 -- 212
	self.saveGoldReward = 0 -- 213
	self.runPersisted = false -- 214
	local char = getCharacter(charId) -- 217
	self.player = __TS__New(Player, char, self.worldRoot) -- 218
	ctx.player = self.player -- 219
	ctx.character = char -- 220
	local save = saveSystem:load() -- 221
	local ____self_player_0, ____damageBonus_1 = self.player, "damageBonus" -- 221
	____self_player_0[____damageBonus_1] = ____self_player_0[____damageBonus_1] + math.max(0, save.permanent.damage) -- 222
	local ____self_player_2, ____maxHp_3 = self.player, "maxHp" -- 222
	____self_player_2[____maxHp_3] = ____self_player_2[____maxHp_3] + math.max(0, save.permanent.maxHp) -- 223
	self.player.hp = self.player.maxHp -- 224
	local ____self_player_4, ____moveSpeed_5 = self.player, "moveSpeed" -- 224
	____self_player_4[____moveSpeed_5] = ____self_player_4[____moveSpeed_5] + math.max(0, save.permanent.moveSpeed) -- 225
	if save.settings ~= nil then -- 225
		audio:setMuted(save.settings.muted) -- 227
		Config.quality = save.settings.quality <= 0 and 0 or (save.settings.quality >= 2 and 2 or 1) -- 228
	end -- 228
	self.skillSystem = __TS__New(SkillSystem, self.player, ctx) -- 232
	self.levelUp = __TS__New(LevelUpSystem, self.skillSystem, rng) -- 233
	self.levelUp.onChoicesReady = function(____, choices) -- 234
		self.joystick:setVisible(false) -- 235
		self.levelUpPanel:show(choices) -- 236
	end -- 234
	self.levelUp.onLevelUpFinished = function() -- 238
		self.levelUpPanel:hide() -- 239
		self.joystick:setVisible(true) -- 240
	end -- 238
	self.weaponSystem = __TS__New(WeaponSystem, self.player, self.worldRoot) -- 244
	self.waveManager:start(mode) -- 247
	self.waveManager:update(0) -- 248
	self.pickups:seedArena() -- 249
	self.mainMenu:hide() -- 252
	self.hud:reset() -- 253
	self.levelUpPanel:hide() -- 254
	self.joystick:setVisible(true) -- 255
	self.cameraRig:snap(Vec2.zero) -- 258
	audio:playMusic("") -- 261
	ctx.phase = "playing" -- 263
end -- 198
function Game.prototype.cleanupRun(self) -- 266
	if self.weaponSystem ~= nil then -- 266
		self.weaponSystem:clear() -- 268
		self.weaponSystem = nil -- 269
	end -- 269
	if self.player ~= nil then -- 269
		self.player.node:removeFromParent() -- 272
		self.player = nil -- 273
	end -- 273
	self.waveManager:clearAll() -- 275
	self.pickups:clearAll() -- 276
	self.skillSystem:reset() -- 277
	self.levelUp:reset() -- 278
	self.feedback:clear() -- 279
	self.levelUpPanel:hide() -- 280
	self.joystick:setVisible(false) -- 281
	self.hud:reset() -- 282
end -- 266
function Game.prototype.togglePause(self) -- 285
	if ctx.phase == "playing" then -- 285
		ctx.phase = "paused" -- 287
		self.joystick:setVisible(false) -- 288
		self.pauseMenu:showPause() -- 289
	elseif ctx.phase == "paused" then -- 289
		self:resumeFromPause() -- 291
	end -- 291
end -- 285
function Game.prototype.resumeFromPause(self) -- 295
	if ctx.phase == "paused" then -- 295
		ctx.phase = "playing" -- 297
		self.pauseMenu:hidePause() -- 298
		self.joystick:setVisible(true) -- 299
	end -- 299
end -- 295
function Game.prototype.restartRun(self) -- 303
	if self.player == nil then -- 303
		return -- 304
	end -- 304
	local charId = self.player.characterDef.id -- 305
	local mode = self.currentMode -- 306
	self.pauseMenu:hidePause() -- 307
	self:persistAfterRun() -- 308
	self:startRun(charId, mode) -- 309
end -- 303
function Game.prototype.quitToMenu(self) -- 312
	self.pauseMenu:hidePause() -- 313
	self:persistAfterRun() -- 315
	self:cleanupRun() -- 316
	ctx.phase = "menu" -- 317
	self.mainMenu:show() -- 318
end -- 312
function Game.prototype.persistAfterRun(self) -- 322
	if self.runPersisted then -- 322
		return -- 323
	end -- 323
	self.runPersisted = true -- 324
	local save = saveSystem:load() -- 325
	save.totalKills = save.totalKills + ctx.stats.kills -- 327
	local goldMulti = self.player ~= nil and self.player.goldMulti or 1 -- 328
	save.gold = save.gold + math.floor(self.saveGoldReward * goldMulti) -- 329
	if self.currentMode == "endless" and ctx.stats.wave > save.bestWave then -- 329
		save.bestWave = ctx.stats.wave -- 332
	end -- 332
	if save.stats == nil then -- 332
		save.stats = {totalGames = 0, totalTime = 0, maxKills = 0} -- 335
	end -- 335
	local ____save_stats_6, ____totalGames_7 = save.stats, "totalGames" -- 335
	____save_stats_6[____totalGames_7] = ____save_stats_6[____totalGames_7] + 1 -- 337
	local ____save_stats_8, ____totalTime_9 = save.stats, "totalTime" -- 337
	____save_stats_8[____totalTime_9] = ____save_stats_8[____totalTime_9] + math.floor(self.elapsed) -- 338
	if ctx.stats.kills > save.stats.maxKills then -- 338
		save.stats.maxKills = ctx.stats.kills -- 339
	end -- 339
	if save.totalKills >= 500 and __TS__ArrayIndexOf(save.unlockedCharacters, "mage") < 0 then -- 339
		local ____save_unlockedCharacters_10 = save.unlockedCharacters -- 339
		____save_unlockedCharacters_10[#____save_unlockedCharacters_10 + 1] = "mage" -- 340
	end -- 340
	if save.gold >= 300 and __TS__ArrayIndexOf(save.unlockedCharacters, "gunner") < 0 then -- 340
		local ____save_unlockedCharacters_11 = save.unlockedCharacters -- 340
		____save_unlockedCharacters_11[#____save_unlockedCharacters_11 + 1] = "gunner" -- 341
	end -- 341
	if save.bestWave >= 20 and __TS__ArrayIndexOf(save.unlockedCharacters, "necromancer") < 0 then -- 341
		local ____save_unlockedCharacters_12 = save.unlockedCharacters -- 341
		____save_unlockedCharacters_12[#____save_unlockedCharacters_12 + 1] = "necromancer" -- 342
	end -- 342
	saveSystem:save(save) -- 343
end -- 322
function Game.prototype.onGameOver(self) -- 346
	if ctx.phase == "gameover" or ctx.phase == "victory" then -- 346
		return -- 347
	end -- 347
	ctx.phase = "gameover" -- 348
	self.joystick:setVisible(false) -- 349
	self.saveGoldReward = math.floor(ctx.stats.wave * 5) -- 350
	self.pauseMenu:showGameOver({ -- 351
		kills = ctx.stats.kills, -- 352
		eliteKills = ctx.stats.eliteKills, -- 352
		bossKills = ctx.stats.bossKills, -- 352
		damageDealt = ctx.stats.damageDealt, -- 353
		damageTaken = ctx.stats.damageTaken, -- 353
		wave = ctx.stats.wave, -- 354
		timeAlive = math.floor(ctx.stats.timeAlive), -- 354
		playerLevel = ctx.stats.playerLevel -- 355
	}) -- 355
	self:persistAfterRun() -- 357
end -- 346
function Game.prototype.onVictory(self) -- 360
	if ctx.phase == "gameover" or ctx.phase == "victory" then -- 360
		return -- 361
	end -- 361
	ctx.phase = "victory" -- 362
	self.joystick:setVisible(false) -- 363
	self.saveGoldReward = math.floor(ctx.stats.wave * 8) -- 364
	self.pauseMenu:showVictory({ -- 365
		kills = ctx.stats.kills, -- 366
		eliteKills = ctx.stats.eliteKills, -- 366
		bossKills = ctx.stats.bossKills, -- 366
		damageDealt = ctx.stats.damageDealt, -- 367
		damageTaken = ctx.stats.damageTaken, -- 367
		wave = ctx.stats.wave, -- 368
		timeAlive = math.floor(ctx.stats.timeAlive), -- 368
		playerLevel = ctx.stats.playerLevel -- 369
	}) -- 369
	self:persistAfterRun() -- 371
end -- 360
return ____exports -- 360