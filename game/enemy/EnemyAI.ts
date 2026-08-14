// 敌人 AI：追踪/远程/冲锋/护盾/自爆/Boss 弹幕 + 敌人子弹管理
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { Enemy } from 'game/enemy/Enemy';
import { ctx } from 'game/core/GameContext';
import { angleBetween, dirTo, dist } from 'game/utils/MathUtils';

// 玩家被弹命中半径（PlayerView 无 radius，用固定值）
const PLAYER_RADIUS = 16;
// 自爆触发距离
const SUICIDE_RANGE = 40;
// 自爆范围
const SUICIDE_AOE = 90;
// 世界边界剔除（世界 2000x2000 + 余量）
const WORLD_HALF = 1200;

// 敌人子弹（轻量实体，带 DrawNode 视觉）
class EnemyBullet {
	pos: Vec2.Type;
	vel: Vec2.Type;
	radius: number;
	damage: number;
	alive = true;

	private draw: DrawNode.Type;

	constructor(pos: Vec2.Type, vel: Vec2.Type, damage: number, radius: number, root: Node.Type) {
		this.pos = pos;
		this.vel = vel;
		this.damage = damage;
		this.radius = radius;
		this.draw = DrawNode();
		this.draw.drawDot(Vec2.zero, radius + 5, Color(210, 48, 54, 70));
		this.draw.drawDot(Vec2.zero, radius, Color(255, 105, 92, 255));
		this.draw.drawDot(Vec2.zero, Math.max(2, radius * 0.38), Color(255, 226, 184, 255));
		this.draw.addTo(root);
		this.draw.position = this.pos;
	}

	update(dt: number): void {
		if (!this.alive) return;
		this.pos = Vec2(this.pos.x + this.vel.x * dt, this.pos.y + this.vel.y * dt);
		this.draw.position = this.pos;
		// 玩家碰撞
		const player = ctx.player;
		if (player !== undefined && player.isAlive) {
			const dx = player.pos.x - this.pos.x;
			const dy = player.pos.y - this.pos.y;
			const rr = this.radius + PLAYER_RADIUS;
			if (dx * dx + dy * dy <= rr * rr) {
				this.alive = false;
				if (ctx.onPlayerDamaged) ctx.onPlayerDamaged(this.damage, this.pos);
			}
		}
		// 离屏剔除
		if (Math.abs(this.pos.x) > WORLD_HALF || Math.abs(this.pos.y) > WORLD_HALF) {
			this.alive = false;
		}
	}

	remove(): void {
		this.draw.removeFromParent();
	}
}

// 敌人子弹管理器（WaveManager 持有并每帧 update）
export class EnemyBulletManager {
	private bullets: EnemyBullet[] = [];
	private root: Node.Type;

	constructor(root: Node.Type) {
		this.root = root;
	}

	spawn(pos: Vec2.Type, vel: Vec2.Type, damage: number, radius = 5): void {
		if (this.bullets.length >= 400) return;
		this.bullets.push(new EnemyBullet(pos, vel, damage, radius, this.root));
	}

	update(dt: number): void {
		for (let i = this.bullets.length - 1; i >= 0; i--) {
			const b = this.bullets[i];
			b.update(dt);
			if (!b.alive) {
				b.remove();
				const last = this.bullets.length - 1;
				this.bullets[i] = this.bullets[last];
				this.bullets.pop();
			}
		}
	}

	clear(): void {
		for (let i = 0; i < this.bullets.length; i++) {
			this.bullets[i].remove();
		}
		this.bullets.length = 0;
	}

	get count(): number {
		return this.bullets.length;
	}
}

// AI 主入口（Enemy.update 每帧调用）
export function updateEnemyAI(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale = 1): void {
	if (!enemy.isAlive || enemy.markedDead) return;
	if (enemy.freezeTimer > 0) return;
	switch (enemy.def.ai) {
		case 'chase':
			aiChase(enemy, playerPos, dt, dtScale);
			break;
		case 'chaseShoot':
			aiChaseShoot(enemy, playerPos, dt, dtScale);
			break;
		case 'charge':
			aiCharge(enemy, playerPos, dt, dtScale);
			break;
		case 'shield':
			aiShield(enemy, playerPos, dt, dtScale);
			break;
		case 'suicide':
			aiSuicide(enemy, playerPos, dt, dtScale);
			break;
		case 'boss':
			aiBoss(enemy, playerPos, dt, dtScale);
			break;
	}
	enemy.facing = angleBetween(enemy.pos, playerPos);
}

function moveToward(enemy: Enemy, playerPos: Vec2.Type, speed: number, dt: number): void {
	const dir = dirTo(enemy.pos, playerPos);
	const d = speed * dt;
	enemy.pos = Vec2(enemy.pos.x + dir.x * d, enemy.pos.y + dir.y * d);
}

