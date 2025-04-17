local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local StarterGui = game:GetService("StarterGui")

local function showNotification()
    StarterGui:SetCore("SendNotification", {
        Title = "Ferret Hub V2",
        Text = "Change Rebirths While Using OP Features",
        Duration = 10,
        Button1 = "Join Discord",
        Callback = function(response)
            if response == "Button1" then
                setclipboard("https://discord.gg/c8hPCcPbNq")
                StarterGui:SetCore("SendNotification", {
                    Title = "Discord",
                    Text = "Discord invite copied to clipboard!",
                    Duration = 3
                })
            end
        end
    })
end

showNotification()


local function configureOP()
    local player = game:GetService("Players").LocalPlayer
    

    if player:FindFirstChild("TierData") then
        local OPness = {
            player.TierData:FindFirstChild("Basic") and player.TierData.Basic:FindFirstChild("Active"),
            player.TierData:FindFirstChild("Cool") and player.TierData.Cool:FindFirstChild("Active"),
            player.TierData:FindFirstChild("Legend") and player.TierData.Legend:FindFirstChild("Active")
        }
        
        for _, setting in ipairs(OPness) do
            if setting then
                setting.Value = true
            end
        end
    end

    if player:FindFirstChild("Boosts") then
        local boostPaths = {
            "QuadStrength",
            "TripleHatch",
            "QuadCoins",
            "DoubleXP",
            "DoubleTokens",
            "DoubleCoins",
            "DecaStrength",
            "AutoTrain"
        }
        
        for _, boostName in ipairs(boostPaths) do
            local boost = player.Boosts:FindFirstChild(boostName)
            if boost then
                boost.Value = 1000
            end
        end
    end
end


local platform = nil
local platformColor = Color3.fromRGB(100, 100, 100) -- Grey color

local function createPlatform(position)
    if platform then platform:Destroy() end
    
    platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 1, 20)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Color = platformColor
    platform.Material = Enum.Material.Concrete
    platform.Position = position + Vector3.new(0, -3, 0) -- Below target
    platform.Parent = workspace
end


local function smoothTeleport(cframe)
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return end
    
    createPlatform(cframe.Position)
    
    local tweenInfo = TweenInfo.new(
        1, -- Time
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(
        character.PrimaryPart,
        tweenInfo,
        {CFrame = cframe}
    )
    
    tween:Play()
    tween.Completed:Wait()
end


local function teleportToAnotherServer()
    local gamePlaceId = game.PlaceId
    local success, err = pcall(function()
        TeleportService:Teleport(gamePlaceId)
    end)
    if not success then
        warn("Failed to teleport: " .. err)
    else
        print("Teleporting to another server!")
    end
end


local function checkForMods()
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(modIDs, player.UserId) then
            teleportToAnotherServer()
            print("A mod/owner joined or is present! Teleporting to another server!")
            return
        end
    end
end


Players.PlayerAdded:Connect(function(player)
    if table.find(modIDs, player.UserId) then
        teleportToAnotherServer()
        print("A mod/owner joined! Teleporting to another server!")
    end
end)

RunService.Heartbeat:Connect(function()
    checkForMods()
end)

checkForMods()

local spawnCFrame = CFrame.new(118, 1704, 5494)
local kothCFrame = CFrame.new(535, 1698, 2293)
local flagCFrame = CFrame.new(-281, 1627, 5831)

local function createPlatform(position, color)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Anchored = true
    platform.CanCollide = false
    platform.Transparency = 0.7
    platform.Color = color
    platform.Material = Enum.Material.Neon
    platform.Position = position
    platform.Parent = workspace
    return platform
end

local function smoothTeleport(targetCFrame, platformColor)
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return end
    
    character.PrimaryPart.CanCollide = false
    local platform = createPlatform(targetCFrame.Position, platformColor)
    
    local tween = TweenService:Create(
        character.PrimaryPart,
        TweenInfo.new(1.5, Enum.EasingStyle.Quad),
        {CFrame = targetCFrame}
    )
    tween:Play()
    tween.Completed:Wait()
    return platform
end

local kothPlatform = nil
local function handleKOTH(toggle)
    if toggle then
        kothPlatform = smoothTeleport(kothCFrame, Color3.fromRGB(255, 0, 0))
    else
        local tween = TweenService:Create(
            LocalPlayer.Character.PrimaryPart,
            TweenInfo.new(1.5, Enum.EasingStyle.Quad),
            {CFrame = spawnCFrame}
        )
        tween:Play()
        tween.Completed:Connect(function()
            LocalPlayer.Character.PrimaryPart.CanCollide = true
            if kothPlatform then kothPlatform:Destroy() end
        end)
    end
end

local flagPlatform = nil
local function handleFlag(toggle)
    if toggle then
        flagPlatform = smoothTeleport(flagCFrame, Color3.fromRGB(0, 0, 255))
    else
        local tween = TweenService:Create(
            LocalPlayer.Character.PrimaryPart,
            TweenInfo.new(1.5, Enum.EasingStyle.Quad),
            {CFrame = spawnCFrame}
        )
        tween:Play()
        tween.Completed:Connect(function()
            LocalPlayer.Character.PrimaryPart.CanCollide = true
            if flagPlatform then flagPlatform:Destroy() end
        end)
    end
end


local flying = false
local FlyTrack = nil
local currentFlyDirection = Vector3.zero
local flyConnection = nil


local function initializeFlying(character, humanoid)
    local FlyAnimation = Instance.new("Animation")
    FlyAnimation.AnimationId = "rbxassetid://11372296693"
    local track = humanoid:LoadAnimation(FlyAnimation)
    return track
end

local function updateFlyDirection()
    local direction = Vector3.zero
    local camera = workspace.CurrentCamera
    local UIS = game:GetService("UserInputService")
    if UIS:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + camera.CFrame.LookVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - camera.CFrame.LookVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - camera.CFrame.RightVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + camera.CFrame.RightVector
    end

    if direction.Magnitude == 0 then
        direction = currentFlyDirection
    else
        currentFlyDirection = direction.Unit
    end
    return direction.Unit
end

local function startFlying()
    if not flying then
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        flying = true
        FlyTrack = initializeFlying(character, humanoid)
        FlyTrack:Play()

        workspace.Gravity = 0
        humanoid.JumpPower = 0

        currentFlyDirection = rootPart.CFrame.LookVector

        flyConnection = RunService.RenderStepped:Connect(function()
            if flying then
                local flyDirection = updateFlyDirection()
                local finalVelocity = flyDirection * 60
                rootPart.Velocity = Vector3.new(finalVelocity.X, finalVelocity.Y, finalVelocity.Z)
            end
        end)
    end
end

local function stopFlying()
    if flying then
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        flying = false
        if FlyTrack then
            FlyTrack:Stop()
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        -- Restore gravity and jump
        workspace.Gravity = 196.2
        humanoid.JumpPower = 50
        rootPart.Velocity = Vector3.new(0, -30, 0)
    end
end

local function toggleFly()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Info")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Welcome to Ferret Hub!")
lbls:Seperator()

