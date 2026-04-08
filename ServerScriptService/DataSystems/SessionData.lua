-- @ScriptType: ModuleScript
local SessionData = {
	RoundState = "Lobby", 
	TimeRemaining = 0,
	ActivePlayers = {}    
}

function SessionData.Reset()
	SessionData.RoundState = "Lobby"
	SessionData.TimeRemaining = 0
	table.clear(SessionData.ActivePlayers)
end

function SessionData.CheckWinCondition()
	local kiraAlive = false
	local taskForceAlive = 0
	local totalPlayersInMatch = 0

	for userId, data in pairs(SessionData.ActivePlayers) do
		totalPlayersInMatch += 1
		if data.IsAlive then
			if data.Role == "Kira" then
				kiraAlive = true
			elseif data.Role == "TaskForce" then
				taskForceAlive += 1
			end
		end
	end

	-- DEV MODE PATCH: Prevent instant win if you are testing by yourself
	if totalPlayersInMatch == 1 then
		return nil 
	end

	if not kiraAlive then
		return "TaskForce" 
	elseif taskForceAlive == 0 then
		return "Kira" 
	end

	return nil 
end

return SessionData