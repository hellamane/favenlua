-- Prison Life
-- Made by hellamane 3/16/26 7:52 PM
-- Fully Restored & Fixed Version (Cleaned notifications, added Forcefield Check toggle)

local DiscordLib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt")()

local win = DiscordLib:Window("faven.lua")
local toolsServer = win:Server("Tools", "")
local playerConfigChan = toolsServer:Channel("Player Configurations")
local toolsChan = toolsServer:Channel("Tools")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputService = game:GetService("VirtualInputService")

local HitboxEnabled = false
local Connections = {}
local OriginalSizes = {}

local function enlargeHitboxes(char)
    if not HitboxEnabled then return end

    local parts = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg"
    }

    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not OriginalSizes[part] then
                OriginalSizes[part] = part.Size
            end

            part.Size = Vector3.new(8, 8, 8)
            part.Transparency = 0.8
            part.CanCollide = false
            part.Massless = true
        end
    end
end

local function restoreHitboxes(char)
    for part, size in pairs(OriginalSizes) do
        if part and part.Parent then
            part.Size = size
            part.Transparency = 0
        end
    end
    OriginalSizes = {}
end

local function setupPlayer(plr)
    if plr == LocalPlayer then return end

    if plr.Character then
        enlargeHitboxes(plr.Character)
    end

    Connections[plr] = plr.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        enlargeHitboxes(char)
    end)
end

local function enableHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        setupPlayer(plr)
    end

    Connections["_PlayerAdded"] = Players.PlayerAdded:Connect(setupPlayer)
end

local function disableHitbox()
    HitboxEnabled = false

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            restoreHitboxes(plr.Character)
        end
    end

    for _, conn in pairs(Connections) do
        if conn.Disconnect then conn:Disconnect() end
    end

    Connections = {}
end

--// PLAYER CONFIGURATIONS CHANNEL
playerConfigChan:Toggle("Hitbox Extender", false, function(state)
    HitboxEnabled = state
    if state then
        enableHitbox()
    else
        disableHitbox()
    end
end)

playerConfigChan:Seperator()

--// SHARED AIMLOCK & TARGET UTILS
local aimlockMode = "None"
local Aiming = false
local currentTarget = nil
local lastAttacker = nil

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://12221967"
toggleSound.Volume = 1
toggleSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function IsValidTarget(plr, filterTeam)
    if not plr or plr == LocalPlayer or not plr.Character then return end
    local hum = plr.Character:FindFirstChild("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    if not hum or not head or hum.Health <= 0 then return false end
    if filterTeam and LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then return false end
    if plr.Character:FindFirstChildOfClass("ForceField") then return false end
    return true
end

local function IsGuardOrCrim(plr)
    if not plr.Team then return false end
    local name = plr.Team.Name
    return name == "Guards" or name == "Criminals"
end

local function GetClosestToMouse(filterTeam)
    local cam = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local closest, shortest = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if aimlockMode == "Guard/Crim Aimlock" then
            if IsValidTarget(plr, false) and (IsGuardOrCrim(plr) or plr == lastAttacker) then
                local head = plr.Character.Head
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = plr
                    end
                end
            end
        elseif aimlockMode == "Standard Aimlock" then
            if IsValidTarget(plr, true) then
                local head = plr.Character.Head
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = plr
                    end
                end
            end
        end
    end

    return closest
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.HealthChanged:Connect(function()
        if hum.Health < hum.MaxHealth then
            local attacker = hum:FindFirstChild("creator")
            if attacker and attacker.Value and attacker.Value ~= LocalPlayer then
                lastAttacker = attacker.Value
            end
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if Aiming and aimlockMode ~= "None" then
        if aimlockMode == "Guard/Crim Aimlock" and lastAttacker and IsValidTarget(lastAttacker, false) then
            currentTarget = lastAttacker
        else
            currentTarget = GetClosestToMouse(aimlockMode == "Standard Aimlock")
        end

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(
                cam.CFrame.Position,
                currentTarget.Character.Head.Position
            )
        end
    end
end)

playerConfigChan:Seperator()

local ESPEnabled = false
local espData = {}
local espPlayerAddedConn
local espHeartbeat

local function clearESP(plr)
    local data = espData[plr]
    if not data then return end

    if data.highlight then data.highlight:Destroy() end
    if data.bill then data.bill:Destroy() end

    if data.conns then
        for _, c in ipairs(data.conns) do
            if c.Disconnect then c:Disconnect() end
        end
    end

    if data.charConn and data.charConn.Disconnect then
        data.charConn:Disconnect()
    end

    espData[plr] = nil
end

local function applyESP(plr, char)
    if not ESPEnabled then return end
    if plr == LocalPlayer then return end
    if not char then return end

    clearESP(plr)

    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end

    local color = plr.TeamColor and plr.TeamColor.Color or Color3.new(1,1,1)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Adornee = char
    highlight.Parent = char

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 60, 0, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = head

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = bill

    local function updateText()
        label.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "]"
    end
    updateText()

    local conns = {}

    conns[#conns+1] = hum.HealthChanged:Connect(function()
        updateText()
    end)

    conns[#conns+1] = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
        local c = plr.TeamColor and plr.TeamColor.Color or Color3.new(1,1,1)
        highlight.FillColor = c
        highlight.OutlineColor = c
        label.TextColor3 = c
    end)

    espData[plr] = {
        highlight = highlight,
        bill = bill,
        conns = conns,
        character = char
    }
end

local function setupPlayerESP(plr)
    if plr == LocalPlayer then return end
    if not ESPEnabled then return end

    if plr.Character then
        applyESP(plr, plr.Character)
    end

    local charConn = plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 5)
        applyESP(plr, char)
    end)

    espData[plr] = espData[plr] or {}
    espData[plr].charConn = charConn
