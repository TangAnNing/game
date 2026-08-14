-- [ts]: HUD.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local DrawNode = ____Dora.DrawNode -- 3
local Label = ____Dora.Label -- 3
local Node = ____Dora.Node -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local ____GameContext = require("game.core.GameContext") -- 4
local ctx = ____GameContext.ctx -- 4
local ____MathUtils = require("game.utils.MathUtils") -- 5
local clamp = ____MathUtils.clamp -- 5
local FONT = "sarasa-mono-sc-regular" -- 7
local function createLabel(text, size, pos, anchor, parent) -- 9
	local label = Label(FONT, size) -- 10
	if label == nil then -- 10
		return nil -- 11
	end -- 11
	label.text = text -- 12
	label.anchor = anchor -- 13
	label.position = pos -- 14
	label:addTo(parent) -- 15
	return label -- 16
end -- 9
local function drawRect(draw, x, y, w, h, color) -- 19
	draw:drawPolygon( -- 20
		{ -- 21
			Vec2(x, y), -- 21
			Vec2(x + w, y), -- 21
			Vec2(x + w, y + h), -- 21
			Vec2(x, y + h) -- 21
		}, -- 21
		color -- 22
	) -- 22
end -- 19
____exports.HUD = __TS__Class() -- 26
local HUD = ____exports.HUD -- 26
HUD.name = "HUD" -- 26
function HUD.prototype.____constructor(self, root, uiRoot) -- 59
	self.tipTimer = 0 -- 40
	self.tipActive = false -- 41
	self.lastHpRatio = -1 -- 43
	self.lastExpRatio = -1 -- 44
	self.lastLevel = -1 -- 45
	self.lastWave = -1 -- 46
	self.lastKills = -1 -- 47
	self.margin = 18 -- 53
	self.barW = 250 -- 54
	self.barH = 20 -- 55
	self.expH = 6 -- 56
	self.uiRoot = uiRoot -- 60
	self.root = Node() -- 61
	self.root:addTo(uiRoot) -- 62
	local W = View.size.width -- 64
	local H = View.size.height -- 65
	local leftX = -W / 2 + self.margin -- 66
	local topY = H / 2 - self.margin -- 67
	local panels = DrawNode() -- 68
	panels:addTo(self.root) -- 69
	drawRect( -- 70
		panels, -- 70
		leftX - 10, -- 70
		topY - 76, -- 70
		self.barW + 142, -- 70
		94, -- 70
		Color(8, 17, 20, 205) -- 70
	) -- 70
	drawRect( -- 71
		panels, -- 71
		W / 2 - 225, -- 71
		topY - 103, -- 71
		215, -- 71
		121, -- 71
		Color(8, 17, 20, 205) -- 71
	) -- 71
	panels:drawSegment( -- 72
		Vec2(leftX - 10, topY + 18), -- 72
		Vec2(leftX + self.barW + 132, topY + 18), -- 72
		3, -- 72
		Color(205, 150, 55, 230) -- 72
	) -- 72
	panels:drawSegment( -- 73
		Vec2(W / 2 - 225, topY + 18), -- 73
		Vec2(W / 2 - 10, topY + 18), -- 73
		3, -- 73
		Color(70, 125, 121, 230) -- 73
	) -- 73
	self.lvLabel = createLabel( -- 76
		"Lv.1", -- 76
		30, -- 76
		Vec2(leftX, topY + 12), -- 76
		Vec2(0, 0.5), -- 76
		self.root -- 76
	) -- 76
	local hpY = topY - self.barH - 8 -- 79
	self.hpBg = DrawNode() -- 80
	self.hpBg:addTo(self.root) -- 81
	drawRect( -- 82
		self.hpBg, -- 82
		leftX, -- 82
		hpY, -- 82
		self.barW, -- 82
		self.barH, -- 82
		Color(35, 38, 46, 200) -- 82
	) -- 82
	self.hpFill = DrawNode() -- 83
	self.hpFill:addTo(self.root) -- 84
	drawRect( -- 85
		self.hpFill, -- 85
		leftX, -- 85
		hpY, -- 85
		self.barW, -- 85
		self.barH, -- 85
		Color(226, 76, 86, 255) -- 85
	) -- 85
	self.hpLabel = createLabel( -- 86
		"100 / 100", -- 86
		28, -- 86
		Vec2(leftX + self.barW + 12, hpY + self.barH / 2), -- 86
		Vec2(0, 0.5), -- 86
		self.root -- 86
	) -- 86
	local expY = hpY - self.expH - 3 -- 89
	self.expBg = DrawNode() -- 90
	self.expBg:addTo(self.root) -- 91
	drawRect( -- 92
		self.expBg, -- 92
		leftX, -- 92
		expY, -- 92
		self.barW, -- 92
		self.expH, -- 92
		Color(35, 38, 46, 200) -- 92
	) -- 92
	self.expFill = DrawNode() -- 93
	self.expFill:addTo(self.root) -- 94
	drawRect( -- 95
		self.expFill, -- 95
		leftX, -- 95
		expY, -- 95
		self.barW, -- 95
		self.expH, -- 95
		Color(140, 100, 230, 255) -- 95
	) -- 95
	self.waveLabel = createLabel( -- 98
		"波次 1", -- 98
		32, -- 98
		Vec2(W / 2 - self.margin, topY - 10), -- 98
		Vec2(1, 0.5), -- 98
		self.root -- 98
	) -- 98
	self.killLabel = createLabel( -- 99
		"击杀 0", -- 99
		28, -- 99
		Vec2(W / 2 - self.margin, topY - 46), -- 99
		Vec2(1, 0.5), -- 99
		self.root -- 99
	) -- 99
	self.modeLabel = createLabel( -- 100
		"章节远征", -- 100
		26, -- 100
		Vec2(W / 2 - self.margin, topY - 80), -- 100
		Vec2(1, 0.5), -- 100
		self.root -- 100
	) -- 100
	self.tipLabel = createLabel( -- 103
		"", -- 103
		46, -- 103
		Vec2(0, H / 2 - 118), -- 103
		Vec2(0.5, 0.5), -- 103
		self.root -- 103
	) -- 103
	if self.tipLabel ~= nil then -- 103
		self.tipLabel.visible = false -- 105
	end -- 105
	self.resultRoot = Node() -- 109
	self.resultRoot:addTo(self.uiRoot) -- 110
	local bg = DrawNode() -- 111
	bg:addTo(self.resultRoot) -- 112
	drawRect( -- 113
		bg, -- 113
		-W / 2, -- 113
		-H / 2, -- 113
		W, -- 113
		H, -- 113
		Color(8, 10, 18, 190) -- 113
	) -- 113
	self.resultTitle = createLabel( -- 114
		"", -- 114
		40, -- 114
		Vec2(0, 70), -- 114
		Vec2(0.5, 0.5), -- 114
		self.resultRoot -- 114
	) -- 114
	self.resultStats = createLabel( -- 115
		"", -- 115
		18, -- 115
		Vec2(0, -20), -- 115
		Vec2(0.5, 0.5), -- 115
		self.resultRoot -- 115
	) -- 115
	self.resultRoot.visible = false -- 116
