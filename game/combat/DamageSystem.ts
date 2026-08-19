// 伤害结算：暴击、击退、HitStop、震屏、闪白、吸血
import { Vec2 } from 'Dora';
import { DamageInfo, DamageKind, DamageSource, EnemyView } from 'game/core/Types';
import { ctx, PlayerView } from 'game/core/GameContext';
import { Config } from 'game/config/Config';
import { rng } from 'game/utils/RNG';
import { scale } from 'game/utils/MathUtils';
import { audio, Sfx } from 'game/audio/AudioManager';

export class DamageSystem {
	// 构建伤害信息：暴击判定、属性加成、击退方向（dir 应为单位向量）
	static buildInfo(
		base: number,
		player: PlayerView,
		source: DamageSource,
		dir: Vec2.Type,
		kind: DamageKind = 'physical',
		critOverride?: boolean
	): DamageInfo {
		const crit = critOverride !== undefined ? critOverride : rng.chance(player.critChance);
		const amount = base * (1 + player.damageBonus) * (crit ? player.critMulti : 1);
		const knockPower = crit ? 150 : 90;
		return {
			amount,
			kind,
			crit,
			knockback: scale(dir, knockPower),
			hitStop: crit ? Config.hitStopCrit : Config.hitStopNormal,
			shake: crit ? Config.shakeMedium : Config.shakeSmall,
			flash: true,
			source,
		};
	}

	// 应用伤害：敌方扣血 + 战斗统计 + 吸血 + 打击感反馈
	static apply(enemy: EnemyView, info: DamageInfo): void {
		if (!enemy.isAlive || enemy.markedDead) return;
		enemy.takeDamage(info);
		ctx.stats.damageDealt += info.amount;
		// 吸血
		const player = ctx.player;
		if (player !== undefined && player.lifesteal > 0) {
			const heal = info.amount * player.lifesteal;
			if (heal > 0 && player.hp < player.maxHp) {
				player.hp = Math.min(player.maxHp, player.hp + heal);
			}
		}
		// 打击感反馈
		if (ctx.feedback !== undefined) {
			ctx.feedback.spawnDamageText(enemy.pos, info.amount, info.crit);
			if (info.flash) {
				ctx.feedback.spawnFlash(enemy.pos, 0xffffff);
			}
			if (info.hitStop > 0) {
				ctx.feedback.hitStop(info.hitStop);
			}
			if (info.shake > 0) {
				ctx.feedback.shake(info.shake);
			}
		}
		// 同帧范围命中只保留一层主体音；暴击叠加短促高频强调。
		if (info.source === 'melee') {
			audio.playSfx(Sfx.MeleeImpact, 0.07);
		}
		if (info.crit) audio.playSfx(Sfx.Critical, 0.09);
	}
}

// 便捷导出：对单个敌人结算伤害
export function damageEnemy(enemy: EnemyView, info: DamageInfo): void {
	DamageSystem.apply(enemy, info);
}
