-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local Events = ReplicatedStorage:WaitForChild("Events")
local WriteNameEvent = Events:WaitForChild("WriteNameEvent")

local PlayDeathEffectEvent = Events:FindFirstChild("PlayDeathEffectEvent")
if not PlayDeathEffectEvent then
	PlayDeathEffectEvent = Instance.new("RemoteEvent")
	PlayDeathEffectEvent.Name = "PlayDeathEffectEvent"
	PlayDeathEffectEvent.Parent = Events
end

WriteNameEvent.OnServerEvent:Connect(function(player, targetRealName)
	local playerData = SessionData.ActivePlayers[player.UserId]

	-- Check if Kira has already killed this cycle!
	if SessionData.HasKilledThisCycle then 
		print("[SERVER] Kira cannot kill again until the next cycle.")
		return 
	end

	if playerData and playerData.Role == "Kira" then
		-- Lock the notebook for this cycle
		SessionData.HasKilledThisCycle = true

		local persistentProfile = _G.PlayerProfiles and _G.PlayerProfiles[player.UserId]
		local equippedEffect = "HeartAttack" 
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
				print("[SERVER] Kira wrote a name! 40 second timer started.")
				task.wait(40)

				local victimData = SessionData.ActivePlayers[victimPlayer.UserId]
				if victimData and victimData.IsAlive and victimPlayer.Character then
					victimData.IsAlive = false

					-- Broadcast the cinematic to EVERYONE
					PlayDeathEffectEvent:FireAllClients(victimPlayer, equippedEffect)
					task.wait(2) -- Wait for the cinematic to finish

					if victimPlayer.Character and victimPlayer.Character:FindFirstChild("Humanoid") then
						victimPlayer.Character.Humanoid.Health = 0
						task.wait(0.1)
						victimPlayer.Character:Destroy() 
					end

					-- Check if Kira just won the game before calling the meeting
					local winner = SessionData.CheckWinCondition()
					if winner and _G.EndGame then
						_G.EndGame(winner)
						return
					end

					-- 🔥 AUTOMATICALLY START THE MEETING INTERSECTION
					if _G.StartMeeting then
						_G.StartMeeting("SYSTEM", "A Heart Attack has occurred...")
					end
				end
			end)
		end
	end
end)