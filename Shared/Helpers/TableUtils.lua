--[[
	@Title: scriptName
	@Author: Dr_K4rma
	@Date: 11 Apr. 2021
	@Package: ServerScriptService.RovaFramework.Shared.Helpers
	@Provides: Utility module for working with tables.
]]--

_G()
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


----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------


----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------
--[[
    Returns another table with the filtered results of the entries that matched the conditionFunction
    @f_table <table> table to filter through
    @f_conditionFunction <function(<value>, <index>)> function to use to filter the passed table
    @f_maintainIndex <boolean> maintains the index from the original table to the returned table. Mainly useful for dictionaries. False by default.
    @returns <table> table with filtered entries
]]
function public.FilterTableBy(f_table, f_conditionFunction, f_maintainIndex)
	f_maintainIndex = f_maintainIndex or false
	local temp = {}
	for index, value in pairs(f_table) do
		if f_conditionFunction(value, index) then
			if f_maintainIndex then
				temp[index] = value
			else
				table.insert(temp, value)
			end
		end
	end
	return temp
end

--[[
    Finds ocurrence of value and returns the index where it was found. Returns nil if no value found.
    @f_haystack <table> table to search through
    @f_needle <f_Needle> value to try and find in the haystack
    @returns <int> index at which the value was found
]]
function public.FindTableOccurrence(f_haystack, f_Needle)
	for index, value in pairs(f_haystack) do
		if value == f_Needle then
			return index
		end
	end
end

--[[
    Whether or not a certain value is in a table. If you're asking why this function is necessary... It's really not, it's more for readability.
    @f_haystack <table> table to search through
    @f_needle <f_Needle> value to try and find in the haystack
    @returns <boolean> whether or not the needle is present in the haystack
]]
function public.IsInTable(f_haystack, f_Needle)
	if (public.FindTableOccurrence(f_haystack, f_Needle) == nil) then return false end
	return true
end

----------------------------------
--		MAIN CODE
----------------------------------


return public