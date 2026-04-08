-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

-- Change line 6 to this:
local WriteNameEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WriteNameEvent")

local function TriggerVotingPhase()
	print("SUDDEN DEATH ALERT!")
	SessionData.RoundState = "Voting"
	task.wait(3) 

	local meetingSpawn = workspace:FindFirstChild("MeetingSpawnLocation")
	for _, player in ipairs(Players:GetPlayers()) do
		local pData = SessionData.ActivePlayers[player.UserId]
		if pData and pData.IsAlive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = meetingSpawn.CFrame
		end
	end

	if _G.StartVotingPhase then
		_G.StartVotingPhase()
	end
end

WriteNameEvent.OnServerEvent:Connect(function(player, targetRealName)
	local playerData = SessionData.ActivePlayers[player.UserId]

	if playerData and playerData.Role == "Kira" then
		local victimPlayer = nil
		for userId, pData in pairs(SessionData.ActivePlayers) do
			if pData.RealName == targetRealName and pData.IsAlive then
				victimPlayer = Players:GetPlayerByUserId(userId)
				break
			end
		end

		if victimPlayer then
			task.spawn(function()
				print("40 second timer started for " .. victimPlayer.Name)
				task.wait(40)

				-- Check if victim is still alive (didn't leave or get arrested)
				local victimData = SessionData.ActivePlayers[victimPlayer.UserId]
				if victimData and victimData.IsAlive and victimPlayer.Character then
					victimData.IsAlive = false
					victimPlayer.Character.Humanoid.Health = 0

					task.wait(0.1)
					victimPlayer.Character:Destroy() 

					TriggerVotingPhase()
				end
			end)
		end
	end
end)