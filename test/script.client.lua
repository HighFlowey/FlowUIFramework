local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local module = require(ReplicatedStorage.Packages.Flowuiframework)

local theme = {
	background0 = module.key(Color3.fromRGB(190, 2, 2)),
	background1 = module.key(Color3.fromRGB(208, 42, 42)),
	Button0 = module.key(Color3.fromRGB(208, 42, 42)),
	Button1 = module.key(Color3.fromRGB(190, 2, 2)),
	Text = module.key(Color3.fromRGB(255, 255, 255)),
}

local function HoverStart(self, size: UDim2)
	local goal = { Size = size + UDim2.fromOffset(10, 10) }
	local tween = TweenService:Create(self.obj, TweenInfo.new(0.25), goal)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
end

local function HoverEnd(self, size: UDim2)
	local goal = { Size = size }
	local tween = TweenService:Create(self.obj, TweenInfo.new(0.25), goal)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
end

local templates = {
	Button = module.new("TextButton"):Render({
		BackgroundColor3 = theme.Button0,
		TextColor3 = theme.Text,
		Size = UDim2.fromScale(1, 0.1),
		Text = "Button",
		[module.Connect .. " Activated"] = function(self)
			local newText = self.obj.Text == "Button" and "😈😈😈" or "Button"
			self:Render({
				Text = newText,
			})
		end,
		[module.Connect .. " MouseEnter"] = function(self)
			HoverStart(self, UDim2.fromScale(1, 0.1))
		end,
		[module.Connect .. " MouseLeave"] = function(self)
			HoverEnd(self, UDim2.fromScale(1, 0.1))
		end,
	}),
	ScrollingFrame = module.new("ScrollingFrame"):Render({
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		CanvasSize = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.5),
		[module.Children] = {
			module.new("UIListLayout"):Render({}),
			module.new("UIPadding"):Render({
				PaddingRight = UDim.new(0, 8),
			}),
		},
	}),
}

module.new("ScreenGui"):Render({
	ResetOnSpawn = false,
	Parent = Players.LocalPlayer.PlayerGui,
	[module.Children] = {
		templates.ScrollingFrame:Clone():Render({
			Position = UDim2.fromScale(0.35, 0.5),
			[module.Children] = {
				templates.Button:Clone():Render({}),
				templates.Button:Clone():Render({}),
			},
		}),
		templates.ScrollingFrame:Clone():Render({
			Position = UDim2.fromScale(0.65, 0.5),
			[module.Children] = {
				templates.Button:Clone():Render({}),
				templates.Button:Clone():Render({}),
			},
		}),
	},
})
