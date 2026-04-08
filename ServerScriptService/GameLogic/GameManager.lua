-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local AnimeNames = {
	"Light Yagami", "L Lawliet", "Misa Amane", "Ryuk", 
	"Soichiro Yagami", "Touta Matsuda", "Teru Mikami", "Kiyomi Takada"
}

-- Centralized End Game Function
_G.EndGame = function(winningTeam)
	if SessionData.RoundState == "PostMatch" then return end -- Prevent double firing
	SessionData.RoundState = "PostMatch"

	print("=== MATCH OVER ===")
	print("Winner: " .. winningTeam)

	-- Reward players
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
			print(Players:GetNameFromUserIdAsync(userId) .. " received coins for winning!")
		end
	end

	task.wait(5) -- Give time for a victory screen to show
	SessionData.Reset()

	-- Respawn everyone back to the lobby
	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
end

local function StartRound()
	SessionData.Reset()
	SessionData.RoundState = "Playing"
	SessionData.TimeRemaining = GameConfig.RoundTimeLimitSeconds

	local availableNames = table.clone(AnimeNames)
	local playersList = Players:GetPlayers()

	if #playersList == 0 then return end

	-- Assign Roles
	local kiraIndex = math.random(1, #playersList)
	local kiraPlayer = playersList[kiraIndex]

	for _, player in ipairs(playersList) do
		local nameIndex = math.random(1, #availableNames)
		local assignedName = table.remove(availableNames, nameIndex)

		SessionData.ActivePlayers[player.UserId] = {
			Role = (player == kiraPlayer) and "Kira" or "TaskForce",
			RealName = assignedName,
			IsAlive = true,
			CollectedIDs = {}
		}
		print(player.Name .. " | Role: " .. SessionData.ActivePlayers[player.UserId].Role .. " | Name: " .. assignedName)
	end

	-- Spawn ID Cards
	if _G.DistributeIDCards then
		_G.DistributeIDCards()
	end

	print("Round Started! Kira is hidden.")
end

-- The Main Game Loop
task.spawn(function()
	while true do
		if SessionData.RoundState == "Lobby" then
			local playerCount = #Players:GetPlayers()
			local requiredPlayers = GameConfig.DevMode and 1 or GameConfig.MinPlayersToStart

			if playerCount >= requiredPlayers then
				print("Starting match in 5 seconds...")
				task.wait(5)
				StartRound()
			else
				task.wait(2)
			end

		elseif SessionData.RoundState == "Playing" then
			SessionData.TimeRemaining -= 1

			-- Check for natural win condition (Kira kills everyone)
			local winner = SessionData.CheckWinCondition()
			if winner then
				_G.EndGame(winner)
			elseif SessionData.TimeRemaining <= 0 then
				_G.EndGame("TaskForce") -- Time out means Kira failed
			end

			task.wait(1)
		end
	end
end)