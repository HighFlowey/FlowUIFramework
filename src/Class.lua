-- Services
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Identifiers = require(script.Parent:WaitForChild("Identifiers"))
local Signal = require(script.Parent.Parent:WaitForChild("signal"))

-- Default services that get applied to objects
-- Because Instance.new doesn't do these unlike creating them manually in Studio
local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
	["SortOrder"] = Enum.SortOrder.LayoutOrder,
	["BackgroundColor3"] = Color3.fromRGB(79, 79, 79),
	["ScrollBarImageColor3"] = Color3.fromRGB(36, 36, 36),
	["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling,
}

-- variables
local module = {}
local class = {}

-- get gui inset for calculating accurate mouse Position
local guiInset = GuiService:GetGuiInset()

-- these are the events that the module uses to create user inputs like dragging
-- and zomoming
local customEvents = {
	Mouse1Click = {},
	Mouse2Click = {},
	ZoomIn = {},
	ZoomOut = {},
	Drag = {},
}

-- creating identifiers for events so developers can put them as properties 
-- when creating objects
local customEvents_Identifiers = {
	[Identifiers.Mouse1Click] = "Mouse1Click",
	[Identifiers.Mouse2Click] = "Mouse2Click",
	[Identifiers.ZoomIn] = "ZoomIn",
	[Identifiers.ZoomOut] = "ZoomOut",
	[Identifiers.Drag] = "Drag",
}

-- this function sets individual properties of objects and is used by the module
-- not the developers
function class:SetProperty(i, v)
	-- check if object has this property
	local success = pcall(function()
		self.obj[i] = v
	end)

	-- if developer is setting parent to a valid object
	-- start listening for changes that happen to parent, and when parent becomes nil
	-- fire the destroyed event.
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

-- this function is used to add properties to an object and should
-- only be used once by the developers.
function class:Render(list: {}, archivable: boolean)
	local done = Signal.new()
	archivable = if archivable ~= nil then archivable else true

	-- iterate through the list of properties and apply them
	for i, v in list do
		-- properties could be custom identifiers made by the module
		-- for example a drag event, so we have to parse the name of the property
		-- to see if it's a special identifier or just a normal property
		local info = string.split(i, " ")
		local customEventIdentifier = customEvents_Identifiers[info[1]]
		local customEvent = customEvents[customEventIdentifier]

		-- when archivable is true, the :Clone() method can clone these properties
		-- so we have to store them.
		if archivable then
			if info[1] == Identifiers.Children then
				for _, original in v do
					table.insert(self.changes.children, original)
				end
			elseif info[1] ~= Identifiers.Reference then
				self.changes.any[i] = v
			end
		end

		-- if the property is an event identifier
		-- we will make it a signal and store it.
		if customEvent then
			if customEvent[self] == nil then
				customEvent[self] = {}
			end

			local signal = Signal.new()
			table.insert(customEvent[self], signal)

			signal:Connect(v)

			-- destor the signal when object gets deleted
			self.Destroyed:Connect(function()
				signal:Destroy()
				signal = nil
			end)
		elseif info[1] == Identifiers.Connect or info[1] == Identifiers.Once then
			-- this identifier is meant for using roblox signals
			-- like GetAttributeChangedSignal
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
			-- this identifier calls the function after this thread
			-- meant for running code that's supposed to run after
			-- all the properties have been applied.
			task.defer(v, self)
		elseif info[1] == Identifiers.Merge then
			-- this identifier applies a list of properties to object.
			self:Render(v)
		elseif info[1] == Identifiers.Children then
			-- this identifier accepts a list of objects as child.
			for i, v in v do
				v:Render({ Parent = self.obj })
			end
		elseif info[1] == Identifiers.Reference then
			-- this identifier set's a state object's value to self.
			v.value = self
		elseif typeof(v) == "userdata" then
			-- this is when you want to dynamically change a property's value
			-- so you set it to a state object.
			self.obj[i] = v.value

			local c = v.updated:Connect(function(newValue)
				self.obj[i] = newValue
			end)

			if self.connections[i] then
				self.connections[i]:Disconnect()
			end

			self.connections[i] = c
		else
			-- just a normal roblox property.
			self:SetProperty(i, v)
		end
	end

	-- tells the module that the properties have been applied after
	-- a heartbeat has been fired.
	-- this might be a bad idea but I had no other way of doing this
	-- (tried task.defer but it wasnt safe)
	RunService.Heartbeat:Once(function()
		done:Fire(self)
	end)

	return done:Wait()
