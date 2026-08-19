-- [ts]: DamageSystem.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____Config = require("game.config.Config") -- 5
local Config = ____Config.Config -- 5
local ____RNG = require("game.utils.RNG") -- 6
local rng = ____RNG.rng -- 6
local ____MathUtils = require("game.utils.MathUtils") -- 7
local scale = ____MathUtils.scale -- 7
local ____AudioManager = require("game.audio.AudioManager") -- 8
local audio = ____AudioManager.audio -- 8
local Sfx = ____AudioManager.Sfx -- 8
____exports.DamageSystem = __TS__Class() -- 10
local DamageSystem = ____exports.DamageSystem -- 10
DamageSystem.name = "DamageSystem" -- 10
function DamageSystem.prototype.____constructor(self) -- 10
end -- 10
function DamageSystem.buildInfo(self, base, player, source, dir, kind, critOverride) -- 12
	if kind == nil then -- 12
		kind = "physical" -- 17
	end -- 17
	local ____temp_0 -- 20
	if critOverride ~= nil then -- 20
		____temp_0 = critOverride -- 20
	else -- 20
		____temp_0 = rng:chance(player.critChance) -- 20
	end -- 20
	local crit = ____temp_0 -- 20
	local amount = base * (1 + player.damageBonus) * (crit and player.critMulti or 1) -- 21
	local knockPower = crit and 150 or 90 -- 22
	return { -- 23
		amount = amount, -- 24
		kind = kind, -- 25
		crit = crit, -- 26
		knockback = scale(dir, knockPower), -- 27
		hitStop = crit and Config.hitStopCrit or Config.hitStopNormal, -- 28
		shake = crit and Config.shakeMedium or Config.shakeSmall, -- 29
		flash = true, -- 30
		source = source -- 31
	} -- 31
end -- 12
function DamageSystem.apply(self, enemy, info) -- 36
	if not enemy.isAlive or enemy.markedDead then -- 36
		return -- 37
	end -- 37
	enemy:takeDamage(info) -- 38
	local ____ctx_stats_1, ____damageDealt_2 = ctx.stats, "damageDealt" -- 38
	____ctx_stats_1[____damageDealt_2] = ____ctx_stats_1[____damageDealt_2] + info.amount -- 39
	local player = ctx.player -- 41
	if player ~= nil and player.lifesteal > 0 then -- 41
		local heal = info.amount * player.lifesteal -- 43
		if heal > 0 and player.hp < player.maxHp then -- 43
			player.hp = math.min(player.maxHp, player.hp + heal) -- 45
		end -- 45
	end -- 45
	if ctx.feedback ~= nil then -- 45
		ctx.feedback:spawnDamageText(enemy.pos, info.amount, info.crit) -- 50
		if info.flash then -- 50
			ctx.feedback:spawnFlash(enemy.pos, 16777215) -- 52
		end -- 52
		if info.hitStop > 0 then -- 52
			ctx.feedback:hitStop(info.hitStop) -- 55
		end -- 55
		if info.shake > 0 then -- 55
			ctx.feedback:shake(info.shake) -- 58
		end -- 58
	end -- 58
	if info.source == "melee" then -- 58
		audio:playSfx(Sfx.MeleeImpact, 0.07) -- 63
	end -- 63
	if info.crit then -- 63
		audio:playSfx(Sfx.Critical, 0.09) -- 65
	end -- 65
end -- 36
function ____exports.damageEnemy(enemy, info) -- 70
	____exports.DamageSystem:apply(enemy, info) -- 71
end -- 70
return ____exports -- 70