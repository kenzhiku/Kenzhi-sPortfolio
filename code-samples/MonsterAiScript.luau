local monster = script.Parent
local Workspace = game:GetService("Workspace")
local PathFindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local humanoid = monster:FindFirstChild("Humanoid")
local humanoidRootPart = monster:FindFirstChild("HumanoidRootPart")

humanoid.WalkSpeed = 25

local npcPaths = game.Workspace.PathPoints
local npcPoints = npcPaths:GetChildren()

humanoidRootPart:SetNetworkOwner(nil)

local Animator = humanoid:FindFirstChild("Animator")
local walkAnim = script:FindFirstChild("WalkAnim")
local walkTrack = Animator:LoadAnimation(walkAnim)

local walkSound = script:FindFirstChild("T-Type Footsteps")
walkSound.Looped = true
walkSound.Parent = monster.HumanoidRootPart

local growlSound = script:FindFirstChild("monster-growl")
growlSound.Parent = monster.HumanoidRootPart

local killSound = script:FindFirstChild("htf-head-or-body-rips-apart")
killSound.Parent = monster.HumanoidRootPart

local killAnimation = script:FindFirstChild("KillAnim")
local killTrack = Animator:LoadAnimation(killAnimation)
killTrack.Priority = Enum.AnimationPriority.Action

local killCamEvent = game.ReplicatedStorage.KillCamEvent

local monsterArm = monster:FindFirstChild("HoldPos")
local weldConstraint = monsterArm:FindFirstChild("WeldConstraint") or Instance.new("WeldConstraint", monsterArm)


local isPathFinding = false
local isGrabbing = false
local currentMoveTask = nil

local agentParams = {
	AgentRadius = 2.0,
	AgentHeight = 5.0,
	AgentCanJump = true,
	WaypointSpacing = 10,
}

local path = PathFindingService:CreatePath(agentParams)
local reachedConnection
local debugParts = {}

local status = false

local function closestPlayer()
	local player = Players:GetPlayers()
	local nearestPlayer
	local shortestDistance
	
	for _, plr in ipairs(Players:GetPlayers()) do
		local plrCharacter = plr.Character

		if plrCharacter then
			local plrHumanoid = plrCharacter:FindFirstChild("Humanoid")
			local plrHumanoidRootPart = plrCharacter:FindFirstChild("HumanoidRootPart")

			if plrHumanoid and plrHumanoid.Health > 0 and plrHumanoidRootPart then
				local distance = (plrHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
				if not shortestDistance or distance < shortestDistance then
					shortestDistance = distance
					nearestPlayer = plrHumanoidRootPart
				end
			end
		end
	end
	return nearestPlayer, shortestDistance
end

local function walkToPart2(targetPosition, yieldable)
	local success, errorMessage
	
	success, errorMessage = pcall(function()
		path:ComputeAsync(humanoidRootPart.Position, targetPosition)
	end)
	
	if success then
		if path.Status == Enum.PathStatus.Success then
			
			for _, oldPart in ipairs(debugParts) do
				oldPart:Destroy()
			end
			
			table.clear(debugParts)
			
			local waypoints = path:GetWaypoints()
			
			--for i, waypoint in ipairs(waypoints) do
			--	local part = Instance.new("Part")
			--	part.Position = waypoint.Position
			--	part.Size = Vector3.new(0.5, 0.5, 0.5)
			--	part.Color = Color3.new(1, 0, 1)
			--	part.Anchored = true
			--	part.CanCollide = false
			--	part.Parent = Workspace	
			--	table.insert(debugParts, part)
			--end
			
			if yieldable then
				for i, waypoint in ipairs(waypoints) do
					if i == 1 then continue end
					if isGrabbing then break end

					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()

					local _, dist = closestPlayer()
					if isGrabbing or (dist and dist <= 50) then
						break
					end
				end
			else
				if waypoints[2] then
					humanoid:MoveTo(waypoints[2].Position)
				end
			end
		end
	else
		warn("Path not computed")
		print("Path cannot be found")
	end
end

local function grabPlayer(character)
	if isGrabbing then return end
	
	local charHumanoid = character:FindFirstChild("Humanoid")
	local playerTorso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

	if charHumanoid and charHumanoid.Health > 0 and playerTorso and character ~= monster then
		isGrabbing = true

		local player = game.Players:GetPlayerFromCharacter(character)

		humanoid.WalkSpeed = 0
		humanoid:MoveTo(monster.HumanoidRootPart.Position)

		if walkTrack.IsPlaying and walkSound.IsPlaying then
			walkTrack:Stop()
			walkSound:Stop()
		end

		charHumanoid.PlatformStand = true
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end

		character:PivotTo(monsterArm.CFrame)
		weldConstraint.Part0 = monsterArm
		weldConstraint.Part1 = playerTorso

		local playerHead = character:FindFirstChild("Head")

		killCamEvent:FireClient(player, monsterArm.Position, monster.HumanoidRootPart.Position)
		killTrack:Play()
		growlSound:Play()

		killTrack.Ended:Wait()

		charHumanoid.Health = 0
		killSound:Play()
		weldConstraint.Part1 = nil

		task.wait(1)
		humanoid.WalkSpeed = 25
		isGrabbing = false
	end
end

humanoidRootPart.Touched:Connect(function(hit)
	if hit and hit.Parent then
		grabPlayer(hit.Parent)
	end
end)


while true do
	task.wait(0.2)
	if isGrabbing then continue end
	
	local targetChar, distance = closestPlayer()
	
	humanoid.Running:Connect(function(speed)
		if speed > 0.5 and not isGrabbing then
			walkTrack:Play()
			walkSound:Play()
		else
			walkTrack:Stop()
			walkSound:Stop()
		end
	end)
	
	if targetChar and distance <= 10 then
		print("Jumpscaring Player")
		grabPlayer(targetChar.Parent)	
	elseif targetChar and distance <= 100 then
		print("Player detected 100 studs away")
		walkToPart2(targetChar.Position, false)
	else
		if #npcPoints > 0 then
			local randomPath = npcPoints[math.random(1, #npcPoints)]
			print("Going to a random path point")
			walkToPart2(randomPath.Position, true)
		end
	end	
end