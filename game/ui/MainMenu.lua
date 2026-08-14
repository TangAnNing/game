-- [tsx]: MainMenu.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local createRoot = ____DoraX.createRoot -- 2
local signal = ____DoraX.signal -- 2
local ____Dora = require("Dora") -- 4
local Color = ____Dora.Color -- 4
local Director = ____Dora.Director -- 4
local Vec2 = ____Dora.Vec2 -- 4
local View = ____Dora.View -- 4
local ____Characters = require("game.player.Characters") -- 5
local characters = ____Characters.characters -- 5
local ____Save = require("game.save.Save") -- 6
local saveSystem = ____Save.saveSystem -- 6
local ____Config = require("game.config.Config") -- 7
local Config = ____Config.Config -- 7
local FONT = "sarasa-mono-sc-regular" -- 10
local W = View.size.width -- 11
local H = View.size.height -- 12
local UNLOCK_COST = { -- 21
	swordsman = 0, -- 22
	mage = 300, -- 23
	druid = 0, -- 24
	gunner = 300, -- 25
	necromancer = 1200 -- 26
} -- 26
local CHARACTER_ORDER = { -- 29
	"swordsman", -- 29
	"mage", -- 29
	"druid", -- 29
	"gunner", -- 29
	"necromancer" -- 29
} -- 29
local MODES = {{mode = "chapter", label = "章节远征", desc = "10 波战斗，击败深渊领主", accent = 14263361}, {mode = "endless", label = "无尽深潜", desc = "10 波后持续强化，挑战最高记录", accent = 5809880}, {mode = "challenge", label = "高压试炼", desc = "敌人生命 +35%，坚持到第 12 波", accent = 14048348}, {mode = "daily", label = "每日秘境", desc = "固定种子，所有人面对相同战局", accent = 6667650}} -- 31
local function rect(draw, x, y, w, h, fill, border) -- 38
	draw:drawPolygon( -- 39
		{ -- 39
			Vec2(x, y), -- 39
			Vec2(x + w, y), -- 39
			Vec2(x + w, y + h), -- 39
			Vec2(x, y + h) -- 39
		}, -- 39
		fill, -- 39
		border ~= nil and 1 or 0, -- 39
		border -- 39
	) -- 39
end -- 38
____exports.MainMenu = __TS__Class() -- 42
local MainMenu = ____exports.MainMenu -- 42
MainMenu.name = "MainMenu" -- 42
function MainMenu.prototype.____constructor(self, props) -- 49
	self.root = nil -- 44
	self.screen = signal("main") -- 45
	self.selectedChar = signal("swordsman") -- 46
	self.saveTick = signal(0) -- 47
	self.props = props -- 50
end -- 49
function MainMenu.prototype.show(self) -- 53
	if self.root == nil then -- 53
		self.root = createRoot(Director.ui) -- 54
	end -- 54
	self.screen.value = "main" -- 55
	local ____self_saveTick_0, ____value_1 = self.saveTick, "value" -- 55
	____self_saveTick_0[____value_1] = ____self_saveTick_0[____value_1] + 1 -- 56
	self.root:render(function() return self:renderScreen() end) -- 57
end -- 53
function MainMenu.prototype.hide(self) -- 60
	local ____opt_2 = self.root -- 60
	if ____opt_2 ~= nil then -- 60
		____opt_2:unmount() -- 61
	end -- 61
	self.root = nil -- 62
end -- 60
function MainMenu.prototype.renderScreen(self) -- 65
	local ____ = self.saveTick.value -- 65
	local body = self.screen.value == "chars" and self:renderCharSelect() or (self.screen.value == "modes" and self:renderModeSelect() or (self.screen.value == "settings" and self:renderSettings() or self:renderMain())) -- 67
	return React.createElement( -- 74
		"node", -- 74
		{key = "menu-" .. self.screen.value}, -- 74
		React.createElement( -- 74
			"draw-node", -- 74
			{onMount = function(____self) return self:drawBackdrop(____self) end} -- 74
		), -- 74
		body -- 77
	) -- 77
