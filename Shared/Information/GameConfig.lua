
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
	
	-- Which SCPs are enabled
	enabledSCPs = {	-- SCP classes are defined in SCPService
		["2123"] = true,	-- Particle Accelerator
	},
	
	-- Character data
	characterData = {
		defaultWalkSpeed = 16,	-- Character's default walk speed
		defaultJumpHeight = 4,	-- Character's default jump height
	},
	
	-- Data regarding PDAKeyslots
	pdaKeyslot = {
		ACTIVATION_DISTANCE = 8,
	},
	
	-- Data regarding camera tracking
	cameraTracking = {
		UPDATE_INTERVAL = 1,	-- Interval at which each player reports camera CFrame
		CHECK_INTERVAL = 5,		-- Interval at which server checks if players have sent any updates recently
		TRACK_IGNORE = "@gameTags.CAMERA_TRACK_IGNORE",	-- Tag applied to player's character when camera tracking offset can be ignored
	},
	
	remotes = {
		UI_BUTTON_CLASS = "UIButtonClassREM",
		REALISM_SET_LOOK_ANGLES = "ReplicatedRealismREM",
	},
	
	-- Various game tags
	gameTags = {
		RAYCAST_IGNORE = "RaycastIgnore",
		CAMERA_TRACK_IGNORE = "CameraTrackIgnore",
		CARD_READER = "CardReader",
		RAGDOLL = "Ragdoll",
		NODE_GRAPH = "NodeGraph",
		VISUALIZE = "Visualize",
		SCP = "SCP",
		PDA_KEYSLOT = "PDA_Keyslot",
		HOVER_INFO = "HoverInfo",
		UI_BUTTON = "UIButtonClassObject"
	},
	
	-- Open Source Credits
	openSourceCredits = {
		[33655127] 	= {"boatbomber", "3D Sound System "},
		[1631699] 	= {"devSparkle", "Overture Libraries"},
		[2032622]	= {"CloneTrooper1019", "Character Realism Module"},
		[1930588726] = {"Orodex", "Vector Utils"},
	},
	
	-- Config for realism module
	realismConfig = {
		-----------------------------------
		-- A dictionary mapping materials
		-- to walking sound ids.
		-----------------------------------

		Sounds =
			{
				Dirt     = 178054124;
				Wood     = 177940988;
				Concrete = 277067660;
				Grass    = 4776173570;
				Metal    = 4790537991;
				Sand     = 4777003964;
				Fabric   = 4776951843;
				Gravel   = 4776998555;
				Marble   = 4776962643;
			};

		---------------------------------------
		-- A dictionary mapping materials to 
		-- names in the 'Sounds' table, for
		-- any materials that don't have a
		-- specific sound id.
		---------------------------------------

		MaterialMap = 
			{
				Mud    = "Dirt";
				Pebble = "Dirt";
				Ground = "Dirt";

				Sand      = "Sand";
				Snow      = "Sand";
				Sandstone = "Sand";

				Rock    = "Gravel";
				Basalt  = "Gravel";
				Asphalt = "Gravel";
				Glacier = "Gravel";
				Slate   = "Gravel";

				WoodPlanks = "Wood";
				LeafyGrass = "Grass";

				Ice       = "Marble";
				Salt      = "Marble";
				Marble    = "Marble";
				Pavement  = "Marble";
				Limestone = "Marble";

				Foil          = "Metal";
				DiamondPlate  = "Metal";
				CorrodedMetal = "Metal";
			};

		---------------------------------------------
		-- Multiplier values (in radians) for each
		-- joint, based on the pitch/yaw look angles
		---------------------------------------------

		RotationFactors =
			{
				-------------------------------
				-- Shared
				-------------------------------

				Head = 
				{
					Pitch = 0.8;
					Yaw = 0.75;
				};

				-------------------------------
				-- R15
				-------------------------------

				UpperTorso = 
				{
					Pitch =  0.5;
					Yaw   =  0.5;
				};

				LeftUpperArm = 
				{
					Pitch =  0.0;
					Yaw   = -0.5;
				};

				RightUpperArm =
				{
					Pitch =  0.0;
					Yaw   = -0.5;
				};

				-------------------------------
				-- R6
				-------------------------------

				Torso =
				{
					Pitch =  0.4;
					Yaw   =  0.2;
				};

				["Left Arm"] =
				{
					Pitch =  0.0;
					Yaw   = -0.5;
				};

				["Right Arm"] =
				{
					Pitch =  0.0;
					Yaw   = -0.5;
				};

				["Left Leg"] =
				{
					Pitch =  0.0;
					Yaw   = -0.2;
				};

				["Right Leg"] =
				{
					Pitch =  0.0;
					Yaw   = -0.2;
				};
			};
	}
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