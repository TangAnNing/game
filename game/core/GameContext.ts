// 中央单例 GameContext：跨域回调注册 + 共享战斗状态
// 各域在启动时注册回调，避免循环 import
import { Vec2 } from 'Dora';
import { DamageInfo, PickupKind, EnemyKind, GamePhase, CharacterDef } from 'game/core/Types';
import type { GameMode } from 'game/core/Types';

// 战斗统计（供 HUD/Debug 使用）
export interface CombatStats {
	kills: number;
	eliteKills: number;
	bossKills: number;
	damageDealt: number;
	damageTaken: number;
	wave: number;
	timeAlive: number;
	playerLevel: number;
}

// 玩家可读接口（Player 实现，跨域读取属性用）
export interface PlayerView {
	readonly pos: Vec2.Type;
	hp: number;
	maxHp: number;
	level: number;
	exp: number;
	expNeed: number;
	moveSpeed: number;
	attackSpeed: number;
	critChance: number;
	critMulti: number;
	damageBonus: number;
	projectileCount: number;
	pierce: number;
	split: number;
	lifesteal: number;
	pickupRadius: number;
	invincible: boolean;
	invincibleTimer: number;
	regen: number;
	magnet: number;
	// 技能扩展属性（SkillSystem 直接修改）
	dodge: number;
	bulletSpeedMulti: number;
	expMulti: number;
	goldMulti: number;
	thorns: number;
	// 状态效果开关（链式/追踪/弹射/爆炸/减速光环/灼烧/中毒/冰冻）
	chain: number;
	homing: number;
	ricochet: number;
	explosion: number;
	slowAura: number;
	burn: number;
	poison: number;
	freeze: number;
	skillStacks: Record<string, number>;
	isAlive: boolean;
}

export class GameContext {
	// ---- 玩家 ----
	player?: PlayerView;
	character: CharacterDef | undefined = undefined;

	// ---- 战斗统计 ----
	stats: CombatStats = {
		kills: 0,
		eliteKills: 0,
		bossKills: 0,
		damageDealt: 0,
		damageTaken: 0,
		wave: 0,
		timeAlive: 0,
		playerLevel: 0,
	};

	// ---- 游戏阶段 ----
	phase: GamePhase = 'menu';
	mode: GameMode = 'chapter';

	// ---- 跨域回调（由各域注册）----
	onDamageEnemy?: (enemy: unknown, info: DamageInfo) => void;
	onEnemyDied?: (enemy: unknown, exp: number, pos: Vec2.Type, kind: EnemyKind) => void;
	onSpawnPickup?: (kind: PickupKind, pos: Vec2.Type, value?: number) => void;
	onAddExp?: (amount: number, pos: Vec2.Type) => void;
	onPlayerLevelUp?: () => void;
	onPlayerDamaged?: (amount: number, from: Vec2.Type) => void;
	onGameOver?: () => void;
	onVictory?: () => void;
	onPauseToggle?: () => void;

	// ---- 战斗辅助（由各域注册）----
	// 对玩家最近敌人排序（供武器索敌），返回目标数组
	findEnemiesNear?: (pos: Vec2.Type, radius: number, limit: number) => unknown[];
	// 对敌人施加群体效果（AOE 技能）
	damageEnemiesInRadius?: (pos: Vec2.Type, radius: number, info: DamageInfo) => number;
	// 拾取物吸取（技能/磁铁）
	magnetPickups?: (pos: Vec2.Type, radius: number) => void;
	damageBreakablesInRadius?: (pos: Vec2.Type, radius: number, damage: number) => number;

	// ---- 领域服务（由各域注册）----
	feedback?: {
		spawnDamageText: (pos: Vec2.Type, amount: number, crit: boolean) => void;
		spawnFlash: (pos: Vec2.Type, color: number) => void;
		shake: (strength: number) => void;
		hitStop: (duration: number) => void;
	};
	vfx?: {
		burst: (pos: Vec2.Type, color: number, count: number, speed: number) => void;
		ring: (pos: Vec2.Type, color: number, radius: number) => void;
		flash: (pos: Vec2.Type, color: number, radius: number) => void;
		slash: (pos: Vec2.Type, angle: number, color: number, radius: number) => void;
	};
}

// 单例导出：各域直接 import { ctx } from 'game/core/GameContext'
export const ctx = new GameContext();
