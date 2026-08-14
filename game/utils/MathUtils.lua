-- [ts]: MathUtils.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Vec2 = ____Dora.Vec2 -- 2
____exports.TWO_PI = math.pi * 2 -- 4
function ____exports.distSq(a, b) -- 7
	local dx = a.x - b.x -- 8
	local dy = a.y - b.y -- 9
	return dx * dx + dy * dy -- 10
end -- 7
function ____exports.dist(a, b) -- 14
	return math.sqrt(____exports.distSq(a, b)) -- 15
end -- 14
function ____exports.normalize(v) -- 19
	local len = v.length -- 20
	if len < 0.0001 then -- 20
		return Vec2.zero -- 21
	end -- 21
	return Vec2(v.x / len, v.y / len) -- 22
end -- 19
function ____exports.dirTo(a, b) -- 26
	return ____exports.normalize(Vec2(b.x - a.x, b.y - a.y)) -- 27
end -- 26
function ____exports.scale(v, s) -- 31
	return Vec2(v.x * s, v.y * s) -- 32
end -- 31
function ____exports.colorOf(rgb, alpha) -- 37
	if alpha == nil then -- 37
		alpha = 255 -- 37
	end -- 37
	return Color((alpha & 255) << 24 | rgb & 16777215) -- 39
end -- 37
function ____exports.withAlpha(color, alpha) -- 43
	return (alpha & 255) << 24 | color & 16777215 -- 44
end -- 43
function ____exports.add(a, b) -- 48
	return Vec2(a.x + b.x, a.y + b.y) -- 49
end -- 48
function ____exports.sub(a, b) -- 53
	return Vec2(a.x - b.x, a.y - b.y) -- 54
end -- 53
function ____exports.lerp(a, b, t) -- 58
	return a + (b - a) * t -- 59
end -- 58
function ____exports.lerpVec(a, b, t) -- 63
	return Vec2( -- 64
		____exports.lerp(a.x, b.x, t), -- 64
		____exports.lerp(a.y, b.y, t) -- 64
	) -- 64
end -- 63
function ____exports.clamp(v, min, max) -- 68
	return v < min and min or (v > max and max or v) -- 69
end -- 68
function ____exports.wrapAngle(a) -- 73
	while a > math.pi do -- 73
		a = a - ____exports.TWO_PI -- 74
	end -- 74
	while a < -math.pi do -- 74
		a = a + ____exports.TWO_PI -- 75
	end -- 75
	return a -- 76
end -- 73
function ____exports.angleToVec(angle) -- 80
	return Vec2( -- 81
		math.cos(angle), -- 81
		math.sin(angle) -- 81
	) -- 81
end -- 80
function ____exports.angleBetween(a, b) -- 85
	return math.atan(b.y - a.y, b.x - a.x) -- 86
end -- 85
function ____exports.damp(current, target, lambda, dt) -- 90
	return ____exports.lerp( -- 91
		current, -- 91
		target, -- 91
		1 - math.exp(-lambda * dt) -- 91
	) -- 91
end -- 90
function ____exports.easeOutCubic(t) -- 95
	local u = 1 - t -- 96
	return 1 - u * u * u -- 97
end -- 95
function ____exports.easeInOutQuad(t) -- 100
	return t < 0.5 and 2 * t * t or 1 - 2 * (1 - t) * (1 - t) -- 101
end -- 100
function ____exports.inArc(origin, point, facing, halfAngle, range) -- 105
	local d = ____exports.sub(point, origin) -- 106
	if d.length > range then -- 106
		return false -- 107
	end -- 107
	local ang = math.atan(d.y, d.x) -- 108
	return math.abs(____exports.wrapAngle(ang - facing)) <= halfAngle -- 109
end -- 105
return ____exports -- 105