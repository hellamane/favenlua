local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modIDs = {1327199087, 3404114204, 417399445, 476757220, 17804357, 432138635, 100509360, 28620140, 199822737}

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to Ferret Hub!")
info:Seperator()

local function checkForMods()
    local modDetected = false
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(modIDs, player.UserId) then
            modDetected = true
            break
        end
    end
    return modDetected
end

local function createModNotification()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModWarning"
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Owner/Mod in server (You should go)"
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    label.Parent = frame
    frame.Parent = screenGui
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    return screenGui
end

local function collectItems(itemName, delay)
    while getgenv().CollectCoinsSlow or getgenv().CollectCoinsSlower or getgenv().CollectEggsSlow or getgenv().CollectEggsSlower do
        if checkForMods() then
            getgenv().CollectCoinsSlow = false
            getgenv().CollectCoinsSlower = false
            getgenv().CollectEggsSlow = false
            getgenv().CollectEggsSlower = false
            break
        end
        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local coinsFolder = Workspace:FindFirstChild("Coins")
        if coinsFolder then
            for _, item in ipairs(coinsFolder:GetChildren()) do
                if item:IsA("MeshPart") and item.Name:lower() == itemName:lower() then
                    firetouchinterest(item, root, 0)
                    task.wait(delay)
                    firetouchinterest(item, root, 1)
                end
            end
        end
        task.wait(1)
    end
end

local function getRewards()
    while getgenv().GetRewards do
        if checkForMods() then
            getgenv().GetRewards = false
            break
        end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            if remotes:FindFirstChild("QuestReward") then
                remotes.QuestReward:FireServer()
            end
            if remotes:FindFirstChild("ChestReward") then
                remotes.ChestReward:FireServer()
            end
            if remotes:FindFirstChild("ActivateGift") then
                remotes.ActivateGift:FireServer()
            end
        end
        task.wait(5)
    end
end

local function ensureGamepasses()
    local gamepasses = {"Spam", "Dual", "Double", "DoubleCoins", "DoubleEnergy", "Flying", "Wear", "AutoRebirth", "DecaStrength", "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"}
    for _, gp in ipairs(gamepasses) do
        if not Players.LocalPlayer:FindFirstChild(gp) then
            local newGP = Instance.new("BoolValue")
            newGP.Name = gp
            newGP.Value = true
            newGP.Parent = Players.LocalPlayer
        else
            Players.LocalPlayer[gp].Value = true
        end
    end
end

local function ensureBoosts()
    local boosts = {"AutoRebirth", "AutoTrain", "DecaStrength", "DoubleCoins", "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"}
    local boostsFolder = Players.LocalPlayer:FindFirstChild("Boosts")
    if not boostsFolder then
        boostsFolder = Instance.new("Folder")
        boostsFolder.Name = "Boosts"
        boostsFolder.Parent = Players.LocalPlayer
    end
    for _, b in ipairs(boosts) do
        local boost = boostsFolder:FindFirstChild(b)
        if not boost then
            boost = Instance.new("NumberValue")
            boost.Name = b
            boost.Value = 1000
            boost.Parent = boostsFolder
        else
            boost.Value = 1000
        end
    end
end

local function activateOPMode()
    ensureGamepasses()
    ensureBoosts()
    if Players.LocalPlayer:FindFirstChild("TierData") then
        for _, tier in ipairs({"Basic", "Cool", "Legend"}) do
            local td = Players.LocalPlayer.TierData:FindFirstChild(tier)
            if td and td:FindFirstChild("Active") then
                td.Active.Value = true
            end
        end
    end
    if Players.LocalPlayer:FindFirstChild("Settings") then
        local autoRebirth = Players.LocalPlayer.Settings:FindFirstChild("AutoRebirth")
        if autoRebirth then
            autoRebirth.Value = true
        end
    end
end

local function antiVoidFunction()
    local char = Players.LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and root.Position.Y < -50 then
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            if spawn then
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(root, tweenInfo, {CFrame = spawn.CFrame}):Play()
            end
        end
    end
end

-- Part 3: UI Toggles and Buttons

local autofarm = serv:Channel("Autofarm")
autofarm:Toggle("Collect Coins (Slow)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlow = bool
        if bool then task.spawn(function() collectItems("coin", 0.4) end) end
    end
end)
autofarm:Toggle("Collect Coins (Slower)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlower = bool
        if bool then task.spawn(function() collectItems("coin", 0.6) end) end
    end
end)
autofarm:Toggle("Collect Eggs (Slow)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsSlow = bool
        if bool then task.spawn(function() collectItems("egg", 0.4) end) end
    end
end)
autofarm:Toggle("Collect Eggs (Slower)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsSlower = bool
        if bool then task.spawn(function() collectItems("egg", 0.6) end) end
    end
end)
autofarm:Toggle("Get Rewards", false, function(bool)
    if not checkForMods() then
        getgenv().GetRewards = bool
        if bool then task.spawn(function() getRewards() end) end
    end
end)

local opFeatures = serv:Channel("OP Features")
opFeatures:Toggle("Activate OP Mode", false, function(bool)
    if not checkForMods() then
        getgenv().OPMode = bool
        if bool then activateOPMode() end
    end
end)
opFeatures:Button("Boosts", function()
    if not checkForMods() then ensureBoosts() end
end)
opFeatures:Button("Gamepasses", function()
    if not checkForMods() then ensureGamepasses() end
end)
opFeatures:Dropdown("Pick Rebirth Amount", {"1","5","10","30","50","100","500","750","1000","2500","5000","20000","50000","75000","100000"}, function(value)
    local num = tonumber(value)
    if num then
        local autoRebirthConfig = Players.LocalPlayer:FindFirstChild("PlayerData") and Players.LocalPlayer.PlayerData:FindFirstChild("AutoRebirthConfig")
        if autoRebirthConfig then
            local autoAmount = autoRebirthConfig:FindFirstChild("AutoAmount")
            if autoAmount then
                autoAmount.Value = num
            end
        end
    end
end)

local misc = serv:Channel("Misc")
misc:Toggle("Anti-Void", false, function(bool)
    if not checkForMods() then
        getgenv().AntiVoidEnabled = bool
        if bool then
            getgenv().AntiVoidConnection = RunService.Heartbeat:Connect(function() antiVoidFunction() end)
        else
            if getgenv().AntiVoidConnection then
                getgenv().AntiVoidConnection:Disconnect()
                getgenv().AntiVoidConnection = nil
            end
        end
    end
end)
misc:Button("FPS Boost", function()
    local settings_ = Players.LocalPlayer:FindFirstChild("Settings")
    if settings_ then
        local offList = {"Particles", "RebirthSFX", "StrengthPopup", "Minigames"}
        for _, sName in ipairs(offList) do
            local s = settings_:FindFirstChild(sName)
            if s and s:IsA("BoolValue") then
                s.Value = false
            end
        end
        local onList = {"HideYourPets", "HideRebirthPopup", "HideOtherPets"}
        for _, sName in ipairs(onList) do
            local s = settings_:FindFirstChild(sName)
            if s and s:IsA("BoolValue") then
                s.Value = true
            end
        end
    end
end)

local modNotification
RunService.Heartbeat:Connect(function()
    if checkForMods() then
        if not modNotification then
            modNotification = createModNotification()
        end
    else
        if modNotification then
            modNotification:Destroy()
            modNotification = nil
        end
    end
end)
