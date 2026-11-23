local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")


-- Remote Events --
local TriggerFolder = ReplicatedStorage:WaitForChild("Events")
local wallTrigger = TriggerFolder:FindFirstChild("WallTrigger")
-- Remote Events --

-- Bindable Events --
local enableLights = script:WaitForChild("EnableLights")
local startLightTask =  TriggerFolder:WaitForChild("StartLightTask")
-- Bindable Events -- 

-- Sound Effects --
local powerOutage = SoundService:WaitForChild("power outage sound effect")
local powerOn = SoundService:WaitForChild("electricity box sfx")
local flickerSound = SoundService:WaitForChild("SFX_Lights_Flicker_Loop")
local doorknock = SoundService:WaitForChild("Door knocking sond")
-- Sound Effects --

-- PowerBox --
local powerBox = game.Workspace.MainHouse.PowerBox.PowerClick
local powerClick = powerBox:WaitForChild("ClickDetector")
-- PowerBox -- 

-- Monster Parts -- 
local monsterPrefab = ReplicatedStorage.MonsterAssets:WaitForChild("FirstMonster")
local activeMonster = nil

local function spawnMonsterToWorkSpace(shouldBeSpawned)
	if shouldBeSpawned then
		if not activeMonster or not activeMonster.Parent then
			activeMonster = monsterPrefab:Clone()
			activeMonster.Parent = workspace
		end
	else
		if activeMonster then
			activeMonster:Destroy()
			activeMonster = nil
		end
	end
end
-- Monster Parts -- 

-- NPCs --
local pizzaManPrefab = ReplicatedStorage.NPCS:WaitForChild("Pizza Man")
local activePizzaMan = nil

local function spawnNPCToWorkSpace(shouldBeSpawned)
	if shouldBeSpawned then
		if not activePizzaMan or not activePizzaMan.Parent then
			activePizzaMan = pizzaManPrefab:Clone()
			activePizzaMan.Parent = workspace
		end
	else
		if activePizzaMan then
			activePizzaMan:Destroy()
			activePizzaMan = nil
		end
	end
end
-- NPCs --


local function waitForPlayers()
	-- Wait for at least 1 player to join
	if #Players:GetPlayers() == 0 then
		Players.PlayerAdded:Wait()
	end

	-- Give PlayerGui a brief moment to fully initialize on client startup
	local firstPlayer = Players:GetPlayers()[1]
	if firstPlayer then
		firstPlayer:WaitForChild("PlayerGui")
		task.wait(1) 
	end
end


-- Trash Section --
local gameStatusText = game.StarterGui.GameStatus.Frame.RemainingTrash
local trashCache = ReplicatedStorage:WaitForChild("Cache")
local trashBag = game.Workspace.Trashbag

