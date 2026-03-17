-- Prison Life Luau Code
-- Made by hellamane 3/16/26 7:52 PM
-- This script should not be skidded.

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Prison Life", "")
local tools = serv:Channel("Tools")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    else
        disableHitbox()
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
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "faven.lua",
            Text = text,
            Duration = 2
        })
    end)
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

RunService.RenderStepped:Connect(function()
    if Aiming and AimlockEnabled then
        AimLock()
    end
end)

tools:Seperator()

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

local function setupPlayer(plr)
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
        setupPlayer(plr)
    end

    espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
        setupPlayer(plr)
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
    if state then enableESP() else disableESP() end
end)

tools:Seperator()

local InfJumpEnabled = false

tools:Toggle("Infinite Jump", false, function(state)
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

tools:Seperator()

local NoCollideTools = false

tools:Toggle("NoCollide Tools", false, function(state)
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

tools:Seperator()

local currentWS = 19
local currentJP = 35

local wsMin, wsMax = 16, 33
local jpMin, jpMax = 24, 110

tools:Textbox("Walk Speed", "Enter a value between 16 and 33", true, function(text)
    local num = tonumber(text)
    if not num or num < wsMin or num > wsMax then
        DiscordLib:Notification("faven.lua", "Your Walk Speed should be between 16 and 33.", "Okay!")
        return
    end
    currentWS = num
end)

tools:Seperator()

tools:Textbox("Jump Power", "Enter a value between 24 and 110", true, function(text)
    local num = tonumber(text)
    if not num or num < jpMin or num > jpMax then
        DiscordLib:Notification("faven.lua", "Your Jump Power should be between 24 and 110.", "Okay!")
        return
    end
    currentJP = num
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    hum.WalkSpeed = currentWS
    hum.JumpPower = currentJP
end)

local loverbou = serv:Channel("Misc")

local KEYBIND = Enum.KeyCode.G
local AimlockEnabled = true
local Aiming = false
local currentTarget = nil
local lastAttacker = nil

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://12221967"
toggleSound.Volume = 1
toggleSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function Notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "faven.lua",
            Text = text,
            Duration = 2
        })
    end)
end

local function IsValidTarget(plr)
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
        if IsValidTarget(plr) then
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

local function AimLock()
    if lastAttacker and IsValidTarget(lastAttacker) then
        currentTarget = lastAttacker
    else
        currentTarget = GetClosestToMouseFiltered()
    end

    if currentTarget and IsValidTarget(currentTarget) then
        local cam = workspace.CurrentCamera
        local head = currentTarget.Character.Head
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

loverbou:Bind(
    "Guard/Crim Aimlock",
    Enum.KeyCode.RightShift,
    function()
        if not AimlockEnabled then return end

        Aiming = not Aiming
        toggleSound:Play()

        if Aiming then
            Notify("Guard/Crim Aimlock Enabled")
        else
            Notify("Guard/Crim Aimlock Disabled")
            currentTarget = nil
            lastAttacker = nil
        end
    end
)

RunService.RenderStepped:Connect(function()
    if Aiming and AimlockEnabled then
        AimLock()
    end
end)

loverbou:Seperator()

