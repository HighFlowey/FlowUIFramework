--[=[
@class Identifier

Use these as [Properties] when using [Class:Render]
]=]

--[=[
@prop Mouse1Click Identifier
@within Module

Bind a function that gets called when mousebutton1 is pressed on a gui object

```lua
Class:Render({
    [Module.Mouse1Click] = function(self)
        self.obj:Destroy() -- destroys itself when clicked
    end
})
```
]=]

--[=[
@prop Mouse2Click Identifier
@within Module

Bind a function that gets called when mousebutton2 is pressed on a gui object (on mobile this counts as double click)

```lua
Class:Render({
    [Module.Mouse2Click] = function(self)
        self.obj:Destroy() -- destroys itself when right clicked
    end
})
```
]=]

--[=[
@prop Drag Identifier
@within Module

Bind a function that gets called when ui object is getting dragged by mouse or touch

```lua
Class:Render({
    [Module.Drag] = function(self, delta)
        -- delta is Vector2
        self.obj.Position += Udim2.fromOffset(delta.X, delta.Y)
    end
})
```
]=]

--[=[
@prop ZoomIn Identifier
@within Module

Bind a function that gets called when ui should zoomin by using mouse wheel or pinch gestures on mobile devices

```lua
Class:Render({
    [Module.ZoomIn] = function(self, delta)
        -- delta is Vector2
        self.obj.Size += Udim2.fromOffset(delta.X, delta.Y)
    end
})
```
]=]

--[=[
@prop ZoomOut Identifier
@within Module

Bind a function that gets called when ui should zoomout by using mouse wheel or pinch gestures on mobile devices

```lua
Class:Render({
    [Module.ZoomOut] = function(self, delta)
        -- delta is Vector2
        self.obj.Size -= Udim2.fromOffset(delta.X, delta.Y)
    end
})
```
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
        print(self.Parent) -- StarterGui
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

print(ref.value) -- TestClass
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
        print(self.Name) -- Testing
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

Created by using [Module.new]
This class holds all the methods and properties that you need to use to create and manage objects

```lua
local myClass = Class:Render({
    Name = "MyClass",
    ResetOnSpawn = false,
})

print(myClass.Name, myClass.ResetOnSpawn) -- MyClass, false

myClass:Render({
    Name = "ScreenGui"
})

print(myClass.Name) -- ScreenGui
```
]=]

--[=[
@prop obj Instance
@within Class

Returns the Roblox Instance created by [Class]
]=]

--[=[
@prop Destroyed Signal
@within Class

Fires when [Class] is destroyed
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

--[=[
@type Properties {[string|Identifier]: any}
@within Class
]=]

return true
