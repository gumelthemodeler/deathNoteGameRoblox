-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local Events = ReplicatedStorage:WaitForChild("Events")
local TriggerPerkEvent = Instance.new("RemoteEvent")
TriggerPerkEvent.Name = "TriggerPerkEvent"
TriggerPerkEvent.Parent = Events

-- Cooldown Tracker [UserId][PerkName] = Time
local activeCooldowns = {}

-- A table of functions for every perk in the game!
local PerkLogic = {

	-- ⚡ TASER COMBAT (Civilian General Perk)
	["Taser"] = function(player, targetPlayer, chargeLevel)
		local targetData = SessionData.ActivePlayers[targetPlayer.UserId]
		if not targetData or not targetData.IsAlive then return end

		local targetCharacter = targetPlayer.Character
		local humanoid = targetCharacter and targetCharacter:FindFirstChild("Humanoid")
		if not humanoid then return end

		print(player.Name .. " shot " .. targetPlayer.Name .. " with a Taser! Charge: " .. tostring(chargeLevel))

		-- Apply Debuffs based on charge time
		if chargeLevel == "Tap" then
			humanoid.WalkSpeed = 8 -- Slowness
			task.delay(3, function() if humanoid then humanoid.WalkSpeed = 16 end end)
		elseif chargeLevel == "Charged" then
			humanoid.WalkSpeed = 4 -- Heavy Daze
			-- In the future, we can fire a client event here to blur their screen (Confusion)
			-- and set a flag in SessionData that blocks Kira from using sabotages (Silence)
			task.delay(5, function() if humanoid then humanoid.WalkSpeed = 16 end end)
		end
	end,

	-- 🚪 HEAVY LOCKDOWN (Mello Role Perk)
	["Lockdown"] = function(player)
		print(player.Name .. " initiated a facility Lockdown!")

		-- Find all doors tagged as "SecurityDoor" and close them
		for _, door in ipairs(workspace:GetDescendants()) do
			if door.Name == "SecurityDoor" and door:IsA("BasePart") then
				-- Slide door down/closed
				door.CFrame = door.CFrame * CFrame.new(0, -10, 0) 
				door.CanCollide = true

				-- Re-open after 10 seconds
				task.delay(10, function()
					door.CFrame = door.CFrame * CFrame.new(0, 10, 0)
					door.CanCollide = false
				end)
			end
		end
	end,
}

TriggerPerkEvent.OnServerEvent:Connect(function(player, perkName, targetArg, extraArg)
	local pData = SessionData.ActivePlayers[player.UserId]
	if not pData or not pData.IsAlive then return end

	-- Anti-Spam Cooldown Check
	if not activeCooldowns[player.UserId] then activeCooldowns[player.UserId] = {} end
	local lastUsed = activeCooldowns[player.UserId][perkName] or 0

	-- Default 30s cooldown for all perks for testing
	if os.clock() - lastUsed < 30 then 
		return 
	end

	-- Run the perk logic if it exists
	if PerkLogic[perkName] then
		activeCooldowns[player.UserId][perkName] = os.clock()
		PerkLogic[perkName](player, targetArg, extraArg)
	end
end)