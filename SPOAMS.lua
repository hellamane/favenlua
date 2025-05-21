local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if getgenv().aim == nil then
	getgenv().aim = true
end

local function sendBadgeNotification(active)

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BadgeNotification"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false


	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 80)
	frame.Position = UDim2.new(0.5, -150, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local uicorner = Instance.new("UICorner", frame)
	uicorner.CornerRadius = UDim.new(0, 10)

	-- Title label displays "faven.lua"
	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "faven.lua"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 22
	titleLabel.TextColor3 = Color3.new(1, 1, 1)


	local messageLabel = Instance.new("TextLabel", frame)
	messageLabel.Position = UDim2.new(0, 0, 0.4, 0)
	messageLabel.Size = UDim2.new(1, 0, 0.6, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 20
	messageLabel.TextColor3 = Color3.new(1, 1, 1)
	if active then
		messageLabel.Text = "Aimbot is active, equip your tool to use. (First Person Recommended)"
	else
		messageLabel.Text = "Aimbot is deactivated, bye."
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 3)
	local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
	tween:Play()
	task.delay(4, function()
		screenGui:Destroy()
	end)
end


sendBadgeNotification(getgenv().aim)

local lastAimState = getgenv().aim
spawn(function()
	while wait(0.1) do
		if getgenv().aim ~= lastAimState then
			lastAimState = getgenv().aim
			sendBadgeNotification(getgenv().aim)
		end
	end
end)

local shotDelay = 0.1
local targetSearchInterval = 0.1
local maxRange = 100

local function setupCharacter(character)
	local head = character:WaitForChild("Head", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	
	local currentTool = nil
	local aimConnection = nil
	local lockedTarget = nil
	local currentAimPos = nil
	local lastShotTime = tick()
	local lastTargetSearchTime = tick()
	
	local function getNearestTarget()
		local nearestTarget = nil
		local smallestDistance = math.huge
		local localPos = head.Position

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local tHead = player.Character.Head
				local tHumanoid = player.Character:FindFirstChild("Humanoid")
				if tHumanoid and tHumanoid.Health > 0 then
					local distance = (tHead.Position - localPos).Magnitude
					if distance <= maxRange and distance < smallestDistance then
						smallestDistance = distance
						nearestTarget = tHead
					end
				end
			end
		end

		return nearestTarget
	end

	local function stopAim()
		if aimConnection then
			aimConnection:Disconnect()
			aimConnection = nil
		end
		lockedTarget = nil
		currentAimPos = nil
	end

	local function startAim()
		lastShotTime = tick()
		lastTargetSearchTime = tick()
		aimConnection = RunService.RenderStepped:Connect(function(deltaTime)
			if not getgenv().aim then return end
			
			if not currentTool or currentTool.Parent ~= character then
				lockedTarget = nil
				currentAimPos = nil
				return
			end

			local currentTime = tick()
			if currentTime - lastTargetSearchTime >= targetSearchInterval then
				local candidate = getNearestTarget()
				if candidate then
					if lockedTarget then
						local curDist = (lockedTarget.Position - head.Position).Magnitude
						local candDist = (candidate.Position - head.Position).Magnitude
						if candDist < curDist then
							lockedTarget = candidate
						end
					else
						lockedTarget = candidate
					end
				else
					lockedTarget = nil
				end
				lastTargetSearchTime = currentTime
			end

			if lockedTarget then
				local predictedPos = lockedTarget.Position
				local hrp = lockedTarget.Parent:FindFirstChild("HumanoidRootPart")
				if hrp then
					local horizontalVel = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
					if horizontalVel.Magnitude > 0.1 then
						local offset = horizontalVel * shotDelay
						predictedPos = Vector3.new(
							lockedTarget.Position.X + offset.X,
							lockedTarget.Position.Y,
							lockedTarget.Position.Z + offset.Z
						)
					else
						predictedPos = lockedTarget.Position
					end
				end

				if currentAimPos then
					currentAimPos = currentAimPos:Lerp(predictedPos, 0.25)
				else
					currentAimPos = predictedPos
				end

				local camCF = Camera.CFrame
				local targetCF = CFrame.new(camCF.Position, currentAimPos)
				Camera.CFrame = camCF:Lerp(targetCF, 0.1)

				if currentTime - lastShotTime >= shotDelay then
					if currentTool and currentTool:FindFirstChild("RemoteBridge") then
						currentTool.RemoteBridge:FireServer(currentAimPos)
					end
					lastShotTime = currentTime
				end
			else
				currentAimPos = nil
			end
		end)
	end

	spawn(function()
		while currentTool and currentTool.Parent == character do
			if getgenv().aim and not aimConnection then
				startAim()
			elseif not getgenv().aim and aimConnection then
				stopAim()
			end
			wait(0.1)
		end
	end)

	local function attachTool(tool)
		currentTool = tool
		tool.Equipped:Connect(function()
			if getgenv().aim and not aimConnection then
				startAim()
			end
		end)
		tool.Unequipped:Connect(function()
			stopAim()
		end)
	end

	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChild("RemoteBridge") then
			attachTool(item)
		end
	end

	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:FindFirstChild("RemoteBridge") then
			attachTool(child)
		end
	end)

	humanoid.Died:Connect(function()
		stopAim()
	end)
	character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stopAim()
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
	task.spawn(function()
		setupCharacter(character)
	end)
end)
if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end

local function cleanupFolders()
	local gameMaps = Workspace:FindFirstChild("GameMaps")
	if gameMaps then
		for _, folderName in ipairs({"GamepassPads", "DevproductPads"}) do
			local folder = gameMaps:FindFirstChild(folderName)
			if folder then
				folder:Destroy()
			end
		end
	end
end

local function cleanupTreeModels()
	local trunkColor = Color3.fromRGB(102, 75, 57)
	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name:lower() == "tree" then
			for _, child in ipairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					if child.BrickColor.Color ~= trunkColor then
						child:Destroy()
					end
				else
					child:Destroy()
				end
			end
		end
	end
end

task.spawn(function()
	task.wait(2)
	cleanupFolders()
	cleanupTreeModels()
end)
