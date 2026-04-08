-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- FIXED PATH: Look inside the Events folder!
local Events = ReplicatedStorage:WaitForChild("Events")
local SubmitVoteEvent = Events:WaitForChild("SubmitVoteEvent")
local StartMeetingEvent = Events:WaitForChild("StartMeetingEvent") 

local VotingGui = PlayerGui:WaitForChild("VotingGui")
local VotingPanel = VotingGui:WaitForChild("VotingPanel")
local PlayerList = VotingPanel:WaitForChild("PlayerList")
local SkipButton = VotingPanel:WaitForChild("SkipVoteButton")

-- FORCE HIDE UI ON SPAWN
VotingPanel.Visible = false
local hasVoted = false

local function OpenVotingMenu(activePlayersData)
	hasVoted = false
	VotingPanel.Visible = true

	for _, child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for userIdStr, data in pairs(activePlayersData) do
		local userId = tonumber(userIdStr)
		local player = Players:GetPlayerByUserId(userId)

		if player and data.IsAlive then
			local VoteBtn = Instance.new("TextButton")
			VoteBtn.Size = UDim2.new(1, 0, 0, 40)
			VoteBtn.Text = player.Name
			VoteBtn.Parent = PlayerList

			VoteBtn.MouseButton1Click:Connect(function()
				if not hasVoted then
					hasVoted = true
					SubmitVoteEvent:FireServer(userId)

					VoteBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
					VoteBtn.Text = player.Name .. " (VOTED)"

					task.wait(1)
					VotingPanel.Visible = false
				end
			end)
		end
	end

	if not PlayerList:FindFirstChild("UIListLayout") then
		local layout = Instance.new("UIListLayout")
		layout.Parent = PlayerList
		layout.Padding = UDim.new(0, 5)
	end
end

SkipButton.MouseButton1Click:Connect(function()
	if not hasVoted then
		hasVoted = true
		SubmitVoteEvent:FireServer(0)
		VotingPanel.Visible = false
	end
end)

StartMeetingEvent.OnClientEvent:Connect(OpenVotingMenu)