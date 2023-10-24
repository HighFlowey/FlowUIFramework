local Signal = require(script.Packages.signal)

local memory = {}
local module = {}
module.Reference = "SpecialCharacter_Reference"
module.Children = "SpecialCharacter_Children"
module.Merge = "SpecialCharacter_Merge"

local handlerClass = {}
handlerClass.SavedProperties = {}
handlerClass.Connections = {}
module.__index = handlerClass

local defaultProperties = {
	["TextScaled"] = true,
	["Size"] = UDim2.fromOffset(100, 50),
}

local function SetProperty(object: Instance, property: string, value: any)
	if typeof(value) == "userdata" and value.value then
		-- this value is made by using the module.Value function
		object[property] = value.value
		memory[object].SavedProperties[property] = value
		value.onChanged:Connect(function(newValue)
			object[property] = newValue
		end)
	else
		-- could be a normal roblox property
		local _ = pcall(function()
			object[property] = value
		end)
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
		elseif i == module.Reference then
			v.value = self.object
		elseif i == "Parent" then
			task.defer(function()
				SetProperty(self.object, i, v)
			end)
		elseif string.split(i, ":")[1] == "SpecialCharacter_Event" then
			local info = string.split(i, ":")
			local eventName = info[2]
			local eventMethod = info[3]
			local archivable = info[4] == "true" and true
			self.SavedProperties[i] = archivable and v or nil

			if eventMethod == "Connect" then
				self.object[eventName]:Connect(function(...)
					v(self.object, ...)
				end)
			elseif eventMethod == "Once" then
				self.object[eventName]:Once(function(...)
					v(self.object, ...)
				end)
			end
		else
			SetProperty(self.object, i, v)
		end
	end

	return self.object
end

function module.clone(referenceObject: Instance)
	local reference = memory[referenceObject]
	local newHandler = setmetatable({ object = reference.object:Clone() }, module)

	memory[newHandler.object] = newHandler
	newHandler:Render(reference.SavedProperties)

	return newHandler
end

function module.new(className: string)
	local object = Instance.new(className)
	local handler = setmetatable({ object = object }, module)

	memory[object] = handler
	handler:Render(defaultProperties)

	return handler
end

function module.Connect(eventName: string, archivable: boolean)
	return `SpecialCharacter_Event:{eventName}:Connect:{tostring(archivable)}`
end

function module.Once(eventName: string, archivable: boolean)
	return `SpecialCharacter_Event:{eventName}:Once:{tostring(archivable)}`
end

function module.Value<t>(value: t)
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
