--// PI | Discord steppin0nsteppas

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		wait(0.5)
            local proxContainer = dirt:FindFirstChild("PROX")
            if proxContainer and proxContainer:FindFirstChild("Grow") then
                local prompt = proxContainer["Grow"]
                prompt.MaxActivationDistance = 10000
                fireproximityprompt(prompt)
            end
        end
		
        local dirtGrown = wheat:FindFirstChild("DirtGrown")
        if dirtGrown then
		wait(0.5)
            local proxContainer = dirtGrown:FindFirstChild("PROX")
            if proxContainer and proxContainer:FindFirstChild("Collect") then
                local prompt = proxContainer["Collect"]
                prompt.MaxActivationDistance = 10000
                fireproximityprompt(prompt)
            end
        end
    end
end

wheatTab:Toggle("Wheat Autofarm", false, function(state)
    getgenv().WheatAutofarm = state
    if state then
        while getgenv().WheatAutofarm do
            autoFarmWheat()
            RunService.Heartbeat:Wait(0.5)
        end
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

local sausage = serv:Channel("Sausage")

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

local mush = serv:Channel("Mush")

mush:Button("Convert Max Mush", function()
    ReplicatedStorage.ConvertMaxMush:FireServer()
end)

mush:Toggle("Convert Mush", false, function(state)
    getgenv().ConvertMush = state
    if state then
        while getgenv().ConvertMush do
            ReplicatedStorage.ConvertMush:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

mush:Toggle("Mush Boost", false, function(state)
    getgenv().MushBoost = state
    if state then
        while getgenv().MushBoost do
            ReplicatedStorage.MushBoost:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
    end
end)

local shrimp = serv:Channel("Shrimp")
shrimp:Toggle("Shrimp Upgrade", false, function(state)
    getgenv().ShrimpUpgrade = state
    if state then
        while getgenv().ShrimpUpgrade do
            ReplicatedStorage.ShrimpUpgrade:FireServer()
            RunService.Heartbeat:Wait(0.5)
        end
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

local misc = serv:Channel("Misc")

misc:Button("Collect", function()
    ReplicatedStorage.Collect:FireServer()
end)

misc:Button("Convert", function()
    ReplicatedStorage.Convert:FireServer()
end)
misc:Button("Change Value", function()
    ReplicatedStorage.ChangeValue:FireServer()
end)
