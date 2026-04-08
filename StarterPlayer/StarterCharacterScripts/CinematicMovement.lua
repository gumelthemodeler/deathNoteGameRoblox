-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local rootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")

-- Disable default Roblox rotation so we can strafe properly
Humanoid.AutoRotate = false

-- ==========================================
-- 1. PHYSICS-BASED ROTATION SETUP
-- ==========================================
-- We create a physics constraint to turn the character smoothly WITHOUT clipping
local RootAttachment = Instance.new("Attachment")
RootAttachment.Name = "BodyRotationAttachment"
RootAttachment.Parent = rootPart

local BodyAlign = Instance.new("AlignOrientation")
BodyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
BodyAlign.Attachment0 = RootAttachment
BodyAlign.MaxTorque = 100000 -- Strong enough to turn the character
BodyAlign.Responsiveness = 15 -- High responsiveness for a snappy, smooth turn
BodyAlign.Parent = rootPart

-- ==========================================
-- 2. ANIMATION SETUP
-- ==========================================
local ANIM_IDS = {
	Idle = "rbxassetid://74783453136208", 
	WalkForward = "rbxassetid://100425627626299", 
	WalkBackward = "rbxassetid://82132599313856", 
	WalkLeft = "rbxassetid://83678777739735",     
	WalkRight = "rbxassetid://122697254650056",    
	Sprint = "rbxassetid://110871861652328" 
}

local LoadedAnims = {}
for name, id in pairs(ANIM_IDS) do
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	local track = Animator:LoadAnimation(anim)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action -- Overwrites default animations
	LoadedAnims[name] = track
end

-- Stop any default animations that might already be running
for _, playingTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
	playingTrack:Stop()
end

local CurrentAnim = LoadedAnims.Idle
CurrentAnim:Play()

-- ==========================================
-- 3. AUDIO SETUP (FOOTSTEPS)
-- ==========================================
local FootstepSound = Instance.new("Sound")
FootstepSound.SoundId = "rbxassetid://833562479" 
FootstepSound.Volume = 0.5
FootstepSound.Parent = rootPart

-- ==========================================
-- 4. MOVEMENT & AMBIENCE LOGIC (JITTER PROOF)
-- ==========================================
local bobbingTime = 0
local lastStepTime = 0
local smoothedLocalVelocity = Vector3.zero -- Used to absorb physics jitters

RunService.RenderStepped:Connect(function(deltaTime)
	if not Humanoid or Humanoid.Health <= 0 then return end

	-- 🔄 PHYSICS-LOCKED ROTATION
	local camLook = Camera.CFrame.LookVector
	local flatCamLook = Vector3.new(camLook.X, 0, camLook.Z).Unit

	if flatCamLook.Magnitude > 0 then
		BodyAlign.CFrame = CFrame.lookAt(Vector3.zero, flatCamLook)
	end

	-- 🏃 SMOOTHED MOVEMENT CALCULATIONS
	local velocity = rootPart.AssemblyLinearVelocity
	local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z) 
	local speed = flatVelocity.Magnitude

	local isMoving = speed > 1.5 -- Slightly higher threshold to prevent idle twitching
	local isSprinting = speed > 16

	local targetAnim = LoadedAnims.Idle

	if isMoving then
		if isSprinting then
			targetAnim = LoadedAnims.Sprint
		else
			-- Convert world velocity to local velocity
			local rawLocalVelocity = rootPart.CFrame:VectorToObjectSpace(flatVelocity)

			-- 🔥 THE FIX: Smooth the velocity reading to absorb micro-stutters
			smoothedLocalVelocity = smoothedLocalVelocity:Lerp(rawLocalVelocity, deltaTime * 12)

			-- 🔥 THE FIX: Add a 20% "Deadzone" favoring Forward/Backward movement. 
			-- This stops rapid flickering when walking perfectly diagonally.
			if math.abs(smoothedLocalVelocity.X) > (math.abs(smoothedLocalVelocity.Z) * 1.2) then
				if smoothedLocalVelocity.X > 0 then
					targetAnim = LoadedAnims.WalkRight
				else
					targetAnim = LoadedAnims.WalkLeft
				end
			else
				if smoothedLocalVelocity.Z > 0 then
					targetAnim = LoadedAnims.WalkBackward
				else
					targetAnim = LoadedAnims.WalkForward
				end
			end
		end
	else
		-- Reset smoothing when stopped
		smoothedLocalVelocity = Vector3.zero
	end

	-- 🎬 SMOOTH ANIMATION BLENDING
	if CurrentAnim ~= targetAnim then
		-- Increased crossfade time slightly for a softer transition
		CurrentAnim:Stop(0.3)
		CurrentAnim = targetAnim
		CurrentAnim:Play(0.3)
	end

	-- Adjust playback speed based on velocity
	if isMoving then
		-- Clamp the speed so it doesn't get ridiculously fast or jittery
		local animSpeed = math.clamp(speed / 16, 0.5, 1.5)
		CurrentAnim:AdjustSpeed(animSpeed)
	else
		CurrentAnim:AdjustSpeed(1)
	end

	-- 🎥 CAMERA BOBBING & FOOTSTEPS
	if isMoving and Humanoid.FloorMaterial ~= Enum.Material.Air then
		local bobFrequency = isSprinting and 12 or 8
		local bobIntensity = isSprinting and 0.4 or 0.15

		bobbingTime = bobbingTime + (deltaTime * bobFrequency)

		local bobY = math.sin(bobbingTime) * bobIntensity
		local bobX = math.cos(bobbingTime / 2) * (bobIntensity / 2)

		Camera.CFrame = Camera.CFrame * CFrame.new(bobX, bobY, 0)

		if math.sin(bobbingTime) < -0.8 and (tick() - lastStepTime) > 0.3 then
			lastStepTime = tick()
			FootstepSound.PlaybackSpeed = 0.9 + (math.random() * 0.2)
			FootstepSound.Volume = isSprinting and 0.8 or 0.4
			FootstepSound:Play()
		end
	else
		bobbingTime = 0
	end
end)