// 程序化特效工厂：粒子爆散/冲击波/闪光/斩击弧光
// 内部使用 DrawNode 池 + 活动列表，update(dt) 统一推进并回收
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { ObjectPool } from 'game/utils/ObjectPool';
import { rng } from 'game/utils/RNG';
import { ctx } from 'game/core/GameContext';
import { withAlpha } from 'game/utils/MathUtils';

type VFXKind = 'burst' | 'ring' | 'flash' | 'slash';

interface Particle {
	dx: number;
	dy: number;
	vx: number;
	vy: number;
	size: number;
}

interface VFXItem {
	node: DrawNode.Type;
	kind: VFXKind;
	life: number;
	maxLife: number;
	color: number;
	angle: number;
	radius: number;
	particles: Particle[];
}

// 画圆多边形顶点（局部坐标，segment 段数）
function circleVerts(radius: number, segments: number): Vec2.Type[] {
	const verts: Vec2.Type[] = [];
	for (let i = 0; i < segments; i++) {
		const a = (i / segments) * Math.PI * 2;
		verts.push(Vec2(Math.cos(a) * radius, Math.sin(a) * radius));
	}
	return verts;
}

const ITEM_POOL = new ObjectPool<VFXItem>(
	() => ({
		node: DrawNode(),
		kind: 'burst',
		life: 0,
		maxLife: 0,
		color: 0xffffff,
		angle: 0,
		radius: 0,
		particles: [],
	}),
	(item) => {
		item.node.clear();
		// 池化节点不 remove（Dora remove 会 dispose 节点），隐藏等待复用
		item.node.visible = false;
		item.particles.length = 0;
	}
);

export class VFX {
	private root: Node.Type;
	private active: VFXItem[] = [];
	private maxActive = 256;

	constructor(root: Node.Type) {
		this.root = root;
		this.bind();
	}

	// 注册到 ctx（箭头包装保证 this 绑定）
	private bind(): void {
		ctx.vfx = {
			burst: (pos, color, count, speed) => this.burst(pos, color, count, speed),
			ring: (pos, color, radius) => this.ring(pos, color, radius),
			flash: (pos, color, radius) => this.flash(pos, color, radius),
			slash: (pos, angle, color, radius) => this.slash(pos, angle, color, radius),
		};
	}

	// 粒子爆散
	burst(pos: Vec2.Type, color: number, count: number, speed: number): void {
		const item = this.obtain('burst', pos, color, 0.35, 0, 0);
		const n = Math.max(2, Math.min(24, count));
		for (let i = 0; i < n; i++) {
			const a = rng.range(0, Math.PI * 2);
			const sp = rng.range(0.3, 1) * speed;
			item.particles.push({
				dx: 0,
				dy: 0,
				vx: Math.cos(a) * sp,
				vy: Math.sin(a) * sp,
				size: rng.range(2, 4.5),
			});
		}
	}

	// 冲击波扩散环
	ring(pos: Vec2.Type, color: number, radius: number): void {
		this.obtain('ring', pos, color, 0.3, 0, radius);
	}

	// 闪光圆快速消失
	flash(pos: Vec2.Type, color: number, radius: number): void {
		this.obtain('flash', pos, color, 0.14, 0, radius);
	}

	// 弧形斩击光
	slash(pos: Vec2.Type, angle: number, color: number, radius: number): void {
		this.obtain('slash', pos, color, 0.12, angle, radius);
	}

	private obtain(kind: VFXKind, pos: Vec2.Type, color: number, life: number, angle: number, radius: number): VFXItem {
		let item: VFXItem;
		if (this.active.length >= this.maxActive) {
			// 超上限：回收最老的一个
			const oldest = this.active.shift();
			if (oldest !== undefined) {
				ITEM_POOL.release(oldest);
			}
		}
		item = ITEM_POOL.acquire();
		item.node.position = Vec2(pos.x, pos.y);
		item.node.visible = true;
		// 幂等挂载：池化节点复用时不重复 addTo（重复 add 报 child already added）
		if (item.node.parent !== this.root) {
			item.node.addTo(this.root);
		}
		item.kind = kind;
		item.life = life;
		item.maxLife = life;
		item.color = color;
		item.angle = angle;
		item.radius = radius;
		this.active.push(item);
		return item;
	}

