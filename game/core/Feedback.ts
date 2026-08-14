// 打击感中枢：HitStop、震屏、伤害跳字、受击闪白
import { Color, Director, DrawNode, Label, Node, Vec2 } from 'Dora';
import { CameraRig } from 'game/core/CameraRig';
import { ctx } from 'game/core/GameContext';
import { withAlpha } from 'game/utils/MathUtils';

// 活动跳字
interface FloatText {
	node: Label.Type;
	life: number;
	maxLife: number;
	vy: number;
}

// 活动闪白圆
interface FlashCircle {
	node: DrawNode.Type;
	life: number;
	maxLife: number;
	radius: number;
	color: number;
}

export class Feedback {
	private cameraRig: CameraRig;
	private uiRoot: Node.Type;
	private texts: FloatText[] = [];
	private flashes: FlashCircle[] = [];
	// HitStop 剩余时长（已按 timeScale 缩放）
	private hitStopRemaining = 0;

	constructor(cameraRig: CameraRig, uiRoot?: Node.Type) {
		this.cameraRig = cameraRig;
		this.uiRoot = uiRoot !== undefined ? uiRoot : Director.entry;
		// 挂载时恢复时间缩放
		Director.scheduler.timeScale = 1;
		this.bind();
	}

	private bind(): void {
		ctx.feedback = {
			spawnDamageText: (pos, amount, crit) => this.spawnDamageText(pos, amount, crit),
			spawnFlash: (pos, color) => this.spawnFlash(pos, color),
			shake: (strength) => this.shake(strength),
			hitStop: (duration) => this.hitStop(duration),
		};
	}

	// HitStop：全局慢放后恢复
	hitStop(duration: number): void {
		if (duration <= 0) return;
		if (Director.scheduler.timeScale < 1) {
			// 已在慢放中：延长剩余时间
			this.hitStopRemaining = Math.max(this.hitStopRemaining, duration * Director.scheduler.timeScale);
			return;
		}
		Director.scheduler.timeScale = 0.05;
		this.hitStopRemaining = duration * 0.05;
	}

	// 屏幕震动
	shake(strength: number): void {
		this.cameraRig.shake(strength);
	}

	// 伤害跳字：向上飘 + 淡出
	spawnDamageText(pos: Vec2.Type, amount: number, crit: boolean): void {
		const label = Label('sarasa-mono-sc-regular', crit ? 36 : 26);
		if (label === undefined) return;
		const text = crit ? '' + Math.round(amount) : '' + Math.floor(amount);
		label.text = text;
		label.position = Vec2(pos.x + 6, pos.y + 10);
		label.color = Color(crit ? 0xffffc43d : 0xfff7eee2);
		label.addTo(this.uiRoot);
		this.texts.push({
			node: label,
			life: 0.5,
			maxLife: 0.5,
			vy: crit ? 70 : 55,
		});
	}

	// 受击闪白圆
	spawnFlash(pos: Vec2.Type, color: number): void {
		const node = DrawNode();
		node.position = Vec2(pos.x, pos.y);
		node.addTo(this.uiRoot);
		this.flashes.push({
			node,
			life: 0.12,
			maxLife: 0.12,
			radius: 14,
			color,
		});
	}

	update(dt: number): void {
		// HitStop 计时（dt 已受 timeScale 缩放）
		if (this.hitStopRemaining > 0) {
			this.hitStopRemaining -= dt;
			if (this.hitStopRemaining <= 0) {
				Director.scheduler.timeScale = 1;
			}
		}
		// 跳字
		for (let i = this.texts.length - 1; i >= 0; i--) {
			const t = this.texts[i];
			t.life -= dt;
			if (t.life <= 0) {
				t.node.removeFromParent();
				this.texts.splice(i, 1);
				continue;
			}
			const p = t.node.position;
			t.node.position = Vec2(p.x, p.y + t.vy * dt);
			t.node.opacity = t.life / t.maxLife;
		}
		// 闪白圆
		for (let i = this.flashes.length - 1; i >= 0; i--) {
			const f = this.flashes[i];
			f.life -= dt;
			if (f.life <= 0) {
				f.node.removeFromParent();
				this.flashes.splice(i, 1);
				continue;
			}
			f.node.clear();
			const t = 1 - f.life / f.maxLife;
			const alpha = (1 - t) * 255;
			const radius = f.radius * (1 - t * 0.4);
			const verts: Vec2.Type[] = [];
			for (let i2 = 0; i2 < 16; i2++) {
				const a = (i2 / 16) * Math.PI * 2;
				verts.push(Vec2(Math.cos(a) * radius, Math.sin(a) * radius));
			}
			verts.push(Vec2.zero);
			f.node.drawPolygon(verts, Color(withAlpha(f.color, Math.round(alpha))));
		}
	}

	// 清空所有活动反馈（重开/切场景）
	clear(): void {
		for (let i = this.texts.length - 1; i >= 0; i--) {
			this.texts[i].node.removeFromParent();
			this.texts.splice(i, 1);
		}
		for (let i = this.flashes.length - 1; i >= 0; i--) {
			this.flashes[i].node.removeFromParent();
			this.flashes.splice(i, 1);
		}
		Director.scheduler.timeScale = 1;
		this.hitStopRemaining = 0;
	}
}
