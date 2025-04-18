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

local platform = nil
local platformColor = Color3.fromRGB(100, 100, 100)

local function createPlatform(position)
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 1, 20)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Color = platformColor
    platform.Material = Enum.Material.Concrete
    platform.Position = position + Vector3.new(0, -3, 0)
    platform.Parent = workspace
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

local noclipEnabled = false
local originalCollisionGroup = nil

local function toggleNoClip(enable)
    noclipEnabled = enable
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if enable then
                    originalCollisionGroup = part.CollisionGroup
                    part.CollisionGroup = "NoCollision"
                else
                    part.CollisionGroup = originalCollisionGroup
                end
            end
        end
        if Humanoid then
            Humanoid.WalkSpeed = enable and 50 or 16
            Humanoid.JumpPower = enable and 0 or 50
        end
    end
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

local collectedEggs = {}
local isCollectingEggs = false
local collectedCoins = {}
local isCollectingCoins = false
local collectionInterval = 1
local collectionTimeout = 0.3

local function collectSingle(objectType)
    local collectedTable
    local isCollecting
    local findName
    if objectType == "egg" then
        collectedTable = collectedEggs
        isCollecting = isCollectingEggs
        findName = "egg"
    elseif objectType == "coin" then
        collectedTable = collectedCoins
        isCollecting = isCollectingCoins
        findName = "coin"
    else
        return
    end

    if isCollecting then
        local closestObj = nil
        local closestDistance = math.huge

        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name:lower():find(findName) and obj:IsA("BasePart") and not collectedTable[obj] then
                local distance = (RootPart.Position - obj.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestObj = obj
                end
            end
        end

        if closestObj then
            collectedTable[closestObj] = {
                originalPosition = closestObj.Position,
                transparency = closestObj.Transparency,
                canCollide = closestObj.CanCollide,
            }
            closestObj.Transparency = 1
            closestObj.CanCollide = false

            local tweenInfo = TweenInfo.new(collectionTimeout, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = TweenService:Create(closestObj, tweenInfo, { Position = RootPart.Position })
            tween:Play()

            tween.Completed:Connect(function()
                if closestObj and IsValid(closestObj) then
                    closestObj:Destroy()
                    firetouchinterest(LocalPlayer.Character.PrimaryPart, closestObj, 1)
                    firetouchinterest(LocalPlayer.Character.PrimaryPart, closestObj, 0)
                end
            end)
        end
    else
        for obj, data in pairs(collectedTable) do
            if obj and IsValid(obj) then
                local tweenInfo = TweenInfo.new(collectionTimeout, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(obj, tweenInfo, { Position = data.originalPosition })
                tween:Play()
                tween.Completed:Connect(function()
                    obj.Transparency = data.transparency
                    obj.CanCollide = data.canCollide
                end)
            else
                warn("Object was already destroyed:", obj)
            end
        end
        if objectType == "egg" then
            collectedEggs = {}
        elseif objectType == "coin" then
            collectedCoins = {}
        end
    end
end

local function autoCollect()
    if isCollectingEggs then
        collectSingle("egg")
    end
    if isCollectingCoins then
        collectSingle("coin")
    end
    task.delay(collectionTimeout, autoCollect)
end

local function toggleEggCollection(bool)
    isCollectingEggs = bool
    if not bool then
        for obj, data in pairs(collectedEggs) do
            if obj and IsValid(obj) then
                local tweenInfo = TweenInfo.new(collectionTimeout, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(obj, tweenInfo, { Position = data.originalPosition })
                tween:Play()
                tween.Completed:Connect(function()
                    obj.Transparency = data.transparency
                    obj.CanCollide = data.canCollide
                end)
            end
        end
        collectedEggs = {}
    end
end

local function toggleCoinCollection(bool)
    isCollectingCoins = bool
    if not bool then
        for obj, data in pairs(collectedCoins) do
            if obj and IsValid(obj) then
                local tweenInfo = TweenInfo.new(collectionTimeout, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(obj, tweenInfo, { Position = data.originalPosition })
                tween:Play()
                tween.Completed:Connect(function()
                    obj.Transparency = data.transparency
                    obj.CanCollide = data.canCollide
                end)
            end
        end
        collectedCoins = {}
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
woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    getgenv().CollectEggsSlowly = bool
    if bool then
        spawn(function()
            while getgenv().CollectEggsSlowly do
                local folder = workspace:FindFirstChild("Coins")
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj.Name == "Egg" and obj:FindFirstChild("TouchInterest") then
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 0)
                            task.wait(0.7)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)
woogy:Toggle("Collect Coins Slowly Detectable From Leaderboard", false, function(bool)
    getgenv().CollectCoinsSlowly = bool
    if bool then
        spawn(function()
            while getgenv().CollectCoinsSlowly do
                local folder = workspace:FindFirstChild("Coins")
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj.Name == "Coin" and obj:FindFirstChild("TouchInterest") then
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, obj, 0)
                            task.wait(0.7)
                        end
                    end
                end
                task.wait(1)
            end
        end)
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
