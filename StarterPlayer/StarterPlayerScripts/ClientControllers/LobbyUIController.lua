-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local ShopPurchaseEvent = Events:WaitForChild("ShopPurchaseEvent")
local ShopEquipEvent = Events:WaitForChild("ShopEquipEvent")
local SyncDataEvent = Events:WaitForChild("SyncDataEvent")

local LobbyGui = PlayerGui:WaitForChild("LobbyGui")
local CoinDisplay = LobbyGui:WaitForChild("CoinDisplay")
local ShopPanel = LobbyGui:WaitForChild("ShopPanel")
local BuyRemButton = ShopPanel:WaitForChild("BuyRemButton")

-- Request data from the server the moment the player joins
task.wait(1)
SyncDataEvent:FireServer()

-- When the server sends our data back, update the screen!
SyncDataEvent.OnClientEvent:Connect(function(coins, gems, inventory, equipped)
	CoinDisplay.Text = "Coins: " .. coins .. " | Gems: " .. gems

	-- Check if we already own Rem so we can change the button text
	local ownsRem = table.find(inventory.ShinigamiSkins, "Rem") ~= nil
	local hasRemEquipped = equipped.Shinigami == "Rem"

	if hasRemEquipped then
		BuyRemButton.Text = "Rem (EQUIPPED)"
		BuyRemButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Green
	elseif ownsRem then
		BuyRemButton.Text = "Equip Rem"
		BuyRemButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200) -- Grey
	else
		BuyRemButton.Text = "Buy Rem (300 Coins)"
		BuyRemButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Gold
	end
end)

-- Handle clicking the Buy/Equip button
BuyRemButton.MouseButton1Click:Connect(function()
	-- The server double-checks everything, so we can just ask it to attempt the purchase/equip
	-- We pass the Category ("ShinigamiSkins") and the Item Name ("Rem")

	if string.find(BuyRemButton.Text, "Buy") then
		ShopPurchaseEvent:FireServer("ShinigamiSkins", "Rem")
	elseif string.find(BuyRemButton.Text, "Equip") then
		ShopEquipEvent:FireServer("ShinigamiSkins", "Rem")
	end
end)