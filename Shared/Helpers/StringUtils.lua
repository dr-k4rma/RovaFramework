--[[
	@Title: StringUtils
	@Author: Dr_K4rma aka Alexander Karpov
	@Date: 20 Feb. 2021
    @Package: ServerScriptService.RovaFramework.Shared.Helpers
	@Provides: Utilities for strings
	Credits to Stephen Leitnick, library pulled from their open-source game framework, "Aero Game Framework"
]]

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
function public.Trim(str)
	return str:match("^%s*(.-)%s*$")
end

function public.TrimStart(str)
	return str:match("^%s*(.+)")
end

function public.TrimEnd(str)
	return str:match("(.-)%s*$")
end

function public.EqualsIgnoreCase(str, compare)
	return (str:lower() == compare:lower())
end

function public.RemoveWhitespace(str)
	return str:gsub("%s+", "")
end

function public.RemoveExcessWhitespace(str)
	return str:gsub("%s+", " ")
end

function public.EndsWith(str, endsWith)
	return str:match(public.Escape(endsWith) .. "$") ~= nil
end

function public.StartsWith(str, startsWith)
	return str:match("^" .. public.Escape(startsWith)) ~= nil
end

function public.Contains(str, contains)
	return str:find(contains) ~= nil
end

function public.Escape(str)
	local escaped = str:gsub("([%.%$%^%(%)%[%]%+%-%*%?%%])", "%%%1")
	return escaped
end

----------------------------------
--		MAIN CODE
----------------------------------

return public