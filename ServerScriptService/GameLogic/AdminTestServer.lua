-- @ScriptType: Script
-- Location: ServerScriptService -> GameLogic -> AdminTestServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local Events = ReplicatedStorage:WaitForChild("Events")
local AdminTestEvent = Instance.new("RemoteEvent")
AdminTestEvent.Name = "AdminTestEvent"
AdminTestEvent.Parent = Events

-- Add your User ID here to ensure hackers can't use this menu!
local DEV_USER_ID = 0 -- Replace 0 with your actual Roblox User ID (or leave as 0 for Studio testing)

AdminTestEvent.OnServerEvent:Connect(function(player, command)
	-- Security Check (Uncomment in live game)
	-- if player.UserId ~= DEV_USER_ID and not game:GetService("RunService"):IsStudio() then return end

	print("[DEV PANEL] Executing: " .. command)

	if command == "ForceMeeting" then
		if _G.StartMeeting then
			_G.StartMeeting("DEV ADMIN", "Forced Test Meeting")
		end

	elseif command == "SpawnTestBody" then
		if _G.SpawnBody and player.Character then
			-- Spawns a dummy body right next to you
			_G.SpawnBody("TestDummy", player.Character)
		end

	elseif command == "SpawnIDCards" then
		if _G.DistributeIDCards then
			_G.DistributeIDCards()
		end

	elseif command == "SetRoleKira" then
		if not SessionData.ActivePlayers[player.UserId] then
			SessionData.ActivePlayers[player.UserId] = { IsAlive = true, CollectedIDs = {}, RealName = "Light Yagami" }
		end
		SessionData.ActivePlayers[player.UserId].Role = "Kira"
		print("You are now registered as KIRA.")

	elseif command == "SetRoleCiv" then
		if not SessionData.ActivePlayers[player.UserId] then
			SessionData.ActivePlayers[player.UserId] = { IsAlive = true, CollectedIDs = {}, RealName = "Soichiro" }
		end
		SessionData.ActivePlayers[player.UserId].Role = "TaskForce"
		print("You are now registered as TASK FORCE.")

	elseif command == "TriggerLockdown" then
		-- Simulate firing the Perk Manager event
		local TriggerPerkEvent = Events:FindFirstChild("TriggerPerkEvent")
		if TriggerPerkEvent then
			-- Fire it via Bindable or just call the logic if you made it global. 
			-- For now, we'll force a state that tests it.
			print("Test: Triggering Lockdown...")
			for _, door in ipairs(workspace:GetDescendants()) do
				if door.Name == "SecurityDoor" and door:IsA("BasePart") then
					door.CFrame = door.CFrame * CFrame.new(0, -10, 0) 
					door.CanCollide = true
					task.delay(5, function()
						door.CFrame = door.CFrame * CFrame.new(0, 10, 0)
						door.CanCollide = false
					end)
				end
			end
		end
	end
end)