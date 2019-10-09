--[[
	desc: BUFF, a service for buff.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-7-30
]]--

---@class Actor.Service.BUFF
local _BUFF = {}

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return Actor.Buff
function _BUFF.AddBuff(entity, data)
    if (not entity.buffs) then
        return
    end

    if (data.class.CanNew(entity, data)) then
        local buff = data.class.New(entity, data)
        table.insert(entity.buffs.list, buff)
        entity.buffs.addCaller:Call(buff)

        return buff
    end
end

---@param buffs Actor.Component.Buffs
---@param path string
---@param tag string
---@return Actor.Buff
function _BUFF.GetBuff(buffs, path, tag)
    for n=1, #buffs.list do
        local data = buffs.list[n]:GetData()

        if (data.path == path and data.tag == tag) then
            return buffs.list[n]
        end
    end
end

---@param buffs Actor.Component.Buffs
---@param path string
---@return int
function _BUFF.GetBuffCount(buffs, path)
    if (buffs == nil) then
        return 0
    end

    local count = 0

    for n=1, #buffs.list do
        if (buffs.list[n]:GetPath() == path) then
            count = count + 1
        end
    end

    return count
end

---@param buffs Actor.Component.Buffs
function _BUFF.ClearDebuff(buffs)
    for n=#buffs.list, 1, -1 do
        if (buffs.list[n]:GetData().isDebuff) then
            buffs.list[n]:Exit()
        end
    end
end

---@param buffs Actor.Component.Buffs
function _BUFF.ClearAll(buffs)
    for n=#buffs.list, 1, -1 do
        buffs.list[n]:Exit()
    end
end

return _BUFF