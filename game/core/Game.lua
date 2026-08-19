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
	audio:update(dt) -- 154
	inputSystem:update() -- 155
	debugPanel:update(dt) -- 156
	local phase = ctx.phase -- 158
	if phase == "playing" then -- 158
		self.elapsed = self.elapsed + dt -- 161
		ctx.stats.timeAlive = self.elapsed -- 162
		if ctx.player ~= nil and ctx.player.isAlive then -- 162
			local p = self.player -- 165
			if p ~= nil then -- 165
				p:update(dt, inputSystem.moveDir) -- 167
			end -- 167
			if self.weaponSystem ~= nil then -- 167
				self.weaponSystem:update(dt) -- 170
			end -- 170
			self.skillSystem:update(dt) -- 172
			self.waveManager:update(dt) -- 173
			self.pickups:update(dt) -- 174
			self.scene:update(dt) -- 175
		end -- 175
		if self.cameraRig ~= nil and ctx.player ~= nil then -- 175
			self.cameraRig:follow(ctx.player.pos) -- 180
		end -- 180
	end -- 180
	self.cameraRig:update(dt) -- 185
	self.feedback:update(dt) -- 186
	self.vfx:update(dt) -- 187
	self.hud:update(dt) -- 190
	if inputSystem.pausePressed and (phase == "playing" or phase == "paused") then -- 190
		self:togglePause() -- 194
	end -- 194
end -- 153
function Game.prototype.startRun(self, charId, mode) -- 199
	self.currentMode = mode -- 200
	ctx.mode = mode -- 201
	if mode == "daily" then -- 201
		rng:setSeed(tonumber(os.date("%Y%m%d")) or 20260813) -- 202
	end -- 202
	self:cleanupRun() -- 205
	ctx.stats = { -- 208
		kills = 0, -- 209
		eliteKills = 0, -- 209
		bossKills = 0, -- 209
		damageDealt = 0, -- 210
		damageTaken = 0, -- 210
		wave = 0, -- 211
		timeAlive = 0, -- 211
		playerLevel = 1 -- 211
	} -- 211
	self.elapsed = 0 -- 213
	self.saveGoldReward = 0 -- 214
	self.runPersisted = false -- 215
	local char = getCharacter(charId) -- 218
	self.player = __TS__New(Player, char, self.worldRoot) -- 219
	ctx.player = self.player -- 220
	ctx.character = char -- 221
	local save = saveSystem:load() -- 222
	local ____self_player_0, ____damageBonus_1 = self.player, "damageBonus" -- 222
	____self_player_0[____damageBonus_1] = ____self_player_0[____damageBonus_1] + math.max(0, save.permanent.damage) -- 223
	local ____self_player_2, ____maxHp_3 = self.player, "maxHp" -- 223
	____self_player_2[____maxHp_3] = ____self_player_2[____maxHp_3] + math.max(0, save.permanent.maxHp) -- 224
	self.player.hp = self.player.maxHp -- 225
	local ____self_player_4, ____moveSpeed_5 = self.player, "moveSpeed" -- 225
	____self_player_4[____moveSpeed_5] = ____self_player_4[____moveSpeed_5] + math.max(0, save.permanent.moveSpeed) -- 226
	if save.settings ~= nil then -- 226
		audio:setMuted(save.settings.muted) -- 228
		Config.quality = save.settings.quality <= 0 and 0 or (save.settings.quality >= 2 and 2 or 1) -- 229
	end -- 229
	self.skillSystem = __TS__New(SkillSystem, self.player, ctx) -- 233
	self.levelUp = __TS__New(LevelUpSystem, self.skillSystem, rng) -- 234
	self.levelUp.onChoicesReady = function(____, choices) -- 235
		self.joystick:setVisible(false) -- 236
		self.levelUpPanel:show(choices) -- 237
	end -- 235
	self.levelUp.onLevelUpFinished = function() -- 239
		self.levelUpPanel:hide() -- 240
		self.joystick:setVisible(true) -- 241
	end -- 239
	self.weaponSystem = __TS__New(WeaponSystem, self.player, self.worldRoot) -- 245
	self.waveManager:start(mode) -- 248
	self.waveManager:update(0) -- 249
	self.pickups:seedArena() -- 250
	self.mainMenu:hide() -- 253
	self.hud:reset() -- 254
	self.levelUpPanel:hide() -- 255
	self.joystick:setVisible(true) -- 256
	self.cameraRig:snap(Vec2.zero) -- 259
	audio:playMusic("") -- 262
	ctx.phase = "playing" -- 264
end -- 199
function Game.prototype.cleanupRun(self) -- 267
	if self.weaponSystem ~= nil then -- 267
		self.weaponSystem:clear() -- 269
		self.weaponSystem = nil -- 270
	end -- 270
	if self.player ~= nil then -- 270
		self.player.node:removeFromParent() -- 273
		self.player = nil -- 274
	end -- 274
	self.waveManager:clearAll() -- 276
	self.pickups:clearAll() -- 277
	self.skillSystem:reset() -- 278
	self.levelUp:reset() -- 279
	self.feedback:clear() -- 280
	self.levelUpPanel:hide() -- 281
	self.joystick:setVisible(false) -- 282
	self.hud:reset() -- 283
end -- 267
function Game.prototype.togglePause(self) -- 286
	if ctx.phase == "playing" then -- 286
		ctx.phase = "paused" -- 288
		self.joystick:setVisible(false) -- 289
		self.pauseMenu:showPause() -- 290
	elseif ctx.phase == "paused" then -- 290
		self:resumeFromPause() -- 292
	end -- 292
