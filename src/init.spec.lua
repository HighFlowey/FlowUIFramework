local Players = game:GetService("Players")
return function()
	local FlowUIFramework = require(script.Parent)

	local class = FlowUIFramework.new("ScreenGui")

	afterAll(function()
		class.obj:Destroy()
	end)

	describe("Module.new", function()
		it("Should return a Class", function()
			expect(class).to.be.ok()
			expect(class.obj).to.be.ok()
			expect(class.className).to.be.ok()
			expect(class.Render).to.be.ok()
			expect(class.Clone).to.be.ok()
		end)
	end)

	describe("Identifier", function()
		it("Identifier.Children should add children to Class.obj", function()
			class:Render({
				-- Archivable properties
				[FlowUIFramework.Children] = {
					FlowUIFramework.new("Frame"):Render({
						Name = "TempFrame",
						Size = UDim2.fromScale(1, 1),
					}),
				},
			}, false)

			expect(class.obj.TempFrame).to.be.ok()
		end)

		it("Identifier.Merge should add a list of properties to Class.obj", function()
			class:Render({
				-- Archivable properties
				[FlowUIFramework.Merge] = { IgnoreGuiInset = true },
			}, false)

			expect(class.obj.IgnoreGuiInset).to.equal(true)
		end)

		it("Identifier.Init should call a function after Class:Render method is finished setting properties", function()
			class:Render({
				-- Archivable properties
				DisplayOrder = 10,
				[FlowUIFramework.Init] = function(self)
					expect(self.obj.DisplayOrder).to.equal(10)
				end,
			}, false)
		end)

		it("Identifier.Connect should call function when event is fired", function()
			local times = 0

			class:Render({
				[FlowUIFramework.Connect .. " Changed"] = function(self)
					times += 1
				end,
			}, false)

			for i = 1, 3 do
				class:Render({
					DisplayOrder = i,
				}, false)
			end

			expect(times).to.equal(3)
		end)

		it("Identifier.Once should call function ONCE when event is fired", function()
			local times = 0

			class:Render({
				[FlowUIFramework.Once .. " Changed"] = function(self)
					times += 1
				end,
			}, false)

			for i = 1, 3 do
				class:Render({
					DisplayOrder = i,
				}, false)
			end

			expect(times).to.equal(1)
		end)

		it("Identifier.Reference should set Key.value to Class.obj", function()
			local key = FlowUIFramework.key()

			class:Render({
				[FlowUIFramework.Reference] = key,
			})

			expect(key.value).to.equal(class)
		end)
	end)

	describe("Class", function()
		it("Should have a Roblox ScreenGui Instance as it's .obj property", function()
			expect(typeof(class.obj)).to.equal("Instance")
			expect(class.obj.ClassName).to.equal("ScreenGui")
			expect(class.className).to.equal(class.obj.ClassName)
		end)

		it("Render method should change object's property", function()
			class:Render({
				-- Archivable properties
				Name = "TempScreenGui",
			})
			class:Render({
				-- Non-Archivable properties
				ResetOnSpawn = false,
				Parent = Players.LocalPlayer.PlayerGui,
			}, false)
			expect(class.obj.Name).to.equal("TempScreenGui")
		end)

		it("Clone method should clone .obj property", function()
			local clone = class:Clone()
			expect(clone.obj.Name).to.equal("TempScreenGui")

			afterAll(function()
				clone.obj:Destroy()
			end)

			it("Shouldn't clone property changes that weren't archivable", function()
				expect(clone.obj.Parent).to.never.equal(Players.LocalPlayer.PlayerGui)
				expect(clone.obj.ResetOnSpawn).to.never.equal(false)
			end)
		end)

		it("Should return it's .obj properties without using .obj", function()
			expect(class.Name).to.equal("TempScreenGui")
		end)
	end)
end
