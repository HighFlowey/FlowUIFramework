local Signal = require(script.Parent.signal)

local module = {}
module.Children = "SpecialCharacter_Children"
module.Merge = "SpecialCharacter_Merge"

local handlerClass = {}
module.__index = handlerClass

local function SetProperty(object: Instance, property: string, value: any)
	if typeof(value) == "table" and value.value then
		-- this value is made by using the module.Value function
		object[property] = value.value
		value.onChanged:Connect(function(newValue)
			object[property] = newValue
		end)
	else
		-- could be a normal roblox property
		object[property] = value
	end
end

function handlerClass:Render(properties: {})
	for i, v in properties do
		if i == module.Children then
			for _, child: Instance in v do
				child.Parent = self.object
			end
		elseif i == module.Merge then
			self:Render(v)
		elseif i == "Parent" then
			task.defer(function()
				SetProperty(self.object, i, v)
			end)
		else
			SetProperty(self.object, i, v)
		end
	end

	return self.object
end

function module.new(className: string)
	local object = Instance.new(className)
	local handler = setmetatable({ object = object }, module)

	return handler
end

function module.value<t>(value: t)
	local t = {
		value = value,
		onChanged = Signal.new(),
	}

	local self: { value: t, onChanged: Signal.Signal } = newproxy(true)
	local meta = getmetatable(self)
	meta.__index = t
	meta.__newindex = function(_, i, v)
		if i ~= "value" then
			return
		end

		if t.value == v then
			return
		end

		t.value = v
		t.onChanged:Fire(v)
	end

	return self
end

return module
