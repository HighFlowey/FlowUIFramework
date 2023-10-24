local Signal = require(script.Packages.signal)

local SPECIAL_CHARACTER_KEY = "SPCR"
local module = {}
module.Children = `{SPECIAL_CHARACTER_KEY}:Children`
module.Merge = `{SPECIAL_CHARACTER_KEY}:Merge`
module.Connect = `{SPECIAL_CHARACTER_KEY}:Connect`
module.Once = `{SPECIAL_CHARACTER_KEY}:Once`

local function SetProperty(t: Template, i: any, v: any)
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
				obj.Parent = t.obj
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
		else
			warn(`Failed to set {t.obj}'s property({i}) to {v}`, msg)
		end
	else
		local success, msg = pcall(function()
			t.obj[i] = v
		end)

		if success then
			return true
		else
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

function module.new(className: string): Template
	local template = {}
	template.connections = {}
	template.transfer = {}
	template.obj = Instance.new(className)

	function template:Render(properties: {})
		for i, v in properties do
			local transfer = SetProperty(self, i, v)

			if self.transfer and transfer then
				self.transfer[i] = v
			end
		end

		return self.obj
	end

	function template.create()
		local handler = {}
		handler.connections = {}
		handler.obj = Instance.new(className)

		handler.Render = template.Render
		handler:Render(template.transfer)

		return handler
	end

	return template
end

export type Template = {
	obj: Instance,
	Render: (Template, properties: {}) -> (),
	create: () -> (),
}
export type Key = {
	value: any,
	updated: Signal.Signal,
}

return module
