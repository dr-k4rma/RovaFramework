--[[
	@Title: PlayerSetupService
	@Author: Dr_K4rma
	@Date: 12 Apr. 2021
	@Package: ServerScriptService.RovaFramework.Server.Services
	@Provides: Service used to provide setup for the player and their character
]]--

_G()
local public = {}

----------------------------------
--		DEPENDENCIES
----------------------------------
import "EventUtils"

----------------------------------
--	SERVICES & PRIMARY OBJECTS
----------------------------------
local Players = game:GetService("Players")

local REM = EventUtils.GetRemoteEvent("PlayersREM")

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
Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local Humanoid = Character.Humanoid

		-- Delete automatic healing
		Character:WaitForChild("Health", 5):Destroy()
	end)
end)

return public