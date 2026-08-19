-- [ts]: AttackSounds.ts
local ____exports = {} -- 1
____exports.meleeSwing = { -- 4
	output = "Audio/sfx_sword_sweep.wav", -- 5
	synth = {}, -- 5
	seed = 2101, -- 5
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "noise", role = "drums", volume = 0.48, notes = {{pitch = "C4", start = 0, duration = 1.2, velocity = 0.9}, {pitch = "C4", start = 0.7, duration = 0.75, velocity = 0.35}}}, {instrument = "saw", role = "melody", volume = 0.3, notes = {{pitch = "D3", start = 0.05, duration = 0.28, velocity = 0.9}, {pitch = "A2", start = 0.3, duration = 0.42, velocity = 0.72}, {pitch = "D2", start = 0.68, duration = 0.45, velocity = 0.45}}}}}, -- 6
	audio = {volume = 0.72, stereo = false, reverb = 0.03, lowPass = 0.68} -- 16
} -- 16
____exports.meleeImpact = { -- 19
	output = "Audio/sfx_sword_impact.wav", -- 20
	synth = {}, -- 20
	seed = 2102, -- 20
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "noise", role = "drums", volume = 0.62, notes = {{pitch = "C4", start = 0, duration = 0.34, velocity = 1}}}, {instrument = "sub", role = "bass", volume = 0.7, notes = {{pitch = "D2", start = 0, duration = 0.45, velocity = 1}, {pitch = "A1", start = 0.18, duration = 0.65, velocity = 0.65}}}}}, -- 21
	audio = { -- 29
		volume = 0.82, -- 29
		stereo = false, -- 29
		reverb = 0.025, -- 29
		distortion = 0.12, -- 29
		lowPass = 0.58 -- 29
	} -- 29
} -- 29
____exports.magicCast = { -- 32
	output = "Audio/sfx_magic_cast.wav", -- 33
	synth = {}, -- 33
	seed = 2103, -- 33
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "fm", role = "melody", volume = 0.62, notes = {{pitch = "D5", start = 0, duration = 0.25, velocity = 0.72}, {pitch = "A5", start = 0.18, duration = 0.32, velocity = 0.92}, {pitch = "D6", start = 0.43, duration = 0.5, velocity = 0.62}}}, {instrument = "noise", role = "drums", volume = 0.16, notes = {{pitch = "C4", start = 0, duration = 0.65, velocity = 0.55}}}}}, -- 34
	audio = {volume = 0.58, stereo = false, reverb = 0.08, delay = 0.025} -- 43
} -- 43
____exports.gunShot = { -- 46
	output = "Audio/sfx_gun_shot.wav", -- 47
	synth = {}, -- 47
	seed = 2104, -- 47
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "noise", role = "drums", volume = 0.72, notes = {{pitch = "C4", start = 0, duration = 0.2, velocity = 1}}}, {instrument = "pulse", role = "melody", volume = 0.36, notes = {{pitch = "E3", start = 0, duration = 0.14, velocity = 0.95}, {pitch = "E2", start = 0.12, duration = 0.2, velocity = 0.6}}}}}, -- 48
	audio = { -- 56
		volume = 0.62, -- 56
		stereo = false, -- 56
		reverb = 0.015, -- 56
		distortion = 0.18, -- 56
		lowPass = 0.72 -- 56
	} -- 56
} -- 56
____exports.natureSummon = { -- 59
	output = "Audio/sfx_nature_summon.wav", -- 60
	synth = {}, -- 60
	seed = 2105, -- 60
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "pluck", role = "melody", volume = 0.58, notes = {{pitch = "D4", start = 0, duration = 0.32, velocity = 0.72}, {pitch = "A4", start = 0.3, duration = 0.36, velocity = 0.86}, {pitch = "D5", start = 0.64, duration = 0.55, velocity = 0.72}}}, {instrument = "pad", role = "harmony", volume = 0.22, notes = {{pitch = "D3", start = 0, duration = 1.7, velocity = 0.6}, {pitch = "A3", start = 0.2, duration = 1.5, velocity = 0.5}}}}}, -- 61
	audio = {volume = 0.55, stereo = false, reverb = 0.13, lowPass = 0.82} -- 71
} -- 71
____exports.necroSummon = { -- 74
	output = "Audio/sfx_necro_summon.wav", -- 75
	synth = {}, -- 75
	seed = 2106, -- 75
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "organ", role = "harmony", volume = 0.38, notes = {{pitch = "D2", start = 0, duration = 1.7, velocity = 0.78}, {pitch = "Ab2", start = 0.35, duration = 1.25, velocity = 0.62}}}, {instrument = "bell", role = "melody", volume = 0.25, notes = {{pitch = "D5", start = 0.12, duration = 0.35, velocity = 0.7}, {pitch = "Ab4", start = 0.5, duration = 0.55, velocity = 0.6}}}}}, -- 76
	audio = { -- 85
		volume = 0.58, -- 85
		stereo = false, -- 85
		reverb = 0.16, -- 85
		distortion = 0.06, -- 85
		lowPass = 0.62 -- 85
	} -- 85
} -- 85
____exports.familiarHit = { -- 88
	output = "Audio/sfx_familiar_hit.wav", -- 89
	synth = {}, -- 89
	seed = 2107, -- 89
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "pluck", role = "melody", volume = 0.5, notes = {{pitch = "G4", start = 0, duration = 0.18, velocity = 0.85}, {pitch = "D4", start = 0.14, duration = 0.22, velocity = 0.55}}}, {instrument = "noise", role = "drums", volume = 0.28, notes = {{pitch = "C4", start = 0, duration = 0.16, velocity = 0.75}}}}}, -- 90
	audio = {volume = 0.42, stereo = false, reverb = 0.025, lowPass = 0.76} -- 98
} -- 98
____exports.playerHurt = { -- 101
	output = "Audio/sfx_player_hurt.wav", -- 102
	synth = {}, -- 102
	seed = 2108, -- 102
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "noise", role = "drums", volume = 0.46, notes = {{pitch = "C4", start = 0, duration = 0.38, velocity = 0.9}}}, {instrument = "saw", role = "melody", volume = 0.38, notes = {{pitch = "C3", start = 0, duration = 0.24, velocity = 0.9}, {pitch = "F2", start = 0.2, duration = 0.5, velocity = 0.58}}}}}, -- 103
	audio = { -- 111
		volume = 0.58, -- 111
		stereo = false, -- 111
		reverb = 0.035, -- 111
		distortion = 0.1, -- 111
		lowPass = 0.66 -- 111
	} -- 111
} -- 111
____exports.criticalHit = { -- 114
	output = "Audio/sfx_critical.wav", -- 115
	synth = {}, -- 115
	seed = 2109, -- 115
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "bell", role = "melody", volume = 0.55, notes = {{pitch = "D6", start = 0, duration = 0.24, velocity = 1}, {pitch = "A5", start = 0.16, duration = 0.38, velocity = 0.72}}}, {instrument = "noise", role = "drums", volume = 0.3, notes = {{pitch = "C4", start = 0, duration = 0.18, velocity = 0.82}}}}}, -- 116
	audio = {volume = 0.52, stereo = false, reverb = 0.06} -- 124
} -- 124
____exports.eliteDown = { -- 127
	output = "Audio/sfx_elite_down.wav", -- 128
	synth = {}, -- 128
	seed = 2110, -- 128
	score = {bpm = 300, beatsPerBar = 5, bars = 1, tracks = {{instrument = "sub", role = "bass", volume = 0.68, notes = {{pitch = "D2", start = 0, duration = 0.55, velocity = 1}, {pitch = "A1", start = 0.42, duration = 0.75, velocity = 0.75}}}, {instrument = "noise", role = "drums", volume = 0.4, notes = {{pitch = "C4", start = 0, duration = 0.6, velocity = 0.85}}}}}, -- 129
	audio = { -- 137
		volume = 0.68, -- 137
		stereo = false, -- 137
		reverb = 0.12, -- 137
		distortion = 0.08, -- 137
		lowPass = 0.52 -- 137
	} -- 137
} -- 137
____exports.combatSounds = { -- 140
	____exports.meleeSwing, -- 140
	____exports.meleeImpact, -- 140
	____exports.magicCast, -- 140
	____exports.gunShot, -- 140
	____exports.natureSummon, -- 140
	____exports.necroSummon, -- 140
	____exports.familiarHit, -- 140
	____exports.playerHurt, -- 140
	____exports.criticalHit, -- 140
	____exports.eliteDown -- 140
} -- 140
return ____exports -- 140