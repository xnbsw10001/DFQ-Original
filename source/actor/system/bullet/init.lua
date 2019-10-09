--[[
	desc: Bullet, a system of bullet.
	author: Musoucrow
	since: 2018-8-7
	alter: 2019-6-30
]]--

local _MATH = require("lib.math")
local _MAP = require("map.init")
local _MOTION = require("actor.service.motion")

local _Tweener = require("util.gear.tweener")
local _Point3 = require("graphics.drawunit.point3")
local _Attack = require("actor.gear.attack")
local _Base = require("actor.system.base")

---@class Actor.System.Bullet : Actor.System
local _Bullet = require("core.class")(_Base)

---@param entity Actor.Entity
local function _BeObstructed(entity)
    entity.identity.destroyProcess = 1
end

---@param attack Actor.Gear.Attack
---@param enemy Actor.Entity
local function _OnHit(attack, enemy)
    attack._entity.identity.destroyProcess = 1
end

function _Bullet:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        bullet = true
    }, "bullet")
end

---@param entity Actor.Entity
function _Bullet:OnEnter(entity)
    local bullet = entity.bullet
    local transform = entity.transform
    local pos = transform.position

    if (bullet.length > 0) then
        local tx = pos.x + bullet.length * transform.direction
        local target = _Point3.New(true, tx, pos.y, pos.z)

        if (bullet.angleY ~= 0) then
            target.x, target.y = _MATH.RotatePoint(tx, pos.y, pos.x, pos.y, math.rad(bullet.angleY) * transform.direction)
        elseif (bullet.angleZ ~= 0) then
            target.x, target.z = _MATH.RotatePoint(tx, pos.z, pos.x, pos.z, math.rad(bullet.angleZ) * transform.direction)
        end

        if (bullet.obstacleType) then
            bullet.moveTweener = _MOTION.NewMoveTweener(transform, entity.aspect)
            bullet.moveTweener:Enter(bullet.time, pos, target, bullet.easing)
        else
            bullet.moveTweener = _Tweener.New(transform.position, target, bullet.easing, function ()
                transform.positionTick = true
            end)

            bullet.moveTweener:Enter(bullet.time)
        end
    end

    if (bullet.attackData) then
        local Func = not bullet.isCross and _OnHit or bullet.OnHit
        bullet.attack = _Attack.New(entity)
        bullet.attack:Enter(bullet.attackData, bullet.attackValue, Func)
    end

    if (bullet.obstacleType == "destroy") then
        transform.obstructCaller:AddListener(entity, _BeObstructed)
    end
end

---@param entity Actor.Entity
function _Bullet:OnExit(entity)
    if (entity.identity.destroyProcess == 0 and entity.bullet.obstacleType == "destroy") then
        entity.transform.obstructCaller:DelListener(entity, _BeObstructed)
    end
end

function _Bullet:Update(dt)
    if (_MAP.GetLoadProcess() > 0) then
        return
    end

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (not e.identity.isPaused) then
            local bullet = e.bullet

            if (bullet.attack) then
                bullet.attack:Update()
            end

            if (bullet.moveTweener and bullet.moveTweener.isRunning) then
                bullet.moveTweener:Update(dt)

                if (bullet.endDestroy and not bullet.moveTweener.isRunning) then
                    e.identity.destroyProcess = 1
                end
            end

            if (e.transform.position.z > 0 and bullet.endDestroy) then
                e.identity.destroyProcess = 1
            end

            if (bullet.rotateSpeed) then
                e.transform.radian.value = e.transform.radian.value + bullet.rotateSpeed * e.transform.direction
                e.transform.radianTick = true
            end
        end
    end
end

return _Bullet