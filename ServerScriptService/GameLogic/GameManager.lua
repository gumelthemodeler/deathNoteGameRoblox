-- @ScriptType: Script
-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

-- Auto-Create the Bridge Events
local Events = ReplicatedStorage:WaitForChild("Events")
local function GetOrCreateEvent(name)
	local ev = Events:FindFirstChild(name)
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = Events
	end
	return ev
end

local UpdateTimer = GetOrCreateEvent("UpdateTimer")
local ShowVoting = GetOrCreateEvent("ShowVoting")
local SyncRoleEvent = GetOrCreateEvent("SyncRoleEvent")
local VoteGamemode = GetOrCreateEvent("VoteGamemode")
local UpdateGamemodeVotes = GetOrCreateEvent("UpdateGamemodeVotes")

local AnimeNames = {
	"Light Yagami", "L Lawliet", "Misa Amane", "Ryuk", 
	"Soichiro Yagami", "Touta Matsuda", "Teru Mikami", "Kiyomi Takada"
}

-- 🗳️ GAMEMODE VOTING LOGIC
local currentGamemodeVotes = {}

-- The SERVER uses "OnServerEvent" to listen to the clients
VoteGamemode.OnServerEvent:Connect(function(player, modeName)
	if SessionData.RoundState == "Lobby" then
		currentGamemodeVotes[player.UserId] = modeName
		UpdateGamemodeVotes:FireAllClients(currentGamemodeVotes)
	end
end)

local function GetWinningGamemode()
	local counts = {}
	for _, mode in pairs(currentGamemodeVotes) do
		counts[mode] = (counts[mode] or 0) + 1
	end

	local bestMode = "CLASSIC" -- Default fallback
	local maxVotes = 0
	for mode, count in pairs(counts) do
		if count > maxVotes then
			maxVotes = count
			bestMode = mode
		end
	end
	return bestMode
end

-- Centralized End Game Function
_G.EndGame = function(winningTeam)
	if SessionData.RoundState == "PostMatch" then return end
	SessionData.RoundState = "PostMatch"

	print("=== MATCH OVER ===")
	-- The SERVER uses "FireAllClients" to broadcast to the UI
	UpdateTimer:FireAllClients("MATCH OVER: " .. string.upper(winningTeam) .. " WINS", "")

	for userId, sessionInfo in pairs(SessionData.ActivePlayers) do
		local persistentProfile = _G.PlayerProfiles[userId]
		if not persistentProfile then continue end

		if sessionInfo.Role == winningTeam then
			if winningTeam == "Kira" then
				persistentProfile.Coins += GameConfig.Rewards.WinAsKiraCoins
				persistentProfile.Stats.WinsAsKira += 1
			else
				persistentProfile.Coins += GameConfig.Rewards.WinAsTFCoins
				persistentProfile.Stats.WinsAsTaskForce += 1
			end
		end
	end

	task.wait(5)
	SessionData.Reset()

	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
end

local function StartRound(gamemode)
	SessionData.Reset()
	SessionData.RoundState = "Playing"
	SessionData.TimeRemaining = GameConfig.RoundTimeLimitSeconds

	local availableNames = table.clone(AnimeNames)
	local playersList = Players:GetPlayers()

	if #playersList == 0 then return end

	local kiraIndex = math.random(1, #playersList)
	local kiraPlayer = playersList[kiraIndex]

	for _, player in ipairs(playersList) do
		local nameIndex = math.random(1, #availableNames)
		local assignedName = table.remove(availableNames, nameIndex)

		local isKira = (player == kiraPlayer)
		local role = isKira and "Kira" or "TaskForce"

		SessionData.ActivePlayers[player.UserId] = {
			Role = role,
			RealName = assignedName,
			IsAlive = true,
			CollectedIDs = {}
		}

		local persistentData = _G.PlayerProfiles[player.UserId]
		local equippedShinigami = "Ryuk"
		if persistentData and persistentData.Equipped and persistentData.Equipped.Shinigami then
			equippedShinigami = persistentData.Equipped.Shinigami
		end

		SyncRoleEvent:FireClient(player, role, assignedName, equippedShinigami)
	end

	if _G.DistributeIDCards then _G.DistributeIDCards() end
	print("Round Started! Gamemode: " .. gamemode)
end

local function runCountdown(stateText, seconds, abortIfPlayersLeave)
	for i = seconds, 0, -1 do
		local requiredPlayers = math.max(2, GameConfig.MinPlayersToStart) 

		if abortIfPlayersLeave and #Players:GetPlayers() < requiredPlayers then
			UpdateTimer:FireAllClients("WAITING FOR PLAYERS...", "--:--")
			return false 
		end

		local timeString = string.format("%d:%02d", math.floor(i / 60), i % 60)
		UpdateTimer:FireAllClients(stateText, timeString)
		task.wait(1)
	end
	return true
end

-- The Main Game Loop
task.spawn(function()
	while true do
		if SessionData.RoundState == "Lobby" then
			local playerCount = #Players:GetPlayers()
			local requiredPlayers = math.max(2, GameConfig.MinPlayersToStart) 

			if playerCount >= requiredPlayers then
				-- 1. Intermission
				if runCountdown("INTERMISSION", 15, true) then

					-- 2. Gamemode Voting
					currentGamemodeVotes = {}
					UpdateGamemodeVotes:FireAllClients(currentGamemodeVotes)

					ShowVoting:FireAllClients(true)
					runCountdown("VOTING ENDS IN", 10, false)
					ShowVoting:FireAllClients(false)

					local winningMode = GetWinningGamemode()

					-- 3. Game Start
					runCountdown("STARTING: " .. winningMode, 3, false)
					StartRound(winningMode)
				end
			else
				UpdateTimer:FireAllClients("WAITING FOR PLAYERS...", string.format("%d / %d", playerCount, requiredPlayers))
				task.wait(1)
			end

		elseif SessionData.RoundState == "Playing" then
			SessionData.TimeRemaining -= 1

			local timeStr = string.format("%d:%02d", math.floor(SessionData.TimeRemaining / 60), SessionData.TimeRemaining % 60)
			UpdateTimer:FireAllClients("SURVIVE", timeStr)

			local winner = SessionData.CheckWinCondition()
			if winner then
				_G.EndGame(winner)
			elseif SessionData.TimeRemaining <= 0 then
				_G.EndGame("TaskForce")
			end

			task.wait(1)
		end
	end
end)