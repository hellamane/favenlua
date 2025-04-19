--// Dominus Lifting Simulator | Discord #steppin0nsteppas
local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local coinOriginalPositions = {}
local eggOriginalPositions = {}

local function storeOriginalPositions()
    for _, obj in pairs(workspace.Coins:GetChildren()) do
        if obj:IsA("MeshPart") and obj.Name == "Coin" then
            coinOriginalPositions[obj] = obj.Position
        elseif obj:IsA("MeshPart") and obj.Name == "Egg" then
            eggOriginalPositions[obj] = obj.Position
        end
    end
end

storeOriginalPositions()

local function collectCoins()
    while getgenv().CollectCoins do
        for _, coin in pairs(workspace.Coins:GetChildren()) do
            if coin:IsA("MeshPart") and coin.Name == "Coin" then
                firetouchinterest(coin, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                task.wait(0.3)
                firetouchinterest(coin, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            end
        end
        task.wait(1)
    end

    for coin, originalPosition in pairs(coinOriginalPositions) do
        if coin:IsA("MeshPart") and coin.Name == "Coin" then
            coin.Position = originalPosition
        end
    end
end

local function collectEggs()
    while getgenv().CollectEggs do
        for _, egg in pairs(workspace.Coins:GetChildren()) do
            if egg:IsA("MeshPart") and egg.Name == "Egg" then
                firetouchinterest(egg, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                task.wait(0.3)
                firetouchinterest(egg, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            end
        end
        task.wait(1)
    end

    for egg, originalPosition in pairs(eggOriginalPositions) do
        if egg:IsA("MeshPart") and egg.Name == "Egg" then
            egg.Position = originalPosition
        end
    end
end

local function smoothTeleport(cframe)
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return end
    createPlatform(cframe.Position)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(character.PrimaryPart, tweenInfo, {CFrame = cframe})
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

RunService.Heartbeat:Connect(checkForMods)
checkForMods()

local spawnCFrame = CFrame.new(118, 1704, 5494)

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

local function smoothTeleportTarget(targetCFrame, platformColor)
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart then return end
    character.PrimaryPart.CanCollide = false
    local platform = createPlatform(targetCFrame.Position, platformColor)
    local tween = TweenService:Create(character.PrimaryPart, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    return platform
end

local lastSafePosition = nil
local antiVoidEnabled = false
local antiVoidConnection = nil

local function findSpawnLocation()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            print("Found SpawnLocation:", obj.Name, obj.CFrame)
            return obj.CFrame
        end
    end
    warn("No SpawnLocation found in workspace!")
    return spawnCFrame -- Fallback to the initial spawn CFrame
end

local function checkVoid()
    if antiVoidEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPosition = LocalPlayer.Character.HumanoidRootPart.Position
        if rootPosition.Y < -50 then
            print("Anti-Void triggered at Y:", rootPosition.Y)
            local spawnPoint = findSpawnLocation()
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = spawnPoint})
            tween:Play()
            print("Anti-Void: Tweening to spawn:", spawnPoint.Position)
        end
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
woogy:Toggle("Collect Coins Slowly", false, function(bool)
    getgenv().CollectCoins = bool
    if bool then
        collectCoins()
    end
end)

woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    getgenv().CollectEggs = bool
    if bool then
        collectEggs()
    end
end)

local op = serv:Channel("OP Features")
op:Button("Toggle OP Mode", function()
    local opEnabled = not getgenv().OPMode
    getgenv().OPMode = opEnabled
    local player = game:GetService("Players").LocalPlayer
    if not player then return end
    local boosts = player:FindFirstChild("Boosts")
    if not boosts then return end
    local OPness = player:FindFirstChild("OPness")
    if OPness then
        for _, setting in ipairs(OPness:GetChildren()) do
            if setting:IsA("BoolValue") then setting.Value = opEnabled end
        end
    end
    local numberValues = {
        boosts:FindFirstChild("QuadStrength"), boosts:FindFirstChild("TripleHatch"),
        boosts:FindFirstChild("QuadCoins"), boosts:FindFirstChild("DoubleXP"),
        boosts:FindFirstChild("DoubleTokens"), boosts:FindFirstChild("DoubleCoins"),
        boosts:FindFirstChild("DecaStrength"), boosts:FindFirstChild("AutoTrain")
    }
    for _, boost in ipairs(numberValues) do
        if boost and boost:IsA("NumberValue") then boost.Value = opEnabled and 1000 or 1 end
    end
end)

local gotn = serv:Channel("Misc")

gotn:Toggle("Anti-Void", false, function(bool)
    antiVoidEnabled = bool
    if bool then
        lastSafePosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or nil
        antiVoidConnection = RunService.Heartbeat:Connect(checkVoid)
    else
        if antiVoidConnection then
            antiVoidConnection:Disconnect()
            antiVoidConnection = nil
        end
        lastSafePosition = nil
    end
end)

gotn:Seperator()
gotn:Button("Better Quality (rips)", function()
    _G.Settings = {
        Players = {["Ignore Me"] = true, ["Ignore Others"] = true},
        Meshes = {Destroy = false, LowDetail = true},
        Images = {Invisible = true, LowDetail = false, Destroy = false},
        ["No Particles"] = true, ["No Camera Effects"] = true, ["No Explosions"] = true,
        ["No Clothes"] = true, ["Low Water Graphics"] = true, ["No Shadows"] = true,
        ["Low Rendering"] = true, ["Low Quality Parts"] = true
    }
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
end)
gotn:Seperator()

gotn:Button("FPS Boost", function()
    local function optimizeSettings()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        local function removeParts(instance)
            if instance:IsA("BasePart") then instance.Material = Enum.Material.SmoothPlastic instance.Reflectance = 0 instance.CastShadow = false
            elseif instance:IsA("Decal") or instance:IsA("Texture") then instance:Destroy()
            elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then instance:Destroy() end
        end
        for _, instance in pairs(workspace:GetDescendants()) do removeParts(instance) end
        workspace.DescendantAdded:Connect(removeParts)
    end
    optimizeSettings()
end)
