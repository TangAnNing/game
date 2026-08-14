// 玩家实体：移动、生命、经验升级、属性面板
// 攻击由 Weapons 驱动，Player 只维护自身状态与视觉
import { Color, Director, DrawNode, Label, Node, Vec2 } from 'Dora';
import { CharacterDef } from 'game/core/Types';
import { ctx, PlayerView } from 'game/core/GameContext';
import { Config } from 'game/config/Config';
import { clamp, normalize, withAlpha } from 'game/utils/MathUtils';
import { rng } from 'game/utils/RNG';

export class Player implements PlayerView {
	// ---- 属性（PlayerView 契约）----
	hp = 100;
	maxHp = 100;
	level = 1;
	exp = 0;
	expNeed = 1;
	moveSpeed = 240;
	attackSpeed = 1;
	critChance = 0.1;
	critMulti = 1.5;
	damageBonus = 0;
	projectileCount = 1;
	pierce = 0;
	split = 0;
	lifesteal = 0;
	pickupRadius = 0;
	invincible = false;
	invincibleTimer = 0;
	regen = 0;
	magnet = 0;
	isAlive = true;
	// PlayerView 扩展属性（技能系统读写）
	dodge = 0;
	bulletSpeedMulti = 1;
	expMulti = 1;
	goldMulti = 1;
	thorns = 0;
	chain = 0;
	homing = 0;
	ricochet = 0;
	explosion = 0;
	slowAura = 0;
	burn = 0;
	poison = 0;
	freeze = 0;

	// 朝向角（武器攻击方向），弧度
	facing = 0;
	// 技能层数记录（供武器/成长域查询）
	skillStacks: Record<string, number> = {};

	private character: CharacterDef;
	private posValue: Vec2.Type = Vec2.zero;
	private nodeValue: Node.Type = Node();
	private body: DrawNode.Type = DrawNode();
	private nameLabel: Label.Type | undefined = undefined;
	private radius = 16;

	constructor(character: CharacterDef, root?: Node.Type) {
		this.character = character;
		const parent = root !== undefined ? root : Director.entry;
		this.nodeValue.addTo(parent);
		this.body.addTo(this.nodeValue);
		const label = Label('sarasa-mono-sc-regular', 12);
		if (label !== undefined) {
			label.text = character.name;
			label.anchor = Vec2(0.5, 0.5);
			label.position = Vec2(0, this.radius + 14);
			label.addTo(this.nodeValue);
			this.nameLabel = label;
		}
		// 注册到 ctx
		ctx.player = this;
		// 核心回调：拾取经验→addExp（升级）；受击伤害（EnemyAI 子弹）
		ctx.onAddExp = (amount: number, _pos: Vec2.Type): void => this.addExp(amount);
		ctx.onPlayerDamaged = (amount: number, from: Vec2.Type): void => this.takeDamage(amount, from);
		this.resetForNewGame();
	}

	// 新一局重置
	resetForNewGame(): void {
		this.maxHp = this.character.maxHp;
		this.hp = this.maxHp;
		this.level = 1;
		this.exp = 0;
		this.expNeed = this.calcExpNeed(1);
		this.moveSpeed = this.character.moveSpeed;
		this.attackSpeed = 1;
		this.critChance = 0.1;
		this.critMulti = 1.5;
		this.damageBonus = 0;
		this.projectileCount = this.character.projectileCount;
		this.pierce = this.character.pierce;
		this.split = 0;
		this.lifesteal = 0;
		this.pickupRadius = Config.expPickupRadius;
		this.invincible = false;
		this.invincibleTimer = 0;
		this.regen = 0;
		this.magnet = 0;
		this.isAlive = true;
		this.dodge = 0;
		this.bulletSpeedMulti = 1;
		this.expMulti = 1;
		this.goldMulti = 1;
		this.thorns = 0;
		this.chain = 0;
		this.homing = 0;
		this.ricochet = 0;
		this.explosion = 0;
		this.slowAura = 0;
		this.burn = 0;
		this.poison = 0;
		this.freeze = 0;
		this.facing = 0;
		this.posValue = Vec2.zero;
		this.skillStacks = {};
		this.nodeValue.position = Vec2.zero;
		this.nodeValue.visible = true;
		this.redrawBody();
	}

