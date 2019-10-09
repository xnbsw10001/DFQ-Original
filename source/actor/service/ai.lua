--[[
	desc: AI, a service for ai.
	author: Musoucrow
	since: 2018-5-29
	alter: 2018-12-28
]]--

local _CONFIG = require("config")
local _ECSMGR = require("actor.ecsmgr")

---@class Actor.Service.AI
local _AI = {}

local _list = _ECSMGR.NewComboList({ais = true})

---@param ais Actor.Component.Ais
---@param enable boolean
function _AI.SetEnableOfLogin(ais, enable)
    for n=1, ais.container:GetLength() do
        local ai = ais.container:GetWithIndex(n) ---@type Actor.Ai
        ai.enable = enable
    end
end

---@param enable boolean
function _AI.SetEnable(enable)
    for n=1, _list:GetLength() do
        _AI.SetEnableOfLogin(_list:Get(n).ais, enable)
    end
    
    _CONFIG.user.player.ais.enable = not enable
end

return _AI