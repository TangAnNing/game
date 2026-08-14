// 虚拟摇杆：左下角半透明底座 + 拖动摇杆头；输出归一化方向（死区 0.15）
// 触摸层为全屏 sized 节点（touch.location 为左下角原点本地坐标，需换算屏幕中心坐标）
import { Color, DrawNode, Node, Size, Vec2, View } from 'Dora';
import type { Touch } from 'Dora';

const STICK_RADIUS = 90;
const KNOB_RADIUS = 36;
const DEAD_ZONE = 0.15;

export class VirtualJoystick {
	private root: Node.Type;
	private touchNode: Node.Type;
	private knob: DrawNode.Type;
	private _visible = true;
	private active = false;
	private offset: Vec2.Type = Vec2(0, 0);
	// 摇杆底座中心（屏幕中心坐标系，左下角区域）
	private baseCenter: Vec2.Type;

	constructor(uiRoot: Node.Type) {
		const w = View.size.width;
		const h = View.size.height;
		this.baseCenter = Vec2(-w / 2 + 150, -h / 2 + 150);

		this.root = Node();
		const base = DrawNode();
		base.drawDot(this.baseCenter, STICK_RADIUS, Color(14, 31, 33, 125));
		base.drawDot(this.baseCenter, STICK_RADIUS - 12, Color(62, 112, 106, 42));
		drawRing(base, this.baseCenter, STICK_RADIUS - 2, 24, 3, Color(94, 151, 139, 115));
		this.knob = DrawNode();
		this.drawKnob(this.baseCenter);
		base.addTo(this.root);
		this.knob.addTo(this.root);
		this.root.addTo(uiRoot);

		// 触摸层：全屏命中区（size 下本地坐标原点在左下角）
		this.touchNode = Node();
		this.touchNode.size = Size(w, h);
		this.touchNode.touchEnabled = true;
		this.touchNode.swallowTouches = true;
		this.touchNode.onTapBegan((touch) => this.onBegan(touch));
		this.touchNode.onTapMoved((touch) => this.onMoved(touch));
		this.touchNode.onTapEnded(() => this.onEnded());
		this.touchNode.addTo(uiRoot);
	}

	get isVisible(): boolean {
		return this._visible;
	}

	setVisible(v: boolean): void {
		this._visible = v;
		this.root.visible = v;
		this.touchNode.visible = v;
		if (!v) this.onEnded();
	}

	get moveDir(): Vec2.Type {
		const dx = this.offset.x / STICK_RADIUS;
		const dy = this.offset.y / STICK_RADIUS;
		const len = Math.sqrt(dx * dx + dy * dy);
		if (len < DEAD_ZONE) return Vec2(0, 0);
		if (len > 1) return Vec2(dx / len, dy / len);
		return Vec2(dx, dy);
	}

	// 触摸本地坐标（左下原点）转屏幕中心坐标
	private toScreen(local: Vec2.Type): Vec2.Type {
		return Vec2(local.x - View.size.width / 2, local.y - View.size.height / 2);
	}

	private onBegan(touch: Touch.Type): void {
		const p = this.toScreen(touch.location);
		// 只响应左下半屏
		if (p.x >= 0 || p.y >= 0) return;
		this.active = true;
		this.updateKnob(p);
	}

	private onMoved(touch: Touch.Type): void {
		if (!this.active) return;
		this.updateKnob(this.toScreen(touch.location));
	}

	private onEnded(): void {
		if (!this.active) return;
		this.active = false;
		this.offset = Vec2(0, 0);
		this.knob.clear();
		this.drawKnob(this.baseCenter);
	}

	private updateKnob(p: Vec2.Type): void {
		let ox = p.x - this.baseCenter.x;
		let oy = p.y - this.baseCenter.y;
		const len = Math.sqrt(ox * ox + oy * oy);
		if (len > STICK_RADIUS) {
			ox = (ox / len) * STICK_RADIUS;
			oy = (oy / len) * STICK_RADIUS;
		}
		this.offset = Vec2(ox, oy);
		this.knob.clear();
		this.drawKnob(Vec2(this.baseCenter.x + ox, this.baseCenter.y + oy));
	}

	private drawKnob(center: Vec2.Type): void {
		this.knob.drawDot(center, KNOB_RADIUS, Color(208, 161, 65, 185));
		this.knob.drawDot(center, KNOB_RADIUS - 9, Color(46, 72, 70, 235));
		drawRing(this.knob, center, KNOB_RADIUS, 18, 2, Color(244, 212, 139, 190));
	}
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
	const points = circleVertsAt(center, radius, segments);
	for (let i = 0; i < points.length; i++) draw.drawSegment(points[i], points[(i + 1) % points.length], width, color);
}
