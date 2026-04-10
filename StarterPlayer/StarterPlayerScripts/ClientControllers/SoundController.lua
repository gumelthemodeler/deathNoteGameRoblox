-- @ScriptType: LocalScript
-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage:WaitForChild("Events")
local ShowVoting = Events:WaitForChild("ShowVoting")
local UpdateTimer = Events:WaitForChild("UpdateTimer")
local PlayDeathEffectEvent = Events:WaitForChild("PlayDeathEffectEvent")

-- Build Audio Instances
local function CreateSound(id, volume, looped)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = volume
	sound.Looped = looped
	sound.Parent = game:GetService("SoundService")
	return sound
end

-- Ambient Tracks
local LobbyMusic = CreateSound("1843475306", 0.3, true) -- Eerie, calm background
local GameMusic = CreateSound("1843400713", 0.3, true) -- Tension thriller background

-- Standard SFX
local PopupSFX = CreateSound("82578705191577", 0.8, false) -- UI Whoosh
local TickSFX = CreateSound("119133534035860", 0.5, false) -- Clock Tick

-- Cinematic SFX
local KiraVictorySFX = CreateSound("71191289424817", 0.8, false)
local LVictorySFX = CreateSound("72982825100404", 0.8, false)
local HeartAttackSFX = CreateSound("140695149439373", 1, false) -- Dramatic death sting

LobbyMusic:Play()
local currentTrack = LobbyMusic

-- Crossfade helper
local function FadeToMusic(newTrack)
	if currentTrack == newTrack then return end

	-- Fade out old track
	if currentTrack then
		TweenService:Create(currentTrack, TweenInfo.new(2), {Volume = 0}):Play()
		task.delay(2, function() currentTrack:Stop() end)
	end

	-- Fade in new track (unless we are passing 'nil' to silence the background for a victory theme)
	if newTrack then
		newTrack.Volume = 0
		newTrack:Play()
		TweenService:Create(newTrack, TweenInfo.new(2), {Volume = 0.3}):Play()
	end

	currentTrack = newTrack
end

-- Play SFX when voting pops up
ShowVoting.OnClientEvent:Connect(function(isVisible)
	if isVisible then
		PopupSFX:Play()
	end
end)

-- Play the dramatic Heart Attack sting globally when someone dies
PlayDeathEffectEvent.OnClientEvent:Connect(function(victimPlayer, effectName)
	if effectName == "HeartAttack" then
		HeartAttackSFX:Play()
	end
end)

-- Manage music state based on timer text
UpdateTimer.OnClientEvent:Connect(function(stateText, timeString)
	if stateText == "SURVIVE" then
		FadeToMusic(GameMusic)

	elseif stateText == "WAITING FOR PLAYERS..." or stateText == "INTERMISSION" then
		FadeToMusic(LobbyMusic)

	elseif stateText == "MATCH OVER: KIRA WINS" then
		FadeToMusic(nil) -- Silence ambient music
		KiraVictorySFX:Play()

	elseif stateText == "MATCH OVER: TASKFORCE WINS" then
		FadeToMusic(nil) -- Silence ambient music
		LVictorySFX:Play()
	end

	-- Play a tick sound for the final 3 seconds of a countdown
	if timeString == "0:03" or timeString == "0:02" or timeString == "0:01" then
		TickSFX:Play()
	end
end)