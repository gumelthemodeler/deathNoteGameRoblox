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

		local idCard = Instance.new("Part")
		idCard.Size = Vector3.new(1, 0.2, 1.5)
		idCard.Color = Color3.fromRGB(200, 200, 200)
		idCard.CFrame = chosenSpawn.CFrame
		idCard.Name = "IDCard_" .. data.RealName
		idCard.Parent = workspace

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Collect ID"
		prompt.ObjectText = "Unknown ID Card"
		prompt.HoldDuration = 1.5
		prompt.Parent = idCard

		prompt.Triggered:Connect(function(player)
			local playerData = SessionData.ActivePlayers[player.UserId]
			if not playerData then return end

			if playerData.Role == "Kira" then
				table.insert(playerData.CollectedIDs, data.RealName)
				print("Kira collected the ID for: " .. data.RealName)
			else
				print(player.Name .. " (Task Force) hid an ID card.")
			end
			idCard:Destroy()
		end)
	end
end

_G.DistributeIDCards = DistributeIDCards