-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local Events = ReplicatedStorage:WaitForChild("Events")
local WriteNameEvent = Events:WaitForChild("WriteNameEvent")

-- Create an event to broadcast the cinematic death to all players
local PlayDeathEffectEvent = Instance.new("RemoteEvent")
PlayDeathEffectEvent.Name = "PlayDeathEffectEvent"
PlayDeathEffectEvent.Parent = Events

local function TriggerVotingPhase()
	print("SUDDEN DEATH ALERT!")
	SessionData.RoundState = "Voting"
	task.wait(4) -- Wait a little longer so people can see the death cinematic

	local meetingSpawn = workspace:FindFirstChild("MeetingSpawnLocation")
	if meetingSpawn then
		for _, player in ipairs(Players:GetPlayers()) do
			local pData = SessionData.ActivePlayers[player.UserId]
			if pData and pData.IsAlive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = meetingSpawn.CFrame
			end
		end
	end

	if _G.StartVotingPhase then
		_G.StartVotingPhase()
	end
end

WriteNameEvent.OnServerEvent:Connect(function(player, targetRealName)
	local playerData = SessionData.ActivePlayers[player.UserId]

	if playerData and playerData.Role == "Kira" then
		-- Fetch Kira's equipped Death Effect
		local persistentProfile = _G.PlayerProfiles[player.UserId]
		local equippedEffect = "HeartAttack" -- Default
		if persistentProfile and persistentProfile.Equipped and persistentProfile.Equipped.DeathEffect then
			equippedEffect = persistentProfile.Equipped.DeathEffect
		end

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

				local victimData = SessionData.ActivePlayers[victimPlayer.UserId]
				if victimData and victimData.IsAlive and victimPlayer.Character then
					victimData.IsAlive = false

					-- Broadcast the cinematic to EVERYONE in the server
					PlayDeathEffectEvent:FireAllClients(victimPlayer, equippedEffect)

					-- Wait a moment for the cinematic to play out before actually removing the body
					task.wait(1.5)
					if victimPlayer.Character and victimPlayer.Character:FindFirstChild("Humanoid") then
						victimPlayer.Character.Humanoid.Health = 0
						task.wait(0.1)
						victimPlayer.Character:Destroy() 
					end

					TriggerVotingPhase()
				end
			end)
		end
	end
end)