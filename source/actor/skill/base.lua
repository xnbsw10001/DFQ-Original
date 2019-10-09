--[[
	desc: Skill, actor's action.
	author: Musoucrow
	since: 2018-5-9
	alter: 2019-9-13
]]--

local _TABLE = require("lib.table")
local _INPUT = require("actor.service.input")
local _STATE = require("actor.service.state")

local _Timer = require("util.gear.timer")

---@class Actor.Skill
---@field protected _timer Util.Gear.Timer
---@field protected _entity Actor.Entity
---@field protected _judgeAi Actor.Ai.BattleJudge
---@field protected _data Actor.RESMGR.SkillData
---@field protected _key string
---@field public mp int
---@field public time milli
---@field public state string
---@field public coolDown boolean
---@field public order int
---@field public attackValues table<int, Actor.Gear.Attack.AttackValue>
---@field public dura int
---@field public duraMax int
---@field public isCombo boolean
---@field public hpRate number
---@field public isUltimate boolean
local _Skill = require("core.class")()

---@param self Actor.Skill
local function _OnBeaten(self)
    if (self:InCoolDown()) then
        self:SetNowTime(self:GetNowTime() + self:GetData().beatenTime)
    end
end

---@param entity Actor.Entity
---@param key string
---@param data Actor.RESMGR.SkillData
function _Skill:Ctor(entity, key, data)
    self._entity = entity
    self._data = data
    self._timer = _Timer.New()

    self._key = key
    self.state = data.state
    self.time = data.time or 0
    self.mp = data.mp or 0
    self.order = data.order or 0
    self.attackValues = _TABLE.Clone(data.attackValues)
    self.duraMax = data.dura
    self.dura = 0
    self.isCombo = false
    self.hpRate = data.hpRate or 1
    self.isUltimate = data.isUltimate
    
    if (data.nowTime) then
        self._timer:Enter(data.nowTime)
    elseif (data.inCoolDown) then
        self:CoolDown()
    elseif (self.duraMax) then
        self:Reset()
    end

    if (data.aiData) then
        self._judgeAi = data.aiData.class.NewWithConfig(entity, data.aiData, self)
    end

    if (data.beatenTime) then
        self._entity.battle.beatenCaller:AddListener(self, _OnBeaten)
    end
end

function _Skill:Update(dt)
    if (self._timer.isRunning) then
        self._timer:Update(dt)

        if (not self._timer.isRunning and self.duraMax) then
            self.dura = self.dura + 1

            if (self.dura < self.duraMax) then
                self._timer:Enter(self.time)
            end
        end
    end

    if (self:CanUse() and _INPUT.IsReleased(self._entity.input, self._key)) then
        self:Use()
    end
end

function _Skill:Exit()
    if (self._data.beatenTime) then
        self._entity.battle.beatenCaller:DelListener(self, _OnBeaten)
    end
end

---@param noKey boolean
function _Skill:AITick(noKey)
    if (not self:CanUse() or not self._judgeAi) then
        return false
    end
    
    self._judgeAi.key = not noKey and self._key or nil

    return self._judgeAi:Tick()
end

---@return Actor.Entity
function _Skill:GetAITarget()
    return self._judgeAi.target
end

---@param isForce boolean
function _Skill:CoolDown(isForce)
    if (self.duraMax) then
        self.dura = self.dura - 1
    end

    if (not isForce and self._timer.isRunning) then
        return
    end

    self._timer:Enter(self.time)
end

function _Skill:Reset()
    if (self.duraMax) then
        self.dura = 0
        self._timer:Enter(self.time)
        self.isCombo = false
    else
        self._timer:Exit()
        self.isCombo = true
    end
end

---@return boolean
function _Skill:IsActive()
    return self:CanUse()
end

---@return boolean
function _Skill:CanUse()
    local hasDura = not self.duraMax or (self.duraMax and self.dura > 0)
    return not self:InCoolDown() and hasDura and self:Cond() and self._entity.attributes.hp > 0 and self._entity.attributes.hp <= self._entity.attributes.maxHp * self.hpRate
end

---@return boolean
function _Skill:Cond()
    local isSame = self._entity.states.current:GetName() == self.state
    
    return _STATE.HasTag(self._entity.states, "free") or (self.isCombo and isSame) or (_STATE.HasTag(self._entity.states, "cancel") and not isSame)
end

function _Skill:Use()
    self:CoolDown()
    self.isCombo = false

    if (self.state) then
        _STATE.Play(self._entity.states, self.state, false, self)
    end
end

---@return Actor.RESMGR.SkillData
function _Skill:GetData()
    return self._data
end

---@return Actor.RESMGR.SkillData
function _Skill:ToData()
    local data = {nowTime = self._timer.to - self._timer.from}
    setmetatable(data, {__index = _TABLE.GetOrigin(self._data, true)})

    return data
end

function _Skill:Save()
    return self._data.path
end

---@return string
function _Skill:GetKey()
    return self._key
end

---@return number
function _Skill:GetProcess()
    return self._timer:GetProcess()
end

---@return boolean
function _Skill:InCoolDown()
    return not self.duraMax and self._timer.isRunning
end

---@return milli
function _Skill:GetNowTime()
    return self._timer.from
end

---@param time milli
function _Skill:SetNowTime(time)
    self._timer.from = time
end

return _Skill