end

local function enableESP()
    if ESPEnabled then return end
    ESPEnabled = true

    for _, plr in ipairs(Players:GetPlayers()) do
        setupPlayerESP(plr)
    end

    espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
        setupPlayerESP(plr)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        clearESP(plr)
    end)

    espHeartbeat = RunService.Heartbeat:Connect(function()
        if not ESPEnabled then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")

                    local data = espData[plr]

                    if not data
                    or data.character ~= char
                    or not head
                    or not hum
                    or hum.Health <= 0
                    or not data.highlight
                    or not data.bill
                    or data.highlight.Parent ~= char
                    or data.bill.Parent ~= head then
                        applyESP(plr, char)
                    end
                end
            end
        end
    end)
end

local function disableESP()
    ESPEnabled = false

    if espPlayerAddedConn then
        espPlayerAddedConn:Disconnect()
        espPlayerAddedConn = nil
    end

    if espHeartbeat then
        espHeartbeat:Disconnect()
        espHeartbeat = nil
    end

    for plr in pairs(espData) do
        clearESP(plr)
    end
end

playerConfigChan:Toggle("ESP", false, function(state)
    if state then 
        enableESP() 
    else 
        disableESP() 
    end
end)

playerConfigChan:Seperator()

local InfJumpEnabled = false

playerConfigChan:Toggle("Infinite Jump", false, function(state)
    InfJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled then
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

playerConfigChan:Seperator()

local NoCollideTools = false

playerConfigChan:Toggle("NoCollide Tools", false, function(state)
    NoCollideTools = state
end)

local function makeToolNonCollide(tool)
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not NoCollideTools then return end

    local char = LocalPlayer.Character
    if not char then return end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            makeToolNonCollide(tool)
        end
    end

    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            makeToolNonCollide(tool)
        end
    end
end)

playerConfigChan:Seperator()

-- Forcefield Check toggle placed under the last toggle in player configs
local forcefieldCheckEnabled = true
playerConfigChan:Toggle("Forcefield Check", true, function(state)
    forcefieldCheckEnabled = state
end)

playerConfigChan:Seperator()

local currentWS = 19
local currentJP = 35

local wsMin, wsMax = 16, 33
local jpMin, jpMax = 24, 110

playerConfigChan:Textbox("Walk Speed", "Enter a value between 16 and 33", true, function(text)
    local num = tonumber(text)
    if not num or num < wsMin or num > wsMax then
        return
    end
    currentWS = num
end)

playerConfigChan:Seperator()

