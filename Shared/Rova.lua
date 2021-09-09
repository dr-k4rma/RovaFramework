--[[
	@Title: Rova Framework
	@Author: Dr_K4rma aka Alexander Karpov
	@Date: 1 Feb. 2021
	@Package: RovaFramework.Shared
	@Provides: Rova Framework Driver
]]

local module = {}

----------------------------------
--		DEPENDENCIES
----------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local RS = game:GetService("RunService")

----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------


----------------------------------
--		CONFIG VARIABLES
----------------------------------
local FRAMEWORK_TAG_NAME = "RovaFrameworkFolder"	-- The tag that is used to identify Rova Framework folders
local USE_INJECTED_METHODS = true					-- Whether or not to allow Rova to inject methods into the function environment of the scripts where it is initialized
local CLEAR_GLOBAL_AFTER_LOAD_ON_CLIENT = true		-- Whether _G as callable function is cleared after modules are all loaded. Setting this to false presents security rist for client-side

----------------------------------
--		MISC VARIABLES
----------------------------------
local frameworkFolders = {}
local packages = {}
local default = {}

local ServerIgnoreClientDirectories = {
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer"),
}

----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------
local errorNoBreak = function(err)
	spawn(function()
		error(err.."\n"..debug.traceback())
	end)
	wait()
end

local function isInTable(Needle, haystack)
	for _, element in pairs(haystack) do
		if element == Needle then
			return true
		end
	end
	return false
end

local function createInstance(name, class, Parent)
	local inst = Instance.new(class)
	inst.Name = name
	inst.Parent = Parent
	return inst
end

local function findFirstChildOfNameAndClass(name, class, Parent, recursive)
	recursive = recursive or false
	local toSearch = recursive and Parent:GetDescendants() or Parent:GetChildren()
	for _, inst in pairs(toSearch) do
		if inst.Name == name and inst.ClassName == class then
			return inst
		end
	end
end

local function retrieve(name, class, Parent, yields)
	yields = yields or false
	local instanceCreated = false

	local SearchInstance = findFirstChildOfNameAndClass(name, class, Parent)
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

local function loadModule(Module)
	local moduleHandle;
	if typeof(Module) == "string" then
		moduleHandle = Module
	elseif typeof(Module) == "Instance" then
		moduleHandle = Module.Name
	end

	local Module = packages[moduleHandle]
	if typeof(Module) == "Instance" then
		local success, err = pcall(function()
			local ModuleObject = Module
			Module = require(Module)
			-- If on client, also deletes the module
			if RS:IsClient() then
				ModuleObject:Destroy()
			end
		end)
		if not success then
			error("Failed to load module "..Module:GetFullName()..". Errata as follows:\n"..err)
		end
		packages[moduleHandle] = Module
		return Module
	elseif typeof(Module) == "table" then
		return Module
	end
end

local function manifestHandleInit(ManifestFile)
	local manifest = nil
	local success, err = pcall(function()
		manifest = require(ManifestFile)
	end)
	if not success then
		error("Failed to load module "..ManifestFile:GetFullName()..": "..err)
	end
	return manifest
end

local function manifestHandleMove(ManifestFile)
	local manifest = require(ManifestFile)
	
	-- If on the server, move folders to proper location
	if not RS:IsClient() then
		if manifest.__location then
			local FrameworkFolder = retrieve("RovaFramework", "Folder", manifest.__location)
			CS:AddTag(ManifestFile.Parent, FRAMEWORK_TAG_NAME)
			ManifestFile.Parent.Parent = FrameworkFolder
		end
	end
end

local function manifestHandleLoad(ManifestFile)
	local manifest = require(ManifestFile)
	
	-- Implementation of ignore function based on tag in manifest
	if manifest.__tags then
		if RS:IsClient() then
			--print("Client: Ignoring "..ManifestFile:GetFullName())
			if isInTable("ClientIgnore", manifest.__tags) then return end
		else
			--print("Server: Ignoring "..ManifestFile:GetFullName())
			if isInTable("ServerIgnore", manifest.__tags) then return end
		end
	end

	-- Handles the loading of manifest-defined modules
	for index, path in pairs(manifest) do
		if string.sub(index, 1, 2) == "__" then continue end

		local splitPath = string.split(path, ".")
		local Module = frameworkFolders
		for _, directory in pairs(splitPath) do
			Module = Module[directory]
		end
		coroutine.wrap(loadModule)(Module)
	end