end

function class:Clone()
	-- creates a new object with the properties that had the
	-- archivable tag on them.
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
	-- creates an object with the appropriate events and properties.
	local newClass = newproxy(true)
	local meta = getmetatable(newClass)
	local t = {}
	t.Destroyed = Signal.new()
	t.obj = Instance.new(className)
	t.ready = false -- turns true when object's parent stopped being nil
	t.className = className
	t.connections = {}
	t.dragging = false
	t.changes = {
		-- list of properties that are changed and it's children.
		-- the Clone method uses these to have identical properties.
		children = {},
		any = {},
	}

	-- using meta methods to give objects similar use to roblox objects
	-- example: object.Name should return it's name.
	-- and Object.Name = "new" should rename it to "new".
	meta.__index = function(_, i)
		return if t[i] ~= nil then t[i] else if class[i] ~= nil then class[i] else t.obj[i]
	end
	meta.__newindex = function(_, i, v)
		local robloxProperty = newClass:SetProperty(i, v)

		if not robloxProperty then
			t[i] = v
		end
	end
	-- printing the Object would print it's name.
	meta.__tostring = function(_)
		return t.obj.Name
	end

	-- apply the default properties to the object.
	newClass:Render(DEFAULT_PROPERTIES, false)

	return newClass
end

local function IsMouseOverClass(class: Class)
	-- checks if mouse is over the object (used for ui objects)
	local parentGui: ScreenGui = class.obj:FindFirstAncestorWhichIsA("ScreenGui")

	if parentGui then
		local mousePosition = UserInputService:GetMouseLocation()
		local yOffset = parentGui.IgnoreGuiInset == false and guiInset.Y or 0
		local objects =
			Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y - yOffset)

		if #objects > 0 and objects[1] == class.obj then
			return true
		end
	end
end

local lastTouch = -1 -- double clicking on mobile will count as mousebutton2

UserInputService.InputBegan:Connect(function(input)
	-- getting mouse/touch inputs for dragging and zooming in/out
	local mouse

	if input.UserInputType == Enum.UserInputType.Touch then
		-- mobile
		if time() - lastTouch < 0.5 then
			mouse = 2
		else
			mouse = 1
			lastTouch = time()
		end
	else
		-- pc
		mouse = input.UserInputType == Enum.UserInputType.MouseButton1 and 1
			or input.UserInputType == Enum.UserInputType.MouseButton2 and 2
	end

	if mouse then
		-- MouseClick1 or MouseClick2

		if mouse == 1 then
			for class: Class, signals: { Signal.Signal } in customEvents.Drag do
				if IsMouseOverClass(class) then
					class.dragging = UserInputService:GetMouseLocation()

					break
				end
			end
		end

		for class: Class, signals: { Signal.Signal } in customEvents[`Mouse{mouse}Click`] do
			if IsMouseOverClass(class) then
				for _, signal in signals do
					signal:Fire(class)
				end

				break
			end
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	-- getting mouse/touch inputs for dragging and zooming in/out
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local zoomAmount = input.Position.Z
		local style = zoomAmount < 0 and "Out" or "In"
		zoomAmount = math.abs(zoomAmount)

		for class: Class, signals: { Signal.Signal } in customEvents[`Zoom{style}`] do
			if IsMouseOverClass(class) then
				for _, signal in signals do
					signal:Fire(class, zoomAmount)
				end

				break
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	-- getting mouse/touch inputs for dragging and zooming in/out
	local mouse = input.UserInputType == Enum.UserInputType.MouseButton1 and 1
		or input.UserInputType == Enum.UserInputType.MouseButton2 and 2

	if mouse then
		for class: Class, signals: { Signal.Signal } in customEvents.Drag do
			if class.dragging ~= false then
				class.dragging = false

				break
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- loop through objects and give them the new position if theyre getting dragged
	for class: Class, signals: { Signal.Signal } in customEvents.Drag do
		if class.dragging ~= false and class.dragging ~= nil then
			local delta = UserInputService:GetMouseLocation() - class.dragging

			for _, signal in signals do
				signal:Fire(class, delta)
			end

			class.dragging = UserInputService:GetMouseLocation()
		end
	end
end)

-- for type checking
export type Class = {
	obj: Instance,
	className: string,
	Destroyed: Signal.Signal,
	Render: (self: Class, list: { [string]: any }, archivable: boolean) -> Class,
	Clone: (self: Class) -> Class,
}

return module