end -- 286
function Game.prototype.resumeFromPause(self) -- 296
	if ctx.phase == "paused" then -- 296
		ctx.phase = "playing" -- 298
		self.pauseMenu:hidePause() -- 299
		self.joystick:setVisible(true) -- 300
	end -- 300
end -- 296
function Game.prototype.restartRun(self) -- 304
	if self.player == nil then -- 304
		return -- 305
	end -- 305
	local charId = self.player.characterDef.id -- 306
	local mode = self.currentMode -- 307
	self.pauseMenu:hidePause() -- 308
	self:persistAfterRun() -- 309
	self:startRun(charId, mode) -- 310
end -- 304
function Game.prototype.quitToMenu(self) -- 313
	self.pauseMenu:hidePause() -- 314
	self:persistAfterRun() -- 316
	self:cleanupRun() -- 317
	ctx.phase = "menu" -- 318
	self.mainMenu:show() -- 319
end -- 313
function Game.prototype.persistAfterRun(self) -- 323
	if self.runPersisted then -- 323
		return -- 324
	end -- 324
	self.runPersisted = true -- 325
	local save = saveSystem:load() -- 326
	save.totalKills = save.totalKills + ctx.stats.kills -- 328
	local goldMulti = self.player ~= nil and self.player.goldMulti or 1 -- 329
	save.gold = save.gold + math.floor(self.saveGoldReward * goldMulti) -- 330
	if self.currentMode == "endless" and ctx.stats.wave > save.bestWave then -- 330
		save.bestWave = ctx.stats.wave -- 333
	end -- 333
	if save.stats == nil then -- 333
		save.stats = {totalGames = 0, totalTime = 0, maxKills = 0} -- 336
	end -- 336
	local ____save_stats_6, ____totalGames_7 = save.stats, "totalGames" -- 336
	____save_stats_6[____totalGames_7] = ____save_stats_6[____totalGames_7] + 1 -- 338
	local ____save_stats_8, ____totalTime_9 = save.stats, "totalTime" -- 338
	____save_stats_8[____totalTime_9] = ____save_stats_8[____totalTime_9] + math.floor(self.elapsed) -- 339
	if ctx.stats.kills > save.stats.maxKills then -- 339
		save.stats.maxKills = ctx.stats.kills -- 340
	end -- 340
	if save.totalKills >= 500 and __TS__ArrayIndexOf(save.unlockedCharacters, "mage") < 0 then -- 340
		local ____save_unlockedCharacters_10 = save.unlockedCharacters -- 340
		____save_unlockedCharacters_10[#____save_unlockedCharacters_10 + 1] = "mage" -- 341
	end -- 341
	if save.gold >= 300 and __TS__ArrayIndexOf(save.unlockedCharacters, "gunner") < 0 then -- 341
		local ____save_unlockedCharacters_11 = save.unlockedCharacters -- 341
		____save_unlockedCharacters_11[#____save_unlockedCharacters_11 + 1] = "gunner" -- 342
	end -- 342
	if save.bestWave >= 20 and __TS__ArrayIndexOf(save.unlockedCharacters, "necromancer") < 0 then -- 342
		local ____save_unlockedCharacters_12 = save.unlockedCharacters -- 342
		____save_unlockedCharacters_12[#____save_unlockedCharacters_12 + 1] = "necromancer" -- 343
	end -- 343
	saveSystem:save(save) -- 344
end -- 323
function Game.prototype.onGameOver(self) -- 347
	if ctx.phase == "gameover" or ctx.phase == "victory" then -- 347
		return -- 348
	end -- 348
	ctx.phase = "gameover" -- 349
	self.joystick:setVisible(false) -- 350
	self.saveGoldReward = math.floor(ctx.stats.wave * 5) -- 351
	self.pauseMenu:showGameOver({ -- 352
		kills = ctx.stats.kills, -- 353
		eliteKills = ctx.stats.eliteKills, -- 353
		bossKills = ctx.stats.bossKills, -- 353
		damageDealt = ctx.stats.damageDealt, -- 354
		damageTaken = ctx.stats.damageTaken, -- 354
		wave = ctx.stats.wave, -- 355
		timeAlive = math.floor(ctx.stats.timeAlive), -- 355
		playerLevel = ctx.stats.playerLevel -- 356
	}) -- 356
	self:persistAfterRun() -- 358
end -- 347
function Game.prototype.onVictory(self) -- 361
	if ctx.phase == "gameover" or ctx.phase == "victory" then -- 361
		return -- 362
	end -- 362
	ctx.phase = "victory" -- 363
	self.joystick:setVisible(false) -- 364
	self.saveGoldReward = math.floor(ctx.stats.wave * 8) -- 365
	self.pauseMenu:showVictory({ -- 366
		kills = ctx.stats.kills, -- 367
		eliteKills = ctx.stats.eliteKills, -- 367
		bossKills = ctx.stats.bossKills, -- 367
		damageDealt = ctx.stats.damageDealt, -- 368
		damageTaken = ctx.stats.damageTaken, -- 368
		wave = ctx.stats.wave, -- 369
		timeAlive = math.floor(ctx.stats.timeAlive), -- 369
		playerLevel = ctx.stats.playerLevel -- 370
	}) -- 370
	self:persistAfterRun() -- 372
end -- 361
return ____exports -- 361