	// 场景边界（与 Scene 的 2000x2000 世界保持一致）
	private get halfW(): number {
		return 1000 - 24;
	}
	private get halfH(): number {
		return 1000 - 24;
	}

	// 每帧更新：移动、无敌计时、回血、磁吸
	update(dt: number, inputDir: Vec2.Type): void {
		if (!this.isAlive) return;
		// 移动
		if (inputDir.length > 0.01) {
			const dir = normalize(inputDir);
			this.posValue = Vec2(
				this.posValue.x + dir.x * this.moveSpeed * dt,
				this.posValue.y + dir.y * this.moveSpeed * dt
			);
			this.facing = Math.atan2(dir.y, dir.x);
		}
		// 边界 clamp
		this.posValue = Vec2(
			clamp(this.posValue.x, -this.halfW, this.halfW),
			clamp(this.posValue.y, -this.halfH, this.halfH)
		);
		// 无敌计时
		if (this.invincibleTimer > 0) {
			this.invincibleTimer -= dt;
			if (this.invincibleTimer <= 0) {
				this.invincibleTimer = 0;
				this.invincible = false;
			}
		}
		// 回血
		if (this.regen > 0 && this.hp < this.maxHp) {
			this.hp = Math.min(this.maxHp, this.hp + this.regen * dt);
		}
		// 拾取磁吸
		if (ctx.magnetPickups !== undefined) {
			ctx.magnetPickups(this.posValue, this.pickupRadius + this.magnet);
		}
		// 视觉同步
		this.nodeValue.position = Vec2(this.posValue.x, this.posValue.y);
		this.redrawBody();
	}

	// 获得经验并处理升级
	addExp(amount: number): void {
		if (!this.isAlive) return;
		this.exp += amount * this.expMulti;
		while (this.exp >= this.expNeed) {
			this.exp -= this.expNeed;
			this.level += 1;
			this.expNeed = this.calcExpNeed(this.level);
			ctx.stats.playerLevel = this.level;
			ctx.onPlayerLevelUp?.();
		}
	}

	// 受到伤害
	takeDamage(amount: number, from: Vec2.Type): void {
		if (!this.isAlive || this.invincible) return;
		if (this.dodge > 0 && rng.chance(Math.min(0.75, this.dodge))) {
			ctx.vfx?.flash(this.posValue, 0x80d8ff, 22);
			return;
		}
		this.hp -= amount;
		ctx.stats.damageTaken += amount;
		if (this.thorns > 0) {
			ctx.damageEnemiesInRadius?.(from, 42, {
				amount: amount * this.thorns,
				kind: 'physical',
				crit: false,
				knockback: Vec2.zero,
				hitStop: 0,
				shake: 0,
				flash: true,
				source: 'skill',
			});
		}
		// 受伤反馈
		if (ctx.feedback !== undefined) {
			ctx.feedback.spawnFlash(this.posValue, 0xffffff);
			ctx.feedback.shake(Config.shakeMedium);
			ctx.feedback.hitStop(0.02);
		}
		if (this.hp <= 0) {
			this.hp = 0;
			this.isAlive = false;
			this.nodeValue.visible = false;
			ctx.onGameOver?.();
		} else {
			this.invincible = true;
			this.invincibleTimer = this.skillStacks['invincible'] !== undefined ? 1 : 0.45;
		}
	}

	// 治疗
	heal(amount: number): void {
		if (!this.isAlive) return;
		this.hp = Math.min(this.maxHp, this.hp + amount);
	}

	private calcExpNeed(level: number): number {
		return Math.floor(Config.expBase * Math.pow(level, Config.expCurve));
	}

