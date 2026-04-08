-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

-- You will need to create this RemoteEvent in ReplicatedStorage.Events
local UpdateTaskProgressEvent = Instance.new("RemoteEvent")
UpdateTaskProgressEvent.Name = "UpdateTaskProgressEvent"
UpdateTaskProgressEvent.Parent = ReplicatedStorage:WaitForChild("Events")

local TaskLocations = workspace:WaitForChild("TaskLocations"):GetDescendants()

-- Setup the physical task prompts
for _, obj in ipairs(TaskLocations) do
	if obj:IsA("ProximityPrompt") and obj.Name == "TaskPrompt" then
		obj.ActionText = "Investigate"
		obj.ObjectText = "Case Files"
		obj.HoldDuration = 3 -- Takes 3 seconds to complete a task

		obj.Triggered:Connect(function(player)
			local sessionData = SessionData.ActivePlayers[player.UserId]
			local persistentData = _G.PlayerProfiles[player.UserId]

			-- Inside the ProximityPrompt.Triggered function...
			UpdateTaskProgressEvent:FireAllClients(SessionData.TotalTasksCompleted)

			-- CHECK WIN CONDITION
			if SessionData.TotalTasksCompleted >= 20 then
				print("TASK FORCE WINS VIA TASKS!")
				SessionData.RoundState = "PostMatch"

				-- You would call your Game Manager reward function here, 
				-- or trigger a global cinematic exposing Kira!
				-- (For now, let's just create an event to end the game)
				if _G.EndGame then
					_G.EndGame("TaskForce")
				end
			end

			-- Only alive Task Force members can do tasks
			if sessionData and sessionData.Role == "TaskForce" and sessionData.IsAlive then

				-- Give them a little coin reward for actually doing their job
				if persistentData then
					persistentData.Coins += GameConfig.Rewards.TaskCompleteCoins
					persistentData.Stats.TasksCompleted += 1
				end

				-- We'll track total tasks done by the team
				if not SessionData.TotalTasksCompleted then SessionData.TotalTasksCompleted = 0 end
				SessionData.TotalTasksCompleted += 1

				print(player.Name .. " completed a task! Total: " .. SessionData.TotalTasksCompleted)

				-- Disable this specific prompt for this player (Requires a local script normally, 
				-- but for simplicity, we'll just temporarily disable it globally so people have to move around)
				obj.Enabled = false
				task.delay(15, function() obj.Enabled = true end)

				-- Tell all clients to update the top progress bar
				UpdateTaskProgressEvent:FireAllClients(SessionData.TotalTasksCompleted)
			end
		end)
	end
end