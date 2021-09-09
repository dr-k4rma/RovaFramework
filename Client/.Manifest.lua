return {
	__location = game:GetService("ReplicatedStorage"),
	__tags = {"ServerIgnore"},
	"Client.Controllers.LocalGameSetupController", -- Responsible for initial setup of the game on the client. This is the first thing that should be called.
	"Client.Controllers.PlayerController", -- Controller that manages localside player setup and controls
}