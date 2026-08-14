// 怪物实体：DrawNode 视觉、受击闪白/击退、对象池复用
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { DamageInfo, EnemyDef, EnemyKind, EnemyView } from 'game/core/Types';
import { ctx } from 'game/core/GameContext';
import { Config } from 'game/config/Config';
import { ObjectPool } from 'game/utils/ObjectPool';
import { updateEnemyAI } from 'game/enemy/EnemyAI';
import { getEnemyDef } from 'game/enemy/EnemyTypes';

const SEGMENTS = 14;

function circleVerts(radius: number): Vec2.Type[] {
	const verts: Vec2.Type[] = [];
	for (let i = 0; i < SEGMENTS; i++) {
		const a = (i / SEGMENTS) * Math.PI * 2;
		verts.push(Vec2(Math.cos(a) * radius, Math.sin(a) * radius));
	}
	return verts;
}

// 0xRRGGBB 拆色（Lua 5.3 无带符号右移，用除法+取模）
function splitColor(color: number): { r: number; g: number; b: number } {
	return {
		r: Math.floor(color / 65536) % 256,
		g: Math.floor(color / 256) % 256,
		b: color % 256,
	};
}

function colorOf(color: number, alpha = 255): Color.Type {
	const c = splitColor(color);
	return Color(c.r, c.g, c.b, alpha);
}

let nextEnemyId = 1;

// 敌人子弹发射器（EnemyBulletManager 满足该结构，避免 Enemy↔EnemyAI 循环 import）
export interface BulletLauncher {
	spawn(pos: Vec2.Type, vel: Vec2.Type, damage: number, radius?: number): void;
}

export class Enemy implements EnemyView {
	readonly id: number;
	pos: Vec2.Type;
	radius: number;
	kind: EnemyKind;
	isElite: boolean;
	isBoss: boolean;
	isAlive = false;
	hp = 0;
	maxHp: number;
	markedDead = false;
	def: EnemyDef;
	color: number;

	// 移动/受击状态
	velocity = Vec2.zero;
	facing = 0;
	slowMult = 1;
	slowTimer = 0;
	freezeTimer = 0;
	flashTimer = 0;

	// AI 计时状态（EnemyAI 读写）
	aiTimer = 0;
	shootTimer = 0;
	chargeState = 0; // 0=追踪 1=蓄力 2=冲锋
	chargeTimer = 0;
	chargeDir = Vec2.zero;
	suicideArmed = false;

	// 视野剔除标记（WaveManager 设置）
	isVisible = true;

	// 敌人子弹发射器（WaveManager 注入 EnemyBulletManager）
	bulletManager?: BulletLauncher;

	private root: Node.Type;
	private nodeRef: Node.Type;
	private bodyDraw: DrawNode.Type;
	private flashDraw: DrawNode.Type;
	private healthDraw: DrawNode.Type;
	private showHealthTimer = 0;

	constructor(def: EnemyDef, spawnPos: Vec2.Type, root: Node.Type) {
		this.id = nextEnemyId++;
		this.def = def;
		this.kind = def.kind;
		this.radius = def.radius;
		this.maxHp = def.maxHp;
		this.color = def.color;
		this.isElite = def.isElite;
		this.isBoss = def.isBoss;
		this.pos = spawnPos;
		this.root = root;
		this.nodeRef = Node();
		this.nodeRef.position = this.pos;
		this.bodyDraw = DrawNode();
		this.flashDraw = DrawNode();
		this.healthDraw = DrawNode();
		this.bodyDraw.addTo(this.nodeRef);
		this.flashDraw.addTo(this.nodeRef);
		this.healthDraw.addTo(this.nodeRef);
		this.resetFromPool(spawnPos, def);
	}

	get node(): Node.Type {
		return this.nodeRef;
	}

