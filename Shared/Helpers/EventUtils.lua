--[[
	Event Utilities
	Author: Dr_K4rma aka Alexander Karpov
	Date: 5 Feb. 2021
	Provides: Utilities for retrieving and interfacing with Remotes and Bindables
]]

_G()
local public = {}

----------------------------------
--		DEPENDENCIES
----------------------------------
import "GUtils"

----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RS = game:GetService("RunService")

----------------------------------
--		CONFIG VARIABLES
----------------------------------
local BINDABLE_DIRECTORY_NAME = "RovaBindableStorage"
local REMOTE_DIRECTORY_NAME = "RovaRemoteStorage"

local EVENT_TYPES = {
	Remote = {
		"RemoteEvent",
		"RemoteFunction",
	},
	Bindable = {
		"BindableEvent",
		"BindableFunction",
	},
}

----------------------------------
--		MISC VARIABLES
----------------------------------
local BindableDirectory = RS:IsClient() and ReplicatedStorage or ServerStorage
local RemoteDirectory = ReplicatedStorage

----------------------------------
--		MAIN CODE
----------------------------------

-- Initialize directories for storing the events
BindableDirectory = GUtils.Retrieve(BINDABLE_DIRECTORY_NAME, "Folder", BindableDirectory)
RemoteDirectory = GUtils.Retrieve(REMOTE_DIRECTORY_NAME, "Folder", RemoteDirectory, RS:IsClient())

-- Create the public functions for this class
for categoryName, eventTypes in pairs(EVENT_TYPES) do
	local StorageDirectory
	if categoryName == "Remote" then
		StorageDirectory = RemoteDirectory
	elseif categoryName == "Bindable" then
		StorageDirectory = BindableDirectory
	end
	
	for _, eventType in pairs(eventTypes) do
		public["Get"..eventType] = function(name)
			--print("Get"..eventType, debug.traceback())
			local Event = GUtils.Retrieve(name, eventType, StorageDirectory, RS:IsClient())
			--print(Event:GetFullName())
			return Event
		end
	end
end

return public