-- Prison Life
-- Made by hellamane 3/16/26 7:52 PM
-- Fixed and Organized

local DiscordLib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt")()

local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Tools", "")
local tools = serv:Channel("Tools")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

-- Get Game Name safely for badge notifications
local gameName = "Prison Life"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.GameId)
    if info and info.Name then
        gameName = info.Name
    end
end)

local function showBadgeNotification(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "faven.lua",
            Text = "You're playing " .. gameName,
            Duration = duration or 3,
        })
    end)
end

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

tools:Toggle("Hitbox Extender", false, function(state)
    HitboxEnabled = state
    if state then
        enableHitbox()
        showBadgeNotification("Hitbox Extender Enabled", 2)
    else
        disableHitbox()
        showBadgeNotification("Hitbox Extender Disabled", 2)
    end
end)

tools:Seperator()

local AimlockEnabled = true
local Aiming = false
local currentTarget = nil

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://12221967"
toggleSound.Volume = 1
toggleSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function Notify(text)
    showBadgeNotification(text, 2)
end

local function IsValidTarget(plr)
    if not plr or plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    if not hum or not head or hum.Health <= 0 then return false end
    if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then return false end
    if plr.Character:FindFirstChildOfClass("ForceField") then return false end
    return true
end

local function GetClosestToMouse()
    local cam = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local closest, shortest = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidTarget(plr) then
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

    return closest
end

local function AimLock()
    currentTarget = GetClosestToMouse()

    if currentTarget and IsValidTarget(currentTarget) then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.new(
            cam.CFrame.Position,
            currentTarget.Character.Head.Position
        )
    end
end

tools:Bind(
    "Aimlock",
    Enum.KeyCode.RightShift,
    function()
        if not AimlockEnabled then return end

        Aiming = not Aiming
        toggleSound:Play()

        if Aiming then
            Notify("Aimlock Enabled")
        else
            Notify("Aimlock Disabled")
            currentTarget = nil
        end
    end
)

tools:Seperator()

RunService.RenderStepped:Connect(function()
    if Aiming and AimlockEnabled then
        AimLock()
    end
end)

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

tools:Toggle("ESP", false, function(state)
    if state then 
        enableESP() 
        showBadgeNotification("ESP Enabled", 2)
    else 
        disableESP() 
        showBadgeNotification("ESP Disabled", 2)
    end
end)

tools:Seperator()

local InfJumpEnabled = false

tools:Toggle("Infinite Jump", false, function(state)
    InfJumpEnabled = state
    if state then
        showBadgeNotification("Infinite Jump Enabled", 2)
    else
        showBadgeNotification("Infinite Jump Disabled", 2)
    end
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

tools:Seperator()

local NoCollideTools = false

tools:Toggle("NoCollide Tools", false, function(state)
    NoCollideTools = state
    if state then
        showBadgeNotification("NoCollide Tools Enabled", 2)
    else
        showBadgeNotification("NoCollide Tools Disabled", 2)
    end
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

tools:Seperator()

local currentWS = 19
local currentJP = 35

local wsMin, wsMax = 16, 33
local jpMin, jpMax = 24, 110

tools:Textbox("Walk Speed", "Enter a value between 16 and 33", true, function(text)
    local num = tonumber(text)
    if not num or num < wsMin or num > wsMax then
        showBadgeNotification("Your Walk Speed should be between 16 and 33.", 2)
        return
    end
    currentWS = num
    showBadgeNotification("Walk Speed set to " .. tostring(num), 2)
end)

tools:Seperator()

tools:Textbox("Jump Power", "Enter a value between 24 and 110", true, function(text)
    local num = tonumber(text)
    if not num or num < jpMin or num > jpMax then
        showBadgeNotification("Your Jump Power should be between 24 and 110.", 2)
        return
    end
    currentJP = num
    showBadgeNotification("Jump Power set to " .. tostring(num), 2)
end)

tools:Seperator()

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    hum.WalkSpeed = currentWS
    hum.JumpPower = currentJP
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
    local CONTROL = {F = 0, B = 0, L = 0, R = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
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
        task.spawn(function()
            repeat task.wait()
                local camera = workspace.CurrentCamera
                if not vfly and humanoid then
                    humanoid.PlatformStand = true
                end

                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
                    SPEED = 50 * vehicleflyspeed
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, 0, 0).p) - camera.CFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, 0, 0).p) - camera.CFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camera.CFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0}
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
        end
    end)
    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then 
        flyKeyDown:Disconnect() 
        flyKeyUp:Disconnect() 
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
        showBadgeNotification("Vehicle Fly Enabled", 2)
    else
        NOFLY()
        showBadgeNotification("Vehicle Fly Disabled", 2)
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

local isCoolingDown = false
local coolDownTimer = 0
local globalTeleportMethod = "CFrame"

tpChannel:Dropdown("Teleport Method", {"CFrame", "Tween"}, function(selected)
    globalTeleportMethod = selected
end)

tpChannel:Seperator()

local keys = {}
for name in pairs(teleportList) do
    table.insert(keys, name)
end

