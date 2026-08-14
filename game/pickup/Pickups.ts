// 拾取物系统：经验球磁吸/宝箱/治疗/可破坏木箱炸药桶 + 敌人掉落规则
import { Color, DrawNode, Node, Vec2 } from 'Dora';
import { ctx } from 'game/core/GameContext';
import { DamageInfo, EnemyKind, PickupKind } from 'game/core/Types';
import { rng } from 'game/utils/RNG';
import { distSq } from 'game/utils/MathUtils';

const PLAYER_RADIUS = 16;
const PICKUP_DIST = 24;
const MAGNET_RADIUS = 90;
const EXP_LIFE = 14;
const ITEM_LIFE = 25;
const HEAL_AMOUNT = 20;
const CHEST_EXP = 30;
const CRATE_HP = 20;
const BARREL_HP = 10;
const BARREL_AOE = 110;
const BARREL_DAMAGE = 30;

interface Pickup {
	kind: PickupKind;
	pos: Vec2.Type;
	value: number;
	hp: number; // crate/barrel 可破坏血量
	alive: boolean;
	magnetized: boolean;
	timer: number;
	pulse: number;
	draw: DrawNode.Type;
}

function rectVerts(w: number, h: number): Vec2.Type[] {
	return [
		Vec2(-w / 2, -h / 2),
		Vec2(w / 2, -h / 2),
		Vec2(w / 2, h / 2),
		Vec2(-w / 2, h / 2),
	];
}

function drawPickupVisual(draw: DrawNode.Type, kind: PickupKind, pulse = 0): void {
	draw.clear();
	switch (kind) {
		case 'exp': {
			const r = 5 + Math.sin(pulse) * 1.2;
			draw.drawDot(Vec2.zero, r + 4, Color(90, 160, 255, 70));
			draw.drawDot(Vec2.zero, r, Color(120, 190, 255, 255));
			break;
		}
		case 'chest':
			draw.drawPolygon(rectVerts(22, 16), Color(222, 168, 58, 255));
			drawRectOutline(draw, 22, 16, 2, Color(98, 59, 20, 255));
			draw.drawSegment(Vec2(-10, 2), Vec2(10, 2), 2, Color(255, 219, 116, 255));
			draw.drawDot(Vec2(0, -1), 3, Color(72, 42, 12, 255));
			break;
		case 'heal':
			draw.drawDot(Vec2.zero, 14, Color(40, 105, 69, 110));
			draw.drawSegment(Vec2(-8, 0), Vec2(8, 0), 4, Color(100, 238, 137, 255));
			draw.drawSegment(Vec2(0, -8), Vec2(0, 8), 4, Color(100, 238, 137, 255));
			break;
		case 'crate':
			draw.drawPolygon(rectVerts(30, 26), Color(147, 96, 47, 255));
			drawRectOutline(draw, 30, 26, 2.5, Color(72, 45, 25, 255));
			draw.drawSegment(Vec2(-13, -10), Vec2(13, 10), 3, Color(203, 144, 71, 255));
			draw.drawSegment(Vec2(-13, 10), Vec2(13, -10), 3, Color(203, 144, 71, 255));
			break;
		case 'barrel':
			draw.drawPolygon(rectVerts(24, 30), Color(173, 47, 42, 255));
			drawRectOutline(draw, 24, 30, 2.5, Color(57, 35, 38, 255));
			draw.drawSegment(Vec2(-11, 8), Vec2(11, 8), 3, Color(43, 39, 43, 255));
			draw.drawSegment(Vec2(-11, -8), Vec2(11, -8), 3, Color(43, 39, 43, 255));
			draw.drawDot(Vec2.zero, 5, Color(255, 183, 63, 255));
			break;
	}
}

function drawRectOutline(draw: DrawNode.Type, w: number, h: number, width: number, color: Color.Type): void {
	const x = w / 2;
	const y = h / 2;
	draw.drawSegment(Vec2(-x, -y), Vec2(x, -y), width, color);
	draw.drawSegment(Vec2(x, -y), Vec2(x, y), width, color);
	draw.drawSegment(Vec2(x, y), Vec2(-x, y), width, color);
	draw.drawSegment(Vec2(-x, y), Vec2(-x, -y), width, color);
}

