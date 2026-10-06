local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if getgenv().FavenScriptCleanup then
    pcall(function()
        getgenv().FavenScriptCleanup()
    end)
end

local activeConnections = {}
local activeLoops = { Running = true }

getgenv().FavenScriptCleanup = function()
    activeLoops.Running = false

    for _, conn in ipairs(activeConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(activeConnections)

    if getgenv().ActivePlatform then
        pcall(function()
            getgenv().ActivePlatform:Destroy()
            getgenv().ActivePlatform = nil
        end)
    end

    local targets = {game:GetService("CoreGui"), LocalPlayer:FindFirstChildOfClass("PlayerGui")}
    for _, container in ipairs(targets) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child.Name:lower():find("discord") or child.Name == "faven.lua" or child:FindFirstChild("faven.lua") then
                    child:Destroy()
                end
            end
        end
    end
end

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

local function sendNotification(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "faven.lua",
            Text = msg,
            Duration = 5,
            Icon = "rbxassetid://10028537753"
        })
    end)
end

local function playIntroTransition()
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "IntroSplashGui"
    splashGui.ResetOnSpawn = false
    splashGui.IgnoreGuiInset = true
    splashGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.Parent = splashGui

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(0, 300, 0, 300)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = "rbxassetid://10028537753"
    imageLabel.ImageTransparency = 1
    imageLabel.Parent = splashGui

    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(bg, tweenInfo, {BackgroundTransparency = 0.3}):Play()
    local fadeIn = TweenService:Create(imageLabel, tweenInfo, {ImageTransparency = 0})
    fadeIn:Play()
    fadeIn.Completed:Wait()

    task.wait(1.2)

    TweenService:Create(bg, tweenInfo, {BackgroundTransparency = 1}):Play()
    local fadeOut = TweenService:Create(imageLabel, tweenInfo, {ImageTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Wait()

    splashGui:Destroy()

    local gameName = "Roblox Game"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name
        end
    end)

    sendNotification("You're currently playing " .. gameName .. ".")
end

playIntroTransition()

local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Pass The Bomb", "")

local automationz = serv:Channel("Automations")

local autoPassEnabled = false
local avoidBombEnabled = false

local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end

    return nearestPlayer
end

automationz:Toggle(
    "Pass Bomb",
    false,
    function(bool)
        autoPassEnabled = bool
        if autoPassEnabled then
            task.spawn(function()
                while autoPassEnabled and activeLoops.Running do
                    local lpFolder = workspace:FindFirstChild("LocalPlayer") or workspace:FindFirstChild(LocalPlayer.Name)
                    local gotBomb = lpFolder and lpFolder:FindFirstChild("GotBombValue") and lpFolder.GotBombValue.Value
                    
                    if gotBomb then
                        local target = getNearestPlayer()
                        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            local passPart = lpFolder:FindFirstChild("BombPassPart")
                            local targetPos = target.Character.HumanoidRootPart.CFrame

                            if passPart and passPart:IsA("BasePart") then
                                passPart.CFrame = targetPos
                            elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
)

automationz:Seperator()

automationz:Toggle(
    "Avoid Bomb",
    false,
    function(bool)
        avoidBombEnabled = bool
        if avoidBombEnabled then
            task.spawn(function()
                while avoidBombEnabled and activeLoops.Running do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local myPos = LocalPlayer.Character.HumanoidRootPart.Position

                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetFolder = workspace:FindFirstChild(player.Name)
                                local targetHasBomb = (player.Character:FindFirstChild("Bomb") ~= nil) or 
                                                      (targetFolder and targetFolder:FindFirstChild("GotBombValue") and targetFolder.GotBombValue.Value)

                                if targetHasBomb then
                                    local enemyRoot = player.Character.HumanoidRootPart
                                    local dist = (enemyRoot.Position - myPos).Magnitude

                                    if dist <= 7 then
                                        local targetCFrame = enemyRoot.CFrame * CFrame.new(0, 5, 3)
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
                                        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        end
    end
)

local playertweaking = serv:Channel("Player Settings")

local currentWalkSpeed = 16
local currentJumpPower = 50
local loopStatsEnabled = false

playertweaking:Slider(
    "WalkSpeed",
    16,
    75,
    16,
    function(value)
        currentWalkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
)

playertweaking:Seperator()

playertweaking:Slider(
    "JumpPower",
    0,
    50,
    50,
    function(value)
        currentJumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
)

playertweaking:Seperator()

playertweaking:Toggle(
    "Loop Stats",
    false,
    function(bool)
        loopStatsEnabled = bool
        if loopStatsEnabled then
            task.spawn(function()
                while loopStatsEnabled and activeLoops.Running do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        hum.WalkSpeed = currentWalkSpeed
                        hum.JumpPower = currentJumpPower
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
)

playertweaking:Seperator()

local noclipEnabled = false
local noclipConn = nil

playertweaking:Toggle(
    "Noclip",
    false,
    function(bool)
        noclipEnabled = bool
        if noclipEnabled then
            sendNotification("Make sure you don't noclip out the map or you'll be kicked/killed")
            noclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(activeConnections, noclipConn)
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end
    end
)

playertweaking:Seperator()

local infJumpEnabled = false

playertweaking:Toggle(
    "Inf Jump",
    false,
    function(bool)
        infJumpEnabled = bool
        if infJumpEnabled then
            sendNotification("Make sure you don't jump too high or you'll be kicked/killed")
        end
    end
)

playertweaking:Seperator()

local platformEnabled = false
local platformConn = nil
local platformYOffset = -3.5

playertweaking:Toggle(
    "Platform",
    false,
    function(bool)
        platformEnabled = bool
        
        if getgenv().ActivePlatform then
            getgenv().ActivePlatform:Destroy()
            getgenv().ActivePlatform = nil
        end
        if platformConn then
            platformConn:Disconnect()
            platformConn = nil
        end

        if platformEnabled then
            platformYOffset = -3.5
            local platform = Instance.new("Part")
            platform.Name = "FavenPlatform"
            platform.Size = Vector3.new(15, 1, 15)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Material = Enum.Material.SmoothPlastic
            platform.Color = Color3.fromRGB(20, 20, 20)
            platform.Transparency = 0.85
            platform.Parent = workspace

            getgenv().ActivePlatform = platform

            platformConn = RunService.RenderStepped:Connect(function()
                if platformEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().ActivePlatform then
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                        platformYOffset = platformYOffset + 0.35
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                        platformYOffset = platformYOffset - 0.35
                    end

                    local root = LocalPlayer.Character.HumanoidRootPart
                    getgenv().ActivePlatform.CFrame = root.CFrame * CFrame.new(0, platformYOffset, 0)
                end
            end)
            table.insert(activeConnections, platformConn)

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local deathConn
                deathConn = hum.Died:Connect(function()
                    if getgenv().ActivePlatform then
                        getgenv().ActivePlatform:Destroy()
                        getgenv().ActivePlatform = nil
                    end
                    if platformConn then
                        platformConn:Disconnect()
                        platformConn = nil
                    end
                    if deathConn then deathConn:Disconnect() end
                end)
                table.insert(activeConnections, deathConn)
            end
        end
    end
)

local jumpConn = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
table.insert(activeConnections, jumpConn)

local settingsChan = serv:Channel("Settings")

local antiAfkConn = nil

settingsChan:Toggle(
    "Anti AFK",
    false,
    function(bool)
        if bool then
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
            table.insert(activeConnections, antiAfkConn)
        else
            if antiAfkConn then
                antiAfkConn:Disconnect()
                antiAfkConn = nil
            end
        end
    end
)

settingsChan:Seperator()

settingsChan:Button(
    "Low Graphics",
    function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.Technology = Enum.Technology.Compatibility

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") 
               or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end

        if workspace:FindFirstChildOfClass("Terrain") then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            terrain.Material = Enum.Material.SmoothPlastic
            pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
        end

        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Material = Enum.Material.SmoothPlastic
                descendant.Reflectance = 0
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                descendant:Destroy()
            elseif descendant:IsA("MeshPart") then
                descendant.TextureID = ""
            elseif descendant:IsA("SpecialMesh") then
                descendant.TextureId = ""
            elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") 
                   or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
                descendant.Enabled = false
            end
        end
    end
)