playerConfigChan:Textbox("Jump Power", "Enter a value between 24 and 110", true, function(text)
    local num = tonumber(text)
    if not num or num < jpMin or num > jpMax then
        return
    end
    currentJP = num
end)

playerConfigChan:Seperator()

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    hum.WalkSpeed = currentWS
    hum.JumpPower = currentJP
end)


--// TOOLS CHANNEL (New Player Target Features & Controls)
local selectedTargetPlayer = nil
local playerConfigEnabled = false
local autoFistEnabled = false
local autoKillEnabled = false
local autoResetEnabled = false
local originalPositionBeforeTarget = nil
local isExecutingTargetAction = false

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerNames, p.Name)
    end
end

local playerDropdown = toolsChan:Dropdown("Select Target Player", playerNames, function(choice)
    selectedTargetPlayer = Players:FindFirstChild(choice)
end)

toolsChan:Seperator()

toolsChan:Button("Refresh Players", function()
    pcall(function()
        playerDropdown:Clear()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                playerDropdown:Add(p.Name)
            end
        end
    end)
end)

toolsChan:Seperator()

toolsChan:Toggle("Enable Target Features", false, function(state)
    playerConfigEnabled = state
end)

toolsChan:Seperator()

toolsChan:Toggle("Auto Fist", false, function(state)
    autoFistEnabled = state
end)

toolsChan:Seperator()

toolsChan:Toggle("Auto Kill", false, function(state)
    autoKillEnabled = state
end)

toolsChan:Seperator()

toolsChan:Toggle("Auto Reset", false, function(state)
    autoResetEnabled = state
end)

local function hasGunInBackpackOrChar()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local weaponsFound = false
    
    local function checkContainer(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("remington") or name:find("ak") or name:find("m4") or name:find("m700") or name:find("mp5") or name:find("fal") then
                    weaponsFound = true
                end
            end
        end
    end
    
    checkContainer(char)
    checkContainer(backpack)
    return weaponsFound
end

local function getClosestGunAndGrab(gunType)
    local targetPos = nil
    if gunType == "Shotgun" then
        local guardPos = Vector3.new(820, 97, 2229)
        local crimPos = Vector3.new(-938, 91, 2039)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetPos = (hrp.Position - guardPos).Magnitude < (hrp.Position - crimPos).Magnitude and guardPos or crimPos
        else
            targetPos = guardPos
        end
    else
        targetPos = Vector3.new(-931, 91, 2039)
    end

    local targetObj = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "TouchGiver" and obj:IsA("BasePart") then
            if (obj.Position - targetPos).Magnitude < 25 then
                targetObj = obj
                break
            end
        end
    end

    if targetObj and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local originalCF = targetObj.CFrame
        local originalAnchored = targetObj.Anchored
        pcall(function()
            targetObj.Anchored = true
            targetObj.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
            task.wait(0.2)
            firetouchinterest(hrp, targetObj, 0)
            firetouchinterest(hrp, targetObj, 1)
            task.wait(0.2)
            targetObj.CFrame = originalCF
            targetObj.Anchored = originalAnchored
        end)
    end
end

RunService.Heartbeat:Connect(function()
    if not playerConfigEnabled then 
        isExecutingTargetAction = false
        return 
    end
    if not selectedTargetPlayer or not selectedTargetPlayer.Character then return end
    
    local targetChar = selectedTargetPlayer.Character
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHum or not targetHrp or targetHum.Health <= 0 then 
        isExecutingTargetAction = false
        return 
    end

    -- Forcefield check active only if the toggle is enabled
    if forcefieldCheckEnabled and targetChar:FindFirstChildOfClass("ForceField") then
        if isExecutingTargetAction and originalPositionBeforeTarget then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = originalPositionBeforeTarget
            end
            isExecutingTargetAction = false
        end
        return
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    if not isExecutingTargetAction then
        originalPositionBeforeTarget = hrp.CFrame
        isExecutingTargetAction = true
    end

    hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)

    if autoFistEnabled then
        pcall(function()
            VirtualInputService:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.05)
            VirtualInputService:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    elseif autoKillEnabled then
        if not hasGunInBackpackOrChar() then
            getClosestGunAndGrab("Shotgun")
            getClosestGunAndGrab("AK-47")
            task.wait(0.2)
        end

        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    item.Parent = char
                end
            end
        end

        pcall(function()
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local fireEvent = tool:FindFirstChild("FireEvent") or (tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild("FireEvent"))
                    if fireEvent and fireEvent:IsA("RemoteEvent") then
                        fireEvent:FireServer(targetHrp.Position, targetHrp)
                    end
                end
            end
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end)
    end

    if targetHum.Health <= 0 then
        if autoResetEnabled then
            hum.Health = 0
        else
            if originalPositionBeforeTarget then
                hrp.CFrame = originalPositionBeforeTarget
            end
        end
        isExecutingTargetAction = false
    end
end)


