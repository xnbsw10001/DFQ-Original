--[[
	desc: Equipments, a equipment container.
	author: Musoucrow
	since: 2018-6-25
	alter: 2019-9-13
]]--

local _RESMGR = require("actor.resmgr")

local _Caller = require("core.caller")
local _Container = require("core.container")

---@class Actor.Component.Equipments
---@field public container Core.Container
---@field public caller Core.Caller
---@field public hasWear boolean
---@field public defaultWeaponPath string
local _Equipments = require("core.class")()

function _Equipments.HandleData(data)
    for k, v in pairs(data) do
        if (k ~= "class") then
            data[k] = _RESMGR.NewEquipmentData(v)
        end
    end
end

function _Equipments:Ctor(data)
    self.container = _Container.New()
    self.caller = _Caller.New()
    self.data = data
end

return _Equipments