	// 对象池复用：完全重置并重建视觉
	resetFromPool(pos: Vec2.Type, def: EnemyDef): void {
		this.def = def;
		this.kind = def.kind;
		this.radius = def.radius;
		this.maxHp = def.maxHp;
		this.color = def.color;
		this.isElite = def.isElite;
		this.isBoss = def.isBoss;
		this.isAlive = true;
		this.markedDead = false;
		this.hp = def.maxHp;
		this.pos = pos;
		this.velocity = Vec2.zero;
		this.facing = 0;
		this.slowMult = 1;
		this.slowTimer = 0;
		this.freezeTimer = 0;
		this.flashTimer = 0;
		this.showHealthTimer = 0;
		this.aiTimer = 0;
		this.shootTimer = def.shootInterval !== undefined ? def.shootInterval * 0.6 : 0;
		this.chargeState = 0;
		this.chargeTimer = 0;
		this.chargeDir = Vec2.zero;
		this.suicideArmed = false;
		this.isVisible = true;
		this.nodeRef.position = this.pos;
		this.nodeRef.visible = true;
		// 幂等挂载：已有父说明已在场景树（对象池复用），无需重复 addTo
		if (this.nodeRef.parent !== this.root) {
			this.nodeRef.addTo(this.root);
		}
		this.redrawVisual(def);
	}

	private redrawVisual(def: EnemyDef): void {
		this.bodyDraw.clear();
		this.flashDraw.clear();
		this.healthDraw.clear();
		const body = colorOf(def.color);
		const bright = Color(246, 232, 190, 255);
		this.bodyDraw.drawDot(Vec2(3, -4), def.radius + 5, Color(0, 0, 0, 90));
		this.bodyDraw.drawPolygon(this.enemyShape(def), body, 2.5, colorOf(0xf0dbc0));
		this.drawEnemyFeatures(def, bright);
		// 精英/Boss 外环
		if (def.isElite || def.isBoss) {
			drawRing(this.bodyDraw, def.radius + 5, 18, 2, bright);
		}
		if (def.isBoss) {
			drawRing(this.bodyDraw, def.radius + 10, 20, 3, colorOf(0x70151f));
		}
		// 自爆怪警示内圈
		if (def.kind === 'exploder') {
			drawRing(this.bodyDraw, def.radius * 0.55, 12, 2, Color(255, 220, 120, 255));
		}
	}

	private enemyShape(def: EnemyDef): Vec2.Type[] {
		const r = def.radius;
		switch (def.kind) {
			case 'runner': return [Vec2(r, 0), Vec2(0, r * 0.8), Vec2(-r, 0), Vec2(0, -r * 0.8)];
			case 'tank': return [Vec2(r, r * 0.55), Vec2(r * 0.55, r), Vec2(-r * 0.55, r), Vec2(-r, r * 0.55), Vec2(-r, -r * 0.55), Vec2(-r * 0.55, -r), Vec2(r * 0.55, -r), Vec2(r, -r * 0.55)];
			case 'ranger': return [Vec2(r, 0), Vec2(r * 0.25, r), Vec2(-r * 0.85, r * 0.65), Vec2(-r * 0.85, -r * 0.65), Vec2(r * 0.25, -r)];
			case 'charger': return [Vec2(r * 1.25, 0), Vec2(r * 0.15, r), Vec2(-r, r * 0.65), Vec2(-r, -r * 0.65), Vec2(r * 0.15, -r)];
			case 'shield': return [Vec2(r, 0), Vec2(r * 0.55, r), Vec2(-r * 0.8, r), Vec2(-r, 0), Vec2(-r * 0.8, -r), Vec2(r * 0.55, -r)];
			case 'exploder': return [Vec2(r, 0), Vec2(r * 0.45, r * 0.8), Vec2(-r * 0.45, r * 0.8), Vec2(-r, 0), Vec2(-r * 0.45, -r * 0.8), Vec2(r * 0.45, -r * 0.8)];
			case 'elite': return [Vec2(r * 1.15, 0), Vec2(r * 0.55, r), Vec2(-r * 0.6, r), Vec2(-r, 0), Vec2(-r * 0.6, -r), Vec2(r * 0.55, -r)];
			case 'boss': return [Vec2(r * 1.15, 0), Vec2(r * 0.7, r * 0.8), Vec2(0, r), Vec2(-r, r * 0.7), Vec2(-r * 0.85, 0), Vec2(-r, -r * 0.7), Vec2(0, -r), Vec2(r * 0.7, -r * 0.8)];
			default: return circleVerts(r);
		}
	}