	// 重绘身体：圆 + 朝向线
	private redrawBody(): void {
		this.body.clear();
		const color = Color(0xff000000 | this.character.color);
		const outline = Color(withAlpha(0xf6ead3, 225));
		const dark = Color(20, 28, 31, 255);
		const forward = Vec2(Math.cos(this.facing), Math.sin(this.facing));
		const side = Vec2(-forward.y, forward.x);
		// 地面投影与外轮廓。
		this.body.drawDot(Vec2(3, -5), this.radius + 7, Color(0, 0, 0, 90));
		this.body.drawPolygon(circleVerts(this.radius, 18), color, 3, outline);
		// 朝向明确的面甲，不再依赖一根调试线。
		const face = Vec2(forward.x * 10, forward.y * 10);
		this.body.drawPolygon([
			Vec2(face.x + side.x * 7, face.y + side.y * 7),
			Vec2(face.x - side.x * 7, face.y - side.y * 7),
			Vec2(forward.x * 21, forward.y * 21),
		], dark, 2, outline);
		this.body.drawDot(Vec2(-forward.x * 4, -forward.y * 4), 5, Color(236, 207, 137, 255));
		this.drawClassSilhouette(forward, side, outline);
		// 受伤闪烁提示
		if (this.invincibleTimer > 0 && this.invincible) {
			this.nodeValue.opacity = 0.5;
		} else {
			this.nodeValue.opacity = 1;
		}
	}

	private drawClassSilhouette(forward: Vec2.Type, side: Vec2.Type, outline: Color.Type): void {
		const tip = (distance: number, lateral = 0): Vec2.Type => Vec2(forward.x * distance + side.x * lateral, forward.y * distance + side.y * lateral);
		switch (this.character.id) {
			case 'swordsman':
				this.body.drawSegment(tip(-3, -8), tip(31, -8), 6, Color(211, 221, 220, 255));
				this.body.drawSegment(tip(7, -14), tip(7, -2), 4, Color(105, 71, 37, 255));
				break;
			case 'mage':
				this.body.drawSegment(tip(-8, -10), tip(25, -10), 4, Color(96, 68, 44, 255));
				this.body.drawDot(tip(29, -10), 7, Color(105, 182, 255, 255));
				this.body.drawPolygon([tip(-10, 0), tip(-22, 13), tip(-22, -13)], Color(43, 65, 109, 255), 2, outline);
				break;
			case 'druid':
				this.body.drawSegment(tip(-4, -11), tip(25, -11), 4, Color(93, 66, 38, 255));
				this.body.drawSegment(tip(21, -11), tip(30, -17), 3, Color(84, 179, 96, 255));
				this.body.drawSegment(tip(21, -11), tip(30, -5), 3, Color(84, 179, 96, 255));
				break;
			case 'gunner':
				this.body.drawSegment(tip(1, -9), tip(30, -9), 7, Color(56, 62, 67, 255));
				this.body.drawSegment(tip(24, -13), tip(36, -13), 3, Color(237, 191, 80, 255));
				break;
			case 'necromancer':
				this.body.drawPolygon([tip(-4, 12), tip(-22, 19), tip(-17, 0)], Color(73, 33, 84, 255), 2, outline);
				this.body.drawSegment(tip(-5, -10), tip(26, -10), 4, Color(79, 61, 45, 255));
				this.body.drawDot(tip(29, -10), 6, Color(193, 103, 238, 255));
				break;
		}
	}

	// ---- 访问器 ----
	get pos(): Vec2.Type {
		return this.posValue;
	}
	get node(): Node.Type {
		return this.nodeValue;
	}
	get characterDef(): CharacterDef {
		return this.character;
	}
}

function circleVerts(radius: number, segments: number): Vec2.Type[] {
	const verts: Vec2.Type[] = [];
	for (let i = 0; i < segments; i++) {
		const a = (i / segments) * Math.PI * 2;
		verts.push(Vec2(Math.cos(a) * radius, Math.sin(a) * radius));
	}
	return verts;
}
