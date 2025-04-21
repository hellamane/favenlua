local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Info")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Welcome to Ferret Hub!")
lbls:Seperator()

local farm = serv:Channel("Autofarm")

farm:Toggle("Collect Coins (Slow)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlow = bool
        if bool then
            collectCoins("coin", 0.4)
        end
    else
        warn("Moderators detected! Cannot collect coins.")
    end
end)

farm:Toggle("Collect Coins (Slower)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlower = bool
        if bool then
            collectCoins("coin", 0.6)
        end
    else
        warn("Moderators detected! Cannot collect coins.")
    end
end)

farm:Toggle("Collect Eggs (Slow)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsSlow = bool
        if bool then
            collectEggs("egg", 0.4)
        end
    else
        warn("Moderators detected! Cannot collect eggs.")
    end
end)

farm:Toggle("Collect Eggs (Slower)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggsSlower = bool
        if bool then
            collectEggs("egg", 0.6)
        end
    else
        warn("Moderators detected! Cannot collect eggs.")
    end
end)

local op = serv:Channel("OP Features")

op:Toggle("Activate OP Mode", false, function(bool)
    if not checkForMods() then
        getgenv().OPMode = bool
        if bool then
            activateOPMode()
        end
    else
        warn("Moderators detected! Cannot activate OP Mode.")
    end
end)

op:Button("Boosts", function()
    if not checkForMods() then
        ensureBoosts()
    else
        warn("Moderators detected! Cannot apply boosts.")
    end
end)

op:Button("Gamepasses", function()
    if not checkForMods() then
        ensureGamepasses()
    else
        warn("Moderators detected! Cannot apply gamepasses.")
    end
end)

local misc = serv:Channel("Misc")

misc:Toggle("Anti-Void", false, function(bool)
    if not checkForMods() then
        getgenv().AntiVoidEnabled = bool
        if bool then
            getgenv().AntiVoidConnection = RunService.Heartbeat:Connect(function()
                local character = Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if character.HumanoidRootPart.Position.Y < -50 then
                        character.HumanoidRootPart.CFrame = Workspace.SpawnLocation.CFrame
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
        settings().Rendering.QualityLevel = 1
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
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

local function collectCoins(itemName, delay)
    while getgenv().CollectCoinsSlow or getgenv().CollectCoinsSlower do
        if checkForMods() then
            getgenv().CollectCoinsSlow = false
            getgenv().CollectCoinsSlower = false
            break
        end
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        for _, item in pairs(Workspace.Coins:GetChildren()) do
            if item.Name:lower() == itemName:lower() then
                firetouchinterest(item, rootPart, 0)
                task.wait(delay)
                firetouchinterest(item, rootPart, 1)
            end
        end
        task.wait(1)
    end
end

local function collectEggs(itemName, delay)
    while getgenv().CollectEggsSlow or getgenv().CollectEggsSlower do
        if checkForMods() then
            getgenv().CollectEggsSlow = false
            getgenv().CollectEggsSlower = false
            break
        end
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        for _, item in pairs(Workspace.Coins:GetChildren()) do
            if item.Name:lower() == itemName:lower() then
                firetouchinterest(item, rootPart, 0)
                task.wait(delay)
                firetouchinterest(item, rootPart, 1)
            end
        end
        task.wait(1)
    end
end

local function ensureGamepasses()
    local gamepasses = {
        "Spam", "Dual", "VIP", "Double", "DoubleCoins",
        "DoubleEnergy", "Flying", "Wear", "AutoRebirth",
        "DecaStrength", "DoubleTokens", "DoubleXP", 
        "QuadCoins", "QuadStrength", "TripleHatch"
    }
    for _, gamepassName in ipairs(gamepasses) do
        if not Players.LocalPlayer:FindFirstChild(gamepassName) then
            local newGamepass = Instance.new("BoolValue")
            newGamepass.Name = gamepassName
            newGamepass.Value = true
            newGamepass.Parent = Players.LocalPlayer
        else
            Players.LocalPlayer[gamepassName].Value = true
        end
    end
end

local function ensureBoosts()
    local boosts = {
        "AutoRebirth", "AutoTrain", "DecaStrength", "DoubleCoins",
        "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"
    }
    for _, boostName in ipairs(boosts) do
        local boost = Players.LocalPlayer.Boosts:FindFirstChild(boostName)
        if not boost then
            boost = Instance.new("NumberValue")
            boost.Name = boostName
            boost.Value = 1000
            boost.Parent = Players.LocalPlayer.Boosts
        else
            boost.Value = 1000
        end
    end
end

local function activateOPMode()
    ensureGamepasses()
    ensureBoosts()
    for _, tier in ipairs({"Basic", "Cool", "Legend"}) do
        local tierData = Players.LocalPlayer.TierData:FindFirstChild(tier)
        if tierData then
            tierData.Active.Value = true
        end
    end
    local autoRebirth = Players.LocalPlayer.Settings:FindFirstChild("AutoRebirth")
    if autoRebirth then
        autoRebirth.Value = true
    end
end
