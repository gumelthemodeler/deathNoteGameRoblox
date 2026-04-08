-- @ScriptType: ModuleScript
local DefaultProfile = {
	-- Core Economy
	Coins = 0,               -- Soft Currency (earned by playing)
	Gems = 0,                -- Hard Currency (Robux purchases)
	Level = 1,
	Experience = 0,

	-- Lifetime Stats
	Stats = {
		WinsAsKira = 0,
		WinsAsTaskForce = 0,
		TotalKills = 0,
		TasksCompleted = 0,
		TimesArrested = 0
	},

	-- Unlocked Cosmetics Inventory
	Inventory = {
		ShinigamiSkins = {"Ryuk"},           
		DeathEffects = {"HeartAttack"},
		NotebookSkins = {"ClassicBlack"},
		LMonograms = {"DefaultL"}
	},

	-- Currently Equipped Cosmetics
	Equipped = {
		Shinigami = "Ryuk",
		DeathEffect = "HeartAttack",
		Notebook = "ClassicBlack",
		LMonogram = "DefaultL"
	}
}

return DefaultProfile