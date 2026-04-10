-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. GRAB THE PHYSICAL UI ELEMENTS
-- ==========================================
local MainGui = PlayerGui:WaitForChild("Main")

-- Main Menu Elements
local MainFrame = MainGui:WaitForChild("Frame")
local ProfileButton = MainFrame:WaitForChild("ProfileButton")
local ShopButton = MainFrame:WaitForChild("ShopButton")
local SpectateButton = MainFrame:WaitForChild("SpectateButton")
local SettingsButton = MainFrame:WaitForChild("SettingsButton")
local CurrencyLabel = MainFrame:WaitForChild("currencyLabel")
local CurrencyValue = CurrencyLabel:WaitForChild("currencyValue")

-- Profile Dossier Elements
local ProfileFrame = MainGui:WaitForChild("ProfileFrame")
local StatsFolder = ProfileFrame:WaitForChild("Stats")

-- 🛑 NEW: The Gothic Text Elements
local UsernameLabel = ProfileFrame:WaitForChild("UsernameLabel")
local TextReturnButton = ProfileFrame:WaitForChild("TextReturnButton")

-- Set the Username automatically
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.Shadow.Text = LocalPlayer.Name -- Updates the shadow text to match!

-- Ensure Profile is hidden when the game starts
ProfileFrame.Visible = false

-- ==========================================
-- 2. HOVER ANIMATIONS
-- ==========================================
local function AddImageHoverEffect(button)
	local originalSize = button.Size
	local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 8, originalSize.Y.Scale, originalSize.Y.Offset + 8)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {Size = hoverSize}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {Size = originalSize}):Play()
	end)
end

-- Image Button Hovers
AddImageHoverEffect(ProfileButton)
AddImageHoverEffect(ShopButton)
AddImageHoverEffect(SpectateButton)
AddImageHoverEffect(SettingsButton)

-- 🩸 NEW: Text Button Hover (Color Fade instead of Size Growth)
TextReturnButton.MouseEnter:Connect(function()
	TweenService:Create(TextReturnButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 50, 50)}):Play()
end)
TextReturnButton.MouseLeave:Connect(function()
	TweenService:Create(TextReturnButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
end)

-- ==========================================
-- 3. CINEMATIC CAMERA LOGIC
-- ==========================================
local clonedCharacter = nil

local function OpenWorldProfile()
	local camPart = workspace:FindFirstChild("ProfileCamera")
	local spawnPart = workspace:FindFirstChild("ProfileCharacterSpawn")

	if camPart and spawnPart then
		Camera.CameraType = Enum.CameraType.Scriptable
		TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = camPart.CFrame}):Play()

		if LocalPlayer.Character then
			LocalPlayer.Character.Archivable = true
			clonedCharacter = LocalPlayer.Character:Clone()
			clonedCharacter.Parent = workspace

			if clonedCharacter:FindFirstChild("HumanoidRootPart") then
				clonedCharacter.HumanoidRootPart.CFrame = spawnPart.CFrame
				clonedCharacter.HumanoidRootPart.Anchored = true
			end

			local animator = clonedCharacter:FindFirstChild("Humanoid") and clonedCharacter.Humanoid:FindFirstChild("Animator")
			if animator then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://81919575092144" 
				local track = animator:LoadAnimation(anim)
				track:Play()
			end
		end
	end
end

local function CloseWorldProfile()
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

	if clonedCharacter then
		clonedCharacter:Destroy()
		clonedCharacter = nil
	end
end

-- ==========================================
-- 4. BUTTON CLICKS
-- ==========================================
ProfileButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	ProfileFrame.Visible = true
	OpenWorldProfile()
end)

TextReturnButton.MouseButton1Click:Connect(function()
	ProfileFrame.Visible = false
	MainFrame.Visible = true
	CloseWorldProfile()
end)

ShopButton.MouseButton1Click:Connect(function()
	print("Shop Button Clicked")
end)

-- ==========================================
-- 5. SERVER DATA SYNC
-- ==========================================
local Events = ReplicatedStorage:WaitForChild("Events")
local SyncDataEvent = Events:WaitForChild("SyncDataEvent")

-- Listens for the Server to send the stats over
SyncDataEvent.OnClientEvent:Connect(function(coins, gems, inventory, equipped, level, stats)
	CurrencyValue.Text = tostring(coins)

	if stats then
		-- We concatenate the title and the number so it doesn't just show a floating "0"
		-- You can add or remove spaces here to make it align perfectly in your UI!
		StatsFolder.PlayerLevel.Text = "Player Level        " .. tostring(level)
		StatsFolder.KiraWins.Text = "Kira Wins           " .. tostring(stats.WinsAsKira)
		StatsFolder.LWins.Text = "L Wins              " .. tostring(stats.WinsAsTaskForce)
		StatsFolder.TotalKills.Text = "Total Kills         " .. tostring(stats.TotalKills)
		StatsFolder.TasksDone.Text = "Tasks Done          " .. tostring(stats.TasksCompleted)

		local totalGames = stats.WinsAsKira + stats.WinsAsTaskForce
		local winPercent = totalGames > 0 and math.floor((totalGames / (totalGames + stats.TimesArrested)) * 100) or 0
		StatsFolder.WinPercent.Text = "Win %               " .. tostring(winPercent) .. "%"
	end
end)

-- 🔥 THE FIX: Request the data from the Server as soon as the UI loads!
SyncDataEvent:FireServer()