end -- 65
function MainMenu.prototype.drawBackdrop(self, draw) -- 82
	rect( -- 83
		draw, -- 83
		-W / 2, -- 83
		-H / 2, -- 83
		W, -- 83
		H, -- 83
		Color(10, 17, 20, 255) -- 83
	) -- 83
	rect( -- 84
		draw, -- 84
		-W / 2, -- 84
		H / 2 - 8, -- 84
		W, -- 84
		8, -- 84
		Color(211, 155, 58, 255) -- 84
	) -- 84
	do -- 84
		local x = -W / 2 -- 85
		while x <= W / 2 do -- 85
			draw:drawSegment( -- 86
				Vec2(x, -H / 2), -- 86
				Vec2(x, H / 2), -- 86
				0.5, -- 86
				Color(43, 67, 68, 90) -- 86
			) -- 86
			x = x + 80 -- 85
		end -- 85
	end -- 85
	do -- 85
		local y = -H / 2 -- 88
		while y <= H / 2 do -- 88
			draw:drawSegment( -- 89
				Vec2(-W / 2, y), -- 89
				Vec2(W / 2, y), -- 89
				0.5, -- 89
				Color(43, 67, 68, 90) -- 89
			) -- 89
			y = y + 80 -- 88
		end -- 88
	end -- 88
	draw:drawDot( -- 91
		Vec2(-W * 0.33, 20), -- 91
		math.min(W, H) * 0.24, -- 91
		Color(31, 65, 59, 90) -- 91
	) -- 91
end -- 82
function MainMenu.prototype.renderMain(self) -- 94
	local save = saveSystem:load() -- 95
	local compact = W < 820 -- 96
	local leftX = compact and 0 or -W * 0.22 -- 97
	local rightX = compact and 0 or W * 0.23 -- 98
	return React.createElement( -- 99
		"node", -- 99
		{key = "main-content"}, -- 99
		React.createElement("label", { -- 99
			key = "title", -- 99
			fontName = FONT, -- 99
			fontSize = compact and 52 or 68, -- 99
			text = "秘境收割者", -- 99
			color3 = 15782794, -- 99
			x = leftX, -- 99
			y = compact and 170 or 98, -- 99
			anchorX = 0.5, -- 99
			anchorY = 0.5 -- 99
		}), -- 99
		React.createElement("label", { -- 99
			key = "subtitle", -- 99
			fontName = FONT, -- 99
			fontSize = compact and 28 or 30, -- 99
			text = "守住阵线。夺取力量。收割整片秘境。", -- 99
			color3 = 11125948, -- 99
			x = leftX, -- 99
			y = compact and 108 or 24, -- 99
			anchorX = 0.5, -- 99
			anchorY = 0.5 -- 99
		}), -- 99
		React.createElement( -- 99
			"label", -- 99
			{ -- 99
				key = "record", -- 99
				fontName = FONT, -- 99
				fontSize = 28, -- 99
				text = (((("金币 " .. tostring(save.gold)) .. "    无尽纪录 ") .. tostring(save.bestWave)) .. " 波    累计击杀 ") .. tostring(save.totalKills), -- 99
				color3 = 14076328, -- 99
				x = leftX, -- 99
				y = compact and 62 or -28, -- 99
				anchorX = 0.5, -- 99
				anchorY = 0.5 -- 99
			} -- 99
		), -- 99
		self:button( -- 104
			"开始远征", -- 104
			function() -- 104
				self.screen.value = "chars" -- 104
			end, -- 104
			rightX, -- 104
			compact and -15 or 76, -- 104
			340, -- 104
			13670968 -- 104
		), -- 104
		self:button( -- 105
			"战斗设置", -- 105
			function() -- 105
				self.screen.value = "settings" -- 105
			end, -- 105
			rightX, -- 105
			compact and -85 or 4, -- 105
			340, -- 105
			4156784 -- 105
		), -- 105
		self.props.onQuit ~= nil and self:button( -- 106
			"退出游戏", -- 106
			function() -- 106
				local ____this_5 -- 106
				____this_5 = self.props -- 106
				local ____opt_4 = ____this_5.onQuit -- 106
				return ____opt_4 and ____opt_4(____this_5) -- 106
			end, -- 106
			rightX, -- 106
			compact and -155 or -68, -- 106
			340, -- 106
			5717827 -- 106
		) or React.createElement("node", {key = "no-quit"}), -- 106
		React.createElement("label", { -- 106
			key = "controls", -- 106
			fontName = FONT, -- 106
			fontSize = 28, -- 106
			text = "WASD / 方向键移动    Esc 暂停    自动攻击", -- 106
			color3 = 7901581, -- 106
			x = rightX, -- 106
			y = compact and -220 or -156, -- 106
			anchorX = 0.5, -- 106
			anchorY = 0.5 -- 106
		}) -- 106
	) -- 106
