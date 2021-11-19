--[[
	@Title: Rova Framework
	@Author: Dr_K4rma
	@Date: 1 Feb. 2021, updated 18 Nov. 2021
	@Package: ServerScriptService.RovaFramework.Shared
	@Provides: Rova Framework Driver
]]--

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

-- Behavior Variables
local USE_INJECTED_METHODS = true					-- Whether or not to allow Rova to inject methods into the function environment of the scripts where it is initialized.
local CLEAR_GLOBAL_AFTER_LOAD_ON_CLIENT = true		-- Whether _G as callable function is cleared after modules are all loaded. Setting this to false presents security rist for client-side.
local CLIENT_DELETE_MODULE_AFTER_CACHE = true 		-- Whether or not ModuleScripts initialized on the client are deleted after they are cached in the framework.
local MODULE_LOAD_TIMEOUT = 0.5						-- How long Rova will wait for a module to load before it moved onto loading the next module. Set to math.huge for indefinite yield.

-- Debug variables
local PRINT_MANIFEST_LOAD_ORDER = false		-- Will print the full name of the manifest upon first load
local PRINT_DIRECTORY_MOVE_CHANGE = false		-- Will print where directories are being moved
local PRINT_LOAD_ORDER = false					-- Will print the name of the module being loaded upon first load

----------------------------------
--		MISC VARIABLES
----------------------------------
local frameworkFolders = {}
local packages = {}
local default = {}

local ServerIgnoreClientDirectories = {
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer")
}

----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------
local function rovaPrint(f_message, f_prefix)
	f_prefix = f_prefix or ""
	if RS:IsServer() then
		print(f_prefix.."[S_Rova]: "..f_message)
	else
		print(f_prefix, "[C_Rova]:"..f_message)
	end
end

local function rovaWarn(f_message, f_prefix)
	f_prefix = f_prefix or ""
	if RS:IsServer() then
		warn(f_prefix.."[S_Rova]: "..f_message)
	else
		warn(f_prefix, "[C_Rova]:"..f_message)
	end
end

local function rovaError(f_message, f_prefix)
	f_prefix = f_prefix or ""
	if RS:IsServer() then
		error(f_prefix.."[S_Rova]: "..f_message)
	else
		error(f_prefix.."[C_Rova]:"..f_message)
	end
end

