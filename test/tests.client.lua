local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

local tests = {
	ReplicatedStorage.Packages.Flowuiframework,
}

TestEZ.TestBootstrap:run(tests)
