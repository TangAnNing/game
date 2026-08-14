-- [ts]: SkillDefs.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local ____exports = {} -- 1
local function R(id, name, desc, rarity, maxStack, active, exclusive) -- 6
	if active == nil then -- 6
		active = false -- 6
	end -- 6
	return { -- 6
		id = id, -- 7
		name = name, -- 8
		desc = desc, -- 9
		rarity = rarity, -- 10
		active = active, -- 11
		maxStack = maxStack, -- 12
		exclusive = exclusive -- 13
	} -- 13
end -- 6
____exports.skillDefs = { -- 16
	damagePlus = R( -- 18
		"damagePlus", -- 18
		"力量强化", -- 18
		"伤害提升 15%。", -- 18
		"common", -- 18
		5 -- 18
	), -- 18
	damagePlus2 = R( -- 19
		"damagePlus2", -- 19
		"狂暴之力", -- 19
		"伤害大幅提升 25%。", -- 19
		"rare", -- 19
		3 -- 19
	), -- 19
	attackSpeed = R( -- 20
		"attackSpeed", -- 20
		"疾风攻击", -- 20
		"攻击速度 +12%。", -- 20
		"common", -- 20
		5 -- 20
	), -- 20
	moveSpeed = R( -- 21
		"moveSpeed", -- 21
		"迅捷步伐", -- 21
		"移动速度 +10%。", -- 21
		"common", -- 21
		3 -- 21
	), -- 21
	maxHp = R( -- 22
		"maxHp", -- 22
		"坚韧体魄", -- 22
		"最大生命 +20（同时回复等量生命）。", -- 22
		"common", -- 22
		5 -- 22
	), -- 22
	critChance = R( -- 23
		"critChance", -- 23
		"致命精准", -- 23
		"暴击率 +8%。", -- 23
		"common", -- 23
		5 -- 23
	), -- 23
	critDamage = R( -- 24
		"critDamage", -- 24
		"致命一击", -- 24
		"暴击伤害 +30%。", -- 24
		"rare", -- 24
		4 -- 24
	), -- 24
	pierce = R( -- 25
		"pierce", -- 25
		"贯穿", -- 25
		"弹道穿透 +1，可命中更多敌人。", -- 25
		"rare", -- 25
		3 -- 25
	), -- 25
	split = R( -- 26
		"split", -- 26
		"分裂弹", -- 26
		"弹道命中后分裂 +1 个次级弹。", -- 26
		"epic", -- 26
		2 -- 26
	), -- 26
	projectilePlus = R( -- 27
		"projectilePlus", -- 27
		"多重射击", -- 27
		"弹道数 +1。", -- 27
		"rare", -- 27
		4 -- 27
	), -- 27
	lifesteal = R( -- 28
		"lifesteal", -- 28
		"吸血", -- 28
		"造成伤害的 3% 转化为生命。", -- 28
		"common", -- 28
		5 -- 28
	), -- 28
	pickupRadius = R( -- 29
		"pickupRadius", -- 29
		"拾取扩展", -- 29
		"拾取范围 +30。", -- 29
		"common", -- 29
		3 -- 29
	), -- 29
	regen = R( -- 30
		"regen", -- 30
		"自愈", -- 30
		"每秒回复 1 点生命。", -- 30
		"common", -- 30
		5 -- 30
	), -- 30
	dodge = R( -- 31
		"dodge", -- 31
		"灵巧闪避", -- 31
		"闪避率 +5%。", -- 31
		"rare", -- 31
		3 -- 31
	), -- 31
	bulletSpeed = R( -- 32
		"bulletSpeed", -- 32
		"弹道加速", -- 32
		"弹道速度 +15%。", -- 32
		"common", -- 32
		3 -- 32
	), -- 32
	explosion = R( -- 33
		"explosion", -- 33
		"爆破", -- 33
		"弹道命中时产生小范围爆炸。", -- 33
		"epic", -- 33
		1 -- 33
	), -- 33
	magnet = R( -- 34
		"magnet", -- 34
		"磁力牵引", -- 34
		"经验/拾取磁吸范围 +40。", -- 34
		"common", -- 34
		3 -- 34
	), -- 34
	gold = R( -- 35
		"gold", -- 35
		"贪婪", -- 35
		"金币收益 +20%。", -- 35
		"common", -- 35
		3 -- 35
	), -- 35
	experience = R( -- 36
		"experience", -- 36
		"悟性", -- 36
		"经验收益 +15%。", -- 36
		"common", -- 36
		5 -- 36
	), -- 36
	invincible = R( -- 37
		"invincible", -- 37
		"护体", -- 37
		"受击后获得 1 秒无敌。", -- 37
		"rare", -- 37
		1 -- 37
	), -- 37
	thorns = R( -- 38
		"thorns", -- 38
		"荆棘", -- 38
		"受到伤害时反弹 30% 给攻击者。", -- 38
		"epic", -- 38
		3 -- 38
	), -- 38
	slowAura = R( -- 39
		"slowAura", -- 39
		"霜寒领域", -- 39
		"减速光环：周围敌人移速降低。", -- 39
		"rare", -- 39
		2 -- 39
	), -- 39
	burn = R( -- 40
		"burn", -- 40
		"灼烧", -- 40
		"灼烧光环：周围敌人持续受到火焰伤害。", -- 40
		"rare", -- 40
		3 -- 40
	), -- 40
	poison = R( -- 41
		"poison", -- 41
		"淬毒", -- 41
		"中毒光环：周围敌人持续受到毒性伤害。", -- 41
		"rare", -- 41
		3 -- 41
	), -- 41
	freeze = R( -- 42
		"freeze", -- 42
		"冰冻", -- 42
		"周期性冰冻周围敌人。", -- 42
		"epic", -- 42
		2 -- 42
	), -- 42
	chain = R( -- 43
		"chain", -- 43
		"连锁闪电", -- 43
		"弹道命中时向附近敌人连锁跳跃。", -- 43
		"epic", -- 43
		3 -- 43
	), -- 43
	ricochet = R( -- 44
		"ricochet", -- 44
		"弹射", -- 44
		"弹道命中后弹射 +1 次。", -- 44
		"rare", -- 44
		3 -- 44
	), -- 44
	homing = R( -- 45
		"homing", -- 45
		"追踪", -- 45
		"弹道自动追踪最近的敌人。", -- 45
		"epic", -- 45
		1 -- 45
	), -- 45
	soulEater = R( -- 48
		"soulEater", -- 48
		"亡魂汲取", -- 48
		"死灵专属：吸血效果 +6%。", -- 48
		"epic", -- 48
		3, -- 48
		false, -- 48
		"necromancer" -- 48
	), -- 48
	bloodBlade = R( -- 49
		"bloodBlade", -- 49
		"血刃", -- 49
		"剑士专属：近战吸血 +5%。", -- 49
		"rare", -- 49
		3, -- 49
		false, -- 49
		"swordsman" -- 49
	), -- 49
	comboHit = R( -- 50
		"comboHit", -- 50
		"连击", -- 50
		"剑士专属：攻击速度 +10%。", -- 50
		"rare", -- 50
		3, -- 50
		false, -- 50
		"swordsman" -- 50
	), -- 50
	manaFlow = R( -- 51
		"manaFlow", -- 51
		"法力涌动", -- 51
		"法师专属：技能冷却 -15%。", -- 51
		"rare", -- 51
		3, -- 51
		false, -- 51
		"mage" -- 51
	), -- 51
	arcaneSurge = R( -- 52
		"arcaneSurge", -- 52
		"奥术奔涌", -- 52
		"法师专属：暴击率 +12%。", -- 52
		"rare", -- 52
		3, -- 52
		false, -- 52
		"mage" -- 52
	), -- 52
	doubleCast = R( -- 53
		"doubleCast", -- 53
		"双重施法", -- 53
		"法师专属：弹道有概率额外发射一发。", -- 53
		"epic", -- 53
		3, -- 53
		false, -- 53
		"mage" -- 53
	), -- 53
	natureGrow = R( -- 54
		"natureGrow", -- 54
		"自然生长", -- 54
		"德鲁伊专属：经验收益 +30%。", -- 54
		"rare", -- 54
		3, -- 54
		false, -- 54
		"druid" -- 54
	), -- 54
	summonCount = R( -- 55
		"summonCount", -- 55
		"自然盟友", -- 55
		"德鲁伊专属：召唤物数量 +1。", -- 55
		"epic", -- 55
		3, -- 55
		false, -- 55
		"druid" -- 55
	), -- 55
	summonExplode = R( -- 56
		"summonExplode", -- 56
		"毁灭萌芽", -- 56
		"德鲁伊专属：召唤物攻击引发范围爆裂。", -- 56
		"epic", -- 56
		2, -- 56
		false, -- 56
		"druid" -- 56
	), -- 56
	activeBladeStorm = R( -- 59
		"activeBladeStorm", -- 59
		"剑刃风暴", -- 59
		"主动：对周围敌人造成大量伤害并击退。", -- 59
		"epic", -- 59
		1, -- 59
		true -- 59
	), -- 59
	activeMeteor = R( -- 60
		"activeMeteor", -- 60
		"陨石术", -- 60
		"主动：召唤陨石轰击目标区域。", -- 60
		"epic", -- 60
		1, -- 60
		true -- 60
	), -- 60
	activeHeal = R( -- 61
		"activeHeal", -- 61
		"治疗术", -- 61
		"主动：立即回复 30% 最大生命。", -- 61
		"rare", -- 61
		1, -- 61
		true -- 61
	) -- 61
} -- 61
function ____exports.getSkillDef(id) -- 65
	return ____exports.skillDefs[id] -- 66
end -- 65
function ____exports.poolForCharacter(charId, rng) -- 70
	local pool = {} -- 71
	for ____, id in ipairs(__TS__ObjectKeys(____exports.skillDefs)) do -- 72
		local def = ____exports.skillDefs[id] -- 73
		if def.exclusive == nil or def.exclusive == charId then -- 73
			pool[#pool + 1] = id -- 75
		end -- 75
	end -- 75
	do -- 75
		local i = #pool - 1 -- 79
		while i > 0 do -- 79
			local j = rng:int(0, i) -- 80
			local tmp = pool[i + 1] -- 81
			pool[i + 1] = pool[j + 1] -- 82
			pool[j + 1] = tmp -- 83
			i = i - 1 -- 79
		end -- 79
	end -- 79
	return pool -- 85
end -- 70
return ____exports -- 70