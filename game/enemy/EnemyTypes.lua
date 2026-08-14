-- [ts]: EnemyTypes.ts
local ____exports = {} -- 1
____exports.enemyDefs = { -- 4
	walker = { -- 5
		kind = "walker", -- 6
		name = "魔影行者", -- 7
		radius = 14, -- 8
		maxHp = 30, -- 9
		moveSpeed = 70, -- 10
		damage = 8, -- 11
		exp = 2, -- 12
		color = 4177759, -- 13
		isElite = false, -- 14
		isBoss = false, -- 15
		ai = "chase" -- 16
	}, -- 16
	runner = { -- 18
		kind = "runner", -- 19
		name = "疾风斥候", -- 20
		radius = 11, -- 21
		maxHp = 20, -- 22
		moveSpeed = 140, -- 23
		damage = 6, -- 24
		exp = 2, -- 25
		color = 12116815, -- 26
		isElite = false, -- 27
		isBoss = false, -- 28
		ai = "chase" -- 29
	}, -- 29
	tank = { -- 31
		kind = "tank", -- 32
		name = "重甲卫士", -- 33
		radius = 22, -- 34
		maxHp = 90, -- 35
		moveSpeed = 40, -- 36
		damage = 15, -- 37
		exp = 5, -- 38
		color = 2068303, -- 39
		isElite = false, -- 40
		isBoss = false, -- 41
		ai = "chase" -- 42
	}, -- 42
	ranger = { -- 44
		kind = "ranger", -- 45
		name = "蚀骨射手", -- 46
		radius = 13, -- 47
		maxHp = 28, -- 48
		moveSpeed = 80, -- 49
		damage = 10, -- 50
		exp = 4, -- 51
		color = 4181951, -- 52
		isElite = false, -- 53
		isBoss = false, -- 54
		ai = "chaseShoot", -- 55
		shootInterval = 2.2, -- 56
		shootSpeed = 220 -- 57
	}, -- 57
	charger = { -- 59
		kind = "charger", -- 60
		name = "狂怒冲锋者", -- 61
		radius = 15, -- 62
		maxHp = 45, -- 63
		moveSpeed = 90, -- 64
		damage = 14, -- 65
		exp = 4, -- 66
		color = 16752447, -- 67
		isElite = false, -- 68
		isBoss = false, -- 69
		ai = "charge", -- 70
		chargeCooldown = 2.6, -- 71
		chargeSpeed = 340 -- 72
	}, -- 72
	shield = { -- 74
		kind = "shield", -- 75
		name = "壁垒守卫", -- 76
		radius = 16, -- 77
		maxHp = 60, -- 78
		moveSpeed = 55, -- 79
		damage = 10, -- 80
		exp = 5, -- 81
		color = 8363983, -- 82
		isElite = false, -- 83
		isBoss = false, -- 84
		ai = "shield", -- 85
		shieldRadius = 0.9 -- 86
	}, -- 86
	exploder = { -- 88
		kind = "exploder", -- 89
		name = "爆裂魔种", -- 90
		radius = 13, -- 91
		maxHp = 25, -- 92
		moveSpeed = 110, -- 93
		damage = 25, -- 94
		exp = 4, -- 95
		color = 16736063, -- 96
		isElite = false, -- 97
		isBoss = false, -- 98
		ai = "suicide" -- 99
	}, -- 99
	elite = { -- 101
		kind = "elite", -- 102
		name = "精英·血瞳统领", -- 103
		radius = 20, -- 104
		maxHp = 300, -- 105
		moveSpeed = 75, -- 106
		damage = 18, -- 107
		exp = 30, -- 108
		color = 12541951, -- 109
		isElite = true, -- 110
		isBoss = false, -- 111
		ai = "chase", -- 112
		shootInterval = 3.2, -- 113
		shootSpeed = 260 -- 114
	}, -- 114
	boss = { -- 116
		kind = "boss", -- 117
		name = "深渊领主", -- 118
		radius = 34, -- 119
		maxHp = 1500, -- 120
		moveSpeed = 55, -- 121
		damage = 25, -- 122
		exp = 200, -- 123
		color = 13578047, -- 124
		isElite = false, -- 125
		isBoss = true, -- 126
		ai = "boss", -- 127
		shootInterval = 2.5, -- 128
		shootSpeed = 200 -- 129
	} -- 129
} -- 129
function ____exports.getEnemyDef(kind) -- 134
	local def = ____exports.enemyDefs[kind] -- 135
	if def == nil then -- 135
		return ____exports.enemyDefs.walker -- 136
	end -- 136
	return def -- 137
end -- 134
____exports.eliteKinds = { -- 141
	"walker", -- 141
	"runner", -- 141
	"tank", -- 141
	"ranger", -- 141
	"charger", -- 141
	"shield", -- 141
	"exploder" -- 141
} -- 141
return ____exports -- 141