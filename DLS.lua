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
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(modIDs, player.UserId) then
            return true
        end
    end
    return false
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

local function ensureGamepasses()
    local gamepasses = {"Double", "VIP", "DoubleCoins", "DoubleEnergy", "Flying", "AutoRebirth", "DecaStrength", "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength", "TripleHatch"}
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
    local boosts = {"AutoRebirth", "AutoTrain", "DecaStrength", "DoubleCoins", "DoubleTokens", "DoubleXP", "QuadCoins", "QuadStrength"}
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
        if root and root.Position.Y < -40 then
            local spawnLoc = Workspace:FindFirstChild("SpawnLocation")
            if spawnLoc then
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(root, tweenInfo, {CFrame = spawnLoc.CFrame}):Play()
            end
        end
    end
end

local autofarm = serv:Channel("Autofarm")
autofarm:Toggle("Collect Coins", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlow = bool
        if bool then task.spawn(function() collectItems("coin", 0.2) end) end
    end
end)
autofarm:Toggle("Collect Coins (Slow)", false, function(bool)
    if not checkForMods() then
        getgenv().CollectCoinsSlower = bool
        if bool then task.spawn(function() collectItems("coin", 0.4) end) end
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
local currentRebirthValue = 1
opFeatures:Dropdown("Pick Rebirth Amount", {"1", "5", "10", "30", "50", "100", "500", "750", "1000", "2500", "5000", "20000", "50000", "75000", "100000"}, function(value)
    local num = tonumber(value)
    if num then
        currentRebirthValue = num
        if getgenv().ApplyRebirthSetting then
            local autoRebirthConfig = Players.LocalPlayer:FindFirstChild("PlayerData") and Players.LocalPlayer.PlayerData:FindFirstChild("AutoRebirthConfig")
            if autoRebirthConfig then
                local autoAmount = autoRebirthConfig:FindFirstChild("AutoAmount")
                if autoAmount then
                    autoAmount.Value = num
                end
            end
        end
    end
end)
local applyRebirthToggle = false
opFeatures:Toggle("Apply Rebirth Setting", false, function(state)
    applyRebirthToggle = state
    getgenv().ApplyRebirthSetting = state
    local autoRebirthConfig = Players.LocalPlayer:FindFirstChild("PlayerData") and Players.LocalPlayer.PlayerData:FindFirstChild("AutoRebirthConfig")
    if autoRebirthConfig then
        local autoAmount = autoRebirthConfig:FindFirstChild("AutoAmount")
        if autoAmount then
            if state then
                autoAmount.Value = currentRebirthValue
            else
                autoAmount.Value = 923
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

misc:Button("mod detector", function()
    if not _G.modDetectorActive then
        _G.modDetectorActive = true
        local modStatus = checkForMods() and "Mods are in the server!" or "Mods are not in the server!"
        local color = checkForMods() and Color3.fromRGB(139,0,0) or Color3.fromRGB(0,128,0)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ModDetectorGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        local label = Instance.new("TextLabel")
        label.Name = "ModDetectorLabel"
        label.Size = UDim2.new(0, 400, 0, 50)
        label.Position = UDim2.new(0.5, -200, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = modStatus
        label.TextColor3 = color
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 19
        label.Parent = screenGui
        local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenInc = TweenService:Create(label, tweenInfo, {TextSize = 25})
        local tweenDec = TweenService:Create(label, tweenInfo, {TextSize = 19})
        tweenInc:Play()
        tweenInc.Completed:Wait()
        tweenDec:Play()
        tweenDec.Completed:Wait()
        wait(10)
        screenGui:Destroy()
        _G.modDetectorActive = false
    end
end)

local eggs = serv:Channel("Eggs")
local selectedCapsule = nil
local originalCapsuleCFrame = nil

eggs:Dropdown("Pick an egg", {"Arctic", "Candy", "Cave", "Desert2", "Elemental", "EternalEaster", "Frozen", "Jungle2", "Lava", "Nature", "Radioactive", "Shadow", "Tokens"}, function(value)
    if Workspace:FindFirstChild("Capsules") then
        selectedCapsule = Workspace.Capsules:FindFirstChild(value)
        if selectedCapsule then
            if selectedCapsule.PrimaryPart then
                originalCapsuleCFrame = selectedCapsule.PrimaryPart.CFrame
            end
            for _, part in ipairs(selectedCapsule:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

eggs:Toggle("Open Egg", false, function(state)
    getgenv().OpenEgg = state
    local player = Players.LocalPlayer
    if state and selectedCapsule and not checkForMods() then
        spawn(function()
            while getgenv().OpenEgg and selectedCapsule and not checkForMods() do
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:FindFirstChild("HumanoidRootPart")
                if root and selectedCapsule.PrimaryPart then
                    local capsuleCFrame = selectedCapsule.PrimaryPart.CFrame
                    local targetCFrame = capsuleCFrame * CFrame.new(0, -4, 0)
                    if (root.Position - targetCFrame.p).Magnitude > 4 then
                        root.CFrame = targetCFrame
                    end
                end
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui and playerGui:FindFirstChild("CapsuleUi") and playerGui.CapsuleUi:FindFirstChild("AutoOpen") then
                    playerGui.CapsuleUi.AutoOpen.Value = true
                end
                wait(5)
            end
        end)
    else
        local spawnLoc = Workspace:FindFirstChild("SpawnLocation")
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:FindFirstChild("HumanoidRootPart")
        if spawnLoc and root then
            if spawnLoc:IsA("BasePart") then
                root.CFrame = spawnLoc.CFrame
            else
                root.CFrame = spawnLoc
            end
        end
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui and playerGui:FindFirstChild("CapsuleUi") and playerGui.CapsuleUi:FindFirstChild("AutoOpen") then
            playerGui.CapsuleUi.AutoOpen.Value = false
        end
    end
end)

local previousModState = nil
local randomSpots = {
    CFrame.new(414, 1745, 5587),
    CFrame.new(306, 1713, 5544),
    CFrame.new(152, 1703, 5658),
    CFrame.new(147, 1702, 5528),
    CFrame.new(64, 1703, 5528),
    CFrame.new(52, 1702, 5651),
    CFrame.new(-21, 1702, 5691),
    CFrame.new(-63, 1702, 5610),
    CFrame.new(-363, 1616, 5847),
    CFrame.new(-422, 1616, 5796),
    CFrame.new(-377, 1616, 5734),
    CFrame.new(19, 1711, 5774),
    CFrame.new(-17, 1709, 5803),
    CFrame.new(53, 1709, 5793),
    CFrame.new(121, 1704, 5495),
    CFrame.new(113, 1702, 5457),
    CFrame.new(151, 1702, 5512),
    CFrame.new(531, 1698, 2290),
    CFrame.new(529, 1711, 2300),
    CFrame.new(564, 1698, 2436),
    CFrame.new(589, 1698, 2364),
    CFrame.new(505, 1698, 2322),
    CFrame.new(438, 1699, 2381),
    CFrame.new(445, 1698, 2445)
}
RunService.Heartbeat:Connect(function()
    local modsPresent = checkForMods()
    if previousModState == nil then
        previousModState = modsPresent
    elseif previousModState == true and modsPresent == false then
        if #randomSpots > 0 then
            local validSpot, chosen
            for i = 1, 10 do
                chosen = randomSpots[math.random(1, #randomSpots)]
                local canTeleport = true
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        local vel = hrp.Velocity.Magnitude
                        if (hrp.Position - chosen.p).Magnitude < 40 and vel > 2 then
                            canTeleport = false
                            break
                        end
                    end
                end
                if canTeleport then
                    validSpot = chosen
                    break
                end
            end
            if validSpot then
                local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = validSpot
                    local notif = Instance.new("ScreenGui")
                    notif.Name = "RandomTeleportNotif"
                    notif.ResetOnSpawn = false
                    notif.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(0, 400, 0, 50)
                    lbl.Position = UDim2.new(0.5, -200, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "Teleported to a random spot!"
                    lbl.TextColor3 = Color3.new(1,1,1)
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextSize = 24
                    lbl.Parent = notif
                    delay(10, function() if notif then notif:Destroy() end end)
                end
            end
        end
    end
    previousModState = modsPresent
end)
