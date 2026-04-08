-- @ScriptType: LocalScript
local Players = game:GetService("Players")

-- The aesthetic properties of your highlight
local HIGHLIGHT_FILL_COLOR = Color3.fromRGB(200, 210, 255) -- Cold pale blue
local HIGHLIGHT_OUTLINE_COLOR = Color3.fromRGB(255, 255, 255) -- Pure white rim
local FILL_TRANSPARENCY = 0.9 -- Mostly invisible body glow
local OUTLINE_TRANSPARENCY = 0.6 -- Faint, subtle outline

local function ApplyHighlight(character)
	-- Don't double-highlight if one already exists
	if character:FindFirstChild("CinematicHighlight") then return end

	-- Wait for the character to fully load
	character:WaitForChild("HumanoidRootPart", 5)

	local highlight = Instance.new("Highlight")
	highlight.Name = "CinematicHighlight"
	highlight.FillColor = HIGHLIGHT_FILL_COLOR
	highlight.OutlineColor = HIGHLIGHT_OUTLINE_COLOR
	highlight.FillTransparency = FILL_TRANSPARENCY
	highlight.OutlineTransparency = OUTLINE_TRANSPARENCY

	-- DepthMode controls if you can see it through walls.
	-- Occluded = Hidden behind walls. AlwaysOnTop = X-Ray vision.
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded 

	highlight.Parent = character
end

-- 1. Highlight players who are already in the game when you join
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		ApplyHighlight(player.Character)
	end

	-- Listen for when they respawn
	player.CharacterAdded:Connect(function(character)
		ApplyHighlight(character)
	end)
end

-- 2. Highlight new players who join after you
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		ApplyHighlight(character)
	end)
end)