--// VEHICLE SERVER
local vehicleServer = win:Server("Vehicle", "")
local vehicleChannel = vehicleServer:Channel("Vehicle Controls")

local FLYING = false
local vehicleflyspeed = 1
local flyKeyDown, flyKeyUp

local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    else
        return nil
    end
end

local function sFLY(vfly)
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
        humanoid = char:FindFirstChildOfClass("Humanoid")
    end

    if flyKeyDown or flyKeyUp then
        flyKeyDown:Disconnect()
        flyKeyUp:Disconnect()
    end

    local T = getRoot(char)
    if not T then return end
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        pcall(function()
            local cam = workspace.CurrentCamera
            if humanoid then
                cam.CameraSubject = humanoid
            end
        end)

        task.spawn(function()
            repeat task.wait()
                local camera = workspace.CurrentCamera
                if not vfly and humanoid then
                    humanoid.PlatformStand = true
                end

                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50 * vehicleflyspeed
                else
                    SPEED = 0
                end

                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    BV.Velocity = (((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                                  ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, 0, 0).p) - camera.CFrame.p)) * SPEED) + 
                                  (Vector3.new(0, 1, 0) * (CONTROL.Q + CONTROL.E) * SPEED)
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R, Q = CONTROL.Q, E = CONTROL.E}
                elseif SPEED ~= 0 then
                    BV.Velocity = (((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + 
                                  ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, 0, 0).p) - camera.CFrame.p)) * SPEED) + 
                                  (Vector3.new(0, 1, 0) * (lCONTROL.Q + lCONTROL.E) * SPEED)
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camera.CFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()

            if humanoid then humanoid.PlatformStand = false end
        end)
    end

    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = -1
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = -1
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 1
        elseif input.KeyCode == Enum.KeyCode.Q then
            CONTROL.Q = -1
        elseif input.KeyCode == Enum.KeyCode.E then
            CONTROL.E = 1
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then
            CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then
            CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.Q then
            CONTROL.Q = 0
        elseif input.KeyCode == Enum.KeyCode.E then
            CONTROL.E = 0
        end
    end)
    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then 
        flyKeyDown:Disconnect() 
        flyKeyDown = nil
        flyKeyUp:Disconnect() 
        flyKeyUp = nil
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
end

vehicleChannel:Toggle("Vehicle Fly", false, function(bool)
    if bool then
        NOFLY()
        task.wait()
        sFLY(true)
    else
        NOFLY()
    end
end)

vehicleChannel:Seperator()

vehicleChannel:Slider("Vehicle Speed", 1, 18, 1, function(value)
    vehicleflyspeed = value
end)


--// TELEPORTS SERVER & CHANNEL
local Teleports = win:Server("Teleports", "")
local tpChannel = Teleports:Channel("Locations")

local teleportList = {
    ["Town Store"] = CFrame.new(438, 12, 1167),
    ["Secret Highway Room"] = CFrame.new(-36, 11, 1290),
    ["Cells"] = CFrame.new(919, 100, 2448),
    ["Guard Room"] = CFrame.new(817, 101, 2229),
    ["Waiting Room"] = CFrame.new(703, 100, 2247),
    ["Waiting Room 2"] = CFrame.new(766, 100, 2236),
    ["Cafeteria"] = CFrame.new(900, 100, 2261),
    ["Cafeteria Inside"] = CFrame.new(906, 100, 2232),
    ["Yard"] = CFrame.new(803, 98, 2544),
    ["Yard Tower"] = CFrame.new(831, 126, 2598),
    ["Roof"] = CFrame.new(920, 132, 2232),
    ["Crim Base"] = CFrame.new(-943, 94, 2056),
    ["Secret Room"] = CFrame.new(680, 100, 2330),
    ["Sniper Tower"] = CFrame.new(-297, 114, 2023),
    ["Sewer"] = CFrame.new(917, 79, 2109),
    ["Sewer 2"] = CFrame.new(917, 79, 2431),
    ["Neutral Spawn"] = CFrame.new(868, 40, 2342)
}

