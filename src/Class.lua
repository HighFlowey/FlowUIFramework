local Identifiers = require(script.Parent:WaitForChild("Identifiers"))

local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
	["SortOrder"] = Enum.SortOrder.LayoutOrder,
	["BackgroundColor3"] = Color3.fromRGB(79, 79, 79),
	["ScrollBarImageColor3"] = Color3.fromRGB(36, 36, 36),
}

local module = {}
local class = {}

function class:Render(list: {}, archivable: boolean)
	archivable = if archivable ~= nil then archivable else true

	for i, v in list do
		local info = string.split(i, " ")

		if archivable then
			if info[1] == Identifiers.Children then
				for _, original in v do
					table.insert(self.changes.children, original)
				end
			elseif info[1] ~= Identifiers.Reference then
				self.changes.any[i] = v
			end
		end

		if info[1] == Identifiers.Connect or info[1] == Identifiers.Once then
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
			if typeof(v) == "table" then
				for n, value in v do
					local success = pcall(function()
						self.obj[i][n] = value
					end)
				end
			else
				local success = pcall(function()
					self.obj[i] = v
				end)
			end
		end
	end

	return self
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

	meta.__index = function(_, i)
		return class[i] or t[i] or t.obj[i]
	end
	meta.__newindex = function(_, i, v)
		if t[i] then
			t[i] = v
		elseif t.obj[i] then
			t.obj[i] = v
		end
	end
	meta.__tostring = function(_)
		return t.obj.Name
	end

	t.obj = Instance.new(className)
	t.className = className
	t.connections = {}
	t.changes = {
		children = {},
		any = {},
	}

	newClass:Render(DEFAULT_PROPERTIES, false)

	return newClass
end

export type Class = {
	obj: Instance,
	className: string,
	Render: (self: Class, list: { [string]: any }, archivable: boolean) -> Class,
	Clone: (self: Class) -> Class,
}

return module
