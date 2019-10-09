--[[
	desc: Buffs, a component of buff set.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-4-2
]]--

local _RESMGR = require("actor.resmgr")

local _Caller = require("core.caller")

---@class Actor.Component.Buffs
---@field public list table<int, Actor.Buff>
---@field public addCaller Core.Caller
---@field public delCaller Core.Caller
---@field public undebuffCount int
local _Buffs = require("core.class")()

function _Buffs.HandleData(data)
	for n=1, #data do
		if (type(data[n]) == "string") then
			data[n] = _RESMGR.NewBuffData(data[n])
		else
			data[n] = _RESMGR.NewBuffData(data[n].path, data[n])
		end
	end
end

function _Buffs:Ctor(data)
	self.list = {}
	self.data = data
    self.addCaller = _Caller.New()
	self.delCaller = _Caller.New()
	self.undebuffCount = 0
end

return _Buffs