export class PickupSystem {
	private root: Node.Type;
	private pickups: Pickup[] = [];

	constructor(root: Node.Type) {
		this.root = root;
		// 敌人死亡掉落（Enemy.die 调用）
		ctx.onEnemyDied = (enemy: unknown, exp: number, pos: Vec2.Type, kind: EnemyKind): void => {
			this.spawn('exp', pos, exp);
			if (kind === 'elite' && rng.chance(0.3)) this.spawn('chest', pos);
			if (kind === 'boss') this.spawn('chest', pos);
		};
		// 外部（战斗/技能域）生成掉落物
		ctx.onSpawnPickup = (kind: PickupKind, pos: Vec2.Type, value?: number): void => {
			this.spawn(kind, pos, value);
		};
		// 磁铁技能：强制吸取范围内经验球
		ctx.magnetPickups = (pos: Vec2.Type, radius: number): void => {
			for (let i = 0; i < this.pickups.length; i++) {
				const p = this.pickups[i];
				if (p.kind === 'exp' && distSq(p.pos, pos) <= radius * radius) {
					p.magnetized = true;
				}
			}
		};
		ctx.damageBreakablesInRadius = (pos: Vec2.Type, radius: number, damage: number): number => {
			return this.damageInRadius(pos, radius, damage);
		};
	}

	seedArena(): void {
		for (let i = 0; i < 12; i++) {
			const angle = rng.range(0, Math.PI * 2);
			const distance = rng.range(180, 820);
			this.spawn(i % 4 === 0 ? 'barrel' : 'crate', Vec2(Math.cos(angle) * distance, Math.sin(angle) * distance));
		}
	}

	spawn(kind: PickupKind, pos: Vec2.Type, value?: number): void {
		const p: Pickup = {
			kind: kind,
			pos: Vec2(pos.x, pos.y),
			value: value !== undefined ? value : 1,
			hp: kind === 'crate' ? CRATE_HP : kind === 'barrel' ? BARREL_HP : 0,
			alive: true,
			magnetized: false,
			timer: kind === 'exp' ? EXP_LIFE : ITEM_LIFE,
			pulse: rng.range(0, Math.PI * 2),
			draw: DrawNode(),
		};
		drawPickupVisual(p.draw, kind, p.pulse);
		p.draw.addTo(this.root);
		p.draw.position = p.pos;
		this.pickups.push(p);
	}

	update(dt: number): void {
		const player = ctx.player;
		for (let i = this.pickups.length - 1; i >= 0; i--) {
			const p = this.pickups[i];
			if (!p.alive) {
				this.removeAt(i);
				continue;
			}
			p.timer -= dt;
			if (p.timer <= 0) {
				this.removeAt(i);
				continue;
			}
			p.pulse += dt * 5;
			// 可拾取类型：经验/宝箱/治疗
			if (player !== undefined && player.isAlive && p.kind !== 'crate' && p.kind !== 'barrel') {
				const dx = player.pos.x - p.pos.x;
				const dy = player.pos.y - p.pos.y;
				const d2 = dx * dx + dy * dy;
				const magnetR = p.kind === 'exp' ? MAGNET_RADIUS + player.magnet : 0;
				if (!p.magnetized && p.kind === 'exp' && d2 <= magnetR * magnetR) {
					p.magnetized = true;
				}
				if (p.magnetized) {
					const dist = Math.sqrt(d2);
					if (dist > 0.001) {
						const step = 460 * dt;
						p.pos = Vec2(p.pos.x + (dx / dist) * step, p.pos.y + (dy / dist) * step);
					}
					p.draw.position = p.pos;
					if (d2 <= (PICKUP_DIST + PLAYER_RADIUS) * (PICKUP_DIST + PLAYER_RADIUS)) {
						this.collect(p);
						this.removeAt(i);
						continue;
					}
				} else if (d2 <= (PICKUP_DIST + PLAYER_RADIUS) * (PICKUP_DIST + PLAYER_RADIUS)) {
					this.collect(p);
					this.removeAt(i);
					continue;
				}
			}
			if (p.kind === 'exp') {
				drawPickupVisual(p.draw, p.kind, p.pulse);
			}
			p.draw.position = p.pos;
		}
	}

