// 弹道实体：移动、穿透、分裂，池化复用
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { DamageInfo, EnemyView } from 'game/core/Types';
import { ctx, PlayerView } from 'game/core/GameContext';
import { DamageSystem } from 'game/combat/DamageSystem';
import { ObjectPool } from 'game/utils/ObjectPool';
import { distSq, normalize, scale, withAlpha } from 'game/utils/MathUtils';
import { Config } from 'game/config/Config';

// 把 ctx.findEnemiesNear 返回的 unknown 窄化为 EnemyView
export function asEnemy(e: unknown): EnemyView | undefined {
	if (e === undefined) return undefined;
	const enemy = e as EnemyView;
	if (enemy !== undefined && typeof enemy.takeDamage === 'function' && enemy.isAlive) {
		return enemy;
	}
	return undefined;
}

export class Bullet {
	// 静态池
	static bulletPool = new ObjectPool<Bullet>(
		() => new Bullet(),
		(b) => b.reset()
	);

	// 状态
	active = false;
	pos: Vec2.Type = Vec2.zero;
	vel: Vec2.Type = Vec2.zero;
	damage = 0;
	pierce = 0;
	split = 0;
	ricochet = 0;
	radius = 5;
	life = 0;
	color = 0xffffff;
	// 分裂新子弹通知（由 WeaponSystem 注册，箭头包装）
	onSplit: ((b: Bullet) => void) | undefined = undefined;
	private root: Node.Type = Node();
	private hitIds: number[] = [];
	private node: DrawNode.Type = DrawNode();

	private constructor() {}

	// 从池中获取并初始化
	static spawn(
		root: Node.Type,
		pos: Vec2.Type,
		vel: Vec2.Type,
		damage: number,
		range: number,
		radius: number,
		pierce: number,
		split: number,
		ricochet: number,
		color: number,
		onSplit?: (b: Bullet) => void
	): Bullet {
		const b = Bullet.bulletPool.acquire();
		b.active = true;
		b.pos = pos;
		b.vel = vel;
		b.damage = damage;
		b.pierce = pierce;
		b.split = split;
		b.ricochet = ricochet;
		b.radius = radius;
		const speed = vel.length;
		b.life = speed > 0.001 ? range / speed : 1;
		b.color = color;
		b.root = root;
		b.onSplit = onSplit !== undefined ? (nb: Bullet) => onSplit(nb) : undefined;
		b.hitIds.length = 0;
		b.node.position = Vec2(pos.x, pos.y);
		b.node.visible = true;
		// 幂等挂载：池化节点复用时不重复 addTo
		if (b.node.parent !== root) {
			b.node.addTo(root);
		}
		return b;
	}

	// 归还池（重置）
	private reset(): void {
		this.active = false;
		this.hitIds.length = 0;
		this.ricochet = 0;
		this.onSplit = undefined;
		this.node.clear();
		// 池化节点不 remove（Dora remove 会 dispose 节点），隐藏等待复用
		this.node.visible = false;
	}

	// 回收（WeaponSystem 调用后回池）
	recycle(): void {
		if (!this.active) return;
		Bullet.bulletPool.release(this);
	}