local selectedDest = nil
local globalTeleportMethod = "CFrame"
local isCoolingDown = false
local coolDownTimer = 0
local customSpawnCF = CFrame.new(868, 40, 2342)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp and customSpawnCF then
        hrp.CFrame = customSpawnCF + Vector3.new(0, 3, 0)
    end
end)

tpChannel:Dropdown("Teleport Method", {"CFrame", "Tween"}, function(selected)
    globalTeleportMethod = selected
end)

tpChannel:Seperator()

local keys = {}
for name in pairs(teleportList) do
    table.insert(keys, name)
end

local dropdown = tpChannel:Dropdown("Teleport To:", keys, function(selected)
    selectedDest = selected
end)

tpChannel:Seperator()

tpChannel:Button("Teleport Now", function()
    if not selectedDest then return end

    if isCoolingDown then return end

    local cf = teleportList[selectedDest]
    if not cf then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = (hrp.Position - cf.Position).Magnitude
    if distance > 300 then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    if globalTeleportMethod == "CFrame" then
        hrp.CFrame = cf + Vector3.new(0, 3, 0)
    elseif globalTeleportMethod == "Tween" then
        local downTween = TweenService:Create(
            hrp,
            TweenInfo.new(0.35, Enum.EasingStyle.Linear),
            {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
        )
        downTween:Play()
        downTween.Completed:Wait()

        local undergroundTarget = CFrame.new(cf.X, cf.Y - 10, cf.Z)
        local travelTime = math.clamp(distance / 45, 1, 10)

        local tpTween = TweenService:Create(
            hrp,
            TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
            {CFrame = undergroundTarget}
        )
        tpTween:Play()
        tpTween.Completed:Wait()

        TweenService:Create(
            hrp,
            TweenInfo.new(0.9, Enum.EasingStyle.Linear),
            {CFrame = cf + Vector3.new(0, 3, 0)}
        ):Play()
    end

    task.delay(0.6, function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)

    isCoolingDown = true
    coolDownTimer = 6

    task.spawn(function()
        while coolDownTimer > 0 do
            task.wait(1)
            coolDownTimer -= 1
        end
        isCoolingDown = false
    end)
end)

tpChannel:Seperator()

tpChannel:Button("Set Spawn", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        customSpawnCF = char.HumanoidRootPart.CFrame
    end
end)

tpChannel:Seperator()

tpChannel:Button("Clear Teleports", function()
    teleportList = {}
    dropdown:Clear()
end)

tpChannel:Seperator()

tpChannel:Button("Add Custom CFrame", function()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local name = "Custom_" .. tostring(math.random(1000, 9999))
    teleportList[name] = hrp.CFrame
    dropdown:Add(name)
end)


--// WEAPONS SERVER & CHANNELS
local weaponsServer = win:Server("Weapons", "")
local weaponTeleportsChan = weaponsServer:Channel("Weapons")
local weaponSkinsChan = weaponsServer:Channel("Weapon Skins")
local weaponModsChan = weaponsServer:Channel("Weapon Mods")

local weaponLocations = {
    ["MP5 Guards"] = Vector3.new(813, 97, 2229),
    ["Remington 870 Guards"] = Vector3.new(820, 97, 2229),
    ["M4A1 Guards"] = Vector3.new(847, 97, 2229),
    ["M700 Guards"] = Vector3.new(835, 97, 2229),
    ["Remington 870 Crims"] = Vector3.new(-938, 91, 2039),
    ["AK-47 Crims"] = Vector3.new(-931, 91, 2039),
    ["M700 Crims"] = Vector3.new(-920, 91, 2036),
    ["FAL Crims"] = Vector3.new(-902, 91, 2047)
}

local weaponNames = {}
for name in pairs(weaponLocations) do
    table.insert(weaponNames, name)
end

local selectedWeapon = nil
local weaponCoolingDown = false
local weaponCoolDownTimer = 0

weaponTeleportsChan:Dropdown(
    "Pick A Weapon",
    weaponNames,
    function(choice)
        selectedWeapon = choice
    end
)

weaponTeleportsChan:Seperator()

weaponTeleportsChan:Button("Grab Guns", function()
    if not selectedWeapon then return end

    if weaponCoolingDown then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = weaponLocations[selectedWeapon]
    local targetObj = nil

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "TouchGiver" and obj:IsA("BasePart") then
            if (obj.Position - targetPos).Magnitude < 15 then
                targetObj = obj
                break
            end
        end
    end

    if not targetObj then return end

    local originalCF = targetObj.CFrame
    local originalAnchored = targetObj.Anchored

    pcall(function()
        targetObj.Anchored = true
        targetObj.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
        task.wait(0.2)

        firetouchinterest(hrp, targetObj, 0)
        firetouchinterest(hrp, targetObj, 1)
        task.wait(0.2)

        targetObj.CFrame = originalCF
        targetObj.Anchored = originalAnchored
    end)

    weaponCoolingDown = true
    weaponCoolDownTimer = 6

    task.spawn(function()
        while weaponCoolDownTimer > 0 do
            task.wait(1)
            weaponCoolDownTimer -= 1
        end
        weaponCoolingDown = false
    end)
end)

weaponSkinsChan:Button("Apply Gold Skin to All", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in ipairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end
end)

weaponModsChan:Button("Instant Reload Mod", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local fireEvent = handle:FindFirstChild("FireEvent") or tool:FindFirstChild("FireEvent")
            end
        end
    end
end)


--// SETTINGS SERVER & CHANNELS
local settingsServer = win:Server("Settings", "")
local aimSettingsChannel = settingsServer:Channel("Aim Settings")
local settingsChannel = settingsServer:Channel("Settings & Misc")

aimSettingsChannel:Dropdown(
    "Aimlock Mode",
    {"None", "Standard Aimlock", "Guard/Crim Aimlock"},
    function(choice)
        aimlockMode = choice
    end
)

aimSettingsChannel:Seperator()

aimSettingsChannel:Bind(
    "Aimlock Keybind",
    Enum.KeyCode.RightShift,
    function()
        if aimlockMode ~= "None" then
            Aiming = not Aiming
            toggleSound:Play()
        end
    end
)

aimSettingsChannel:Seperator()

local triggerbotEnabled = false
aimSettingsChannel:Toggle("Triggerbot", false, function(state)
    triggerbotEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if triggerbotEnabled then
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target.Parent then
            local enemyPlr = Players:GetPlayerFromCharacter(target.Parent)
            if enemyPlr and IsValidTarget(enemyPlr, true) then
                mouse1press()
                task.wait(0.05)
                mouse1release()
            end
        end
    end
end)

settingsChannel:Toggle(
    "Anti AFK",
    false,
    function(bool)
        if bool then
            if _G.AntiAFKConnection then
                _G.AntiAFKConnection:Disconnect()
            end

            _G.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
            end)
        else
            if _G.AntiAFKConnection then
                _G.AntiAFKConnection:Disconnect()
                _G.AntiAFKConnection = nil
            end
        end
    end
)

settingsChannel:Seperator()

settingsChannel:Toggle(
    "Loop DayTime",
    false,
    function(bool)
        if bool then
            _G.DayLoop = true
            task.spawn(function()
                while _G.DayLoop do
                    pcall(function()
                        local Lighting = game:GetService("Lighting")
                        Lighting.ClockTime = 14
                        Lighting.Brightness = 2
                        Lighting.GlobalShadows = false
                    end)
                    task.wait(5)
                end
            end)
        else
            _G.DayLoop = false
        end
    end
)

settingsChannel:Seperator()

settingsChannel:Button(
    "Boost FPS",
    function()
        pcall(function()
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = false
                end
            end

            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1

            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterTransparency = 1
            end
        end)
    end
)
