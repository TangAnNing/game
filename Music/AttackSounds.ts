// 暗黑幻想战斗音效：短促主体、克制尾音，适合高频自动战斗。
import type { MusicDefinition } from 'Agent/Gen/Music';

export const meleeSwing: MusicDefinition = {
	output: 'Audio/sfx_sword_sweep.wav', synth: {}, seed: 2101,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'noise', role: 'drums', volume: 0.48, notes: [
			{ pitch: 'C4', start: 0, duration: 1.2, velocity: 0.9 },
			{ pitch: 'C4', start: 0.7, duration: 0.75, velocity: 0.35 },
		] },
		{ instrument: 'saw', role: 'melody', volume: 0.3, notes: [
			{ pitch: 'D3', start: 0.05, duration: 0.28, velocity: 0.9 },
			{ pitch: 'A2', start: 0.3, duration: 0.42, velocity: 0.72 },
			{ pitch: 'D2', start: 0.68, duration: 0.45, velocity: 0.45 },
		] },
	] }, audio: { volume: 0.72, stereo: false, reverb: 0.03, lowPass: 0.68 },
};

export const meleeImpact: MusicDefinition = {
	output: 'Audio/sfx_sword_impact.wav', synth: {}, seed: 2102,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'noise', role: 'drums', volume: 0.62, notes: [
			{ pitch: 'C4', start: 0, duration: 0.34, velocity: 1 },
		] },
		{ instrument: 'sub', role: 'bass', volume: 0.7, notes: [
			{ pitch: 'D2', start: 0, duration: 0.45, velocity: 1 },
			{ pitch: 'A1', start: 0.18, duration: 0.65, velocity: 0.65 },
		] },
	] }, audio: { volume: 0.82, stereo: false, reverb: 0.025, distortion: 0.12, lowPass: 0.58 },
};

export const magicCast: MusicDefinition = {
	output: 'Audio/sfx_magic_cast.wav', synth: {}, seed: 2103,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'fm', role: 'melody', volume: 0.62, notes: [
			{ pitch: 'D5', start: 0, duration: 0.25, velocity: 0.72 },
			{ pitch: 'A5', start: 0.18, duration: 0.32, velocity: 0.92 },
			{ pitch: 'D6', start: 0.43, duration: 0.5, velocity: 0.62 },
		] },
		{ instrument: 'noise', role: 'drums', volume: 0.16, notes: [
			{ pitch: 'C4', start: 0, duration: 0.65, velocity: 0.55 },
		] },
	] }, audio: { volume: 0.58, stereo: false, reverb: 0.08, delay: 0.025 },
};

export const gunShot: MusicDefinition = {
	output: 'Audio/sfx_gun_shot.wav', synth: {}, seed: 2104,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'noise', role: 'drums', volume: 0.72, notes: [
			{ pitch: 'C4', start: 0, duration: 0.2, velocity: 1 },
		] },
		{ instrument: 'pulse', role: 'melody', volume: 0.36, notes: [
			{ pitch: 'E3', start: 0, duration: 0.14, velocity: 0.95 },
			{ pitch: 'E2', start: 0.12, duration: 0.2, velocity: 0.6 },
		] },
	] }, audio: { volume: 0.62, stereo: false, reverb: 0.015, distortion: 0.18, lowPass: 0.72 },
};

export const natureSummon: MusicDefinition = {
	output: 'Audio/sfx_nature_summon.wav', synth: {}, seed: 2105,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'pluck', role: 'melody', volume: 0.58, notes: [
			{ pitch: 'D4', start: 0, duration: 0.32, velocity: 0.72 },
			{ pitch: 'A4', start: 0.3, duration: 0.36, velocity: 0.86 },
			{ pitch: 'D5', start: 0.64, duration: 0.55, velocity: 0.72 },
		] },
		{ instrument: 'pad', role: 'harmony', volume: 0.22, notes: [
			{ pitch: 'D3', start: 0, duration: 1.7, velocity: 0.6 },
			{ pitch: 'A3', start: 0.2, duration: 1.5, velocity: 0.5 },
		] },
	] }, audio: { volume: 0.55, stereo: false, reverb: 0.13, lowPass: 0.82 },
};

