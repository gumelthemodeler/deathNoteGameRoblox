-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

local SpawnPoints = workspace:WaitForChild("IDSpawnPoints"):GetChildren()

local function DistributeIDCards()
	local availableSpawns = table.clone(SpawnPoints)

	for userId, data in pairs(SessionData.ActivePlayers) do
		if #availableSpawns == 0 then break end

		local spawnIndex = math.random(1, #availableSpawns)
		local chosenSpawn = table.remove(availableSpawns, spawnIndex)

		-- Create the physical ID
		local idCard = Instance.new("Part")
		idCard.Size = Vector3.new(1, 0.2, 1.5)
		idCard.Color = Color3.fromRGB(200, 150, 100) -- Manilla Folder Color
		idCard.CFrame = chosenSpawn.CFrame
		idCard.Name = "IDCard_" .. data.RealName
		idCard.Parent = workspace

		-- The 3-Second Vulnerable Pickup Prompt
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Inspect Evidence"
		prompt.ObjectText = "Dropped ID"
		prompt.HoldDuration = 3 -- 🔥 Kira must stand still for 3 seconds!
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.Parent = idCard

		prompt.Triggered:Connect(function(player)
			local pData = SessionData.ActivePlayers[player.UserId]
			if not pData or not pData.IsAlive then return end

			if pData.Role == "Kira" then
				-- KIRA STEALS THE ID
				table.insert(pData.CollectedIDs, data.RealName)
				print("[SERVER] Kira successfully stole the ID for: " .. data.RealName)

				-- Destroy it so Kira knows they got it (and Civilians notice it's missing)
				idCard:Destroy()
			else
				-- CIVILIAN TRIES TO GRAB IT (DENIED)
				-- Civilians cannot move the IDs. They just have to leave them there.
				print("[SERVER] " .. player.Name .. " (Civilian) tried to grab an ID. Denied.")
			end
		end)
	end
end

_G.DistributeIDCards = DistributeIDCards