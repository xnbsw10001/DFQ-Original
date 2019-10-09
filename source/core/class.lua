--[[
	desc: Class for lua.
	author: Musoucrow
	since: 2018-3-7
	alter: 2018-6-21
	docs:
		* When using New() would not automatically use Ctor() of the base class, you should manually use it. (Base.Ctor(self, ...))
		* When accessing attribute of the base class, you should use self.xxx, if the current class has homonymous attribute that will cover the base class.
		* When accessing method of the base class, you should use Base.func(self, ...).
		* When using self:func(), if the current class has not it, that will access the method of the base class and upper untill access it.
		* The class is powered by Wuyinjie.
]]--

local _TABLE = require("lib.table") ---@type Lib.TABLE

local function _Class(...) -- super list
    local cls
	local superList = {...}

    if (#superList > 0) then
		cls = _TABLE.Clone(superList[1])
		
        for n=2, #superList do
			cls = _TABLE.Clone(superList[n], cls)
		end
    else
        cls = {Ctor = function() end}
    end

    function cls.New(...)
        local instance = setmetatable({}, {__index = cls})
        instance.class = cls
        instance:Ctor(...)
        return instance
    end    

    return cls
end

return _Class