end -- 59
function HUD.prototype.update(self, dt) -- 120
	if self.tipActive then -- 120
		self.tipTimer = self.tipTimer - dt -- 123
		if self.tipTimer <= 0 then -- 123
			self.tipActive = false -- 125
			if self.tipLabel ~= nil then -- 125
				self.tipLabel.visible = false -- 126
			end -- 126
		end -- 126
	end -- 126
	local player = ctx.player -- 130
	if player == nil then -- 130
		return -- 131
	end -- 131
	if self.hpLabel ~= nil then -- 131
		self.hpLabel.text = (tostring(math.ceil(player.hp)) .. " / ") .. tostring(math.ceil(player.maxHp)) -- 132
	end -- 132
	local hpRatio = player.maxHp > 0 and clamp(player.hp / player.maxHp, 0, 1) or 0 -- 135
	if math.abs(hpRatio - self.lastHpRatio) > 0.002 then -- 135
		self.lastHpRatio = hpRatio -- 137
		local w = math.max(0, self.barW * hpRatio) -- 138
		self.hpFill:clear() -- 139
		local hpY = View.size.height / 2 - self.margin - self.barH - 8 -- 140
		drawRect( -- 141
			self.hpFill, -- 141
			-View.size.width / 2 + self.margin, -- 141
			hpY, -- 141
			w, -- 141
			self.barH, -- 141
			Color(226, 76, 86, 255) -- 141
		) -- 141
	end -- 141
	if player.level ~= self.lastLevel then -- 141
		self.lastLevel = player.level -- 146
		if self.lvLabel ~= nil then -- 146
			self.lvLabel.text = "Lv." .. tostring(player.level) -- 147
		end -- 147
	end -- 147
	local expRatio = player.expNeed > 0 and clamp(player.exp / player.expNeed, 0, 1) or 0 -- 151
	if math.abs(expRatio - self.lastExpRatio) > 0.002 then -- 151
		self.lastExpRatio = expRatio -- 153
		local w = math.max(0, self.barW * expRatio) -- 154
		self.expFill:clear() -- 155
		local hpY = View.size.height / 2 - self.margin - self.barH - 8 -- 156
		local expY = hpY - self.expH - 3 -- 157
		drawRect( -- 158
			self.expFill, -- 158
			-View.size.width / 2 + self.margin, -- 158
			expY, -- 158
			w, -- 158
			self.expH, -- 158
			Color(140, 100, 230, 255) -- 158
		) -- 158
	end -- 158
	local stats = ctx.stats -- 162
	if stats.wave ~= self.lastWave then -- 162
		self.lastWave = stats.wave -- 164
		if self.waveLabel ~= nil then -- 164
			self.waveLabel.text = "波次 " .. tostring(stats.wave) -- 165
		end -- 165
		if self.modeLabel ~= nil then -- 165
			self.modeLabel.text = ctx.mode == "endless" and "无尽深潜" or (ctx.mode == "challenge" and "高压试炼" or (ctx.mode == "daily" and "每日秘境" or "章节远征")) -- 166
		end -- 166
	end -- 166
	if stats.kills ~= self.lastKills then -- 166
		self.lastKills = stats.kills -- 169
		if self.killLabel ~= nil then -- 169
			self.killLabel.text = "击杀 " .. tostring(stats.kills) -- 170
		end -- 170
	end -- 170
