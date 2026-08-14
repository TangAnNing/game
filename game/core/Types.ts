// 核心类型契约：所有跨域共享的纯类型/枚举
import { Vec2 } from 'Dora';
// ---------- 伤害 ----------
export type DamageKind = 'physical' | 'magic' | 'true' | 'poison';
export type DamageSource = 'melee' | 'bullet' | 'summon' | 'skill' | 'explosion' | 'dot' | 'environment';

export interface DamageInfo {
	amount: number;
	kind: DamageKind;
	crit: boolean;
	// 击退：方向单位向量 * 力度
	knockback: Vec2.Type;
	// 触发 HitStop 时长（秒），0 表示不触发
	hitStop: number;
	// 屏幕震动强度（像素），0 表示不震
	shake: number;
	// 是否闪白
	flash: boolean;
	source: DamageSource;
}

// ---------- 角色 ----------
export type CharacterId = 'swordsman' | 'mage' | 'druid' | 'gunner' | 'necromancer';
export type WeaponClass = 'melee' | 'ranged' | 'summon';

export interface CharacterDef {
	id: CharacterId;
	name: string;
	desc: string;
	color: number; // 0xRRGGBB
	weaponClass: WeaponClass;
	// 基础属性
	maxHp: number;
	moveSpeed: number;
	baseDamage: number;
	attackInterval: number;
	// 武器基础参数
	range: number;       // 近战半径/弹道射程
	projectileCount: number; // 远程弹道数 / 召唤职业的基础召唤物数量
	pierce: number;
	speed: number;
	unlockHint: string;
}

// ---------- 怪物 ----------
export type EnemyKind = 'walker' | 'runner' | 'tank' | 'ranger' | 'charger' | 'shield' | 'exploder' | 'elite' | 'boss';

// 敌人对外可见接口（战斗域只读此接口，敌人域实现）
export interface EnemyView {
	readonly id: number;
	readonly pos: Vec2.Type;
	readonly radius: number;
	readonly kind: EnemyKind;
	readonly isElite: boolean;
	readonly isBoss: boolean;
	readonly isAlive: boolean;
	readonly hp: number;
	readonly maxHp: number;
	// 受到伤害（敌人域实现，含闪白/击退处理）
	takeDamage(info: DamageInfo): void;
	// 是否已被伤害系统处理（避免重复结算）
	markedDead: boolean;
}


export interface EnemyDef {
	kind: EnemyKind;
	name: string;
	radius: number;
	maxHp: number;
	moveSpeed: number;
	damage: number;
	exp: number;
	color: number; // 0xRRGGBB
	isElite: boolean;
	isBoss: boolean;
	// AI 配置
	ai: 'chase' | 'chaseShoot' | 'charge' | 'shield' | 'suicide' | 'boss';
	shootInterval?: number;
	shootSpeed?: number;
	shieldRadius?: number;
	chargeCooldown?: number;
	chargeSpeed?: number;
}

// ---------- 拾取物 ----------
export type PickupKind = 'exp' | 'chest' | 'heal' | 'crate' | 'barrel';

// ---------- 技能 ----------
export type SkillId =
	// 通用
	| 'damagePlus' | 'damagePlus2' | 'attackSpeed' | 'moveSpeed'
	| 'maxHp' | 'critChance' | 'critDamage' | 'pierce'
	| 'split' | 'projectilePlus' | 'lifesteal' | 'pickupRadius'
	| 'regen' | 'dodge' | 'bulletSpeed' | 'explosion'
	| 'magnet' | 'gold' | 'experience' | 'invincible'
	| 'thorns' | 'slowAura' | 'burn' | 'poison'
	| 'freeze' | 'chain' | 'ricochet' | 'homing'
	// 职业专属
	| 'soulEater' | 'bloodBlade' | 'comboHit'
	| 'manaFlow' | 'arcaneSurge' | 'doubleCast'
	| 'natureGrow' | 'summonCount' | 'summonExplode'
	// 主动
	| 'activeBladeStorm' | 'activeMeteor' | 'activeHeal';

export type SkillRarity = 'common' | 'rare' | 'epic';

export interface SkillDef {
	id: SkillId;
	name: string;
	desc: string;
	rarity: SkillRarity;
	// 应用类型：被动（属性修改）或主动（施放）
	active: boolean;
	// 叠加层数
	maxStack: number;
	// 专属角色限制（undefined 表示通用）
	exclusive?: CharacterId;
}

// ---------- 波次 ----------
export interface WaveDef {
	index: number;
	// 每类怪物的生成数
	spawns: { kind: EnemyKind; count: number; delay: number }[];
	// 波次持续时间内持续刷怪的总数
	streamCount: number;
	streamInterval: number;
	bossKind?: EnemyKind;
}

// ---------- 存档 ----------
export interface SaveData {
	version: number;
	// 局外金币
	gold: number;
	// 已解锁角色
	unlockedCharacters: CharacterId[];
	// 永久属性加成
	permanent: {
		damage: number;
		maxHp: number;
		moveSpeed: number;
	};
	// 最高无尽波次
	bestWave: number;
	// 总击杀
	totalKills: number;
	// 设置项（可选，兼容旧档；外壳域读写）
	settings?: {
		quality: number;
		sfxVolume: number;
		musicVolume: number;
		muted: boolean;
	};
	// 对局累计统计（可选，兼容旧档；外壳域读写）
	stats?: {
		totalGames: number;
		totalTime: number;
		maxKills: number;
	};
}

// ---------- 游戏流程 ----------
export type GamePhase = 'menu' | 'playing' | 'levelup' | 'paused' | 'gameover' | 'victory';

// 游戏模式：章节/无尽/挑战/每日
export type GameMode = 'chapter' | 'endless' | 'challenge' | 'daily';
