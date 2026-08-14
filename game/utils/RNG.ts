// LCG 随机数（Dora 无 Math.random）
export class RNG {
	private state: number;

	constructor(seed?: number) {
		this.state = seed !== undefined ? seed >>> 0 : 0x1234abcd;
	}

	setSeed(seed: number): void {
		this.state = seed >>> 0;
	}

	// 返回 [0, 1) 浮点
	next(): number {
		// 使用 32 位乘法低位保持随机性
		this.state = (this.state * 1664525 + 1013904223) >>> 0;
		return this.state / 4294967296;
	}

	// 返回 [min, max] 整数
	int(min: number, max: number): number {
		if (max <= min) return min;
		return min + Math.floor(this.next() * (max - min + 1));
	}

	// 返回 [min, max) 浮点
	range(min: number, max: number): number {
		return min + this.next() * (max - min);
	}

// 从数组随机取一个（TSTL：Lua 数组不能含 nil，泛型约束放宽松以支持 string 数组）
	pick<T extends object>(arr: T[]): T {
		return arr[this.int(0, arr.length - 1)] as T;
	}

	// 从字符串数组随机取一个（pick 泛型约束 object 时用这个）
	pickString(arr: string[]): string {
		const i = this.int(0, arr.length - 1);
		const v = arr[i];
		return v !== undefined ? v : '';
	}

	// 概率判定（0..1）
	chance(p: number): boolean {
		return this.next() < p;
	}

	// 以 mean 为中心的正态近似（中心极限定理，n=3）
	gauss(mean: number, std: number): number {
		let sum = 0;
		for (let i = 0; i < 3; i++) sum += this.next();
		return mean + (sum - 1.5) * 2 * std;
	}
}

// 全局随机源（种子可被调试面板重置）
export const rng = new RNG();