end -- 120
function HUD.prototype.showWaveTip(self, n) -- 175
	if self.tipLabel == nil then -- 175
		return -- 176
	end -- 176
	self.tipLabel.text = ("第 " .. tostring(n)) .. " 波来袭！" -- 177
	self.tipLabel.visible = true -- 178
	self.tipActive = true -- 179
	self.tipTimer = 2.2 -- 180
end -- 175
function HUD.prototype.showGameOver(self, stats) -- 184
	self:showResult("游戏结束", stats) -- 185
end -- 184
function HUD.prototype.showVictory(self, stats) -- 189
	self:showResult("胜利！", stats) -- 190
end -- 189
function HUD.prototype.showResult(self, title, stats) -- 193
	if self.resultTitle ~= nil then -- 193
		self.resultTitle.text = title -- 194
	end -- 194
	if self.resultStats ~= nil then -- 194
		self.resultStats.text = (((("第 " .. tostring(stats.wave)) .. " 波    击杀 ") .. tostring(stats.kills)) .. "\n") .. (("生存 " .. tostring(math.floor(stats.timeAlive))) .. " 秒    等级 ") .. tostring(stats.playerLevel) -- 196
	end -- 196
	self.resultRoot.visible = true -- 200
end -- 193
function HUD.prototype.hideResult(self) -- 204
	self.resultRoot.visible = false -- 205
end -- 204
function HUD.prototype.reset(self) -- 209
	self.lastHpRatio = -1 -- 210
	self.lastExpRatio = -1 -- 211
	self.lastLevel = -1 -- 212
	self.lastWave = -1 -- 213
	self.lastKills = -1 -- 214
	self.tipActive = false -- 215
	if self.tipLabel ~= nil then -- 215
		self.tipLabel.visible = false -- 216
	end -- 216
	self:hideResult() -- 217
end -- 209
return ____exports -- 209