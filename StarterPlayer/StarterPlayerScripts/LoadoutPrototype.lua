-- @ScriptType: LocalScript
-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy old prototypes for clean testing
if PlayerGui:FindFirstChild("LoadoutPrototype") then
	PlayerGui.LoadoutPrototype:Destroy()
end

local LoadoutGui = Instance.new("ScreenGui")
LoadoutGui.Name = "LoadoutPrototype"
LoadoutGui.ResetOnSpawn = false
LoadoutGui.Parent = PlayerGui

-- ==========================================
-- 0. MOCK TOGGLE BUTTON (For Testing)
-- ==========================================
local MockProfileBtn = Instance.new("TextButton")
MockProfileBtn.Size = UDim2.new(0, 150, 0, 50)
MockProfileBtn.Position = UDim2.new(0, 20, 1, -70)
MockProfileBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
MockProfileBtn.Text = "OPEN PROFILE"
MockProfileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MockProfileBtn.Font = Enum.Font.Jura
MockProfileBtn.TextSize = 20
MockProfileBtn.Parent = LoadoutGui

local MockStroke = Instance.new("UIStroke")
MockStroke.Color = Color3.fromRGB(255, 50, 50)
MockStroke.Parent = MockProfileBtn

-- ==========================================
-- 1. THE MAIN PROFILE PANEL (Crimson Aesthetic)
-- ==========================================
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 420, 0, 720) -- Exact dimensions of your old dossier
MainPanel.AnchorPoint = Vector2.new(0, 0.5)
MainPanel.Position = UDim2.new(0, 40, 0.5, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 3, 3) -- Deep pitch-red
MainPanel.BackgroundTransparency = 0.1
MainPanel.Visible = false -- Hidden by default!
MainPanel.Parent = LoadoutGui

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(120, 20, 20) -- Blood red outline
PanelStroke.Thickness = 2
PanelStroke.Parent = MainPanel

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, 0, 0, 50)
HeaderTitle.Position = UDim2.new(0, 20, 0, 10)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LOADOUT PLANNER"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
HeaderTitle.Font = Enum.Font.Antique
HeaderTitle.TextSize = 32
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = MainPanel

-- ==========================================
-- 2. ROLE TABS (Horizontal Navigation)
-- ==========================================
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, -40, 0, 40)
TabsContainer.Position = UDim2.new(0, 20, 0, 70)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = MainPanel

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.Padding = UDim.new(0, 8)
TabsLayout.Parent = TabsContainer

local currentActiveTab = nil

-- ==========================================
-- 3. THE LOADOUT SCROLLING AREA
-- ==========================================
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -40, 1, -140)
ContentScroll.Position = UDim2.new(0, 20, 0, 120)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
ContentScroll.ScrollBarThickness = 4
ContentScroll.BorderSizePixel = 0
ContentScroll.Parent = MainPanel

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 15)
ContentLayout.Parent = ContentScroll

local function ClearLoadout()
	for _, child in ipairs(ContentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
end

-- Generates the sleek, wide perk blocks
local function CreatePerkSlot(title, subtitle, isRolePerk)
	local box = Instance.new("TextButton")
	box.Size = UDim2.new(1, -10, 0, 70)
	-- Role perks have a slightly different red tint to distinguish them from general perks
	box.BackgroundColor3 = isRolePerk and Color3.fromRGB(30, 5, 5) or Color3.fromRGB(15, 10, 10)
	box.BackgroundTransparency = 0.2
	box.Text = ""
	box.Parent = ContentScroll

	local stroke = Instance.new("UIStroke")
	stroke.Color = isRolePerk and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(80, 80, 80)
	stroke.Thickness = 1
	stroke.Parent = box

	-- Icon Placeholder Square
	local iconSlot = Instance.new("Frame")
	iconSlot.Size = UDim2.new(0, 50, 0, 50)
	iconSlot.Position = UDim2.new(0, 10, 0.5, -25)
	iconSlot.BackgroundColor3 = Color3.fromRGB(10, 5, 5)
	iconSlot.Parent = box

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Color = Color3.fromRGB(100, 30, 30)
	iconStroke.Parent = iconSlot

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 0, 25)
	titleLabel.Position = UDim2.new(0, 75, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	titleLabel.Font = Enum.Font.Jura
	titleLabel.TextSize = 20
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = box

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, -80, 0, 25)
	subLabel.Position = UDim2.new(0, 75, 0, 35)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = subtitle
	subLabel.TextColor3 = Color3.fromRGB(150, 100, 100)
	subLabel.Font = Enum.Font.Bodoni
	subLabel.TextSize = 14
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Parent = box

	-- Simple hover glow
	box.MouseEnter:Connect(function() stroke.Thickness = 2 end)
	box.MouseLeave:Connect(function() stroke.Thickness = 1 end)
