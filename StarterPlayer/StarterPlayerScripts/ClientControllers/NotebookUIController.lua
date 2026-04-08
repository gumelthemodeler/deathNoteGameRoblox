-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local WriteNameEvent = Events:WaitForChild("WriteNameEvent")
local UpdateNotebookUI = Events:WaitForChild("UpdateNotebookUI")

local NotebookGui = PlayerGui:WaitForChild("NotebookGui")
local MainBackground = NotebookGui:WaitForChild("MainBackground")
local NameList = MainBackground:WaitForChild("NameList")
local OpenButton = NotebookGui:WaitForChild("OpenNotebookButton")

-- FORCE HIDE UI ON SPAWN
MainBackground.Visible = false
OpenButton.Visible = false 
local notebookOpen = false

OpenButton.MouseButton1Click:Connect(function()
	notebookOpen = not notebookOpen
	MainBackground.Visible = notebookOpen
end)

local function AddNameToNotebook(realName, avatarName)
	OpenButton.Visible = true 

	local NameEntry = Instance.new("TextButton")
	NameEntry.Size = UDim2.new(1, 0, 0, 50)
	NameEntry.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	NameEntry.Font = Enum.Font.Jura
	NameEntry.TextSize = 24
	NameEntry.Text = realName .. " (" .. avatarName .. ")"
	NameEntry.Parent = NameList

	NameEntry.MouseButton1Click:Connect(function()
		print("Writing name: " .. realName)
		WriteNameEvent:FireServer(realName)

		NameEntry.Text = "~~" .. realName .. "~~"
		NameEntry.TextColor3 = Color3.fromRGB(150, 0, 0)
		NameEntry.Interactable = false
	end)

	if not NameList:FindFirstChild("UIListLayout") then
		local layout = Instance.new("UIListLayout")
		layout.Parent = NameList
		layout.Padding = UDim.new(0, 5)
	end
end

UpdateNotebookUI.OnClientEvent:Connect(function(realName, avatarName)
	AddNameToNotebook(realName, avatarName)

	if not notebookOpen then
		notebookOpen = true
		MainBackground.Visible = true
	end
end)