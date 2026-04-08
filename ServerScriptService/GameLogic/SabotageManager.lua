-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local SessionData = require(ServerScriptService.DataSystems.SessionData)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

-- Create the RemoteEvents safely
local EventsFolder = ReplicatedStorage:WaitForChild("Events")

local TriggerSabotageEvent = Instance.new("RemoteEvent")
TriggerSabotageEvent.Name = "TriggerSabotageEvent"
TriggerSabotageEvent.Parent = EventsFolder

local SabotageEffectEvent = Instance.new("RemoteEvent")
SabotageEffectEvent.Name = "SabotageEffectEvent"
SabotageEffectEvent.Parent = EventsFolder

-- Track cooldowns globally for the match
local lastSabotageTimes = {
	Blackout = 0,
	FakeHeartAttack = 0
}

TriggerSabotageEvent.OnServerEvent:Connect(function(player, sabotageType)
	local pData = SessionData.ActivePlayers[player.UserId]

	-- Security: Only living Kiras can do this
	if not pData or pData.Role ~= "Kira" or not pData.IsAlive then return end

	local currentTime = os.time()
	local cooldown = GameConfig.SabotageCooldowns[sabotageType] or 30

	if currentTime - (lastSabotageTimes[sabotageType] or 0) < cooldown then
		-- Still on cooldown
		return
	end

	lastSabotageTimes[sabotageType] = currentTime
	print("Kira triggered sabotage: " .. sabotageType)

	if sabotageType == "Blackout" then
		-- Save original lighting
		local originalAmbient = Lighting.Ambient
		local originalBrightness = Lighting.Brightness

		-- Plunge map into darkness
		Lighting.Ambient = Color3.fromRGB(5, 5, 5)
		Lighting.Brightness = 0

		-- Restore after 15 seconds
		task.delay(15, function()
			Lighting.Ambient = originalAmbient
			Lighting.Brightness = originalBrightness
		end)

	elseif sabotageType == "FakeHeartAttack" then
		-- Pick a random living Task Force member
		local aliveTF = {}
		for uid, data in pairs(SessionData.ActivePlayers) do
			if data.Role == "TaskForce" and data.IsAlive then
				local tfPlayer = Players:GetPlayerByUserId(uid)
				if tfPlayer then table.insert(aliveTF, tfPlayer) end
			end
		end

		if #aliveTF > 0 then
			local target = aliveTF[math.random(1, #aliveTF)]
			print("Fake heart attack targeted on: " .. target.Name)
			SabotageEffectEvent:FireClient(target, "FakeHeartAttack")
		end
	end
end)