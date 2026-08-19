// 主控状态机：菜单→战斗→升级→暂停→结算
// 各子系统在构造时注册 ctx 回调；Game 负责生命周期编排与每帧驱动

import { Camera2D, Director, Node, Vec2 } from 'Dora';
import { ctx } from 'game/core/GameContext';
import { getCharacter } from 'game/player/Characters';
import type { CharacterId, GameMode } from 'game/core/Types';
import { Player } from 'game/player/Player';
import { WeaponSystem } from 'game/player/Weapons';
import { CameraRig } from 'game/core/CameraRig';
import { VFX } from 'game/core/VFX';
import { Feedback } from 'game/core/Feedback';
import { Scene } from 'game/scene/Scene';
import { WaveManager } from 'game/enemy/WaveManager';
import { PickupSystem } from 'game/pickup/Pickups';
import { SkillSystem } from 'game/skills/SkillSystem';
import { LevelUpSystem } from 'game/skills/LevelUp';
import { rng } from 'game/utils/RNG';
import { HUD } from 'game/ui/HUD';
import { LevelUpPanel } from 'game/ui/LevelUpPanel';
import { MainMenu } from 'game/ui/MainMenu';
import { PauseMenu } from 'game/ui/PauseMenu';
import { VirtualJoystick } from 'game/ui/VirtualJoystick';
import { inputSystem } from 'game/input/Input';
import { audio } from 'game/audio/AudioManager';
import { debugPanel } from 'game/debug/DebugPanel';
import { saveSystem } from 'game/save/Save';
import { Config } from 'game/config/Config';


// 节点层级：
//   worldRoot（世界实体 + 相机跟随区域）
//   uiRoot（HUD/面板，直接挂 Director.entry 屏幕中心坐标）
//   camera 由 CameraRig.setup 注册到 Director
export class Game {
	private worldRoot: Node.Type = Node();
	private uiRoot: Node.Type = Node();
	private logicNode: Node.Type = Node();

	// 子系统
	private cameraRig: CameraRig = new CameraRig();
	private vfx: VFX;
	private feedback: Feedback;
	private scene: Scene;
	private waveManager: WaveManager;
	private pickups: PickupSystem;
	private weaponSystem: WeaponSystem | undefined = undefined;
	private skillSystem: SkillSystem;
	private levelUp: LevelUpSystem;
	private hud: HUD;
	private levelUpPanel: LevelUpPanel;
	private mainMenu: MainMenu;
	private pauseMenu: PauseMenu;
	private joystick: VirtualJoystick;

	// 运行时状态
	private player: Player | undefined = undefined;
	private currentMode: GameMode = 'chapter';
	private elapsed = 0;
	private saveGoldReward = 0;
	private runPersisted = true;

	constructor() {
		this.worldRoot.addTo(Director.entry);
		this.uiRoot.addTo(Director.ui);

		// 相机跟随
		this.setupCamera();

		// 特效与反馈（世界/UI 分离挂载）
		this.vfx = new VFX(this.worldRoot);
		this.feedback = new Feedback(this.cameraRig, this.worldRoot);

		// 关卡场景
		this.scene = new Scene(this.worldRoot);

		// 敌人与拾取（先于玩家，保证 ctx.player 可用时回调就绪）
		this.waveManager = new WaveManager(this.worldRoot);
		this.pickups = new PickupSystem(this.worldRoot);

		// 玩家由 startRun 创建；但跨域回调（onAddExp/onPlayerDamaged）需要 Player 实例。
		// 这些回调在 Player 构造时已由 Player 自身注册到 ctx，因此此处仅创建面板，
		// 待 startRun 时构造 Player 后再接线 levelUp.onChoicesReady。
		this.skillSystem = new SkillSystem(ctx.player ?? this.dummyPlayerView(), ctx);
		this.levelUp = new LevelUpSystem(this.skillSystem, rng);
		this.hud = new HUD(this.worldRoot, this.uiRoot);
		this.levelUpPanel = new LevelUpPanel(this.uiRoot);
		this.joystick = new VirtualJoystick(this.uiRoot);
		this.joystick.setVisible(false);
		this.mainMenu = new MainMenu({ onStart: (charId, mode) => this.startRun(charId, mode) });
		this.pauseMenu = new PauseMenu({
			onResume: () => this.resumeFromPause(),
			onRestart: () => this.restartRun(),
			onQuit: () => this.quitToMenu(),
		});

		// 升级选择接线
		this.levelUp.onChoicesReady = (choices) => {
			this.joystick.setVisible(false);
			this.levelUpPanel.show(choices);
		};
		this.levelUp.onLevelUpFinished = () => {
			this.levelUpPanel.hide();
			this.joystick.setVisible(true);
		};
		// 关键接线：面板点选 → 升级系统应用技能（此前缺失导致升级无法选择）
		this.levelUpPanel.onPick = (index: number) => this.levelUp.choose(index);

		// 暂停切换
		ctx.onPauseToggle = () => this.togglePause();

		// 死亡/胜利结算
		ctx.onGameOver = () => this.onGameOver();
		ctx.onVictory = () => this.onVictory();

		// 输入系统接入虚拟摇杆
		inputSystem.attachJoystick(this.joystick);

		// 主调度（每帧驱动所有子系统）
		this.logicNode.addTo(Director.entry);
		this.logicNode.schedule((dt: number) => {
			this.update(dt);
			return false;
		});

		// 启动主菜单
		ctx.phase = 'menu';
		this.mainMenu.show();
	}

