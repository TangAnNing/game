// 全局常量：性能档位、数值基线、视口
export const Quality = {
	Low: 0,
	Medium: 1,
	High: 2,
} as const;
export type QualityLevel = 0 | 1 | 2;

export const Config = {
	// 画质档位（由 DebugPanel 或设备自动设置）
	quality: Quality.High as QualityLevel,

	// 同屏实体上限（低/中/高）
	enemyCap: [120, 200, 300] as number[],
	bulletCap: [200, 400, 600] as number[],

	// 分帧：每帧更新的怪物比例（1/4）
	aiTickDivisor: 4,

	// 视野剔除：离屏余量（像素）
	cullMargin: 120,

	// 经验曲线：level -> expNeed = base * level^curve
	expBase: 12,
	expCurve: 1.5,

	// 升级三选一候选数
	levelUpChoices: 3,

	// 默认视口（运行时可从 View.size 校正）
	viewWidth: 960,
	viewHeight: 540,

	// 玩家默认数值
	playerMoveSpeed: 240,
	playerMaxHp: 100,
	playerBaseDamage: 12,
	playerAttackInterval: 0.7,

	// 拾取物
	expPickupRadius: 16,
	expMagnetRadius: 90,

	// 打击感
	hitStopNormal: 0.03,
	hitStopCrit: 0.08,
	shakeSmall: 3,
	shakeMedium: 6,
	shakeLarge: 10,

	// 存档
	saveFile: 'reaper_save.json',
	savePath: 'reaper_save.json',
};
