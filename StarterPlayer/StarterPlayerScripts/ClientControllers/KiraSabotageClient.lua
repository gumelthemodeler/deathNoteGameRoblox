-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local TriggerSabotageEvent = EventsFolder:WaitForChild("TriggerSabotageEvent")

-- Cooldown tracking on the client so we don't spam the server
local onCooldown = {
	Blackout = false,
	FakeHeartAttack = false
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- Press 1 for Blackout
	if input.KeyCode == Enum.KeyCode.One and not onCooldown.Blackout then
		TriggerSabotageEvent:FireServer("Blackout")
		onCooldown.Blackout = true

		-- Visual UI feedback could go here
		task.delay(45, function() onCooldown.Blackout = false end)
	end

	-- Press 2 for Fake Heart Attack
	if input.KeyCode == Enum.KeyCode.Two and not onCooldown.FakeHeartAttack then
		TriggerSabotageEvent:FireServer("FakeHeartAttack")
		onCooldown.FakeHeartAttack = true

		-- Visual UI feedback could go here
		task.delay(60, function() onCooldown.FakeHeartAttack = false end)
	end
end)