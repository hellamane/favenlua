--// QUEZ VEHICLE FLY — STABLE VERSION
--// WASD, Shift Boost, Q/E Up-Down, Smooth Takeoff, Anti-Fling

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local flyEnabled = false
local currentSeat = nil
local vehicle = nil
local wheelParts = {}
local flightConnection = nil

local BASE_SPEED = 60
local BOOST_SPEED = 120
local VERTICAL_SPEED = 45
local TARGET_HOVER = 30

local currentHover = 0
local baseY = nil
local extraHeight = 0

local keys = {W=false,A=false,S=false,D=false,Q=false,E=false,Shift=false}

UIS.InputBegan:Connect(function(i,g)
	if g then return end
	local kc = i.KeyCode
	if kc == Enum.KeyCode.W then keys.W = true end
	if kc == Enum.KeyCode.A then keys.A = true end
	if kc == Enum.KeyCode.S then keys.S = true end
	if kc == Enum.KeyCode.D then keys.D = true end
	if kc == Enum.KeyCode.Q then keys.Q = true end
	if kc == Enum.KeyCode.E then keys.E = true end
	if kc == Enum.KeyCode.LeftShift or kc == Enum.KeyCode.RightShift then keys.Shift = true end
end)

UIS.InputEnded:Connect(function(i)
	local kc = i.KeyCode
	if kc == Enum.KeyCode.W then keys.W = false end
	if kc == Enum.KeyCode.A then keys.A = false end
	if kc == Enum.KeyCode.S then keys.S = false end
	if kc == Enum.KeyCode.D then keys.D = false end
	if kc == Enum.KeyCode.Q then keys.Q = false end
	if kc == Enum.KeyCode.E then keys.E = false end
	if kc == Enum.KeyCode.LeftShift or kc == Enum.KeyCode.RightShift then keys.Shift = false end
end)

local function collectWheels(model)
	wheelParts = {}
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local name = part.Name:lower()
			if name:find("wheel") or name:find("tire") then
				table.insert(wheelParts, part)
			end
		end
	end
end

humanoid.Seated:Connect(function(active, seat)
	if active then
		currentSeat = seat
		vehicle = seat:FindFirstAncestorWhichIsA("Model")
		if vehicle and not vehicle.PrimaryPart then
			vehicle.PrimaryPart = seat
		end
		collectWheels(vehicle)
		currentHover = 0
		extraHeight = 0
		if flyEnabled and vehicle and vehicle.PrimaryPart then
			baseY = vehicle.PrimaryPart.Position.Y
		end
	else
		currentSeat = nil
		vehicle = nil
		wheelParts = {}
		baseY = nil
		currentHover = 0
		extraHeight = 0
	end
end)

local function stabilize(model)
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Velocity = Vector3.zero
			p.RotVelocity = Vector3.zero
		end
	end
end

local function startFlight()
	if flightConnection then flightConnection:Disconnect() end
	
	flightConnection = RunService.RenderStepped:Connect(function(dt)
		if not flyEnabled then return end
		if not vehicle or not vehicle.PrimaryPart or not currentSeat then return end
		local cam = workspace.CurrentCamera
		if not cam then return end

		local primary = vehicle.PrimaryPart
		if not baseY then
			baseY = primary.Position.Y
		end

		currentHover = math.clamp(currentHover + dt * 2.5, 0, TARGET_HOVER)

		if keys.Q then
			extraHeight = extraHeight + VERTICAL_SPEED * dt
		end
		if keys.E then
			extraHeight = extraHeight - VERTICAL_SPEED * dt
		end

		local targetY = baseY + currentHover + extraHeight

		local speed = keys.Shift and BOOST_SPEED or BASE_SPEED
		local move = Vector3.zero

		if keys.W then move += cam.CFrame.LookVector end
		if keys.S then move -= cam.CFrame.LookVector end
		if keys.A then move -= cam.CFrame.RightVector end
		if keys.D then move += cam.CFrame.RightVector end

		local horiz = Vector3.new(move.X, 0, move.Z)
		if horiz.Magnitude > 0 then
			horiz = horiz.Unit * speed * dt
		end

		local pos = primary.Position
		pos = Vector3.new(pos.X, targetY, pos.Z) + Vector3.new(horiz.X, 0, horiz.Z)

		local look = cam.CFrame.LookVector
		vehicle:SetPrimaryPartCFrame(CFrame.new(pos, pos + look))
		  	for _, wheel in ipairs(wheelParts) do
			if wheel and wheel.Parent then
				wheel.Velocity = Vector3.zero
				wheel.RotVelocity = Vector3.zero
			end
		end
		stabilize(vehicle)
	end)
end

local function stopFlight()
	if flightConnection then
		flightConnection:Disconnect()
		flightConnection = nil
	end
	baseY = nil
	currentHover = 0
	extraHeight = 0
	wheelParts = {}
end

tools:Toggle("Vehicle Fly", false, function(bool)
	flyEnabled = bool
	if flyEnabled then
		if vehicle and vehicle.PrimaryPart then
			collectWheels(vehicle)
			baseY = vehicle.PrimaryPart.Position.Y
			currentHover = 0
			extraHeight = 0
			startFlight()
		end
	else
		stopFlight()
	end
end)