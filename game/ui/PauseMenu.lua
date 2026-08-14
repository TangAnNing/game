-- [tsx]: PauseMenu.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Director = ____Dora.Director -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local createRoot = ____DoraX.createRoot -- 3
local signal = ____DoraX.signal -- 3
local FONT = "sarasa-mono-sc-regular" -- 7
local W = View.size.width -- 8
local H = View.size.height -- 9
local function rect(draw, x, y, w, h, fill, border) -- 19
	draw:drawPolygon( -- 20
		{ -- 20
			Vec2(x, y), -- 20
			Vec2(x + w, y), -- 20
			Vec2(x + w, y + h), -- 20
			Vec2(x, y + h) -- 20
		}, -- 20
		fill, -- 20
		border ~= nil and 1 or 0, -- 20
		border -- 20
	) -- 20
end -- 19
____exports.PauseMenu = __TS__Class() -- 23
local PauseMenu = ____exports.PauseMenu -- 23
PauseMenu.name = "PauseMenu" -- 23
function PauseMenu.prototype.____constructor(self, props) -- 29
	self.state = signal("hidden") -- 26
	self.stats = signal(nil) -- 27
	self.props = props -- 30
end -- 29
function PauseMenu.prototype.showPause(self) -- 33
	self.state.value = "pause" -- 34
	self:ensureRoot() -- 35
end -- 33
function PauseMenu.prototype.hidePause(self) -- 38
	self.state.value = "hidden" -- 39
	self:unmount() -- 40
end -- 38
function PauseMenu.prototype.showGameOver(self, stats) -- 43
	self.stats.value = stats -- 44
	self.state.value = "gameover" -- 45
	self:ensureRoot() -- 46
end -- 43
function PauseMenu.prototype.showVictory(self, stats) -- 49
	self.stats.value = stats -- 50
	self.state.value = "victory" -- 51
	self:ensureRoot() -- 52
end -- 49
function PauseMenu.prototype.ensureRoot(self) -- 55
	if self.root == nil then -- 55
		self.root = createRoot(Director.ui) -- 56
	end -- 56
	self.root:render(function() return self:renderPanel() end) -- 57
end -- 55
function PauseMenu.prototype.unmount(self) -- 60
	local ____opt_0 = self.root -- 60
	if ____opt_0 ~= nil then -- 60
		____opt_0:unmount() -- 61
	end -- 61
	self.root = nil -- 62
