// 战斗 HUD：左上血条/等级/经验条，右上波次/击杀，中间波次提示，结算遮罩
// 挂载到 uiRoot（Director.ui），以屏幕中心为原点布局；数值变化时重绘/更新文本
import { Color, DrawNode, Label, Node, Vec2, View } from 'Dora';
import { ctx, type CombatStats } from 'game/core/GameContext';
import { clamp } from 'game/utils/MathUtils';

const FONT = 'sarasa-mono-sc-regular';

function createLabel(text: string, size: number, pos: Vec2.Type, anchor: Vec2.Type, parent: Node.Type): Label.Type | undefined {
	const label = Label(FONT, size);
	if (label === undefined) return undefined;
	label.text = text;
	label.anchor = anchor;
	label.position = pos;
	label.addTo(parent);
	return label;
}

function drawRect(draw: DrawNode.Type, x: number, y: number, w: number, h: number, color: Color.Type): void {
	draw.drawPolygon(
		[Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h)],
		color,
	);
}

export class HUD {
	private uiRoot: Node.Type;
	private root: Node.Type;
	// 血条/经验条
	private hpBg: DrawNode.Type;
	private hpFill: DrawNode.Type;
	private expBg: DrawNode.Type;
	private expFill: DrawNode.Type;
	private lvLabel: Label.Type | undefined;
	private hpLabel: Label.Type | undefined;
	private waveLabel: Label.Type | undefined;
	private killLabel: Label.Type | undefined;
	private modeLabel: Label.Type | undefined;
	private tipLabel: Label.Type | undefined;
	private tipTimer = 0;
	private tipActive = false;
	// 缓存上次渲染值，避免每帧重绘
	private lastHpRatio = -1;
	private lastExpRatio = -1;
	private lastLevel = -1;
	private lastWave = -1;
	private lastKills = -1;
	// 结算遮罩
	private resultRoot: Node.Type;
	private resultTitle: Label.Type | undefined;
	private resultStats: Label.Type | undefined;

	private readonly margin = 18;
	private readonly barW = 250;
	private readonly barH = 20;
	private readonly expH = 6;

	// root 为世界根（兼容参数），HUD 实际挂载到 uiRoot 保证 UI 层级
	constructor(root: Node.Type, uiRoot: Node.Type) {
		this.uiRoot = uiRoot;
		this.root = Node();
		this.root.addTo(uiRoot);

		const W = View.size.width;
		const H = View.size.height;
		const leftX = -W / 2 + this.margin;
		const topY = H / 2 - this.margin;
		const panels = DrawNode();
		panels.addTo(this.root);
		drawRect(panels, leftX - 10, topY - 76, this.barW + 142, 94, Color(8, 17, 20, 205));
		drawRect(panels, W / 2 - 225, topY - 103, 215, 121, Color(8, 17, 20, 205));
		panels.drawSegment(Vec2(leftX - 10, topY + 18), Vec2(leftX + this.barW + 132, topY + 18), 3, Color(205, 150, 55, 230));
		panels.drawSegment(Vec2(W / 2 - 225, topY + 18), Vec2(W / 2 - 10, topY + 18), 3, Color(70, 125, 121, 230));

		// 左上：等级
		this.lvLabel = createLabel('Lv.1', 30, Vec2(leftX, topY + 12), Vec2(0, 0.5), this.root);

		// 左上：血条（背景+填充）
		const hpY = topY - this.barH - 8;
		this.hpBg = DrawNode();
		this.hpBg.addTo(this.root);
		drawRect(this.hpBg, leftX, hpY, this.barW, this.barH, Color(35, 38, 46, 200));
		this.hpFill = DrawNode();
		this.hpFill.addTo(this.root);
		drawRect(this.hpFill, leftX, hpY, this.barW, this.barH, Color(226, 76, 86, 255));
		this.hpLabel = createLabel('100 / 100', 28, Vec2(leftX + this.barW + 12, hpY + this.barH / 2), Vec2(0, 0.5), this.root);

		// 左上：经验条（背景+填充）
		const expY = hpY - this.expH - 3;
		this.expBg = DrawNode();
		this.expBg.addTo(this.root);
		drawRect(this.expBg, leftX, expY, this.barW, this.expH, Color(35, 38, 46, 200));
		this.expFill = DrawNode();
		this.expFill.addTo(this.root);
		drawRect(this.expFill, leftX, expY, this.barW, this.expH, Color(140, 100, 230, 255));

		// 右上：波次/击杀
		this.waveLabel = createLabel('波次 1', 32, Vec2(W / 2 - this.margin, topY - 10), Vec2(1, 0.5), this.root);
		this.killLabel = createLabel('击杀 0', 28, Vec2(W / 2 - this.margin, topY - 46), Vec2(1, 0.5), this.root);
		this.modeLabel = createLabel('章节远征', 26, Vec2(W / 2 - this.margin, topY - 80), Vec2(1, 0.5), this.root);

		// 中间：波次提示（初始隐藏）
		this.tipLabel = createLabel('', 46, Vec2(0, H / 2 - 118), Vec2(0.5, 0.5), this.root);
		if (this.tipLabel !== undefined) {
			this.tipLabel.visible = false;
		}

		// 兼容旧调用的结算节点默认隐藏；实际结算由 PauseMenu 负责
		this.resultRoot = Node();
		this.resultRoot.addTo(this.uiRoot);
		const bg = DrawNode();
		bg.addTo(this.resultRoot);
		drawRect(bg, -W / 2, -H / 2, W, H, Color(8, 10, 18, 190));
		this.resultTitle = createLabel('', 40, Vec2(0, 70), Vec2(0.5, 0.5), this.resultRoot);
		this.resultStats = createLabel('', 18, Vec2(0, -20), Vec2(0.5, 0.5), this.resultRoot);
		this.resultRoot.visible = false;
	}

