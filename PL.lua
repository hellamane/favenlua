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

            -- Save original size once
            if not OriginalSizes[part] then
                OriginalSizes[part] = part.Size
            end

            part.Size = Vector3.new(8, 8, 8) -- bigger hitbox
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

local KEYBIND = Enum.KeyCode.G
local AimlockEnabled = true
local Aiming = false
local currentTarget = nil

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://12221967"
toggleSound.Volume = 1
toggleSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function Notify(text)
    DiscordLib:Notification("faven.lua", text, "Okay!")
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
        cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.Head.Position)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == KEYBIND and AimlockEnabled then
        Aiming = not Aiming
        if not Aiming then currentTarget = nil end
    end
end)

RunService.RenderStepped:Connect(function()
    if Aiming and AimlockEnabled then AimLock() end
end)

tools:Seperator()

tools:Button("Aimlock", function()
    Notify("Press G to toggle Aimlock")
end)

tools:Seperator()

local ESPEnabled = false
local espData = {}
local espPlayerAddedConn

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
        if hum.Health <= 0 then
            clearESP(plr)
        end
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
        conns = conns
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
end

local function disableESP()
    ESPEnabled = false

    if espPlayerAddedConn then
        espPlayerAddedConn:Disconnect()
        espPlayerAddedConn = nil
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

local dummymansz = serv:Channel("Credits")

dummymansz:Label("Made by hellamane/I92140I9/steppin0nsteppas")

local Teleports = win:Server("Teleports", "")
local tpChannel = Teleports:Channel("Locations")

local teleportList = {
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

    local distance = (hrp.Position - cf.Position).Magnitude
    local speed = 60
    local travelTime = math.clamp(distance / speed, 0.5, 6)

    local tpTween = TweenService:Create(
        hrp,
        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
        {CFrame = cf}
    )
    tpTween:Play()
    tpTween.Completed:Wait()

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end)

tpChannel:Button("Clear Teleports", function()
    teleportList = {}
    dropdown:Clear()
end)

tpChannel:Button("Add Custom CFrame", function()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local name = "Custom_" .. tostring(math.random(1000, 9999))
    teleportList[name] = hrp.CFrame
    dropdown:Add(name)
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

    local distance = (hrp.Position - targetHRP.Position).Magnitude
    local speed = 60
    local travelTime = math.clamp(distance / speed, 0.5, 6)

    local tpTween = TweenService:Create(
        hrp,
        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
        {CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)}
    )
    tpTween:Play()
    tpTween.Completed:Wait()

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end)
