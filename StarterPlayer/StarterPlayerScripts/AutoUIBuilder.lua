-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local function CreateScreenGui(name)
	local sg = Instance.new("ScreenGui")
	sg.Name = name
	sg.ResetOnSpawn = false
	sg.Parent = PlayerGui
	return sg
end

-- 🔥 SUBTLE CLIENT-SIDE GLOW GENERATOR
local function CreateGlowEffect(parent, baseColor)
	local glowFolder = Instance.new("Folder")
	glowFolder.Name = "GlowEffects"
	glowFolder.Parent = parent

	for i = 1, 2 do
		local glowFrame = Instance.new("Frame")
		glowFrame.Size = UDim2.new(1, 0, 1, 0)
		glowFrame.BackgroundTransparency = 1
		glowFrame.ZIndex = parent.ZIndex - 1
		glowFrame.Parent = glowFolder

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = glowFrame

		local stroke = Instance.new("UIStroke")
		stroke.Color = baseColor
		stroke.Thickness = i * 1.5 
		stroke.Transparency = 0.65 + (i * 0.1) 
		stroke.Parent = glowFrame

		local pulseInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(stroke, pulseInfo, {Transparency = stroke.Transparency + 0.15}):Play()
	end
end

-- 🦇 GOTHIC STYLE APPLIER
local function ApplyGothicStyle(frame, transparency)
	frame.BackgroundColor3 = Color3.fromRGB(20, 5, 5) 
	frame.BackgroundTransparency = transparency or 0.3
	frame.BorderSizePixel = 0

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(255, 30, 30) 
	innerStroke.Thickness = 1 
	innerStroke.Parent = frame

	CreateGlowEffect(frame, Color3.fromRGB(255, 0, 0))
end

-- Prevent duplicate GUIs
for _, guiName in ipairs({"MainHUD", "LobbyGui", "ProfileGui"}) do
	if PlayerGui:FindFirstChild(guiName) then
		PlayerGui[guiName]:Destroy()
	end
end

-- ==========================================
-- 1. MAIN HUD (Coins & Left Menu)
-- ==========================================
local MainHUD = CreateScreenGui("MainHUD")

local CoinContainer = Instance.new("Frame")
CoinContainer.Name = "CoinContainer"
CoinContainer.Size = UDim2.new(0, 150, 0, 90) 
CoinContainer.AnchorPoint = Vector2.new(0, 0) 
CoinContainer.Position = UDim2.new(0, 40, 0, 20)
CoinContainer.BackgroundTransparency = 1 
CoinContainer.Parent = MainHUD

local CoinIcon = Instance.new("ImageLabel")
CoinIcon.Name = "CoinIcon"
CoinIcon.Size = UDim2.new(0, 80, 0, 80)
CoinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
CoinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
CoinIcon.BackgroundTransparency = 1
CoinIcon.Image = "rbxassetid://92601399866484"
CoinIcon.Parent = CoinContainer

local CoinText = Instance.new("TextLabel")
CoinText.Name = "CoinText"
CoinText.Size = UDim2.new(1, 0, 1, 0) 
CoinText.BackgroundTransparency = 1
CoinText.TextColor3 = Color3.fromRGB(255, 255, 255) 
CoinText.TextSize = 40 
CoinText.Font = Enum.Font.Antique
CoinText.TextXAlignment = Enum.TextXAlignment.Center 
CoinText.TextYAlignment = Enum.TextYAlignment.Center 
CoinText.Text = "0"
CoinText.Parent = CoinIcon

local TextStroke = Instance.new("UIStroke")
TextStroke.Color = Color3.fromRGB(20, 5, 5) 
TextStroke.Thickness = 2
TextStroke.Parent = CoinText

local LeftMenuContainer = Instance.new("Frame")
LeftMenuContainer.Name = "LeftMenuContainer"
LeftMenuContainer.Size = UDim2.new(0, 150, 0, 600) 
LeftMenuContainer.AnchorPoint = Vector2.new(0, 0) 
LeftMenuContainer.Position = UDim2.new(0, 40, 0, 120) 
LeftMenuContainer.BackgroundTransparency = 1
LeftMenuContainer.Parent = MainHUD

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5) 
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = LeftMenuContainer

local function CreateMenuButton(name, imageId, layoutOrder)
	local btn = Instance.new("ImageButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 120, 0, 120) 
	btn.BackgroundTransparency = 1
	btn.Image = imageId
	btn.LayoutOrder = layoutOrder
	btn.Parent = LeftMenuContainer

	local originalSize = btn.Size
	local hoverSize = UDim2.new(0, 130, 0, 130)

	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {Size = hoverSize}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {Size = originalSize}):Play() end)
	return btn
