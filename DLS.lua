-- Part 0: Services and modIDs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

-- Part 1: DiscordLib UI Setup
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to Ferret Hub!")
info:Seperator()

-- Part 2: Function Definitions
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

local function collectItems(itemName, delay)
    while getgenv().CollectCoinsSlow or getgenv().CollectCoinsSlower or getgenv().CollectEggsSlow or getgenv().CollectEggsSlower do
        if checkForMods() then
            getgenv().CollectCoinsSlow = false
            getgenv().CollectCoinsSlower = false
            getgenv().CollectEggsSlow = false
            getgenv().CollectEggsSlower = false
            break
        end
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local coinsFolder = Workspace:FindFirstChild("Coins")
        if coinsFolder then
            for _, item in ipairs(coinsFolder:GetChildren()) do
                if item:IsA("MeshPart") and item.Name:lower() == itemName:lower() then
                    firetouchinterest(item, rootPart, 0)
                    task.wait(delay)
                    firetouchinterest(item, rootPart, 1)
                end
            end
        end
        task.wait(1)
    end
end

local function ensureGamepasses()
    local gamepasses = {
        "Spam", "Dual", "Double", "DoubleCoins",
        "DoubleEnergy", "Flying", "Wear", "AutoRebirth",
        "DecaStrength", "DoubleTokens", "DoubleXP", 
        "QuadCoins", "QuadStrength", "TripleHatch"
    }
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
    local boosts = {
        "AutoRebirth", "AutoTrain", "DecaStrength", "DoubleCoins",
        "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"
    }
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
    local character = Players.LocalPlayer.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
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
    if not checkForMods() then
        settings().Rendering.QualityLevel = 1
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end)
