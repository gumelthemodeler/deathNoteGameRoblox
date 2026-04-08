-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VerifyEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("VerifyPlayerEvent")

-- UI Elements
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FocusGui = PlayerGui:WaitForChild("FocusGui")
local FocusBackground = FocusGui:WaitForChild("FocusBackground")
local FocusFill = FocusBackground:WaitForChild("FocusFill")

local isFocusing = false
local focusTarget = nil
local focusTime = 0
local REQUIRED_TIME = 3.0 -- Seconds to steal ID

local function ResetFocus()
	focusTime = 0
	focusTarget = nil
	FocusBackground.Visible = false
	FocusFill.Size = UDim2.new(0, 0, 1, 0)
end

-- Toggle Focus Mode with 'F'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then 
		isFocusing = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		isFocusing = false
		ResetFocus()
	end
end)

-- The Stalking Raycast Loop
RunService.RenderStepped:Connect(function(dt)
	if not isFocusing then return end

	-- Raycast out from the camera
	local rayOrigin = Camera.CFrame.Position
	local rayDirection = Camera.CFrame.LookVector * 50 -- 50 studs range

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if result and result.Instance then
		local character = result.Instance:FindFirstAncestorOfClass("Model")
		local targetPlayer = Players:GetPlayerFromCharacter(character)

		if targetPlayer and targetPlayer ~= LocalPlayer then
			if focusTarget ~= targetPlayer then
				focusTarget = targetPlayer
				focusTime = 0 -- Reset timer if they look at someone new
			end

			-- Only fill bar if they are looking at the same person
			focusTime += dt
			FocusBackground.Visible = true

			-- Smoothly update the UI bar
			local fillPercentage = math.clamp(focusTime / REQUIRED_TIME, 0, 1)
			FocusFill.Size = UDim2.new(fillPercentage, 0, 1, 0)

			if focusTime >= REQUIRED_TIME then
				print("Captured Identity for: " .. targetPlayer.Name)
				VerifyEvent:FireServer(targetPlayer) -- Send to Server!

				-- Flash the bar green/white to show success, then reset
				FocusFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
				task.wait(0.2)
				FocusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				isFocusing = false
				ResetFocus()
			end
		else
			ResetFocus()
		end
	else
		ResetFocus()
	end
end)