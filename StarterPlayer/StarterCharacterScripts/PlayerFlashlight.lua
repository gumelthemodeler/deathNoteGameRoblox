-- @ScriptType: LocalScript
local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Create a dynamic spotlight on the player
local Flashlight = Instance.new("SpotLight")
Flashlight.Name = "DynamicFlashlight"
Flashlight.Brightness = 1.5
Flashlight.Range = 45
Flashlight.Angle = 60
Flashlight.Color = Color3.fromRGB(240, 240, 255) -- Cold LED white
Flashlight.Shadows = true -- 🔥 CRITICAL: This makes the light cast shadows off objects!
Flashlight.Parent = rootPart