	// SkillSystem 需要 PlayerView；Player 尚未创建时用占位（后续 startRun 重建）
	private dummyPlayerView() {
		// 返回最小可用 PlayerView（仅作构造参数，实际不会被使用到核心逻辑）
		const base = {
			pos: Vec2.zero, hp: 100, maxHp: 100, level: 1, exp: 0, expNeed: 1,
			moveSpeed: 240, attackSpeed: 1, critChance: 0.1, critMulti: 1.5,
			damageBonus: 0, projectileCount: 1, pierce: 0, split: 0,
			lifesteal: 0, pickupRadius: 16, invincible: false, invincibleTimer: 0,
			regen: 0, magnet: 0, dodge: 0, bulletSpeedMulti: 1, expMulti: 1, goldMulti: 1,
			thorns: 0, chain: 0, homing: 0, ricochet: 0, explosion: 0,
			slowAura: 0, burn: 0, poison: 0, freeze: 0, skillStacks: {}, isAlive: true,
		};
		return base;
	}

	private setupCamera(): void {
		const camera = Camera2D();
		Director.pushCamera(camera);
		this.cameraRig.setup(camera, Vec2.zero);
	}

	// 每帧驱动
	private update(dt: number): void {
		audio.update(dt);
		inputSystem.update();
		debugPanel.update(dt);

		const phase = ctx.phase;
		if (phase === 'playing') {
			// 只有 playing 阶段推进战斗；升级面板会冻结世界
			this.elapsed += dt;
			ctx.stats.timeAlive = this.elapsed;

			if (ctx.player !== undefined && ctx.player.isAlive) {
				const p = this.player;
				if (p !== undefined) {
					p.update(dt, inputSystem.moveDir);
				}
				if (this.weaponSystem !== undefined) {
					this.weaponSystem.update(dt);
				}
				this.skillSystem.update(dt);
				this.waveManager.update(dt);
				this.pickups.update(dt);
				this.scene.update(dt);
			}

			// 相机跟随（即使玩家死亡也保持最后位置）
			if (this.cameraRig !== undefined && ctx.player !== undefined) {
				this.cameraRig.follow(ctx.player.pos);
			}
		}

		// 相机与反馈每帧更新
		this.cameraRig.update(dt);
		this.feedback.update(dt);
		this.vfx.update(dt);

		// HUD 每帧
		this.hud.update(dt);

		// 暂停输入切换
		if (inputSystem.pausePressed && (phase === 'playing' || phase === 'paused')) {
			this.togglePause();
		}
	}

	// ---------- 运行生命周期 ----------
	private startRun(charId: CharacterId, mode: GameMode): void {
		this.currentMode = mode;
		ctx.mode = mode;
		if (mode === 'daily') rng.setSeed(tonumber(os.date('%Y%m%d')) ?? 20260813);

		// 清理上一局
		this.cleanupRun();

		// 复位统计
		ctx.stats = {
			kills: 0, eliteKills: 0, bossKills: 0,
			damageDealt: 0, damageTaken: 0,
			wave: 0, timeAlive: 0, playerLevel: 1,
		};
		this.elapsed = 0;
		this.saveGoldReward = 0;
		this.runPersisted = false;

		// 创建玩家
		const char = getCharacter(charId);
		this.player = new Player(char, this.worldRoot);
		ctx.player = this.player;
		ctx.character = char;
		const save = saveSystem.load();
		this.player.damageBonus += Math.max(0, save.permanent.damage);
		this.player.maxHp += Math.max(0, save.permanent.maxHp);
		this.player.hp = this.player.maxHp;
		this.player.moveSpeed += Math.max(0, save.permanent.moveSpeed);
		if (save.settings !== undefined) {
			audio.setMuted(save.settings.muted);
			Config.quality = save.settings.quality <= 0 ? 0 : save.settings.quality >= 2 ? 2 : 1;
		}

		// 技能系统绑定实际玩家
		this.skillSystem = new SkillSystem(this.player, ctx);
		this.levelUp = new LevelUpSystem(this.skillSystem, rng);
		this.levelUp.onChoicesReady = (choices) => {
			this.joystick.setVisible(false);
			this.levelUpPanel.show(choices);
		};
		this.levelUp.onLevelUpFinished = () => {
			this.levelUpPanel.hide();
			this.joystick.setVisible(true);
		};

		// 武器系统
		this.weaponSystem = new WeaponSystem(this.player, this.worldRoot);

		// 波次
		this.waveManager.start(mode);
		this.waveManager.update(0); // 立即进入第一波倒计时
		this.pickups.seedArena();

		// 隐藏菜单，显示 HUD
		this.mainMenu.hide();
		this.hud.reset();
		this.levelUpPanel.hide();
		this.joystick.setVisible(true);

		// 相机复位
		this.cameraRig.snap(Vec2.zero);

		// 音频（占位：无音乐资源则静默）
		audio.playMusic('');

		ctx.phase = 'playing';
	}

