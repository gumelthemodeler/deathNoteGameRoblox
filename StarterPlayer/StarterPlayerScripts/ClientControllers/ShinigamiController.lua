-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local SyncRoleEvent = Events:WaitForChild("SyncRoleEvent")
local ShinigamiModels = ReplicatedStorage:WaitForChild("ShinigamiModels")

local activeShinigami = nil

-- Function to clean up the Shinigami when a round ends or they are arrested
local function RemoveShinigami()
	if activeShinigami then
		activeShinigami:Destroy()
		activeShinigami = nil
	end
end

SyncRoleEvent.OnClientEvent:Connect(function(role, realName, equippedShinigamiName)
	RemoveShinigami()

	if role == "Kira" then
		local modelTemplate = ShinigamiModels:FindFirstChild(equippedShinigamiName)

		if modelTemplate and modelTemplate.PrimaryPart then
			activeShinigami = modelTemplate:Clone()
			activeShinigami.Parent = workspace
			print("Spawned local Shinigami companion: " .. equippedShinigamiName)
		else
			warn("Missing Shinigami model or PrimaryPart for: " .. tostring(equippedShinigamiName))
		end
	end
end)

-- The Floating Animation Loop
RunService.RenderStepped:Connect(function(deltaTime)
	if not activeShinigami then return end

	local character = LocalPlayer.Character
	if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid").Health > 0 then
		local rootPart = character.HumanoidRootPart

		-- Position the Shinigami 3 studs to the right, 4 studs up, and 4 studs behind the player
		local targetCFrame = rootPart.CFrame * CFrame.new(3, 4, 4)

		-- Make it slowly bob up and down based on the current time
		local bobbingOffset = math.sin(os.clock() * 2) * 0.5 
		targetCFrame = targetCFrame * CFrame.new(0, bobbingOffset, 0)

		-- Smoothly glide the Shinigami to the target position
		local currentCFrame = activeShinigami.PrimaryPart.CFrame
		local smoothCFrame = currentCFrame:Lerp(targetCFrame, 5 * deltaTime)

		activeShinigami:SetPrimaryPartCFrame(smoothCFrame)
	else
		-- If the player dies, hide the Shinigami
		RemoveShinigami()
	end
end)