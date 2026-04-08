-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local ShopPurchaseEvent = Events:WaitForChild("ShopPurchaseEvent")
local ShopEquipEvent = Events:WaitForChild("ShopEquipEvent")
local SyncDataEvent = Events:WaitForChild("SyncDataEvent")
local ShinigamiModels = ReplicatedStorage:WaitForChild("ShinigamiModels")

local Catalog = {
	{Name = "Ryuk", Price = 0, Currency = "Coins"},
	{Name = "Rem", Price = 300, Currency = "Coins"},
	{Name = "Sidoh", Price = 800, Currency = "Coins"},
	{Name = "TheReaper", Price = 400, Currency = "Gems"}
}
local currentIndex = 1
local playerInventory = {ShinigamiSkins = {}}
local playerEquipped = {Shinigami = "Ryuk"}

-- Wait for the AutoUIBuilder to create the Shop Panel
local LobbyGui = PlayerGui:WaitForChild("LobbyGui", 10)
if not LobbyGui then return end

local ShopPanel = LobbyGui:WaitForChild("ShopPanel")
local Viewport = ShopPanel:WaitForChild("Viewport")
local ItemNameLabel = ShopPanel:WaitForChild("ItemNameLabel")
local ActionButton = ShopPanel:WaitForChild("ActionButton")
local PrevButton = ShopPanel:WaitForChild("PrevButton")
local NextButton = ShopPanel:WaitForChild("NextButton")

local ViewportCam = Instance.new("Camera")
Viewport.CurrentCamera = ViewportCam
ViewportCam.Parent = Viewport

local current3DModel = nil

local function RenderShinigami(index)
	local item = Catalog[index]
	ItemNameLabel.Text = item.Name

	if current3DModel then current3DModel:Destroy() end

	local template = ShinigamiModels:FindFirstChild(item.Name)
	if template then
		current3DModel = template:Clone()
		current3DModel.Parent = Viewport

		local root = current3DModel.PrimaryPart or current3DModel:FindFirstChild("HumanoidRootPart")
		if root then
			ViewportCam.CFrame = CFrame.new(root.Position + Vector3.new(0, 1, -6), root.Position)
		end
	else
		ItemNameLabel.Text = item.Name .. " (Model Missing)"
	end

	local ownsItem = table.find(playerInventory.ShinigamiSkins, item.Name) ~= nil
	local isEquipped = playerEquipped.Shinigami == item.Name

	if isEquipped then
		ActionButton.Text = "EQUIPPED"
		ActionButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	elseif ownsItem then
		ActionButton.Text = "EQUIP"
		ActionButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	else
		ActionButton.Text = "BUY (" .. item.Price .. " " .. item.Currency .. ")"
		ActionButton.BackgroundColor3 = item.Currency == "Gems" and Color3.fromRGB(150, 0, 150) or Color3.fromRGB(15, 15, 15)
	end
end

PrevButton.MouseButton1Click:Connect(function()
	currentIndex = currentIndex - 1
	if currentIndex < 1 then currentIndex = #Catalog end
	RenderShinigami(currentIndex)
end)

NextButton.MouseButton1Click:Connect(function()
	currentIndex = currentIndex + 1
	if currentIndex > #Catalog then currentIndex = 1 end
	RenderShinigami(currentIndex)
end)

ActionButton.MouseButton1Click:Connect(function()
	local item = Catalog[currentIndex]
	if string.find(ActionButton.Text, "BUY") then
		ShopPurchaseEvent:FireServer("ShinigamiSkins", item.Name)
	elseif string.find(ActionButton.Text, "EQUIP") then
		ShopEquipEvent:FireServer("ShinigamiSkins", item.Name)
	end
end)

SyncDataEvent.OnClientEvent:Connect(function(coins, gems, inventory, equipped)
	playerInventory = inventory
	playerEquipped = equipped
	RenderShinigami(currentIndex) 
end)