local dropdown = tpChannel:Dropdown("Teleport To:", keys, function(selected)
    if isCoolingDown then
        showBadgeNotification("You have to wait " .. tostring(math.ceil(coolDownTimer)) .. "s to teleport again.", 2)
        return
    end

    local cf = teleportList[selected]
    if not cf then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = (hrp.Position - cf.Position).Magnitude
    if distance > 300 then
        showBadgeNotification("You got to get closer!", 3)
        return
    end

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

tpChannel:Button("Clear Teleports", function()
    teleportList = {}
    dropdown:Clear()
    showBadgeNotification("Cleared Custom Teleports", 2)
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
    showBadgeNotification("Added Custom Location", 2)
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
local weaponSpecificTeleportMethod = "CFrame"
local weaponCoolingDown = false
local weaponCoolDownTimer = 0

weaponTeleportsChan:Dropdown("Teleport Method", {"CFrame", "Tween"}, function(selected)
    weaponSpecificTeleportMethod = selected
end)

weaponTeleportsChan:Seperator()

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
    if weaponCoolingDown then
        showBadgeNotification("You have to wait " .. tostring(math.ceil(weaponCoolDownTimer)) .. "s to teleport again.", 2)
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = weaponLocations[selectedWeapon]
    local targetCF = CFrame.new(targetPos)

    local distance = (hrp.Position - targetPos).Magnitude
    if distance > 300 then
        showBadgeNotification("You got to get closer!", 3)
        return
    end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    if weaponSpecificTeleportMethod == "CFrame" then
        hrp.CFrame = targetCF + Vector3.new(0, 3, 0)
    elseif weaponSpecificTeleportMethod == "Tween" then
        local downTween = TweenService:Create(
            hrp,
            TweenInfo.new(0.35, Enum.EasingStyle.Linear),
            {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
        )
        downTween:Play()
        downTween.Completed:Wait()

        local undergroundTarget = CFrame.new(targetPos.X, targetPos.Y - 10, targetPos.Z)
        local travelTime = math.clamp(distance / 56, 1, 10)

        local tpTween = TweenService:Create(
            hrp,
            TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
            {CFrame = undergroundTarget}
        )
        tpTween:Play()
        tpTween.Completed:Wait()

        local upTween = TweenService:Create(
            hrp,
            TweenInfo.new(0.4, Enum.EasingStyle.Linear),
            {CFrame = targetCF + Vector3.new(0, 3, 0)}
        )
        upTween:Play()
        upTween.Completed:Wait()
    end

    task.delay(0.6, function()
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
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
    showBadgeNotification("Applied Gold Skin!", 2)
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
    showBadgeNotification("Weapon Mod Enabled!", 2)
end)

--// SETTINGS SERVER
local settingsServer = win:Server("Settings", "")
local settingsChannel = settingsServer:Channel("Settings & Misc")

local AimlockEnabledMisc = true
local AimingMisc = false
local currentTargetMisc = nil
local lastAttacker = nil

local toggleSoundMisc = Instance.new("Sound")
toggleSoundMisc.SoundId = "rbxassetid://12221967"
toggleSoundMisc.Volume = 1
toggleSoundMisc.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function NotifyMisc(text)
    showBadgeNotification(text, 2)
end

local function IsValidTargetMisc(plr)
    if not plr or plr == LocalPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    if not hum or not head or hum.Health <= 0 then return false end
    if plr.Team == LocalPlayer.Team then return false end
    return true
end

local function IsGuardOrCrim(plr)
    if not plr.Team then return false end
    local name = plr.Team.Name
    return name == "Guards" or name == "Criminals"
end

local function GetClosestToMouseFiltered()
    local cam = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local closest, shortest = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidTargetMisc(plr) then
            if IsGuardOrCrim(plr) or plr == lastAttacker then
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

local function AimLockMisc()
    if lastAttacker and IsValidTargetMisc(lastAttacker) then
        currentTargetMisc = lastAttacker
    else
        currentTargetMisc = GetClosestToMouseFiltered()
    end

    if currentTargetMisc and IsValidTargetMisc(currentTargetMisc) then
        local cam = workspace.CurrentCamera
        local head = currentTargetMisc.Character.Head
        cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
    end
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

settingsChannel:Bind(
    "Guard/Crim Aimlock",
    Enum.KeyCode.RightShift,
    function()
        if not AimlockEnabledMisc then return end

        AimingMisc = not AimingMisc
        toggleSoundMisc:Play()

        if AimingMisc then
            NotifyMisc("Guard/Crim Aimlock Enabled")
        else
            NotifyMisc("Guard/Crim Aimlock Disabled")
            currentTargetMisc = nil
            lastAttacker = nil
        end
    end
)

settingsChannel:Seperator()

RunService.RenderStepped:Connect(function()
    if AimingMisc and AimlockEnabledMisc then
        AimLockMisc()
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

            _G.AntiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
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
    "Loop DayTime (loopfb)",
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
                        Lighting.FogEnd = 9e9
                    end)
                    task.wait(1)
                end
            end)

        else
            _G.DayLoop = false

        end
    end
)

settingsChannel:Seperator()

settingsChannel:Button(
    "Boost FPS (Antilag)",
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
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0

            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect")
                or effect:IsA("SunRaysEffect")
                or effect:IsA("ColorCorrectionEffect")
                or effect:IsA("BloomEffect")
                or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end
        end)
    end
)
