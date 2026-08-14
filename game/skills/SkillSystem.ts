// 技能系统：被动叠加生效 + 主动施放 + 光环/DoT 状态效果
// 契约：直接修改 PlayerView 属性（含技能扩展属性）；玩家域未提供的职业专属扩展经 SkillMods 桥接
import { Vec2 } from 'Dora';
import type { DamageInfo, EnemyView, SkillId } from 'game/core/Types';
import type { GameContext, PlayerView } from 'game/core/GameContext';
import { getSkillDef } from 'game/skills/SkillDefs';
import { DamageSystem } from 'game/combat/DamageSystem';

// 玩家域尚未在 PlayerView 中提供的扩展属性（玩家/武器/召唤域可按需读取）
export interface SkillMods {
	invincibleOnHit: boolean; // 受击后 1s 无敌（玩家域实现受伤逻辑时读取）
	// 职业专属
	soulEater: number; // 死灵吸血+
	bloodBlade: number; // 剑士吸血
	combo: number; // 剑士连击
	manaFlow: number; // 法师冷却-
	arcaneSurge: number; // 法师暴击+
	doubleCast: number; // 法师双重施法概率
	summonCount: number; // 召唤数+
	summonExplode: number; // 召唤自爆等级
}

// 敌人对外状态接口：EnemyView 未定义减速/冰冻，敌人域提供时才会生效
interface StatusEnemy extends EnemyView {
	slowdown?(factor: number, duration: number): void;
	freeze?(duration: number): void;
}

// 主动技能冷却（秒）
const ACTIVE_COOLDOWN: Record<string, number> = {
	activeBladeStorm: 8,
	activeMeteor: 10,
	activeHeal: 12,
};

export class SkillSystem {
	private player: PlayerView;
	private game: GameContext;
	private learnedSkills: SkillId[] = [];
	private levels = new Map<SkillId, number>();
	private cooldowns = new Map<SkillId, number>();
	private mods: SkillMods = {
		invincibleOnHit: false,
		soulEater: 0,
		bloodBlade: 0,
		combo: 0,
		manaFlow: 0,
		arcaneSurge: 0,
		doubleCast: 0,
		summonCount: 0,
		summonExplode: 0,
	};
	// 光环/DoT 计时器
	private slowTimer = 0;
	private burnTimer = 0;
	private poisonTimer = 0;
	private freezeTimer = 0;

	constructor(player: PlayerView, game: GameContext) {
		this.player = player;
		this.game = game;
	}

	// 已学技能列表（按学习顺序）
	get learned(): SkillId[] {
		return this.learnedSkills.slice();
	}

	// 某技能当前层数
	getLevel(id: SkillId): number {
		return this.levels.get(id) ?? 0;
	}

	// 聚合后的扩展属性（供武器/玩家域读取）
	getMods(): SkillMods {
		return { ...this.mods };
	}

	// 主动技能是否就绪（已学习且不在冷却）
	isReady(id: SkillId): boolean {
		if (this.getLevel(id) <= 0) return false;
		return (this.cooldowns.get(id) ?? 0) <= 0;
	}

