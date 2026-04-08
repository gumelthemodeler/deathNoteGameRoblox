-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for the AutoUIBuilder to make the MainHUD
local MainHUD = PlayerGui:WaitForChild("MainHUD", 10)
if not MainHUD then return end

local CoinContainer = MainHUD:WaitForChild("CoinContainer")
local CoinText = CoinContainer:WaitForChild("CoinText")

local LeftMenu = MainHUD:WaitForChild("LeftMenuContainer")
local StoreButton = LeftMenu:WaitForChild("StoreButton")
local ProfileButton = LeftMenu:WaitForChild("ProfileButton")
local SpectateButton = LeftMenu:WaitForChild("SpectateButton")
local SettingsButton = LeftMenu:WaitForChild("SettingsButton")

-- Hover Animation Logic (DbD Style: Icons grow slightly)
local function AddHoverEffect(button)
	local originalSize = button.Size
	local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 8, originalSize.Y.Scale, originalSize.Y.Offset + 8)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {Size = hoverSize}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize}):Play()
	end)
end

AddHoverEffect(StoreButton)
AddHoverEffect(ProfileButton)
AddHoverEffect(SpectateButton)
AddHoverEffect(SettingsButton)

-- Listen for Data Sync
local Events = ReplicatedStorage:WaitForChild("Events")
local SyncDataEvent = Events:WaitForChild("SyncDataEvent")

SyncDataEvent.OnClientEvent:Connect(function(coins, gems, inventory, equipped)
	CoinText.Text = tostring(coins)
end)

-- Button Click Logic
StoreButton.MouseButton1Click:Connect(function()
	local shopPanel = PlayerGui:FindFirstChild("LobbyGui") and PlayerGui.LobbyGui:FindFirstChild("ShopPanel")
	if shopPanel then
		shopPanel.Visible = not shopPanel.Visible
	end
end)

ProfileButton.MouseButton1Click:Connect(function()
	print("Profile opened - Ready to wire Inventory Panel")
end)

SpectateButton.MouseButton1Click:Connect(function()
	print("Spectate mode triggered")
end)

SettingsButton.MouseButton1Click:Connect(function()
	print("Settings opened")
end)