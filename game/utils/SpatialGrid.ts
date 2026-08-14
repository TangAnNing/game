// 空间哈希网格：同屏碰撞查询优化
// 用法：每帧 clear() 后 rehash()，或对移动实体 update()；queryRange() 取邻域
import { Vec2 } from 'Dora';

export interface GridItem {
	pos: Vec2.Type;
	radius: number;
}

export class SpatialGrid {
	private cellSize: number;
	private cells = new Map<number, number[]>();
	private items: GridItem[] = [];

	constructor(cellSize = 64) {
		this.cellSize = cellSize;
	}

	private key(cx: number, cy: number): number {
		// 简单的哈希组合（避免字符串拼接开销）
		return (cx + 4096) * 8192 + (cy + 4096);
	}

	clear(): void {
		this.cells.clear();
		this.items.length = 0;
	}

	add(item: GridItem): void {
		this.items.push(item);
		const cx = Math.floor(item.pos.x / this.cellSize);
		const cy = Math.floor(item.pos.y / this.cellSize);
		const k = this.key(cx, cy);
		const cell = this.cells.get(k);
		if (cell !== undefined) {
			cell.push(this.items.length - 1);
		} else {
			this.cells.set(k, [this.items.length - 1]);
		}
	}

	// 查询点所在单元格
	private cellIndices(cx: number, cy: number): number[] {
		const k = this.key(cx, cy);
		const cell = this.cells.get(k);
		return cell !== undefined ? cell : [];
	}

	// 查询以 pos 为中心、radius 半径内的所有 item 索引（含边界）
	query(pos: Vec2.Type, radius: number): number[] {
		const minX = Math.floor((pos.x - radius) / this.cellSize);
		const maxX = Math.floor((pos.x + radius) / this.cellSize);
		const minY = Math.floor((pos.y - radius) / this.cellSize);
		const maxY = Math.floor((pos.y + radius) / this.cellSize);
		const result: number[] = [];
		for (let cx = minX; cx <= maxX; cx++) {
			for (let cy = minY; cy <= maxY; cy++) {
				const cell = this.cellIndices(cx, cy);
				for (let i = 0; i < cell.length; i++) {
					result.push(cell[i]);
				}
			}
		}
		return result;
	}

	// 查询并过滤出真正相交的 item
	queryHit(pos: Vec2.Type, radius: number, out: GridItem[]): void {
		out.length = 0;
		const idxs = this.query(pos, radius);
		const rr = radius + 0.001;
		for (let i = 0; i < idxs.length; i++) {
			const item = this.items[idxs[i]];
			const dx = item.pos.x - pos.x;
			const dy = item.pos.y - pos.y;
			const r = item.radius + rr;
			if (dx * dx + dy * dy <= r * r) {
				out.push(item);
			}
		}
	}

	get itemCount(): number {
		return this.items.length;
	}

	// 直接访问 item（索引来自 query）
	itemAt(index: number): GridItem {
		return this.items[index];
	}
}
