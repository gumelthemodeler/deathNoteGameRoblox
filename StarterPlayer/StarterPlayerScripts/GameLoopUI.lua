-- @ScriptType: LocalScript
-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateTimer = Events:WaitForChild("UpdateTimer")
local ShowVoting = Events:WaitForChild("ShowVoting")
local VoteGamemode = Events:WaitForChild("VoteGamemode")
local UpdateGamemodeVotes = Events:WaitForChild("UpdateGamemodeVotes")

local function ApplyGothicStyle(frame, transparency)
	frame.BackgroundColor3 = Color3.fromRGB(20, 5, 5) 
	frame.BackgroundTransparency = transparency or 0.3
	frame.BorderSizePixel = 0

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(255, 30, 30) 
	innerStroke.Thickness = 1 
	innerStroke.Parent = frame
end

if PlayerGui:FindFirstChild("RoundGui") then PlayerGui.RoundGui:Destroy() end

local RoundGui = Instance.new("ScreenGui")
RoundGui.Name = "RoundGui"
RoundGui.ResetOnSpawn = false
RoundGui.Parent = PlayerGui

-- ==========================================
-- 1. TOP BAR TIMER
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 300, 0, 70)
TopBar.AnchorPoint = Vector2.new(0.5, 0)
TopBar.Position = UDim2.new(0.5, 0, 0, 20)
TopBar.BackgroundTransparency = 1
TopBar.Parent = RoundGui

local StateLabel = Instance.new("TextLabel")
StateLabel.Size = UDim2.new(1, 0, 0, 25)
StateLabel.BackgroundTransparency = 1
StateLabel.Text = "WAITING FOR PLAYERS"
StateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StateLabel.Font = Enum.Font.Jura
StateLabel.TextSize = 20
StateLabel.Parent = TopBar

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(1, 0, 1, -25)
TimeLabel.Position = UDim2.new(0, 0, 0, 25)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "--:--"
TimeLabel.TextColor3 = Color3.fromRGB(255, 40, 40) 
TimeLabel.Font = Enum.Font.Antique
TimeLabel.TextSize = 48
TimeLabel.Parent = TopBar

local TimerStroke = Instance.new("UIStroke")
TimerStroke.Color = Color3.fromRGB(20, 5, 5)
TimerStroke.Thickness = 2
TimerStroke.Parent = TimeLabel

-- ==========================================
-- 2. VOTING POPUP (With Avatar Support)
-- ==========================================
local VotingPanel = Instance.new("Frame")
VotingPanel.Size = UDim2.new(0, 640, 0, 400)
VotingPanel.AnchorPoint = Vector2.new(0.5, 0.5)
VotingPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
ApplyGothicStyle(VotingPanel, 0.15)
VotingPanel.Visible = false
VotingPanel.Parent = RoundGui

local VotingTitle = Instance.new("TextLabel")
VotingTitle.Size = UDim2.new(1, 0, 0, 60)
VotingTitle.BackgroundTransparency = 1
VotingTitle.Text = "SELECT GAMEMODE"
VotingTitle.TextColor3 = Color3.fromRGB(255, 40, 40)
VotingTitle.Font = Enum.Font.Antique
VotingTitle.TextSize = 36
VotingTitle.Parent = VotingPanel

local OptionsContainer = Instance.new("Frame")
OptionsContainer.Size = UDim2.new(1, -40, 1, -80)
OptionsContainer.Position = UDim2.new(0, 20, 0, 60)
OptionsContainer.BackgroundTransparency = 1
OptionsContainer.Parent = VotingPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 20)
UIListLayout.Parent = OptionsContainer

-- A table to store the avatar containers for each mode
local modeAvatarContainers = {}

local function CreateGamemodeCard(name, desc)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(0, 280, 1, -20)
	ApplyGothicStyle(card, 0.4)
	card.Text = ""
	card.Parent = OptionsContainer

	-- Container for the floating player heads
	local avatarContainer = Instance.new("Frame")
	avatarContainer.Size = UDim2.new(1, 0, 0, 40)
	avatarContainer.Position = UDim2.new(0, 0, 0, -50) -- Floats exactly above the card
	avatarContainer.BackgroundTransparency = 1
	avatarContainer.Parent = card

	local avatarLayout = Instance.new("UIListLayout")
	avatarLayout.FillDirection = Enum.FillDirection.Horizontal
	avatarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	avatarLayout.Padding = UDim.new(0, 5)
	avatarLayout.Parent = avatarContainer

	modeAvatarContainers[name] = avatarContainer

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = name
	title.TextColor3 = Color3.fromRGB(255, 50, 50)
	title.Font = Enum.Font.Antique
	title.TextSize = 28
	title.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 100)
	descLabel.Position = UDim2.new(0, 10, 0, 70)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.Font = Enum.Font.Bodoni
	descLabel.TextSize = 16
	descLabel.TextWrapped = true
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = card

	-- Interaction
	local clickSound = Instance.new("Sound")
	clickSound.SoundId = "rbxassetid://6895058988" -- Soft click
	clickSound.Volume = 0.5
	clickSound.Parent = card

	card.MouseButton1Click:Connect(function()
		clickSound:Play()
		VoteGamemode:FireServer(name)
	end)

	card.MouseEnter:Connect(function()
		TweenService:Create(card:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {Thickness = 2, Color = Color3.fromRGB(255,100,100)}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {Thickness = 1, Color = Color3.fromRGB(255,30,30)}):Play()
	end)
end

CreateGamemodeCard("CLASSIC", "1 Kira vs Task Force. Find the notebook or survive the night.")
CreateGamemodeCard("TWO KIRAS", "2 Kiras vs Task Force. Double the danger, double the deception.")

-- ==========================================
-- 3. NETWORK HOOKS & UPDATES
-- ==========================================
UpdateTimer.OnClientEvent:Connect(function(stateText, timeString)
	StateLabel.Text = stateText
	TimeLabel.Text = timeString
end)

ShowVoting.OnClientEvent:Connect(function(isVisible)
	VotingPanel.Visible = isVisible
end)

UpdateGamemodeVotes.OnClientEvent:Connect(function(votesData)
	-- First, clear out all old avatars from every card
	for _, container in pairs(modeAvatarContainers) do
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("ImageLabel") then child:Destroy() end
		end
	end

	-- Then, generate the new avatars based on the server data
	for userId, votedMode in pairs(votesData) do
		local targetContainer = modeAvatarContainers[votedMode]

		if targetContainer then
			-- We wrap the image fetch in a task.spawn so it doesn't freeze the UI while loading
			task.spawn(function()
				local thumbType = Enum.ThumbnailType.HeadShot
				local thumbSize = Enum.ThumbnailSize.Size48x48
				local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

				if isReady then
					local avatarIcon = Instance.new("ImageLabel")
					avatarIcon.Size = UDim2.new(0, 40, 0, 40)
					avatarIcon.Image = content
					avatarIcon.BackgroundTransparency = 1
					avatarIcon.Parent = targetContainer

					-- Make the avatar perfectly circular
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(1, 0)
					corner.Parent = avatarIcon

					-- Give the avatar a red border so it matches the theme
					local stroke = Instance.new("UIStroke")
					stroke.Color = Color3.fromRGB(255, 50, 50)
					stroke.Thickness = 2
					stroke.Parent = avatarIcon
				end
			end)
		end
	end
end)