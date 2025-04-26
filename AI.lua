--// Apple Incremental not AI lol | Discord: steppin0nsteppas

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Apple Incremental", "")
local appleChannel = serv:Channel("Apples")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().appleToggle = false
getgenv().autoSell = false

local function collectApples()
    while getgenv().appleToggle do
        local appleFolder = Workspace:FindFirstChild("Apples")
        if appleFolder and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, apple in ipairs(appleFolder:GetChildren()) do
                if not getgenv().appleToggle then break end
                if apple:IsA("BasePart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    -- Create a target CFrame that keeps your current Y but uses the apple's X,Z.
                    local targetCF = CFrame.new(apple.Position.X, hrp.Position.Y, apple.Position.Z)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
                    tween:Play()
                    tween.Completed:Wait()
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.1)
    end
end

appleChannel:Toggle("Collect Apples", false, function(state)
    getgenv().appleToggle = state
    if state then
        spawn(function()
            collectApples()
        end)
    end
end)

local autosellOriginal = {}

local function enableAutosell()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local sellFolder = Workspace:FindFirstChild("sell")
    if not sellFolder then
        warn("sell folder not found in workspace.")
        return
    end
    local sellPart = sellFolder:FindFirstChild("sellPart")
    if not sellPart then
        warn("sellPart not found.")
        return
    end
    if not autosellOriginal.Size then
        autosellOriginal.Size = sellPart.Size
        autosellOriginal.CFrame = sellPart.CFrame
        autosellOriginal.CanCollide = sellPart.CanCollide
        autosellOriginal.Transparency = sellPart.Transparency
    end

    sellPart.CanCollide = false
    sellPart.Size = Vector3.new(50,50,50)
    sellPart.Transparency = 1

    spawn(function()
        while getgenv().autoSell do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local marketVal = game:GetService("ReplicatedStorage"):FindFirstChild("marketPercentage")
                if marketVal and marketVal.Value > 0 then
                    sellPart.CFrame = CFrame.new(hrp.Position)
                end
            end
            task.wait(1)
        end
    end)
end

local function disableAutosell()
    local sellFolder = Workspace:FindFirstChild("sell")
    if not sellFolder then return end
    local sellPart = sellFolder:FindFirstChild("sellPart")
    if not sellPart then return end
    if autosellOriginal.Size then
        sellPart.Size = autosellOriginal.Size
        sellPart.CFrame = autosellOriginal.CFrame
        sellPart.CanCollide = autosellOriginal.CanCollide
        sellPart.Transparency = autosellOriginal.Transparency
        autosellOriginal = {}
    end
end

appleChannel:Toggle("Autosell", false, function(state)
    getgenv().autoSell = state
    if state then
        enableAutosell()
    else
        disableAutosell()
    end
end)
