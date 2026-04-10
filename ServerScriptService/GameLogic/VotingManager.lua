-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateTimer = Events:WaitForChild("UpdateTimer")

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

local isMeetingActive = false
local currentVotes = {}
local alivePlayersDuringMeeting = 0

-- ==========================================
-- THE MEETING LOOP
-- ==========================================
_G.StartMeeting = function(callerName, reason)
	if isMeetingActive or SessionData.RoundState ~= "Playing" then return end
	isMeetingActive = true
	currentVotes = {}
	alivePlayersDuringMeeting = 0

	print("🚨 INTERSECTION TRIGGERED: " .. reason .. " 🚨")

	-- 1. Teleport all alive players to the Meeting Room
	local meetingSpawns = workspace:FindFirstChild("MeetingSpawns")
	local spawnPoints = meetingSpawns and meetingSpawns:GetChildren() or {}
	local spawnIndex = 1

	for userId, data in pairs(SessionData.ActivePlayers) do
		if data.IsAlive then
			alivePlayersDuringMeeting += 1
			local plr = Players:GetPlayerByUserId(userId)
			if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				plr.Character.HumanoidRootPart.Anchored = true -- Freeze them

				if #spawnPoints > 0 then
					plr.Character.HumanoidRootPart.CFrame = spawnPoints[spawnIndex].CFrame + Vector3.new(0, 3, 0)
					spawnIndex = (spawnIndex % #spawnPoints) + 1
				end
			end
		end
	end

	-- 2. Broadcast to UI
	UpdateTimer:FireAllClients("MEETING IN PROGRESS", "--:--")
	ShowPlayerVoting:FireAllClients(true, reason, SessionData.ActivePlayers)

	-- 3. Wait for Voting Phase (90 seconds to argue and vote)
	task.spawn(function()
		for i = 90, 0, -1 do
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
-- TALLY VOTES & RESTART CYCLE
-- ==========================================
SubmitPlayerVote.OnServerEvent:Connect(function(player, votedTargetUserId)
	local pData = SessionData.ActivePlayers[player.UserId]
	if isMeetingActive and pData and pData.IsAlive then
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
		if votedId ~= "Skip" then
			voteCounts[votedId] = (voteCounts[votedId] or 0) + 1
			if voteCounts[votedId] > maxVotes then
				maxVotes = voteCounts[votedId]
				executedUserId = votedId
				tied = false
			elseif voteCounts[votedId] == maxVotes then
				tied = true
			end
		end
	end

	-- Process Execution
	if executedUserId and not tied then
		local targetData = SessionData.ActivePlayers[executedUserId]
		local targetPlayer = Players:GetPlayerByUserId(executedUserId)

		if targetData and targetData.IsAlive then
			print("[SERVER] " .. targetPlayer.Name .. " was voted out and arrested!")
			targetData.IsAlive = false
			if targetPlayer and targetPlayer.Character then
				targetPlayer.Character:BreakJoints()
			end

			local winner = SessionData.CheckWinCondition()
			if winner and _G.EndGame then
				_G.EndGame(winner)
				return
			end
		end
	else
		print("[SERVER] Voting ended in a tie or skip. No one was arrested.")
	end

	-- UNFREEZE EVERYONE & RESTART THE CYCLE
	for userId, data in pairs(SessionData.ActivePlayers) do
		local plr = Players:GetPlayerByUserId(userId)
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			plr.Character.HumanoidRootPart.Anchored = false
			-- Optional: Teleport them back to their original spawn points here
		end
	end

	-- 🔥 UNLOCK KIRA SO THEY CAN KILL AGAIN
	SessionData.HasKilledThisCycle = false
	print("[SERVER] Cycle Reset. Kira can now strike again.")
end