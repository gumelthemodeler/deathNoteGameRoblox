-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local SabotageGui = PlayerGui:WaitForChild("SabotageGui")
local RedFlash = SabotageGui:WaitForChild("RedFlash")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local SabotageEffectEvent = EventsFolder:WaitForChild("SabotageEffectEvent")

SabotageEffectEvent.OnClientEvent:Connect(function(effectType)
	if effectType == "FakeHeartAttack" then

		-- Flash the screen red and make the character stumble (walkspeed slow)
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = 4 -- Force them to a crawl
		end

		-- Tween the red flash in and out to simulate a heartbeat
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local heartBeatTween = TweenService:Create(RedFlash, tweenInfo, {BackgroundTransparency = 0.5})

		heartBeatTween:Play()

		-- End the panic attack after 10 seconds
		task.delay(10, function()
			heartBeatTween:Cancel()
			RedFlash.BackgroundTransparency = 1
			if humanoid then
				humanoid.WalkSpeed = 16 -- Reset to normal speed
			end
		end)
	end
end)