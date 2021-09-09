--[[
	@Title: PlayerController
	@Author: Dr_K4rma
	@Date: 12 Apr. 2021
	@Package: ServerScriptService.RovaFramework.Client.Controllers
	@Provides: Controller that manages localside player setup and controls
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
local REM = EventUtils.GetRemoteEvent("PlayersREM")

local LocalPlayer = game:GetService("Players").LocalPlayer

----------------------------------
--		CONFIG VARIABLES
----------------------------------


----------------------------------
--		MISC VARIABLES
----------------------------------


----------------------------------
--		PRIVATE FUNCTIONS
----------------------------------
local function onCharacterAdded(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

	Humanoid.Died:Connect(function()
		-- Stuff that happens when humanoid dies
	end)
end

----------------------------------
--		PUBLIC FUNCTIONS
----------------------------------


----------------------------------
--		MAIN CODE
----------------------------------

-- Handles character setup (and whatnot)
onCharacterAdded(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Handles instructions being sent from the server
REM.OnClientEvent:Connect(function(action, ...)
	local args = {...}
	-- Do stuff here
end)

return public