--// Dominus Lifting Simulator | Discord #steppin0nsteppas
getgenv().CollectCoins = false
getgenv().CollectEggs = false
getgenv().OPMode = false

local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local coinOriginalPositions = {}
local eggOriginalPositions = {}

local function storeOriginalPositions()
    for _, obj in pairs(Workspace.Coins:GetChildren()) do
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
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        for _, coin in pairs(Workspace.Coins:GetChildren()) do
            if coin:IsA("MeshPart") and coin.Name == "Coin" then
                firetouchinterest(coin, rootPart, 0)
                task.wait(0.3)
                firetouchinterest(coin, rootPart, 1)
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
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        for _, egg in pairs(Workspace.Coins:GetChildren()) do
            if egg:IsA("MeshPart") and egg.Name == "Egg" then
                firetouchinterest(egg, rootPart, 0)
                task.wait(0.3)
                firetouchinterest(egg, rootPart, 1)
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
op:Button("Activate OP Mode", function()
    getgenv().OPMode = not getgenv().OPMode
    local opEnabled = getgenv().OPMode
    local player = Players.LocalPlayer
    if not player then return end

    -- Apply OP settings to boosts or similar values
    local boosts = player:FindFirstChild("Boosts")
    if boosts then
        for _, setting in ipairs(boosts:GetChildren()) do
            if setting:IsA("BoolValue") then
                setting.Value = opEnabled
            end
        end
        local numberValues = {
            boosts:FindFirstChild("QuadStrength"), boosts:FindFirstChild("TripleHatch"),
            boosts:FindFirstChild("QuadCoins"), boosts:FindFirstChild("DoubleXP"),
            boosts:FindFirstChild("DoubleTokens"), boosts:FindFirstChild("DoubleCoins"),
            boosts:FindFirstChild("DecaStrength"), boosts:FindFirstChild("AutoTrain")
        }
        for _, boost in ipairs(numberValues) do
            if boost and boost:IsA("NumberValue") then
                boost.Value = opEnabled and 1000 or 1
            end
        end
    end

    -- Print OP Mode status
    if opEnabled then
        print("OP Mode Activated!")
    else
        print("OP Mode Deactivated!")
    end
end)

local gotn = serv:Channel("Misc")

gotn:Toggle("Anti-Void", false, function(bool)
    getgenv().AntiVoidEnabled = bool
    if bool then
        RunService.Heartbeat:Connect(function()
            local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Position.Y < -50 then
                rootPart.CFrame = Workspace.SpawnLocation.CFrame
            end
        end)
    else
        if getgenv().AntiVoidConnection then
            getgenv().AntiVoidConnection:Disconnect()
            getgenv().AntiVoidConnection = nil
        end
    end
end)

gotn:Button("FPS Boost", function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            descendant:Destroy()
        end
    end)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v:Destroy()
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end

    local settings = Players.LocalPlayer:FindFirstChild("Settings")
    if settings then
        local boolValues = {
            settings:FindFirstChild("HideOtherPets"),
            settings:FindFirstChild("HideRebirthPopup"),
            settings:FindFirstChild("HideYourPets"),
        }
        for _, boolValue in pairs(boolValues) do
            if boolValue and boolValue:IsA("BoolValue") then
                boolValue.Value = true
            end
        end
    end
end)
