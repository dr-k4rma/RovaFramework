--[[
	@Title: ReferenceHolder
	@Author: Dr_K4rma
	@Date: 10 Apr. 2021
	@Package: ServerScriptService.RovaFramework.Shared.Helpers
	@Provides: Holds a reference to an object until said object has been deleted (parent set to nil)
]]--

--[[
	Hello future me! (or whomever is reading this)
	You might be wondering why this module even exists, and luckily, I had a bit of foresight, so here we go!
	
	So essentially, when using setmetatable({}, {__mode = "v"}), the mode is set to be used in such a way, that the
	key-value pair is removed from the dictionary if there is no longer any references to it. However, there is a *bit* of
	an edge case to it, and that the following:
	
	If the object exists, and is parented to any real ROBLOX object, it will still be cleaned up from the table, since no
	reference exists to it in code. This module was created to address this edge-case. Essentially, when you call
	ReferenceHolder.Store(Object), the object gets loaded into the holdStorage table, therefore creating a reference to the object,
	which allows weak tables to keep the object in storage. However, as soon as the object is destroyed (parent is set to nil), the
	reference to the object gets removed from holdStorage, which allows any other weak tables to also remove the object from their
	storage.
	
	Yup. That's it. That's the only reason for this module's existence.
	
	Memory leaks are scary!
]]

local public = {}

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
local holdStorage = {}

----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------
local function cleanupStorage(Object, NewParent)
	if NewParent == nil then
		for i, v in pairs(holdStorage) do
			if v == Object then
				holdStorage[i] = nil
			end
		end
	end
end

----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------

--[[
	Adds an Object to referenceStorage
	This is done specifically to hold a reference until such a time that said instance is destroyed
	@Object <Instance> Instance Object to store
	@returns <Instance> Object
]]
function public.Store(Object)
	assert(typeof(Object) == "Instance", "Passed object \""..tostring(Object).."\" is not of type 'Instance'\n"..debug.traceback())
	
	local addIndex = #holdStorage + 1
	holdStorage[addIndex] = Object
	Object.AncestryChanged:Connect(cleanupStorage)
	
	return Object
end

----------------------------------
--		MAIN CODE
----------------------------------

return public