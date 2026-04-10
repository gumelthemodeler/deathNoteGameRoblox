-- @ScriptType: LocalScript
-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local ShowPlayerVoting = Events:WaitForChild("ShowPlayerVoting")
local SubmitPlayerVote = Events:WaitForChild("SubmitPlayerVote")

-- ==========================================
-- 1. BUILD THE UI (Auto-Generation)
-- ==========================================
if PlayerGui:FindFirstChild("MeetingGui") then
	PlayerGui.MeetingGui:Destroy()
end

local MeetingGui = Instance.new("ScreenGui")
MeetingGui.Name = "MeetingGui"
MeetingGui.ResetOnSpawn = false
MeetingGui.IgnoreGuiInset = true
MeetingGui.Parent = PlayerGui

-- Dark Overlay background
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Overlay.BackgroundTransparency = 1 -- Starts hidden
Overlay.Visible = false
Overlay.Parent = MeetingGui

-- The Main Tablet Frame
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 600, 0, 500)
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.Position = UDim2.new(0.5, 0, 0.5, 50) -- Starts slightly lower for a pop-up animation
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
MainPanel.BackgroundTransparency = 1
MainPanel.Parent = Overlay

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(150, 20, 20)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 1
PanelStroke.Parent = MainPanel

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, 0, 0, 50)
HeaderTitle.Position = UDim2.new(0, 0, 0, 10)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "INTERSECTION: CAST YOUR VOTE"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
HeaderTitle.Font = Enum.Font.Antique
HeaderTitle.TextSize = 32
HeaderTitle.TextTransparency = 1
HeaderTitle.Parent = MainPanel

local ReasonLabel = Instance.new("TextLabel")
ReasonLabel.Size = UDim2.new(1, 0, 0, 30)
ReasonLabel.Position = UDim2.new(0, 0, 0, 50)
ReasonLabel.BackgroundTransparency = 1
ReasonLabel.Text = "A body was discovered..."
ReasonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ReasonLabel.Font = Enum.Font.Jura
ReasonLabel.TextSize = 18
ReasonLabel.TextTransparency = 1
ReasonLabel.Parent = MainPanel

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(1, -40, 1, -160)
PlayerListScroll.Position = UDim2.new(0, 20, 0, 90)
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
PlayerListScroll.ScrollBarThickness = 4
PlayerListScroll.Parent = MainPanel

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Parent = PlayerListScroll

local hasVoted = false

-- ==========================================
-- 2. DYNAMIC BUTTON GENERATOR
-- ==========================================
local function ClearPlayerList()
	for _, child in ipairs(PlayerListScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
end

local function CreateVoteButton(displayName, targetId, isSkip)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 50)
	btn.BackgroundColor3 = isSkip and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 10, 10)
	btn.BackgroundTransparency = 0.2
	btn.Text = ""
	btn.Parent = PlayerListScroll

	local stroke = Instance.new("UIStroke")
	stroke.Color = isSkip and Color3.fromRGB(100, 100, 150) or Color3.fromRGB(100, 30, 30)
	stroke.Parent = btn

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 1, 0)
	nameLabel.Position = UDim2.new(0, 20, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = displayName
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameLabel.Font = Enum.Font.Jura
	nameLabel.TextSize = 22
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	if isSkip then nameLabel.TextXAlignment = Enum.TextXAlignment.Center end
	nameLabel.Parent = btn

	-- Hover & Click Logic
	btn.MouseEnter:Connect(function()
		if not hasVoted then stroke.Thickness = 2 end
	end)
	btn.MouseLeave:Connect(function()
		if not hasVoted then stroke.Thickness = 1 end
	end)

	btn.MouseButton1Click:Connect(function()
		if hasVoted then return end
		hasVoted = true

		-- Visual feedback that you locked in your vote
		stroke.Color = Color3.fromRGB(255, 0, 0)
		stroke.Thickness = 3
		nameLabel.Text = displayName .. " (VOTED)"
		nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

		-- Dim all other buttons
		for _, otherBtn in ipairs(PlayerListScroll:GetChildren()) do
			if otherBtn:IsA("TextButton") and otherBtn ~= btn then
				otherBtn.BackgroundTransparency = 0.8
				otherBtn:FindFirstChild("TextLabel").TextTransparency = 0.6
				otherBtn:FindFirstChild("UIStroke").Transparency = 0.8
			end
		end

		-- Send the vote to the server
		SubmitPlayerVote:FireServer(targetId)
	end)
end

-- ==========================================
-- 3. ANIMATION & EVENT HANDLING
-- ==========================================
local function FadeUI(visible)
	local targetTrans = visible and 0 or 1
	local targetOverlayTrans = visible and 0.4 or 1
	local targetPos = visible and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 50)

	if visible then Overlay.Visible = true end

	TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = targetOverlayTrans}):Play()
	TweenService:Create(MainPanel, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		BackgroundTransparency = targetTrans,
		Position = targetPos
	}):Play()

	TweenService:Create(PanelStroke, TweenInfo.new(0.5), {Transparency = targetTrans}):Play()
	TweenService:Create(HeaderTitle, TweenInfo.new(0.5), {TextTransparency = targetTrans}):Play()
	TweenService:Create(ReasonLabel, TweenInfo.new(0.5), {TextTransparency = targetTrans}):Play()

	if not visible then
		task.delay(0.5, function() Overlay.Visible = false end)
	end
end

ShowPlayerVoting.OnClientEvent:Connect(function(isVisible, reason, activePlayers)
	if isVisible then
		hasVoted = false
		ReasonLabel.Text = string.upper(reason)
		ClearPlayerList()

		-- Generate a button for every ALIVE player using their Anime Name
		for userIdStr, data in pairs(activePlayers) do
			if data.IsAlive then
				-- Remote events convert numeric dictionary keys to strings, so we convert it back
				local actualUserId = tonumber(userIdStr) or userIdStr 

				-- Add a little "(YOU)" indicator so the player knows which name is theirs
				local displayName = data.RealName
				if actualUserId == LocalPlayer.UserId then
					displayName = displayName .. " (YOU)"
				end

				CreateVoteButton(displayName, actualUserId, false)
			end
		end

		-- Always add the Skip button
		CreateVoteButton("SKIP VOTE", "Skip", true)

		FadeUI(true)
	else
		FadeUI(false)
	end
end)