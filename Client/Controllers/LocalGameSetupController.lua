--[[
	@Title: Local Game Setup Controller
	@Author: Dr_K4rma aka Alexander Karpov
	@Date: 5 Feb. 2021
    @Package: ServerScriptService.RovaFramework.Client.Controllers
	@Provides: Responsible for initial setup of the game on the client. This is the first thing that should be called.
]]

_G()
local public = {}

----------------------------------
--		DEPENDENCIES
----------------------------------


----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------
local StarterGui = game:GetService("StarterGui")

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player.PlayerGui

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

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) -- Disables Playerlist
PlayerGui:SetTopbarTransparency(1)

return public