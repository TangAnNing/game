// 场景：世界背景、网格、边界、装饰与刷怪点
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { RNG } from 'game/utils/RNG';
import { clamp } from 'game/utils/MathUtils';

const WORLD_SIZE = 2000;
const HALF = WORLD_SIZE / 2;
const TILE_STEP = 160;
const DECOR_COUNT = 110;
const DECOR_SEED = 20240520;

export class Scene {
	private root: Node.Type;
	private background: DrawNode.Type;
	private decorDraw: DrawNode.Type;
	private boundsDraw: DrawNode.Type;

	constructor(root: Node.Type) {
		this.root = root;
		this.background = DrawNode();
		this.decorDraw = DrawNode();
		this.boundsDraw = DrawNode();
		this.drawBackground();
		this.drawBounds();
		this.buildDecor();
		this.background.addTo(this.root);
		this.decorDraw.addTo(this.root);
		this.boundsDraw.addTo(this.root);
	}

	getWorldBounds(): { minX: number; maxX: number; minY: number; maxY: number } {
		return { minX: -HALF, maxX: HALF, minY: -HALF, maxY: HALF };
	}

	// 从世界边缘带随机生成刷怪点（默认避开玩家视野 margin）
	getSpawnPointNearEdge(worldCenter: Vec2.Type, margin: number): Vec2.Type {
		for (let attempt = 0; attempt < 8; attempt++) {
			const a = this.spawnRng.range(0, Math.PI * 2);
			const r = this.spawnRng.range(HALF - 160, HALF - 50);
			const x = Math.cos(a) * r;
			const y = Math.sin(a) * r;
			const dx = x - worldCenter.x;
			const dy = y - worldCenter.y;
			if (dx * dx + dy * dy >= margin * margin) {
				return Vec2(x, y);
			}
		}
		// 兜底：玩家向外 margin 方向（clamp 在世界内）
		const a2 = this.spawnRng.range(0, Math.PI * 2);
		const x2 = clamp(worldCenter.x + Math.cos(a2) * margin, -HALF + 40, HALF - 40);
		const y2 = clamp(worldCenter.y + Math.sin(a2) * margin, -HALF + 40, HALF - 40);
		return Vec2(x2, y2);
	}

	isInside(pos: Vec2.Type): boolean {
		return Math.abs(pos.x) <= HALF && Math.abs(pos.y) <= HALF;
	}

	update(dt: number): void {
		// 目前无动态场景元素
	}

	// ---------- 内部 ----------
	private spawnRng = new RNG(0xabcdef01);

	private drawBackground(): void {
		this.background.clear();
		const c = Color(13, 24, 26, 255);
		this.background.drawPolygon(
			[Vec2(-HALF, -HALF), Vec2(HALF, -HALF), Vec2(HALF, HALF), Vec2(-HALF, HALF)],
			c,
		);
		// 不规则石板分区，避免开发调试感的全屏工程网格。
		for (let gx = -HALF; gx < HALF; gx += TILE_STEP) {
			for (let gy = -HALF; gy < HALF; gy += TILE_STEP) {
				const odd = (Math.floor((gx + HALF) / TILE_STEP) + Math.floor((gy + HALF) / TILE_STEP)) % 2 === 0;
				const pad = 4;
				this.background.drawPolygon(
					[Vec2(gx + pad, gy + pad), Vec2(gx + TILE_STEP - pad, gy + pad), Vec2(gx + TILE_STEP - pad, gy + TILE_STEP - pad), Vec2(gx + pad, gy + TILE_STEP - pad)],
					Color(odd ? 17 : 15, odd ? 31 : 28, odd ? 32 : 30, 255),
				);
			}
		}
		// 出生祭坛：让地图中心成为明确的视觉锚点。
		this.background.drawDot(Vec2.zero, 190, Color(23, 52, 48, 255));
		drawRing(this.background, Vec2.zero, 190, 32, 4, Color(61, 104, 91, 180));
		drawRing(this.background, Vec2.zero, 116, 24, 2, Color(203, 156, 67, 150));
		for (let i = 0; i < 8; i++) {
			const a = (i / 8) * Math.PI * 2;
			const p1 = Vec2(Math.cos(a) * 126, Math.sin(a) * 126);
			const p2 = Vec2(Math.cos(a) * 176, Math.sin(a) * 176);
			this.background.drawSegment(p1, p2, 5, Color(172, 127, 53, 120));
		}
	}