local function spawnTrash()
	for _, child in ipairs(trashCache:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = game.Workspace.Trashbag
	end
end

local function updateGameStatus(message)
	for _, player in ipairs(Players:GetPlayers()) do
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			local statusText = playerGui:FindFirstChild("GameStatus")
				and playerGui.GameStatus.Frame:FindFirstChild("RemainingTrash")
			if statusText then
				statusText.Text = message
			end
		end
	end
end


local function waitForTrashCompletion()
	while #trashBag:GetChildren() > 0 do
		updateGameStatus("Remaining Trash: " .. #trashBag:GetChildren())
		wait(1)
	end
	updateGameStatus("All Trash Collected!")
end
-- Trash Section --

-- LightSection --

local MainHouseFolder = workspace:WaitForChild("MainHouse")

local bedRoomLightSwitch = game.Workspace.MainHouse.BedroomLightSwitch.LightSwitch.ToggleSwitch
local bathRoomLightSwitch = game.Workspace.MainHouse.BathRoomLightSwitch.LightSwitch.ToggleSwitch
local mainRoomLightSwitch = game.Workspace.MainHouse.MainRoomLightSwitch.LightSwitch.ToggleSwitch
local garageLightSwitch = game.Workspace.MainHouse.GarageLightSwitch.LightSwitch.ToggleSwitch

local switches = {
	bedRoomLightSwitch,
	bathRoomLightSwitch,
	mainRoomLightSwitch,
	garageLightSwitch
}

local lightSwitches = {
	MainHouseFolder:WaitForChild("MainRoomLightSwitch"),
	MainHouseFolder:WaitForChild("BedroomLightSwitch"),
	MainHouseFolder:WaitForChild("GarageLightSwitch"),
	MainHouseFolder:WaitForChild("BathRoomLightSwitch")
}


local function turnOffAllTheLights()
	bedRoomLightSwitch:Fire(false)
	bathRoomLightSwitch:Fire(false)
	mainRoomLightSwitch:Fire(false)
	garageLightSwitch:Fire(false)
end

local function turnOnAllTheLights()
	bedRoomLightSwitch:Fire(true)
	bathRoomLightSwitch:Fire(true)
	mainRoomLightSwitch:Fire(true)
	garageLightSwitch:Fire(true)
end

local function startFlickerSequence(duration)
	local startTime = os.clock()

	flickerSound.Looped = true
	flickerSound:Play()

	while os.clock() - startTime < duration do

		for _, lightToggle in ipairs(switches) do
			local randomState = (math.random() > 0.5) 
			lightToggle:Fire(randomState)

		end

		task.wait(math.random(5, 20) / 100)
	end

	for _, lightToggle in ipairs(switches) do
		lightToggle:Fire(false)
	end
	flickerSound:Stop()
end

local function highlightAllSwitches()
	for _, switchModel in ipairs(lightSwitches) do
		if not switchModel:FindFirstChild("ObjectiveHighlight") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "ObjectiveHighlight"
			highlight.FillColor = Color3.fromRGB(255, 230, 100) 
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.Parent = switchModel
		end
	end
end

local function startLightSwitchTask()
	highlightAllSwitches()

	local totalToTurnOn = #lightSwitches
	local currentCount = 0
	
	updateGameStatus("Turn on all Lights: 0/" .. totalToTurnOn)
	
	local taskCompletedEvent = Instance.new("BindableEvent")
	local connections = {}
	
	for _, switchModel in ipairs(lightSwitches) do
		local lightSwitchpart = switchModel:FindFirstChild("LightSwitch")
		local clickDetector = lightSwitchpart and lightSwitchpart:FindFirstChildOfClass("ClickDetector")
		
		
		if clickDetector then
			local connection
			connection = clickDetector.MouseClick:Connect(function()
				local highlight = switchModel:FindFirstChild("ObjectiveHighlight")
				if highlight then
					highlight:Destroy()
					currentCount += 1
					
					updateGameStatus("Turn on Light Switches: " .. currentCount .. "/" .. totalToTurnOn)
					
					if currentCount >= totalToTurnOn then
						updateGameStatus("Lights Completed!")
						
						for _, conn in ipairs(connections) do
							conn:Disconnect()
						end
						
						taskCompletedEvent:Fire()
					end
				end
			end)
			table.insert(connections, connection)
		end
	end
	
	taskCompletedEvent.Event:Wait()
	taskCompletedEvent:Destroy()

end

local isOn = true

local function setHousePowerEnabled(powerOn)
	isOn = powerOn
	
	for _, switchModel in ipairs(lightSwitches) do
		local lightSwitchPart = switchModel:FindFirstChild("LightSwitch")
		if lightSwitchPart then
			local lightScript = lightSwitchPart:FindFirstChildOfClass("Script")
			if lightScript then
				lightScript.Disabled = not powerOn
			end
			
			local clickDetector = lightSwitchPart:FindFirstChildOfClass("ClickDetector")
			if clickDetector then
				clickDetector.MaxActivationDistance = powerOn and 30 or 0
			end
		end
	end
end
-- Light section --

-- Open Door Task -- 
local door = game.Workspace.MainHouse.XDoorEntrance

local function openDoorTask()
	local clickDetector = door:WaitForChild("ClickDetector")
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "ObjectiveHighlight"
	highlight.FillColor = Color3.fromRGB(255, 230, 100) 
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = door
	
	local taskCompletedEvent = Instance.new("BindableEvent")
	
	local connection
	connection = clickDetector.MouseClick:Connect(function()
		if highlight then
			highlight:Destroy()
		end
		taskCompletedEvent:Fire()
	end)
	
	taskCompletedEvent.Event:Wait()
	connection:Disconnect()
	taskCompletedEvent:Destroy()
end
-- Open Door Task -- 

-- Events method --
enableLights.Event:Connect(function(shouldBeOn)
	if shouldBeOn ~= nil then
		setHousePowerEnabled(shouldBeOn)
	else
		setHousePowerEnabled(not isOn)
	end
end)
-- Events method --

-- Dialogue --

local frameDialogue = game.StarterGui.Dialogue.FrameDialogue

local function typeText(textLabel, text)
	for i = 1, #text do
		textLabel.Text = string.sub(text, 1, i)
		wait(0.05)
	end
end

local function broadcastDialogue(message)
	for _, player in ipairs(Players:GetPlayers()) do
		local playerGUi = player:WaitForChild("PlayerGui")
		if playerGUi then
			local playerDialogue = playerGUi:WaitForChild("Dialogue")
			local dialogueFrame = playerDialogue:WaitForChild("FrameDialogue")
			local textLabel = dialogueFrame:WaitForChild("TextLabel")
			
			if dialogueFrame and textLabel then
				dialogueFrame.Visible = true
				task.wait(1)
				typeText(textLabel, message)
				task.wait(5)
				textLabel.Text =""
				dialogueFrame.Visible = false
			end
		end
	end

end


-- Dialogue


local function mainGame()

	waitForPlayers()
	turnOffAllTheLights()
	
	updateGameStatus("Go back to your house")
	startLightTask.Event:Wait()
	startLightSwitchTask()
	updateGameStatus("")
	
	task.wait(10)
	
	spawnTrash()
	waitForTrashCompletion()
	task.wait(3)
	
	updateGameStatus("")
	task.wait(5)	
	
	startFlickerSequence(10)
	powerOutage:Play()
	task.wait(0.5)
	
	turnOffAllTheLights()
	enableLights:Fire(false)
	
	task.wait(5)
	updateGameStatus("Power Outage! Find the powerbox to turn on the lights!")
	
	powerClick.MouseClick:Wait()
	enableLights:Fire(true)
	
	powerOn:Play()
	turnOffAllTheLights()
	
	updateGameStatus("Power Restored!")
	task.wait(3)
	updateGameStatus("")

	task.wait(10)

	doorknock:Play()
	spawnMonsterToWorkSpace(true)

	task.wait(1)
	updateGameStatus("Open the door to the house")
	openDoorTask()
	updateGameStatus("")
	spawnNPCToWorkSpace(true)
	spawnMonsterToWorkSpace(false)
	broadcastDialogue("Pizza guy: Hello Sir! Here's your pizza.")

	broadcastDialogue("Me: Hey I did not order a pizza.")
	broadcastDialogue("Me: Oh well, atleast I got it for free")
end

mainGame()