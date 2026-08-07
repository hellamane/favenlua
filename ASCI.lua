-- Made by faven.lua/steppin0nsteppas
-- 4/28/26 Completed and will not update, use while you can (If You're Reading This).



local DiscordLib =
local DiscordLib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt")()

local win = DiscordLib:Window("faven.lua")

local serv = win:Server("Ascension Incremental", "")

local startpage = serv:Channel("Welcome")



local plr = game:GetService("Players").LocalPlayer

local prestiges = plr:WaitForChild("PrestigesUnlock")
local axerein = plr:WaitForChild("AxeRein")
local eventUnlocks = plr:WaitForChild("EventUnlocks")

local targets = {
    prestiges:WaitForChild("Challenges"),
    prestiges:WaitForChild("NewWorld"),
    prestiges:WaitForChild("Rings"),
    axerein:WaitForChild("Crusher"),
    axerein:WaitForChild("Factory"),
    axerein:WaitForChild("Mine"),
    eventUnlocks:WaitForChild("EventWorldII")
}

task.spawn(function()
    while task.wait(0.1) do
        for _, v in ipairs(targets) do
            if v.Value == false then
                v.Value = true
            end
        end
    end
end)


startpage:Seperator()


startpage:Label("Welcome to faven.lua")


startpage:Seperator()


startpage:Label("Made by steppin0nsteppas")


startpage:Seperator()


startpage:Label("I still need to fix a couple things for this, but it works mostly.")






local automationz = serv:Channel("Automations")


automationz:Toggle(
    "Auto Buy Upgrades",
    false,
    function(bool)
        if bool then
            local plr = game:GetService("Players").LocalPlayer
            local stat = plr.Settings:FindFirstChild("AutoBuyUpgrades")
            if stat then
                stat.Value = true
            end
        end
    end
)

automationz:Seperator()


automationz:Toggle(
    "Auto Ascend",
    false,
    function(bool)
        if bool then
            local plr = game:GetService("Players").LocalPlayer
            local stat = plr.Settings:FindFirstChild("AutoAsc")
            if stat then
                stat.Value = true
            end
        end
    end
)


automationz:Seperator()


automationz:Toggle(
    "Auto Buy Rebirths",
    false,
    function(bool)
        if bool then
            local plr = game:GetService("Players").LocalPlayer


            local multi = plr.UpgradeTreeMulti:FindFirstChild("AutoBuyRebirths")
            if multi then
                multi.Value = 1
            end


            local add = plr.UpgradeTreeAdditional:FindFirstChild("AutoBuyRebirths")
            if add then
                add.Value = true
            end
        end
    end
)


automationz:Seperator()


automationz:Toggle(
    "Auto Buy Points",
    false,
    function(bool)
        if bool then
            local plr = game:GetService("Players").LocalPlayer


            local multi = plr.UpgradeTreeMulti:FindFirstChild("AutoBuyPoints")
            if multi then
                multi.Value = 1
            end


            local add = plr.UpgradeTreeAdditional:FindFirstChild("AutoBuyPoints")
            if add then
                add.Value = true
            end
        end
    end
)


automationz:Seperator()


automationz:Toggle(
    "Auto Buy Dices",
    false,
    function(bool)
        if bool then
            local plr = game:GetService("Players").LocalPlayer


            local multi = plr.UpgradeTreeMulti:FindFirstChild("AutoBuyDices")
            if multi then
                multi.Value = 1
            end


            local add = plr.UpgradeTreeAdditional:FindFirstChild("AutoBuyDices")
            if add then
                add.Value = true
            end
        end
    end
)






local firstworldz = serv:Channel("Spawn World")




firstworldz:Toggle(
    "Auto Rebirth",
    false,
    function(bool)
        getgenv().AutoRebirth = bool

        if bool then
            task.spawn(function()
                while getgenv().AutoRebirth do
                    local RS = game:GetService("ReplicatedStorage")
                    local Remotes = RS:WaitForChild("Remotes")
                    local Rebirthzz = Remotes:WaitForChild("Rebirth")

                    Rebirthzz:FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
)


firstworldz:Seperator()


firstworldz:Toggle(
    "Auto Roll Rarity",
    false,
    function(bool)
        getgenv().AutoRollRarity = bool

        if bool then
            task.spawn(function()
                while getgenv().AutoRollRarity do
                    local RS = game:GetService("ReplicatedStorage")
                    local Remotes = RS:WaitForChild("Remotes")
                    local RollRarityEvent = Remotes:WaitForChild("RollRarityEvent")

                    RollRarityEvent:FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
)

firstworldz:Seperator()

firstworldz:Toggle(
    "Use Basic Rune",
    false,
    function(bool)
        getgenv().UseBasicRune = bool

        -- Locate the Hitbox
        local folder = workspace:FindFirstChild("BasicRune")
        if not folder then return end

        local rune = folder:FindFirstChild("BasicRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        -- Save original CFrame once
        if not getgenv().OriginalBasicRuneCF then
            getgenv().OriginalBasicRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseBasicRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalBasicRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalBasicRuneCF
            end
        end
    end
)

firstworldz:Seperator()

firstworldz:Toggle(
    "Use Dice Rune",
    false,
    function(bool)
        getgenv().UseDiceRune = bool

        local folder = workspace:FindFirstChild("DiceRune")
        if not folder then return end

        local rune = folder:FindFirstChild("DiceRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalDiceRuneCF then
            getgenv().OriginalDiceRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseDiceRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalDiceRuneCF then
                hitbox.CFrame = getgenv().OriginalDiceRuneCF
            end
        end
    end
)




local eventworldz = serv:Channel("Event World")

eventworldz:Label("This is for the first event world as of 4/24/26")

eventworldz:Toggle(
    "Auto Collect (Event 1)",
    false,
    function(bool)
        if bool then
            local v = game:GetService("Players").LocalPlayer.EventUpgradeTree2:FindFirstChild("AutoCollect")
            if v then
                v.Value = 1
            end
        end
    end
)

eventworldz:Seperator()


eventworldz:Toggle(
    "1st Event Upgrade",
    false,
    function(bool)
        getgenv().EventUpgradeBuy1z = bool

        if bool then
            task.spawn(function()
                while getgenv().EventUpgradeBuy1z do
                    local RS = game:GetService("ReplicatedStorage")
                    local Remotes = RS:WaitForChild("Remotes")
                    local EventUpgradeBuy1z = Remotes:WaitForChild("EventUpgradeBuy")

                    EventUpgradeBuy1z:FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
)


eventworldz:Seperator()


eventworldz:Toggle(
    "Use 1K Visits Rune",
    false,
    function(bool)
        getgenv().UseVisitRune = bool


        local folder = workspace:FindFirstChild("VisitRune")
        if not folder then return end

        local rune = folder:FindFirstChild("VisitRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVisitRuneCF then
            getgenv().OriginalVisitRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVisitRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVisitRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalVisitRuneCF
            end
        end
    end
)


eventworldz:Seperator()


eventworldz:Toggle(
    "Use Recover Rune",
    false,
    function(bool)
        getgenv().UseRecoverRune = bool


        local folder = workspace:FindFirstChild("RecoverRune")
        if not folder then return end

        local rune = folder:FindFirstChild("RecoverRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        -- Save original CFrame once
        if not getgenv().OriginalRecoverRuneCF then
            getgenv().OriginalRecoverRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseRecoverRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalRecoverRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalRecoverRuneCF
            end
        end
    end
)


eventworldz:Seperator()


eventworldz:Toggle(
    "Use 75K Visits Rune",
    false,
    function(bool)
        getgenv().UseVisitRune2 = bool


        local folder = workspace:FindFirstChild("VisitRune2")
        if not folder then return end

        local rune = folder:FindFirstChild("VisitRune2")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVisitRune2CF then
            getgenv().OriginalVisitRune2CF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVisitRune2 do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVisitRune2CF and hitbox then
                hitbox.CFrame = getgenv().OriginalVisitRune2CF
            end
        end
    end
)


eventworldz:Seperator()


eventworldz:Toggle(
    "Use 400K Visits Rune",
    false,
    function(bool)
        getgenv().UseVisitRune3 = bool


        local folder = workspace:FindFirstChild("VisitRune3")
        if not folder then return end

        local rune = folder:FindFirstChild("VisitRune3")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVisitRune3CF then
            getgenv().OriginalVisitRune3CF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVisitRune3 do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVisitRune3CF and hitbox then
                hitbox.CFrame = getgenv().OriginalVisitRune3CF
            end
        end
    end
)


local eventworldz2 = serv:Channel("Event World2")

eventworldz2:Label("This is for the second event world as of 4/27/26")

eventworldz2:Toggle(
    "Auto Collect (Event 2)",
    false,
    function(bool)
        if bool then
            local v = game:GetService("Players").LocalPlayer.EventUpgradeTree:FindFirstChild("AutoCollect")
            if v then
                v.Value = 1
            end
        end
    end
)

eventworldz2:Seperator()

eventworldz2:Toggle(
    "2nd Event Upgrade",
    false,
    function(bool)
        getgenv().EventUpgradeBuy2z = bool

        if bool then
            task.spawn(function()
                while getgenv().EventUpgradeBuy2z do
                    local RS = game:GetService("ReplicatedStorage")
                    local Remotes = RS:WaitForChild("Remotes")
                    local EventUpgradeBuy2z = Remotes:WaitForChild("EventUpgradeBuy2")

                    EventUpgradeBuy2z:FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
)

eventworldz2:Seperator()


eventworldz2:Toggle(
    "Use Growth Rune",
    false,
    function(bool)
        getgenv().UseGrowthRune = bool


        local folder = workspace:FindFirstChild("GrowthRune")
        if not folder then return end

        local rune = folder:FindFirstChild("GrowthRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalGrowthRuneCF then
            getgenv().OriginalGrowthRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseGrowthRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalGrowthRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalGrowthRuneCF
            end
        end
    end
)


eventworldz2:Seperator()


eventworldz2:Toggle(
    "Use 1M Visits Rune",
    false,
    function(bool)
        getgenv().UseVisitRune4 = bool


        local folder = workspace:FindFirstChild("VisitRune4")
        if not folder then return end

        local rune = folder:FindFirstChild("VisitRune4")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVisitRune4CF then
            getgenv().OriginalVisitRune4CF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVisitRune4 do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVisitRune4CF and hitbox then
                hitbox.CFrame = getgenv().OriginalVisitRune4CF
            end
        end
    end
)


eventworldz2:Seperator()


eventworldz2:Toggle(
    "Use 1.5M Visits Rune",
    false,
    function(bool)
        getgenv().UseVisitRune5 = bool


        local folder = workspace:FindFirstChild("VisitRune5")
        if not folder then return end

        local rune = folder:FindFirstChild("VisitRune5")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVisitRune5CF then
            getgenv().OriginalVisitRune5CF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVisitRune5 do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVisitRune5CF and hitbox then
                hitbox.CFrame = getgenv().OriginalVisitRune5CF
            end
        end
    end
)


local hellvish = serv:Channel("Hell World")



hellvish:Toggle(
    "Gain Magma",
    false,
    function(bool)
        getgenv().UseMagmaButton = bool


        local folder = workspace:FindFirstChild("Buttons")
        if not folder then return end

        local magma = folder:FindFirstChild("Magma")
        if not magma then return end

        local touch = magma:FindFirstChild("TouchPart")
        if not touch or not touch:IsA("BasePart") then return end


        if not getgenv().OriginalMagmaTouchCF then
            getgenv().OriginalMagmaTouchCF = touch.CFrame
        end

        if bool then
            touch.CanCollide = false

            task.spawn(function()
                while getgenv().UseMagmaButton do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and touch then
                        touch.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            touch.CanCollide = true

            if getgenv().OriginalMagmaTouchCF and touch then
                touch.CFrame = getgenv().OriginalMagmaTouchCF
            end
        end
    end
)

hellvish:Seperator()


hellvish:Toggle(
    "Use Volcano Rune",
    false,
    function(bool)
        getgenv().UseVolcanoRune = bool


        local folder = workspace:FindFirstChild("VolcanoRune")
        if not folder then return end

        local rune = folder:FindFirstChild("VolcanoRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end


        if not getgenv().OriginalVolcanoRuneCF then
            getgenv().OriginalVolcanoRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVolcanoRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVolcanoRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalVolcanoRuneCF
            end
        end
    end
)




local zenworldz = serv:Channel("Zen World")

zenworldz:Toggle(
    "Clear Bamboo Lag",
    false,
    function(bool)
        getgenv().ClearBambooLag = bool

        local folder = workspace:FindFirstChild("LocalBambooStorage")
        if not folder then return end

        if bool then
            task.spawn(function()
                while getgenv().ClearBambooLag do
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("BasePart") then
                            obj.Transparency = 1
                            obj.CanCollide = false
                        elseif obj:IsA("Model") then
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
)

zenworldz:Seperator()

zenworldz:Textbox(
    "Spawn Rate",
    "Enter Spawn Rate Value",
    true,
    function(text)
        local num = tonumber(text)
        if num then
            local stat = game:GetService("Players").LocalPlayer.IncStats:FindFirstChild("SpawnRate")
            if stat then
                stat.Value = num
            end
        end
    end
)

zenworldz:Seperator()


zenworldz:Textbox(
    "Radius",
    "Enter Your Radius Value",
    true,
    function(text)
        local num = tonumber(text)
        if num then
            local stat = game:GetService("Players").LocalPlayer.IncStats:FindFirstChild("Radius")
            if stat then
                stat.Value = num
            end
        end
    end
)

zenworldz:Seperator()


zenworldz:Textbox(
    "Bamboo Capacity",
    "Enter Capacity Value",
    true,
    function(text)
        local num = tonumber(text)
        if num then
            local stat = game:GetService("Players").LocalPlayer.IncStats:FindFirstChild("MaxSpawn")
            if stat then
                stat.Value = num
            end
        end
    end
)

zenworldz:Seperator()


zenworldz:Toggle(
    "Use Panda Rune",
    false,
    function(bool)
        getgenv().UsePandaRune = bool

        local folder = workspace:FindFirstChild("PandaRune")
        if not folder then return end

        local rune = folder:FindFirstChild("PandaRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalPandaRuneCF then
            getgenv().OriginalPandaRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UsePandaRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalPandaRuneCF then
                hitbox.CFrame = getgenv().OriginalPandaRuneCF
            end
        end
    end
)

zenworldz:Seperator()


zenworldz:Toggle(
    "Use Sakura Rune",
    false,
    function(bool)
        getgenv().UseSakuraRune = bool

        local folder = workspace:FindFirstChild("SakuraRune")
        if not folder then return end

        local rune = folder:FindFirstChild("SakuraRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalSakuraRuneCF then
            getgenv().OriginalSakuraRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseSakuraRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalSakuraRuneCF then
                hitbox.CFrame = getgenv().OriginalSakuraRuneCF
            end
        end
    end
)



local fruitworldzz = serv:Channel("Fruit World")



fruitworldzz:Toggle(
    "Clear Fruit Lag",
    false,
    function(bool)
        getgenv().ClearFruitLag = bool

        local folder = workspace:FindFirstChild("LocalFruitStorage")
        if not folder then
            return
        end

        if bool then
            task.spawn(function()
                while getgenv().ClearFruitLag do
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("BasePart") then
                            obj.Transparency = 1
                            obj.CanCollide = false
                        elseif obj:IsA("Model") then
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
)

fruitworldzz:Seperator()


fruitworldzz:Textbox(
    "Fruit Spawn Rate",
    "Enter value",
    true,
    function(text)
        local n = tonumber(text)
        if n then
            local v = game:GetService("Players").LocalPlayer.FruitStats:FindFirstChild("FruitSpawnRate")
            if v then
                v.Value = n
            end
        end
    end
)

fruitworldzz:Seperator()

fruitworldzz:Textbox(
    "Fruit Radius",
    "Enter value",
    true,
    function(text)
        local n = tonumber(text)
        if n then
            local v = game:GetService("Players").LocalPlayer.FruitStats:FindFirstChild("FruitRadius")
            if v then
                v.Value = n
            end
        end
    end
)

fruitworldzz:Seperator()

fruitworldzz:Textbox(
    "Fruit Max Spawn",
    "Enter value",
    true,
    function(text)
        local n = tonumber(text)
        if n then
            local v = game:GetService("Players").LocalPlayer.FruitStats:FindFirstChild("FruitMaxSpawn")
            if v then
                v.Value = n
            end
        end
    end
)

fruitworldzz:Seperator()


fruitworldzz:Toggle(
    "Use Refresher Rune",
    false,
    function(bool)
        getgenv().UseRefresherRune = bool

        local folder = workspace:FindFirstChild("RefresherRune")
        if not folder then return end

        local rune = folder:FindFirstChild("RefresherRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalRefresherRuneCF then
            getgenv().OriginalRefresherRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseRefresherRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalRefresherRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalRefresherRuneCF
            end
        end
    end
)


fruitworldzz:Seperator()



fruitworldzz:Toggle(
    "Use Tree Rune",
    false,
    function(bool)
        getgenv().UseTreeRune = bool

        local folder = workspace:FindFirstChild("TreeRune")
        if not folder then return end

        local rune = folder:FindFirstChild("TreeRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        -- Save original CFrame once
        if not getgenv().OriginalTreeRuneCF then
            getgenv().OriginalTreeRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseTreeRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp and hitbox then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalTreeRuneCF and hitbox then
                hitbox.CFrame = getgenv().OriginalTreeRuneCF
            end
        end
    end
)


local dockworldzz = serv:Channel("Dock World")


dockworldzz:Toggle(
    "Large Net",
    false,
    function(bool)
        if bool then
            local v = game:GetService("Players").LocalPlayer.Nets:FindFirstChild("LargeNet")
            if v then
                v.Value = true
            end
        end
    end
)

dockworldzz:Seperator()

dockworldzz:Toggle(
    "Medium Net",
    false,
    function(bool)
        if bool then
            local v = game:GetService("Players").LocalPlayer.Nets:FindFirstChild("MediumNet")
            if v then
                v.Value = true
            end
        end
    end
)

dockworldzz:Seperator()

dockworldzz:Toggle(
    "Small Net",
    false,
    function(bool)
        if bool then
            local v = game:GetService("Players").LocalPlayer.Nets:FindFirstChild("SmallNet")
            if v then
                v.Value = true
            end
        end
    end
)

dockworldzz:Seperator()

dockworldzz:Toggle(
    "Auto Sell Fish",
    false,
    function(bool)
        getgenv().AutoSellFish = bool

        if bool then
            task.spawn(function()
                while getgenv().AutoSellFish do
                    local r = game:GetService("ReplicatedStorage").Remotes:FindFirstChild("SellFishEvent")
                    if r then
                        r:FireServer()
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
)

dockworldzz:Seperator()

dockworldzz:Toggle(
    "Auto Fishing",
    false,
    function(bool)
        getgenv().AutoFishing = bool

        if bool then
            task.spawn(function()
                while getgenv().AutoFishing do
                    local r = game:GetService("ReplicatedStorage").Remotes:FindFirstChild("FishingEvent")
                    if r then
                        r:FireServer()
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
)

dockworldzz:Seperator()

dockworldzz:Toggle(
    "Use Ocean Rune",
    false,
    function(bool)
        getgenv().UseOceanRune = bool

        local folder = workspace:FindFirstChild("OceanRune")
        if not folder then return end

        local rune = folder:FindFirstChild("OceanRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalOceanRuneCF then
            getgenv().OriginalOceanRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseOceanRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalOceanRuneCF then
                hitbox.CFrame = getgenv().OriginalOceanRuneCF
            end
        end
    end
)


dockworldzz:Seperator()


dockworldzz:Toggle(
    "Use Deep Rune",
    false,
    function(bool)
        getgenv().UseDeepRune = bool

        local folder = workspace:FindFirstChild("DeepRune")
        if not folder then return end

        local rune = folder:FindFirstChild("DeepRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalDeepRuneCF then
            getgenv().OriginalDeepRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseDeepRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalDeepRuneCF then
                hitbox.CFrame = getgenv().OriginalDeepRuneCF
            end
        end
    end
)


local treeworldzz = serv:Channel("Industry World")


treeworldzz:Label("I'm still currently testing things, more features soon.")


treeworldzz:Seperator()



treeworldzz:Textbox(
    "Enter Chop Speed",
    "Enter value",
    function(text)
        local num = tonumber(text)
        if not num then
            return
        end

        local stat = game:GetService("Players").LocalPlayer.TreeStats:FindFirstChild("Cooldown")
        if stat then
            stat.Value = num
        end
    end
)



treeworldzz:Textbox(
    "Enter Chop Damage",
    "Enter value",
    true,
    function(text)
        local num = tonumber(text)
        if not num then
            return
        end

        local stat = game:GetService("Players").LocalPlayer.TreeStats:FindFirstChild("Damage")
        if stat then
            stat.Value = num
        end

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "faven.lua",
            Text = "May not work if it exceeds upgrade's dmg, etc.",
            Duration = 3
        })
    end
)


treeworldzz:Seperator()


local treeFolder = workspace:WaitForChild("W6"):WaitForChild("Trees")
local savedPositions = {}
local bringTrees = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local treeFolder = workspace:WaitForChild("W6"):WaitForChild("Trees")
local savedPositions = {}
local bringTrees = false

local function modelHasMesh(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("MeshPart") then
            return true
        end
    end
    return false
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local treeFolder = workspace:WaitForChild("W6"):WaitForChild("Trees")
local running = false

local function modelHasMesh(model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("MeshPart") then
            return true
        end
    end
    return false
end

local function getTrees()
    local list = {}
    for _, m in ipairs(treeFolder:GetChildren()) do
        if m:IsA("Model") and modelHasMesh(m) then
            table.insert(list, m)
        end
    end
    return list
end

treeworldzz:Toggle(
    "Goto Trees",
    false,
    function(state)
        running = state

        if state then
            task.spawn(function()
                while running do
                    local trees = getTrees()
                    if #trees == 0 then
                        task.wait(0.2)
                        continue
                    end

                    local tree = trees[1]
                    local primary = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")

                    if primary then
                        hrp.CFrame = primary.CFrame + Vector3.new(0, 3, 0)
                    end

                    while running and tree.Parent == treeFolder do
                        task.wait(0.1)
                    end

                    task.wait(0.1)
                end
            end)
        end
    end
)




treeworldzz:Seperator()



local Players = game:GetService("Players")
local player = Players.LocalPlayer

local treeFolder = workspace:WaitForChild("W6"):WaitForChild("Trees")
local invisible = false

local function setTreeVisibility(model, state)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Transparency = state and 1 or 0
        end
    end
end

treeworldzz:Toggle(
    "Invisible Trees",
    false,
    function(state)
        invisible = state

        if state then
            for _, model in ipairs(treeFolder:GetChildren()) do
                if model:IsA("Model") then
                    setTreeVisibility(model, true)
                end
            end

            task.spawn(function()
                while invisible do
                    for _, model in ipairs(treeFolder:GetChildren()) do
                        if model:IsA("Model") then
                            setTreeVisibility(model, true)
                        end
                    end
                    task.wait(0.2)
                end
            end)

        else
            for _, model in ipairs(treeFolder:GetChildren()) do
                if model:IsA("Model") then
                    setTreeVisibility(model, false)
                end
            end
        end
    end
)




treeworldzz:Seperator()

treeworldzz:Toggle(
    "Use Mine Rune",
    false,
    function(bool)
        getgenv().UseMineRune = bool

        local folder = workspace:FindFirstChild("MineRune")
        if not folder then return end

        local rune = folder:FindFirstChild("MineRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalMineRuneCF then
            getgenv().OriginalMineRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseMineRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalMineRuneCF then
                hitbox.CFrame = getgenv().OriginalMineRuneCF
            end
        end
    end
)


treeworldzz:Seperator()


treeworldzz:Toggle(
    "Use Volt Rune",
    false,
    function(bool)
        getgenv().UseVoltRune = bool

        local folder = workspace:FindFirstChild("VoltRune")
        if not folder then return end

        local rune = folder:FindFirstChild("VoltRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalVoltRuneCF then
            getgenv().OriginalVoltRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseVoltRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalVoltRuneCF then
                hitbox.CFrame = getgenv().OriginalVoltRuneCF
            end
        end
    end
)

local galactixy = serv:Channel("Magic Forest World")


galactixy:Label("I'm still currently testing things, more features soon.")


galactixy:Seperator()


galactixy:Toggle(
    "Auto Anomaly (Rankage)",
    false,
    function(bool)
        getgenv().AutoAnomalyRankage = bool

        local root = workspace:FindFirstChild("W7")
        if not root then return end

        local anomaly = root:FindFirstChild("Anomaly")
        if not anomaly then return end

        local buttonModel = anomaly:FindFirstChild("Button")
        if not buttonModel then return end


        local parts = {
            buttonModel:FindFirstChild("Button"),
            buttonModel:FindFirstChild("Hitbox"),
            buttonModel:FindFirstChild("Mesh")
        }

        if bool then
            -- store original CFrames fresh every toggle ON
            getgenv().OriginalAnomalyParts = {}

            for i, p in ipairs(parts) do
                if p and p:IsA("BasePart") then
                    getgenv().OriginalAnomalyParts[i] = p.CFrame
                    p.CanCollide = false
                end
            end

            task.spawn(function()
                while getgenv().AutoAnomalyRankage do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        for _, p in ipairs(parts) do
                            if p and p:IsA("BasePart") then
                                p.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                            end
                        end
                    end

                    task.wait(0.05)
                end
            end)

        else

            if getgenv().OriginalAnomalyParts then
                for i, p in ipairs(parts) do
                    local original = getgenv().OriginalAnomalyParts[i]
                    if p and p:IsA("BasePart") and original then
                        p.CFrame = original
                        p.CanCollide = true
                    end
                end
            end
        end
    end
)



galactixy:Seperator()

galactixy:Toggle(
    "Use Cyber Rune",
    false,
    function(bool)
        getgenv().UseCyberRune = bool

        local folder = workspace:FindFirstChild("CyberRune")
        if not folder then return end

        local rune = folder:FindFirstChild("CyberRune")
        if not rune then return end

        local hitbox = rune:FindFirstChild("Hitbox", true)
        if not hitbox or not hitbox:IsA("BasePart") then return end

        if not getgenv().OriginalCyberRuneCF then
            getgenv().OriginalCyberRuneCF = hitbox.CFrame
        end

        if bool then
            hitbox.CanCollide = false

            task.spawn(function()
                while getgenv().UseCyberRune do
                    local plr = game:GetService("Players").LocalPlayer
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hitbox.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                    end

                    task.wait(0.05)
                end
            end)
        else
            hitbox.CanCollide = true

            if getgenv().OriginalCyberRuneCF then
                hitbox.CFrame = getgenv().OriginalCyberRuneCF
            end
        end
    end
)

galactixy:Seperator()


galactixy:Label("VERY OP, set prestige to a value to unlock boards.")



galactixy:Textbox(
    "Prestige",
    "Enter Prestige Value",
    true,
    function(text)
        local num = tonumber(text)
        if num then
            local plr = game:GetService("Players").LocalPlayer
            local prestige = plr.Prestiges:FindFirstChild("Prestige")
            if prestige then
                prestige.Value = num
            end
        end
    end
)

galactixy:Seperator()



local serv = win:Server("Player Obstructions", "")
local drops = serv:Channel("Player Settings")
local teleportz = serv:Channel("Teleportation")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local movementToggle = false
local wsValue = hum.WalkSpeed
local jpValue = hum.JumpPower

local originalValues = {
    WalkSpeed = hum.WalkSpeed,
    JumpPower = hum.JumpPower
}

drops:Toggle(
    "Enable Movement Modifier",
    false,
    function(state)
        movementToggle = state

        if state then
            originalValues.WalkSpeed = hum.WalkSpeed
            originalValues.JumpPower = hum.JumpPower

            hum.WalkSpeed = wsValue
            hum.JumpPower = jpValue
        else
            hum.WalkSpeed = originalValues.WalkSpeed
            hum.JumpPower = originalValues.JumpPower
        end
    end
)

drops:Slider(
    "WalkSpeed Value",
    0,
    150,
    originalValues.WalkSpeed,
    function(val)
        wsValue = val
        if movementToggle then
            hum.WalkSpeed = wsValue
        end
    end
)

drops:Slider(
    "JumpPower Value",
    0,
    200,
    originalValues.JumpPower,
    function(val)
        jpValue = val
        if movementToggle then
            hum.JumpPower = jpValue
        end
    end
)


local Players = game:GetService("Players")
local player = Players.LocalPlayer

local locations = {
    ["Spawn World"] = CFrame.new(102, 3, -160),
    ["Event World I"] = CFrame.new(761, 3, 154),
    ["Event World II"] = CFrame.new(772, 3, 431),
    ["Hell World"] = CFrame.new(72, 3, -443),
    ["Zen World"] = CFrame.new(86, 3, -792),
    ["Fruit World"] = CFrame.new(1191, 8, 475),
    ["Docks World"] = CFrame.new(816, 4, -489),
    ["Industry World"] = CFrame.new(1090, 4, -346),
    ["Magic Forest"] = CFrame.new(1352, 1, 147)
}

local selected = "Spawn World"

teleportz:Dropdown(
    "Select Location",
    {"Spawn World", "Event World I", "Event World II", "Hell World", "Zen World", "Fruit World", "Docks World", "Industry World", "Magic Forest"},
    function(choice)
        selected = choice
    end
)

teleportz:Button(
    "Teleport",
    function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = locations[selected]
        end
    end
)
