-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local SubmitVoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SubmitVoteEvent")
local StartMeetingEvent = Instance.new("RemoteEvent")
StartMeetingEvent.Name = "StartMeetingEvent"
StartMeetingEvent.Parent = ReplicatedStorage:WaitForChild("Events")

local currentVotes = {}
local votingActive = false

-- This is called by DeathNoteExecution when the 40 seconds are up
_G.StartVotingPhase = function()
	currentVotes = {}
	votingActive = true
	SessionData.RoundState = "Voting"
	print("Voting has opened! Players have " .. GameConfig.VotingTimeSeconds .. " seconds.")

	-- Tell all clients to open their Voting UI
	StartMeetingEvent:FireAllClients(SessionData.ActivePlayers)

	task.wait(GameConfig.VotingTimeSeconds)

	votingActive = false
	print("Voting closed. Tallying results...")

	local highestVotes = 0
	local arrestedUserId = nil
	local tie = false

	-- Tally the votes
	for targetId, voteCount in pairs(currentVotes) do
		if targetId == 0 then continue end -- 0 is a skipped vote

		if voteCount > highestVotes then
			highestVotes = voteCount
			arrestedUserId = targetId
			tie = false
		elseif voteCount == highestVotes then
			tie = true
		end
	end

	if tie or not arrestedUserId then
		print("Vote tied or skipped. No one was arrested.")
	else
		local arrestedPlayer = Players:GetPlayerByUserId(arrestedUserId)
		if arrestedPlayer then
			print(arrestedPlayer.Name .. " was ARRESTED!")

			local arrestedData = SessionData.ActivePlayers[arrestedUserId]
			if arrestedData then
				arrestedData.IsAlive = false -- Mark them as dead/removed

				-- Remove their character from the map
				if arrestedPlayer.Character then
					arrestedPlayer.Character:Destroy()
				end

				-- Check if we caught Kira!
				if arrestedData.Role == "Kira" then
					print("TASK FORCE WINS! Kira was caught.")
					if _G.EndGame then _G.EndGame("TaskForce") end
					return -- Stop the script here so it doesn't resume the round
				end
			end
		end
	end

	-- If the game didn't end, resume the round
	print("Resuming round...")
	SessionData.RoundState = "Playing"
end

-- Listen for votes from clients
SubmitVoteEvent.OnServerEvent:Connect(function(player, targetUserId)
	if not votingActive then return end

	-- Initialize vote count if it doesn't exist
	if not currentVotes[targetUserId] then
		currentVotes[targetUserId] = 0
	end

	currentVotes[targetUserId] += 1
	print(player.Name .. " voted for UserId: " .. targetUserId)
end)