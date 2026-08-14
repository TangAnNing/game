-- [ts]: Characters.ts
local ____exports = {} -- 1
____exports.characters = { -- 4
	swordsman = { -- 6
		id = "swordsman", -- 7
		name = "重剑士", -- 8
		desc = "挥舞巨剑环身横扫，伤害周围全部敌人", -- 9
		color = 13652048, -- 10
		weaponClass = "melee", -- 11
		maxHp = 120, -- 12
		moveSpeed = 230, -- 13
		baseDamage = 16, -- 14
		attackInterval = 0.75, -- 15
		range = 150, -- 16
		projectileCount = 1, -- 17
		pierce = 0, -- 18
		speed = 0, -- 19
		unlockHint = "初始角色" -- 20
	}, -- 20
	mage = { -- 23
		id = "mage", -- 24
		name = "元素法师", -- 25
		desc = "释放多发远程元素弹，射程远", -- 26
		color = 5275856, -- 27
		weaponClass = "ranged", -- 28
		maxHp = 85, -- 29
		moveSpeed = 240, -- 30
		baseDamage = 12, -- 31
		attackInterval = 0.7, -- 32
		range = 260, -- 33
		projectileCount = 3, -- 34
		pierce = 0, -- 35
		speed = 360, -- 36
		unlockHint = "累计击杀 500 解锁" -- 37
	}, -- 37
	druid = { -- 40
		id = "druid", -- 41
		name = "林间德鲁伊", -- 42
		desc = "召唤两只林间精灵自动索敌攻击", -- 43
		color = 5292128, -- 44
		weaponClass = "summon", -- 45
		maxHp = 100, -- 46
		moveSpeed = 250, -- 47
		baseDamage = 11, -- 48
		attackInterval = 0.9, -- 49
		range = 120, -- 50
		projectileCount = 2, -- 51
		pierce = 0, -- 52
		speed = 320, -- 53
		unlockHint = "初始角色" -- 54
	}, -- 54
	gunner = { -- 57
		id = "gunner", -- 58
		name = "枪手", -- 59
		desc = "速射穿透弹，攻速极快", -- 60
		color = 13672528, -- 61
		weaponClass = "ranged", -- 62
		maxHp = 95, -- 63
		moveSpeed = 260, -- 64
		baseDamage = 10, -- 65
		attackInterval = 0.45, -- 66
		range = 220, -- 67
		projectileCount = 1, -- 68
		pierce = 2, -- 69
		speed = 420, -- 70
		unlockHint = "累计拾取 300 金币解锁" -- 71
	}, -- 71
	necromancer = { -- 74
		id = "necromancer", -- 75
		name = "死灵法师", -- 76
		desc = "召唤骷髅军团，攻击吸血", -- 77
		color = 10506448, -- 78
		weaponClass = "summon", -- 79
		maxHp = 80, -- 80
		moveSpeed = 220, -- 81
		baseDamage = 13, -- 82
		attackInterval = 0.8, -- 83
		range = 140, -- 84
		projectileCount = 3, -- 85
		pierce = 0, -- 86
		speed = 300, -- 87
		unlockHint = "无尽模式达到第 20 波解锁" -- 88
	} -- 88
} -- 88
function ____exports.getCharacter(id) -- 92
	return ____exports.characters[id] -- 93
end -- 92
return ____exports -- 92