end

local StoreButton = CreateMenuButton("StoreButton", "rbxassetid://74540904287259", 1)
local ProfileButton = CreateMenuButton("ProfileButton", "rbxassetid://134344391486300", 2)
local SpectateButton = CreateMenuButton("SpectateButton", "rbxassetid://119082781398218", 3)
local SettingsButton = CreateMenuButton("SettingsButton", "rbxassetid://89512707251260", 4)

-- ==========================================
-- 2. THE SHOP GUI
-- ==========================================
local LobbyGui = CreateScreenGui("LobbyGui")
local ShopPanel = Instance.new("Frame")
ShopPanel.Name = "ShopPanel"
ShopPanel.Size = UDim2.new(0, 400, 0, 500)
ShopPanel.Position = UDim2.new(0.5, -200, 0.5, -250)
ApplyGothicStyle(ShopPanel, 0.2)
ShopPanel.Visible = false
ShopPanel.Parent = LobbyGui

local ShopTitle = Instance.new("TextLabel")
ShopTitle.Size = UDim2.new(1, 0, 0, 50)
ShopTitle.BackgroundTransparency = 1
ShopTitle.Text = "BLACK MARKET"
ShopTitle.TextColor3 = Color3.fromRGB(255, 40, 40)
ShopTitle.Font = Enum.Font.Antique
ShopTitle.TextSize = 38
ShopTitle.Parent = ShopPanel

local Viewport = Instance.new("ViewportFrame")
Viewport.Name = "Viewport"
Viewport.Size = UDim2.new(1, -40, 0, 300)
Viewport.Position = UDim2.new(0, 20, 0, 60)
ApplyGothicStyle(Viewport, 0.7)
Viewport.Parent = ShopPanel

local ItemNameLabel = Instance.new("TextLabel")
ItemNameLabel.Name = "ItemNameLabel"
ItemNameLabel.Size = UDim2.new(1, 0, 0, 40)
ItemNameLabel.Position = UDim2.new(0, 0, 0, 370)
ItemNameLabel.BackgroundTransparency = 1
ItemNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemNameLabel.Font = Enum.Font.Bodoni
ItemNameLabel.TextSize = 28
ItemNameLabel.Parent = ShopPanel

local ActionButton = Instance.new("TextButton")
ActionButton.Name = "ActionButton"
ActionButton.Size = UDim2.new(0, 200, 0, 50)
ActionButton.Position = UDim2.new(0.5, -100, 1, -70)
ActionButton.Text = "LOADING..."
ActionButton.Font = Enum.Font.Bodoni
ActionButton.TextSize = 24
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyGothicStyle(ActionButton, 0.5)
ActionButton.Parent = ShopPanel

local function CreateArrowBtn(name, text, xPos)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 50, 0, 50)
	btn.Position = UDim2.new(xPos, xPos == 0 and 20 or -70, 1, -70)
	btn.Text = text
	btn.Font = Enum.Font.Bodoni
	btn.TextSize = 30
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ApplyGothicStyle(btn, 0.5)
	btn.Parent = ShopPanel
	return btn
end
local PrevButton = CreateArrowBtn("PrevButton", "<", 0)
local NextButton = CreateArrowBtn("NextButton", ">", 1)

-- ==========================================
-- 3. THE ASYMMETRICAL PROFILE GUI
-- ==========================================
local ProfileGui = CreateScreenGui("ProfileGui")

local ProfileContainer = Instance.new("Frame")
ProfileContainer.Name = "ProfileContainer"
ProfileContainer.Size = UDim2.new(1, 0, 1, 0)
ProfileContainer.BackgroundTransparency = 1 
ProfileContainer.Visible = false
ProfileContainer.Parent = ProfileGui

local DossierPanel = Instance.new("Frame")
DossierPanel.Name = "DossierPanel"
DossierPanel.Size = UDim2.new(0, 380, 0, 650)
DossierPanel.AnchorPoint = Vector2.new(0, 0.5)
DossierPanel.Position = UDim2.new(0, 50, 0.5, 0) 
DossierPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
DossierPanel.BackgroundTransparency = 0.15
DossierPanel.BorderSizePixel = 0
DossierPanel.Parent = ProfileContainer

local DossierStroke = Instance.new("UIStroke")
DossierStroke.Color = Color3.fromRGB(220, 220, 220)
DossierStroke.Thickness = 2
DossierStroke.Parent = DossierPanel

