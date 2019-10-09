--[[
	desc: Ais, a component of AI management.
	author: Musoucrow
	since: 2018-5-2
	alter: 2018-8-7
]]--

local _RESMGR = require("actor.resmgr")

local _Container = require("core.container")

---@class Actor.Component.Ais
---@field enable boolean
---@field container Core.Container
local _Ais = require("core.class")()

function _Ais.HandleData(data)
    for k, v in pairs(data) do
        if (k ~= "class") then
            data[k] = _RESMGR.GetAIData(v)
        end
    end
end

function _Ais:Ctor(data)
    self.enable = true
    self.data = data
    self.container = _Container.New()
end

return _Ais