	// 每帧更新：移动 + 碰撞
	update(dt: number, player: PlayerView): void {
		if (!this.active) return;
		if (player.homing > 0) {
			const targets = ctx.findEnemiesNear?.(this.pos, 180, 1) ?? [];
			const target = targets.length > 0 ? asEnemy(targets[0]) : undefined;
			if (target !== undefined) {
				const speed = this.vel.length;
				const desired = normalize(Vec2(target.pos.x - this.pos.x, target.pos.y - this.pos.y));
				const turn = Math.min(1, dt * 7);
				const blended = normalize(Vec2(
					this.vel.x / speed * (1 - turn) + desired.x * turn,
					this.vel.y / speed * (1 - turn) + desired.y * turn,
				));
				this.vel = scale(blended, speed);
			}
		}
		this.pos = Vec2(this.pos.x + this.vel.x * dt, this.pos.y + this.vel.y * dt);
		this.life -= dt;
		// 世界边界回收，不能按固定屏幕中心判断，否则玩家走远后无法射击
		const halfW = 1000 + Config.cullMargin;
		const halfH = 1000 + Config.cullMargin;
		if (this.life <= 0 || Math.abs(this.pos.x) > halfW || Math.abs(this.pos.y) > halfH) {
			this.recycle();
			return;
		}
		// 碰撞检测
		const candidates = ctx.findEnemiesNear !== undefined
			? ctx.findEnemiesNear(this.pos, this.radius + 40, 8)
			: [];
		for (let i = 0; i < candidates.length; i++) {
			const enemy = asEnemy(candidates[i]);
			if (enemy === undefined || !enemy.isAlive || enemy.markedDead) continue;
			if (this.hitIds.indexOf(enemy.id) >= 0) continue;
			const rr = this.radius + enemy.radius;
			if (distSq(this.pos, enemy.pos) <= rr * rr) {
				this.hitIds.push(enemy.id);
				this.onHit(enemy, player);
				if (!this.active) return;
			}
		}
		// 重绘
		this.node.clear();
		this.node.position = Vec2(this.pos.x, this.pos.y);
		this.node.drawDot(Vec2.zero, this.radius, Color(0xff000000 | this.color));
		const speed = Math.sqrt(this.vel.x * this.vel.x + this.vel.y * this.vel.y);
		if (speed > 0.001) {
			const nx = this.vel.x / speed;
			const ny = this.vel.y / speed;
			this.node.drawSegment(Vec2(-nx * this.radius * 0.5, -ny * this.radius * 0.5), Vec2(-nx * (this.radius + 16), -ny * (this.radius + 16)), Math.max(2, this.radius * 0.7), Color(withAlpha(this.color, 105)));
		}
		this.node.drawDot(Vec2.zero, Math.max(2, this.radius * 0.42), Color(255, 248, 220, 245));
	}

	// 命中敌人：结算伤害、穿透/分裂判定
	private onHit(enemy: EnemyView, player: PlayerView): void {
		const dir = normalize(this.vel);
		const info: DamageInfo = DamageSystem.buildInfo(this.damage, player, 'bullet', dir, 'physical');
		DamageSystem.apply(enemy, info);
		ctx.vfx?.burst(enemy.pos, this.color, 6, 140);
		ctx.damageBreakablesInRadius?.(this.pos, this.radius + 12, info.amount);
		if (player.explosion > 0) {
			ctx.damageEnemiesInRadius?.(enemy.pos, 52 + player.explosion * 8, {
				amount: this.damage * (0.35 + player.explosion * 0.1),
				kind: 'magic', crit: false, knockback: Vec2.zero,
				hitStop: 0, shake: 2, flash: true, source: 'explosion',
			});
			ctx.vfx?.ring(enemy.pos, this.color, 52 + player.explosion * 8);
		}
		if (player.chain > 0) {
			const chained = ctx.findEnemiesNear?.(enemy.pos, 120, player.chain + 1) ?? [];
			for (let i = 0; i < chained.length; i++) {
				const next = asEnemy(chained[i]);
				if (next !== undefined && next.id !== enemy.id) {
					DamageSystem.apply(next, {
						amount: this.damage * 0.35, kind: 'magic', crit: false,
						knockback: Vec2.zero, hitStop: 0, shake: 0, flash: true, source: 'skill',
					});
				}
			}
		}
		if (this.ricochet > 0) {
			const targets = ctx.findEnemiesNear?.(enemy.pos, 180, 4) ?? [];
			for (let i = 0; i < targets.length; i++) {
				const target = asEnemy(targets[i]);
				if (target !== undefined && target.id !== enemy.id && this.hitIds.indexOf(target.id) < 0) {
					const speed = this.vel.length;
					this.vel = scale(normalize(Vec2(target.pos.x - this.pos.x, target.pos.y - this.pos.y)), speed);
					this.pierce = Math.max(this.pierce, 0);
					this.ricochet -= 1;
					return;
				}
			}
		}
		// 分裂：向两侧斜向发射
		if (this.split > 0 && this.active) {
			const baseAngle = Math.atan2(this.vel.y, this.vel.x);
			const speed = this.vel.length;
			for (let i = 0; i < 2; i++) {
				const a = baseAngle + (i === 0 ? 0.45 : -0.45);
				const sub = Bullet.spawn(
					this.root,
					this.pos,
					Vec2(Math.cos(a) * speed, Math.sin(a) * speed),
					this.damage,
					this.life * speed,
					this.radius * 0.8,
					this.pierce,
					this.split - 1,
					this.ricochet,
					this.color,
					this.onSplit
				);
				if (this.onSplit !== undefined) {
					this.onSplit(sub);
				}
			}
		}
		this.pierce -= 1;
		if (this.pierce < 0) {
			this.recycle();
		}
	}

	get isActive(): boolean {
		return this.active;
	}
}
