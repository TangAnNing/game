// 数学工具：Vec2 的 x/y 是 readonly，一律返回新 Vec2。禁用 Math.hypot。
import { Color, Vec2 } from 'Dora';

export const TWO_PI = Math.PI * 2;

// 距离平方（性能优先，避免开方）
export function distSq(a: Vec2.Type, b: Vec2.Type): number {
	const dx = a.x - b.x;
	const dy = a.y - b.y;
	return dx * dx + dy * dy;
}

// 距离
export function dist(a: Vec2.Type, b: Vec2.Type): number {
	return Math.sqrt(distSq(a, b));
}

// 归一化（零向量返回零向量）
export function normalize(v: Vec2.Type): Vec2.Type {
	const len = v.length;
	if (len < 0.0001) return Vec2.zero;
	return Vec2(v.x / len, v.y / len);
}

// 从 a 指向 b 的单位向量
export function dirTo(a: Vec2.Type, b: Vec2.Type): Vec2.Type {
	return normalize(Vec2(b.x - a.x, b.y - a.y));
}

// 向量乘标量
export function scale(v: Vec2.Type, s: number): Vec2.Type {
	return Vec2(v.x * s, v.y * s);
}

// 颜色工具：Dora Color 工厂接受 ARGB 整数/Color3/四通道，不直接接受 0xRRGGBB
// rgb 为 0xRRGGBB，alpha 0-255；返回可直接传给 drawDot/drawPolygon 的 Color
export function colorOf(rgb: number, alpha = 255): Color.Type {
	// 用 ARGB 整数合成：Color(argb)
	return Color(((alpha & 0xff) << 24) | (rgb & 0xffffff));
}

// ARGB 合成：color 为 0xRRGGBB，alpha 0-255（Dora Color(argb) 无两参重载，需合成 ARGB 整数）
export function withAlpha(color: number, alpha: number): number {
	return ((alpha & 0xff) << 24) | (color & 0xffffff);
}

// 向量相加
export function add(a: Vec2.Type, b: Vec2.Type): Vec2.Type {
	return Vec2(a.x + b.x, a.y + b.y);
}

// 向量相减
export function sub(a: Vec2.Type, b: Vec2.Type): Vec2.Type {
	return Vec2(a.x - b.x, a.y - b.y);
}

// 线性插值
export function lerp(a: number, b: number, t: number): number {
	return a + (b - a) * t;
}

// Vec2 线性插值
export function lerpVec(a: Vec2.Type, b: Vec2.Type, t: number): Vec2.Type {
	return Vec2(lerp(a.x, b.x, t), lerp(a.y, b.y, t));
}

// 限制在 [min, max]
export function clamp(v: number, min: number, max: number): number {
	return v < min ? min : v > max ? max : v;
}

// 角度归一化到 [-PI, PI]
export function wrapAngle(a: number): number {
	while (a > Math.PI) a -= TWO_PI;
	while (a < -Math.PI) a += TWO_PI;
	return a;
}

// 朝向角度的单位向量
export function angleToVec(angle: number): Vec2.Type {
	return Vec2(Math.cos(angle), Math.sin(angle));
}

// 两点朝向角度
export function angleBetween(a: Vec2.Type, b: Vec2.Type): number {
	return Math.atan2(b.y - a.y, b.x - a.x);
}

// 平滑阻尼（帧率无关的指数趋近）
export function damp(current: number, target: number, lambda: number, dt: number): number {
	return lerp(current, target, 1 - Math.exp(-lambda * dt));
}

// 缓动函数
export function easeOutCubic(t: number): number {
	const u = 1 - t;
	return 1 - u * u * u;
}

export function easeInOutQuad(t: number): number {
	return t < 0.5 ? 2 * t * t : 1 - 2 * (1 - t) * (1 - t);
}

// 判断点是否在扇形内（origin 原点，facing 朝向角，halfAngle 半角弧度，range 半径）
export function inArc(origin: Vec2.Type, point: Vec2.Type, facing: number, halfAngle: number, range: number): boolean {
	const d = sub(point, origin);
	if (d.length > range) return false;
	const ang = Math.atan2(d.y, d.x);
	return Math.abs(wrapAngle(ang - facing)) <= halfAngle;
}
