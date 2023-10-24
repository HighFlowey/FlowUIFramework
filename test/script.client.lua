local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = require(ReplicatedStorage.FlowUIFramework)
local Reference = module.Reference
local Children = module.Children
local Merge = module.Merge
local Event = module.Event
local Value = module.Value

local text = Value("Hi Hi Hi !!!")
local textlabelPreset = {
	["BackgroundColor3"] = Color3.fromRGB(113, 0, 0),
	["TextColor3"] = Color3.fromRGB(255, 255, 255),
}

local textlabelTemplate = module.new("TextLabel"):Render({
	[Merge] = textlabelPreset,
	["Text"] = text,
	[Event("MouseEnter", true)] = function(self)
		print(self) -- TextLabel
	end,
})

local textlabel = Value()
local screenGui: ScreenGui = module.new("ScreenGui"):Render({
	["Name"] = "GUI",
	["ResetOnSpawn"] = false,
	[Children] = {
		module.clone(textlabelTemplate):Render({
			[Reference] = textlabel,
		}),
	},
})

print(textlabel.value) -- TextLabel

screenGui.Parent = Players.LocalPlayer.PlayerGui

while true do
	text.value = "LOL!"
	task.wait(5)
	text.value = "UH HUH!"
	task.wait(5)
end
