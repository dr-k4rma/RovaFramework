--[[
	Local Rova Initializer
	Author: Dr_K4rma aka Alexander Karpov
	Date: 4 Feb. 2021
	Provides: Local launcher script for the Rova framework
]]

----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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


----------------------------------
--		MAIN CODE
----------------------------------

require(ReplicatedStorage:WaitForChild("RovaFramework").Shared.Rova)