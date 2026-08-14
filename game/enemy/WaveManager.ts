// 波次管理：生成队列、同屏上限、分帧 AI、视野剔除、波次推进
import { Color, Label, Node, Vec2, View } from 'Dora';
import { ctx } from 'game/core/GameContext';
import { Config } from 'game/config/Config';
import { DamageInfo, EnemyKind, GameMode, WaveDef } from 'game/core/Types';
import { Enemy, enemyPool, setEnemyPoolRoot } from 'game/enemy/Enemy';
import { EnemyBulletManager } from 'game/enemy/EnemyAI';
import { getEnemyDef, eliteKinds } from 'game/enemy/EnemyTypes';
import { rng } from 'game/utils/RNG';
import { clamp, distSq } from 'game/utils/MathUtils';
import { DamageSystem } from 'game/combat/DamageSystem';

const WORLD_HALF = 1000;
const SPAWN_INNER = 120; // 世界内缩，避免生成在边界外
const WAVE_BREAK = 3; // 波间秒数
const SPAWN_PER_FRAME = 8; // 每帧最多生成数
const STREAM_BASE = ['walker', 'runner', 'tank'] as EnemyKind[];

interface SpawnEntry {
	kind: EnemyKind;
	remaining: number;
	delay: number;
	timer: number;
}

// 内置 10 波（第 3/6/10 波带精英，第 10 波 Boss）
const waveDefs: WaveDef[] = [
	{ index: 1, spawns: [{ kind: 'walker', count: 8, delay: 0.4 }], streamCount: 4, streamInterval: 2.0 },
	{ index: 2, spawns: [{ kind: 'walker', count: 10, delay: 0.4 }, { kind: 'runner', count: 4, delay: 1.2 }], streamCount: 8, streamInterval: 1.8 },
	{ index: 3, spawns: [{ kind: 'walker', count: 6, delay: 0.4 }, { kind: 'runner', count: 6, delay: 0.8 }, { kind: 'elite', count: 1, delay: 6 }], streamCount: 10, streamInterval: 1.6 },
	{ index: 4, spawns: [{ kind: 'tank', count: 4, delay: 0.8 }, { kind: 'ranger', count: 4, delay: 1.0 }], streamCount: 12, streamInterval: 1.5 },
	{ index: 5, spawns: [{ kind: 'charger', count: 6, delay: 0.6 }, { kind: 'walker', count: 10, delay: 0.4 }], streamCount: 14, streamInterval: 1.4 },
	{ index: 6, spawns: [{ kind: 'shield', count: 5, delay: 0.7 }, { kind: 'runner', count: 8, delay: 0.5 }, { kind: 'elite', count: 2, delay: 8 }], streamCount: 16, streamInterval: 1.3 },
	{ index: 7, spawns: [{ kind: 'exploder', count: 6, delay: 0.6 }, { kind: 'ranger', count: 6, delay: 0.9 }], streamCount: 18, streamInterval: 1.2 },
	{ index: 8, spawns: [{ kind: 'tank', count: 6, delay: 0.7 }, { kind: 'charger', count: 8, delay: 0.5 }, { kind: 'shield', count: 4, delay: 1.0 }], streamCount: 20, streamInterval: 1.1 },
	{ index: 9, spawns: [{ kind: 'exploder', count: 8, delay: 0.5 }, { kind: 'walker', count: 12, delay: 0.3 }, { kind: 'runner', count: 10, delay: 0.5 }], streamCount: 24, streamInterval: 1.0 },
	{ index: 10, spawns: [{ kind: 'boss', count: 1, delay: 2 }, { kind: 'elite', count: 2, delay: 10 }, { kind: 'walker', count: 10, delay: 0.5 }], streamCount: 12, streamInterval: 1.6 },
];

export class WaveManager {
	private root: Node.Type;
	private bullets: EnemyBulletManager;
	private enemies: Enemy[] = [];
	private entries: SpawnEntry[] = [];
	private streamCount = 0;
	private streamInterval = 1;
	private streamTimer = 0;
	private waveIndex = 0;
	private state: 'intermission' | 'active' = 'intermission';
	private timer = WAVE_BREAK;
	private tickIndex = 0;
	private started = false;
	private waveLabel: Label.Type | undefined;
	private labelTimer = 0;
	private mode: GameMode = 'chapter';

	constructor(root: Node.Type) {
		this.root = root;
		this.bullets = new EnemyBulletManager(root);
		setEnemyPoolRoot(root);
		// 注册跨域回调（战斗域通过 ctx 使用敌人列表）
		ctx.findEnemiesNear = (pos: Vec2.Type, radius: number, limit: number): unknown[] => {
			return this.findEnemiesNear(pos, radius, limit);
		};
		ctx.damageEnemiesInRadius = (pos: Vec2.Type, radius: number, info: DamageInfo): number => {
			return this.damageEnemiesInRadius(pos, radius, info);
		};
		ctx.onDamageEnemy = (enemy: unknown, info: DamageInfo): void => {
			if (enemy instanceof Enemy && enemy.isAlive && !enemy.markedDead) {
				enemy.takeDamage(info);
			}
		};
	}

