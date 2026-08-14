// 输入系统：键盘(WASD+方向键)/手柄左摇杆/虚拟摇杆 合成移动方向；Esc/Start 暂停触发；攻击按住状态
import { KeyName, Keyboard, ButtonName, AxisName, Controller, Vec2 } from 'Dora';
import type { VirtualJoystick } from 'game/ui/VirtualJoystick';

export class InputSystem {
	private joystick: VirtualJoystick | undefined = undefined;
	private _moveDir: Vec2.Type = Vec2(0, 0);
	private _pausePressed = false;
	private _attackHeld = false;

	// 设置虚拟摇杆引用（主控在创建后调用）
	attachJoystick(j: VirtualJoystick): void {
		this.joystick = j;
	}

	get moveDir(): Vec2.Type {
		return this._moveDir;
	}

	get pausePressed(): boolean {
		return this._pausePressed;
	}

	get isAttackHeld(): boolean {
		return this._attackHeld;
	}

	// 每帧轮询（主控 update 循环调用）
	update(): void {
		this._pausePressed = false;

		let dx = 0;
		let dy = 0;

		// 键盘 WASD + 方向键（isKeyPressed 为按住状态）
		if (Keyboard.isKeyPressed(KeyName.W) || Keyboard.isKeyPressed(KeyName.Up)) dy += 1;
		if (Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down)) dy -= 1;
		if (Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left)) dx -= 1;
		if (Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right)) dx += 1;

		// 手柄左摇杆
		const ax = Controller.getAxis(0, AxisName.LeftX);
		const ay = Controller.getAxis(0, AxisName.LeftY);
		if (Math.abs(ax) > 0.15 || Math.abs(ay) > 0.15) {
			dx += ax;
			dy += ay;
		}

		// 虚拟摇杆（移动端触控）
		if (this.joystick !== undefined && this.joystick.isVisible) {
			const jv = this.joystick.moveDir;
			dx += jv.x;
			dy += jv.y;
		}

		// 归一化（保留手柄/摇杆的幅度缩放）
		const len = Math.sqrt(dx * dx + dy * dy);
		if (len > 1) {
			dx /= len;
			dy /= len;
		}
		this._moveDir = Vec2(dx, dy);

		// 暂停：Esc 或手柄 Start 一帧触发
		if (Keyboard.isKeyDown(KeyName.Escape) || Controller.isButtonDown(0, ButtonName.Start)) {
			this._pausePressed = true;
		}

		// 攻击按住：空格/手柄 X（占位，攻击时机由战斗域决定）
		this._attackHeld =
			Keyboard.isKeyPressed(KeyName.Space) || Controller.isButtonDown(0, ButtonName.X);
	}
}

// 单例导出：主控创建后调用 inputSystem.update()
export const inputSystem = new InputSystem();
