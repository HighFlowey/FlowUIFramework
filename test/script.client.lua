local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = require(ReplicatedStorage.FlowUIFramework)
local Reference = module.Reference
local Children = module.Children
local Connect = module.Event
local Merge = module.Merge
local Value = module.Value
local Once = module.Once

local text = Value("Hi Hi Hi !!!") -- will automatically update properties when changed
local textlabelPreset = {
	["BackgroundColor3"] = Color3.fromRGB(113, 0, 0),
	["TextColor3"] = Color3.fromRGB(255, 255, 255),
	["Size"] = UDim2.fromOffset(100, 50),
}

local textlabelTemplate = module.new("TextLabel"):Render({
	[Merge] = textlabelPreset, -- apply properties from a table
	["Name"] = "TemplateTextLabel",
	["Text"] = text, -- autoupdate works for cloned objects aswell
	[Connect("MouseEnter", true)] = function(self) -- event applies to cloned objects because of the second argument
		self.Size = self.Size + UDim2.fromOffset(15, 15)
	end,
	[Connect("MouseLeave", true)] = function(self)
		self.Size = self.Size - UDim2.fromOffset(15, 15)
	end,
	[Once("MouseWheelForward", true)] = function(self)
		self.Transparency += 0.5
	end,
})

local textlabel = Value()
local screenGui: ScreenGui = module.new("ScreenGui"):Render({
	["Name"] = "GUI",
	["ResetOnSpawn"] = false,
	[Children] = {
		module.clone(textlabelTemplate):Render({
			[Reference] = textlabel,
			["Name"] = "TestTextLabel_1",
		}),
		module.clone(textlabelTemplate):Render({
			["Name"] = "TestTextLabel_2",
			["Position"] = UDim2.fromOffset(textlabel.value.Size.X.Offset + 5, 0),
		}),
	},
})

print(textlabel.value) -- TestTextLabel_1

screenGui.Parent = Players.LocalPlayer.PlayerGui

while true do
	text.value = "LOL!"
	task.wait(5)
	text.value = "UH HUH!"
	task.wait(5)
end
