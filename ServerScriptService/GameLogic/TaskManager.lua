-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local UpdateTaskProgressEvent = EventsFolder:FindFirstChild("UpdateTaskProgressEvent")
if not UpdateTaskProgressEvent then
	UpdateTaskProgressEvent = Instance.new("RemoteEvent")
	UpdateTaskProgressEvent.Name = "UpdateTaskProgressEvent"
	UpdateTaskProgressEvent.Parent = EventsFolder
end

local TaskLocations = workspace:WaitForChild("TaskLocations"):GetDescendants()

for _, obj in ipairs(TaskLocations) do
	if obj:IsA("ProximityPrompt") and obj.Name == "TaskPrompt" then
		obj.ActionText = "Investigate"
		obj.ObjectText = "Case Files"
		obj.HoldDuration = 3 -- Takes 3 seconds to complete (or fake) a task

		obj.Triggered:Connect(function(player)
			local sessionData = SessionData.ActivePlayers[player.UserId]
			local persistentData = _G.PlayerProfiles and _G.PlayerProfiles[player.UserId]

			if not sessionData or not sessionData.IsAlive then return end

			if sessionData.Role == "TaskForce" then
				-- REAL TASK: Increase score and pay the player
				if not SessionData.TotalTasksCompleted then SessionData.TotalTasksCompleted = 0 end
				SessionData.TotalTasksCompleted += 1

				if persistentData then
					persistentData.Coins += GameConfig.Rewards.TaskCompleteCoins
					persistentData.Stats.TasksCompleted += 1
				end

				UpdateTaskProgressEvent:FireAllClients(SessionData.TotalTasksCompleted)

				if SessionData.TotalTasksCompleted >= GameConfig.TotalTasksRequired then
					if _G.EndGame then _G.EndGame("TaskForce") end
				end

			elseif sessionData.Role == "Kira" then
				-- FAKE TASK: Do absolutely nothing to the score, but make it look like they did it
				print(player.Name .. " (Kira) successfully faked a task.")
			end

			-- Disable the prompt for EVERYONE so Kira can't spam the same spot to look busy
			obj.Enabled = false
			task.delay(15, function() obj.Enabled = true end)
		end)
	end
end