
--[[
	How to use this config file
	
	Syntax:
		@ - If a property is a string, and it starts with this symbol, it is referencing another property in this config file by path
			Ex: cameraTracking.TRACK_IGNORE = "@gameTags.CAMERA_TRACK_IGNORE"
				
				cameraTracking.TRACK_IGNORE is referencing the value set at gameTags.CAMERA_TRACK_IGNORE, and will be set as such at runtime
]]

local GameConfig = {
	
	-- General data
	general = {
		HRP_NAME = "HumanoidRootPart",
	},
	
	-- Character data
	characterData = {
		defaultWalkSpeed = 16,	-- Character's default walk speed
		defaultJumpHeight = 4,	-- Character's default jump height
	},
	
	remotes = {
		
	},
	
	-- Various game tags
	gameTags = {
		RAYCAST_IGNORE = "RaycastIgnore",
	},
	
	-- Open Source Credits
	openSourceCredits = {
		[1631699] 	= {"devSparkle", "Overture Libraries"},
	},
}

-- Handles setting property values based off of syntax
local function getProperty(propertyPath)
	local args = string.split(propertyPath, ".")
	local dir = GameConfig
	for _, prop in pairs(args) do
		dir = dir[prop]
	end
	return dir
end

local handleValueSyntax
handleValueSyntax = function(currentTable)
	-- Iterate through currentTable
	for index, element in pairs(currentTable) do
		-- If it's a table, call recursive function on it
		if typeof(element) == "table" then
			handleValueSyntax(element)
			-- If it's a string, check if it's a property pointer (@)
		elseif typeof(element) == "string" then
			if string.sub(element, 1, 1) == "@" then
				local path = string.sub(element, 2, string.len(element))
				currentTable[index] = getProperty(path)
			end
		end
	end
end

handleValueSyntax(GameConfig)

return GameConfig