end -- 60
function PauseMenu.prototype.renderPanel(self) -- 65
	local state = self.state.value -- 66
	if state == "hidden" then -- 66
		return {} -- 67
	end -- 67
	local isEnd = state == "gameover" or state == "victory" -- 68
	local stats = self.stats.value -- 69
	local title = state == "pause" and "暂停" or (state == "victory" and "远征完成" or "倒下了") -- 70
	local color = state == "victory" and 9360283 or (state == "gameover" and 14713731 or 15782794) -- 71
	local detail = stats == nil and "" or (((((((((("存活 " .. tostring(math.floor(stats.timeAlive))) .. " 秒    波次 ") .. tostring(stats.wave)) .. "    等级 ") .. tostring(stats.playerLevel)) .. "\n击杀 ") .. tostring(stats.kills)) .. "    精英 ") .. tostring(stats.eliteKills)) .. "    Boss ") .. tostring(stats.bossKills) -- 72
	local ____React_createElement_4 = React.createElement -- 72
	local ____array_3 = __TS__SparseArrayNew( -- 72
		"node", -- 72
		{key = "pause-" .. state}, -- 72
		React.createElement( -- 72
			"draw-node", -- 72
			{ -- 72
				key = "pause-overlay", -- 72
				onMount = function(____self) return rect( -- 72
					____self, -- 75
					-W / 2, -- 75
					-H / 2, -- 75
					W, -- 75
					H, -- 75
					Color(5, 10, 13, 226) -- 75
				) end -- 75
			} -- 75
		), -- 75
		React.createElement( -- 75
			"draw-node", -- 75
			{ -- 75
				key = "pause-panel-bg", -- 75
				onMount = function(____self) return rect( -- 75
					____self, -- 76
					-280, -- 76
					-210, -- 76
					560, -- 76
					420, -- 76
					Color(18, 29, 32, 252), -- 76
					Color(84, 113, 105, 255) -- 76
				) end -- 76
			} -- 76
		), -- 76
		React.createElement("label", { -- 76
			key = "title", -- 76
			fontName = FONT, -- 76
			fontSize = 46, -- 76
			text = title, -- 76
			color3 = color, -- 76
			x = 0, -- 76
			y = 142, -- 76
			anchorX = 0.5, -- 76
			anchorY = 0.5 -- 76
		}) -- 76
	) -- 76
	local ____isEnd_2 -- 78
	if isEnd then -- 78
		____isEnd_2 = React.createElement("label", { -- 78
			key = "detail", -- 78
			fontName = FONT, -- 78
			fontSize = 30, -- 78
			text = detail, -- 78
			color3 = 13687767, -- 78
			textWidth = 490, -- 78
			x = 0, -- 78
			y = 52, -- 78
			anchorX = 0.5, -- 78
			anchorY = 0.5 -- 78
		}) -- 78
	else -- 78
		____isEnd_2 = React.createElement("label", { -- 78
			key = "pause-detail", -- 78
			fontName = FONT, -- 78
			fontSize = 28, -- 78
			text = "战场状态已保存，继续后不会丢失进度", -- 78
			color3 = 11123637, -- 78
			x = 0, -- 78
			y = 52, -- 78
			anchorX = 0.5, -- 78
			anchorY = 0.5 -- 78
		}) -- 78
	end -- 78
	__TS__SparseArrayPush( -- 78
		____array_3, -- 78
		____isEnd_2, -- 78
		state == "pause" and self:button( -- 79
			"继续远征", -- 79
			function() return self.props:onResume() end, -- 79
			0, -- 79
			-45, -- 79
			290, -- 79
			4156784 -- 79
		) or self:button( -- 79
			"再战一次", -- 79
			function() return self.props:onRestart() end, -- 79
			0, -- 79
			-45, -- 79
			290, -- 79
			13670968 -- 79
		), -- 79
		self:button( -- 80
			"返回大厅", -- 80
			function() return self.props:onQuit() end, -- 80
			0, -- 80
			-120, -- 80
			290, -- 80
			3362641 -- 80
		) -- 80
	) -- 80
	return ____React_createElement_4(__TS__SparseArraySpread(____array_3)) -- 73
end -- 65
function PauseMenu.prototype.button(self, text, onTap, x, y, width, color) -- 85
	local h = 60 -- 86
	return React.createElement( -- 87
		"node", -- 87
		{ -- 87
			key = (((text .. "-") .. tostring(x)) .. "-") .. tostring(y), -- 87
			x = x, -- 87
			y = y, -- 87
			width = width, -- 87
			height = h, -- 87
			touchEnabled = true, -- 87
			swallowTouches = true, -- 87
			onTapped = onTap -- 87
		}, -- 87
		React.createElement( -- 87
			"draw-node", -- 87
			{onMount = function(____self) -- 87
				local r = math.floor(color / 65536) % 256 -- 90
				local g = math.floor(color / 256) % 256 -- 91
				local b = color % 256 -- 92
				rect( -- 93
					____self, -- 93
					0, -- 93
					0, -- 93
					width, -- 93
					h, -- 93
					Color(r, g, b, 255) -- 93
				) -- 93
			end} -- 89
		), -- 89
		React.createElement("label", { -- 89
			key = text .. "-label", -- 89
			fontName = FONT, -- 89
			fontSize = 34, -- 89
			text = text, -- 89
			color3 = 16777215, -- 89
			x = width / 2, -- 89
			y = h / 2, -- 89
			anchorX = 0.5, -- 89
			anchorY = 0.5 -- 89
		}) -- 89
	) -- 89
end -- 85
return ____exports -- 85