	private drawBounds(): void {
		this.boundsDraw.clear();
		const shadow = Color(0, 0, 0, 180);
		const c = Color(197, 145, 56, 255);
		this.boundsDraw.drawSegment(Vec2(-HALF, -HALF), Vec2(HALF, -HALF), 12, shadow);
		this.boundsDraw.drawSegment(Vec2(HALF, -HALF), Vec2(HALF, HALF), 12, shadow);
		this.boundsDraw.drawSegment(Vec2(HALF, HALF), Vec2(-HALF, HALF), 12, shadow);
		this.boundsDraw.drawSegment(Vec2(-HALF, HALF), Vec2(-HALF, -HALF), 12, shadow);
		this.boundsDraw.drawSegment(Vec2(-HALF, -HALF), Vec2(HALF, -HALF), 4, c);
		this.boundsDraw.drawSegment(Vec2(HALF, -HALF), Vec2(HALF, HALF), 4, c);
		this.boundsDraw.drawSegment(Vec2(HALF, HALF), Vec2(-HALF, HALF), 4, c);
		this.boundsDraw.drawSegment(Vec2(-HALF, HALF), Vec2(-HALF, -HALF), 4, c);
	}

	// 固定种子散布装饰（草/石），数量受控
	private buildDecor(): void {
		this.decorDraw.clear();
		const rng = new RNG(DECOR_SEED);
		for (let i = 0; i < DECOR_COUNT; i++) {
			const x = rng.range(-HALF + 30, HALF - 30);
			const y = rng.range(-HALF + 30, HALF - 30);
			if (rng.chance(0.45)) {
				// 发光菌簇
				const r = rng.range(2, 5);
				this.decorDraw.drawDot(Vec2(x, y), r + 4, Color(45, 136, 105, 24));
				this.decorDraw.drawDot(Vec2(x, y), r, Color(64, rng.int(120, 185), 122, 185));
			} else if (rng.chance(0.62)) {
				// 裂纹，由两段不共线笔画构成。
				const a = rng.range(0, Math.PI * 2);
				const len = rng.range(12, 30);
				const mid = Vec2(x + Math.cos(a) * len * 0.5, y + Math.sin(a) * len * 0.5);
				this.decorDraw.drawSegment(Vec2(x, y), mid, 1.5, Color(58, 73, 70, 170));
				this.decorDraw.drawSegment(mid, Vec2(mid.x + Math.cos(a + 0.7) * len * 0.45, mid.y + Math.sin(a + 0.7) * len * 0.45), 1.2, Color(58, 73, 70, 130));
			} else {
				// 破碎石块
				const r = rng.range(5, 11);
				this.decorDraw.drawPolygon([Vec2(x - r, y - r * 0.4), Vec2(x + r * 0.7, y - r), Vec2(x + r, y + r * 0.5), Vec2(x - r * 0.5, y + r)], Color(53, 65, 65, 220));
			}
		}
		// 四处固定遗迹，使移动时景观不再同质。
		const sites = [Vec2(-560, 420), Vec2(620, 500), Vec2(-610, -520), Vec2(560, -470)];
		for (const p of sites) this.drawRuin(p);
	}

	private drawRuin(p: Vec2.Type): void {
		drawRing(this.decorDraw, p, 72, 16, 5, Color(79, 91, 83, 210));
		drawRing(this.decorDraw, p, 48, 12, 2, Color(172, 127, 53, 140));
		for (let i = 0; i < 4; i++) {
			const a = i * Math.PI / 2 + 0.25;
			const base = Vec2(p.x + Math.cos(a) * 78, p.y + Math.sin(a) * 78);
			this.decorDraw.drawSegment(base, Vec2(base.x, base.y + 42), 9, Color(64, 75, 71, 255));
			this.decorDraw.drawDot(Vec2(base.x, base.y + 43), 8, Color(89, 99, 90, 255));
		}
	}
}

function circleVerts(radius: number, segments: number): Vec2.Type[] {
	return circleVertsAt(Vec2.zero, radius, segments);
}

function circleVertsAt(center: Vec2.Type, radius: number, segments: number): Vec2.Type[] {
	const verts: Vec2.Type[] = [];
	for (let i = 0; i < segments; i++) {
		const a = (i / segments) * Math.PI * 2;
		verts.push(Vec2(center.x + Math.cos(a) * radius, center.y + Math.sin(a) * radius));
	}
	return verts;
}

function drawRing(draw: DrawNode.Type, center: Vec2.Type, radius: number, segments: number, width: number, color: Color.Type): void {
	for (let i = 0; i < segments; i++) {
		const a1 = (i / segments) * Math.PI * 2;
		const a2 = ((i + 1) / segments) * Math.PI * 2;
		draw.drawSegment(Vec2(center.x + Math.cos(a1) * radius, center.y + Math.sin(a1) * radius), Vec2(center.x + Math.cos(a2) * radius, center.y + Math.sin(a2) * radius), width, color);
	}
}
