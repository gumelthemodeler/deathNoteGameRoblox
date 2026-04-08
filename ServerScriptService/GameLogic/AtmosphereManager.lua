-- @ScriptType: Script
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Base values
local BASE_BRIGHTNESS = 1.5
local CLOUD_BRIGHTNESS = 0.5 -- How dark it gets when a "cloud" passes over

task.spawn(function()
	while true do
		-- Wait a random amount of time before a cloud passes (30 seconds to 2 minutes)
		task.wait(math.random(30, 120))

		-- A cloud rolls in (Takes 10 seconds to get dark)
		local tweenIn = TweenService:Create(Lighting, TweenInfo.new(10, Enum.EasingStyle.Sine), {Brightness = CLOUD_BRIGHTNESS})
		tweenIn:Play()
		tweenIn.Completed:Wait()

		-- Cloud stays for 15 to 40 seconds
		task.wait(math.random(15, 40))

		-- Cloud rolls out (Takes 15 seconds to return to normal brightness)
		local tweenOut = TweenService:Create(Lighting, TweenInfo.new(15, Enum.EasingStyle.Sine), {Brightness = BASE_BRIGHTNESS})
		tweenOut:Play()
	end
end)