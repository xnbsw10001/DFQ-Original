--[[
	desc: CONFIG, a data set.
	author: Musoucrow
	since: 2018-5-22
	alter: 2019-8-14
]]--

---@class CONFIG
---@field user User
local _CONFIG = {
    setting = {
        version = 1,
        hasModify = false,
        language = "cn",
        music = 0.7,
        sound = 1,
        digit = true,
        shadow = true
    },
    debug = {
        point = false,
        collider = false,
        ai = false,
        fps = false,
        bgm = true,
        transparency = false,
        transport = false,
        ui = true,
        map = {
            object = false,
            up = false,
            down = false,
            obstacle = false
        }
    }
}

_CONFIG.arrow = {"up", "down", "left", "right"}

_CONFIG.code = {
    up = "up",
    down = "down",
    left = "left",
    right = "right",
    getItem = "lctrl",
    goNext = "lshift",
    talk = "space",
    normalAttack = "x",
    skill1 = "a",
    skill2 = "s",
    skill3 = "d",
    skill4 = "f",
    skill5 = "g",
    skill6 = "h",
    step = "z",
    counterAttack = "c",
    suptool1 = "q",
    suptool2 = "w",
    dash = "v"
}

_CONFIG.anticode = {}

do
    for k, v in pairs(_CONFIG.code) do
        _CONFIG.anticode[v] = k
    end
end

return _CONFIG