local woogy = serv:Channel("Autofarm")

woogy:Label("Use Noclip for KOTH.")

woogy:Toggle("Auto KOTH", false, handleKOTH)

woogy:Seperator()

woogy:Toggle("Auto Capture Flag", false, handleFlag)

woogy:Seperator()

woogy:Toggle("Collect Eggs", false, function(bool)
    getgenv().CollectEggs = bool
    if bool then
        spawn(function()
            while getgenv().CollectEggs do
                local folder = workspace:FindFirstChild("Coins")
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj.Name == "Egg" and obj:FindFirstChild("TouchInterest") then
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 0)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

woogy:Seperator()

woogy:Toggle("Collect Coins Detectable From Leaderboard", false, function(bool)
    getgenv().CollectCoins = bool
    if bool then
        spawn(function()
            while getgenv().CollectCoins do
                local folder = workspace:FindFirstChild("Coins")
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj.Name == "Coin" and obj:FindFirstChild("TouchInterest") then
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 0)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local op = serv:Channel("OP Features")

op:Label("Use The Rebirth Script Located In The Discord So It Works Fully.")
op:Toggle("Enable OP Mode", false, function(bool)
    getgenv().OPMode = bool
    if bool then
        pcall(configureOP)
    end
end)

op:Seperator()

op:Label("Click The Fly Button To Fly")

op:Button("Activate Flight", toggleFly)

local function toggleFly()
    toggleFly()
end

local gotn = serv:Channel("Misc")

gotn:Button("FPS Boost", function()
    local function optimizeSettings()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0

        local function removeParts(instance)
            if instance:IsA("BasePart") then
                instance.Material = Enum.Material.SmoothPlastic
                instance.Reflectance = 0
                instance.CastShadow = false
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                instance:Destroy()
            elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
                instance:Destroy()
            end
        end

        for _, instance in pairs(workspace:GetDescendants()) do
            removeParts(instance)
        end

        workspace.DescendantAdded:Connect(function(instance)
            removeParts(instance)
        end)
    end

    optimizeSettings()
end)

gotn:Seperator()

gotn:Button("Better Quality (rips)", function()
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true
        },
        Meshes = {
            Destroy = false,
            LowDetail = true
        },
        Images = {
            Invisible = true,
            LowDetail = false,
            Destroy = false,
        },
        ["No Particles"] = true,
        ["No Camera Effects"] = true,
        ["No Explosions"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true
    }
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
end)
