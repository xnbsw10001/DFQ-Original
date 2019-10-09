--[[
	desc: RESMGR, a manager of resource.
	author: Musoucrow
	since: 2018-6-12
	alter: 2019-8-26
]]--

local _FILE = require("lib.file")
local _MATH = require("lib.math")
local _GRAPHICS = require("lib.graphics")
local _STRING = require("lib.string")
local _RESOURCE = require("lib.resource")

---@class Actor.RESMGR
local _RESMGR = {}

local _poolGroup = {
    sprite = {},
    frameani = {},
    particle = {},
    instance = {},
    state = {},
    collider = {},
    avatar = {},
    attack = {},
    skill = {},
    ai = {},
    buff = {},
    equipment = {},
    attribute = {}
}

local _meta = {__mode = 'v'}

for k, v in pairs(_poolGroup) do
    setmetatable(v, _meta)
end

local _colliderMap = _FILE.ReadScript("config/actor/colliderMap.cfg")
local _emptyMap = {}

local function _HeaderHandle(path)
    if (type(path) ~= "string") then
        return path
    end

    if (string.sub(path, 1, 6) ~= "actor/") then
        path = "actor/" .. path
    end

    return path
end

---@param path string
---@param data Lib.RESOURCE.SpriteData
---@return Lib.RESOURCE.SpriteData
local function _HandleSpriteData(path, data)
    local list = _STRING.Split(path, "/")
    local header = table.concat(list, "/", 2, #list - 2)
    local colliderPath = _STRING.ToDirectory(path)

    if (_colliderMap[header]) then
        if (type(_colliderMap[header]) == "string") then
            local start, endl = string.find(list[#list - 1], _colliderMap[header])

            if (start == 1 and endl == #list[#list - 1]) then
                colliderPath = header
            end
        else
            colliderPath = header
        end
    end

    if (colliderPath == header and not data.collider) then
        data.collider = colliderPath .. "/" .. list[#list]
    end

    if (data.collider) then
        data.colliderData = _RESMGR.GetColliderData(data.collider)
        data.collider = nil
    end

    return data
end

---@param path string
---@param data Lib.RESOURCE.Lib.RESOURCE.ParticleData
---@return Lib.RESOURCE.ParticleData
local function _HandleParticleData(path, data)
    if (data.collider) then
        data.colliderData = _RESMGR.GetColliderData(data.collider)
        data.collider = nil
    end

    return data
end

---@param path string
---@param avatar Actor.Drawable.Frameani.Avatar
---@param passMap table @can null
---@return Lib.RESOURCE.SpriteData
local function _NewAvatarSpriteData(path, avatar, passMap)
    local spriteDatas = {}
    local sortingMap = {}
    passMap = passMap or _emptyMap

    for k, v in pairs(avatar.config) do
        if (not passMap[k] and not avatar.passMap[k]) then
            local spritePath = avatar.data.path .. "/" .. v .. "/" .. path
            local spriteData = _RESMGR.GetSpriteData(spritePath)
    
            spriteDatas[#spriteDatas + 1] = spriteData
            sortingMap[spriteData] = avatar.data.layer[k]
        end
    end

    if (#spriteDatas == 1) then
        return spriteDatas[1]
    end

    local spriteData = {} ---@type Lib.RESOURCE.SpriteData
    local minX, minY, maxX, maxY

    for n=1, #spriteDatas do
        local w = spriteDatas[n].w
        local h = spriteDatas[n].h

        if (w ~= 1 and h ~= 1) then
            local minx = -spriteDatas[n].ox
            local miny = -spriteDatas[n].oy
            local maxx = minx + w
            local maxy = miny + h

            minX = minX or minx
            minY = minY or miny
            maxX = maxX or maxx
            maxY = maxY or maxy

            minX = minx < minX and minx or minX
            minY = miny < minY and miny or minY
            maxX = maxx > maxX and maxx or maxX
            maxY = maxy > maxY and maxy or maxY
        end
    end

    for n=1, #spriteDatas do
        local colliderData = spriteDatas[n].colliderData

        if (colliderData) then
            spriteData.colliderData = spriteData.colliderData or {}

            for k, v in pairs(colliderData) do
                spriteData.colliderData[k] = spriteData.colliderData[k] or {}
                local i = spriteData.colliderData[k]

                for n=1, #v do
                    i[#i + 1] = v[n]
                end
            end
        end
    end

    table.sort(spriteDatas, function(a, b)
        return sortingMap[a] < sortingMap[b]
    end)


    minX = not minX and 1 or minX
    minY = not minY and 1 or minY
    maxX = not maxX and 1 or maxX
    maxY = not maxY and 1 or maxY

    spriteData.w = maxX - minX
    spriteData.h = maxY - minY
    spriteData.ox = -minX
    spriteData.oy = -minY
    spriteData.subjects = spriteDatas

    return spriteData
end

---@param avatar Actor.Drawable.Frameani.Avatar
local function _InitAvatarSpriteDatas(avatar)
    local data = avatar.data
    local header = avatar.key .. "|" .. data.path .. "/"
    local spriteDatas = {}
    local partCount = 0
    
    for k, v in pairs(avatar.config) do
        partCount = partCount + 1

        if (partCount >= 2) then
            break
        end
    end

    for n=1, #data.files do
        local spriteData = _NewAvatarSpriteData(data.files[n], avatar)
        table.insert(spriteDatas, spriteData)
        _poolGroup.sprite[header .. data.files[n]] = spriteData
    end

    if (data.extra) then
        for k, v in pairs(data.extra) do
            local spriteData = _NewAvatarSpriteData(v.frame, avatar, v.passMap)
            table.insert(spriteDatas, spriteData)
            _poolGroup.sprite[header .. k] = spriteData
        end
    end

    if (partCount == 1) then
        return
    end

    local horizontalCount = #data.files
    local verticalCount = 1

    while (horizontalCount > verticalCount) do
        horizontalCount = math.ceil(horizontalCount * 0.5)
        verticalCount = verticalCount * 2
    end

    local x = 0
    local y = 0
    local w = 0
    local h = 0

    for n=1, #spriteDatas do
        local spriteData = spriteDatas[n]

        spriteData.x = x
        spriteData.y = y
        h = h < spriteData.h and spriteData.h or h
        x = x + spriteData.w + 1

        if (n % horizontalCount == 0) then
            w = w < x and x or w
            x = 0
            y = y + h + 1
        end
    end

    w = w - 1
    h = y + h

    local canvas = _GRAPHICS.NewCanvas(w, h)
    _GRAPHICS.SetCanvas(canvas)

    for n=1, #spriteDatas do
        local spriteData = spriteDatas[n]
        local x = spriteData.x + spriteData.ox
        local y = spriteData.y + spriteData.oy

        if (spriteData.subjects) then
            for m=1, #spriteData.subjects do
                local v = spriteData.subjects[m]
    
                _GRAPHICS.SetBlendmode(v.blendmode or "alpha")
    
                if (v.quad) then
                    _GRAPHICS.DrawObj(v.image, v.quad, x, y, 0, 1, 1, v.ox, v.oy)
                else
                    _GRAPHICS.DrawObj(v.image, x, y, 0, 1, 1, v.ox, v.oy)
                end
            end
        end
    end

    _GRAPHICS.SetBlendmode("alpha")
    _GRAPHICS.SetCanvas()

    for n=1, #spriteDatas do
        local spriteData = spriteDatas[n]
        spriteData.image = canvas
        spriteData.quad = _RESOURCE.NewQuad(spriteData.x, spriteData.y, spriteData.w, spriteData.h, w, h)
    end
end

---@param path string
---@param avatar Actor.Drawable.Frameani.Avatar
---@return Lib.RESOURCE.SpriteData
local function _GetAvatarSpriteData(path, avatar)
    _InitAvatarSpriteDatas(avatar)

    return _poolGroup.sprite[path]
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.InstanceData
local function _NewInstanceData(path, keys)
    ---@class Actor.RESMGR.InstanceData
    local data, path = _RESOURCE.ReadConfig(path, "config/actor/instance/%s.cfg", keys)

    if (not data) then
        assert(nil, "config/actor/instance/" .. path)
    end

    for k, v in pairs(data) do
        if (type(v) == "table") then
            local script = v.script or k
            script = string.gsub(script, "_", ".")
            v.class = require("actor.component." .. script)
            v.script = nil

            if (v.class.HandleData) then
                v.class.HandleData(v)
            end
        end
    end

    data.path = path
    
    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.StateData
local function _NewStateData(path, keys)
    ---@class Actor.RESMGR.StateData
    local data, path = _RESOURCE.ReadConfig(path, "config/actor/state/%s.cfg", keys)
    data.script = string.gsub(data.script, "/", ".")
    data.class = require("actor.state." .. data.script)
    data.script = nil

    if (data.class.HandleData) then
        data.class.HandleData(data)
    end

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.ColliderData
local function _NewColliderData(path, keys)
    ---@class Actor.RESMGR.ColliderData
    local data = _RESOURCE.ReadConfig(path, "config/actor/collider/%s.cfg", keys)

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AvatarData
local function _NewAvatarData(path, keys)
    ---@class Actor.RESMGR.AvatarData
    ---@field public path string
    ---@field public layer table<string, number>
    ---@field public files table<int, string>
    local data = _RESOURCE.ReadConfig(path, "config/actor/avatar/%s.cfg", keys)
    local files = {}

    for n=1, #data.files do
        if (type(data.files[n]) == "table") then
            for m=data.files[n][1], data.files[n][2] do
                table.insert(files, tostring(m))
            end
        else
            table.insert(files, tostring(data.files[n]))
        end
    end

    data.files = files
    data.path = _HeaderHandle(data.path)

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AttackData
local function _NewAttackData(path, keys)
    ---@class Actor.RESMGR.AttackData
    local data = _RESOURCE.ReadConfig(path, "config/actor/attack/%s.cfg", keys)
    
    if (data.effect) then
        data.effectSet = _RESOURCE.Recur(_RESMGR.GetInstanceData, data.effect, "aspect")
        data.effect = nil
    end

    if (data.sound) then
        data.soundDataSet = _RESOURCE.Recur(_RESMGR.GetSoundData, data.sound)
        data.sound = nil
    end

    if (data.buff) then
        if (#data.buff == 0) then
            data.buff = _RESMGR.NewBuffData(data.buff.path, data.buff)
        else
            for n=1, #data.buff do
                data.buff[n] = _RESMGR.NewBuffData(data.buff[n].path, data.buff[n])
            end
        end
    end

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AIData
local function _NewAIData(path, keys)
    ---@class Actor.RESMGR.AIData
    local data = _RESOURCE.ReadConfig(path, "config/actor/ai/%s.cfg", keys)

    data.script = string.gsub(data.script, "/", ".")
    data.class = require("actor.ai.".. data.script)
    data.script = nil

    if (data.class.HandleData) then
        data.class.HandleData(data)
    end

    return data
end

---@return Actor.RESMGR.ItemData
local function _NewItemData(path, pathFormat, keys, type, scriptHead, iconHead, hasCircle)
    ---@class Actor.RESMGR.ItemData
    local data, path = _RESOURCE.ReadConfig(path, pathFormat, keys)

    if (not data) then
        print(pathFormat .. " | " ..  path)
    end

    if (data.script) then
        data.script = string.gsub(data.script, "/", ".")
        data.class = require(scriptHead .. data.script)
        data.script = nil
    end

    data.type = type
    data.name = _STRING.GetVersion(data.name)
    data.path = path

    if (data.ai) then
        data.aiData = _RESMGR.GetAIData(data.ai)
        data.ai = nil
    end

    if (data.class and data.class.HandleData) then
        data.class.HandleData(data)
    end

    if (data.special) then
        data.special = "效果: " .. _STRING.GetVersion(data.special)
    end

    if (data.comment) then
        data.comment = _STRING.GetVersion(data.comment)
    end

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.SkillData
local function _NewSkillData(path, keys)
    ---@class Actor.RESMGR.SkillData : Actor.RESMGR.ItemData
    local data = _NewItemData(path, "config/actor/skill/%s.cfg", keys, "skill",
            "actor.skill.", "ui/icon/skill/")
    data.kind = "skill"
    data.subKind = data.subKind or "normal"
    data.origin = data.origin or data.path

    --[[if (data.stateData) then
        data.stateData = _RESMGR.GetStateData(data.stateData)
    end]]--

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.BuffData
local function _NewBuffData(path, keys)
    ---@class Actor.RESMGR.BuffData : Actor.RESMGR.ItemData
    local data = _NewItemData(path, "config/actor/buff/%s.cfg", keys, "buff",
            "actor.buff.", "ui/icon/buff/")
    
    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.EquipmentData
local function _NewEquipmentData(path, keys)
    ---@class Actor.RESMGR.EquipmentData : Actor.RESMGR.ItemData
    ---@field kind string
    ---@field subKind string
    local data = _NewItemData(path, "config/actor/equipment/%s.cfg", keys, "equipment",
            "actor.equipment.", "ui/icon/equipment/", true)

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AttributeData
local function _NewAttributeData(path, keys)
    ---@class Actor.RESMGR.AttributeData : Actor.RESMGR.ItemData
    ---@field value number
    ---@field operation string @'+' or '*'
    local data = _NewItemData(path, "config/actor/attribute/%s.cfg", keys, "attribute", _, "ui/icon/attribute/")

    return data
end

---@param path string
---@param keys table<number, string>
---@param avatar Actor.Drawable.Frameani.Avatar
---@return Lib.RESOURCE.SpriteData
function _RESMGR.GetSpriteData(path, keys, avatar)
    if (avatar) then
        path = avatar.key .. "|" .. avatar.data.path .. "/" .. path
        local data = _RESOURCE.GetResource(_poolGroup.sprite, _GetAvatarSpriteData, path, _, avatar)

        return data
    else
        path = _HeaderHandle(path)
        local data = _RESOURCE.GetSpriteData(path, keys)

        return _RESOURCE.GetResource(_poolGroup.sprite, _HandleSpriteData, path, _, data)
    end
end

---@param path string
---@param keys table<number, string>
---@param avatar Actor.Drawable.Frameani.Avatar
---@return Lib.RESOURCE.FrameaniData
function _RESMGR.GetFrameaniData(path, keys, avatar)
    path = _HeaderHandle(path)

    if (avatar) then
        local avatarPath = type(path) == "table" and path.path or path
        local tag = _RESOURCE.GetTag(avatar.key .. "|" .. avatarPath, keys)

        return _RESOURCE.GetResource(_poolGroup.frameani, _RESOURCE.NewFrameaniData, path, tag, keys, _RESMGR.GetSpriteData, _, avatar)
    else
        return _RESOURCE.GetConfigResource(_poolGroup.frameani, _RESOURCE.NewFrameaniData, path, keys, _RESMGR.GetSpriteData)
    end
end

---@param path string
---@param keys table<number, string>
---@return Lib.RESOURCE.ParticleData
function _RESMGR.GetParticleData(path, keys)
    path = _HeaderHandle(path)
    local data = _RESOURCE.GetParticleData(path, keys)

    return _RESOURCE.GetResource(_poolGroup.particle, _HandleParticleData, path, _, data)
end

---@param path string
---@return SoundData
function _RESMGR.GetSoundData(path)
    return _RESOURCE.GetSoundData(_HeaderHandle(path))
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.InstanceData
function _RESMGR.GetInstanceData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.instance, _NewInstanceData, path, keys)
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.StateData
function _RESMGR.GetStateData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.state, _NewStateData, path, keys)
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.ColliderData
function _RESMGR.GetColliderData(path, keys)
    if (type(path) == "table") then
        return path
    end
    
    if (string.sub(path, 1, 8) == "(sprite)") then
        local spritePath = string.sub(path, 9, #path)
        local pos = string.find(spritePath, "-")
        local key

        if (pos) then
            key = string.sub(spritePath, pos + 1, #spritePath)
            spritePath = string.sub(spritePath, 1, pos - 1)
        end

        local spriteData = _RESMGR.GetSpriteData(spritePath)

        if (pos) then
            return spriteData.colliderData[key]
        end

        return spriteData.colliderData
    end

    local key
    local pos = string.find(path, "-")

    if (pos) then
        key = string.sub(path, pos + 1, #path)
        path = string.sub(path, 1, pos - 1)
    end

    local data = _RESOURCE.GetConfigResource(_poolGroup.collider, _NewColliderData, path, keys)

    if (key) then
        return data[key]
    end

    return data
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AvatarData
function _RESMGR.GetAvatarData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.avatar, _NewAvatarData, path, keys)
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AttackData
function _RESMGR.GetAttackData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.attack, _NewAttackData, path, keys)
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.SkillData
function _RESMGR.GetSkillData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.skill, _NewSkillData, path, keys)
end

---@param path string
---@param keys table<number, string>
---@return Actor.RESMGR.AIData
function _RESMGR.GetAIData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.ai, _NewAIData, path, keys)
end

---@param path string
---@param param table @not copy
---@param keys table<number, string>
---@return Actor.RESMGR.BuffData
function _RESMGR.NewBuffData(path, param, keys)
    local data = _RESOURCE.GetConfigResource(_poolGroup.buff, _NewBuffData, path, keys)

    if (not param) then
        return data
    end

    setmetatable(param, {__index = data, __base = true})

    return param
end

---@param path string
---@param param table @not copy
---@param keys table<number, string>
---@return Actor.RESMGR.EquipmentData
function _RESMGR.NewEquipmentData(path, param, keys, onlyAdd)
    local data = _RESOURCE.GetConfigResource(_poolGroup.equipment, _NewEquipmentData, path, keys)

    if (not param) then
        return data
    end

    if (not onlyAdd and param.add and data.add) then
        for k, v in pairs(data.add) do
            if (param.add[k]) then
                param.add[k] = param.add[k] + v
            else
                param.add[k] = v
            end
        end
    end

    setmetatable(param, {__index = data, __base = true})

    return param
end

---@param path string
---@param param table @not copy
---@param keys table<number, string>
---@return Actor.RESMGR.AttributeData
function _RESMGR.NewAttributeData(path, param, keys)
    local data = _RESOURCE.GetConfigResource(_poolGroup.attribute, _NewAttributeData, path, keys)

    if (not param) then
        return data
    end

    setmetatable(param, {__index = data, __base = true})

    return param
end

---@param path string
---@param param table @not copy
---@param keys table<number, string>
---@return Actor.RESMGR.ItemData
function _RESMGR.GetItemData(path, param, keys)
    local pos = string.find(path, "/")
    local type = string.sub(path, 0, pos - 1)
    path = string.sub(path, pos + 1)

    if (type == "equipment") then
        return _RESMGR.NewEquipmentData(path, param, keys)
    elseif (type == "skill") then
        return _RESMGR.GetSkillData(path, keys)
    elseif (type == "buff") then
        return _RESMGR.NewBuffData(path, param, keys)
    elseif (type == "attribute") then
        return _RESMGR.NewAttributeData(path, param, keys)
    end
end

return _RESMGR