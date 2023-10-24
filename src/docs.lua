local module = {}

--[=[
    @class Module
]=]

--[=[
	@function new
	@within Module

	@param className string -- a roblox class (e.g., ScreenGui or Frame)
	@return Template
	Creates a template.
]=]

--[=[
    @class Template
]=]

--[=[
	@prop obj Instance
	@within Template

	The roblox instance that's attached to this template.
]=]

--[=[
	@method Render
	@within Template

	@param properties {} -- A table of properties that you want to apply to the template.
	Returns a handler created by the template.
]=]

--[=[
	@function create
	@within Template

	@return Handler
	Returns a handler (clones the template) created by the template.
]=]

--[=[
    @class Handler
]=]

--[=[
	@prop obj Instance
	@within Handler

	The roblox instance that's attached to this handler.
]=]

return module
