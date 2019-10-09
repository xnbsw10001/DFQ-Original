--[[
	desc: Shader, one of Drawunit.
	author: Musoucrow
	since: 2018-3-15
	alter: 2019-9-17
]]--

local _RESOURCE = require("lib.resource")
local _GRAPHICS = require("lib.graphics") ---@type Lib.GRAPHICS

---@class Graphics.Drawunit.Shader
---@field protected _obj Shader
local _Shader = require("core.class")()

---@param code string
function _Shader:Ctor(code)
    if (code) then
        self:Set()
    end
end

---@param code string
function _Shader:Set(code)
    if (not code) then
        self._obj = nil
        return
    end

    self._obj = _RESOURCE.NewShader(code)
end

---@param name string
function _Shader:Get()
    return self._obj
end

---@return boolean
function _Shader:IsRaw()
	return self._obj == nil
end

function _Shader:Apply()
    _GRAPHICS.SetShader(self._obj)
end

return _Shader