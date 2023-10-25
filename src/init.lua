local Identifiers = require(script:WaitForChild("Identifiers"))
local Signal = require(script.Parent:WaitForChild("signal"))
local Class = require(script:WaitForChild("Class"))

local module: Module = table.clone(Identifiers)

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

function module.new(...): Class
	return Class.new(...)
end

export type Class = {
	obj: Instance,
	className: string,
	Render: (self: Class, list: {}, archivable: boolean) -> Class,
	Clone: (self: Class) -> Class,
}

export type Key = {
	value: any,
	updated: Signal.Signal,
}

export type Module = typeof(Identifiers) & typeof(module)

return module
