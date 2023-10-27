local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Identifiers = require(script.Parent:WaitForChild("Identifiers"))
local Signal = require(script.Parent.Parent:WaitForChild("signal"))

local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
	["SortOrder"] = Enum.SortOrder.LayoutOrder,
	["BackgroundColor3"] = Color3.fromRGB(79, 79, 79),
	["ScrollBarImageColor3"] = Color3.fromRGB(36, 36, 36),
	["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling,
}

local module = {}
local class = {}
local customEvents = {
	Mouse1Click = {},
	Mouse2Click = {},
}
local customEvents_Identifiers = {
	[Identifiers.Mouse1Click] = "Mouse1Click",
	[Identifiers.Mouse2Click] = "Mouse2Click",
}

function class:SetProperty(i, v)
	local success = pcall(function()
		self.obj[i] = v
	end)

	if success and (i == "Parent" and v ~= nil) then
		self.ready = true
		self.obj:GetPropertyChangedSignal("Parent"):Connect(function()
			for _, n in self.connections do
				n:Disconnect()
				n = nil
			end

			self.ready = false
			self.Destroyed:Fire()
		end)
	end

	return success
end

function class:Render(list: {}, archivable: boolean)
	local done = Signal.new()
	archivable = if archivable ~= nil then archivable else true

	task.defer(function()
		for i, v in list do
			local info = string.split(i, " ")
			local customEventIdentifier = customEvents_Identifiers[info[1]]
			local customEvent = customEvents[customEventIdentifier]

			if archivable then
				if info[1] == Identifiers.Children then
					for _, original in v do
						table.insert(self.changes.children, original)
					end
				elseif info[1] ~= Identifiers.Reference then
					self.changes.any[i] = v
				end
			end

			if customEvent then
				if customEvent[self] == nil then
					customEvent[self] = {}
				end

				local signal = Signal.new()
				table.insert(customEvent[self], signal)

				signal:Connect(v)

				self.Destroyed:Connect(function()
					signal:Destroy()
					signal = nil
				end)
			elseif info[1] == Identifiers.Connect or info[1] == Identifiers.Once then
				local c: RBXScriptConnection

				c = self.obj[info[2]]:Connect(function(...)
					if info[1] == Identifiers.Once then
						c:Disconnect()
					end

					v(self, ...)
				end)

				if self.connections[i] then
					self.connections[i]:Disconnect()
				end

				self.connections[i] = c
			elseif info[1] == Identifiers.Init then
				task.defer(v, self)
			elseif info[1] == Identifiers.Merge then
				self:Render(v)
			elseif info[1] == Identifiers.Children then
				for i, v in v do
					v:Render({ Parent = self.obj })
				end
			elseif info[1] == Identifiers.Reference then
				v.value = self
			elseif typeof(v) == "userdata" then
				self.obj[i] = v.value

				local c = v.updated:Connect(function(newValue)
					self.obj[i] = newValue
				end)

				if self.connections[i] then
					self.connections[i]:Disconnect()
				end

				self.connections[i] = c
			else
				self:SetProperty(i, v)
			end
		end

		done:Fire(self)
	end)

	return done:Wait()
end

function class:Clone()
	local clonedClass = module.new(self.className)

	clonedClass:Render(self.changes.any)

	for _, v in self.changes.children do
		clonedClass:Render({
			[Identifiers.Children] = {
				v:Clone():Render({ Parent = clonedClass.obj }),
			},
		})
	end

	return clonedClass
end

function module.new(className: string): Class
	local newClass = newproxy(true)
	local meta = getmetatable(newClass)
	local t = {}
	t.Destroyed = Signal.new()
	t.obj = Instance.new(className)
	t.ready = false -- turns true when object's parent stopped being nil
	t.className = className
	t.connections = {}
	t.changes = {
		children = {},
		any = {},
	}

	meta.__index = function(_, i)
		return if t[i] ~= nil then t[i] else if class[i] ~= nil then class[i] else t.obj[i]
	end
	meta.__newindex = function(_, i, v)
		local robloxProperty = newClass:SetProperty(i, v)

		if not robloxProperty then
			t[i] = v
		end
	end
	meta.__tostring = function(_)
		return t.obj.Name
	end

	newClass:Render(DEFAULT_PROPERTIES, false)

	return newClass
end

UserInputService.InputBegan:Connect(function(input, processed)
	local mousePosition = UserInputService:GetMouseLocation()
	local guiInset = GuiService:GetGuiInset()

	local mouse = input.UserInputType == Enum.UserInputType.MouseButton1 and 1
		or input.UserInputType == Enum.UserInputType.MouseButton2 and 2

	if mouse then
		for class: Class, signals: { Signal.Signal } in customEvents[`Mouse{mouse}Click`] do
			local parentGui: ScreenGui = class.obj:FindFirstAncestorWhichIsA("ScreenGui")

			if parentGui then
				local yOffset = parentGui.IgnoreGuiInset == false and guiInset.Y or 0
				local objects =
					Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y - yOffset)

				if #objects > 0 and objects[1] == class.obj then
					for _, signal in signals do
						signal:Fire(class, processed)
					end

					break
				end
			end
		end
	end
end)

export type Class = {
	obj: Instance,
	className: string,
	Destroyed: Signal.Signal,
	Render: (self: Class, list: { [string]: any }, archivable: boolean) -> Class,
	Clone: (self: Class) -> Class,
}

return module
