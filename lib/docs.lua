--[=[
@class Identifier

Only usable in properties list
]=]

--[=[
@class Module
]=]

--[=[
@prop Connect Identifier
@within Module
]=]

--[=[
@prop Once Identifier
@within Module
]=]

--[=[
@prop Merge Identifier
@within Module
]=]

--[=[
@prop Children Identifier
@within Module
]=]

--[=[
@prop Init Identifier
@within Module
]=]

--[=[
@prop Reference Identifier
@within Module
]=]

--[=[
@function key
@within Module

@param v any -- default value
@return Key
]=]

--[=[
@class Key

When changed, it will automatically update the properties it's attached to
]=]

--[=[
@prop value any
@within Key
]=]

--[=[
@prop updated Signal
@within Key
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
@prop obj Instance
@within Class
]=]

--[=[
@method Render
@within Class

@param properties {[string]: any} -- list of properties and identifiers
@param archivable boolean -- list will not apply to clones if set to false (default is true)
@return Class
]=]

--[=[
@method Clone
@within Class

@return Class
]=]

return true
