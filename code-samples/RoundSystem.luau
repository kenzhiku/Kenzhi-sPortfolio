local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local miniGames = ReplicatedStorage:FindFirstChild("MiniGames")
local textEventFolder = ReplicatedStorage:FindFirstChild("TextEvents")
local musicFolder = ReplicatedStorage:FindFirstChild("Music")

local clearListEvent = textEventFolder:FindFirstChild("ClearListEvent")
local showResultsEvent = textEventFolder:FindFirstChild("ShowResultsEvent")

local lobbySong = musicFolder:WaitForChild("Time To Relax")

local text = game.StarterGui.ScreenGui.Frame.Timer
local roundStarting = 8
local intermissionTime = 20
local gameTime = 20
local roundEnding = 10

local status = {"GameTime", "Intermission", "RoundEnding"}

local function updateTimerText(message) 
	for _, player in ipairs(Players:GetPlayers()) do
		local playerGUI = player:WaitForChild("PlayerGui")
		if playerGUI then
			local screenGui = playerGUI:WaitForChild("ScreenGui")
			local frame = screenGui:WaitForChild("Frame")
			local timerLabel = frame:WaitForChild("Timer")
			timerLabel.Text = message
		end
	end
end

local function teleportAllPlayers(location)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then	
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				humanoidRootPart.CFrame = location.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
end

local function randomizeMaps()
	local mapsArray = miniGames:GetChildren()
	
	local randomIndex = math.random(1, #mapsArray)
	
	local mapTemplate = mapsArray[randomIndex]
	
	local clonemap = mapTemplate:Clone()
	clonemap.Parent = workspace
	
	local findStringvalue = clonemap:FindFirstChild("FindMe")
	
	if findStringvalue.Value == "Minefield" then
		gameTime = 60
		
	elseif findStringvalue.Value == "RedOrGreen" then
		gameTime = 120
		
		
	elseif findStringvalue.Value == "Bridge" then
		gameTime = 120
	end
	
	return clonemap
end

while true do
	
	lobbySong:Play()
	

	print("Intermission!")
	for i = intermissionTime, 1, -1 do 
		updateTimerText("Intermission: " .. i)
		task.wait(1)
	end

	print("Round Starting!")
	
	randomizeMaps()
	
	for i = roundStarting, 1, -1 do 
		updateTimerText("ROUND IS STARTING")
		task.wait(1)
	end
	
	local obstacleModel = workspace:FindFirstChild("Obstacle")
	if obstacleModel then
		local mapSpawn = obstacleModel:FindFirstChild("ObstacleSpawnLocation")
		if mapSpawn then
			teleportAllPlayers(mapSpawn)
		end
	end
	
	lobbySong:Stop()
	
	
	local status = "GameTime"
	
	print("Game Time!")
	for i = gameTime, 1, -1 do
		updateTimerText("Game Time: " .. i)
		task.wait(1)
	end
	
	local status = "RoundEnding"
	
	teleportAllPlayers(workspace:FindFirstChild("SpawnLocation"))
	
	showResultsEvent:FireAllClients()	
	
	print("Round Ending")
	for i = roundEnding, 1, -1 do 
		updateTimerText("Round Ending: " .. i)
		task.wait(1)
	end
	
	clearListEvent:FireAllClients()
	
	local removeMap = workspace:FindFirstChild("Obstacle")
	if removeMap then
		removeMap:Destroy()
	end

end