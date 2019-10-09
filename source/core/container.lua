--[[
	desc: 
		* Container, be responsible for saving object.
		* CAREFULLY: Container isn't object's upper, it doesn't manage object.
	author: Musoucrow
	since: 2018-3-11
	alter: 2019-8-19
]]--

---@param start int @defalut=1
local function _RefreshTransfer(self, start)
	start = start or 1

	for n=start, #self._transfer.list do
		self._transfer.map[self._transfer.list[n]] = n
	end
end

---@param tag string
---@param order int
local function _Remove(self, tag, order)
	table.remove(self._list, order)
	table.remove(self._transfer.list, order)

	if (tag) then
		self._map[tag] = nil
		self._transfer.map[tag] = nil
	end

	_RefreshTransfer(self, order)
end

---@class Core.Container
---@field public _list list
---@field public _map map
---@field protected _transfer Core.Container.Transfer
---@field protected _willClean boolean
local _Container = require("core.class")()

function _Container:Ctor()
	self._list = {}
	self._map = {}

	---@class Core.Container.Transfer
	self._transfer = {
		list = {},
		map = {}
	}

	self._willClean = false
end

---@param name string
function _Container:RunEvent_All(name, ...)
	for n in ipairs(self._list) do
		self._list[n][name](self._list[n], ...)
	end
end

---@param tag string
---@param name string
function _Container:RunEvent_Member(tag, name, ...)
	self._map[tag][name](self._map[tag], ...)
end

---@param obj table
---@param tag string
---@param order int
function _Container:Add(obj, tag, order)
	if (tag and self._map[tag]) then
		self:Del(tag)
	end
	
	local max = #self._list + 1
	order = order or max
	
	if (order > max) then
		order = max
	end
	
	table.insert(self._list, order, obj)
	
	if (tag) then
		table.insert(self._transfer.list, order, tag)
		self._map[tag] = obj
	end
	
	_RefreshTransfer(self, order)
end

---@param tag string
function _Container:Del(tag)
	local order = self._transfer.map[tag]

	if (order) then
		_Remove(self, tag, order)
	end
end

function _Container:DelWithIndex(index)
	local tag = self._transfer.list[index]

	if (tag) then
		_Remove(self, tag, index)
	end
end

---@param tag string
---@return table
function _Container:Get(tag)
	return self._map[tag]
end

function _Container:GetWithIndex(index)
	return self._list[index]
end

---@return int
function _Container:GetLength()
	return #self._list
end

function _Container:Iter()
	local index = 0

	return function()
		index = index + 1
		return self._list[index], self._transfer.list[index], index
	end
end

function _Container:Pairs()
	return pairs(self._map)
end

---@param Func function
function _Container:Sort(Func)
	for n=1, #self._list-1 do
		for m=1, #self._list-n do
			if (not Func(self._list[m], self._list[m+1])) then -- For compatibility with table.sort
				local tmp = self._list[m]
				self._list[m] = self._list[m+1]
				self._list[m+1] = tmp

				if (self._transfer.list[m] and self._transfer.list[m+1]) then
					tmp = self._transfer.list[m]
					self._transfer.list[m] = self._transfer.list[m+1]
					self._transfer.list[m+1] = tmp

					tmp = self._transfer.map[self._transfer.list[m]]
					self._transfer.map[self._transfer.list[m]] = self._transfer.map[self._transfer.list[m+1]]
					self._transfer.map[self._transfer.list[m+1]] = tmp
				end
			end
		end
	end
end

function _Container:TryClean()
	if (self._willClean) then
		for n=#self._list, 1, -1 do
			if (self._list[n].HasDestroyed and self._list[n]:HasDestroyed()) then
				_Remove(self, self._transfer.list[n], n)
			end
		end
		
		self._willClean = not self._willClean
	end
end

function _Container:ReadyClean()
	self._willClean = true
end

function _Container:Print() --For test.
	for n=1, #self._transfer.list do
		print (self._transfer.list[n], self._transfer.map[self._transfer.list[n]])
	end
end

function _Container:DelAll()
	self._list = {}
	self._map = {}

	self._transfer = {
		list = {},
		map = {}
	}
end

return _Container