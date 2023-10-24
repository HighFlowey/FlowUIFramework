local Packages = script.Parent
local Signal = require(Packages:WaitForChild("signal"))

local SPECIAL_CHARACTER_KEY = "SPCR"
local OUTPUT = false

local memory = {}
local module = {}
module.Init = `{SPECIAL_CHARACTER_KEY}:Init`
module.Children = `{SPECIAL_CHARACTER_KEY}:Children`
module.Merge = `{SPECIAL_CHARACTER_KEY}:Merge`
module.Connect = `{SPECIAL_CHARACTER_KEY}:Connect`
module.Once = `{SPECIAL_CHARACTER_KEY}:Once`

local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
}

local function SetProperty(t: Class, i: any, v: any)
	local indexInfo = string.split(i, ":")

	if t.connections[i] then
		t.connections[i]:Disconnect()
		t.connections[i] = nil
	end

	if indexInfo[1] == SPECIAL_CHARACTER_KEY then
		if indexInfo[2] == "Merge" then
			for property, value in v do
				SetProperty(t, property, value)
			end

			return true
		elseif indexInfo[2] == "Children" then
			for _, obj: Instance in v do
				local handler = memory[obj]
				if handler and handler.create then
					local newHandler = memory[obj].create()
					newHandler.obj.Parent = t.obj
				else
					obj.Parent = t.obj
				end
			end

			return true
		elseif indexInfo[2] == "Connect" or indexInfo[2] == "Once" then
			local c: RBXScriptConnection

			c = t.obj[indexInfo[3]]:Connect(function(...)
				if indexInfo[2] == "Once" then
					c:Disconnect()
				end

				v(t, ...)
			end)

			t.connections[i] = c

			if indexInfo[4] == "true" then
				return true
			end
		elseif indexInfo[2] == "Init" then
			t.init = v

			if indexInfo[3] == "true" then
				return true
			end
		end
	elseif typeof(v) == "userdata" and v.value then
		local success, msg = pcall(function()
			t.obj[i] = v.value
		end)

		if success then
			local c: RBXScriptConnection

			c = v.updated:Connect(function(newValue)
				t.obj[i] = newValue
			end)

			t.connections[i] = c

			return true
		elseif OUTPUT then
			warn(`Failed to set {t.obj}'s property({i}) to {v}`, msg)
		end
	else
		local success, msg = pcall(function()
			t.obj[i] = v
		end)

		if success then
			return true
		elseif OUTPUT then
			warn(`Failed to set {t.obj}'s property({i}) to {v}`, msg)
		end
	end
end

function module.key(v: any): Key
	local proxy = newproxy(true)
	local meta = getmetatable(proxy)
	local t = {
		value = v,
		updated = Signal.new(),
	}

	meta.__index = t
	meta.__newindex = function(_, i, value)
		if i ~= "value" then
			return
		end

		if t[i] == value then
			return
		end

		t[i] = value
		t.updated:Fire(value)
	end

	return proxy
end

function module.new(className: string, startingProperties: {}): Class
	local class = {}
	class.connections = {}
	class.transfer = {}
	class.obj = Instance.new(className)
	memory[class.obj] = class

	function class:Render(properties: {})
		for i, v in properties do
			local transfer = SetProperty(self, i, v)

			if string.split(i, ":")[2] == "Init" then
				task.defer(v, self)
			end

			if self.transfer and transfer then
				self.transfer[i] = v
			end
		end

		return self.obj
	end

	function class:Create(): Class
		return module.new(self.obj.ClassName, self.transfer)
	end

	class:Render(DEFAULT_PROPERTIES)

	if startingProperties then
		class:Render(startingProperties)
	end

	return class
end

export type Class = {
	obj: Instance,
	Render: (Class, properties: {}) -> (),
	create: (Class) -> (),
}
export type Key = {
	value: any,
	updated: Signal.Signal,
}

return module