	// 应用技能：叠加层数（达到 maxStack 后不再叠加）
	applySkill(id: SkillId): void {
		const def = getSkillDef(id);
		const level = this.getLevel(id);
		if (level >= def.maxStack) return;

		this.levels.set(id, level + 1);
		if (level === 0) this.learnedSkills.push(id);

		const p = this.player;
		p.skillStacks[id] = (p.skillStacks[id] ?? 0) + 1;
		const m = this.mods;
		switch (id) {
			case 'damagePlus': p.damageBonus += 0.15; break;
			case 'damagePlus2': p.damageBonus += 0.25; break;
			case 'attackSpeed': p.attackSpeed *= 1.12; break;
			case 'moveSpeed': p.moveSpeed *= 1.10; break;
			case 'maxHp':
				p.maxHp += 20;
				p.hp += 20;
				break;
			case 'critChance': p.critChance += 0.08; break;
			case 'critDamage': p.critMulti += 0.30; break;
			case 'pierce': p.pierce += 1; break;
			case 'split': p.split += 1; break;
			case 'projectilePlus': p.projectileCount += 1; break;
			case 'lifesteal': p.lifesteal += 0.03; break;
			case 'pickupRadius': p.pickupRadius += 30; break;
			case 'regen': p.regen += 1; break;
			case 'magnet': p.magnet += 40; break;
			// 以下直接写 PlayerView 技能扩展属性（玩家域已定义）
			case 'dodge': p.dodge += 0.05; break;
			case 'bulletSpeed': p.bulletSpeedMulti += 0.15; break;
			case 'gold': p.goldMulti += 0.20; break;
			case 'experience': p.expMulti += 0.15; break;
			case 'thorns': p.thorns += 0.30; break;
			case 'chain': p.chain += 1; break;
			case 'ricochet': p.ricochet += 1; break;
			case 'explosion': p.explosion += 1; break;
			case 'slowAura': p.slowAura += 1; break;
			case 'burn': p.burn += 1; break;
			case 'poison': p.poison += 1; break;
			case 'freeze': p.freeze += 1; break;
			case 'homing': p.homing += 1; break;
			case 'natureGrow': p.expMulti += 0.30; break;
			// 玩家域未提供的属性经 SkillMods 桥接（未实现时静默失效）
			case 'invincible': m.invincibleOnHit = true; break;
			case 'soulEater': p.lifesteal += 0.06; m.soulEater += 0.06; break;
			case 'bloodBlade': p.lifesteal += 0.05; m.bloodBlade += 0.05; break;
			case 'comboHit': p.attackSpeed *= 1.10; m.combo += 1; break;
			case 'manaFlow': m.manaFlow += 0.15; break;
			case 'arcaneSurge': p.critChance += 0.12; m.arcaneSurge += 0.12; break;
			case 'doubleCast': m.doubleCast += 0.20; break;
			case 'summonCount': m.summonCount += 1; break;
			case 'summonExplode': m.summonExplode += 1; break;
			// 主动技能：无被动属性，仅登记学习
			case 'activeBladeStorm':
			case 'activeMeteor':
			case 'activeHeal':
				break;
		}
	}

	// 施放主动技能
	castActive(id: SkillId): void {
		if (this.getLevel(id) <= 0) return;
		if ((this.cooldowns.get(id) ?? 0) > 0) return;
		this.cooldowns.set(id, ACTIVE_COOLDOWN[id] ?? 6);

		const p = this.player;
		const base = 1 + p.damageBonus;
		switch (id) {
			case 'activeBladeStorm': {
				const radius = 140;
				const info: DamageInfo = {
					amount: Math.round(45 * base),
					kind: 'physical',
					crit: false,
					knockback: Vec2.zero,
					hitStop: 0.08,
					shake: 8,
					flash: true,
					source: 'skill',
				};
				this.game.damageEnemiesInRadius?.(p.pos, radius, info);
				this.game.vfx?.ring(p.pos, 0xFFE8A33D, radius);
				this.game.vfx?.burst(p.pos, 0xFFF5C26B, 18, 220);
				break;
			}
			case 'activeMeteor': {
				// 落点：最近的敌人，否则玩家前方 180
				let target = p.pos;
				const found = this.game.findEnemiesNear?.(p.pos, 9999, 1) ?? [];
				if (found.length > 0) {
					const first = found[0] as EnemyView | undefined;
					if (first !== undefined && first.isAlive) target = first.pos;
				} else {
					target = Vec2(p.pos.x + 180, p.pos.y);
				}
				const radius = 110;
				const info: DamageInfo = {
					amount: Math.round(60 * base),
					kind: 'magic',
					crit: false,
					knockback: Vec2.zero,
					hitStop: 0.1,
					shake: 10,
					flash: true,
					source: 'skill',
				};
				this.game.damageEnemiesInRadius?.(target, radius, info);
				this.game.vfx?.burst(target, 0xFFFF9F43, 26, 320);
				this.game.vfx?.flash(target, 0xFFFFD28A, radius);
				this.game.vfx?.ring(target, 0xFFFF9F43, radius);
				break;
			}
			case 'activeHeal': {
				const amount = p.maxHp * 0.3;
				p.hp = Math.min(p.maxHp, p.hp + amount);
				this.game.vfx?.burst(p.pos, 0xFF58E37E, 12, 120);
				break;
			}
		}
	}

