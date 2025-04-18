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
local platformColor = Color3.fromRGB(100, 100, 100) -- Grey color

local function createPlatform(position)
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(20, 1, 20)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Color = platformColor
    platform.Material = Enum.Material.Concrete
    platform.Position = position + Vector3.new(0, -3, 0) -- Below target
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
local kothCFrame = CFrame.new(535, 1698, 2293)
local flagCFrame = CFrame.new(-281, 1627, 5831)

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

local kothToggled = false
local flagToggled = false
local kothPlatform = nil

local function handleKOTH(toggle)
    kothToggled = toggle
    toggleNoClip(toggle or flagToggled)
    if toggle then
        if Humanoid and RootPart then
            Humanoid.Platform = false -- Disable fake freeze temporarily
            RootPart.Anchored = false
            local charPrimaryPart = Character:FindFirstChild("HumanoidRootPart")
            if charPrimaryPart then
                charPrimaryPart.CanCollide = false
            end
            kothPlatform = smoothTeleportTarget(kothCFrame + Vector3.new(0, -3, 0), Color3.fromRGB(255, 0, 0))
            task.wait(1.6) -- Wait for the tween to finish (adjust if needed)
            Humanoid.Platform = true -- Re-enable fake freeze
            RootPart.Anchored = true
        end
    else
        if Humanoid and RootPart then
            Humanoid.Platform = false
            RootPart.Anchored = false
        end
        if kothPlatform then
            kothPlatform:Destroy()
            kothPlatform = nil
        end
    end
end

local flagPlatform = nil
local function handleFlag(toggle)
    flagToggled = toggle
    toggleNoClip(toggle or kothToggled)
    if toggle then
        if Humanoid and RootPart then
            Humanoid.Platform = false -- Disable fake freeze temporarily
            RootPart.Anchored = false
            local charPrimaryPart = Character:FindFirstChild("HumanoidRootPart")
            if charPrimaryPart then
                charPrimaryPart.CanCollide = false
            end
            flagPlatform = smoothTeleportTarget(flagCFrame + Vector3.new(0, -3, 0), Color3.fromRGB(0, 0, 255))
            task.wait(1.6) -- Wait for the tween to finish (adjust if needed)
            Humanoid.Platform = true -- Re-enable fake freeze
            RootPart.Anchored = true
        end
    else
        if Humanoid and RootPart then
            Humanoid.Platform = false
            RootPart.Anchored = false
        end
        if flagPlatform then
            flagPlatform:Destroy()
            flagPlatform = nil
        end
    end
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
            Humanoid.WalkSpeed = enable and 50 or 16 -- Optional speed increase while noclipping
            Humanoid.JumpPower = enable and 0 or 50
        end
    end
end

local lastSafePosition = nil
local antiVoidEnabled = false

local function checkVoid()
    if antiVoidEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPosition = LocalPlayer.Character.HumanoidRootPart.Position
        if rootPosition.Y < -50 then -- Adjust the threshold as needed
            if lastSafePosition then
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(lastSafePosition)})
                tween:Play()
            end
        else
            lastSafePosition = rootPosition
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
woogy:Toggle("Auto KOTH", false, handleKOTH)
woogy:Toggle("Auto Capture Flag", false, handleFlag)
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
        RunService.Heartbeat:Connect(checkVoid)
    else
        RunService:Disconnect(checkVoid)
        lastSafePosition = nil
    end
end)

gotn:Seperator() -- Separator before "Better Quality"
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
gotn:Seperator() -- Separator after "Better Quality"

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