-- HEADER (Icon & Title)
local HeaderIcon = Instance.new("Frame")
HeaderIcon.Size = UDim2.new(0, 100, 0, 100)
HeaderIcon.Position = UDim2.new(0, 20, 0, 20)
HeaderIcon.BackgroundTransparency = 0.8
HeaderIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderIcon.Parent = DossierPanel

local RoleTitle = Instance.new("TextLabel")
RoleTitle.Size = UDim2.new(1, -140, 0, 50)
RoleTitle.Position = UDim2.new(0, 130, 0, 30)
RoleTitle.BackgroundTransparency = 1
RoleTitle.Text = "Kira"
RoleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
RoleTitle.Font = Enum.Font.Antique
RoleTitle.TextSize = 42
RoleTitle.TextXAlignment = Enum.TextXAlignment.Left
RoleTitle.Parent = DossierPanel

local RoleSubtitle = Instance.new("TextLabel")
RoleSubtitle.Size = UDim2.new(1, -140, 0, 20)
RoleSubtitle.Position = UDim2.new(0, 130, 0, 75)
RoleSubtitle.BackgroundTransparency = 1
RoleSubtitle.Text = "\"I am the god of the new world.\""
RoleSubtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
RoleSubtitle.FontFace = Font.fromEnum(Enum.Font.Bodoni, Enum.FontWeight.Light)
RoleSubtitle.TextSize = 16
RoleSubtitle.TextXAlignment = Enum.TextXAlignment.Left
RoleSubtitle.Parent = DossierPanel

-- TABS ROW
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, -40, 0, 40)
TabsContainer.Position = UDim2.new(0, 20, 0, 140)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = DossierPanel

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.Padding = UDim.new(0, 10)
TabsLayout.Parent = TabsContainer

local function CreateTab(name, text, isActive)
	local tab = Instance.new("TextButton")
	tab.Name = name
	tab.Size = UDim2.new(0.3, 0, 1, 0)
	tab.BackgroundColor3 = isActive and Color3.fromRGB(100, 20, 20) or Color3.fromRGB(30, 30, 30)
	tab.BackgroundTransparency = isActive and 0.2 or 0.6
	tab.Text = text
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.Font = Enum.Font.Jura
	tab.TextSize = 16
	tab.Parent = TabsContainer

	local stroke = Instance.new("UIStroke")
	stroke.Color = isActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 100, 100)
	stroke.Parent = tab
	return tab
end

CreateTab("InfoTab", "Information", true)
CreateTab("SkinsTab", "Skins", false)

-- STATS LIST
local StatsContainer = Instance.new("Frame")
StatsContainer.Size = UDim2.new(1, -40, 0, 160)
StatsContainer.Position = UDim2.new(0, 20, 0, 200)
StatsContainer.BackgroundTransparency = 1
StatsContainer.Parent = DossierPanel

local StatsLayout = Instance.new("UIListLayout")
StatsLayout.Padding = UDim.new(0, 5)
StatsLayout.Parent = StatsContainer

local function CreateStatRow(statName, valueStr)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 25)
	row.BackgroundTransparency = 1
	row.Parent = StatsContainer

	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 2, 0.8, 0)
	line.Position = UDim2.new(0, 0, 0.1, 0)
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BorderSizePixel = 0
	line.Parent = row

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.5, 0, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = statName
	title.TextColor3 = Color3.fromRGB(200, 200, 200)
	title.Font = Enum.Font.Jura
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = row

	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(0.5, 0, 1, 0)
	value.Position = UDim2.new(0.5, 0, 0, 0)
	value.BackgroundTransparency = 1
	value.Text = valueStr
	value.TextColor3 = Color3.fromRGB(100, 255, 100) 
	value.Font = Enum.Font.Jura
	value.TextSize = 18
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.Parent = row
end

CreateStatRow("Cost", "FREE")
CreateStatRow("Win Rate", "0%")
CreateStatRow("Total Kills", "0")
CreateStatRow("Tasks Done", "0")

-- WIDE PERK BOXES
local PerksContainer = Instance.new("Frame")
PerksContainer.Size = UDim2.new(1, -40, 0, 220)
PerksContainer.Position = UDim2.new(0, 20, 0, 380)
PerksContainer.BackgroundTransparency = 1
PerksContainer.Parent = DossierPanel

local PerksLayout = Instance.new("UIListLayout")
PerksLayout.Padding = UDim.new(0, 10)
PerksLayout.Parent = PerksContainer

