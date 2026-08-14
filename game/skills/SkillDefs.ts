// 技能定义表：30+ 被动/主动技能（PLAN.md 契约的全部 SkillId）
// 数值描述与 SkillSystem 中的应用逻辑保持一致
import type { CharacterId, SkillDef, SkillId, SkillRarity } from 'game/core/Types';
import type { RNG } from 'game/utils/RNG';

const R = (id: SkillId, name: string, desc: string, rarity: SkillRarity, maxStack: number, active = false, exclusive?: CharacterId): SkillDef => ({
	id,
	name,
	desc,
	rarity,
	active,
	maxStack,
	exclusive,
});

export const skillDefs: Record<SkillId, SkillDef> = {
	// ---------- 通用被动 ----------
	damagePlus: R('damagePlus', '力量强化', '伤害提升 15%。', 'common', 5),
	damagePlus2: R('damagePlus2', '狂暴之力', '伤害大幅提升 25%。', 'rare', 3),
	attackSpeed: R('attackSpeed', '疾风攻击', '攻击速度 +12%。', 'common', 5),
	moveSpeed: R('moveSpeed', '迅捷步伐', '移动速度 +10%。', 'common', 3),
	maxHp: R('maxHp', '坚韧体魄', '最大生命 +20（同时回复等量生命）。', 'common', 5),
	critChance: R('critChance', '致命精准', '暴击率 +8%。', 'common', 5),
	critDamage: R('critDamage', '致命一击', '暴击伤害 +30%。', 'rare', 4),
	pierce: R('pierce', '贯穿', '弹道穿透 +1，可命中更多敌人。', 'rare', 3),
	split: R('split', '分裂弹', '弹道命中后分裂 +1 个次级弹。', 'epic', 2),
	projectilePlus: R('projectilePlus', '多重射击', '弹道数 +1。', 'rare', 4),
	lifesteal: R('lifesteal', '吸血', '造成伤害的 3% 转化为生命。', 'common', 5),
	pickupRadius: R('pickupRadius', '拾取扩展', '拾取范围 +30。', 'common', 3),
	regen: R('regen', '自愈', '每秒回复 1 点生命。', 'common', 5),
	dodge: R('dodge', '灵巧闪避', '闪避率 +5%。', 'rare', 3),
	bulletSpeed: R('bulletSpeed', '弹道加速', '弹道速度 +15%。', 'common', 3),
	explosion: R('explosion', '爆破', '弹道命中时产生小范围爆炸。', 'epic', 1),
	magnet: R('magnet', '磁力牵引', '经验/拾取磁吸范围 +40。', 'common', 3),
	gold: R('gold', '贪婪', '金币收益 +20%。', 'common', 3),
	experience: R('experience', '悟性', '经验收益 +15%。', 'common', 5),
	invincible: R('invincible', '护体', '受击后获得 1 秒无敌。', 'rare', 1),
	thorns: R('thorns', '荆棘', '受到伤害时反弹 30% 给攻击者。', 'epic', 3),
	slowAura: R('slowAura', '霜寒领域', '减速光环：周围敌人移速降低。', 'rare', 2),
	burn: R('burn', '灼烧', '灼烧光环：周围敌人持续受到火焰伤害。', 'rare', 3),
	poison: R('poison', '淬毒', '中毒光环：周围敌人持续受到毒性伤害。', 'rare', 3),
	freeze: R('freeze', '冰冻', '周期性冰冻周围敌人。', 'epic', 2),
	chain: R('chain', '连锁闪电', '弹道命中时向附近敌人连锁跳跃。', 'epic', 3),
	ricochet: R('ricochet', '弹射', '弹道命中后弹射 +1 次。', 'rare', 3),
	homing: R('homing', '追踪', '弹道自动追踪最近的敌人。', 'epic', 1),

	// ---------- 职业专属被动 ----------
	soulEater: R('soulEater', '亡魂汲取', '死灵专属：吸血效果 +6%。', 'epic', 3, false, 'necromancer'),
	bloodBlade: R('bloodBlade', '血刃', '剑士专属：近战吸血 +5%。', 'rare', 3, false, 'swordsman'),
	comboHit: R('comboHit', '连击', '剑士专属：攻击速度 +10%。', 'rare', 3, false, 'swordsman'),
	manaFlow: R('manaFlow', '法力涌动', '法师专属：技能冷却 -15%。', 'rare', 3, false, 'mage'),
	arcaneSurge: R('arcaneSurge', '奥术奔涌', '法师专属：暴击率 +12%。', 'rare', 3, false, 'mage'),
	doubleCast: R('doubleCast', '双重施法', '法师专属：弹道有概率额外发射一发。', 'epic', 3, false, 'mage'),
	natureGrow: R('natureGrow', '自然生长', '德鲁伊专属：经验收益 +30%。', 'rare', 3, false, 'druid'),
	summonCount: R('summonCount', '自然盟友', '德鲁伊专属：召唤物数量 +1。', 'epic', 3, false, 'druid'),
	summonExplode: R('summonExplode', '毁灭萌芽', '德鲁伊专属：召唤物攻击引发范围爆裂。', 'epic', 2, false, 'druid'),

	// ---------- 主动技能 ----------
	activeBladeStorm: R('activeBladeStorm', '剑刃风暴', '主动：对周围敌人造成大量伤害并击退。', 'epic', 1, true),
	activeMeteor: R('activeMeteor', '陨石术', '主动：召唤陨石轰击目标区域。', 'epic', 1, true),
	activeHeal: R('activeHeal', '治疗术', '主动：立即回复 30% 最大生命。', 'rare', 1, true),
};

// 按 ID 取技能定义
export function getSkillDef(id: SkillId): SkillDef {
	return skillDefs[id];
}

// 角色技能候选池：通用（含主动）+ 该角色专属（洗牌后返回，供升级三选一抽取）
export function poolForCharacter(charId: CharacterId, rng: RNG): SkillId[] {
	const pool: SkillId[] = [];
	for (const id of Object.keys(skillDefs) as SkillId[]) {
		const def = skillDefs[id];
		if (def.exclusive === undefined || def.exclusive === charId) {
			pool.push(id);
		}
	}
	// Fisher-Yates 洗牌（使用注入的 RNG，避免全局随机源被多处消费）
	for (let i = pool.length - 1; i > 0; i--) {
		const j = rng.int(0, i);
		const tmp = pool[i];
		pool[i] = pool[j];
		pool[j] = tmp;
	}
	return pool;
}
