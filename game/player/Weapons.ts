// 武器系统：按角色武器类别分派近战/远程/召唤，每 attackInterval 自动攻击
import { Node, Vec2 } from 'Dora';
import { CharacterDef } from 'game/core/Types';
import { ctx } from 'game/core/GameContext';
import { Player } from 'game/player/Player';
import { MeleeAttack } from 'game/combat/Melee';
import { Bullet, asEnemy } from 'game/combat/Bullet';
import { Summon } from 'game/combat/Summon';
import { dirTo } from 'game/utils/MathUtils';
import { rng } from 'game/utils/RNG';
import { audio, Sfx } from 'game/audio/AudioManager';

export class WeaponSystem {
	private player: Player;
	private root: Node.Type;
	private timer = 0;
	private melees: MeleeAttack[] = [];
	private bullets: Bullet[] = [];
	private summons: Summon[] = [];

	constructor(player: Player, root: Node.Type) {
		this.player = player;
		this.root = root;
	}

	// 每帧更新：冷却计时 + 攻击 + 推进活动实体
	update(dt: number): void {
		const player = this.player;
		if (!player.isAlive) {
			return;
		}
		const character = player.characterDef;
		const interval = Math.max(0.1, character.attackInterval / player.attackSpeed);
		this.timer -= dt;
		if (this.timer <= 0) {
			this.timer = interval;
			this.attack(character);
		}
		// 近战攻击推进
		for (let i = this.melees.length - 1; i >= 0; i--) {
			this.melees[i].update(dt);
			if (this.melees[i].isDone) {
				this.melees.splice(i, 1);
			}
		}
		// 子弹推进
		for (let i = this.bullets.length - 1; i >= 0; i--) {
			this.bullets[i].update(dt, player);
			if (!this.bullets[i].isActive) {
				this.bullets.splice(i, 1);
			}
		}
		// 召唤物推进
		for (let i = this.summons.length - 1; i >= 0; i--) {
			this.summons[i].update(dt);
			if (!this.summons[i].active) {
				this.summons.splice(i, 1);
			}
		}
		// 召唤物补员
		if (character.weaponClass === 'summon') {
			this.refillSummons(character);
		}
	}

	// 一次攻击
	private attack(character: CharacterDef): void {
		const player = this.player;
		const baseDamage = character.baseDamage;
		switch (character.weaponClass) {
			case 'melee': {
				// 重剑环身横扫：半角 PI 表示完整 360° 范围。
				const halfAngle = Math.PI;
				this.melees.push(
					new MeleeAttack(
						player.pos,
						player.facing,
						character.range,
						halfAngle,
						baseDamage,
						player,
						character.color,
						this.root
					)
				);
				audio.playSfx(Sfx.MeleeSwing, 0.12);
				break;
			}
			case 'ranged': {
				let count = Math.max(1, player.projectileCount);
				const doubleCastLevel = player.skillStacks['doubleCast'] ?? 0;
				if (doubleCastLevel > 0 && rng.chance(Math.min(0.75, doubleCastLevel * 0.2))) count++;
				const aim = this.aimDir(character.range);
				const baseAngle = Math.atan2(aim.y, aim.x);
				const spread = count > 1 ? 0.16 : 0;
				for (let i = 0; i < count; i++) {
					const offset = (i - (count - 1) / 2) * spread;
					const a = baseAngle + offset;
					const speed = character.speed * player.bulletSpeedMulti;
					const vel = Vec2(Math.cos(a) * speed, Math.sin(a) * speed);
					const b = Bullet.spawn(
						this.root,
						player.pos,
						vel,
						baseDamage,
						character.range,
						5,
						player.pierce,
						player.split,
						player.ricochet,
						character.color,
						(nb) => this.addBullet(nb)
					);
					if (this.bullets.length < 600) this.bullets.push(b);
					else b.recycle();
				}
				audio.playSfx(character.id === 'gunner' ? Sfx.GunShot : Sfx.MagicCast, 0.06);
				ctx.vfx?.flash(player.pos, character.color, 8);
				break;
			}
			case 'summon': {
				if (this.spawnSummon(character)) {
					audio.playSfx(character.id === 'druid' ? Sfx.NatureSummon : Sfx.NecroSummon, 0.18);
				}
				break;
			}
		}
	}

	// 索敌瞄准：最近敌人优先，否则朝玩家 facing
	private aimDir(range: number): Vec2.Type {
		const candidates = ctx.findEnemiesNear !== undefined
			? ctx.findEnemiesNear(this.player.pos, range, 1)
			: [];
		if (candidates.length > 0) {
			const e = asEnemy(candidates[0]);
			if (e !== undefined && e.isAlive) {
				return dirTo(this.player.pos, e.pos);
			}
		}
		return Vec2(Math.cos(this.player.facing), Math.sin(this.player.facing));
	}

	// 生成一个召唤物
	private spawnSummon(character: CharacterDef): boolean {
		const player = this.player;
		const maxSummon = Math.max(1, character.projectileCount);
		const extra = player.skillStacks['summonCount'] !== undefined ? player.skillStacks['summonCount'] : 0;
		if (this.summons.length >= maxSummon + extra) return false;
		const angle = rng.range(0, Math.PI * 2);
		const radius = rng.range(50, 80);
		const pos = Vec2(player.pos.x + Math.cos(angle) * radius, player.pos.y + Math.sin(angle) * radius);
		const s = Summon.spawn(
			this.root,
			player,
			pos,
			character.color,
			character.baseDamage,
			Math.max(0.4, character.attackInterval * 0.85),
			13,
			42,
			Math.max(150, character.speed * 0.6),
			angle
		);
		this.summons.push(s);
		return true;
	}

	// 召唤物补员（死亡/消失后下次冷却补齐）
	private refillSummons(character: CharacterDef): void {
		const maxSummon = Math.max(1, character.projectileCount);
		const extra = this.player.skillStacks['summonCount'] !== undefined ? this.player.skillStacks['summonCount'] : 0;
		if (this.summons.length < maxSummon + extra) {
			this.spawnSummon(character);
		}
	}

	// 分裂子弹接入（Bullet 回调）
	addBullet(b: Bullet): void {
		this.bullets.push(b);
	}

	// 技能变化后刷新（立即执行一次攻击以便观察效果）
	onSkillChanged(): void {
		this.timer = 0;
	}

	// 清空所有活动实体（重开/结算）
	clear(): void {
		for (let i = this.melees.length - 1; i >= 0; i--) {
			this.melees[i].dispose();
			this.melees.splice(i, 1);
		}
		for (let i = this.bullets.length - 1; i >= 0; i--) {
			this.bullets[i].recycle();
			this.bullets.splice(i, 1);
		}
		for (let i = this.summons.length - 1; i >= 0; i--) {
			this.summons[i].recycle();
			this.summons.splice(i, 1);
		}
	}
}
