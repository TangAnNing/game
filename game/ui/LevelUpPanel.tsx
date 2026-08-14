// 升级选择面板：冻结战斗，提供清晰的三选一强化
import { Color, DrawNode, Node, Vec2, View } from 'Dora';
import { React, createRoot, signal } from 'DoraX';
import type { Root, Signal } from 'DoraX';
import type { SkillDef, SkillRarity } from 'game/core/Types';

const FONT = 'sarasa-mono-sc-regular';
const W = View.size.width;
const H = View.size.height;
const RARITY_RGB: Record<SkillRarity, [number, number, number]> = {
	common: [157, 169, 170],
	rare: [82, 164, 218],
	epic: [196, 111, 238],
};

function rect(draw: DrawNode.Type, x: number, y: number, w: number, h: number, fill: Color.Type, border?: Color.Type): void {
	draw.drawPolygon([Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h)], fill, border !== undefined ? 2 : 0, border);
}

export class LevelUpPanel {
	private visible: Signal<boolean> = signal(false);
	private choices: Signal<SkillDef[]> = signal([]);
	private root: Root;
	onPick?: (index: number) => void;

	constructor(parent: Node.Type) {
		this.root = createRoot(parent);
		this.root.render(() => this.renderPanel());
	}

	show(choices: SkillDef[]): void {
		this.choices.value = choices;
		this.visible.value = true;
	}

	hide(): void {
		this.visible.value = false;
		this.choices.value = [];
	}

	dispose(): void {
		this.root.unmount();
	}

	private renderPanel(): React.Element | React.Element[] {
		if (!this.visible.value) return [];
		const cardW = Math.min(272, W * 0.285);
		const cardH = 286;
		const gap = Math.min(28, W * 0.035);
		return (
			<node key="levelup-panel">
				<draw-node key="levelup-overlay" onMount={(self) => rect(self, -W / 2, -H / 2, W, H, Color(5, 10, 13, 232))} />
				<label key="levelup-title" fontName={FONT} fontSize={42} text="力量觉醒" color3={0xf0d38a} x={0} y={H / 2 - 54} anchorX={0.5} anchorY={0.5} />
				<label key="levelup-subtitle" fontName={FONT} fontSize={28} text="战场已冻结 · 选择一项强化继续远征" color3={0x9db4ae} x={0} y={H / 2 - 98} anchorX={0.5} anchorY={0.5} />
				{this.choices.value.map((def, index) => this.renderCard(def, index, cardW, cardH, gap))}
			</node>
		);
	}

	private renderCard(def: SkillDef, index: number, w: number, h: number, gap: number): React.Element {
		const rgb = RARITY_RGB[def.rarity];
		const color = (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
		const x = (index - 1) * (w + gap);
		const tag = def.active ? '主动技能' : def.exclusive !== undefined ? '职业专属' : '被动强化';
		return (
			<node key={def.id} x={x} y={-146} width={w} height={h} touchEnabled={true} swallowTouches={true} onTapped={() => this.onPick?.(index)}>
				<draw-node onMount={(self) => {
					rect(self, 5, -5, w, h, Color(0, 0, 0, 120));
					rect(self, 0, 0, w, h, Color(23, 32, 36, 255), Color(rgb[0], rgb[1], rgb[2], 255));
					rect(self, 0, h - 7, w, 7, Color(rgb[0], rgb[1], rgb[2], 255));
				}} />
				<label key={`${def.id}-tag`} fontName={FONT} fontSize={24} text={tag} color3={color} x={w / 2} y={h - 32} anchorX={0.5} anchorY={0.5} />
				<label key={`${def.id}-name`} fontName={FONT} fontSize={38} text={def.name} color3={0xf5f2e8} x={w / 2} y={h - 82} anchorX={0.5} anchorY={0.5} />
				<label key={`${def.id}-desc`} fontName={FONT} fontSize={27} text={def.desc} color3={0xb7c6c2} textWidth={w - 38} x={w / 2} y={h - 154} anchorX={0.5} anchorY={0.5} />
				<label key={`${def.id}-action`} fontName={FONT} fontSize={26} text="点击选择" color3={0xe9ddbf} x={w / 2} y={28} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}
}
