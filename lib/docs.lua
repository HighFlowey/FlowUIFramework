--[=[
@class Identifier

Use these as [Properties] when using [Class:Render]
]=]

--[=[
@prop Connect Identifier
@within Module

Bind a function to a Roblox Event

```lua
Class:Render({
    [Module.Connect.." Activated"] = function(self)
        self.obj:Destroy() -- destroys itself when clicked
    end
})
```
]=]

--[=[
@prop Once Identifier
@within Module

Bind a function that only gets called once, to a Roblox Event

```lua
Class:Render({
    [Module.Connect.." Activated"] = function(self)
        self.obj:Destroy() -- destroys itself when clicked
    end
})
```
]=]

--[=[
@prop Merge Identifier
@within Module

Add a list of [Properties] to [Class]

```lua
local properties = {
    Name = "ScreenGui"
    Parent = StarterGui,
}

Class:Render({
    [Module.Merge] = properties
})
```
]=]

--[=[
@prop Children Identifier
@within Module

Create/Add children inside of [Class]

```lua
Class:Render({
    [Module.Children] = {
        -- Create 3 TextLabels inside Class
        Module.new("TextLabel"):Render({}),
        Module.new("TextLabel"):Render({}),
        Module.new("TextLabel"):Render({}),
    }
})
```
]=]

--[=[
@prop Init Identifier
@within Module

Bind a function that gets called once [Class:Render] is finished

```lua
Class:Render({
    Parent = StarterGui,
    [Module.Init] = function(self)
        print(self.obj.Parent) -- StarterGui
    end
})
```
]=]

--[=[
@prop Reference Identifier
@within Module

Set [Class] to a [Key]'s value

```lua
local ref = Module.key()

Class:Render({
    Name = "TestClass",
    [Module.Reference] = ref,
})

print(ref.obj) -- TestClass
```
]=]

--[=[
@class Module
]=]

--[=[
@function key
@within Module

@param v any -- default value
@return Key

Creates a [Key]

```lua
local text = Module.key("Testing")

local class = Class:Render({
    Name = text,
    [Module.Init] = function(self)
        print(self.obj.Name) -- Testing
    end
})

text.value = "MyClass"

print(class.Name) -- MyClass
```
]=]

--[=[
@class Key

When [Key.value] is changed, the [Properties] it's attached to will auto update to the new value
]=]

--[=[
@prop value any
@within Key
]=]

--[=[
@prop updated Signal
@within Key

Fires automatically when [Key.value] is changed
]=]

--[=[
@function new
@within Module

@param className string
@return Class
]=]

--[=[
@class Class
]=]

--[=[
@type Properties {[string|Identifier]: any}
@within Class
]=]

--[=[
@prop obj Instance
@within Class
]=]

--[=[
@method Render
@within Class

@param properties Properties -- list of properties and identifiers
@param archivable boolean -- list will not apply to clones if set to false (default is true)
@return Class
]=]

--[=[
@method Clone
@within Class

@return Class
]=]

return true
