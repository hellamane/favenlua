--// Dominus Lifting Simulator | Discord #steppin0nsteppas
getgenv().CollectCoins = false
getgenv().CollectEggs = false
getgenv().AntiVoidEnabled = false
getgenv().GetFlag = false
getgenv().GetKoth = false

local modIDs = {
    1327199087, 3404114204, 417399445, 476757220, 17804357,
    432138635, 100509360, 28620140, 199822737
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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

local function disableFeatures()
    getgenv().CollectCoins = false
    getgenv().CollectEggs = false
    getgenv().GetFlag = false
    getgenv().GetKoth = false
end

local function enableFeatures()
    getgenv().CollectCoins = true
    getgenv().CollectEggs = true
end

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
    else
        notifyModPresence()
    end
end)

woogy:Toggle("Collect Eggs Slowly", false, function(bool)
    if not checkForMods() then
        getgenv().CollectEggs = bool
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

local zones = {
    Flag = Workspace.FlagLocation.CFrame,
    Koth = Workspace.KothLocation.CFrame
}

misc:Toggle("Get Flag", false, function(bool)
    if not checkForMods() then
        getgenv().GetFlag = bool
        if bool then
            local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local tween = TweenService:Create(
                    rootPart,
                    TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {CFrame = zones.Flag}
                )
                tween:Play()
            end
        else
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            if spawn then
                local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local tween = TweenService:Create(
                        rootPart,
                        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                        {CFrame = spawn.CFrame}
                    )
                    tween:Play()
                end
            end
        end
    else
        notifyModPresence()
    end
end)

misc:Toggle("Get Koth", false, function(bool)
    if not checkForMods() then
        getgenv().GetKoth = bool
        if bool then
            local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local tween = TweenService:Create(
                    rootPart,
                    TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {CFrame = zones.Koth}
                )
                tween:Play()
            end
        else
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            if spawn then
                local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local tween = TweenService:Create(
                        rootPart,
                        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                        {CFrame = spawn.CFrame}
                    )
                    tween:Play()
                end
            end
        end
    else
        notifyModPresence()
    end
end)
