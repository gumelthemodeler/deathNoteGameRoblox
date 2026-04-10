-- @ScriptType: LocalScript
-- Location: StarterPlayerScripts -> DevPanelUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AdminTestEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminTestEvent")

-- Create the GUI
local DevGui = Instance.new("ScreenGui")
DevGui.Name = "DevTestingPanel"
DevGui.ResetOnSpawn = false
DevGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 200, 0, 400)
MainPanel.Position = UDim2.new(1, -220, 0.5, -200)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainPanel.BackgroundTransparency = 0.2
MainPanel.Parent = DevGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "DEV CONTROLS"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.Parent = MainPanel

local ButtonList = Instance.new("ScrollingFrame")
ButtonList.Size = UDim2.new(1, 0, 1, -40)
ButtonList.Position = UDim2.new(0, 0, 0, 40)
ButtonList.BackgroundTransparency = 1
ButtonList.ScrollBarThickness = 4
ButtonList.Parent = MainPanel

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = ButtonList

-- Helper to create buttons
local function CreateButton(text, command)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.Code
	btn.TextSize = 14
	btn.Parent = ButtonList

	btn.MouseButton1Click:Connect(function()
		AdminTestEvent:FireServer(command)
	end)
end

-- Generate the Testing Buttons
CreateButton("🚨 Force Meeting", "ForceMeeting")
CreateButton("💀 Spawn Fake Body", "SpawnTestBody")
CreateButton("🪪 Spawn ID Cards", "SpawnIDCards")
CreateButton("🍎 Set Role: Kira", "SetRoleKira")
CreateButton("🛡️ Set Role: Civ", "SetRoleCiv")
CreateButton("🚪 Test Lockdown", "TriggerLockdown")

-- Toggle Panel visibility with 'P' key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.P then
		MainPanel.Visible = not MainPanel.Visible
	end
end)