end

local function importHandler(moduleName)
	local fenv = getfenv(0)

	fenv[moduleName] = loadModule(moduleName)
end

--[[	
	@DEPRECIATED
	Due to roblox's getfenv() limitations in scripts, getfenv doesn't actually get the the variables in the
	local environment. I.e. if public is defined in the 0th fenv, getfenv will not see it.
	RIP one of the major functionalities of Rova ;-;
]]
local function extendsHandler(superName)
	local fenv = getfenv(0)

	-- Makes sure that super is properly imported
	if(typeof(superName) == "string") then
		if not (fenv[superName]) then
			error("Failed to extend class \'"..superName.."\', make sure the class is imported:\n"..debug.traceback())
		end
	end

	local public = fenv.public

	-- Implements super as actual super
	fenv.super = fenv[superName]

	fenv.public = setmetatable(fenv.public, {__index = fenv[superName]})
	fenv.public.__index = fenv.public

	--setmetatable(fenv.public, {__index = fenv[superName]})
end

local function initHandler(Module)
	if USE_INJECTED_METHODS then
		local fenv = getfenv(0)
		
		-- Injecting new methods
		fenv.import = importHandler
	end
end

----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------
--[[
	Returns the library table with the passed name
	@f_name <String> name of library
	@returns <table> table of functions from library
]]
function module:LoadLibrary(f_name)
	return loadModule(f_name)
end

----------------------------------
--		MAIN CODE
----------------------------------

-- Getting FrameworkFolders
if RS:IsClient() then
	for _, Folder in pairs(CS:GetTagged(FRAMEWORK_TAG_NAME)) do
		frameworkFolders[Folder.Name] = Folder
	end
else
	for _, Folder in pairs(ServerScriptService.RovaFramework:GetChildren()) do
		if Folder:IsA("Folder") then
			frameworkFolders[Folder.Name] = Folder
		end
	end
end

-- Caching all modules
for _, FrameworkFolder in pairs(frameworkFolders) do
	for _, Module in pairs(FrameworkFolder:GetDescendants()) do
		if not Module:IsA("ModuleScript") then continue end
		if string.sub(Module.Name, 1, 1) == "." then continue end
		packages[Module.Name] = Module
	end
end

-- Storing reference to rova in _G
_G.Rova = module

-- Initializing _G as callable table
setmetatable(_G, {__call = initHandler})

-- Handle initialization of manifest files
for _, FrameworkFolder in pairs(frameworkFolders) do
	local Manifest = FrameworkFolder:FindFirstChild(".Manifest")
	
	if not Manifest then
		errorNoBreak(FrameworkFolder:GetFullName().." is missing a manifest file")
		continue
	end
	
	local success, err = pcall(manifestHandleInit, Manifest)
	if not success then
		error("[Manifest Initialization Failure]: "..Manifest:GetFullName()..". Errata as follows:\n"..err)
	end
end

-- Handle moving of framework folders
for _, FrameworkFolder in pairs(frameworkFolders) do
	local Manifest = FrameworkFolder:FindFirstChild(".Manifest")
	
	local success, err = pcall(manifestHandleMove, Manifest)
	if not success then
		error("[Directory Move Failure]: "..Manifest:GetFullName()..". Errata as follows:\n"..err)
	end
end

-- Handles loading of the modules defined in the manifest file
for _, FrameworkFolder in pairs(frameworkFolders) do
	local Manifest = FrameworkFolder:FindFirstChild(".Manifest")

	local success, err = pcall(manifestHandleLoad, Manifest)
	if not success then
		error("[Module Load Failure]: "..Manifest:GetFullName()..". Errata as follows:\n"..err)
	end
end

-- Clear _G.Rova and _G() on client in order to avoid security problems
if RS:IsClient() and CLEAR_GLOBAL_AFTER_LOAD_ON_CLIENT then
	_G.Rova = nil
	setmetatable(_G, {__call = nil})
end

return module