	// 每帧更新：冷却、回血、光环/DoT
	update(dt: number): void {
		// 冷却递减
		this.cooldowns.forEach((value, key, map) => {
			if (value > 0) map.set(key, value - dt * (1 + this.mods.manaFlow));
		});

		const p = this.player;
		if (!p.isAlive) return;
		// 主动技能自动施放：技能拥有明确的战场效果，不依赖尚未接入的额外按键
		for (let i = 0; i < this.learnedSkills.length; i++) {
			const id = this.learnedSkills[i];
			if (id === 'activeHeal' && p.hp / p.maxHp <= 0.55) this.castActive(id);
			if (id === 'activeBladeStorm' || id === 'activeMeteor') this.castActive(id);
		}

		// 减速光环（等级存于 PlayerView 扩展属性）
		const slowLevel = p.slowAura;
		if (slowLevel > 0) {
			this.slowTimer -= dt;
			if (this.slowTimer <= 0) {
				this.slowTimer = 0.3;
				this.applyStatus(p.pos, 110, 24, (enemy) => {
					if (enemy.slowdown !== undefined) enemy.slowdown(0.5, 0.5);
				});
			}
		}
		// 灼烧 DoT
		const burnLevel = p.burn;
		if (burnLevel > 0) {
			this.burnTimer -= dt;
			if (this.burnTimer <= 0) {
				this.burnTimer = 0.5;
				this.applyStatus(p.pos, 140, 24, (enemy) => {
					DamageSystem.apply(enemy, this.dotInfo(2 * burnLevel, 'magic'));
				});
			}
		}
		// 中毒 DoT
		const poisonLevel = p.poison;
		if (poisonLevel > 0) {
			this.poisonTimer -= dt;
			if (this.poisonTimer <= 0) {
				this.poisonTimer = 0.8;
				this.applyStatus(p.pos, 140, 24, (enemy) => {
					DamageSystem.apply(enemy, this.dotInfo(3 * poisonLevel, 'poison'));
				});
			}
		}
		// 冰冻控制
		const freezeLevel = p.freeze;
		if (freezeLevel > 0) {
			this.freezeTimer -= dt;
			if (this.freezeTimer <= 0) {
				this.freezeTimer = 2.5;
				this.applyStatus(p.pos, 130, 24, (enemy) => {
					if (enemy.freeze !== undefined) enemy.freeze(1.2);
				});
			}
		}
	}

	// 构造 DoT 伤害信息
	private dotInfo(amount: number, kind: 'magic' | 'poison'): DamageInfo {
		return {
			amount,
			kind,
			crit: false,
			knockback: Vec2.zero,
			hitStop: 0,
			shake: 0,
			flash: false,
			source: 'dot',
		};
	}

	// 对玩家周围敌人施加状态回调（只处理存活敌人）
	private applyStatus(pos: Vec2.Type, radius: number, limit: number, fn: (enemy: StatusEnemy) => void): void {
		const found = this.game.findEnemiesNear?.(pos, radius, limit);
		if (found === undefined) return;
		for (let i = 0; i < found.length; i++) {
			const enemy = found[i] as StatusEnemy | undefined;
			if (enemy !== undefined && enemy.isAlive) fn(enemy);
		}
	}

	// 重置（新对局时调用）
	reset(): void {
		this.learnedSkills.length = 0;
		this.levels.clear();
		this.cooldowns.clear();
		this.slowTimer = 0;
		this.burnTimer = 0;
		this.poisonTimer = 0;
		this.freezeTimer = 0;
		this.mods = {
			invincibleOnHit: false,
			soulEater: 0,
			bloodBlade: 0,
			combo: 0,
			manaFlow: 0,
			arcaneSurge: 0,
			doubleCast: 0,
			summonCount: 0,
			summonExplode: 0,
		};
	}
}
