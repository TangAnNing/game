// 音频管理器：统一音效路径、静音状态与并发节流。
import { Audio } from 'Dora';

export const Sfx = {
	MeleeSwing: 'Audio/sfx_sword_sweep.wav',
	MeleeImpact: 'Audio/sfx_sword_impact.wav',
	MagicCast: 'Audio/sfx_magic_cast.wav',
	GunShot: 'Audio/sfx_gun_shot.wav',
	NatureSummon: 'Audio/sfx_nature_summon.wav',
	NecroSummon: 'Audio/sfx_necro_summon.wav',
	SummonImpact: 'Audio/sfx_familiar_hit.wav',
	PlayerHurt: 'Audio/sfx_player_hurt.wav',
	Critical: 'Audio/sfx_critical.wav',
	EliteDown: 'Audio/sfx_elite_down.wav',
} as const;

export class AudioManager {
	private muted = false;
	private cooldowns: Record<string, number> = {};

	// 静音开关：直接作用于全局音量
	setMuted(muted: boolean): void {
		this.muted = muted;
		Audio.globalVolume = muted ? 0 : 1;
	}

	get isMuted(): boolean {
		return this.muted;
	}

	// cooldown 会合并同帧的大量重复命中，避免声音叠加失真。
	playSfx(name: string, cooldown = 0): boolean {
		if (this.muted || name.length === 0) return false;
		if ((this.cooldowns[name] ?? 0) > 0) return false;
		Audio.play(name, false);
		if (cooldown > 0) this.cooldowns[name] = cooldown;
		return true;
	}

	update(dt: number): void {
		for (const name in this.cooldowns) {
			const next = this.cooldowns[name] - dt;
			this.cooldowns[name] = next > 0 ? next : 0;
		}
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
		this.cooldowns = {};
	}
}

// 单例导出：各域直接 import { audio } from 'game/audio/AudioManager'
export const audio = new AudioManager();
