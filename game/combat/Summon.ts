// 召唤物：自动索敌攻击，池化复用
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { EnemyView } from 'game/core/Types';
import { ctx, PlayerView } from 'game/core/GameContext';
import { DamageSystem } from 'game/combat/DamageSystem';
import { asEnemy } from 'game/combat/Bullet';
import { ObjectPool } from 'game/utils/ObjectPool';
import { add, dist, distSq, dirTo, scale, sub, withAlpha } from 'game/utils/MathUtils';
import { audio, Sfx } from 'game/audio/AudioManager';

export class Summon {
	// 静态池
	static summonPool = new ObjectPool<Summon>(
		() => new Summon(),
		(s) => s.reset()
	);

	// 状态
	active = false;
	pos: Vec2.Type = Vec2.zero;
	color = 0xffffff;
	damage = 0;
	attackInterval = 1;
	attackTimer = 0;
	radius = 14;
	attackRange = 42;
	speed = 230;
	maxHp = 40;
	hp = 40;
	private player: PlayerView | undefined = undefined;
	private node: DrawNode.Type = DrawNode();
	private orbitAngle = 0;

	private constructor() {}

	// 从池中获取并初始化
	static spawn(
		root: Node.Type,
		player: PlayerView,
		pos: Vec2.Type,
		color: number,
		damage: number,
		interval: number,
		radius = 14,
		attackRange = 42,
		speed = 230,
		orbitAngle = 0
	): Summon {
		const s = Summon.summonPool.acquire();
		s.active = true;
		s.player = player;
		s.pos = pos;
		s.color = color;
		s.damage = damage;
		s.attackInterval = interval;
		s.attackTimer = 0;
		s.radius = radius;
		s.attackRange = attackRange;
		s.speed = speed;
		s.orbitAngle = orbitAngle;
		s.hp = s.maxHp;
		s.node.position = Vec2(pos.x, pos.y);
		s.node.visible = true;
		if (s.node.parent !== root) {
			s.node.addTo(root);
		}
		return s;
	}

	// 归还池
	recycle(): void {
		if (!this.active) return;
		Summon.summonPool.release(this);
	}

	private reset(): void {
		this.active = false;
		this.player = undefined;
		this.node.clear();
		this.node.visible = false;
	}

	// 每帧更新：索敌、移动、攻击
	update(dt: number): void {
		if (!this.active) return;
		const player = this.player;
		if (player === undefined) {
			this.recycle();
			return;
		}
		// 索敌（最近敌人）
		let nearest: EnemyView | undefined = undefined;
		let best = Infinity;
		const candidates = ctx.findEnemiesNear !== undefined
			? ctx.findEnemiesNear(this.pos, 320, 4)
			: [];
		for (let i = 0; i < candidates.length; i++) {
			const e = asEnemy(candidates[i]);
			if (e === undefined || !e.isAlive || e.markedDead) continue;
			const d = distSq(this.pos, e.pos);
			if (d < best) {
				best = d;
				nearest = e;
			}
		}
		// 移动：有目标则逼近，无目标则围绕玩家
		if (nearest !== undefined) {
			const targetDist = dist(this.pos, nearest.pos);
			const desired = this.attackRange + nearest.radius + 6;
			if (targetDist > desired) {
				const dir = dirTo(this.pos, nearest.pos);
				this.pos = add(this.pos, scale(dir, this.speed * dt));
			}
		} else {
			const d = dist(this.pos, player.pos);
			if (d > 96) {
				const dir = dirTo(this.pos, player.pos);
				this.pos = add(this.pos, scale(dir, this.speed * dt));
			} else if (d < 40) {
				const dir = dirTo(this.pos, player.pos);
				this.pos = sub(this.pos, scale(dir, this.speed * dt));
			}
		}
		// 攻击
		this.attackTimer -= dt;
		if (nearest !== undefined && this.attackTimer <= 0) {
			const d = dist(this.pos, nearest.pos);
			if (d <= this.attackRange + nearest.radius + 8) {
				this.attackTimer = this.attackInterval;
				const dir = dirTo(this.pos, nearest.pos);
				const info = DamageSystem.buildInfo(this.damage, player, 'summon', dir, 'physical');
				DamageSystem.apply(nearest, info);
				audio.playSfx(Sfx.SummonImpact, 0.08);
				const explodeLevel = player.skillStacks['summonExplode'] ?? 0;
				if (explodeLevel > 0) {
					ctx.damageEnemiesInRadius?.(nearest.pos, 46 + explodeLevel * 8, {
						amount: this.damage * 0.3 * explodeLevel,
						kind: 'magic', crit: false, knockback: Vec2.zero,
						hitStop: 0, shake: 1, flash: true, source: 'explosion',
					});
					ctx.vfx?.ring(nearest.pos, this.color, 46 + explodeLevel * 8);
				}
				ctx.vfx?.burst(nearest.pos, this.color, 4, 100);
			}
		}
		// 重绘
		this.redraw();
	}

	// 受击（预留：敌人攻击召唤物）
	takeHit(amount: number): void {
		if (!this.active) return;
		this.hp -= amount;
		if (this.hp <= 0) {
			this.recycle();
		}
	}

	private redraw(): void {
		const node = this.node;
		node.clear();
		node.position = Vec2(this.pos.x, this.pos.y);
		// 身体
		const verts: Vec2.Type[] = [];
		for (let i = 0; i < 16; i++) {
			const a = (i / 16) * Math.PI * 2;
			verts.push(Vec2(Math.cos(a) * this.radius, Math.sin(a) * this.radius));
		}
		verts.push(Vec2.zero);
		node.drawPolygon(verts, Color(0xff000000 | this.color));
		node.drawPolygon(verts, Color(0xff000000 | this.color), 2, Color(withAlpha(0xffffff, 160)));
		// 眼睛（面向攻击方向近似固定朝向右侧，简单风格）
		const eyeX = this.radius * 0.3;
		const eyeY = this.radius * 0.35;
		node.drawDot(Vec2(eyeX, eyeY), this.radius * 0.16, Color(0xffffffff));
		node.drawDot(Vec2(eyeX, -eyeY), this.radius * 0.16, Color(0xffffffff));
		node.drawDot(Vec2(eyeX + this.radius * 0.05, eyeY), this.radius * 0.07, Color(0xff000000));
		node.drawDot(Vec2(eyeX + this.radius * 0.05, -eyeY), this.radius * 0.07, Color(0xff000000));
	}
}
