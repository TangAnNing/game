// 调试面板：ImGui 显示 FPS/击杀/波次/等级/相位；F3 切换
// Director 无 averageFPS，FPS 用平滑 1/dt 自算
import * as ImGui from 'ImGui';
import { KeyName, Keyboard } from 'Dora';
import { ctx } from 'game/core/GameContext';

export class DebugPanel {
	private visible = false;
	// FPS 平滑统计
	private fpsAccum = 0;
	private fpsFrames = 0;
	private fps = 0;

	toggle(): void {
		this.visible = !this.visible;
	}

	get isVisible(): boolean {
		return this.visible;
	}

	// 每帧调用：F3 开关 + 刷新面板内容
	update(dt: number): void {
		// FPS 统计（每 0.5s 更新一次平滑值）
		this.fpsAccum += dt;
		this.fpsFrames++;
		if (this.fpsAccum >= 0.5) {
			this.fps = this.fpsFrames / this.fpsAccum;
			this.fpsAccum = 0;
			this.fpsFrames = 0;
		}

		if (Keyboard.isKeyDown(KeyName.F3)) this.toggle();
		if (!this.visible) return;

		ImGui.Begin('调试', () => {
			ImGui.Text(`FPS: ${Math.floor(this.fps)}`);
			ImGui.Text(`相位: ${ctx.phase}`);
			ImGui.Text(`击杀: ${ctx.stats.kills}`);
			ImGui.Text(`精英击杀: ${ctx.stats.eliteKills}`);
			ImGui.Text(`Boss 击杀: ${ctx.stats.bossKills}`);
			ImGui.Text(`波次: ${ctx.stats.wave}`);
			ImGui.Text(`等级: ${ctx.stats.playerLevel}`);
			ImGui.Text(`存活: ${Math.floor(ctx.stats.timeAlive)}s`);
			const p = ctx.player;
			if (p !== undefined) {
				ImGui.Text(`HP: ${Math.floor(p.hp)}/${Math.floor(p.maxHp)}`);
				ImGui.Text(`位置: (${Math.floor(p.pos.x)}, ${Math.floor(p.pos.y)})`);
			}
		});
	}
}

// 单例导出：主控在 update 循环中调用 debugPanel.update(dt)
export const debugPanel = new DebugPanel();
