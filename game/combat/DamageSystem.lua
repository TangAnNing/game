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
____exports.DamageSystem = __TS__Class() -- 9
local DamageSystem = ____exports.DamageSystem -- 9
DamageSystem.name = "DamageSystem" -- 9
function DamageSystem.prototype.____constructor(self) -- 9
end -- 9
function DamageSystem.buildInfo(self, base, player, source, dir, kind, critOverride) -- 11
	if kind == nil then -- 11
		kind = "physical" -- 16
	end -- 16
	local ____temp_0 -- 19
	if critOverride ~= nil then -- 19
		____temp_0 = critOverride -- 19
	else -- 19
		____temp_0 = rng:chance(player.critChance) -- 19
	end -- 19
	local crit = ____temp_0 -- 19
	local amount = base * (1 + player.damageBonus) * (crit and player.critMulti or 1) -- 20
	local knockPower = crit and 150 or 90 -- 21
	return { -- 22
		amount = amount, -- 23
		kind = kind, -- 24
		crit = crit, -- 25
		knockback = scale(dir, knockPower), -- 26
		hitStop = crit and Config.hitStopCrit or Config.hitStopNormal, -- 27
		shake = crit and Config.shakeMedium or Config.shakeSmall, -- 28
		flash = true, -- 29
		source = source -- 30
	} -- 30
end -- 11
function DamageSystem.apply(self, enemy, info) -- 35
	if not enemy.isAlive or enemy.markedDead then -- 35
		return -- 36
	end -- 36
	enemy:takeDamage(info) -- 37
	local ____ctx_stats_1, ____damageDealt_2 = ctx.stats, "damageDealt" -- 37
	____ctx_stats_1[____damageDealt_2] = ____ctx_stats_1[____damageDealt_2] + info.amount -- 38
	local player = ctx.player -- 40
	if player ~= nil and player.lifesteal > 0 then -- 40
		local heal = info.amount * player.lifesteal -- 42
		if heal > 0 and player.hp < player.maxHp then -- 42
			player.hp = math.min(player.maxHp, player.hp + heal) -- 44
		end -- 44
	end -- 44
	if ctx.feedback ~= nil then -- 44
		ctx.feedback:spawnDamageText(enemy.pos, info.amount, info.crit) -- 49
		if info.flash then -- 49
			ctx.feedback:spawnFlash(enemy.pos, 16777215) -- 51
		end -- 51
		if info.hitStop > 0 then -- 51
			ctx.feedback:hitStop(info.hitStop) -- 54
		end -- 54
		if info.shake > 0 then -- 54
			ctx.feedback:shake(info.shake) -- 57
		end -- 57
	end -- 57
end -- 35
function ____exports.damageEnemy(enemy, info) -- 64
	____exports.DamageSystem:apply(enemy, info) -- 65
end -- 64
return ____exports -- 64