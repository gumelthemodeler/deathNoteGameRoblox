-- @ScriptType: Script
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Set starting time to nighttime
Lighting.ClockTime = 20 -- 8:00 PM

-- How fast time moves. Lower is slower and creepier.
local TIME_SPEED = 0.002 

RunService.Heartbeat:Connect(function(deltaTime)
	-- Slowly increment the time of day
	-- As the moon moves across the sky, global shadows will dynamically shift!
	Lighting.ClockTime = Lighting.ClockTime + (deltaTime * TIME_SPEED)
end)