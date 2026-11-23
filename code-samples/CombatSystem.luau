local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local eventFolder = ReplicatedStorage:WaitForChild("Events")
local meleeEvent = eventFolder:WaitForChild("MeleeEvent")
local blockingEvent = eventFolder:WaitForChild("BlockingEvent")
local damagePart = ReplicatedStorage:WaitForChild("Damage")

local punchHit = SoundService:WaitForChild("punch sound")
local blockHit = SoundService:WaitForChild("Blocked Punch POOR")

meleeEvent.OnServerEvent:Connect(function(player, isThird)
	local character = player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local clonedPart = damagePart:Clone()
	clonedPart.Parent = character
	clonedPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	clonedPart.Anchored = false

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = humanoidRootPart
	weld.Part1 = clonedPart
	weld.Parent = clonedPart
	
	clonedPart.Touched:Connect(function(hit)
		local hitCharacter = hit.Parent
		local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")
		local hitTorso = hitCharacter:FindFirstChild("Torso") or hitCharacter:FindFirstChild("UpperTorso")
		local hitRootPart = hitCharacter:FindFirstChild("HumanoidRootPart")
		
		local particle = game.ReplicatedStorage.Punch.Attachment:Clone()
		local blockingParticle = game.ReplicatedStorage.HitFX.Punch:Clone()

		local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)

		if hitHumanoid and hitPlayer ~= player then
			
			if  hitHumanoid.Health > 0 then
				
				local targetIsBlocking = hitCharacter:GetAttribute("IsBlocking")
				
				if targetIsBlocking and hitRootPart then
					local directionToAttacker = (humanoidRootPart.Position - hitRootPart.Position).Unit
					local dotProduct = hitRootPart.CFrame.LookVector:Dot(directionToAttacker)

					if dotProduct < 0 then
						targetIsBlocking = false 
					end
				end
				
				local damage = targetIsBlocking and 0.5 or 2
				
				hitCharacter:SetAttribute("IsBeingAttacked", true)
				task.spawn(function()
					task.wait(1.5)
					hitCharacter:SetAttribute("IsBeingAttacked", false)
				end)
				
				hitHumanoid.Health = math.max(0, hitHumanoid.Health - damage)
				local BV = Instance.new("BodyVelocity")
				
				if isThird == true then
					local knockbackPower = targetIsBlocking and 12 or 20
					BV.MaxForce = Vector3.new(5e4, 5e2, 5e4)
					BV.Velocity = humanoidRootPart.CFrame.lookVector * knockbackPower
					BV.Parent = hitTorso
					Debris:AddItem(BV, 0.16)
				else
					local knockbackPower = targetIsBlocking and 3 or 10
					BV.MaxForce = Vector3.new(5e4, 5e2, 5e4)
					BV.Velocity = humanoidRootPart.CFrame.lookVector * knockbackPower
					BV.Parent = hitTorso
					Debris:AddItem(BV, 0.16)
				end
				
				if not targetIsBlocking then
					local animator = hitHumanoid:FindFirstChildOfClass("Animator")
					if animator then
						local hitanim = animator:LoadAnimation(script.HitAnim)
						hitanim.Priority = Enum.AnimationPriority.Action4
						hitanim:Play()
						task.delay(0.5, function()
							if hitanim then hitanim:Stop() end
						end)
					end
				end
				
				local animator = hitHumanoid:FindFirstChildOfClass("Animator")
				if animator then
					local hitanim = animator:LoadAnimation(script.HitAnim)
					hitanim.Priority = Enum.AnimationPriority.Action4
					hitanim:Play()
					task.delay(0.5, function()
						if hitanim then hitanim:Stop() end
					end)
				end
				
				if targetIsBlocking then
					local blockClone = blockHit:Clone()
					blockClone.Parent = hitTorso or clonedPart
					blockClone:Play()
					Debris:AddItem(blockClone, 1)

					local blockingTemplate = ReplicatedStorage:FindFirstChild("HitFX") and ReplicatedStorage.HitFX:FindFirstChild("Punch")
					if blockingTemplate then
						local blockingParticle = blockingTemplate:Clone()
						blockingParticle.Parent = hitTorso or clonedPart
						for _, child in ipairs(blockingParticle:GetChildren()) do
							if child:IsA("ParticleEmitter") then
								child.Enabled = false
								child:Emit(1)
							end
						end
						Debris:AddItem(blockingParticle, 0.5)
					end
				else 	
					local soundClone = punchHit:Clone()
					soundClone.Parent = hitTorso or clonedPart
					soundClone:Play()
					Debris:AddItem(soundClone, 1)

					local particleTemplate = ReplicatedStorage:FindFirstChild("Punch")
					if particleTemplate and particleTemplate:FindFirstChild("Attachment") then
						local particle = particleTemplate.Attachment:Clone()
						particle.Parent = hitTorso or clonedPart
						for _, child in ipairs(particle:GetChildren()) do
							if child:IsA("ParticleEmitter") then
								child.Enabled = false
								child:Emit(1)
							end
						end
						Debris:AddItem(particle, 0.5)
					end
				end
			end
		end
		Debris:AddItem(blockingParticle, 0.5)
		Debris:AddItem(particle, 0.5)
	end)
	Debris:AddItem(clonedPart, 0.2)
end)

blockingEvent.OnServerEvent:Connect(function(player, isBlocking)
	local character = player.Character
	if character then
		character:SetAttribute("IsBlocking", isBlocking)
	end
end)