// 泛型对象池：复用实体避免 GC 抖动
export class ObjectPool<T extends object> {
	private free: T[] = [];
	private factory: () => T;
	private resetFn: (item: T) => void;

	constructor(factory: () => T, resetFn: (item: T) => void) {
		this.factory = (): T => factory();
		this.resetFn = (item: T): void => resetFn(item);
	}

	// 预分配
	prewarm(count: number): void {
		for (let i = 0; i < count; i++) {
			this.free.push(this.factory());
		}
	}

	// 取一个（无空闲则新建）
	acquire(): T {
		const item = this.free.pop();
		if (item !== undefined) return item;
		return this.factory();
	}

	// 归还并重置
	release(item: T): void {
		this.resetFn(item);
		this.free.push(item);
	}

	// 当前空闲数量
	get freeCount(): number {
		return this.free.length;
	}

	// 清空池
	clear(): void {
		this.free.length = 0;
	}
}
