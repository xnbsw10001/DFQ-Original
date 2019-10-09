--[[
	desc: Bullet, a basic bullet.
	author: Musoucrow
	since: 2018-8-7
	alter: 2019-6-26
]]--

local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Bullet
---@field attackData Actor.RESMGR.AttackData
---@field moveTweener Util.Gear.Tweener
---@field length int
---@field time milli
---@field attackValue Actor.Gear.Attack.AttackValue
---@field attack Actor.Gear.Attack
---@field easing string
---@field obstacleType string @nil, "normal", "destroy"
---@field isCross boolean
---@field endDestroy boolean
---@field angleY number
---@field angleZ number
---@field OnHit function
---@field rotateSpeed number
local _Bullet = require("core.class")()

function _Bullet.HandleData(data)
    if (data.attack) then
        data.attack = _RESMGR.GetAttackData(data.attack)
    end
end

function _Bullet:Ctor(data, param)
    self.attackData = data.attack
    self.length = data.length
    self.time = data.time
    self.easing = data.easing
    self.obstacleType = data.obstacleType
    self.endDestroy = data.endDestroy or false
    self.isCross = data.isCross or false
    self.attackValue = data.attackValue or param.attackValue
    self.OnHit = param.OnHit
    self.angleY = data.angleY or param.angleY or 0
    self.angleZ = data.angleZ or param.angleZ or 0
    self.rotateSpeed = data.rotateSpeed or 0
end

return _Bullet