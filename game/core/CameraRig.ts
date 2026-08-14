// 相机跟随 + 屏幕震动
import { Camera2D, Vec2 } from 'Dora';
import { damp } from 'game/utils/MathUtils';
import { rng } from 'game/utils/RNG';

export class CameraRig {
	private camera: Camera2D.Type | undefined = undefined;
	private target: Vec2.Type = Vec2.zero;
	private current: Vec2.Type = Vec2.zero;
	private shakeStrength = 0;
	private shakeOffset: Vec2.Type = Vec2.zero;
	private followLambda = 8;

	// 初始化相机与初始位置
	setup(camera: Camera2D.Type, initialPos?: Vec2.Type): void {
		this.camera = camera;
		const start = initialPos !== undefined ? initialPos : Vec2.zero;
		this.target = start;
		this.current = start;
		this.shakeStrength = 0;
		this.shakeOffset = Vec2.zero;
		camera.position = Vec2(start.x, start.y);
	}

	// 设置跟随平滑系数（越大越紧）
	setFollowLambda(lambda: number): void {
		this.followLambda = lambda;
	}

	// 平滑跟随目标
	follow(pos: Vec2.Type): void {
		this.target = pos;
	}

	// 立即跳到目标位置
	snap(pos: Vec2.Type): void {
		this.target = pos;
		this.current = pos;
		if (this.camera !== undefined) {
			this.camera.position = Vec2(pos.x, pos.y);
		}
	}

	// 添加震屏强度（像素）
	shake(strength: number): void {
		this.shakeStrength = Math.max(this.shakeStrength, strength);
	}

	// 每帧更新：阻尼跟随 + 震屏衰减
	update(dt: number): void {
		this.current = Vec2(
			damp(this.current.x, this.target.x, this.followLambda, dt),
			damp(this.current.y, this.target.y, this.followLambda, dt)
		);
		// 震屏衰减（每秒衰减到 ~10%）
		this.shakeStrength *= Math.exp(-6 * dt);
		if (this.shakeStrength < 0.05) {
			this.shakeStrength = 0;
		}
		let ox = 0;
		let oy = 0;
		if (this.shakeStrength > 0) {
			ox = rng.range(-1, 1) * this.shakeStrength;
			oy = rng.range(-1, 1) * this.shakeStrength;
			this.shakeOffset = Vec2(ox, oy);
		} else {
			this.shakeOffset = Vec2.zero;
		}
		if (this.camera !== undefined) {
			this.camera.position = Vec2(this.current.x + ox, this.current.y + oy);
		}
	}

	get position(): Vec2.Type {
		return this.current;
	}
}
