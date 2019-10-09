--[[
	desc: Identity, a component with data, name and type, etc.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-7-5
]]--

local _Caller = require("core.caller")

local _STRING = require("lib.string")

---@class Actor.Component.Identity
---@field public data Actor.RESMGR.InstanceData
---@field public type string
---@field public name string
---@field public path string
---@field public isPaused boolean
---@field public destroyProcess int @0=alive, 1=ready, 2=destoryed
---@field public canCross boolean
---@field public superior Actor.Entity @can null
---@field public popup Actor.Entity
---@field public destroyCaller Core.Caller
---@field public initCaller Core.Caller
---@field public rate number
local _Identity = require("core.class")()

local _emptyTable = {}

function _Identity.HandleData(data)
    if (data.name) then
        data.name = _STRING.GetVersion(data.name)
    end
end

---@param data Actor.RESMGR.InstanceData
function _Identity:Ctor(data, param, type, id)
    self.data = data
    self.type = type
    self.path = data.path
    self.id = id
    self.isPaused = false
    self.destroyProcess = 0
    self.rate = 1
    self.superior = param.entity

    local identity = data.identity or _emptyTable
    self.name = identity.name
    self.canCross = identity.canCross or param.canCross or false
    self.destroyCaller = _Caller.New()
    self.initCaller = _Caller.New()
end

return _Identity