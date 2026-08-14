// 5 角色定义表：数值/颜色/武器类型
import { CharacterDef, CharacterId } from 'game/core/Types';

export const characters: Record<CharacterId, CharacterDef> = {
	// 重剑士：环身重击，高血量高攻击，攻速偏慢
	swordsman: {
		id: 'swordsman',
		name: '重剑士',
		desc: '挥舞巨剑环身横扫，伤害周围全部敌人',
		color: 0xd05050,
		weaponClass: 'melee',
		maxHp: 120,
		moveSpeed: 230,
		baseDamage: 16,
		attackInterval: 0.75,
		range: 150,
		projectileCount: 1,
		pierce: 0,
		speed: 0,
		unlockHint: '初始角色',
	},
	// 元素法师：远程弹道，多发多射程
	mage: {
		id: 'mage',
		name: '元素法师',
		desc: '释放多发远程元素弹，射程远',
		color: 0x5080d0,
		weaponClass: 'ranged',
		maxHp: 85,
		moveSpeed: 240,
		baseDamage: 12,
		attackInterval: 0.7,
		range: 260,
		projectileCount: 3,
		pierce: 0,
		speed: 360,
		unlockHint: '累计击杀 500 解锁',
	},
	// 林间德鲁伊：召唤物助战
	druid: {
		id: 'druid',
		name: '林间德鲁伊',
		desc: '召唤两只林间精灵自动索敌攻击',
		color: 0x50c060,
		weaponClass: 'summon',
		maxHp: 100,
		moveSpeed: 250,
		baseDamage: 11,
		attackInterval: 0.9,
		range: 120,
		projectileCount: 2,
		pierce: 0,
		speed: 320,
		unlockHint: '初始角色',
	},
	// 枪手：攻速快、穿透
	gunner: {
		id: 'gunner',
		name: '枪手',
		desc: '速射穿透弹，攻速极快',
		color: 0xd0a050,
		weaponClass: 'ranged',
		maxHp: 95,
		moveSpeed: 260,
		baseDamage: 10,
		attackInterval: 0.45,
		range: 220,
		projectileCount: 1,
		pierce: 2,
		speed: 420,
		unlockHint: '累计拾取 300 金币解锁',
	},
	// 死灵法师：召唤骷髅 + 吸血
	necromancer: {
		id: 'necromancer',
		name: '死灵法师',
		desc: '召唤骷髅军团，攻击吸血',
		color: 0xa050d0,
		weaponClass: 'summon',
		maxHp: 80,
		moveSpeed: 220,
		baseDamage: 13,
		attackInterval: 0.8,
		range: 140,
		projectileCount: 3,
		pierce: 0,
		speed: 300,
		unlockHint: '无尽模式达到第 20 波解锁',
	},
};

export function getCharacter(id: CharacterId): CharacterDef {
	return characters[id];
}
