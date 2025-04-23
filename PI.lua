--// PI | Discord steppin0nsteppas

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to Ferret Hub!")
info:Seperator()

local pizza = serv:Channel("Pizza")
local function bringPizzasToPlayer()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    for _, piz in ipairs(Workspace.Pizzas:GetDescendants()) do
        if piz:IsA("BasePart") and piz.Name == "Hitbox" then
            piz.CFrame = rootPart.CFrame
        end
    end
end
pizza:Toggle("Collect Pizza", false, function(state)
    getgenv().CollectingPizzas = state
    if state then
        while getgenv().CollectingPizzas do
            bringPizzasToPlayer()
            RunService.Heartbeat:Wait()
        end
    end
end)

local rebirth = serv:Channel("Rebirth")
rebirth:Toggle("Auto Rebirth Upgrade", false, function(state)
    getgenv().RebirthUpgrade = state
    if state then
        while getgenv().RebirthUpgrade do
            ReplicatedStorage.RebirthUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
rebirth:Toggle("Auto Rebirth", false, function(state)
    getgenv().AutoRebirth = state
    if state then
        while getgenv().AutoRebirth do
            ReplicatedStorage.Rebirth:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local cheese = serv:Channel("Cheez")
cheese:Toggle("Convert Cheez", false, function(state)
    getgenv().ConvertCheez = state
    if state then
        while getgenv().ConvertCheez do
            ReplicatedStorage.ConvertCheez:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
cheese:Toggle("Cheez Upgrade", false, function(state)
    getgenv().CheezUpgrade = state
    if state then
        while getgenv().CheezUpgrade do
            ReplicatedStorage.CheezUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
cheese:Button("Convert Max Cheez", function()
    ReplicatedStorage.ConvertMaxCheez:FireServer()
end)

local pepperoni = serv:Channel("Pepperoni")
pepperoni:Toggle("Convert Pepperoni", false, function(state)
    getgenv().ConvertPepperoni = state
    if state then
        while getgenv().ConvertPepperoni do
            ReplicatedStorage.ConvertPepperoni:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
pepperoni:Toggle("Pepperoni Upgrade", false, function(state)
    getgenv().PepperoniUpgrade = state
    if state then
        while getgenv().PepperoniUpgrade do
            ReplicatedStorage.PepperoniUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
pepperoni:Button("Convert Max Pepperoni", function()
    ReplicatedStorage.ConvertMaxPepperoni:FireServer()
end)

local wheatTab = serv:Channel("Wheat")
local function autoFarmWheat()
    local wheat = Workspace:FindFirstChild("Wheat")
    if wheat then
        local dirt = wheat:FindFirstChild("Dirt")
        if dirt then
            local proxContainer = dirt:FindFirstChild("PROX")
            if proxContainer then
                local growPrompt = proxContainer:FindFirstChild("Grow")
                if growPrompt then
                    growPrompt.MaxActivationDistance = 10000
                    growPrompt.HoldDuration = 0.2
                    growPrompt.Enabled = true
                    local attempts = 0
                    while getgenv().WheatAutofarm and attempts < 3 do
                        fireproximityprompt(growPrompt)
                        task.wait(0.7)
                        attempts = attempts + 1
                    end
                end
            end
        end
        local dirtGrown = wheat:FindFirstChild("DirtGrown")
        if dirtGrown then
            local proxContainer = dirtGrown:FindFirstChild("PROX")
            if proxContainer then
                local collectPrompt = proxContainer:FindFirstChild("Collect")
                if collectPrompt then
                    collectPrompt.MaxActivationDistance = 10000
                    collectPrompt.HoldDuration = 0.2
                    collectPrompt.Enabled = true
                    local attempts = 0
                    while getgenv().WheatAutofarm and attempts < 3 do
                        fireproximityprompt(collectPrompt)
                        task.wait(0.7)
                        attempts = attempts + 1
                    end
                end
            end
        end
    end
end
wheatTab:Toggle("Wheat Autofarm", false, function(state)
    getgenv().WheatAutofarm = state
    if state then
        spawn(function()
            while getgenv().WheatAutofarm do
                autoFarmWheat()
                task.wait(0.5)
            end
        end)
    end
end)

local dough = serv:Channel("Dough")
dough:Toggle("Dough Upgrade", false, function(state)
    getgenv().DoughUpgrade = state
    if state then
        while getgenv().DoughUpgrade do
            ReplicatedStorage.DoughUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
dough:Button("Convert Max Dough", function()
    ReplicatedStorage.ConvertMaxDough:FireServer()
end)
dough:Toggle("Convert Dough", false, function(state)
    getgenv().ConvertDough = state
    if state then
        while getgenv().ConvertDough do
            ReplicatedStorage.ConvertDough:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local mushroom = serv:Channel("Mushroom")
mushroom:Toggle("Mushroom Upgrade", false, function(state)
    getgenv().MushroomUpgrade = state
    if state then
        while getgenv().MushroomUpgrade do
            ReplicatedStorage.MushroomUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
mushroom:Button("Convert Max Mush", function()
    ReplicatedStorage.ConvertMaxMush:FireServer()
end)
mushroom:Toggle("Convert Mush", false, function(state)
    getgenv().ConvertMush = state
    if state then
        while getgenv().ConvertMush do
            ReplicatedStorage.ConvertMush:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
mushroom:Toggle("Mush Boost", false, function(state)
    getgenv().MushBoost = state
    if state then
        while getgenv().MushBoost do
            ReplicatedStorage.MushBoost:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local sausage = serv:Channel("Sausage")
local originalSausageCFrame = nil
sausage:Toggle("Get Sausages", false, function(state)
    getgenv().GetSausages = state
    local sp = Workspace:FindFirstChild("SausagePart")
    if sp then
        if state then
            if not originalSausageCFrame then
                originalSausageCFrame = sp.CFrame
            end
            sp.CanCollide = false
            spawn(function()
                while getgenv().GetSausages do
                    local player = Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        sp.CFrame = root.CFrame
                    end
                    task.wait(0.3)
                end
            end)
        else
            sp.CFrame = originalSausageCFrame or sp.CFrame
            sp.CanCollide = true
            originalSausageCFrame = nil
        end
    end
end)
sausage:Toggle("Auto Sausage Upgrade", false, function(state)
    getgenv().SausageUpgrade = state
    if state then
        while getgenv().SausageUpgrade do
            ReplicatedStorage.SausageUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
sausage:Toggle("Auto Sausage", false, function(state)
    getgenv().AutoSausage = state
    if state then
        while getgenv().AutoSausage do
            ReplicatedStorage.Sausage:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local oven = serv:Channel("Oven")
oven:Button("Use Oven", function()
    ReplicatedStorage.UseOven:FireServer()
end)
oven:Button("Use Oven Client", function()
    ReplicatedStorage.UseOvenClient:FireServer()
end)

local shrimpChannel = serv:Channel("Shrimp")
local shrimpPrompts = { workspace.SpearPROX.ProximityPrompt, workspace.ShrimpPROX.ProximityPrompt }
local function autoFarmShrimp()
    for _, prompt in ipairs(shrimpPrompts) do
        prompt.MaxActivationDistance = 10000
        prompt.HoldDuration = 0.2
        prompt.Enabled = true
        local attempts = 0
        while getgenv().ShrimpAutofarm and attempts < 3 do
            fireproximityprompt(prompt)
            task.wait(0.7)
            attempts = attempts + 1
        end
    end
end
shrimpChannel:Toggle("Auto Shrimp", false, function(state)
    getgenv().ShrimpAutofarm = state
    if state then
        spawn(function()
            while getgenv().ShrimpAutofarm do
                autoFarmShrimp()
                task.wait(0.5)
            end
        end)
    end
end)

local bell = serv:Channel("Bell")
bell:Toggle("Convert Bell", false, function(state)
    getgenv().ConvertBell = state
    if state then
        while getgenv().ConvertBell do
            ReplicatedStorage.ConvertBell:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
bell:Button("Convert Max Bell", function()
    ReplicatedStorage.ConvertMaxBell:FireServer()
end)

local trait = serv:Channel("Trait")
trait:Button("Convert Max Trait", function()
    ReplicatedStorage.ConvertMaxTrait:FireServer()
end)
trait:Toggle("Convert Trait", false, function(state)
    getgenv().ConvertTrait = state
    if state then
        while getgenv().ConvertTrait do
            ReplicatedStorage.ConvertTrait:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local anchovy = serv:Channel("Anchovy")
anchovy:Toggle("Collect Anchovy", false, function(state)
    getgenv().CollectAnchovy = state
    if state then
        while getgenv().CollectAnchovy do
            ReplicatedStorage.CollectAnchovy:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)
anchovy:Toggle("Anchovy Upgrade", false, function(state)
    getgenv().AnchovyUpgrade = state
    if state then
        while getgenv().AnchovyUpgrade do
            ReplicatedStorage.AnchovyUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local mine = serv:Channel("Mine")
mine:Toggle("Mine Ores", false, function(state)
    getgenv().MineOres = state
    if state then
        spawn(function()
            while getgenv().MineOres do
                local ores = Workspace.Ores:GetChildren()
                if #ores >= 3 then
                    local ore = ores[3]
                    if ore and ore:FindFirstChild("Main") and ore.Main:FindFirstChild("MineDetector") then
                        local detector = ore.Main.MineDetector
                        detector.MaxActivationDistance = 600
                        fireclickdetector(detector)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

local misc = serv:Channel("Misc")
misc:Button("FPS Boost", function()
    local function removeExtraGraphics()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Texture") or obj:IsA("Decal") then
                obj:Destroy()
            end
        end
        print("FPS Boost applied successfully!")
    end
    removeExtraGraphics()
end)
misc:Button("Anti AFK", function()
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    print("Anti AFK enabled!")
end)