	private cleanupRun(): void {
		if (this.weaponSystem !== undefined) {
			this.weaponSystem.clear();
			this.weaponSystem = undefined;
		}
		if (this.player !== undefined) {
			this.player.node.removeFromParent();
			this.player = undefined;
		}
		this.waveManager.clearAll();
		this.pickups.clearAll();
		this.skillSystem.reset();
		this.levelUp.reset();
		this.feedback.clear();
		this.levelUpPanel.hide();
		this.joystick.setVisible(false);
		this.hud.reset();
	}

	private togglePause(): void {
		if (ctx.phase === 'playing') {
			ctx.phase = 'paused';
			this.joystick.setVisible(false);
			this.pauseMenu.showPause();
		} else if (ctx.phase === 'paused') {
			this.resumeFromPause();
		}
	}

	private resumeFromPause(): void {
		if (ctx.phase === 'paused') {
			ctx.phase = 'playing';
			this.pauseMenu.hidePause();
			this.joystick.setVisible(true);
		}
	}

	private restartRun(): void {
		if (this.player === undefined) return;
		const charId = this.player.characterDef.id;
		const mode = this.currentMode;
		this.pauseMenu.hidePause();
		this.persistAfterRun();
		this.startRun(charId, mode);
	}

	private quitToMenu(): void {
		this.pauseMenu.hidePause();
		// 结算金币/统计落盘
		this.persistAfterRun();
		this.cleanupRun();
		ctx.phase = 'menu';
		this.mainMenu.show();
	}

	// 结算统计落盘（存档）
	private persistAfterRun(): void {
		if (this.runPersisted) return;
		this.runPersisted = true;
		const save = saveSystem.load();
		// 击杀统计与金币奖励
		save.totalKills += ctx.stats.kills;
		const goldMulti = this.player !== undefined ? this.player.goldMulti : 1;
		save.gold += Math.floor(this.saveGoldReward * goldMulti);
		// 最高波次（无尽）
		if (this.currentMode === 'endless' && ctx.stats.wave > save.bestWave) {
			save.bestWave = ctx.stats.wave;
		}
		if (save.stats === undefined) {
			save.stats = { totalGames: 0, totalTime: 0, maxKills: 0 };
		}
		save.stats.totalGames++;
		save.stats.totalTime += Math.floor(this.elapsed);
		if (ctx.stats.kills > save.stats.maxKills) save.stats.maxKills = ctx.stats.kills;
		if (save.totalKills >= 500 && save.unlockedCharacters.indexOf('mage') < 0) save.unlockedCharacters.push('mage');
		if (save.gold >= 300 && save.unlockedCharacters.indexOf('gunner') < 0) save.unlockedCharacters.push('gunner');
		if (save.bestWave >= 20 && save.unlockedCharacters.indexOf('necromancer') < 0) save.unlockedCharacters.push('necromancer');
		saveSystem.save(save);
	}

	private onGameOver(): void {
		if (ctx.phase === 'gameover' || ctx.phase === 'victory') return;
		ctx.phase = 'gameover';
		this.joystick.setVisible(false);
		this.saveGoldReward = Math.floor(ctx.stats.wave * 5);
		this.pauseMenu.showGameOver({
			kills: ctx.stats.kills, eliteKills: ctx.stats.eliteKills, bossKills: ctx.stats.bossKills,
			damageDealt: ctx.stats.damageDealt, damageTaken: ctx.stats.damageTaken,
			wave: ctx.stats.wave, timeAlive: Math.floor(ctx.stats.timeAlive),
			playerLevel: ctx.stats.playerLevel,
		});
		this.persistAfterRun();
	}

	private onVictory(): void {
		if (ctx.phase === 'gameover' || ctx.phase === 'victory') return;
		ctx.phase = 'victory';
		this.joystick.setVisible(false);
		this.saveGoldReward = Math.floor(ctx.stats.wave * 8);
		this.pauseMenu.showVictory({
			kills: ctx.stats.kills, eliteKills: ctx.stats.eliteKills, bossKills: ctx.stats.bossKills,
			damageDealt: ctx.stats.damageDealt, damageTaken: ctx.stats.damageTaken,
			wave: ctx.stats.wave, timeAlive: Math.floor(ctx.stats.timeAlive),
			playerLevel: ctx.stats.playerLevel,
		});
		this.persistAfterRun();
	}
}
