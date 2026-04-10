-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Create our Shop Events securely
local EventsFolder = ReplicatedStorage:WaitForChild("Events")

local ShopPurchaseEvent = Instance.new("RemoteEvent")
ShopPurchaseEvent.Name = "ShopPurchaseEvent"
ShopPurchaseEvent.Parent = EventsFolder

local ShopEquipEvent = Instance.new("RemoteEvent")
ShopEquipEvent.Name = "ShopEquipEvent"
ShopEquipEvent.Parent = EventsFolder

local SyncDataEvent = Instance.new("RemoteEvent")
SyncDataEvent.Name = "SyncDataEvent"
SyncDataEvent.Parent = EventsFolder

-- Master Price List (Easy to edit later)
local Catalog = {
	ShinigamiSkins = {
		Ryuk = {Price = 0, Currency = "Coins"}, -- Default
		Rem = {Price = 300, Currency = "Coins"},
		Sidoh = {Price = 800, Currency = "Coins"},
		TheReaper = {Price = 400, Currency = "Gems"} -- Premium Robux Skin
	}
}

-- Update client UI with their current coins/inventory/stats
local function SyncClientData(player)
	local profile = _G.PlayerProfiles[player.UserId]
	if profile then
		-- Sends the coins, gems, inventory, equipped, level, AND stats to the client
		SyncDataEvent:FireClient(player, profile.Coins, profile.Gems, profile.Inventory, profile.Equipped, profile.Level, profile.Stats)
	end
end

-- Allow clients to request a data sync when they open the shop
SyncDataEvent.OnServerEvent:Connect(function(player)
	SyncClientData(player)
end)

ShopPurchaseEvent.OnServerEvent:Connect(function(player, category, itemName)
	local profile = _G.PlayerProfiles[player.UserId]
	if not profile then return end

	local itemData = Catalog[category] and Catalog[category][itemName]
	if not itemData then return end

	-- Ensure they don't already own it
	if table.find(profile.Inventory[category], itemName) then
		print(player.Name .. " already owns " .. itemName)
		return
	end

	-- Check currency and charge them
	if profile[itemData.Currency] >= itemData.Price then
		profile[itemData.Currency] -= itemData.Price
		table.insert(profile.Inventory[category], itemName)
		print(player.Name .. " successfully bought: " .. itemName)

		-- Auto-equip upon purchase
		profile.Equipped[string.gsub(category, "Skins", "")] = itemName

		SyncClientData(player) -- Update their screen
	else
		print(player.Name .. " cannot afford " .. itemName)
	end
end)

ShopEquipEvent.OnServerEvent:Connect(function(player, category, itemName)
	local profile = _G.PlayerProfiles[player.UserId]
	if not profile then return end

	-- Security: Verify they actually own it before equipping
	if table.find(profile.Inventory[category], itemName) then
		local equipSlot = string.gsub(category, "Skins", "") -- e.g., "ShinigamiSkins" -> "Shinigami"
		profile.Equipped[equipSlot] = itemName
		print(player.Name .. " equipped: " .. itemName)
		SyncClientData(player)
	end
end)