export const necroSummon: MusicDefinition = {
	output: 'Audio/sfx_necro_summon.wav', synth: {}, seed: 2106,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'organ', role: 'harmony', volume: 0.38, notes: [
			{ pitch: 'D2', start: 0, duration: 1.7, velocity: 0.78 },
			{ pitch: 'Ab2', start: 0.35, duration: 1.25, velocity: 0.62 },
		] },
		{ instrument: 'bell', role: 'melody', volume: 0.25, notes: [
			{ pitch: 'D5', start: 0.12, duration: 0.35, velocity: 0.7 },
			{ pitch: 'Ab4', start: 0.5, duration: 0.55, velocity: 0.6 },
		] },
	] }, audio: { volume: 0.58, stereo: false, reverb: 0.16, distortion: 0.06, lowPass: 0.62 },
};

export const familiarHit: MusicDefinition = {
	output: 'Audio/sfx_familiar_hit.wav', synth: {}, seed: 2107,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'pluck', role: 'melody', volume: 0.5, notes: [
			{ pitch: 'G4', start: 0, duration: 0.18, velocity: 0.85 },
			{ pitch: 'D4', start: 0.14, duration: 0.22, velocity: 0.55 },
		] },
		{ instrument: 'noise', role: 'drums', volume: 0.28, notes: [
			{ pitch: 'C4', start: 0, duration: 0.16, velocity: 0.75 },
		] },
	] }, audio: { volume: 0.42, stereo: false, reverb: 0.025, lowPass: 0.76 },
};

export const playerHurt: MusicDefinition = {
	output: 'Audio/sfx_player_hurt.wav', synth: {}, seed: 2108,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'noise', role: 'drums', volume: 0.46, notes: [
			{ pitch: 'C4', start: 0, duration: 0.38, velocity: 0.9 },
		] },
		{ instrument: 'saw', role: 'melody', volume: 0.38, notes: [
			{ pitch: 'C3', start: 0, duration: 0.24, velocity: 0.9 },
			{ pitch: 'F2', start: 0.2, duration: 0.5, velocity: 0.58 },
		] },
	] }, audio: { volume: 0.58, stereo: false, reverb: 0.035, distortion: 0.1, lowPass: 0.66 },
};

export const criticalHit: MusicDefinition = {
	output: 'Audio/sfx_critical.wav', synth: {}, seed: 2109,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'bell', role: 'melody', volume: 0.55, notes: [
			{ pitch: 'D6', start: 0, duration: 0.24, velocity: 1 },
			{ pitch: 'A5', start: 0.16, duration: 0.38, velocity: 0.72 },
		] },
		{ instrument: 'noise', role: 'drums', volume: 0.3, notes: [
			{ pitch: 'C4', start: 0, duration: 0.18, velocity: 0.82 },
		] },
	] }, audio: { volume: 0.52, stereo: false, reverb: 0.06 },
};

export const eliteDown: MusicDefinition = {
	output: 'Audio/sfx_elite_down.wav', synth: {}, seed: 2110,
	score: { bpm: 300, beatsPerBar: 5, bars: 1, tracks: [
		{ instrument: 'sub', role: 'bass', volume: 0.68, notes: [
			{ pitch: 'D2', start: 0, duration: 0.55, velocity: 1 },
			{ pitch: 'A1', start: 0.42, duration: 0.75, velocity: 0.75 },
		] },
		{ instrument: 'noise', role: 'drums', volume: 0.4, notes: [
			{ pitch: 'C4', start: 0, duration: 0.6, velocity: 0.85 },
		] },
	] }, audio: { volume: 0.68, stereo: false, reverb: 0.12, distortion: 0.08, lowPass: 0.52 },
};

export const combatSounds: MusicDefinition[] = [
	meleeSwing, meleeImpact, magicCast, gunShot, natureSummon,
	necroSummon, familiarHit, playerHurt, criticalHit, eliteDown,
];
