-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

-- Find or create the RemoteEvent safely
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local UpdateTaskProgressEvent = EventsFolder:FindFirstChild("UpdateTaskProgressEvent")
if not UpdateTaskProgressEvent then
	UpdateTaskProgressEvent = Instance.new("RemoteEvent")
	UpdateTaskProgressEvent.Name = "UpdateTaskProgressEvent"
	UpdateTaskProgressEvent.Parent = EventsFolder
end

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

			-- 1. Only alive Task Force members can do tasks
			if sessionData and sessionData.Role == "TaskForce" and sessionData.IsAlive then

				-- 2. Initialize the score if it doesn't exist yet
				if not SessionData.TotalTasksCompleted then 
					SessionData.TotalTasksCompleted = 0 
				end

				-- 3. Increase the score
				SessionData.TotalTasksCompleted += 1
				print(player.Name .. " completed a task! Total: " .. SessionData.TotalTasksCompleted)

				-- 4. Give the player coins
				if persistentData then
					persistentData.Coins += GameConfig.Rewards.TaskCompleteCoins
					persistentData.Stats.TasksCompleted += 1
				end

				-- 5. Update the UI for all players
				UpdateTaskProgressEvent:FireAllClients(SessionData.TotalTasksCompleted)

				-- 6. Check Win Condition
				if SessionData.TotalTasksCompleted >= GameConfig.TotalTasksRequired then
					print("TASK FORCE WINS VIA TASKS!")
					if _G.EndGame then
						_G.EndGame("TaskForce")
					end
				end

				-- 7. Disable this specific prompt temporarily so they have to move around
				obj.Enabled = false
				task.delay(15, function() obj.Enabled = true end)
			else
				-- If Kira tries to do a task, nothing happens, but we can print for debugging
				print(player.Name .. " cannot do tasks (Role: " .. (sessionData and sessionData.Role or "None") .. ")")
			end
		end)
	end
end