	get currentWave(): number {
		return this.waveIndex;
	}

	get isWaveCleared(): boolean {
		return this.state === 'intermission' && this.timer <= 0;
	}

	get activeEnemies(): Enemy[] {
		return this.enemies;
	}

	get bulletManager(): EnemyBulletManager {
		return this.bullets;
	}

	start(mode: GameMode): void {
		this.mode = mode;
		this.started = true;
		this.waveIndex = 0;
		this.state = 'intermission';
		this.timer = 1;
	}

	update(dt: number): void {
		if (!this.started) return;
		this.bullets.update(dt);
		if (this.state === 'intermission') {
			this.timer -= dt;
			this.cleanupDead();
			this.updateLabel(dt);
			if (this.timer <= 0) {
				this.startWave(this.waveIndex + 1);
			}
			return;
		}
		this.spawnFromEntries(dt);
		this.spawnStream(dt);
		this.updateEnemies(dt);
		this.cleanupDead();
		this.updateLabel(dt);
		this.checkWaveCleared();
	}

	clearAll(): void {
		for (let i = this.enemies.length - 1; i >= 0; i--) {
			enemyPool.release(this.enemies[i]);
		}
		this.enemies.length = 0;
		this.bullets.clear();
		this.entries.length = 0;
		this.streamCount = 0;
		this.started = false;
		this.state = 'intermission';
		this.timer = WAVE_BREAK;
		this.hideWaveLabel();
	}

	// ---------- 波次推进 ----------
	private startWave(n: number): void {
		this.waveIndex = n;
		ctx.stats.wave = n;
		const def = this.buildWaveDef(n);
		this.entries = def.spawns.map((s): SpawnEntry => ({
			kind: s.kind,
			remaining: s.count,
			delay: s.delay,
			timer: 0,
		}));
		this.streamCount = def.streamCount;
		this.streamInterval = def.streamInterval;
		this.streamTimer = def.streamInterval;
		this.state = 'active';
		this.showWaveLabel(n);
	}

	private buildWaveDef(n: number): WaveDef {
		if (n <= 10) {
			return waveDefs[n - 1];
		}
		// 无限循环：复用第 10 波骨架，增强 hp 与数量
		const base = waveDefs[9];
		const boost = (n - 10) * 0.15;
		const countBoost = (n - 10) * 0.2;
		return {
			index: n,
			spawns: base.spawns.map((s): { kind: EnemyKind; count: number; delay: number } => ({
				kind: s.kind,
				count: Math.floor(s.count * (1 + countBoost)),
				delay: s.delay,
			})),
			streamCount: Math.floor(base.streamCount * (1 + countBoost)),
			streamInterval: Math.max(0.5, base.streamInterval),
		};
	}

	private checkWaveCleared(): void {
		if (this.enemies.length > 0) return;
		let allSpawned = true;
		for (let i = 0; i < this.entries.length; i++) {
			if (this.entries[i].remaining > 0) {
				allSpawned = false;
				break;
			}
		}
		if (!allSpawned || this.streamCount > 0) return;
		const targetWave = this.mode === 'challenge' ? 12 : 10;
		if (this.mode !== 'endless' && this.waveIndex === targetWave && ctx.onVictory) {
			ctx.onVictory();
			return;
		}
		this.state = 'intermission';
		this.timer = WAVE_BREAK;
		this.hideWaveLabel();
	}

	// ---------- 生成 ----------
	private spawnFromEntries(dt: number): void {
		let spawned = 0;
		for (let i = 0; i < this.entries.length; i++) {
			const en = this.entries[i];
			if (en.remaining <= 0) continue;
			en.timer -= dt;
			if (en.timer <= 0) {
				if (spawned < SPAWN_PER_FRAME && this.aliveCount() < this.enemyCap()) {
					this.spawnEnemy(en.kind);
					en.remaining--;
					spawned++;
				}
				en.timer = en.delay;
			}
		}
	}

	private spawnStream(dt: number): void {
		if (this.streamCount <= 0) return;
		this.streamTimer -= dt;
		if (this.streamTimer <= 0) {
			if (this.aliveCount() < this.enemyCap()) {
				this.spawnEnemy(pickKind(STREAM_BASE));
				this.streamCount--;
			}
			this.streamTimer = this.streamInterval;
		}
	}

	private spawnEnemy(kind: EnemyKind): void {
		const def = getEnemyDef(kind);
		const pos = this.spawnPointNearEdge();
		const e = enemyPool.acquire();
		e.resetFromPool(pos, def);
		let hpMult = 1;
		if (this.waveIndex > 10) hpMult += (this.waveIndex - 10) * 0.15;
		if (this.mode === 'challenge') hpMult *= 1.35;
		if (hpMult > 1) {
			e.applyWaveBoost(hpMult);
		}
		e.bulletManager = this.bullets;
		this.enemies.push(e);
	}

