// 战前大厅：主菜单、角色选择、模式选择与设置
import { React, createRoot, signal } from 'DoraX';
import type { Root } from 'DoraX';
import { Color, Director, DrawNode, Vec2, View } from 'Dora';
import { characters } from 'game/player/Characters';
import { saveSystem } from 'game/save/Save';
import { Config } from 'game/config/Config';
import type { CharacterDef, CharacterId, GameMode, SaveData } from 'game/core/Types';

const FONT = 'sarasa-mono-sc-regular';
const W = View.size.width;
const H = View.size.height;

export interface MainMenuProps {
	onStart: (charId: CharacterId, mode: GameMode) => void;
	onQuit?: () => void;
}

type MenuScreen = 'main' | 'chars' | 'modes' | 'settings';

const UNLOCK_COST: Record<CharacterId, number> = {
	swordsman: 0,
	mage: 300,
	druid: 0,
	gunner: 300,
	necromancer: 1200,
};

const CHARACTER_ORDER: CharacterId[] = ['swordsman', 'mage', 'druid', 'gunner', 'necromancer'];

const MODES: { mode: GameMode; label: string; desc: string; accent: number }[] = [
	{ mode: 'chapter', label: '章节远征', desc: '10 波战斗，击败深渊领主', accent: 0xd9a441 },
	{ mode: 'endless', label: '无尽深潜', desc: '10 波后持续强化，挑战最高记录', accent: 0x58a6d8 },
	{ mode: 'challenge', label: '高压试炼', desc: '敌人生命 +35%，坚持到第 12 波', accent: 0xd65c5c },
	{ mode: 'daily', label: '每日秘境', desc: '固定种子，所有人面对相同战局', accent: 0x65bd82 },
];

function rect(draw: DrawNode.Type, x: number, y: number, w: number, h: number, fill: Color.Type, border?: Color.Type): void {
	draw.drawPolygon([Vec2(x, y), Vec2(x + w, y), Vec2(x + w, y + h), Vec2(x, y + h)], fill, border !== undefined ? 1 : 0, border);
}

export class MainMenu {
	private props: MainMenuProps;
	private root: Root | undefined = undefined;
	private screen = signal<MenuScreen>('main');
	private selectedChar = signal<CharacterId>('swordsman');
	private saveTick = signal(0);

	constructor(props: MainMenuProps) {
		this.props = props;
	}

	show(): void {
		if (this.root === undefined) this.root = createRoot(Director.ui);
		this.screen.value = 'main';
		this.saveTick.value++;
		this.root.render(() => this.renderScreen());
	}

	hide(): void {
		this.root?.unmount();
		this.root = undefined;
	}

	private renderScreen(): React.Element {
		this.saveTick.value;
		const body = this.screen.value === 'chars'
			? this.renderCharSelect()
			: this.screen.value === 'modes'
				? this.renderModeSelect()
				: this.screen.value === 'settings'
					? this.renderSettings()
					: this.renderMain();
		return (
			<node key={`menu-${this.screen.value}`}>
				<draw-node onMount={(self) => this.drawBackdrop(self)} />
				{body}
			</node>
		);
	}

	private drawBackdrop(draw: DrawNode.Type): void {
		rect(draw, -W / 2, -H / 2, W, H, Color(10, 17, 20, 255));
		rect(draw, -W / 2, H / 2 - 8, W, 8, Color(211, 155, 58, 255));
		for (let x = -W / 2; x <= W / 2; x += 80) {
			draw.drawSegment(Vec2(x, -H / 2), Vec2(x, H / 2), 0.5, Color(43, 67, 68, 90));
		}
		for (let y = -H / 2; y <= H / 2; y += 80) {
			draw.drawSegment(Vec2(-W / 2, y), Vec2(W / 2, y), 0.5, Color(43, 67, 68, 90));
		}
		draw.drawDot(Vec2(-W * 0.33, 20), Math.min(W, H) * 0.24, Color(31, 65, 59, 90));
	}

