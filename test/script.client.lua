local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local module = require(ReplicatedStorage.FlowUIFramework)

local text = module.key("Button")
local theme = {
	background0 = module.key(Color3.fromRGB(190, 2, 2)),
	background1 = module.key(Color3.fromRGB(208, 42, 42)),
	Text = module.key(Color3.fromRGB(255, 255, 255)),
	Button0 = module.key(Color3.fromRGB(208, 42, 42)),
	Button1 = module.key(Color3.fromRGB(190, 2, 2)),
}

local templates = {
	Button = module.new("TextButton"),
	ScrollingFrame = module.new("ScrollingFrame"),
}

templates.Button:Render({
	BackgroundColor3 = theme.Button0,
	TextColor3 = theme.Text,
	Size = UDim2.fromScale(1, 0.1),
	Text = text,
	[module.Connect .. ":Activated:true"] = function(self)
		if self.obj.Text == "Button" then
			self:Render({
				Text = "😈😈😈",
			})
		else
			self:Render({
				Text = "Button",
			})
		end
	end,
	[module.Connect .. ":MouseEnter:true"] = function(self)
		local goal = { Size = UDim2.fromScale(1, 0.1) + UDim2.fromOffset(10, 10) }
		local tween = TweenService:Create(self.obj, TweenInfo.new(0.25), goal)
		tween:Play()
		tween.Completed:Connect(function()
			tween:Destroy()
		end)
	end,
	[module.Connect .. ":MouseLeave:true"] = function(self)
		local goal = { Size = UDim2.fromScale(1, 0.1) }
		local tween = TweenService:Create(self.obj, TweenInfo.new(0.25), goal)
		tween:Play()
		tween.Completed:Connect(function()
			tween:Destroy()
		end)
	end,
})

templates.ScrollingFrame:Render({
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 8,
	CanvasSize = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.3, 0.5),
	[module.Children] = {
		module.new("UIListLayout"):Render({}),
		module.new("UIPadding"):Render({
			PaddingRight = UDim.new(0, 8),
		}),
	},
})

module.new("ScreenGui"):Render({
	ResetOnSpawn = false,
	Parent = Players.LocalPlayer.PlayerGui,
	[module.Children] = {
		templates.ScrollingFrame.create():Render({
			[module.Children] = {
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
				templates.Button.create():Render({}),
			},
		}),
	},
})
