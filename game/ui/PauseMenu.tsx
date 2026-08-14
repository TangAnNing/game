// 暂停、失败与胜利结算面板
import { Color, Director, DrawNode, Node, Vec2, View } from 'Dora';
import { React, createRoot, signal } from 'DoraX';
import type { Root } from 'DoraX';
import type { CombatStats } from 'game/core/GameContext';

const FONT = 'sarasa-mono-sc-regular';
const W = View.size.width;
const H = View.size.height;

export interface PauseMenuProps {
	onResume: () => void;
	onRestart: () => void;
	onQuit: () => void;
}

type PanelState = 'hidden' | 'pause' | 'gameover' | 'victory';

function rect(draw: DrawNode.Type, x: number, y: number, w: number, h: number, fill: Color.Type, border?: Color.Type): void {
	draw.drawPolygon([Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h)], fill, border !== undefined ? 1 : 0, border);
}

export class PauseMenu {
	private props: PauseMenuProps;
	private root: Root | undefined;
	private state = signal<PanelState>('hidden');
	private stats = signal<CombatStats | undefined>(undefined);

	constructor(props: PauseMenuProps) {
		this.props = props;
	}

	showPause(): void {
		this.state.value = 'pause';
		this.ensureRoot();
	}

	hidePause(): void {
		this.state.value = 'hidden';
		this.unmount();
	}

	showGameOver(stats: CombatStats): void {
		this.stats.value = stats;
		this.state.value = 'gameover';
		this.ensureRoot();
	}

	showVictory(stats: CombatStats): void {
		this.stats.value = stats;
		this.state.value = 'victory';
		this.ensureRoot();
	}

	private ensureRoot(): void {
		if (this.root === undefined) this.root = createRoot(Director.ui);
		this.root.render(() => this.renderPanel());
	}

	private unmount(): void {
		this.root?.unmount();
		this.root = undefined;
	}

	private renderPanel(): React.Element | React.Element[] {
		const state = this.state.value;
		if (state === 'hidden') return [];
		const isEnd = state === 'gameover' || state === 'victory';
		const stats = this.stats.value;
		const title = state === 'pause' ? '暂停' : state === 'victory' ? '远征完成' : '倒下了';
		const color = state === 'victory' ? 0x8ed39b : state === 'gameover' ? 0xe08383 : 0xf0d38a;
		const detail = stats === undefined ? '' : `存活 ${Math.floor(stats.timeAlive)} 秒    波次 ${stats.wave}    等级 ${stats.playerLevel}\n击杀 ${stats.kills}    精英 ${stats.eliteKills}    Boss ${stats.bossKills}`;
		return (
			<node key={`pause-${state}`}>
				<draw-node key="pause-overlay" onMount={(self) => rect(self, -W / 2, -H / 2, W, H, Color(5, 10, 13, 226))} />
				<draw-node key="pause-panel-bg" onMount={(self) => rect(self, -280, -210, 560, 420, Color(18, 29, 32, 252), Color(84, 113, 105, 255))} />
				<label key="title" fontName={FONT} fontSize={46} text={title} color3={color} x={0} y={142} anchorX={0.5} anchorY={0.5} />
				{isEnd ? <label key="detail" fontName={FONT} fontSize={30} text={detail} color3={0xd0dbd7} textWidth={490} x={0} y={52} anchorX={0.5} anchorY={0.5} /> : <label key="pause-detail" fontName={FONT} fontSize={28} text="战场状态已保存，继续后不会丢失进度" color3={0xa9bbb5} x={0} y={52} anchorX={0.5} anchorY={0.5} />}
				{state === 'pause' ? this.button('继续远征', () => this.props.onResume(), 0, -45, 290, 0x3f6d70) : this.button('再战一次', () => this.props.onRestart(), 0, -45, 290, 0xd09a38)}
				{this.button('返回大厅', () => this.props.onQuit(), 0, -120, 290, 0x334f51)}
			</node>
		);
	}

	private button(text: string, onTap: () => void, x: number, y: number, width: number, color: number): React.Element {
		const h = 60;
		return (
			<node key={`${text}-${x}-${y}`} x={x} y={y} width={width} height={h} touchEnabled={true} swallowTouches={true} onTapped={onTap}>
				<draw-node onMount={(self) => {
					const r = Math.floor(color / 65536) % 256;
					const g = Math.floor(color / 256) % 256;
					const b = color % 256;
					rect(self, 0, 0, width, h, Color(r, g, b, 255));
				}} />
				<label key={`${text}-label`} fontName={FONT} fontSize={34} text={text} color3={0xffffff} x={width / 2} y={h / 2} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}
}
