-- @ScriptType: LocalScript
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create a soft "Studio Light" that follows the player
local StudioLight = Instance.new("PointLight")
StudioLight.Name = "CinematicHighlight"
StudioLight.Color = Color3.fromRGB(220, 230, 255) -- Very pale, cold white
StudioLight.Range = 12 -- Just enough to light up the player and whoever they are talking to
StudioLight.Brightness = 0.35 -- Very subtle!
StudioLight.Shadows = false -- CRITICAL: False. We don't want weird shadows spinning as the camera moves

-- Anchor it to the camera
local LightAnchor = Instance.new("Part")
LightAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
LightAnchor.Transparency = 1
LightAnchor.CanCollide = false
LightAnchor.Anchored = true
LightAnchor.Parent = workspace

StudioLight.Parent = LightAnchor

RunService.RenderStepped:Connect(function()
	if Camera then
		-- Position the light slightly above and behind the camera 
		-- This mimics a professional 3-point lighting setup, giving the character a "rim light"
		LightAnchor.CFrame = Camera.CFrame * CFrame.new(0, 3, 2)
	end
end)