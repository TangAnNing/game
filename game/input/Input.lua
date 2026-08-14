-- [ts]: Input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Keyboard = ____Dora.Keyboard -- 2
local Controller = ____Dora.Controller -- 2
local Vec2 = ____Dora.Vec2 -- 2
____exports.InputSystem = __TS__Class() -- 5
local InputSystem = ____exports.InputSystem -- 5
InputSystem.name = "InputSystem" -- 5
function InputSystem.prototype.____constructor(self) -- 5
	self.joystick = nil -- 6
	self._moveDir = Vec2(0, 0) -- 7
	self._pausePressed = false -- 8
	self._attackHeld = false -- 9
end -- 5
function InputSystem.prototype.attachJoystick(self, j) -- 12
	self.joystick = j -- 13
end -- 12
function InputSystem.prototype.update(self) -- 29
	self._pausePressed = false -- 30
	local dx = 0 -- 32
	local dy = 0 -- 33
	if Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") then -- 33
		dy = dy + 1 -- 36
	end -- 36
	if Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") then -- 36
		dy = dy - 1 -- 37
	end -- 37
	if Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") then -- 37
		dx = dx - 1 -- 38
	end -- 38
	if Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") then -- 38
		dx = dx + 1 -- 39
	end -- 39
	local ax = Controller:getAxis(0, "leftx") -- 42
	local ay = Controller:getAxis(0, "lefty") -- 43
	if math.abs(ax) > 0.15 or math.abs(ay) > 0.15 then -- 43
		dx = dx + ax -- 45
		dy = dy + ay -- 46
	end -- 46
	if self.joystick ~= nil and self.joystick.isVisible then -- 46
		local jv = self.joystick.moveDir -- 51
		dx = dx + jv.x -- 52
		dy = dy + jv.y -- 53
	end -- 53
	local len = math.sqrt(dx * dx + dy * dy) -- 57
	if len > 1 then -- 57
		dx = dx / len -- 59
		dy = dy / len -- 60
	end -- 60
	self._moveDir = Vec2(dx, dy) -- 62
	if Keyboard:isKeyDown("Escape") or Controller:isButtonDown(0, "start") then -- 62
		self._pausePressed = true -- 66
	end -- 66
	self._attackHeld = Keyboard:isKeyPressed("Space") or Controller:isButtonDown(0, "x") -- 70
end -- 29
__TS__SetDescriptor( -- 29
	InputSystem.prototype, -- 29
	"moveDir", -- 29
	{get = function(self) -- 29
		return self._moveDir -- 17
	end}, -- 17
	true -- 17
) -- 17
__TS__SetDescriptor( -- 17
	InputSystem.prototype, -- 17
	"pausePressed", -- 17
	{get = function(self) -- 17
		return self._pausePressed -- 21
	end}, -- 21
	true -- 21
) -- 21
__TS__SetDescriptor( -- 21
	InputSystem.prototype, -- 21
	"isAttackHeld", -- 21
	{get = function(self) -- 21
		return self._attackHeld -- 25
	end}, -- 25
	true -- 25
) -- 25
____exports.inputSystem = __TS__New(____exports.InputSystem) -- 76
return ____exports -- 76