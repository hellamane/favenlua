local RunService = game:GetService("RunService")


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
        warn("Moderators detected! Cannot start collecting coins.")
    end
end)

woogy:Toggle("Collect Coins Stealthier", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsStealthier = bool
        if bool then
            collectCoinsStealthier()
        end
    else
        warn("Moderators detected! Cannot start collecting coins stealthily.")
    end
end)

woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggs = bool
        if bool then
            collectEggs()
        end
    else
        warn("Moderators detected! Cannot start collecting eggs.")
    end
end)

woogy:Toggle("Collect Eggs Stealthier", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsStealthier = bool
        if bool then
            collectEggsStealthier()
        end
    else
        warn("Moderators detected! Cannot start collecting eggs stealthily.")
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
        warn("Moderators detected! Cannot activate OP Mode.")
    end
end)

op:Toggle("Auto Train", false, function(bool)
    if not checkForMods() then
        getgenv().AutoTrain = bool
        if bool then
            autoTrain()
        end
    else
        warn("Moderators detected! Cannot enable Auto Train.")
    end
end)

op:Button("Boosts", function()
    if not checkForMods() then
        ensureBoosts()
    else
        warn("Moderators detected! Cannot apply boosts.")
    end
end)

local misc = serv:Channel("Misc")

misc:Toggle("Anti-Void", false, function(bool)
    if not checkForMods() then
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
    else
        warn("Moderators detected! Cannot enable Anti-Void.")
    end
end)

misc:Button("FPS Boost", function()
    if not checkForMods() then
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
    else
        warn("Moderators detected! Cannot apply FPS Boost.")
    end
end)

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

local function collectCoins()
    while getgenv().CollectCoins do
        if checkForMods() then
            warn("Stopped collecting coins due to moderators.")
            getgenv().CollectCoins = false
            break
        end
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
        if checkForMods() then
            warn("Stopped collecting coins stealthily due to moderators.")
            getgenv().CollectCoinsStealthier = false
            break
        end
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
