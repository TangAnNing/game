-- [ts]: DebugPanel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local Keyboard = ____Dora.Keyboard -- 4
local ____GameContext = require("game.core.GameContext") -- 5
local ctx = ____GameContext.ctx -- 5
____exports.DebugPanel = __TS__Class() -- 7
local DebugPanel = ____exports.DebugPanel -- 7
DebugPanel.name = "DebugPanel" -- 7
function DebugPanel.prototype.____constructor(self) -- 7
	self.visible = false -- 8
	self.fpsAccum = 0 -- 10
	self.fpsFrames = 0 -- 11
	self.fps = 0 -- 12
end -- 7
function DebugPanel.prototype.toggle(self) -- 14
	self.visible = not self.visible -- 15
end -- 14
function DebugPanel.prototype.update(self, dt) -- 23
	self.fpsAccum = self.fpsAccum + dt -- 25
	self.fpsFrames = self.fpsFrames + 1 -- 26
	if self.fpsAccum >= 0.5 then -- 26
		self.fps = self.fpsFrames / self.fpsAccum -- 28
		self.fpsAccum = 0 -- 29
		self.fpsFrames = 0 -- 30
	end -- 30
	if Keyboard:isKeyDown("F3") then -- 30
		self:toggle() -- 33
	end -- 33
	if not self.visible then -- 33
		return -- 34
	end -- 34
	ImGui.Begin( -- 36
		"调试", -- 36
		function() -- 36
			ImGui.Text("FPS: " .. tostring(math.floor(self.fps))) -- 37
			ImGui.Text("相位: " .. ctx.phase) -- 38
			ImGui.Text("击杀: " .. tostring(ctx.stats.kills)) -- 39
			ImGui.Text("精英击杀: " .. tostring(ctx.stats.eliteKills)) -- 40
			ImGui.Text("Boss 击杀: " .. tostring(ctx.stats.bossKills)) -- 41
			ImGui.Text("波次: " .. tostring(ctx.stats.wave)) -- 42
			ImGui.Text("等级: " .. tostring(ctx.stats.playerLevel)) -- 43
			ImGui.Text(("存活: " .. tostring(math.floor(ctx.stats.timeAlive))) .. "s") -- 44
			local p = ctx.player -- 45
			if p ~= nil then -- 45
				ImGui.Text((("HP: " .. tostring(math.floor(p.hp))) .. "/") .. tostring(math.floor(p.maxHp))) -- 47
				ImGui.Text(((("位置: (" .. tostring(math.floor(p.pos.x))) .. ", ") .. tostring(math.floor(p.pos.y))) .. ")") -- 48
			end -- 48
		end -- 36
	) -- 36
end -- 23
__TS__SetDescriptor( -- 23
	DebugPanel.prototype, -- 23
	"isVisible", -- 23
	{get = function(self) -- 23
		return self.visible -- 19
	end}, -- 19
	true -- 19
) -- 19
____exports.debugPanel = __TS__New(____exports.DebugPanel) -- 55
return ____exports -- 55