function aiChase(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	const spd = enemy.def.moveSpeed * enemy.slowMult * dtScale;
	moveToward(enemy, playerPos, spd, dt);
}

function fireAtPlayer(enemy: Enemy, playerPos: Vec2.Type, speed: number, dmg: number): void {
	const dir = dirTo(enemy.pos, playerPos);
	enemy.bulletManager?.spawn(enemy.pos, Vec2(dir.x * speed, dir.y * speed), dmg, 5);
}

function aiChaseShoot(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	const def = enemy.def;
	const spd = def.moveSpeed * enemy.slowMult * dtScale;
	moveToward(enemy, playerPos, spd, dt);
	enemy.shootTimer -= dt;
	if (enemy.shootTimer <= 0) {
		enemy.shootTimer = def.shootInterval ?? 2.2;
		fireAtPlayer(enemy, playerPos, def.shootSpeed ?? 220, def.damage);
	}
}

function aiCharge(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	const def = enemy.def;
	const cooldown = def.chargeCooldown ?? 2.6;
	if (enemy.chargeState === 0) {
		// 追踪阶段，周期性进入蓄力
		moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt);
		enemy.chargeTimer += dt;
		if (enemy.chargeTimer >= cooldown) {
			enemy.chargeState = 1;
			enemy.chargeTimer = 0;
		}
	} else if (enemy.chargeState === 1) {
		// 蓄力阶段：停住蓄力
		enemy.chargeTimer += dt;
		if (enemy.chargeTimer >= 0.5) {
			enemy.chargeState = 2;
			enemy.chargeTimer = 0;
			enemy.chargeDir = dirTo(enemy.pos, playerPos);
		}
	} else {
		// 冲锋阶段：高速直线
		const spd = (def.chargeSpeed ?? 340) * enemy.slowMult * dtScale;
		enemy.pos = Vec2(
			enemy.pos.x + enemy.chargeDir.x * spd * dt,
			enemy.pos.y + enemy.chargeDir.y * spd * dt,
		);
		enemy.chargeTimer += dt;
		// 碰到玩家或超时结束冲锋
		const d = dist(enemy.pos, playerPos);
		if (d < enemy.radius + PLAYER_RADIUS) {
			if (ctx.onPlayerDamaged) ctx.onPlayerDamaged(def.damage, enemy.pos);
			enemy.chargeState = 0;
			enemy.chargeTimer = 0;
		} else if (enemy.chargeTimer >= 1.1) {
			enemy.chargeState = 0;
			enemy.chargeTimer = 0;
		}
	}
}

function aiShield(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	// 缓慢追踪，正面减伤在 Enemy.takeDamage 中处理
	const spd = enemy.def.moveSpeed * enemy.slowMult * dtScale;
	moveToward(enemy, playerPos, spd, dt);
}

function aiSuicide(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	const def = enemy.def;
	moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt);
	const d = dist(enemy.pos, playerPos);
	if (d <= SUICIDE_RANGE + enemy.radius) {
		// 自爆：范围伤害 + 特效 + 自身死亡
		const dx = playerPos.x - enemy.pos.x;
		const dy = playerPos.y - enemy.pos.y;
		if (dx * dx + dy * dy <= SUICIDE_AOE * SUICIDE_AOE) {
			if (ctx.onPlayerDamaged) ctx.onPlayerDamaged(def.damage, enemy.pos);
		}
		if (ctx.vfx) {
			ctx.vfx.flash(enemy.pos, 0xff5f3f, SUICIDE_AOE);
			ctx.vfx.ring(enemy.pos, 0xff8f5f, SUICIDE_AOE);
		}
		if (ctx.feedback) ctx.feedback.shake(8);
		enemy.die();
	}
}

function aiBoss(enemy: Enemy, playerPos: Vec2.Type, dt: number, dtScale: number): void {
	const def = enemy.def;
	moveToward(enemy, playerPos, def.moveSpeed * enemy.slowMult * dtScale, dt);
	enemy.shootTimer -= dt;
	if (enemy.shootTimer <= 0) {
		enemy.shootTimer = def.shootInterval ?? 2.5;
		const speed = def.shootSpeed ?? 200;
		// 扇形弹幕：玩家方向 ±60°，12 颗
		const base = angleBetween(enemy.pos, playerPos);
		const count = 12;
		for (let i = 0; i < count; i++) {
			const a = base - 1.0 + (2.0 * i) / (count - 1);
			enemy.bulletManager?.spawn(
				enemy.pos,
				Vec2(Math.cos(a) * speed, Math.sin(a) * speed),
				def.damage * 0.6,
				6,
			);
		}
	}
}
