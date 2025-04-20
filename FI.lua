getgenv().Coins = false
getgenv().AutoFishing = false
getgenv().LuckBoost = false
getgenv().AutoUpgrade = false

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Fishing Incremental")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Fishing Automation Enabled")
lbls:Seperator()

local serv = win:Server("Fishing", "")
local aimstix = serv:Channel("Assistment")

aimstix:Toggle("Get Coins", false, function(bool)
    getgenv().Coins = bool

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GetFreeCoinsRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetFreeCoins")

    local function fireGetFreeCoins()
        while getgenv().Coins do
            GetFreeCoinsRemote:FireServer()
            task.wait(0.3)
        end
    end

    if getgenv().Coins then
        task.spawn(fireGetFreeCoins)
    end
end)

aimstix:Toggle("Auto Fishing", false, function(bool)
    getgenv().AutoFishing = bool

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local AAAFISH = ReplicatedStorage:WaitForChild("Rod"):WaitForChild("Handle"):WaitForChild("Float"):WaitForChild("AAAFISH")
    local FishCatchedRemote = ReplicatedStorage.Remotes:WaitForChild("FishCatchedClient")
    local PlayerCaughtFishRemote = ReplicatedStorage.Remotes:WaitForChild("PlayerCaughtFish")

    local function getClosestZone()
        local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        local closestZone = nil
        local closestDistance = math.huge

        local zones = {
            workspace.Vodoemi.VodoemZone9.Vodoem9.Bridge.Zone,
            workspace.Vodoemi.VodoemZone9.Vodoem9:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone8.Vodoem8:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone8.Vodoem8.Bridge.Zone,
            workspace.Vodoemi.VodoemZone7.Vodoem7:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone7.Vodoem7.Bridge.Zone,
            workspace.Vodoemi.VodoemZone6.Vodoem6.Bridge.Zone,
            workspace.Vodoemi.VodoemZone6.Vodoem6:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone5.Vodoem5.Bridge.Zone,
            workspace.Vodoemi.VodoemZone5.Vodoem5:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone4.Vodoem4:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone4.Vodoem4.Bridge.Zone,
            workspace.Vodoemi.VodoemZone3.Vodoem3:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone3.Vodoem3.Bridge.Zone,
            workspace.Vodoemi.VodoemZone2.Vodoem2:GetChildren()[10].Zone,
            workspace.Vodoemi.VodoemZone2.Vodoem2.Bridge.Zone,
            workspace.Vodoemi.VodoemZone10.Vodoem10.Bridge.Zone,
            workspace.Vodoemi.VodoemZone10.Vodoem10:GetChildren()[5].Zone,
            workspace.Vodoemi.VodoemZone1.Vodoem1:GetChildren()[21].Zone,
            workspace.Vodoemi.VodoemZone1.Vodoem1.Bridge.Zone,
        }

        for _, zone in ipairs(zones) do
            if zone and zone:IsA("Part") then
                local distance = (playerPosition - zone.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestZone = zone
                end
            end
        end

        return closestZone
    end

    local function autoFish()
        while getgenv().AutoFishing do
            local closestZone = getClosestZone()
            if closestZone then
                local player = game.Players.LocalPlayer.Character
                local rootPart = player:WaitForChild("HumanoidRootPart")

                local tween = TweenService:Create(
                    rootPart,
                    TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {CFrame = closestZone.CFrame}
                )
                tween:Play()
                tween.Completed:Wait()

                if AAAFISH:GetAttribute("CanCatch") then
                    FishCatchedRemote:FireServer()
                    PlayerCaughtFishRemote:FireServer()
                    task.wait(1)
                end
            end
            task.wait(0.1)
        end
    end

    if getgenv().AutoFishing then
        task.spawn(autoFish)
    end
end)

aimstix:Toggle("Luck Boost", false, function(bool)
    getgenv().LuckBoost = bool

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local FishesInfo = require(ReplicatedStorage.Fishes.FishesInfo)

    local function applyLuckBoost()
        if getgenv().LuckBoost then
            for _, fishData in pairs(FishesInfo.ByName) do
                if fishData.Rarity and fishData.Rarity > 1 then
                    fishData.Rarity = fishData.Rarity / 100
                end
            end
        else
            for _, fishData in pairs(FishesInfo.ByName) do
                if fishData.Rarity and fishData.Rarity > 1 then
                    fishData.Rarity = fishData.Rarity * 100
                end
            end
        end
    end

    if getgenv().LuckBoost then
        task.spawn(applyLuckBoost)
    end
end)

aimstix:Toggle("Auto Upgrade", false, function(bool)
    getgenv().AutoUpgrade = bool

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local BuyUpgradeRemote = ReplicatedStorage.Remotes:WaitForChild("BuyUpgrade")
    local BuyGeneratorRemote = ReplicatedStorage.Remotes:WaitForChild("BuyGenerator")
    local BuyNewIslandRemote = ReplicatedStorage.Remotes:WaitForChild("BuyNewIsland")

    local function autoUpgrade()
        while getgenv().AutoUpgrade do
            BuyUpgradeRemote:FireServer()
            BuyGeneratorRemote:FireServer()
            BuyNewIslandRemote:FireServer()
            task.wait(1)
        end
    end

    if getgenv().AutoUpgrade then
        task.spawn(autoUpgrade)
    end
end)

aimstix:Button("Get Gamepasses", function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UpdateBoughtPassesRemote = ReplicatedStorage.Remotes:WaitForChild("UpdateBoughtPassesInfo")
    local GamepassesModule = require(ReplicatedStorage:WaitForChild("Gamepasses"))

    for _, gamepassData in pairs(GamepassesModule.Gamepasses) do
        UpdateBoughtPassesRemote:FireServer(gamepassData[1], true)
    end
end)
