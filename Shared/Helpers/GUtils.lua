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
function public.FindFirstChildOfNameAndClass(name, class, Parent, recursive)
	recursive = recursive or false
	local toSearch = recursive and Parent:GetDescendants() or Parent:GetChildren()
	for _, inst in pairs(toSearch) do
		if inst.Name == name and inst.ClassName == class then
			return inst
		end
	end
end

function public.Retrieve(name, class, Parent, yields)
	yields = yields or false
	local instanceCreated = false

	local SearchInstance = public.FindFirstChildOfNameAndClass(name, class, Parent)
	if SearchInstance then 
		return SearchInstance, instanceCreated
	elseif yields then
		return Parent:WaitForChild(name), instanceCreated
	else
		instanceCreated = true
		SearchInstance = createInstance(name, class, Parent)
	end

	return SearchInstance, instanceCreated
end

function public.GetChildrenWithCondition(Parent, conditionFunction)
	local children = {}
	for _, Child in pairs(Parent:GetChildren()) do
		if conditionFunction(Child) then
			table.insert(children, Child)
		end
	end
	return children
end

function public.GetDescendantsWithCondition(Ancestor, conditionFunction)
	local descendants = {}
	for _, Descendant in pairs(Ancestor:GetDescendants()) do
		if conditionFunction(Descendant) then
			table.insert(descendants, Descendant)
		end
	end
	return descendants
end

function public.Lerp(v0, v1, i)
	return v0 + (v1 - v0) * i
end

function public.Modify(Object, properties)
	for property, value in pairs(properties) do
		Object[property] = value
	end
end

function public.Round(number, factor)
	local mult = 10 ^ (factor or 0)
	return math.floor((number * mult) + 0.5) / mult
end

function public.RoundNearestInterval(number, factor)
	return public.Round(number / factor) * factor
end

function public.StepTowards(value, goal, rate)
	if math.abs(value - goal) < rate then
		return goal
	elseif value > goal then
		return value - rate
	elseif value < goal then
		return value + rate
	end
end

function public.PromiseChild(Object, name, andThen, ...)
	local promise = coroutine.wrap(function (...)
		local Child = Object:WaitForChild(name, 10)

		if Child then
			andThen(Child, ...)
		end
	end)

	promise(...)
end

function public.PromiseValue(Object, prop, andThen, ...)
	local args = {...}

	local promise = coroutine.wrap(function (...)
		local timeOut = tick() + 10

		while not Object[prop] do
			local now = tick()

			if (timeOut - now) < 0 then
				return
			end

			RS.Heartbeat:Wait()
		end

		andThen(Object[prop], ...)
	end)

	promise(...)
end

----------------------------------
--		MAIN CODE
----------------------------------

return public