local function CreatePerkBox(titleText, descText)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 75)
	box.BackgroundColor3 = Color3.fromRGB(30, 10, 10) 
	box.BackgroundTransparency = 0.3
	box.Parent = PerksContainer

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(150, 150, 150)
	stroke.Thickness = 1
	stroke.Parent = box

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 55, 0, 55)
	icon.Position = UDim2.new(0, 10, 0.5, -27.5)
	icon.BackgroundTransparency = 0.5
	icon.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	icon.Parent = box

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -85, 0, 25)
	title.Position = UDim2.new(0, 75, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.Font = Enum.Font.Antique
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = box

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -85, 0, 35)
	desc.Position = UDim2.new(0, 75, 0, 35)
	desc.BackgroundTransparency = 1
	desc.Text = descText
	desc.TextColor3 = Color3.fromRGB(150, 150, 150)
	desc.Font = Enum.Font.Bodoni
	desc.TextSize = 13
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.Parent = box
end

CreatePerkBox("Death Note", "Write names to execute targets after 40s.")
CreatePerkBox("Shinigami Eyes", "Press F to steal identities from a distance.")

-- PURCHASE / EQUIP BUTTON
local EquipBtn = Instance.new("TextButton")
EquipBtn.Size = UDim2.new(0, 200, 0, 50)
EquipBtn.AnchorPoint = Vector2.new(0.5, 0.5)
EquipBtn.Position = UDim2.new(0.5, 0, 1, 0)
EquipBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
EquipBtn.Text = "EQUIP"
EquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EquipBtn.Font = Enum.Font.Jura
EquipBtn.TextSize = 24
EquipBtn.Parent = DossierPanel

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(200, 255, 200)
BtnStroke.Thickness = 2
BtnStroke.Parent = EquipBtn

-- ==========================================
-- 4. CAMERA & WORLD RENDERING LOGIC
-- ==========================================
local clonedCharacter = nil

local function OpenWorldProfile()
	local camPart = workspace:FindFirstChild("ProfileCamera")
	local spawnPart = workspace:FindFirstChild("ProfileCharacterSpawn")

	if camPart and spawnPart then
		-- Lock the camera to the cinematic angle
		Camera.CameraType = Enum.CameraType.Scriptable

		local tween = TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = camPart.CFrame})
		tween:Play()

		-- Clone the player's character into the scene
		if LocalPlayer.Character then
			LocalPlayer.Character.Archivable = true
			clonedCharacter = LocalPlayer.Character:Clone()
			clonedCharacter.Parent = workspace

			-- Anchor the clone so it doesn't fall
			if clonedCharacter:FindFirstChild("HumanoidRootPart") then
				clonedCharacter.HumanoidRootPart.CFrame = spawnPart.CFrame
				clonedCharacter.HumanoidRootPart.Anchored = true
			end

			-- Optional: Play a menacing idle animation
			local animator = clonedCharacter:FindFirstChild("Humanoid") and clonedCharacter.Humanoid:FindFirstChild("Animator")
			if animator then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://81919575092144" -- Default Roblox idle (swap with a custom animation ID later!)
				local track = animator:LoadAnimation(anim)
				track:Play()
			end
		end
	else
		warn("Missing ProfileCamera or ProfileCharacterSpawn in Workspace!")
	end
end

local function CloseWorldProfile()
	-- Return camera to the player
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

	-- Destroy the clone
	if clonedCharacter then
		clonedCharacter:Destroy()
		clonedCharacter = nil
	end
end

-- ==========================================
-- 5. BUTTON TOGGLES
-- ==========================================
local Events = ReplicatedStorage:WaitForChild("Events")
local SyncDataEvent = Events:WaitForChild("SyncDataEvent")

SyncDataEvent.OnClientEvent:Connect(function(coins, gems, inventory, equipped)
	CoinText.Text = tostring(coins)
end)

StoreButton.MouseButton1Click:Connect(function()
	if ProfileContainer.Visible then
		CloseWorldProfile()
	end
	ProfileContainer.Visible = false
	ShopPanel.Visible = not ShopPanel.Visible
	LeftMenuContainer.Visible = not ShopPanel.Visible
end)

ProfileButton.MouseButton1Click:Connect(function()
	ShopPanel.Visible = false
	ProfileContainer.Visible = not ProfileContainer.Visible
	LeftMenuContainer.Visible = not ProfileContainer.Visible

	if ProfileContainer.Visible then
		OpenWorldProfile()
	else
		CloseWorldProfile()
	end
end)