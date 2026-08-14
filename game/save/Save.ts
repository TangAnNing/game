// 存档系统：Content.load/save + Dora json 模块（多返回值需包装）；缺省给默认值，字段级窄化
import { Content, json } from 'Dora';
import { Config } from 'game/config/Config';
import type { CharacterId, SaveData } from 'game/core/Types';

// json.decode/encode 均返回 Lua 多返回值，包装取第一个
function decodeJson(text: string): unknown {
	const [value] = json.decode(text);
	return value;
}

function encodeJson(obj: object): string {
	const [value] = json.encode(obj);
	if (typeof value === 'string') return value;
	return '';
}

const ALL_CHARACTERS: CharacterId[] = ['swordsman', 'mage', 'druid', 'gunner', 'necromancer'];

function isValidCharacter(v: unknown): boolean {
	return (
		v === 'swordsman' || v === 'mage' || v === 'druid' || v === 'gunner' || v === 'necromancer'
	);
}

function defaultSave(): SaveData {
	return {
		version: 1,
		gold: 0,
		unlockedCharacters: ['swordsman', 'druid'],
		permanent: { damage: 0, maxHp: 0, moveSpeed: 0 },
		bestWave: 0,
		totalKills: 0,
		settings: { quality: 1, sfxVolume: 1, musicVolume: 1, muted: false },
		stats: { totalGames: 0, totalTime: 0, maxKills: 0 },
	};
}

export class SaveSystem {
	private savePath: string;
	// 简单键值存储（运行时内存，不持久化）
	private kv: Record<string, string> = {};

	constructor(path: string) {
		this.savePath = path;
	}

	load(): SaveData {
		const out = defaultSave();
		if (!Content.exist(this.savePath)) return out;
		const text = Content.load(this.savePath);
		const raw = decodeJson(text);
		if (typeof raw !== 'object' || raw === undefined) return out;
		const obj = raw as Partial<SaveData>;

		if (typeof obj.gold === 'number') out.gold = obj.gold;
		if (typeof obj.bestWave === 'number') out.bestWave = obj.bestWave;
		if (typeof obj.totalKills === 'number') out.totalKills = obj.totalKills;

		if (typeof obj.unlockedCharacters === 'object' && obj.unlockedCharacters !== undefined) {
			const src = obj.unlockedCharacters as unknown[];
			const chars: CharacterId[] = [];
			for (const c of src) {
				if (isValidCharacter(c)) chars.push(c as CharacterId);
			}
			if (chars.length > 0) out.unlockedCharacters = chars;
		}

		if (typeof obj.permanent === 'object' && obj.permanent !== undefined) {
			const p = obj.permanent as { damage?: number; maxHp?: number; moveSpeed?: number };
			out.permanent = {
				damage: typeof p.damage === 'number' ? p.damage : 0,
				maxHp: typeof p.maxHp === 'number' ? p.maxHp : 0,
				moveSpeed: typeof p.moveSpeed === 'number' ? p.moveSpeed : 0,
			};
		}

		if (typeof obj.settings === 'object' && obj.settings !== undefined) {
			const s = obj.settings as { quality?: number; sfxVolume?: number; musicVolume?: number; muted?: boolean };
			out.settings = {
				quality: typeof s.quality === 'number' ? s.quality : 1,
				sfxVolume: typeof s.sfxVolume === 'number' ? s.sfxVolume : 1,
				musicVolume: typeof s.musicVolume === 'number' ? s.musicVolume : 1,
				muted: typeof s.muted === 'boolean' ? s.muted : false,
			};
		}

		if (typeof obj.stats === 'object' && obj.stats !== undefined) {
			const st = obj.stats as { totalGames?: number; totalTime?: number; maxKills?: number };
			out.stats = {
				totalGames: typeof st.totalGames === 'number' ? st.totalGames : 0,
				totalTime: typeof st.totalTime === 'number' ? st.totalTime : 0,
				maxKills: typeof st.maxKills === 'number' ? st.maxKills : 0,
			};
		}

		// 兜底：保证初始角色始终在解锁列表
		for (const id of ALL_CHARACTERS) {
			if (id === 'swordsman' || id === 'druid') {
				if (out.unlockedCharacters.indexOf(id) < 0) out.unlockedCharacters.push(id);
			}
		}
		return out;
	}

	save(data: SaveData): void {
		Content.save(this.savePath, encodeJson(data));
	}

	hasKey(key: string): boolean {
		return key in this.kv;
	}

	setKey(key: string, value: string): void {
		this.kv[key] = value;
	}

	getKey(key: string): string | undefined {
		return this.kv[key];
	}
}

// 单例导出：各域直接 import { saveSystem } from 'game/save/Save'
export const saveSystem = new SaveSystem(Config.saveFile);
