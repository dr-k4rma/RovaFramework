--[[
	@Title: ObjectClass
	@Author: Dr_K4rma
	@Date: 8 Apr. 2021
	@Package: ServerScriptService.RovaFramework.Shared.Classes
	@Provides: Bottom-line base object for use in OOP
]]--

_G()
local public = {}
public.__index = public

----------------------------------
--		DEPENDENCIES
----------------------------------


----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------


----------------------------------
--		CONFIG VARIABLES
----------------------------------


----------------------------------
--		MISC VARIABLES
----------------------------------


----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------


----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------

function public:Destroy()
	if self.Object then
		self.Object:Destroy()
	end

	self.Object = nil
	self.connections = nil

	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
end

function public.new(Object)
	local self = setmetatable({}, public)

	self.Object = Object
	self.connections = {}

	return self
end

return public