--// Dominus Lifting Simulator | Discord #steppin0nsteppas
getgenv().CollectCoins = false
getgenv().CollectEggs = false
getgenv().AntiVoidEnabled = false
getgenv().OPMode = false
getgenv().AutoTrain = false

local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Function to notify mod presence
local function notifyModPresence()
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    local Notification = Instance.new("TextLabel", Frame)
    local UICorner = Instance.new("UICorner")

    Frame.Size = UDim2.new(0, 300, 0, 100)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    Frame.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
    Frame.Active = true
    Frame.Draggable = true
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame

    Notification.Size = UDim2.new(1, 0, 1, 0)
    Notification.BackgroundTransparency = 1
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.TextScaled = true
    Notification.Text = "Mod is in the server!"

    wait(5) -- Display notification for 5 seconds
    ScreenGui:Destroy()
end

-- Disable all features when a mod is detected
local function disableFeatures()
    getgenv().CollectCoins = false
    getgenv().CollectEggs = false
    getgenv().OPMode = false
    getgenv().AutoTrain = false
end

-- Enable features when no mods are present
local function enableFeatures()
    getgenv().CollectCoins = true
    getgenv().CollectEggs = true
end

-- Check for moderators in the server
local function checkForMods()
    local modDetected = false
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(modIDs, player.UserId) then
            modDetected = true
            notifyModPresence()
            disableFeatures()
            break
        end
    end

    if not modDetected then
        enableFeatures()
    end
end

Players.PlayerAdded:Connect(function(player)
    if table.find(modIDs, player.UserId) then
        notifyModPresence()
        disableFeatures()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if table.find(modIDs, player.UserId) then
        checkForMods()
    end
end)

RunService.Heartbeat:Connect(checkForMods)

-- Create gamepasses and set them to true if missing
local function ensureGamepasses()
    local gamepasses = {"Spam", "InfEquip", "Diamond", "Mystic", "Amethyst", "Holy", "Dual", "VIP", "Double", "DoubleCoins", "DoubleEnergy", "Flying", "Wear"}
    for _, passName in ipairs(gamepasses) do
        if not Players.LocalPlayer:FindFirstChild(passName) then
            local newBool = Instance.new("BoolValue")
            newBool.Name = passName
            newBool.Value = true
            newBool.Parent = Players.LocalPlayer
        else
            Players.LocalPlayer[passName].Value = true
        end
    end
end

ensureGamepasses()

-- Collect coins functionality
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
end

-- Collect eggs functionality
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
end

-- Auto train functionality
local function autoTrain()
    while getgenv().AutoTrain do
        local player = Players.LocalPlayer
        if player then
            local boosts = player:FindFirstChild("Boosts")
            if boosts then
                for _, setting in ipairs(boosts:GetChildren()) do
                    if setting:IsA("BoolValue") or setting:IsA("NumberValue") then
                        setting.Value = true
                    end
                end
            end
        end
        task.wait(1) -- Adjust delay based on training cooldown
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
    if not checkForMods() then
        getgenv().CollectCoins = bool
        if bool then
            collectCoins()
        end
    else
        notifyModPresence()
    end
end)

woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggs = bool
        if bool then
            collectEggs()
        end
    else
        notifyModPresence()
    end
end)

local op = serv:Channel("OP Features")

op:Toggle("Activate OP Mode", false, function(bool)
    if not checkForMods() then
        getgenv().OPMode = bool
        ensureGamepasses()
        if bool then
            local boosts = Players.LocalPlayer:FindFirstChild("Boosts")
            if boosts then
                for _, boost in ipairs(boosts:GetChildren()) do
                    if boost:IsA("BoolValue") or boost:IsA("NumberValue") then
                        boost.Value = true
                    end
                end
            end
        end
    else
        notifyModPresence()
    end
end)

op:Toggle("Auto Train", false, function(bool)
    if not checkForMods() then
        getgenv().AutoTrain = bool
        if bool then
            autoTrain()
        end
    else
        notifyModPresence()
    end
end)

local misc = serv:Channel("Misc")

misc:Toggle("Anti-Void", false, function(bool)
    getgenv().AntiVoidEnabled = bool
    if bool then
        RunService.Heartbeat:Connect(function()
            local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Position.Y < -50 then
                local spawn = Workspace:FindFirstChild("SpawnLocation")
                if spawn then
                    rootPart.CFrame = spawn.CFrame
                end
            end
        end)
    else
        if getgenv().AntiVoidConnection then
            getgenv().AntiVoidConnection:Disconnect()
            getgenv().AntiVoidConnection = nil
        end
    end
end)