	private drawEnemyFeatures(def: EnemyDef, bright: Color.Type): void {
		const r = def.radius;
		this.bodyDraw.drawDot(Vec2(r * 0.38, r * 0.28), Math.max(2, r * 0.14), bright);
		this.bodyDraw.drawDot(Vec2(r * 0.38, -r * 0.28), Math.max(2, r * 0.14), bright);
		if (def.kind === 'tank') {
			this.bodyDraw.drawSegment(Vec2(-r * 0.45, r * 0.7), Vec2(r * 0.35, r * 0.7), 5, Color(34, 60, 46, 255));
			this.bodyDraw.drawSegment(Vec2(-r * 0.45, -r * 0.7), Vec2(r * 0.35, -r * 0.7), 5, Color(34, 60, 46, 255));
		} else if (def.kind === 'ranger') {
			this.bodyDraw.drawSegment(Vec2(r * 0.65, -r * 0.8), Vec2(r * 0.65, r * 0.8), 2.5, Color(111, 232, 219, 255));
		} else if (def.kind === 'charger') {
			this.bodyDraw.drawSegment(Vec2(r * 0.35, r * 0.75), Vec2(r * 1.35, r * 0.95), 3, Color(255, 206, 113, 255));
			this.bodyDraw.drawSegment(Vec2(r * 0.35, -r * 0.75), Vec2(r * 1.35, -r * 0.95), 3, Color(255, 206, 113, 255));
		} else if (def.kind === 'shield') {
			this.bodyDraw.drawSegment(Vec2(r * 0.75, -r), Vec2(r * 0.75, r), 5, Color(190, 216, 247, 255));
		} else if (def.isBoss) {
			this.bodyDraw.drawSegment(Vec2(-r * 0.3, r * 0.8), Vec2(-r * 0.55, r * 1.35), 5, Color(238, 201, 114, 255));
			this.bodyDraw.drawSegment(Vec2(-r * 0.3, -r * 0.8), Vec2(-r * 0.55, -r * 1.35), 5, Color(238, 201, 114, 255));
		}
	}

	// 每帧调用：aiTick=true 时本帧执行 AI（分帧轮转），AI 时间用 dt*divisor 补偿
	update(dt: number, playerPos: Vec2.Type, dtScale: number, aiTick: boolean): void {
		if (!this.isAlive || this.markedDead) return;
		// 减速计时
		if (this.slowTimer > 0) {
			this.slowTimer -= dt;
			if (this.slowTimer <= 0) this.slowMult = 1;
		}
		// 冻结：完全静止（AI 与击退均暂停）
		if (this.freezeTimer > 0) {
			this.freezeTimer -= dt;
			return;
		}
		// 受击闪白淡出
		if (this.flashTimer > 0) {
			this.flashTimer -= dt;
			if (this.flashTimer <= 0) this.flashDraw.clear();
		}
		if (this.showHealthTimer > 0) {
			this.showHealthTimer -= dt;
			this.redrawHealth();
		} else if (!this.isBoss && !this.isElite) {
			this.healthDraw.clear();
		}
		if (aiTick) {
			updateEnemyAI(this, playerPos, dt * Config.aiTickDivisor, dtScale);
		}
		this.applyKnockback(dt);
	}

	// 击退速度应用与衰减；同时把视觉节点同步到逻辑位置
	private applyKnockback(dt: number): void {
		if (this.velocity.x !== 0 || this.velocity.y !== 0) {
			this.pos = Vec2(this.pos.x + this.velocity.x * dt, this.pos.y + this.velocity.y * dt);
			this.velocity = Vec2(this.velocity.x * 0.86, this.velocity.y * 0.86);
		}
		this.nodeRef.position = this.pos;
	}

	takeDamage(info: DamageInfo): void {
		if (!this.isAlive || this.markedDead) return;
		let amount = info.amount;
		// 护盾：正面（玩家侧）减伤 50%。facing 朝向玩家；
		// 击退方向与 facing 同向说明敌人被从背后向前推（背袭），全额；否则减半
		if (this.def.ai === 'shield') {
			const fdot = info.knockback.x * Math.cos(this.facing) + info.knockback.y * Math.sin(this.facing);
			if (fdot <= 0.001) amount *= 0.5;
		}
		this.hp -= amount;
		this.showHealthTimer = 1.8;
		this.redrawHealth();
		// 闪白
		if (info.flash) {
			this.flashTimer = 0.08;
			this.flashDraw.clear();
			this.flashDraw.drawPolygon(circleVerts(this.radius + 1), Color(255, 255, 255, 220));
		}
		// 击退
		if (info.knockback.x !== 0 || info.knockback.y !== 0) {
			this.velocity = Vec2(this.velocity.x + info.knockback.x, this.velocity.y + info.knockback.y);
		}
		if (this.hp <= 0) {
			this.die();
		}
	}

