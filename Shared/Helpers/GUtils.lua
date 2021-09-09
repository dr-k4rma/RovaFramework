--[[
	GUtils "General Utilities"
	Author: Dr_K4rma aka Alexander Karpov
	Date: 5 Feb. 2021
	Provides: General utilities for use in scripts
]]

_G()
local public = {}

----------------------------------
--		DEPENDENCIES
----------------------------------


----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------
local RS = game:GetService("RunService")

----------------------------------
--		CONFIG VARIABLES
----------------------------------


----------------------------------
--		MISC VARIABLES
----------------------------------


----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------
local function createInstance(name, class, Parent)
	local inst = Instance.new(class)
	inst.Name = name
	inst.Parent = Parent
	return inst
end

----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------
--[[
	Instance:FindFirstChild() but also makes sure the class matches
	@f_name <String> name of the descendant to find
	@f_class <String> classname of the descendant to find
	@f_Parent <Instance> instance whose descendants to search
	@f_recursive <boolean> whether to search just the children of the parent, or all the descendants. False by default.
	@returns <Instance> found object or nil if no object found
]]
function public.FindFirstChildOfNameAndClass(f_name, f_class, f_Parent, f_recursive)
	f_recursive = f_recursive or false
	local toSearch = f_recursive and f_Parent:GetDescendants() or f_Parent:GetChildren()
	for _, inst in pairs(toSearch) do
		if inst.Name == f_name and inst.ClassName == f_class then
			return inst
		end
	end
end

--[[
	Retrieves the specified object by name and class. If it already exists in the parent, returns that object
	@f_name <String> name of object to retrieve
	@f_class <String> classname of object to retrieve
	@f_Parent <Instance> instance whose children to search
	@f_yields <boolean> whether or not the function yields when it doesn't find the object it was looking for. Mainly useful on the client when waiting for a specific object to be created.
]]
function public.Retrieve(f_name, f_class, f_Parent, f_yields)
	f_yields = f_yields or false
	local instanceCreated = false

	local SearchInstance = public.FindFirstChildOfNameAndClass(f_name, f_class, f_Parent)
	if SearchInstance then 
		return SearchInstance, instanceCreated
	elseif f_yields then
		return f_Parent:WaitForChild(f_name), instanceCreated
	else
		instanceCreated = true
		SearchInstance = createInstance(f_name, f_class, f_Parent)
	end

	return SearchInstance, instanceCreated
end

--[[
	Retrieves only the children that match the passed condition function
	@f_Parent <Instance> instance whose children to search
	@f_conditionFunction <function(<Child>)> function to use when filtering the children
	@returns <table> table with children that match the condition function
]]
function public.GetChildrenWithCondition(f_Parent, f_conditionFunction)
	local children = {}
	for _, Child in pairs(f_Parent:GetChildren()) do
		if f_conditionFunction(Child) then
			table.insert(children, Child)
		end
	end
	return children
end

--[[
	Retrieves only the descendants that match the passed condition function
	@f_Ancestor <Instance> instance whose descendants to search
	@f_conditionFunction <function(<Descendant>)> function to use when filtering the children
	@returns <table> table with children that match the condition function
]]
function public.GetDescendantsWithCondition(f_Ancestor, f_conditionFunction)
	local descendants = {}
	for _, Descendant in pairs(f_Ancestor:GetDescendants()) do
		if f_conditionFunction(Descendant) then
			table.insert(descendants, Descendant)
		end
	end
	return descendants
end

--[[
	Linear interpolation function
	@v0 <number> start value
	@v1 <number> end value
	@i <number> interpolation range from 0-1
	@returns <number> interpolated value
]]
function public.Lerp(v0, v1, i)
	return v0 + (v1 - v0) * i
end

--[[
	Function to modify an instance using a passed dictionary
	@f_Instance <Instance> instance to modify
	@f_properties <table> dictionary whose entries to use to modify the instance
]]
function public.Modify(f_Instance, f_properties)
	for property, value in pairs(f_properties) do
		f_Instance[property] = value
	end
end

--[[
	Rounding function with factor definition
	@f_number <number> number to round
	@f_factor <int> factor to use when rounding (i.e. factor of 0 will round to nearest integer)
	@returns <number> rounded number
]]
function public.Round(f_number, f_factor)
	local mult = 10 ^ (f_factor or 0)
	return math.floor((f_number * mult) + 0.5) / mult
end

function public.RoundNearestInterval(number, factor)
	return public.Round(number / factor) * factor
end

--[[
	Runs (promised) function on child of specified name when it is added. Timeout for promise is 10 seconds.
	@f_Parent <Instance> parent whose child to wait for
	@f_name <String> name of child to wait for
	@f_andThen <function(<Child>, ...)> function to run when child is found
	@... <any[]> additional arguments to pass to the 'andThen' function
]]
function public.PromiseChild(f_Parent, f_name, f_andThen, ...)
	local promise = coroutine.wrap(function(...)
		local Child = f_Parent:WaitForChild(f_name, 10)

		if Child then
			f_andThen(Child, ...)
		end
	end)

	promise(...)
end

----------------------------------
--		MAIN CODE
----------------------------------

return public