end -- 94
function MainMenu.prototype.renderCharSelect(self) -- 112
	local save = saveSystem:load() -- 113
	local cardW = math.min(280, W * 0.28) -- 114
	local cardH = 172 -- 115
	return React.createElement( -- 116
		"node", -- 116
		{key = "chars-content"}, -- 116
		React.createElement("label", { -- 116
			key = "heading", -- 116
			fontName = FONT, -- 116
			fontSize = 52, -- 116
			text = "选择收割者", -- 116
			color3 = 15782794, -- 116
			x = 0, -- 116
			y = H / 2 - 46, -- 116
			anchorX = 0.5, -- 116
			anchorY = 0.5 -- 116
		}), -- 116
		React.createElement("label", { -- 116
			key = "desc", -- 116
			fontName = FONT, -- 116
			fontSize = 28, -- 116
			text = "不同武器决定整局战斗节奏", -- 116
			color3 = 9743013, -- 116
			x = 0, -- 116
			y = H / 2 - 92, -- 116
			anchorX = 0.5, -- 116
			anchorY = 0.5 -- 116
		}), -- 116
		__TS__ArrayMap( -- 120
			CHARACTER_ORDER, -- 120
			function(____, id, i) -- 120
				local row = math.floor(i / 3) -- 121
				local count = row == 0 and 3 or 2 -- 122
				local indexInRow = row == 0 and i or i - 3 -- 123
				local x = (indexInRow - (count - 1) / 2) * (cardW + 18) -- 124
				local y = 22 - row * (cardH + 14) -- 125
				return self:charCard( -- 126
					characters[id], -- 126
					save, -- 126
					x, -- 126
					y, -- 126
					cardW, -- 126
					cardH -- 126
				) -- 126
			end -- 120
		), -- 120
		self:button( -- 128
			"返回", -- 128
			function() -- 128
				self.screen.value = "main" -- 128
			end, -- 128
			-W / 2 + 105, -- 128
			-H / 2 + 52, -- 128
			170, -- 128
			3362641 -- 128
		) -- 128
	) -- 128
end -- 112
function MainMenu.prototype.charCard(self, def, save, x, y, w, h) -- 133
	local unlocked = __TS__ArrayIndexOf(save.unlockedCharacters, def.id) >= 0 -- 134
	local cost = UNLOCK_COST[def.id] -- 135
	local canAfford = save.gold >= cost -- 136
	local status = unlocked and "选择角色" or (canAfford and ("解锁 " .. tostring(cost)) .. " 金币" or ("需要 " .. tostring(cost)) .. " 金币") -- 137
	return React.createElement( -- 138
		"node", -- 138
		{ -- 138
			key = def.id, -- 138
			x = x, -- 138
			y = y, -- 138
			width = w, -- 138
			height = h, -- 138
			touchEnabled = true, -- 138
			swallowTouches = true, -- 138
			onTapped = function() return self:onCharTap(def.id, unlocked, cost, canAfford) end -- 138
		}, -- 138
		React.createElement( -- 138
			"draw-node", -- 138
			{onMount = function(____self) return self:drawCard( -- 138
				____self, -- 140
				w, -- 140
				h, -- 140
				def.color, -- 140
				unlocked -- 140
			) end} -- 140
		), -- 140
		React.createElement("label", { -- 140
			key = def.id .. "-name", -- 140
			fontName = FONT, -- 140
			fontSize = 38, -- 140
			text = def.name, -- 140
			color3 = unlocked and def.color or 7831935, -- 140
			x = w / 2, -- 140
			y = h - 34, -- 140
			anchorX = 0.5, -- 140
			anchorY = 0.5 -- 140
		}), -- 140
		React.createElement("label", { -- 140
			key = def.id .. "-desc", -- 140
			fontName = FONT, -- 140
			fontSize = 26, -- 140
			text = unlocked and def.desc or def.unlockHint, -- 140
			color3 = unlocked and 12635850 or 9280150, -- 140
			textWidth = w - 30, -- 140
			x = w / 2, -- 140
			y = h - 88, -- 140
			anchorX = 0.5, -- 140
			anchorY = 0.5 -- 140
		}), -- 140
		React.createElement("label", { -- 140
			key = def.id .. "-status", -- 140
			fontName = FONT, -- 140
			fontSize = 24, -- 140
			text = status, -- 140
			color3 = unlocked and 9427111 or (canAfford and 14859620 or 9071213), -- 140
			x = w / 2, -- 140
			y = 22, -- 140
			anchorX = 0.5, -- 140
			anchorY = 0.5 -- 140
		}) -- 140
	) -- 140
