-- [ts]: Feedback.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____MathUtils = require("game.utils.MathUtils") -- 5
local withAlpha = ____MathUtils.withAlpha -- 5
____exports.Feedback = __TS__Class() -- 24
local Feedback = ____exports.Feedback -- 24
Feedback.name = "Feedback" -- 24
function Feedback.prototype.____constructor(self, cameraRig, uiRoot) -- 32
	self.texts = {} -- 27
	self.flashes = {} -- 28
	self.hitStopRemaining = 0 -- 30
	self.cameraRig = cameraRig -- 33
	self.uiRoot = uiRoot ~= nil and uiRoot or Director.entry -- 34
	Director.scheduler.timeScale = 1 -- 36
	self:bind() -- 37
end -- 32
function Feedback.prototype.bind(self) -- 40
	ctx.feedback = { -- 41
		spawnDamageText = function(____, pos, amount, crit) return self:spawnDamageText(pos, amount, crit) end, -- 42
		spawnFlash = function(____, pos, color) return self:spawnFlash(pos, color) end, -- 43
		shake = function(____, strength) return self:shake(strength) end, -- 44
		hitStop = function(____, duration) return self:hitStop(duration) end -- 45
	} -- 45
end -- 40
function Feedback.prototype.hitStop(self, duration) -- 50
	if duration <= 0 then -- 50
		return -- 51
	end -- 51
	if Director.scheduler.timeScale < 1 then -- 51
		self.hitStopRemaining = math.max(self.hitStopRemaining, duration * Director.scheduler.timeScale) -- 54
		return -- 55
	end -- 55
	Director.scheduler.timeScale = 0.05 -- 57
	self.hitStopRemaining = duration * 0.05 -- 58
end -- 50
function Feedback.prototype.shake(self, strength) -- 62
	self.cameraRig:shake(strength) -- 63
end -- 62
function Feedback.prototype.spawnDamageText(self, pos, amount, crit) -- 67
	local label = Label("sarasa-mono-sc-regular", crit and 36 or 26) -- 68
	if label == nil then -- 68
		return -- 69
	end -- 69
	local text = crit and "" .. tostring(math.floor(amount + 0.5)) or "" .. tostring(math.floor(amount)) -- 70
	label.text = text -- 71
	label.position = Vec2(pos.x + 6, pos.y + 10) -- 72
	label.color = Color(crit and 4294951997 or 4294438626) -- 73
	label:addTo(self.uiRoot) -- 74
	local ____self_texts_0 = self.texts -- 74
	____self_texts_0[#____self_texts_0 + 1] = {node = label, life = 0.5, maxLife = 0.5, vy = crit and 70 or 55} -- 75
end -- 67
function Feedback.prototype.spawnFlash(self, pos, color) -- 84
	local node = DrawNode() -- 85
	node.position = Vec2(pos.x, pos.y) -- 86
	node:addTo(self.uiRoot) -- 87
	local ____self_flashes_1 = self.flashes -- 87
	____self_flashes_1[#____self_flashes_1 + 1] = { -- 88
		node = node, -- 89
		life = 0.12, -- 90
		maxLife = 0.12, -- 91
		radius = 14, -- 92
		color = color -- 93
	} -- 93
end -- 84
function Feedback.prototype.update(self, dt) -- 97
	if self.hitStopRemaining > 0 then -- 97
		self.hitStopRemaining = self.hitStopRemaining - dt -- 100
		if self.hitStopRemaining <= 0 then -- 100
			Director.scheduler.timeScale = 1 -- 102
		end -- 102
	end -- 102
	do -- 102
		local i = #self.texts - 1 -- 106
		while i >= 0 do -- 106
			do -- 106
				local t = self.texts[i + 1] -- 107
				t.life = t.life - dt -- 108
				if t.life <= 0 then -- 108
					t.node:removeFromParent() -- 110
					__TS__ArraySplice(self.texts, i, 1) -- 111
					goto __continue19 -- 112
				end -- 112
				local p = t.node.position -- 114
				t.node.position = Vec2(p.x, p.y + t.vy * dt) -- 115
				t.node.opacity = t.life / t.maxLife -- 116
			end -- 116
			::__continue19:: -- 116
			i = i - 1 -- 106
		end -- 106
	end -- 106
	do -- 106
		local i = #self.flashes - 1 -- 119
		while i >= 0 do -- 119
			do -- 119
				local f = self.flashes[i + 1] -- 120
				f.life = f.life - dt -- 121
				if f.life <= 0 then -- 121
					f.node:removeFromParent() -- 123
					__TS__ArraySplice(self.flashes, i, 1) -- 124
					goto __continue22 -- 125
				end -- 125
				f.node:clear() -- 127
				local t = 1 - f.life / f.maxLife -- 128
				local alpha = (1 - t) * 255 -- 129
				local radius = f.radius * (1 - t * 0.4) -- 130
				local verts = {} -- 131
				do -- 131
					local i2 = 0 -- 132
					while i2 < 16 do -- 132
						local a = i2 / 16 * math.pi * 2 -- 133
						verts[#verts + 1] = Vec2( -- 134
							math.cos(a) * radius, -- 134
							math.sin(a) * radius -- 134
						) -- 134
						i2 = i2 + 1 -- 132
					end -- 132
				end -- 132
				verts[#verts + 1] = Vec2.zero -- 136
				f.node:drawPolygon( -- 137
					verts, -- 137
					Color(withAlpha( -- 137
						f.color, -- 137
						math.floor(alpha + 0.5) -- 137
					)) -- 137
				) -- 137
			end -- 137
			::__continue22:: -- 137
			i = i - 1 -- 119
		end -- 119
	end -- 119
end -- 97
function Feedback.prototype.clear(self) -- 142
	do -- 142
		local i = #self.texts - 1 -- 143
		while i >= 0 do -- 143
			self.texts[i + 1].node:removeFromParent() -- 144
			__TS__ArraySplice(self.texts, i, 1) -- 145
			i = i - 1 -- 143
		end -- 143
	end -- 143
	do -- 143
		local i = #self.flashes - 1 -- 147
		while i >= 0 do -- 147
			self.flashes[i + 1].node:removeFromParent() -- 148
			__TS__ArraySplice(self.flashes, i, 1) -- 149
			i = i - 1 -- 147
		end -- 147
	end -- 147
	Director.scheduler.timeScale = 1 -- 151
	self.hitStopRemaining = 0 -- 152
end -- 142
return ____exports -- 142