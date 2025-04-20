--// Dominus Lifting Simulator | Discord #steppin0nsteppas
getgenv().CollectCoins = false
getgenv().CollectEggs = false
getgenv().CollectCoinsStealthier = false
getgenv().CollectEggsStealthier = false
getgenv().AntiVoidEnabled = false
getgenv().OPMode = false
getgenv().AutoTrain = false

local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local modNotificationGui

local function updateModNotification(modDetected)
    if modDetected then
        if not modNotificationGui then
            modNotificationGui = Instance.new("ScreenGui", game.CoreGui)
            modNotificationGui.Name = "ModNotification"

            local NotificationFrame = Instance.new("Frame", modNotificationGui)
            NotificationFrame.Size = UDim2.new(0, 200, 0, 50)
            NotificationFrame.Position = UDim2.new(0.5, -100, 1, -100)
            NotificationFrame.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
            NotificationFrame.BorderSizePixel = 0

            local NotificationText = Instance.new("TextLabel", NotificationFrame)
            NotificationText.Size = UDim2.new(1, 0, 1, 0)
            NotificationText.BackgroundTransparency = 1
            NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
            NotificationText.TextScaled = true
            NotificationText.Text = "Mod is in the server!"
        end
    elseif modNotificationGui then
        modNotificationGui:Destroy()
        modNotificationGui = nil
    end
end

local function checkForMods()
    local modDetected = false
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(modIDs, player.UserId) then
            modDetected = true
            break
        end
    end

    updateModNotification(modDetected)
    return modDetected
end

Players.PlayerAdded:Connect(function(player)
    if table.find(modIDs, player.UserId) then
        updateModNotification(true)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if table.find(modIDs, player.UserId) then
        checkForMods()
    end
end)

RunService.Heartbeat:Connect(function()
    checkForMods()
end)

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

local function ensureTierData()
    local tierData = {
        {path = "TierData.Basic.Active"},
        {path = "TierData.Cool.Active"},
        {path = "TierData.Legend.Active"},
        {path = "Settings.AutoRebirth"}
    }
    for _, data in ipairs(tierData) do
        local segments = string.split(data.path, ".")
        local parent = Players.LocalPlayer
        for i = 1, #segments - 1 do
            parent = parent:FindFirstChild(segments[i])
        end
        if parent and not parent:FindFirstChild(segments[#segments]) then
            local newBool = Instance.new("BoolValue")
            newBool.Name = segments[#segments]
            newBool.Value = true
            newBool.Parent = parent
        elseif parent[segments[#segments]] then
            parent[segments[#segments]].Value = true
        end
    end
end

ensureTierData()

local function ensureBoosts()
    local boosts = {
        "AutoRebirth", "AutoTrain", "DecaStrength", "DoubleCoins",
        "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"
    }
    for _, boostName in ipairs(boosts) do
        if not Players.LocalPlayer.Boosts:FindFirstChild(boostName) then
            local newNumber = Instance.new("NumberValue")
            newNumber.Name = boostName
            newNumber.Value = 1000
            newNumber.Parent = Players.LocalPlayer.Boosts
        else
            Players.LocalPlayer.Boosts[boostName].Value = 1000
        end
    end
end

ensureBoosts()

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

local function collectCoinsStealthier()
    while getgenv().CollectCoinsStealthier do
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        for _, coin in pairs(Workspace.Coins:GetChildren()) do
            if coin:IsA("MeshPart") and coin.Name == "Coin" then
                firetouchinterest(coin, rootPart, 0)
                task.wait(0.6)
                firetouchinterest(coin, rootPart, 1)
            end
        end
        task.wait(2)
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
end

local function collectEggsStealthier()
    while getgenv().CollectEggsStealthier do
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        for _, egg in pairs(Workspace.Coins:GetChildren()) do
            if egg:IsA("MeshPart") and egg.Name == "Egg" then
                firetouchinterest(egg, rootPart, 0)
                task.wait(0.6)
                firetouchinterest(egg, rootPart, 1)
            end
        end
        task.wait(2)
    end
end

local function autoTrain()
    while getgenv().AutoTrain do
        ensureGamepasses()
        local player = Players.LocalPlayer
        if player then
            local boosts = player:FindFirstChild("Boosts")
            if boosts then
                for _, setting in ipairs(boosts:GetChildren()) do
                    if setting:IsA("NumberValue") then
                        setting.Value = 1000
                    end
                end
            end
        end
        task.wait(1)
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
    end
end)

woogy:Toggle("Collect Coins Stealthier", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsStealthier = bool
        if bool then
            collectCoinsStealthier()
        end
    end
end)

woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggs = bool
        if bool then
            collectEggs()
        end
    end
end)

woogy:Toggle("Collect Eggs Stealthier", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsStealthier = bool
        if bool then
            collectEggsStealthier()
        end
    end
end)

local op = serv:Channel("OP Features")

op:Toggle("Activate OP Mode", false, function(bool)
    if not checkForMods() then
        getgenv().OPMode = bool
        ensureGamepasses()
        ensureTierData()
        ensureBoosts()
    else
        updateModNotification(true)
    end
end)

op:Toggle("Auto Train", false, function(bool)
    if not checkForMods() then
        getgenv().AutoTrain = bool
        if bool then
            autoTrain()
        end
    else
        updateModNotification(true)
    end
end)

op:Button("Boosts", function()
    ensureBoosts()
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
