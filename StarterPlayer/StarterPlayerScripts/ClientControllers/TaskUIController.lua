-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TaskGui = PlayerGui:WaitForChild("TaskGui")
local TaskBarFill = TaskGui:WaitForChild("TaskBarBackground"):WaitForChild("TaskBarFill")

local UpdateTaskProgressEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateTaskProgressEvent")

-- Let's say there are 20 tasks total required to win/expose Kira
local TOTAL_TASKS_REQUIRED = 20

-- Initialize bar at 0
TaskBarFill.Size = UDim2.new(0, 0, 1, 0)

UpdateTaskProgressEvent.OnClientEvent:Connect(function(currentTasksCompleted)
	-- Calculate the percentage
	local percentage = math.clamp(currentTasksCompleted / TOTAL_TASKS_REQUIRED, 0, 1)

	-- Smoothly tween the progress bar so it looks polished
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(TaskBarFill, tweenInfo, {Size = UDim2.new(percentage, 0, 1, 0)})
	tween:Play()

	if currentTasksCompleted >= TOTAL_TASKS_REQUIRED then
		print("Task Force completed all tasks! Exposing Kira...")
		-- The server should handle the actual win condition, this just logs it for the client
	end
end)