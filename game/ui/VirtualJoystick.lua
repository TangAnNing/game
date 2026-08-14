-- [ts]: VirtualJoystick.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
local circleVertsAt, drawRing -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Node = ____Dora.Node -- 3
local Size = ____Dora.Size -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
function circleVertsAt(center, radius, segments) -- 113
	local verts = {} -- 114
	do -- 114
		local i = 0 -- 115
		while i < segments do -- 115
			local a = i / segments * math.pi * 2 -- 116
			verts[#verts + 1] = Vec2( -- 117
				center.x + math.cos(a) * radius, -- 117
				center.y + math.sin(a) * radius -- 117
			) -- 117
			i = i + 1 -- 115
		end -- 115
	end -- 115
	return verts -- 119
end -- 119
function drawRing(draw, center, radius, segments, width, color) -- 122
	local points = circleVertsAt(center, radius, segments) -- 123
	do -- 123
		local i = 0 -- 124
		while i < #points do -- 124
			draw:drawSegment(points[i + 1], points[(i + 1) % #points + 1], width, color) -- 124
			i = i + 1 -- 124
		end -- 124
	end -- 124
end -- 124
local STICK_RADIUS = 90 -- 6
local KNOB_RADIUS = 36 -- 7
local DEAD_ZONE = 0.15 -- 8
____exports.VirtualJoystick = __TS__Class() -- 10
local VirtualJoystick = ____exports.VirtualJoystick -- 10
VirtualJoystick.name = "VirtualJoystick" -- 10
function VirtualJoystick.prototype.____constructor(self, uiRoot) -- 20
	self._visible = true -- 14
	self.active = false -- 15
	self.offset = Vec2(0, 0) -- 16
	local w = View.size.width -- 21
	local h = View.size.height -- 22
	self.baseCenter = Vec2(-w / 2 + 150, -h / 2 + 150) -- 23
	self.root = Node() -- 25
	local base = DrawNode() -- 26
	base:drawDot( -- 27
		self.baseCenter, -- 27
		STICK_RADIUS, -- 27
		Color(14, 31, 33, 125) -- 27
	) -- 27
	base:drawDot( -- 28
		self.baseCenter, -- 28
		STICK_RADIUS - 12, -- 28
		Color(62, 112, 106, 42) -- 28
	) -- 28
	drawRing( -- 29
		base, -- 29
		self.baseCenter, -- 29
		STICK_RADIUS - 2, -- 29
		24, -- 29
		3, -- 29
		Color(94, 151, 139, 115) -- 29
	) -- 29
	self.knob = DrawNode() -- 30
	self:drawKnob(self.baseCenter) -- 31
	base:addTo(self.root) -- 32
	self.knob:addTo(self.root) -- 33
	self.root:addTo(uiRoot) -- 34
	self.touchNode = Node() -- 37
	self.touchNode.size = Size(w, h) -- 38
	self.touchNode.touchEnabled = true -- 39
	self.touchNode.swallowTouches = true -- 40
	self.touchNode:onTapBegan(function(touch) return self:onBegan(touch) end) -- 41
	self.touchNode:onTapMoved(function(touch) return self:onMoved(touch) end) -- 42
	self.touchNode:onTapEnded(function() return self:onEnded() end) -- 43
	self.touchNode:addTo(uiRoot) -- 44
end -- 20
function VirtualJoystick.prototype.setVisible(self, v) -- 51
	self._visible = v -- 52
	self.root.visible = v -- 53
	self.touchNode.visible = v -- 54
	if not v then -- 54
		self:onEnded() -- 55
	end -- 55
end -- 51
function VirtualJoystick.prototype.toScreen(self, ____local) -- 68
	return Vec2(____local.x - View.size.width / 2, ____local.y - View.size.height / 2) -- 69
end -- 68
function VirtualJoystick.prototype.onBegan(self, touch) -- 72
	local p = self:toScreen(touch.location) -- 73
	if p.x >= 0 or p.y >= 0 then -- 73
		return -- 75
	end -- 75
	self.active = true -- 76
	self:updateKnob(p) -- 77
end -- 72
function VirtualJoystick.prototype.onMoved(self, touch) -- 80
	if not self.active then -- 80
		return -- 81
	end -- 81
	self:updateKnob(self:toScreen(touch.location)) -- 82
end -- 80
function VirtualJoystick.prototype.onEnded(self) -- 85
	if not self.active then -- 85
		return -- 86
	end -- 86
	self.active = false -- 87
	self.offset = Vec2(0, 0) -- 88
	self.knob:clear() -- 89
	self:drawKnob(self.baseCenter) -- 90
end -- 85
function VirtualJoystick.prototype.updateKnob(self, p) -- 93
	local ox = p.x - self.baseCenter.x -- 94
	local oy = p.y - self.baseCenter.y -- 95
	local len = math.sqrt(ox * ox + oy * oy) -- 96
	if len > STICK_RADIUS then -- 96
		ox = ox / len * STICK_RADIUS -- 98
		oy = oy / len * STICK_RADIUS -- 99
	end -- 99
	self.offset = Vec2(ox, oy) -- 101
	self.knob:clear() -- 102
	self:drawKnob(Vec2(self.baseCenter.x + ox, self.baseCenter.y + oy)) -- 103
end -- 93
function VirtualJoystick.prototype.drawKnob(self, center) -- 106
	self.knob:drawDot( -- 107
		center, -- 107
		KNOB_RADIUS, -- 107
		Color(208, 161, 65, 185) -- 107
	) -- 107
	self.knob:drawDot( -- 108
		center, -- 108
		KNOB_RADIUS - 9, -- 108
		Color(46, 72, 70, 235) -- 108
	) -- 108
	drawRing( -- 109
		self.knob, -- 109
		center, -- 109
		KNOB_RADIUS, -- 109
		18, -- 109
		2, -- 109
		Color(244, 212, 139, 190) -- 109
	) -- 109
end -- 106
__TS__SetDescriptor( -- 106
	VirtualJoystick.prototype, -- 106
	"isVisible", -- 106
	{get = function(self) -- 106
		return self._visible -- 48
	end}, -- 48
	true -- 48
) -- 48
__TS__SetDescriptor( -- 48
	VirtualJoystick.prototype, -- 48
	"moveDir", -- 48
	{get = function(self) -- 48
		local dx = self.offset.x / STICK_RADIUS -- 59
		local dy = self.offset.y / STICK_RADIUS -- 60
		local len = math.sqrt(dx * dx + dy * dy) -- 61
		if len < DEAD_ZONE then -- 61
			return Vec2(0, 0) -- 62
		end -- 62
		if len > 1 then -- 62
			return Vec2(dx / len, dy / len) -- 63
		end -- 63
		return Vec2(dx, dy) -- 64
	end}, -- 64
	true -- 64
) -- 64
return ____exports -- 64