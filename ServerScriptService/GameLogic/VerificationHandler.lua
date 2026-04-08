-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SessionData = require(ServerScriptService.DataSystems.SessionData)

-- Change lines 4 and 5 to this:
local VerifyEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("VerifyPlayerEvent")
local UpdateNotebookUI = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateNotebookUI")

VerifyEvent.OnServerEvent:Connect(function(player, targetPlayer)
	local kiraData = SessionData.ActivePlayers[player.UserId]
	local targetData = SessionData.ActivePlayers[targetPlayer.UserId]

	if not kiraData or kiraData.Role ~= "Kira" then return end
	if not targetData then return end

	local targetRealName = targetData.RealName
	local hasID = false

	for _, nameInInventory in ipairs(kiraData.CollectedIDs) do
		if nameInInventory == targetRealName then
			hasID = true
			break
		end
	end

	if hasID then
		if not targetData.IsVerifiedByKira then
			targetData.IsVerifiedByKira = true
			print("SUCCESS! Kira linked avatar " .. targetPlayer.Name .. " to " .. targetRealName)
			UpdateNotebookUI:FireClient(player, targetRealName, targetPlayer.Name)
		end
	else
		print("Kira tried to verify " .. targetPlayer.Name .. " but lacks their ID card.")
	end
end)