loverbou:Toggle(
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

loverbou:Seperator()

loverbou:Toggle(
    "Loop DayTime",
    false,
    function(bool)

        if bool then
            _G.DayLoop = true

            task.spawn(function()
                while _G.DayLoop do
                    game:GetService("Lighting").ClockTime = 12
                    task.wait(0.1)
                end
            end)

        else
            _G.DayLoop = false
        end

    end
)

loverbou:Seperator()

loverbou:Button(
    "Boost FPS",
    function()

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

    end
)

local dummymansz = serv:Channel("Credits")

dummymansz:Label("Made by hellamane/I92140I9/steppin0nsteppas")

dummymansz:Seperator()

dummymansz:Label("Updated on 3/17/26 10:28PM")

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

local keys = {}
for name in pairs(teleportList) do
    table.insert(keys, name)
end

local dropdown = tpChannel:Dropdown("Teleport To:", keys, function(selected)
    local cf = teleportList[selected]
    if not cf then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local downTween = TweenService:Create(
        hrp,
        TweenInfo.new(0.35, Enum.EasingStyle.Linear),
        {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
    )
    downTween:Play()
    downTween.Completed:Wait()

    local undergroundTarget = CFrame.new(cf.X, cf.Y - 10, cf.Z)
    local distance = (hrp.Position - undergroundTarget.Position).Magnitude
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
        TweenInfo.new(0.5, Enum.EasingStyle.Linear),
        {CFrame = cf + Vector3.new(0, 3, 0)}
    ):Play()

    task.delay(0.6, function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)
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

tpChannel:Seperator()

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

local drop = tpChannel:Dropdown(
    "Pick A Weapon",
    weaponNames,
    function(choice)
        selectedWeapon = choice
    end
)

tpChannel:Button("Grab Guns", function()
    if not selectedWeapon then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local TweenService = game:GetService("TweenService")

    local originalCFrame = hrp.CFrame
    local targetPos = weaponLocations[selectedWeapon]
    local targetCF = CFrame.new(targetPos)

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    local downTween = TweenService:Create(
        hrp,
        TweenInfo.new(0.35, Enum.EasingStyle.Linear),
        {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
    )
    downTween:Play()
    downTween.Completed:Wait()

    local undergroundTarget = CFrame.new(targetPos.X, targetPos.Y - 10, targetPos.Z)
    local distance = (hrp.Position - undergroundTarget.Position).Magnitude
    local travelTime = math.clamp(distance / 45, 1, 10)

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

    task.wait(0.25)

    local downTween2 = TweenService:Create(
        hrp,
        TweenInfo.new(0.35, Enum.EasingStyle.Linear),
        {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
    )
    downTween2:Play()
    downTween2.Completed:Wait()

    local returnDistance = (hrp.Position - originalCFrame.Position).Magnitude
    local returnTime = math.clamp(returnDistance / 45, 1, 10)

    local returnTween = TweenService:Create(
        hrp,
        TweenInfo.new(returnTime, Enum.EasingStyle.Linear),
        {CFrame = originalCFrame - Vector3.new(0, 10, 0)}
    )
    returnTween:Play()
    returnTween.Completed:Wait()

    local finalUp = TweenService:Create(
        hrp,
        TweenInfo.new(0.4, Enum.EasingStyle.Linear),
        {CFrame = originalCFrame}
    )
    finalUp:Play()
    finalUp.Completed:Wait()

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = true
        end
    end
end)

local tpChannel2 = Teleports:Channel("Players")


local selectedPlayer = nil

local playerDropdown = tpChannel2:Dropdown("Select A Player", {}, function(name)
    selectedPlayer = name
end)

local function refreshPlayerList()
    playerDropdown:Clear()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            playerDropdown:Add(plr.Name)
        end
    end
end

refreshPlayerList()

tpChannel2:Seperator()

tpChannel2:Button("Refresh Playerlist", function()
    refreshPlayerList()
end)

tpChannel2:Seperator()

tpChannel2:Button("Teleport To Player", function()
    if not selectedPlayer then
        DiscordLib:Notification("faven.lua", "No player selected.", "Okay!")
        return
    end

    local target = Players:FindFirstChild(selectedPlayer)
    if not target or not target.Character then
        DiscordLib:Notification("faven.lua", "Player not found.", "Okay!")
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHRP then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    local downTween = TweenService:Create(
        hrp,
        TweenInfo.new(0.35, Enum.EasingStyle.Linear),
        {CFrame = hrp.CFrame * CFrame.new(0, -10, 0)}
    )
    downTween:Play()
    downTween.Completed:Wait()

    local running = true

    task.spawn(function()
        while running and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
            local tHRP = target.Character.HumanoidRootPart
            local undergroundPos = CFrame.new(tHRP.Position.X, tHRP.Position.Y - 10, tHRP.Position.Z)
            local distance = (hrp.Position - tHRP.Position).Magnitude
            local travelTime = math.clamp(distance / 45, 0.5, 6)

            local tpTween = TweenService:Create(
                hrp,
                TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
                {CFrame = undergroundPos}
            )
            tpTween:Play()
            tpTween.Completed:Wait()

            if distance < 6 then
                running = false
            end
        end

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local finalHRP = target.Character.HumanoidRootPart
            TweenService:Create(
                hrp,
                TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                {CFrame = finalHRP.CFrame + Vector3.new(0, 3, 0)}
            ):Play()
        end

        task.delay(0.6, function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end)
end)
