local Identifiers = require(script.Parent:WaitForChild("Identifiers"))

local DEFAULT_PROPERTIES = {
	["TextScaled"] = true,
	["BorderSizePixel"] = 0,
	["Size"] = UDim2.fromOffset(200, 150),
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
			else
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
			local success = pcall(function()
				self.obj[i] = v
			end)
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

local classMeta = {
	__index = class,
}

function module.new(className: string): Class
	local newClass = setmetatable({}, classMeta)
	newClass.obj = Instance.new(className)
	newClass.className = className
	newClass.connections = {}
	newClass.changes = {
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
