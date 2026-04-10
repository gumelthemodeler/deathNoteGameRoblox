-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SessionData = require(ServerScriptService.DataSystems.SessionData)

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateTimer = Events:WaitForChild("UpdateTimer")

-- Create custom events for meetings if they don't exist
local function GetOrCreateEvent(name)
	local ev = Events:FindFirstChild(name)
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = Events
	end
	return ev
end

local ShowPlayerVoting = GetOrCreateEvent("ShowPlayerVoting")
local SubmitPlayerVote = GetOrCreateEvent("SubmitPlayerVote")

-- Voting State
local isMeetingActive = false
local currentVotes = {}
local alivePlayersDuringMeeting = 0

-- ==========================================
-- 1. BODY REPORTING SYSTEM
-- ==========================================
-- This function should be called by your DeathNoteExecution script right after a player dies
_G.SpawnBody = function(victimName, deadCharacter)
	if not deadCharacter or not deadCharacter:FindFirstChild("HumanoidRootPart") then return end

	-- Create a chalk outline or physical body part
	local bodyPart = Instance.new("Part")
	bodyPart.Size = Vector3.new(4, 0.5, 4)
	bodyPart.Position = deadCharacter.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
	bodyPart.Anchored = true
	bodyPart.CanCollide = false
	bodyPart.Color = Color3.fromRGB(150, 0, 0) -- Blood pool or chalk outline
	bodyPart.Name = "DeadBody_" .. victimName
	bodyPart.Parent = workspace

	-- Add the Proximity Prompt to Report it
	local reportPrompt = Instance.new("ProximityPrompt")
	reportPrompt.ActionText = "Report Body"
	reportPrompt.ObjectText = victimName
	reportPrompt.HoldDuration = 0.5
	reportPrompt.KeyboardKeyCode = Enum.KeyCode.R
	reportPrompt.Parent = bodyPart

	reportPrompt.Triggered:Connect(function(player)
		local pData = SessionData.ActivePlayers[player.UserId]
		if pData and pData.IsAlive and not isMeetingActive then
			_G.StartMeeting(player.Name, victimName)
		end
	end)
end

-- ==========================================
-- 2. EMERGENCY BUTTON LOGIC
-- ==========================================
-- If you put a part named "EmergencyButton" in the workspace with a prompt inside it, this hooks it up!
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj.Name == "EmergencyButtonPrompt" and obj:IsA("ProximityPrompt") then
		obj.Triggered:Connect(function(player)
			local pData = SessionData.ActivePlayers[player.UserId]
			if pData and pData.IsAlive and not isMeetingActive then
				-- We can add a check here later to limit 1 button press per player
				_G.StartMeeting(player.Name, "Emergency Button")
			end
		end)
	end
end

-- ==========================================
-- 3. THE MEETING LOOP
-- ==========================================
_G.StartMeeting = function(callerName, reason)
	if isMeetingActive or SessionData.RoundState ~= "Playing" then return end
	isMeetingActive = true
	currentVotes = {}
	alivePlayersDuringMeeting = 0

	print("🚨 EMERGENCY MEETING CALLED BY " .. callerName .. " 🚨")

	-- 1. Teleport all alive players to the Meeting Room
	local meetingSpawns = workspace:FindFirstChild("MeetingSpawns")
	local spawnPoints = meetingSpawns and meetingSpawns:GetChildren() or {}
	local spawnIndex = 1

	for userId, data in pairs(SessionData.ActivePlayers) do
		if data.IsAlive then
			alivePlayersDuringMeeting += 1
			local plr = Players:GetPlayerByUserId(userId)
			if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				-- Freeze them
				plr.Character.HumanoidRootPart.Anchored = true

				-- Teleport them to seats if they exist
				if #spawnPoints > 0 then
					plr.Character.HumanoidRootPart.CFrame = spawnPoints[spawnIndex].CFrame + Vector3.new(0, 3, 0)
					spawnIndex = (spawnIndex % #spawnPoints) + 1
				end
			end
		end
	end

	-- Destroy all bodies on the map so they don't get reported again
	for _, obj in ipairs(workspace:GetChildren()) do
		if string.match(obj.Name, "DeadBody_") then
			obj:Destroy()
		end
	end

	-- 2. Broadcast to UI
	local meetingMessage = callerName .. " found " .. reason
	if reason == "Emergency Button" then
		meetingMessage = callerName .. " called an Emergency Meeting!"
	end

	UpdateTimer:FireAllClients("MEETING IN PROGRESS", "--:--")
	ShowPlayerVoting:FireAllClients(true, meetingMessage, SessionData.ActivePlayers)

	-- 3. Wait for Voting Phase (e.g., 60 seconds to argue and vote)
	task.spawn(function()
		for i = 60, 0, -1 do
			-- Check if everyone has voted early
			local votesCast = 0
			for _, _ in pairs(currentVotes) do votesCast += 1 end
			if votesCast >= alivePlayersDuringMeeting then break end

			task.wait(1)
		end

		_G.EndMeeting()
	end)
end

-- ==========================================
-- 4. TALLY VOTES & EXECUTE
-- ==========================================
SubmitPlayerVote.OnServerEvent:Connect(function(player, votedTargetUserId)
	local pData = SessionData.ActivePlayers[player.UserId]
	if isMeetingActive and pData and pData.IsAlive then
		-- Register vote (can be a target UserId, or "Skip")
		currentVotes[player.UserId] = votedTargetUserId
	end
end)

_G.EndMeeting = function()
	isMeetingActive = false
	ShowPlayerVoting:FireAllClients(false, "", {})

	-- Tally the votes
	local voteCounts = {}
	local maxVotes = 0
	local tied = false
	local executedUserId = nil

	for _, votedId in pairs(currentVotes) do
		voteCounts[votedId] = (voteCounts[votedId] or 0) + 1
		if voteCounts[votedId] > maxVotes then
			maxVotes = voteCounts[votedId]
			executedUserId = votedId
			tied = false
		elseif voteCounts[votedId] == maxVotes then
			tied = true
		end
	end

	-- Unfreeze everyone
	for userId, data in pairs(SessionData.ActivePlayers) do
		local plr = Players:GetPlayerByUserId(userId)
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			plr.Character.HumanoidRootPart.Anchored = false
		end
	end

	-- Process Execution
	if executedUserId and executedUserId ~= "Skip" and not tied then
		local targetData = SessionData.ActivePlayers[executedUserId]
		local targetPlayer = Players:GetPlayerByUserId(executedUserId)

		if targetData and targetData.IsAlive then
			print(targetPlayer.Name .. " was voted out by the group!")
			targetData.IsAlive = false
			if targetPlayer and targetPlayer.Character then
				targetPlayer.Character:BreakJoints() -- Execute them
			end

			-- Check if the game should end because of this vote
			local winner = SessionData.CheckWinCondition()
			if winner then
				_G.EndGame(winner)
			end
		end
	else
		print("Voting ended in a tie or skip. No one was executed.")
	end
end