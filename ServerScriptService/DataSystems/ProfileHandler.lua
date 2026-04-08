-- @ScriptType: Script
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")

-- We version the DataStore. If you ever need to completely wipe all player data, just change "V1" to "V2"
local PlayerDataStore = DataStoreService:GetDataStore("DeathNote_PlayerData_V1")
local DefaultProfile = require(ServerStorage:WaitForChild("Templates"):WaitForChild("DefaultProfile"))

-- Global table to hold active players' persistent data
_G.PlayerProfiles = {}

-- Helper function to perfectly clone the DefaultProfile table
local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function LoadData(player)
	local userId = player.UserId
	local key = "Player_" .. userId

	-- Wrap the fetch request in a pcall to prevent server crashes if Roblox DataStores go down
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(key)
	end)

	if success then
		if data then
			-- Player has played before, load their saved data
			_G.PlayerProfiles[userId] = data
			print("Loaded saved profile for " .. player.Name)
		else
			-- Brand new player, give them the DefaultProfile
			_G.PlayerProfiles[userId] = DeepCopy(DefaultProfile)
			print("Created brand new profile for " .. player.Name)
		end
	else
		warn("Roblox DataStores failed to load for " .. player.Name .. ". Error: " .. tostring(data))
		-- Kick the player if data fails to load so we don't accidentally overwrite their save with a blank one
		player:Kick("Roblox DataStores are currently experiencing issues. Please rejoin!")
	end
end

local function SaveData(player)
	local userId = player.UserId
	local key = "Player_" .. userId
	local dataToSave = _G.PlayerProfiles[userId]

	if dataToSave then
		local success, errorMessage = pcall(function()
			PlayerDataStore:SetAsync(key, dataToSave)
		end)

		if success then
			print("Successfully saved data for " .. player.Name)
		else
			warn("Failed to save data for " .. player.Name .. ". Error: " .. tostring(errorMessage))
		end

		-- Clean up server memory so it doesn't lag over time
		_G.PlayerProfiles[userId] = nil
	end
end

-- Connect the functions to player events
Players.PlayerAdded:Connect(LoadData)
Players.PlayerRemoving:Connect(SaveData)

-- BindToClose ensures that if the server crashes or shuts down, it forces a save for everyone still in the server
game:BindToClose(function()
	print("Server shutting down. Forcing final data save...")
	for _, player in ipairs(Players:GetPlayers()) do
		SaveData(player)
	end
	task.wait(3) -- Give the server a brief window to finish saving before it fully closes
end)