	private renderMain(): React.Element {
		const save = saveSystem.load();
		const compact = W < 820;
		const leftX = compact ? 0 : -W * 0.22;
		const rightX = compact ? 0 : W * 0.23;
		return (
			<node key="main-content">
				<label key="title" fontName={FONT} fontSize={compact ? 52 : 68} text="秘境收割者" color3={0xf0d38a} x={leftX} y={compact ? 170 : 98} anchorX={0.5} anchorY={0.5} />
				<label key="subtitle" fontName={FONT} fontSize={compact ? 28 : 30} text="守住阵线。夺取力量。收割整片秘境。" color3={0xa9c4bc} x={leftX} y={compact ? 108 : 24} anchorX={0.5} anchorY={0.5} />
				<label key="record" fontName={FONT} fontSize={28} text={`金币 ${save.gold}    无尽纪录 ${save.bestWave} 波    累计击杀 ${save.totalKills}`} color3={0xd6c9a8} x={leftX} y={compact ? 62 : -28} anchorX={0.5} anchorY={0.5} />
				{this.button('开始远征', () => { this.screen.value = 'chars'; }, rightX, compact ? -15 : 76, 340, 0xd09a38)}
				{this.button('战斗设置', () => { this.screen.value = 'settings'; }, rightX, compact ? -85 : 4, 340, 0x3f6d70)}
				{this.props.onQuit !== undefined ? this.button('退出游戏', () => this.props.onQuit?.(), rightX, compact ? -155 : -68, 340, 0x573f43) : <node key="no-quit" />}
				<label key="controls" fontName={FONT} fontSize={28} text="WASD / 方向键移动    Esc 暂停    自动攻击" color3={0x78918d} x={rightX} y={compact ? -220 : -156} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}

	private renderCharSelect(): React.Element {
		const save = saveSystem.load();
		const cardW = Math.min(280, W * 0.28);
		const cardH = 172;
		return (
			<node key="chars-content">
				<label key="heading" fontName={FONT} fontSize={52} text="选择收割者" color3={0xf0d38a} x={0} y={H / 2 - 46} anchorX={0.5} anchorY={0.5} />
				<label key="desc" fontName={FONT} fontSize={28} text="不同武器决定整局战斗节奏" color3={0x94aaa5} x={0} y={H / 2 - 92} anchorX={0.5} anchorY={0.5} />
				{CHARACTER_ORDER.map((id, i) => {
					const row = Math.floor(i / 3);
					const count = row === 0 ? 3 : 2;
					const indexInRow = row === 0 ? i : i - 3;
					const x = (indexInRow - (count - 1) / 2) * (cardW + 18);
					const y = 22 - row * (cardH + 14);
					return this.charCard(characters[id], save, x, y, cardW, cardH);
				})}
				{this.button('返回', () => { this.screen.value = 'main'; }, -W / 2 + 105, -H / 2 + 52, 170, 0x334f51)}
			</node>
		);
	}

	private charCard(def: CharacterDef, save: SaveData, x: number, y: number, w: number, h: number): React.Element {
		const unlocked = save.unlockedCharacters.indexOf(def.id) >= 0;
		const cost = UNLOCK_COST[def.id];
		const canAfford = save.gold >= cost;
		const status = unlocked ? '选择角色' : canAfford ? `解锁 ${cost} 金币` : `需要 ${cost} 金币`;
		return (
			<node key={def.id} x={x} y={y} width={w} height={h} touchEnabled={true} swallowTouches={true} onTapped={() => this.onCharTap(def.id, unlocked, cost, canAfford)}>
				<draw-node onMount={(self) => this.drawCard(self, w, h, def.color, unlocked)} />
				<label key={`${def.id}-name`} fontName={FONT} fontSize={38} text={def.name} color3={unlocked ? def.color : 0x77817f} x={w / 2} y={h - 34} anchorX={0.5} anchorY={0.5} />
				<label key={`${def.id}-desc`} fontName={FONT} fontSize={26} text={unlocked ? def.desc : def.unlockHint} color3={unlocked ? 0xc0ceca : 0x8d9a96} textWidth={w - 30} x={w / 2} y={h - 88} anchorX={0.5} anchorY={0.5} />
				<label key={`${def.id}-status`} fontName={FONT} fontSize={24} text={status} color3={unlocked ? 0x8fd8a7 : canAfford ? 0xe2bd64 : 0x8a6a6d} x={w / 2} y={22} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}

	private drawCard(draw: DrawNode.Type, w: number, h: number, color: number, unlocked: boolean): void {
		rect(draw, 4, -4, w, h, Color(0, 0, 0, 80));
		rect(draw, 0, 0, w, h, Color(unlocked ? 25 : 20, unlocked ? 37 : 27, unlocked ? 38 : 29, 248), Color(unlocked ? 102 : 65, unlocked ? 126 : 72, unlocked ? 116 : 74, 255));
		const r = Math.floor(color / 65536) % 256;
		const g = Math.floor(color / 256) % 256;
		const b = color % 256;
		rect(draw, 0, h - 5, w, 5, Color(r, g, b, unlocked ? 255 : 90));
	}

	private onCharTap(id: CharacterId, unlocked: boolean, cost: number, canAfford: boolean): void {
		if (!unlocked && !canAfford) return;
		if (!unlocked) {
			const save = saveSystem.load();
			save.gold -= cost;
			save.unlockedCharacters.push(id);
			saveSystem.save(save);
			this.saveTick.value++;
		}
		this.selectedChar.value = id;
		this.screen.value = 'modes';
	}

	private renderModeSelect(): React.Element {
		const def = characters[this.selectedChar.value];
		return (
			<node key="modes-content">
				<label key="heading" fontName={FONT} fontSize={52} text={`${def.name} · 选择行动`} color3={0xf0d38a} x={0} y={H / 2 - 50} anchorX={0.5} anchorY={0.5} />
				{MODES.map((mode, i) => {
					const x = (i % 2 === 0 ? -1 : 1) * Math.min(205, W * 0.23);
					const y = i < 2 ? 48 : -112;
					return this.modeCard(mode, x, y);
				})}
				{this.button('返回选择角色', () => { this.screen.value = 'chars'; }, -W / 2 + 125, -H / 2 + 52, 210, 0x334f51)}
			</node>
		);
	}

	private modeCard(mode: { mode: GameMode; label: string; desc: string; accent: number }, x: number, y: number): React.Element {
		const w = Math.min(370, W * 0.4);
		const h = 164;
		return (
			<node key={mode.mode} x={x} y={y} width={w} height={h} touchEnabled={true} swallowTouches={true} onTapped={() => this.props.onStart(this.selectedChar.value, mode.mode)}>
				<draw-node onMount={(self) => this.drawCard(self, w, h, mode.accent, true)} />
				<label key={`${mode.mode}-title`} fontName={FONT} fontSize={38} text={mode.label} color3={mode.accent} x={w / 2} y={h - 38} anchorX={0.5} anchorY={0.5} />
				<label key={`${mode.mode}-desc`} fontName={FONT} fontSize={26} text={mode.desc} color3={0xb9c8c4} textWidth={w - 38} x={w / 2} y={h - 94} anchorX={0.5} anchorY={0.5} />
				<label key={`${mode.mode}-action`} fontName={FONT} fontSize={24} text="进入秘境" color3={0xe9ddbf} x={w / 2} y={22} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}

	private renderSettings(): React.Element {
		const save = saveSystem.load();
		const q = save.settings?.quality ?? 1;
		const muted = save.settings?.muted ?? false;
		return (
			<node key="settings-content">
				<label key="heading" fontName={FONT} fontSize={52} text="战斗设置" color3={0xf0d38a} x={0} y={H / 2 - 58} anchorX={0.5} anchorY={0.5} />
				<label key="quality-label" fontName={FONT} fontSize={30} text="同屏单位与特效质量" color3={0xb9c8c4} x={0} y={105} anchorX={0.5} anchorY={0.5} />
				{this.button(q === 0 ? '低 · 当前' : '低', () => this.setQuality(0), -180, 35, 150, q === 0 ? 0xd09a38 : 0x334f51)}
				{this.button(q === 1 ? '中 · 当前' : '中', () => this.setQuality(1), 0, 35, 150, q === 1 ? 0xd09a38 : 0x334f51)}
				{this.button(q === 2 ? '高 · 当前' : '高', () => this.setQuality(2), 180, 35, 150, q === 2 ? 0xd09a38 : 0x334f51)}
				{this.button(muted ? '声音：已关闭' : '声音：已开启', () => this.toggleMuted(), 0, -65, 330, muted ? 0x573f43 : 0x3f6d70)}
				{this.button('返回', () => { this.screen.value = 'main'; }, 0, -155, 220, 0x334f51)}
			</node>
		);
	}

	private setQuality(q: number): void {
		const save = saveSystem.load();
		if (save.settings === undefined) save.settings = { quality: q, sfxVolume: 1, musicVolume: 1, muted: false };
		else save.settings.quality = q;
		Config.quality = q <= 0 ? 0 : q >= 2 ? 2 : 1;
		saveSystem.save(save);
		this.saveTick.value++;
	}

	private toggleMuted(): void {
		const save = saveSystem.load();
		if (save.settings === undefined) save.settings = { quality: 1, sfxVolume: 1, musicVolume: 1, muted: true };
		else save.settings.muted = !save.settings.muted;
		saveSystem.save(save);
		this.saveTick.value++;
	}

	private button(text: string, onTap: () => void, x: number, y: number, width: number, color: number): React.Element {
		const h = 66;
		return (
			<node key={`${text}-${x}-${y}`} x={x} y={y} width={width} height={h} touchEnabled={true} swallowTouches={true} onTapped={onTap}>
				<draw-node onMount={(self) => {
					rect(self, 3, -3, width, h, Color(0, 0, 0, 90));
					const r = Math.floor(color / 65536) % 256;
					const g = Math.floor(color / 256) % 256;
					const b = color % 256;
					rect(self, 0, 0, width, h, Color(r, g, b, 255), Color(Math.min(255, r + 35), Math.min(255, g + 35), Math.min(255, b + 35), 255));
				}} />
				<label key={`${text}-label`} fontName={FONT} fontSize={34} text={text} color3={0xffffff} x={width / 2} y={h / 2} anchorX={0.5} anchorY={0.5} />
			</node>
		);
	}
}
