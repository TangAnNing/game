// 近战攻击：扇形范围判定，短暂存在，一次结算
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { DamageInfo } from 'game/core/Types';
import { ctx, PlayerView } from 'game/core/GameContext';
import { DamageSystem } from 'game/combat/DamageSystem';
import { asEnemy } from 'game/combat/Bullet';
import { dirTo, inArc, withAlpha } from 'game/utils/MathUtils';
import { rng } from 'game/utils/RNG';

export class MeleeAttack {
	readonly origin: Vec2.Type;
	readonly facing: number;
	readonly range: number;
	readonly halfAngle: number;
	readonly baseDamage: number;
	readonly color: number;
	readonly crit: boolean;
	private player: PlayerView;
	private life: number;
	private readonly maxLife: number;
	private settled = false;
	private node: DrawNode.Type = DrawNode();

	constructor(
		origin: Vec2.Type,
		facing: number,
		range: number,
		halfAngle: number,
		baseDamage: number,
		player: PlayerView,
		color: number,
		root: Node.Type,
		duration = 0.13
	) {
		this.origin = origin;
		this.facing = facing;
		this.range = range;
		this.halfAngle = halfAngle;
		this.baseDamage = baseDamage;
		this.player = player;
		this.color = color;
		this.crit = rng.chance(player.critChance);
		this.maxLife = duration;
		this.life = duration;
		// 视觉节点：扇形
		this.node.position = Vec2(origin.x, origin.y);
		this.node.addTo(root);
		this.redraw(1);
		// 斩击特效
		ctx.vfx?.slash(origin, facing, color, range);
	}

	update(dt: number): void {
		this.life -= dt;
		if (!this.settled) {
			this.settle();
		}
		if (this.life > 0) {
			this.redraw(this.life / this.maxLife);
		}
		if (this.life <= 0) {
			this.node.removeFromParent();
		}
	}

	get isDone(): boolean {
		return this.life <= 0;
	}

	// 立即结束并移除节点（清场时调用）
	dispose(): void {
		this.life = 0;
		this.node.removeFromParent();
	}

	// 结算范围内敌人
	private settle(): void {
		this.settled = true;
		ctx.damageBreakablesInRadius?.(this.origin, this.range, this.baseDamage * (1 + this.player.damageBonus));
		const candidates = ctx.findEnemiesNear !== undefined
			? ctx.findEnemiesNear(this.origin, this.range + 40, 16)
			: [];
		for (let i = 0; i < candidates.length; i++) {
			const enemy = asEnemy(candidates[i]);
			if (enemy === undefined || !enemy.isAlive || enemy.markedDead) continue;
			if (!inArc(this.origin, enemy.pos, this.facing, this.halfAngle, this.range + enemy.radius)) {
				continue;
			}
			const dir = dirTo(this.origin, enemy.pos);
			const info: DamageInfo = DamageSystem.buildInfo(
				this.baseDamage,
				this.player,
				'melee',
				dir,
				'physical',
				this.crit
			);
			DamageSystem.apply(enemy, info);
			ctx.vfx?.burst(enemy.pos, this.color, 5, 120);
		}
	}

	// 重绘扇形（alpha 随生命周期衰减）
	private redraw(alphaT: number): void {
		this.node.clear();
		const alpha = Math.max(0, Math.min(1, alphaT));
		const segments = 10;
		const verts: Vec2.Type[] = [Vec2.zero];
		for (let i = 0; i <= segments; i++) {
			const a = this.facing - this.halfAngle + (i / segments) * this.halfAngle * 2;
			verts.push(Vec2(Math.cos(a) * this.range, Math.sin(a) * this.range));
		}
		this.node.drawPolygon(verts, Color(withAlpha(this.color, Math.round(70 * alpha))));
		// 弧光边缘
		const a0 = this.facing - this.halfAngle;
		const a1 = this.facing + this.halfAngle;
		this.node.drawSegment(
			Vec2(Math.cos(a0) * this.range, Math.sin(a0) * this.range),
			Vec2(Math.cos(a1) * this.range, Math.sin(a1) * this.range),
			2,
			Color(withAlpha(0xffffff, Math.round(200 * alpha)))
		);
		// 朝向线
		this.node.drawSegment(
			Vec2.zero,
			Vec2(Math.cos(this.facing) * this.range, Math.sin(this.facing) * this.range),
			1.5,
			Color(withAlpha(this.color, Math.round(160 * alpha)))
		);
	}
}
