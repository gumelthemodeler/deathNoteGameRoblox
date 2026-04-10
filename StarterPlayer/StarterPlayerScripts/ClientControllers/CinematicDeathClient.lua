-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Events = ReplicatedStorage:WaitForChild("Events")
local PlayDeathEffectEvent = Events:WaitForChild("PlayDeathEffectEvent")

PlayDeathEffectEvent.OnClientEvent:Connect(function(victimPlayer, effectName)
	local character = victimPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart
	local humanoid = character:FindFirstChild("Humanoid")

	if effectName == "HeartAttack" then
		-- Classic Death Note style
		if humanoid then
			humanoid.WalkSpeed = 0 -- Stop them from running
			-- You could load a clutching chest animation here!
		end

	elseif effectName == "ShadowHands" then
		-- Premium Effect: Black hands drag them down
		if humanoid then humanoid.WalkSpeed = 0 end

		local shadowHole = Instance.new("Part")
		shadowHole.Size = Vector3.new(6, 0.1, 6)
		shadowHole.Color = Color3.new(0, 0, 0)
		shadowHole.Material = Enum.Material.Neon
		shadowHole.CanCollide = false
		shadowHole.Anchored = true
		shadowHole.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
		shadowHole.Parent = workspace

		-- Sink the player into the floor
		local sinkTween = TweenService:Create(rootPart, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {CFrame = rootPart.CFrame * CFrame.new(0, -5, 0)})
		sinkTween:Play()

		Debris:AddItem(shadowHole, 2)

	elseif effectName == "Lightning" then
		-- Premium Effect: Sudden smite
		local strike = Instance.new("Part")
		strike.Size = Vector3.new(2, 100, 2)
		strike.Color = Color3.new(0.5, 0.8, 1)
		strike.Material = Enum.Material.Neon
		strike.Anchored = true
		strike.CanCollide = false
		strike.CFrame = rootPart.CFrame * CFrame.new(0, 50, 0)
		strike.Parent = workspace

		local boom = Instance.new("Sound")
		boom.SoundId = "rbxassetid://142070127" -- Thunder crash
		boom.Volume = 3
		boom.Parent = rootPart
		boom:Play()

		-- Fade out the lightning bolt quickly
		local fade = TweenService:Create(strike, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0, 100, 0)})
		fade:Play()

		Debris:AddItem(strike, 1)
	end
end)