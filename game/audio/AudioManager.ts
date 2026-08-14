// 音频管理器：占位实现，无外部资源时静默；预留 Audio 单例接线（WAV 音效 / 流式音乐）
// 防御式：文件名空或静音时直接返回，避免对缺失资源报错
import { Audio } from 'Dora';

export class AudioManager {
	private muted = false;

	// 静音开关：直接作用于全局音量
	setMuted(muted: boolean): void {
		this.muted = muted;
		Audio.globalVolume = muted ? 0 : 1;
	}

	get isMuted(): boolean {
		return this.muted;
	}

	// 播放音效（WAV）；文件缺失/静音时静默忽略
	playSfx(name: string): void {
		if (this.muted || name.length === 0) return;
		Audio.play(name, false);
	}

	// 播放背景音乐（OGG/WAV/MP3/FLAC），循环播放
	playMusic(name: string): void {
		if (name.length === 0) return;
		if (this.muted) {
			this.stopMusic();
			return;
		}
		Audio.playStream(name, true);
	}

	// 停止背景音乐（可选淡出）
	stopMusic(fade?: number): void {
		Audio.stopStream(fade);
	}

	// 停止所有音频
	stopAll(): void {
		Audio.stopAll();
	}
}

// 单例导出：各域直接 import { audio } from 'game/audio/AudioManager'
export const audio = new AudioManager();