	private redrawHealth(): void {
		this.healthDraw.clear();
		if (this.hp >= this.maxHp && !this.isBoss && !this.isElite) return;
		const w = this.isBoss ? 92 : this.isElite ? 58 : 42;
		const y = this.radius + (this.isBoss ? 24 : 15);
		const ratio = Math.max(0, Math.min(1, this.hp / this.maxHp));
		this.healthDraw.drawPolygon([Vec2(-w / 2, y), Vec2(w / 2, y), Vec2(w / 2, y + 6), Vec2(-w / 2, y + 6)], Color(15, 18, 20, 230));
		this.healthDraw.drawPolygon([Vec2(-w / 2 + 1, y + 1), Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 1), Vec2(-w / 2 + 1 + (w - 2) * ratio, y + 5), Vec2(-w / 2 + 1, y + 5)], Color(this.isBoss ? 215 : 224, this.isBoss ? 54 : 75, this.isBoss ? 65 : 82, 255));
	}

	knockback(force: Vec2.Type): void {
		if (!this.isAlive) return;
		this.velocity = Vec2(this.velocity.x + force.x, this.velocity.y + force.y);
	}

	slowdown(mult: number, duration: number): void {
		this.slowMult = Math.min(this.slowMult, mult);
		this.slowTimer = Math.max(this.slowTimer, duration);
	}

	freeze(duration: number): void {
		this.freezeTimer = Math.max(this.freezeTimer, duration);
	}

	// 无尽模式循环增强：仅提高当前 hp，不改变 maxHp 基线
	applyWaveBoost(hpMult: number): void {
		this.hp = this.maxHp * hpMult;
	}

	// 死亡结算（受击致死或自爆/环境击杀共用）
	die(): void {
		if (!this.isAlive || this.markedDead) return;
		this.isAlive = false;
		this.markedDead = true;
		ctx.stats.kills++;
		if (this.isElite) ctx.stats.eliteKills++;
		if (this.isBoss) ctx.stats.bossKills++;
		// 打击感
		if (ctx.vfx) {
			ctx.vfx.burst(this.pos, this.color, this.isBoss ? 26 : this.isElite ? 16 : 8, this.isBoss ? 240 : 140);
			ctx.vfx.ring(this.pos, this.color, this.isBoss ? 90 : 40);
		}
		if (ctx.feedback) {
			ctx.feedback.spawnDamageText(this.pos, this.def.exp, false);
			if (this.isBoss) ctx.feedback.shake(10);
			else if (this.isElite) ctx.feedback.shake(6);
			else ctx.feedback.shake(3);
		}
		// 掉落/统计通知（PickupSystem 注册）
		if (ctx.onEnemyDied) ctx.onEnemyDied(this, this.def.exp, this.pos, this.kind);
		// 池化节点不 remove（Dora remove 会 dispose 节点），隐藏等待复用
		this.nodeRef.visible = false;
	}

	// 对象池回收前清理（release 时由池调用）
	clearForPool(): void {
		this.isAlive = false;
		this.markedDead = true;
		this.bodyDraw.clear();
		this.flashDraw.clear();
		this.healthDraw.clear();
		this.nodeRef.visible = false;
		this.bulletManager = undefined;
	}
}

function drawRing(draw: DrawNode.Type, radius: number, segments: number, width: number, color: Color.Type): void {
	const points = circleVerts(radius);
	for (let i = 0; i < segments; i++) {
		const a1 = (i / segments) * Math.PI * 2;
		const a2 = ((i + 1) / segments) * Math.PI * 2;
		draw.drawSegment(Vec2(Math.cos(a1) * radius, Math.sin(a1) * radius), Vec2(Math.cos(a2) * radius, Math.sin(a2) * radius), width, color);
	}
}

// 敌人对象池：WaveManager 构造时先 setEnemyPoolRoot(root)
let enemyRoot: Node.Type | undefined;
export function setEnemyPoolRoot(root: Node.Type): void {
	enemyRoot = root;
}

export const enemyPool = new ObjectPool<Enemy>(
	(): Enemy => new Enemy(getEnemyDef('walker'), Vec2.zero, enemyRoot ?? Node()),
	(item: Enemy): void => {
		item.clearForPool();
	},
);
