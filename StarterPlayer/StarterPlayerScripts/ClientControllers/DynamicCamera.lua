-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local NORMAL_FOV = 70
local SPRINT_FOV = 85
local FOV_TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Wait for character and humanoid
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
end)

-- Monitor walking speed to dynamically shift the camera lens
RunService.RenderStepped:Connect(function()
	if not humanoid or not Camera then return end

	-- If moving fast (sprinting), widen the camera lens for a dramatic speed effect
	if humanoid.MoveDirection.Magnitude > 0 and humanoid.WalkSpeed > 16 then
		if Camera.FieldOfView ~= SPRINT_FOV then
			TweenService:Create(Camera, FOV_TWEEN_INFO, {FieldOfView = SPRINT_FOV}):Play()
		end
		-- Otherwise, return to normal cinematic view
	else
		if Camera.FieldOfView ~= NORMAL_FOV then
			TweenService:Create(Camera, FOV_TWEEN_INFO, {FieldOfView = NORMAL_FOV}):Play()
		end
	end
end)