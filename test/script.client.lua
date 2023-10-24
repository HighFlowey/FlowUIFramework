local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = require(ReplicatedStorage.FlowUIFramework)
local text = module.key("lol")
local color = module.key(Color3.fromRGB(243, 51, 51))
local template = module.new("TextLabel")

template:Render({
	["BackgroundColor3"] = color,
	["TextColor3"] = Color3.fromRGB(255, 255, 255),
	["TextScaled"] = true,
	["Size"] = UDim2.fromOffset(100, 50),
	["Font"] = Enum.Font.ArialBold,
	[module.Once .. ":MouseEnter:true"] = function(self)
		self:Render({
			["Transparency"] = self.obj.Transparency + 0.5,
			["BackgroundColor3"] = self.obj.BackgroundColor3,
			["Text"] = "Yiouch!",
		})
	end,
	["Text"] = text,
})

module.new("ScreenGui"):Render({
	["ResetOnSpawn"] = false,
	["Parent"] = Players.LocalPlayer.PlayerGui,
	[module.Children] = {
		template.create():Render({}),
		template.create():Render({
			Position = UDim2.fromOffset(template.obj.Size.X.Offset + 5),
		}),
		template.create():Render({
			Position = UDim2.fromOffset(template.obj.Size.X.Offset * 2 + 10),
		}),
	},
})

while true do
	task.wait(2)
	text.value = "NONONO"
	color.value = Color3.fromRGB(51, 189, 243)
	task.wait(2)
	text.value = "YES"
	color.value = Color3.fromRGB(243, 51, 51)
end