end -- 133
function MainMenu.prototype.drawCard(self, draw, w, h, color, unlocked) -- 148
	rect( -- 149
		draw, -- 149
		4, -- 149
		-4, -- 149
		w, -- 149
		h, -- 149
		Color(0, 0, 0, 80) -- 149
	) -- 149
	rect( -- 150
		draw, -- 150
		0, -- 150
		0, -- 150
		w, -- 150
		h, -- 150
		Color(unlocked and 25 or 20, unlocked and 37 or 27, unlocked and 38 or 29, 248), -- 150
		Color(unlocked and 102 or 65, unlocked and 126 or 72, unlocked and 116 or 74, 255) -- 150
	) -- 150
	local r = math.floor(color / 65536) % 256 -- 151
	local g = math.floor(color / 256) % 256 -- 152
	local b = color % 256 -- 153
	rect( -- 154
		draw, -- 154
		0, -- 154
		h - 5, -- 154
		w, -- 154
		5, -- 154
		Color(r, g, b, unlocked and 255 or 90) -- 154
	) -- 154
end -- 148
function MainMenu.prototype.onCharTap(self, id, unlocked, cost, canAfford) -- 157
	if not unlocked and not canAfford then -- 157
		return -- 158
	end -- 158
	if not unlocked then -- 158
		local save = saveSystem:load() -- 160
		save.gold = save.gold - cost -- 161
		local ____save_unlockedCharacters_6 = save.unlockedCharacters -- 161
		____save_unlockedCharacters_6[#____save_unlockedCharacters_6 + 1] = id -- 162
		saveSystem:save(save) -- 163
		local ____self_saveTick_7, ____value_8 = self.saveTick, "value" -- 163
		____self_saveTick_7[____value_8] = ____self_saveTick_7[____value_8] + 1 -- 164
	end -- 164
	self.selectedChar.value = id -- 166
	self.screen.value = "modes" -- 167
end -- 157
function MainMenu.prototype.renderModeSelect(self) -- 170
	local def = characters[self.selectedChar.value] -- 171
	return React.createElement( -- 172
		"node", -- 172
		{key = "modes-content"}, -- 172
		React.createElement("label", { -- 172
			key = "heading", -- 172
			fontName = FONT, -- 172
			fontSize = 52, -- 172
			text = def.name .. " · 选择行动", -- 172
			color3 = 15782794, -- 172
			x = 0, -- 172
			y = H / 2 - 50, -- 172
			anchorX = 0.5, -- 172
			anchorY = 0.5 -- 172
		}), -- 172
		__TS__ArrayMap( -- 175
			MODES, -- 175
			function(____, mode, i) -- 175
				local x = (i % 2 == 0 and -1 or 1) * math.min(205, W * 0.23) -- 176
				local y = i < 2 and 48 or -112 -- 177
				return self:modeCard(mode, x, y) -- 178
			end -- 175
		), -- 175
		self:button( -- 180
			"返回选择角色", -- 180
			function() -- 180
				self.screen.value = "chars" -- 180
			end, -- 180
			-W / 2 + 125, -- 180
			-H / 2 + 52, -- 180
			210, -- 180
			3362641 -- 180
		) -- 180
	) -- 180
end -- 170
function MainMenu.prototype.modeCard(self, mode, x, y) -- 185
	local w = math.min(370, W * 0.4) -- 186
	local h = 164 -- 187
	return React.createElement( -- 188
		"node", -- 188
		{ -- 188
			key = mode.mode, -- 188
			x = x, -- 188
			y = y, -- 188
			width = w, -- 188
			height = h, -- 188
			touchEnabled = true, -- 188
			swallowTouches = true, -- 188
			onTapped = function() return self.props:onStart(self.selectedChar.value, mode.mode) end -- 188
		}, -- 188
		React.createElement( -- 188
			"draw-node", -- 188
			{onMount = function(____self) return self:drawCard( -- 188
				____self, -- 190
				w, -- 190
				h, -- 190
				mode.accent, -- 190
				true -- 190
			) end} -- 190
		), -- 190
		React.createElement("label", { -- 190
			key = mode.mode .. "-title", -- 190
			fontName = FONT, -- 190
			fontSize = 38, -- 190
			text = mode.label, -- 190
			color3 = mode.accent, -- 190
			x = w / 2, -- 190
			y = h - 38, -- 190
			anchorX = 0.5, -- 190
			anchorY = 0.5 -- 190
		}), -- 190
		React.createElement("label", { -- 190
			key = mode.mode .. "-desc", -- 190
			fontName = FONT, -- 190
			fontSize = 26, -- 190
			text = mode.desc, -- 190
			color3 = 12175556, -- 190
			textWidth = w - 38, -- 190
			x = w / 2, -- 190
			y = h - 94, -- 190
			anchorX = 0.5, -- 190
			anchorY = 0.5 -- 190
		}), -- 190
		React.createElement("label", { -- 190
			key = mode.mode .. "-action", -- 190
			fontName = FONT, -- 190
			fontSize = 24, -- 190
			text = "进入秘境", -- 190
			color3 = 15326655, -- 190
			x = w / 2, -- 190
			y = 22, -- 190
			anchorX = 0.5, -- 190
			anchorY = 0.5 -- 190
		}) -- 190
	) -- 190
end -- 185
function MainMenu.prototype.renderSettings(self) -- 198
	local save = saveSystem:load() -- 199
	local ____opt_9 = save.settings -- 199
	local q = ____opt_9 and ____opt_9.quality or 1 -- 200
	local ____opt_11 = save.settings -- 200
	local ____temp_13 = ____opt_11 and ____opt_11.muted -- 201
	if ____temp_13 == nil then -- 201
		____temp_13 = false -- 201
	end -- 201
	local muted = ____temp_13 -- 201
	return React.createElement( -- 202
		"node", -- 202
		{key = "settings-content"}, -- 202
		React.createElement("label", { -- 202
			key = "heading", -- 202
			fontName = FONT, -- 202
			fontSize = 52, -- 202
			text = "战斗设置", -- 202
			color3 = 15782794, -- 202
			x = 0, -- 202
			y = H / 2 - 58, -- 202
			anchorX = 0.5, -- 202
			anchorY = 0.5 -- 202
		}), -- 202
		React.createElement("label", { -- 202
			key = "quality-label", -- 202
			fontName = FONT, -- 202
			fontSize = 30, -- 202
			text = "同屏单位与特效质量", -- 202
			color3 = 12175556, -- 202
			x = 0, -- 202
			y = 105, -- 202
			anchorX = 0.5, -- 202
			anchorY = 0.5 -- 202
		}), -- 202
		self:button( -- 206
			q == 0 and "低 · 当前" or "低", -- 206
			function() return self:setQuality(0) end, -- 206
			-180, -- 206
			35, -- 206
			150, -- 206
			q == 0 and 13670968 or 3362641 -- 206
		), -- 206
		self:button( -- 207
			q == 1 and "中 · 当前" or "中", -- 207
			function() return self:setQuality(1) end, -- 207
			0, -- 207
			35, -- 207
			150, -- 207
			q == 1 and 13670968 or 3362641 -- 207
		), -- 207
		self:button( -- 208
			q == 2 and "高 · 当前" or "高", -- 208
			function() return self:setQuality(2) end, -- 208
			180, -- 208
			35, -- 208
			150, -- 208
			q == 2 and 13670968 or 3362641 -- 208
		), -- 208
		self:button( -- 209
			muted and "声音：已关闭" or "声音：已开启", -- 209
			function() return self:toggleMuted() end, -- 209
			0, -- 209
			-65, -- 209
			330, -- 209
			muted and 5717827 or 4156784 -- 209
		), -- 209
		self:button( -- 210
			"返回", -- 210
			function() -- 210
				self.screen.value = "main" -- 210
			end, -- 210
			0, -- 210
			-155, -- 210
			220, -- 210
			3362641 -- 210
		) -- 210
	) -- 210
end -- 198
function MainMenu.prototype.setQuality(self, q) -- 215
	local save = saveSystem:load() -- 216
	if save.settings == nil then -- 216
		save.settings = {quality = q, sfxVolume = 1, musicVolume = 1, muted = false} -- 217
	else -- 217
		save.settings.quality = q -- 218
	end -- 218
	Config.quality = q <= 0 and 0 or (q >= 2 and 2 or 1) -- 219
	saveSystem:save(save) -- 220
	local ____self_saveTick_14, ____value_15 = self.saveTick, "value" -- 220
	____self_saveTick_14[____value_15] = ____self_saveTick_14[____value_15] + 1 -- 221
end -- 215
function MainMenu.prototype.toggleMuted(self) -- 224
	local save = saveSystem:load() -- 225
	if save.settings == nil then -- 225
		save.settings = {quality = 1, sfxVolume = 1, musicVolume = 1, muted = true} -- 226
	else -- 226
		save.settings.muted = not save.settings.muted -- 227
	end -- 227
	saveSystem:save(save) -- 228
	local ____self_saveTick_16, ____value_17 = self.saveTick, "value" -- 228
	____self_saveTick_16[____value_17] = ____self_saveTick_16[____value_17] + 1 -- 229
end -- 224
function MainMenu.prototype.button(self, text, onTap, x, y, width, color) -- 232
	local h = 66 -- 233
	return React.createElement( -- 234
		"node", -- 234
		{ -- 234
			key = (((text .. "-") .. tostring(x)) .. "-") .. tostring(y), -- 234
			x = x, -- 234
			y = y, -- 234
			width = width, -- 234
			height = h, -- 234
			touchEnabled = true, -- 234
			swallowTouches = true, -- 234
			onTapped = onTap -- 234
		}, -- 234
		React.createElement( -- 234
			"draw-node", -- 234
			{onMount = function(____self) -- 234
				rect( -- 237
					____self, -- 237
					3, -- 237
					-3, -- 237
					width, -- 237
					h, -- 237
					Color(0, 0, 0, 90) -- 237
				) -- 237
				local r = math.floor(color / 65536) % 256 -- 238
				local g = math.floor(color / 256) % 256 -- 239
				local b = color % 256 -- 240
				rect( -- 241
					____self, -- 241
					0, -- 241
					0, -- 241
					width, -- 241
					h, -- 241
					Color(r, g, b, 255), -- 241
					Color( -- 241
						math.min(255, r + 35), -- 241
						math.min(255, g + 35), -- 241
						math.min(255, b + 35), -- 241
						255 -- 241
					) -- 241
				) -- 241
			end} -- 236
		), -- 236
		React.createElement("label", { -- 236
			key = text .. "-label", -- 236
			fontName = FONT, -- 236
			fontSize = 34, -- 236
			text = text, -- 236
			color3 = 16777215, -- 236
			x = width / 2, -- 236
			y = h / 2, -- 236
			anchorX = 0.5, -- 236
			anchorY = 0.5 -- 236
		}) -- 236
	) -- 236
end -- 232
return ____exports -- 232