	// 玩家攻击破坏木箱/炸药桶（战斗域通过公开方法或后续 ctx 回调调用）
	damage(kind: 'crate' | 'barrel', pos: Vec2.Type, dmg: number): boolean {
		for (let i = 0; i < this.pickups.length; i++) {
			const p = this.pickups[i];
			if (!p.alive || p.kind !== kind) continue;
			if (distSq(p.pos, pos) > 50 * 50) continue;
			p.hp -= dmg;
			if (p.hp <= 0) {
				this.breakPickup(p, i);
				return true;
			}
		}
		return false;
	}

	private damageInRadius(pos: Vec2.Type, radius: number, damage: number): number {
		let hits = 0;
		for (let i = this.pickups.length - 1; i >= 0; i--) {
			const p = this.pickups[i];
			if (!p.alive || (p.kind !== 'crate' && p.kind !== 'barrel')) continue;
			if (distSq(p.pos, pos) > radius * radius) continue;
			p.hp -= damage;
			hits++;
			if (p.hp <= 0) this.breakPickup(p, i);
		}
		return hits;
	}

	clearAll(): void {
		for (let i = 0; i < this.pickups.length; i++) {
			this.pickups[i].draw.removeFromParent();
		}
		this.pickups.length = 0;
	}

	// ---------- 内部 ----------
	private collect(p: Pickup): void {
		const player = ctx.player;
		switch (p.kind) {
			case 'exp':
				if (ctx.onAddExp) ctx.onAddExp(p.value, p.pos);
				break;
			case 'heal':
				if (player !== undefined) {
					player.hp = Math.min(player.maxHp, player.hp + HEAL_AMOUNT);
				}
				break;
			case 'chest':
				this.openChest(p.pos);
				break;
			default:
				break;
		}
		if (p.kind !== 'exp' && ctx.vfx) {
			ctx.vfx.burst(p.pos, p.kind === 'heal' ? 0x50e070 : 0xffd24a, 6, 80);
		}
	}

	private openChest(pos: Vec2.Type): void {
		const player = ctx.player;
		if (rng.chance(0.5)) {
			if (ctx.onAddExp) ctx.onAddExp(CHEST_EXP, pos);
		} else if (player !== undefined) {
			player.hp = Math.min(player.maxHp, player.hp + HEAL_AMOUNT);
		}
	}

	private breakPickup(p: Pickup, index: number): void {
		if (p.kind === 'barrel') {
			// 炸药桶爆炸：AOE 伤害 + 击退
			const info: DamageInfo = {
				amount: BARREL_DAMAGE,
				kind: 'magic',
				crit: false,
				knockback: Vec2.zero,
				hitStop: 0.03,
				shake: 4,
				flash: true,
				source: 'explosion',
			};
			if (ctx.damageEnemiesInRadius) {
				ctx.damageEnemiesInRadius(p.pos, BARREL_AOE, info);
			}
			if (ctx.vfx) {
				ctx.vfx.burst(p.pos, 0xff5030, 14, 180);
				ctx.vfx.ring(p.pos, 0xff5030, BARREL_AOE);
			}
			if (ctx.feedback) ctx.feedback.shake(5);
			this.spawn('exp', p.pos, 3);
		} else {
			// 木箱：掉经验
			this.spawn('exp', p.pos, 2);
			if (rng.chance(0.25)) this.spawn('exp', p.pos, 2);
		}
		this.removeAt(index);
	}

	private removeAt(index: number): void {
		const p = this.pickups[index];
		p.alive = false;
		p.draw.removeFromParent();
		const last = this.pickups.length - 1;
		this.pickups[index] = this.pickups[last];
		this.pickups.pop();
	}
}
