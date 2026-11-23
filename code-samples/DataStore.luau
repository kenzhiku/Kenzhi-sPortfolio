local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local PlayerSurvival = DataStoreService:GetDataStore("PlayerSurvival")
local LeaderboardStore = DataStoreService:GetOrderedDataStore("PlayerSurvival")

local loadedPlayers = {}

Players.PlayerAdded:Connect(function(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local Survival = Instance.new("IntValue")
	Survival.Name = "Survived"
	Survival.Parent = leaderstats
	
	local Coin = Instance.new("IntValue")
	Coin.Name = "Coins"
	Coin.Parent = leaderstats
	
	local success, savedData = pcall(function()
		return PlayerSurvival:GetAsync(tostring(player.UserId))
	end)	

	if success then
		loadedPlayers[player.UserId] = true
		
		if savedData then
			Survival.Value = savedData.Survival or 0
			Coin.Value = savedData.Coins or 0
		else
			Survival.Value = 0
			Coin.Value = 0
		end
	else
		player:Kick("Data failed to load. Please rejoin to protect your save file.")
		return
	end
	
	Survival.Changed:Connect(function(newValue)
		pcall(function()
			LeaderboardStore:SetAsync(tostring(player.UserId), newValue)
		end)
	end)
	
	leaderstats.Parent = player
	
end)

Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local survival = leaderstats:FindFirstChild("Survived")
		local coins = leaderstats:FindFirstChild("Coins")
		if survival and coins then
			
			local playerKey = tostring(player.UserId)
			
			local savedData = {
				Survival = survival.Value,
				Coins = coins.Value
			}
			
			pcall(function()
				PlayerSurvival:SetAsync(playerKey, savedData)
			end)
			
			pcall(function()
				LeaderboardStore:SetAsync(playerKey, survival.Value)
			end)
		end
	end
end)