local function errorNoBreak(f_err, f_prefix)
	spawn(function()
		rovaError(f_err, f_prefix)
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

local function loadModule(f_Module)
	local moduleHandle
	local ModuleObject
	
	if typeof(f_Module) == "string" then
		moduleHandle = f_Module
	elseif typeof(f_Module) == "Instance" then
		moduleHandle = f_Module.Name
	end
	
	if PRINT_LOAD_ORDER then
		rovaPrint("Loading module "..moduleHandle.."...")
	end
	
	f_Module = packages[moduleHandle]
	if typeof(f_Module) == "Instance" then
		ModuleObject = f_Module
		local success, err = pcall(function()
			local ModuleObject = f_Module
			
			local loaded = false
			coroutine.wrap(function()
				f_Module = require(f_Module)
				loaded = true
			end)()
			for i = 0, MODULE_LOAD_TIMEOUT, 0.05 do
				if loaded then break end
				wait(0.05)
			end
			if not loaded then
				error("\tModule load timed out.")
			end
		end)
		if not success then
			packages[moduleHandle] = nil
			error(err)
		end
		
		if RS:IsClient() and CLIENT_DELETE_MODULE_AFTER_CACHE and ModuleObject then
			ModuleObject:Destroy()
		end
		
		-- Module loaded.
		if PRINT_LOAD_ORDER then
			rovaPrint("Success loading "..moduleHandle..".", "\t")
		end
		packages[moduleHandle] = f_Module
		return f_Module
	elseif typeof(f_Module) == "table" then
		return f_Module
	end
end

local function importInjectHandler(f_moduleName)
	local fenv = getfenv(0)
	
	fenv[f_moduleName] = loadModule(f_moduleName)
end

local function initHandler()
	if USE_INJECTED_METHODS then
		local fenv = getfenv(0)

		-- Injecting new methods
		fenv.import = importInjectHandler
	end
end

local function manifestHandleInit(f_frameworkTable)
	if PRINT_MANIFEST_LOAD_ORDER then
		rovaPrint("Loading manifest "..f_frameworkTable.Manifest:GetFullName())
	end
	local success, err = pcall(function()
		f_frameworkTable.Manifest = require(f_frameworkTable.Manifest)
	end)
	if not success then
		error(err)
	end
	if PRINT_MANIFEST_LOAD_ORDER then
		rovaPrint("Manifest Load Success.", "\t")
	end
end

local function manifestHandleMove(f_frameworkTable)
	local manifest = f_frameworkTable.Manifest
	
	-- If on the server, move folders to proper location
	if RS:IsServer() then
		if manifest.__location then
			local newFrameworkLocation = retrieve("RovaFramework", "Folder", manifest.__location)
			CS:AddTag(f_frameworkTable.Instance, FRAMEWORK_TAG_NAME)
			f_frameworkTable.Instance.Parent = newFrameworkLocation
			if PRINT_DIRECTORY_MOVE_CHANGE then
				rovaPrint("Moved "..f_frameworkTable.Instance:GetFullName().." -> "..newFrameworkLocation:GetFullName())
			end
		end
	end
end

local function manifestHandleLoad(f_frameworkTable)
	local manifest = f_frameworkTable.Manifest
	
	-- Implementation of ignore function based on tag in manifest
	if manifest.__tags then
		if RS:IsClient() then
			if isInTable("ClientIgnore", manifest.__tags) then return end
		else
			if isInTable("ServerIgnore", manifest.__tags) then return end
		end
	end
	
	for index, path in pairs(manifest) do
		if string.sub(index, 1, 2) == "__" then continue end	-- Ignore index paths beginning with '__'
		
		local splitPath = string.split(path, ".")
		local superFolder = splitPath[1]
		local Module = frameworkFolders[superFolder].Instance

		for i, directory in pairs(splitPath) do
			if i == 1 then continue end	-- Solves the edge case of where the first item in the list is normally a frameworkTable 
			
			Module = Module:FindFirstChild(directory)
			
			if not Module then
				break	-- Failed to find the object by path
			end
		end
		
		if not Module then	-- Failed to find object by path. Assume already loaded in.
			return
		end
		
		-- Begin loading module
		local success, err = pcall(loadModule, Module)
		if not success then
			errorNoBreak("Failed to load module\n\t"..path.."\nErrata as follows:\n"..err)
		end
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
function module.Import(f_name)
	return loadModule(f_name)
end

--[[
	Implementation for legacy calling of the modules
]]
function module:LoadLibrary(f_name)
	return module.Import(f_name)
end

----------------------------------
--		MAIN CODE
----------------------------------

-- Catalogin framework folders
if RS:IsClient() then
	for _, Folder in pairs(CS:GetTagged(FRAMEWORK_TAG_NAME)) do
		local folderTable = {}
		folderTable.Instance = Folder
		folderTable.Manifest = Folder:FindFirstChild(".Manifest")
		frameworkFolders[Folder.Name] = folderTable
	end
else
	for _, Folder in pairs(ServerScriptService.RovaFramework:GetChildren()) do
		if Folder:IsA("Folder") then
			local folderTable = {}
			folderTable.Instance = Folder
			folderTable.Manifest = Folder:FindFirstChild(".Manifest")
			frameworkFolders[Folder.Name] = folderTable
		end
	end
end

-- Caching modules
for _, FrameworkFolder in pairs(frameworkFolders) do
	for _, Module in pairs(FrameworkFolder.Instance:GetDescendants()) do
		if not Module:IsA("ModuleScript") then continue end		-- skip if the module isnt actually a module
		if string.sub(Module.Name, 1, 1) == "." then continue end	-- skip if the module is preceded by a period '.'
		packages[Module.Name] = Module
	end
end

-- Storing reference to rova in _G
_G.Rova = module

-- Initializing _G as a callable table (if applicable)
if USE_INJECTED_METHODS then
	setmetatable(_G, {__call = initHandler})
end

-- Handle initialization of manifest file
for _, frameworkTable in pairs(frameworkFolders) do
	local Manifest = frameworkTable.Manifest
	
	if not Manifest then	-- Manifest not found. Error, but does not interrupt the framework.
		errorNoBreak(frameworkTable.Instance.Name.." is missing a manifest file.\n\t"..frameworkTable.Instance:GetFullName())
	end
	
	-- Manifest found. Attempting to load.
	local success, err = pcall(manifestHandleInit, frameworkTable)
	if not success then		-- Failed to load. Print location of manifest and what went wrong.
		rovaError("Manifest Initialization Failure.\nManifest failed to load at:\n\t"..Manifest:GetFullName().."\nPlease verify integrity.\nErrata as follows:\n"..err)
	end
end

-- All found manifests verified. Proceed with moving framework directories.

-- Handle the movement of the framework folders
for _, frameworkTable in pairs(frameworkFolders) do
	local manifest = frameworkTable.Manifest
	
	local success, err = pcall(manifestHandleMove, frameworkTable)
	if not success then		-- Failed to load framework folders to designated location. Print location of manifest and what went wrong.
		rovaError("Directory Move Failure.\nManifest failed to move target directory to designated location:\n\t"..frameworkTable.Instance:GetFullName().."..Manifest\nErrata as follows:\n"..err)
	end
end

-- All framework directories moved. Proceed with loading modules.

-- Handle loading of modules defined in the manifest file
for _, frameworkTable in pairs(frameworkFolders) do
	local Manifest = frameworkTable.Manifest
	
	local success, err = pcall(manifestHandleLoad, frameworkTable)
	if not success then
		rovaError("Module Load Failure.\nManifest failed to load:\n\t"..frameworkTable.Instance:GetFullName().."..Manifest\nErrata as follows:\n"..err)
	end
end

-- Clear _G.Rova and _G() on client if specified
if RS:IsClient() and CLEAR_GLOBAL_AFTER_LOAD_ON_CLIENT then
	_G.Rova = nil
	setmetatable(_G, {__call = nil})
end

rovaWarn("Framework Loaded.")

return module