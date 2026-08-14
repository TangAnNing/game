-- [tsx]: LevelUpPanel.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Vec2 = ____Dora.Vec2 -- 2
local View = ____Dora.View -- 2
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local createRoot = ____DoraX.createRoot -- 3
local signal = ____DoraX.signal -- 3
local FONT = "sarasa-mono-sc-regular" -- 7
local W = View.size.width -- 8
local H = View.size.height -- 9
local RARITY_RGB = {common = {157, 169, 170}, rare = {82, 164, 218}, epic = {196, 111, 238}} -- 10
local function rect(draw, x, y, w, h, fill, border) -- 16
	draw:drawPolygon( -- 17
		{ -- 17
			Vec2(x, y), -- 17
			Vec2(x + w, y), -- 17
			Vec2(x + w, y + h), -- 17
			Vec2(x, y + h) -- 17
		}, -- 17
		fill, -- 17
		border ~= nil and 2 or 0, -- 17
		border -- 17
	) -- 17
end -- 16
____exports.LevelUpPanel = __TS__Class() -- 20
local LevelUpPanel = ____exports.LevelUpPanel -- 20
LevelUpPanel.name = "LevelUpPanel" -- 20
function LevelUpPanel.prototype.____constructor(self, parent) -- 26
	self.visible = signal(false) -- 21
	self.choices = signal({}) -- 22
	self.root = createRoot(parent) -- 27
	self.root:render(function() return self:renderPanel() end) -- 28
end -- 26
function LevelUpPanel.prototype.show(self, choices) -- 31
	self.choices.value = choices -- 32
	self.visible.value = true -- 33
end -- 31
function LevelUpPanel.prototype.hide(self) -- 36
	self.visible.value = false -- 37
	self.choices.value = {} -- 38
end -- 36
function LevelUpPanel.prototype.dispose(self) -- 41
	self.root:unmount() -- 42
end -- 41
function LevelUpPanel.prototype.renderPanel(self) -- 45
	if not self.visible.value then -- 45
		return {} -- 46
	end -- 46
	local cardW = math.min(272, W * 0.285) -- 47
	local cardH = 286 -- 48
	local gap = math.min(28, W * 0.035) -- 49
	return React.createElement( -- 50
		"node", -- 50
		{key = "levelup-panel"}, -- 50
		React.createElement( -- 50
			"draw-node", -- 50
			{ -- 50
				key = "levelup-overlay", -- 50
				onMount = function(____self) return rect( -- 50
					____self, -- 52
					-W / 2, -- 52
					-H / 2, -- 52
					W, -- 52
					H, -- 52
					Color(5, 10, 13, 232) -- 52
				) end -- 52
			} -- 52
		), -- 52
		React.createElement("label", { -- 52
			key = "levelup-title", -- 52
			fontName = FONT, -- 52
			fontSize = 42, -- 52
			text = "力量觉醒", -- 52
			color3 = 15782794, -- 52
			x = 0, -- 52
			y = H / 2 - 54, -- 52
			anchorX = 0.5, -- 52
			anchorY = 0.5 -- 52
		}), -- 52
		React.createElement("label", { -- 52
			key = "levelup-subtitle", -- 52
			fontName = FONT, -- 52
			fontSize = 28, -- 52
			text = "战场已冻结 · 选择一项强化继续远征", -- 52
			color3 = 10335406, -- 52
			x = 0, -- 52
			y = H / 2 - 98, -- 52
			anchorX = 0.5, -- 52
			anchorY = 0.5 -- 52
		}), -- 52
		__TS__ArrayMap( -- 55
			self.choices.value, -- 55
			function(____, def, index) return self:renderCard( -- 55
				def, -- 55
				index, -- 55
				cardW, -- 55
				cardH, -- 55
				gap -- 55
			) end -- 55
		) -- 55
	) -- 55
end -- 45
function LevelUpPanel.prototype.renderCard(self, def, index, w, h, gap) -- 60
	local rgb = RARITY_RGB[def.rarity] -- 61
	local color = rgb[1] << 16 | rgb[2] << 8 | rgb[3] -- 62
	local x = (index - 1) * (w + gap) -- 63
	local tag = def.active and "主动技能" or (def.exclusive ~= nil and "职业专属" or "被动强化") -- 64
	return React.createElement( -- 65
		"node", -- 65
		{ -- 65
			key = def.id, -- 65
			x = x, -- 65
			y = -146, -- 65
			width = w, -- 65
			height = h, -- 65
			touchEnabled = true, -- 65
			swallowTouches = true, -- 65
			onTapped = function() -- 65
				local ____opt_0 = self.onPick -- 65
				return ____opt_0 and ____opt_0(self, index) -- 66
			end -- 66
		}, -- 66
		React.createElement( -- 66
			"draw-node", -- 66
			{onMount = function(____self) -- 66
				rect( -- 68
					____self, -- 68
					5, -- 68
					-5, -- 68
					w, -- 68
					h, -- 68
					Color(0, 0, 0, 120) -- 68
				) -- 68
				rect( -- 69
					____self, -- 69
					0, -- 69
					0, -- 69
					w, -- 69
					h, -- 69
					Color(23, 32, 36, 255), -- 69
					Color(rgb[1], rgb[2], rgb[3], 255) -- 69
				) -- 69
				rect( -- 70
					____self, -- 70
					0, -- 70
					h - 7, -- 70
					w, -- 70
					7, -- 70
					Color(rgb[1], rgb[2], rgb[3], 255) -- 70
				) -- 70
			end} -- 67
		), -- 67
		React.createElement("label", { -- 67
			key = def.id .. "-tag", -- 67
			fontName = FONT, -- 67
			fontSize = 24, -- 67
			text = tag, -- 67
			color3 = color, -- 67
			x = w / 2, -- 67
			y = h - 32, -- 67
			anchorX = 0.5, -- 67
			anchorY = 0.5 -- 67
		}), -- 67
		React.createElement("label", { -- 67
			key = def.id .. "-name", -- 67
			fontName = FONT, -- 67
			fontSize = 38, -- 67
			text = def.name, -- 67
			color3 = 16118504, -- 67
			x = w / 2, -- 67
			y = h - 82, -- 67
			anchorX = 0.5, -- 67
			anchorY = 0.5 -- 67
		}), -- 67
		React.createElement("label", { -- 67
			key = def.id .. "-desc", -- 67
			fontName = FONT, -- 67
			fontSize = 27, -- 67
			text = def.desc, -- 67
			color3 = 12043970, -- 67
			textWidth = w - 38, -- 67
			x = w / 2, -- 67
			y = h - 154, -- 67
			anchorX = 0.5, -- 67
			anchorY = 0.5 -- 67
		}), -- 67
		React.createElement("label", { -- 67
			key = def.id .. "-action", -- 67
			fontName = FONT, -- 67
			fontSize = 26, -- 67
			text = "点击选择", -- 67
			color3 = 15326655, -- 67
			x = w / 2, -- 67
			y = 28, -- 67
			anchorX = 0.5, -- 67
			anchorY = 0.5 -- 67
		}) -- 67
	) -- 67
end -- 60
return ____exports -- 60