	// 每帧刷新 HUD 数值（仅变化时更新）
	update(dt: number): void {
		// 波次提示计时
		if (this.tipActive) {
			this.tipTimer -= dt;
			if (this.tipTimer <= 0) {
				this.tipActive = false;
				if (this.tipLabel !== undefined) this.tipLabel.visible = false;
			}
		}

		const player = ctx.player;
		if (player === undefined) return;
		if (this.hpLabel !== undefined) this.hpLabel.text = `${Math.ceil(player.hp)} / ${Math.ceil(player.maxHp)}`;

		// 血条
		const hpRatio = player.maxHp > 0 ? clamp(player.hp / player.maxHp, 0, 1) : 0;
		if (Math.abs(hpRatio - this.lastHpRatio) > 0.002) {
			this.lastHpRatio = hpRatio;
			const w = Math.max(0, this.barW * hpRatio);
			this.hpFill.clear();
			const hpY = View.size.height / 2 - this.margin - this.barH - 8;
			drawRect(this.hpFill, -View.size.width / 2 + this.margin, hpY, w, this.barH, Color(226, 76, 86, 255));
		}

		// 等级
		if (player.level !== this.lastLevel) {
			this.lastLevel = player.level;
			if (this.lvLabel !== undefined) this.lvLabel.text = `Lv.${player.level}`;
		}

		// 经验条
		const expRatio = player.expNeed > 0 ? clamp(player.exp / player.expNeed, 0, 1) : 0;
		if (Math.abs(expRatio - this.lastExpRatio) > 0.002) {
			this.lastExpRatio = expRatio;
			const w = Math.max(0, this.barW * expRatio);
			this.expFill.clear();
			const hpY = View.size.height / 2 - this.margin - this.barH - 8;
			const expY = hpY - this.expH - 3;
			drawRect(this.expFill, -View.size.width / 2 + this.margin, expY, w, this.expH, Color(140, 100, 230, 255));
		}

		// 右上统计
		const stats = ctx.stats;
		if (stats.wave !== this.lastWave) {
			this.lastWave = stats.wave;
			if (this.waveLabel !== undefined) this.waveLabel.text = `波次 ${stats.wave}`;
			if (this.modeLabel !== undefined) this.modeLabel.text = ctx.mode === 'endless' ? '无尽深潜' : ctx.mode === 'challenge' ? '高压试炼' : ctx.mode === 'daily' ? '每日秘境' : '章节远征';
		}
		if (stats.kills !== this.lastKills) {
			this.lastKills = stats.kills;
			if (this.killLabel !== undefined) this.killLabel.text = `击杀 ${stats.kills}`;
		}
	}

	// 波次提示（WaveManager 接线调用）
	showWaveTip(n: number): void {
		if (this.tipLabel === undefined) return;
		this.tipLabel.text = `第 ${n} 波来袭！`;
		this.tipLabel.visible = true;
		this.tipActive = true;
		this.tipTimer = 2.2;
	}

	// 游戏结束遮罩（结算面板细节由外壳域做）
	showGameOver(stats: CombatStats): void {
		this.showResult('游戏结束', stats);
	}

	// 胜利遮罩
	showVictory(stats: CombatStats): void {
		this.showResult('胜利！', stats);
	}

	private showResult(title: string, stats: CombatStats): void {
		if (this.resultTitle !== undefined) this.resultTitle.text = title;
		if (this.resultStats !== undefined) {
			this.resultStats.text =
				`第 ${stats.wave} 波    击杀 ${stats.kills}\n` +
				`生存 ${Math.floor(stats.timeAlive)} 秒    等级 ${stats.playerLevel}`;
		}
		this.resultRoot.visible = true;
	}

	// 隐藏结算遮罩
	hideResult(): void {
		this.resultRoot.visible = false;
	}

	// 重置 HUD（新对局时调用）
	reset(): void {
		this.lastHpRatio = -1;
		this.lastExpRatio = -1;
		this.lastLevel = -1;
		this.lastWave = -1;
		this.lastKills = -1;
		this.tipActive = false;
		if (this.tipLabel !== undefined) this.tipLabel.visible = false;
		this.hideResult();
	}
}
