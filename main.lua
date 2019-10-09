love.filesystem.setRequirePath("source/?.lua;source/?/init.lua")

local _TIME = require("lib.time")
local _MOUSE = require("lib.mouse")
local _KEYBOARD = require("lib.keyboard")
local _TOUCH = require("lib.touch")
local _SYSTEM = require("lib.system")
local _GRAPHICS = require("lib.graphics")
local _SOUND = require("lib.sound")
local _MUSIC = require("lib.music")
local _RESOURCE = require("lib.resource")
local _DIRECTOR = require("director")
local _CONFIG = require("config")

local _User = require("user")

function readconfig(path, pathFormat, keys)
    local config = _RESOURCE.ReadConfig(path, "config/" .. pathFormat .. "%s.cfg", keys)

    return config
end

local function _Update()
    local dt = _TIME.GetDelta()

    _TIME.FrameUpdate()
    _DIRECTOR.Update(dt)
    _SOUND.LateUpdate()
    _MUSIC.LateUpdate(dt)
    _MOUSE.LateUpdate()
    _TOUCH.LateUpdate()
    _KEYBOARD.LateUpdate()
end

function love.load()
    math.randomseed(os.time())

    _CONFIG.user = _User.New()

    _GRAPHICS.Init()
    _DIRECTOR.Init()
end

function love.update(dt)
    _TIME.Update(dt)

    while (_TIME.CanUpdate()) do
        _Update()
        _TIME.LateUpdate()
    end
end

function love.draw()
    _DIRECTOR.Draw()
end

function love.keypressed(key, scancode, isrepeat)
    _KEYBOARD.Pressed(key)
end

function love.keyreleased(key, scancode)
    _KEYBOARD.Released(key)
end

if (not _SYSTEM.IsMobile()) then
    function love.mousemoved(x, y, dx, dy, istouch)
        _MOUSE.Moved(x, y, dx, dy)
        _TOUCH.Moved(0, x, y, dx, dy, 1)
    end

    function love.mousepressed(x, y, button, istouch)
        _MOUSE.Pressed(button)

        local dx, dy = _MOUSE.GetMoving()
        _TOUCH.Pressed(0, x, y, dx, dy, 1)
    end

    function love.mousereleased(x, y, button, istouch)
        _MOUSE.Released(button)

        local dx, dy = _MOUSE.GetMoving()
        _TOUCH.Released(0, x, y, dx, dy, 1)
    end
else
    function love.touchmoved(id, x, y, dx, dy, pressure)
        _TOUCH.Moved(id, x, y, dx, dy, pressure)
    end

    function love.touchpressed(id, x, y, dx, dy, pressure)
        _TOUCH.Pressed(id, x, y, dx, dy, pressure)
    end

    function love.touchreleased(id, x, y, dx, dy, pressure)
        _TOUCH.Released(id, x, y, dx, dy, pressure)
    end
end

function love.resize(w, h)
    _SYSTEM.OnResize(w, h)
end