	// 每帧更新所有活动特效并回收
	update(dt: number): void {
		for (let i = this.active.length - 1; i >= 0; i--) {
			const item = this.active[i];
			item.life -= dt;
			if (item.life <= 0) {
				this.active.splice(i, 1);
				ITEM_POOL.release(item);
				continue;
			}
			this.redraw(item);
		}
	}

	private redraw(item: VFXItem): void {
		const node = item.node;
		node.clear();
		const t = 1 - item.life / item.maxLife; // 0..1 进度
		const alpha = (1 - t) * 255;
		const color = Color(withAlpha(item.color, Math.round(alpha)));
		const bright = Color(withAlpha(item.color, Math.round(Math.min(255, alpha * 1.6))));
		switch (item.kind) {
			case 'burst': {
				const dtScale = 0.016; // 每帧近似的移动量基准
				for (let i = 0; i < item.particles.length; i++) {
					const p = item.particles[i];
					p.dx += p.vx * dtScale;
					p.dy += p.vy * dtScale;
					p.vx *= 0.92;
					p.vy *= 0.92;
					node.drawDot(Vec2(p.dx, p.dy), p.size, color);
				}
				break;
			}
			case 'ring': {
				const r = item.radius * easeOut(t);
				const verts = circleVerts(r, 20);
				verts.push(Vec2.zero);
				node.drawPolygon(verts, Color(withAlpha(item.color, Math.round(alpha * 0.25))));
				// 边缘亮线
				for (let i = 0; i < 20; i++) {
					const a1 = (i / 20) * Math.PI * 2;
					const a2 = ((i + 1) / 20) * Math.PI * 2;
					node.drawSegment(
						Vec2(Math.cos(a1) * r, Math.sin(a1) * r),
						Vec2(Math.cos(a2) * r, Math.sin(a2) * r),
						1.5,
						bright
					);
				}
				break;
			}
			case 'flash': {
				const r = item.radius * (1 - t * 0.4);
				const verts = circleVerts(r, 16);
				verts.push(Vec2.zero);
				node.drawPolygon(verts, Color(withAlpha(0xffffff, Math.round(alpha))));
				node.drawDot(Vec2.zero, r * 0.5, bright);
				break;
			}
			case 'slash': {
				const r = item.radius * (0.4 + 0.6 * easeOut(t));
				const half = 0.6; // 半角约 34°
				const segments = 8;
				const verts: Vec2.Type[] = [Vec2.zero];
				for (let i = 0; i <= segments; i++) {
					const a = item.angle - half + (i / segments) * half * 2;
					verts.push(Vec2(Math.cos(a) * r, Math.sin(a) * r));
				}
				node.drawPolygon(verts, Color(withAlpha(item.color, Math.round(alpha * 0.55))));
				node.drawSegment(
					Vec2(Math.cos(item.angle - half) * r, Math.sin(item.angle - half) * r),
					Vec2(Math.cos(item.angle) * r * 0.7, Math.sin(item.angle) * r * 0.7),
					2,
					bright
				);
				break;
			}
		}
	}

	// 清空所有特效（重开/切换场景时调用）
	clear(): void {
		for (let i = this.active.length - 1; i >= 0; i--) {
			const item = this.active[i];
			this.active.splice(i, 1);
			ITEM_POOL.release(item);
		}
	}

	// 强制绑定（构造后调用一次）
	init(): void {
		this.bind();
	}
}

function easeOut(t: number): number {
	const u = 1 - t;
	return 1 - u * u * u;
}
