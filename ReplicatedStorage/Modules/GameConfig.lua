-- @ScriptType: ModuleScript
local GameConfig = {
	-- Testing
	DevMode = true,              -- Set to FALSE before publishing! Allows 1-player starts.

	-- Round Settings
	MinPlayersToStart = 4,       -- Ignored if DevMode is true
	MaxPlayers = 12,
	RoundTimeLimitSeconds = 600, -- 10 minutes

	-- Gameplay Mechanics
	FocusTimeRequired = 3.0,     -- Seconds Kira must stare to verify ID
	KillTimerSeconds = 40.0,     -- Lore-accurate 40 seconds
	TotalTasksRequired = 20,     -- Tasks Task Force must do to win
	VotingTimeSeconds = 30,      -- How long players have to vote

	-- Sabotage Cooldowns (in seconds)
	SabotageCooldowns = {
		Blackout = 45,
		FakeHeartAttack = 60
	},

	-- Economy Payouts
	Rewards = {
		WinAsKiraCoins = 150,
		WinAsTFCoins = 100,
		TaskCompleteCoins = 5,
		CorrectVoteCoins = 25
	}
	
	
}

return GameConfig