end

-- Creates Section Headers (e.g., "GENERAL PERKS (3/3)")
local function CreateSectionHeader(text)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundTransparency = 1
	header.Text = text
	header.TextColor3 = Color3.fromRGB(180, 180, 180)
	header.Font = Enum.Font.Antique
	header.TextSize = 22
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = ContentScroll
end

-- Builds the lists dynamically based on the tab clicked
local function RenderLoadout(roleName)
	ClearLoadout()

	-- 1. Cosmetics Section (Everyone gets this)
	CreateSectionHeader("COSMETICS")
	CreatePerkSlot("Character Skin", "Default", false)
	CreatePerkSlot("Equipped Emote", "None", false)

	-- 2. General Perks Section (3 Slots)
	CreateSectionHeader("GENERAL PERKS (3 SLOTS)")
	CreatePerkSlot("General Perk 1", "Click to equip a survival perk.", false)
	CreatePerkSlot("General Perk 2", "Click to equip a survival perk.", false)
	CreatePerkSlot("General Perk 3", "Click to equip a survival perk.", false)

	-- 3. Role-Specific Section (3 Slots)
	if roleName ~= "Civilian" then
		CreateSectionHeader(string.upper(roleName) .. " PERKS (3 SLOTS)")
		CreatePerkSlot("Role Perk 1", "Exclusive ability for " .. roleName .. ".", true)
		CreatePerkSlot("Role Perk 2", "Exclusive ability for " .. roleName .. ".", true)
		CreatePerkSlot("Role Perk 3", "Exclusive ability for " .. roleName .. ".", true)
	end
end

-- Generates the Top Tabs
local function CreateTab(roleName)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 85, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
	btn.Text = roleName
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.Font = Enum.Font.Jura
	btn.TextSize = 16
	btn.Parent = TabsContainer

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 20, 20)
	stroke.Parent = btn

	btn.MouseButton1Click:Connect(function()
		-- Reset previous tab
		if currentActiveTab then
			currentActiveTab.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
			currentActiveTab.TextColor3 = Color3.fromRGB(150, 150, 150)
			currentActiveTab:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(80, 20, 20)
		end

		-- Highlight new tab
		btn.BackgroundColor3 = Color3.fromRGB(80, 15, 15)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		stroke.Color = Color3.fromRGB(255, 50, 50)
		currentActiveTab = btn

		RenderLoadout(roleName)
	end)

	return btn
end

-- Initialize Tabs
local civTab = CreateTab("Civilian")
CreateTab("Kira")
CreateTab("L")
CreateTab("Mello")

-- Force click the Civilian tab to start
civTab.BackgroundColor3 = Color3.fromRGB(80, 15, 15)
civTab.TextColor3 = Color3.fromRGB(255, 255, 255)
civTab:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(255, 50, 50)
currentActiveTab = civTab
RenderLoadout("Civilian")

-- ==========================================
-- 4. TOGGLE LOGIC
-- ==========================================
MockProfileBtn.MouseButton1Click:Connect(function()
	MainPanel.Visible = not MainPanel.Visible
	MockProfileBtn.Text = MainPanel.Visible and "CLOSE PROFILE" or "OPEN PROFILE"
end)