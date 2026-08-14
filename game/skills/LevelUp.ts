// 升级三选一系统：玩家域触发 ctx.onPlayerLevelUp → 生成候选 → 面板展示 → 选择应用
import type { CharacterId, SkillDef, SkillId } from 'game/core/Types';
import { ctx } from 'game/core/GameContext';
import { Config } from 'game/config/Config';
import { getSkillDef, poolForCharacter } from 'game/skills/SkillDefs';
import type { SkillSystem } from 'game/skills/SkillSystem';
import type { RNG } from 'game/utils/RNG';

export class LevelUpSystem {
	private skillSystem: SkillSystem;
	private rng: RNG;
	private currentChoices: SkillId[] = [];
	private pendingLevels = 0;
	// UI 面板订阅：候选生成后回调（传 SkillDef[] 便于直接渲染）
	onChoicesReady?: (choices: SkillDef[]) => void;
	// 主控 Game.ts 订阅：三选一完成后通知恢复 phase='playing'
	onLevelUpFinished?: () => void;

	constructor(skillSystem: SkillSystem, rng: RNG) {
		this.skillSystem = skillSystem;
		this.rng = rng;
		// 玩家域在 Player.addExp 升级时调用 ctx.onPlayerLevelUp，这里接线
		ctx.onPlayerLevelUp = (): void => this.beginLevelUp();
	}

	// 当前候选技能定义（供面板查询）
	get choices(): SkillDef[] {
		return this.currentChoices.map((id) => getSkillDef(id));
	}

	// 从角色候选池抽取 Config.levelUpChoices 个未满级技能
	offerChoices(characterId: CharacterId): SkillId[] {
		const pool = poolForCharacter(characterId, this.rng);
		const result: SkillId[] = [];
		for (let i = 0; i < pool.length && result.length < Config.levelUpChoices; i++) {
			const id = pool[i];
			if (this.skillSystem.getLevel(id) < getSkillDef(id).maxStack) {
				result.push(id);
			}
		}
		return result;
	}

	// 进入升级选择：生成三选一 → 切 phase → 通知面板
	beginLevelUp(): void {
		if (ctx.phase === 'levelup') {
			this.pendingLevels++;
			return;
		}
		const charId = ctx.character?.id;
		if (charId === undefined) {
			// 角色未设置时无法选池，直接结束避免卡死
			this.finishLevelUp();
			return;
		}
		this.currentChoices = this.offerChoices(charId);
		ctx.phase = 'levelup';
		this.onChoicesReady?.(this.currentChoices.map((id) => getSkillDef(id)));
	}

	// 选择第 index 项：应用技能 → 恢复游玩
	choose(index: number): void {
		const id = this.currentChoices[index];
		if (id === undefined) return;
		this.skillSystem.applySkill(id);
		this.finishLevelUp();
	}

	// 结束升级选择：恢复游玩阶段（主控可经 onLevelUpFinished 再接线）
	finishLevelUp(): void {
		this.currentChoices = [];
		if (this.pendingLevels > 0) {
			this.pendingLevels--;
			ctx.phase = 'playing';
			this.beginLevelUp();
			return;
		}
		ctx.phase = 'playing';
		this.onLevelUpFinished?.();
	}

	// 新对局重置
	reset(): void {
		this.currentChoices = [];
		this.pendingLevels = 0;
	}
}
