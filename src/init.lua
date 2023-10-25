local Signal = require(script.Parent.signal)

local module = {}
module.Init = "0"
module.Children = "1"
module.Merge = "2"
module.Connect = "3"
module.Once = "4"

local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
}

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

local class = {}
class.obj = nil
class.changes = {}
class.className = nil
module.__index = class

function class:Render(list: {}, archivable: boolean, _cloned: boolean)
	archivable = if archivable ~= nil then archivable else true

	for i, v in list do
		local info = string.split(i, " ")

		if archivable then
			class.changes[i] = v
		end

		if info[1] == module.Connect or info[1] == module.Once then
			local c: RBXScriptConnection

			c = self.obj[info[2]]:Connect(function(...)
				if info[1] == module.Once then
					c:Disconnect()
				end

				v(self, ...)
			end)
		elseif info[1] == module.Init then
			task.defer(v, self)
		elseif info[1] == module.Merge then
			for i, v in v do
				v.obj.Parent = self.obj
			end
		elseif info[1] == module.Children then
			for i, v: Class in v do
				if _cloned then
					v:Clone():Render({ Parent = self.obj })
				else
					v:Render({ Parent = self.obj })
				end
			end
		elseif typeof(v) == "userdata" then
			self.obj[i] = v.value

			local c = v.updated:Connect(function(newValue)
				self.obj[i] = newValue
			end)
		else
			local success = pcall(function()
				self.obj[i] = v
			end)
		end
	end

	return self
end

function class:Clone()
	return module.new(self.className):Render(self.changes, true, true)
end

function module.new(className: string): Class
	local newClass = setmetatable({
		obj = Instance.new(className),
		className = className,
	}, module)

	newClass:Render(DEFAULT_PROPERTIES)

	return newClass
end

export type Class = {
	obj: Instance,
	className: string,
	Render: (self: Class, list: {}) -> Class,
	Clone: (self: Class) -> Class,
}

export type Key = {
	value: any,
	updated: Signal.Signal,
}

return module