	private spawnPointNearEdge(): Vec2.Type {
		const p = ctx.player !== undefined ? ctx.player.pos : Vec2.zero;
		const a = rng.range(0, Math.PI * 2);
		const r = 440 + rng.range(0, 220);
		const x = clamp(p.x + Math.cos(a) * r, -WORLD_HALF + SPAWN_INNER, WORLD_HALF - SPAWN_INNER);
		const y = clamp(p.y + Math.sin(a) * r, -WORLD_HALF + SPAWN_INNER, WORLD_HALF - SPAWN_INNER);
		return Vec2(x, y);
	}

	private enemyCap(): number {
		return Config.enemyCap[Config.quality];
	}

	private aliveCount(): number {
		let c = 0;
		for (let i = 0; i < this.enemies.length; i++) {
			if (this.enemies[i].isAlive) c++;
		}
		return c;
	}

	// ---------- 每帧更新 ----------
	private updateEnemies(dt: number): void {
		const divisor = Config.aiTickDivisor;
		this.tickIndex = (this.tickIndex + 1) % divisor;
		const playerPos = ctx.player !== undefined ? ctx.player.pos : Vec2.zero;
		const halfW = View.size.width / 2 + Config.cullMargin;
		const halfH = View.size.height / 2 + Config.cullMargin;
		let idx = 0;
		for (let i = 0; i < this.enemies.length; i++) {
			const e = this.enemies[i];
			if (!e.isAlive) continue;
			const offX = Math.abs(e.pos.x - playerPos.x);
			const offY = Math.abs(e.pos.y - playerPos.y);
			const visible = offX <= halfW && offY <= halfH;
			e.isVisible = visible;
			const aiTick = idx % divisor === this.tickIndex;
			e.update(dt, playerPos, 1, aiTick);
			const contactRadius = e.radius + 16;
			if (distSq(e.pos, playerPos) <= contactRadius * contactRadius) {
				ctx.onPlayerDamaged?.(e.def.damage, e.pos);
			}
			idx++;
		}
	}

	private cleanupDead(): void {
		for (let i = this.enemies.length - 1; i >= 0; i--) {
			if (!this.enemies[i].isAlive) {
				const last = this.enemies.length - 1;
				const e = this.enemies[i];
				this.enemies[i] = this.enemies[last];
				this.enemies.pop();
				enemyPool.release(e);
			}
		}
	}

	// ---------- 跨域查询（注册到 ctx） ----------
	findEnemiesNear(pos: Vec2.Type, radius: number, limit: number): unknown[] {
		const result: Enemy[] = [];
		const rr = radius * radius;
		for (let i = 0; i < this.enemies.length; i++) {
			const e = this.enemies[i];
			if (!e.isAlive || e.markedDead) continue;
			const dx = e.pos.x - pos.x;
			const dy = e.pos.y - pos.y;
			if (dx * dx + dy * dy <= rr) result.push(e);
		}
		// 距离升序排序（插入排序，敌人数量有限）
		for (let i = 1; i < result.length; i++) {
			const key = result[i];
			let j = i - 1;
			while (j >= 0 && distSq(pos, result[j].pos) > distSq(pos, key.pos)) {
				result[j + 1] = result[j];
				j--;
			}
			result[j + 1] = key;
		}
		if (limit > 0 && result.length > limit) {
			result.length = limit;
		}
		return result;
	}

	damageEnemiesInRadius(pos: Vec2.Type, radius: number, info: DamageInfo): number {
		let count = 0;
		for (let i = 0; i < this.enemies.length; i++) {
			const e = this.enemies[i];
			if (!e.isAlive || e.markedDead) continue;
			const dx = e.pos.x - pos.x;
			const dy = e.pos.y - pos.y;
			const rr = radius + e.radius;
			if (dx * dx + dy * dy <= rr * rr) {
				DamageSystem.apply(e, info);
				count++;
			}
		}
		return count;
	}

	// ---------- 波次提示 Label ----------
	private showWaveLabel(n: number): void {
		this.hideWaveLabel();
		const label = Label('sarasa-mono-sc-regular', 48);
		if (label === undefined) return;
		const isBossWave = n === 10;
		label.text = isBossWave ? `⚠ 第 ${n} 波 · BOSS` : `第 ${n} 波`;
		label.color = Color(isBossWave ? 255 : 230, isBossWave ? 120 : 200, 80, 255);
		label.anchor = Vec2(0.5, 0.5);
		label.y = View.size.height / 2 - 60;
		label.addTo(this.root);
		this.waveLabel = label;
		this.labelTimer = 2.2;
	}

	private hideWaveLabel(): void {
		if (this.waveLabel !== undefined) {
			this.waveLabel.removeFromParent();
			this.waveLabel = undefined;
		}
	}

	private updateLabel(dt: number): void {
		if (this.waveLabel === undefined) return;
		this.labelTimer -= dt;
		if (this.labelTimer <= 0) {
			this.waveLabel.removeFromParent();
			this.waveLabel = undefined;
		}
	}
}

// 辅助导出：供外部遍历精英候选
export function randomBaseKind(): EnemyKind {
	return pickKind(eliteKinds);
}

// 字符串联合无法满足 rng.pick<T extends object>，用索引取随机元素
function pickKind(arr: EnemyKind[]): EnemyKind {
	return arr[rng.int(0, arr.length - 1)] as EnemyKind;
}
