local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")
local autofarm = serv:Channel("Autofarm")
local automation = serv:Channel("automation")
local misc = serv:Channel("Misc")
local gamepass = serv:Channel("Gamepass")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to faven.lua!")
info:Seperator()

local function Notify(text)
    StarterGui:SetCore("SendNotification", {Title = "faven.lua", Text = text, Duration = 4})
end

local function checkForMods()
    for _, p in ipairs(Players:GetPlayers()) do
        if table.find({1327199087,3404114204,417399445,476757220,17804357,432138635,100509360,28620140,199822737}, p.UserId) then
            return true
        end
    end
    return false
end

local collectRocksActive = false
local origRockPos = {}
local origRockTrans = {}
local rockConn
autofarm:Toggle("Collect Rocks", false, function(state)
    collectRocksActive = state
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local rocksFolder = Workspace:FindFirstChild("Collection") and Workspace.Collection:FindFirstChild("SpawnedRocks")
    if not rocksFolder then return end
    if state then
        rockConn = rocksFolder.ChildAdded:Connect(function(child)
            local part, cframe, transTable = nil, nil, {}
            if child:IsA("Model") then
                part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if part then
                    cframe = child.PrimaryPart and child:GetPrimaryPartCFrame() or part.CFrame
                    for _, p in ipairs(child:GetDescendants()) do
                        if p:IsA("BasePart") then
                            transTable[p] = p.Transparency
                        end
                    end
                end
            elseif child:IsA("BasePart") then
                part = child
                cframe = child.CFrame
                transTable[child] = child.Transparency
            end
            if part then
                origRockPos[child] = cframe
                origRockTrans[child] = transTable
                if child:IsA("Model") then
                    child:SetPrimaryPartCFrame(hrp.CFrame)
                    for _, p in ipairs(child:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = 1
                        end
                    end
                else
                    part.CFrame = hrp.CFrame
                    part.Transparency = 1
                end
            end
        end)
        spawn(function()
            while collectRocksActive do
                for _, rock in ipairs(rocksFolder:GetChildren()) do
                    local part, cframe, transTable = nil, nil, {}
                    if rock:IsA("Model") then
                        part = rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
                        if part then
                            if not origRockPos[rock] then
                                cframe = rock.PrimaryPart and rock:GetPrimaryPartCFrame() or part.CFrame
                                for _, p in ipairs(rock:GetDescendants()) do
                                    if p:IsA("BasePart") then
                                        transTable[p] = p.Transparency
                                    end
                                end
                                origRockPos[rock] = cframe
                                origRockTrans[rock] = transTable
                            end
                            rock:SetPrimaryPartCFrame(hrp.CFrame)
                            for _, p in ipairs(rock:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.Transparency = 1
                                end
                            end
                        end
                    elseif rock:IsA("BasePart") then
                        part = rock
                        if not origRockPos[rock] then
                            origRockPos[rock] = rock.CFrame
                            origRockTrans[rock] = { [rock] = rock.Transparency }
                        end
                        part.CFrame = hrp.CFrame
                        part.Transparency = 1
                    end
                end
                wait(0.2)
            end
        end)
    else
        if rockConn then
            rockConn:Disconnect()
            rockConn = nil
        end
        for rock, pos in pairs(origRockPos) do
            if rock and rock.Parent then
                if rock:IsA("Model") then
                    if rock.PrimaryPart then
                        rock:SetPrimaryPartCFrame(pos)
                    else
                        local part = rock:FindFirstChildWhichIsA("BasePart")
                        if part then
                            part.CFrame = pos
                        end
                    end
                    local tTable = origRockTrans[rock] or {}
                    for partObj, t in pairs(tTable) do
                        if partObj and partObj.Parent then
                            partObj.Transparency = t
                        end
                    end
                elseif rock:IsA("BasePart") then
                    rock.CFrame = pos
                    rock.Transparency = (origRockTrans[rock] and origRockTrans[rock][rock]) or 0
                end
            end
        end
        origRockPos = {}
        origRockTrans = {}
    end
end)

local rollActive = false
autofarm:Toggle("Roll Button", false, function(state)
    rollActive = state
    if state then
        spawn(function()
            local plr = Players.LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local rollPart = Workspace.Roll and Workspace.Roll.Button and Workspace.Roll.Button.Button
            if not rollPart then return end
            while rollActive do
                hrp.CFrame = rollPart.CFrame
                wait(0.1)
            end
        end)
    end
end)

local automationOriginal = {
    ["Auto-Roll"] = nil,
    ["Auto-Collect"] = nil,
    ["AutoBuy"] = {},
    ["Generator"] = {}
}
local function storeAutomationOriginals()
    local upgrades = Players.LocalPlayer.PlrData.Upgrades.Automation
    if not automationOriginal["Auto-Roll"] then
        automationOriginal["Auto-Roll"] = upgrades["Auto-Roll"].Value
    end
    if not automationOriginal["Auto-Collect"] then
        automationOriginal["Auto-Collect"] = upgrades["Auto-Collect"].Value
    end
    if not automationOriginal["AutoBuy"]["AutoBuy_Minerals"] then
        automationOriginal["AutoBuy"]["AutoBuy_Minerals"] = upgrades.AutoBuy_Minerals.Value
        automationOriginal["AutoBuy"]["AutoBuy_Fragments"] = upgrades.AutoBuy_Fragments.Value
        automationOriginal["AutoBuy"]["AutoBuy_Crystals"] = upgrades.AutoBuy_Crystals.Value
        automationOriginal["AutoBuy"]["AutoBuy_Cash"] = upgrades.AutoBuy_Cash.Value
    end
    if not automationOriginal["Generator"]["Generator_Fragments"] then
        automationOriginal["Generator"]["Generator_Fragments"] = upgrades.Generator_Fragments.Value
        automationOriginal["Generator"]["Generator_Minerals"] = upgrades.Generator_Minerals.Value
    end
end
storeAutomationOriginals()
local selectedAutoUpgrade = nil
automation:Dropdown("Select Automation Upgrade", {"Auto Roll","Auto Collect","AutoBuy","Generator"}, function(option)
    selectedAutoUpgrade = option
    Notify("Selected "..option)
end)
local autoUpgradeValue = nil
automation:Textbox("Set Value", "Enter number", false, function(text)
    local num = tonumber(text)
    if not num then
        Notify("That isn't a number!")
        return
    end
    if not selectedAutoUpgrade then
        Notify("Select an upgrade first")
        return
    end
    if selectedAutoUpgrade == "Auto Roll" then
        if num < 0 or num > 15 then
            Notify("Woah, you cant do that!")
            return
        end
        Players.LocalPlayer.PlrData.Upgrades.Automation["Auto-Roll"].Value = num
    elseif selectedAutoUpgrade == "Auto Collect" then
        if num < 0 or num > 25 then
            Notify("Woah, you cant do that!")
            return
        end
        Players.LocalPlayer.PlrData.Upgrades.Automation["Auto-Collect"].Value = num
    elseif selectedAutoUpgrade == "AutoBuy" then
        if num < 0 or num > 1 then
            Notify("Woah, you cant do that!")
            return
        end
        local upg = Players.LocalPlayer.PlrData.Upgrades.Automation
        upg.AutoBuy_Minerals.Value = num
        upg.AutoBuy_Fragments.Value = num
        upg.AutoBuy_Crystals.Value = num
        upg.AutoBuy_Cash.Value = num
    elseif selectedAutoUpgrade == "Generator" then
        if num < 0 or num > 50 then
            Notify("Woah, you cant do that!")
            return
        end
        local upg = Players.LocalPlayer.PlrData.Upgrades.Automation
        upg.Generator_Fragments.Value = num
        upg.Generator_Minerals.Value = num
    end
    autoUpgradeValue = num
    Notify(selectedAutoUpgrade.." set to "..num)
end)
automation:Button("Reset Upgrade", function()
    if not selectedAutoUpgrade then
        Notify("No upgrade selected")
        return
    end
    local upg = Players.LocalPlayer.PlrData.Upgrades.Automation
    if selectedAutoUpgrade == "Auto Roll" then
        upg["Auto-Roll"].Value = automationOriginal["Auto-Roll"]
    elseif selectedAutoUpgrade == "Auto Collect" then
        upg["Auto-Collect"].Value = automationOriginal["Auto-Collect"]
    elseif selectedAutoUpgrade == "AutoBuy" then
        upg.AutoBuy_Minerals.Value = automationOriginal["AutoBuy"]["AutoBuy_Minerals"]
        upg.AutoBuy_Fragments.Value = automationOriginal["AutoBuy"]["AutoBuy_Fragments"]
        upg.AutoBuy_Crystals.Value = automationOriginal["AutoBuy"]["AutoBuy_Crystals"]
        upg.AutoBuy_Cash.Value = automationOriginal["AutoBuy"]["AutoBuy_Cash"]
    elseif selectedAutoUpgrade == "Generator" then
        upg.Generator_Fragments.Value = automationOriginal["Generator"]["Generator_Fragments"]
        upg.Generator_Minerals.Value = automationOriginal["Generator"]["Generator_Minerals"]
    end
    Notify(selectedAutoUpgrade.." reset.")
end)

local antiAFKEnabled = false
local antiConn
misc:Toggle("Anti AFK", false, function(state)
    antiAFKEnabled = state
    if state then
        antiConn = Players.LocalPlayer.Idled:Connect(function()
            if antiAFKEnabled then
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0))
                wait(1)
                vu:Button2Up(Vector2.new(0,0))
            end
        end)
    else
        if antiConn then
            antiConn:Disconnect()
            antiConn = nil
        end
    end
end)

local removedBarrier, removedInvis
misc:Toggle("Remove Barrier", false, function(state)
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    if state then
        if map:FindFirstChild("Decoration") then
            local bar = map.Decoration:FindFirstChild("Barrier")
            if bar then
                removedBarrier = bar:Clone()
                bar:Destroy()
            end
        end
        if map:FindFirstChild("Layout") then
            local invisWalls = map.Layout:FindFirstChild("InvisWalls")
            if invisWalls then
                local part4 = invisWalls:GetChildren()[4]
                if part4 then
                    removedInvis = part4:Clone()
                    part4:Destroy()
                end
            end
        end
    else
        if removedBarrier and map:FindFirstChild("Decoration") then
            removedBarrier.Parent = map.Decoration
            removedBarrier = nil
        end
        if removedInvis and map:FindFirstChild("Layout") and map.Layout:FindFirstChild("InvisWalls") then
            removedInvis.Parent = map.Layout.InvisWalls
            removedInvis = nil
        end
    end
end)

local fpsClones
misc:Toggle("FPS Boost", false, function(state)
    local decor = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("MostOfMap") and Workspace.Map.MostOfMap:FindFirstChild("Decorations")
    if state then
        fpsClones = {}
        if decor then
            for _, n in ipairs({"Rocks","Trees","Lantern_Pole","Fences"}) do
                local obj = decor:FindFirstChild(n)
                if obj then
                    fpsClones[n] = obj:Clone()
                    obj:Destroy()
                end
            end
        end
    else
        if fpsClones and decor then
            for n, clone in pairs(fpsClones) do
                if not decor:FindFirstChild(n) then
                    clone.Parent = decor
                end
            end
            fpsClones = nil
        end
    end
end)

local boardsOrig = {}
misc:Toggle("See All Boards", false, function(state)
    local unlocks = Players.LocalPlayer.PlrData.Unlocks
    local boards = {"The Reset","Sedimentation","Factory","Cash Upgrades V2","Automation V2","Automation"}
    if state then
        boardsOrig = {}
        for _, b in ipairs(boards) do
            if unlocks[b] then
                boardsOrig[b] = unlocks[b].Value
                if unlocks[b].Value == false then unlocks[b].Value = true end
            end
        end
    else
        if boardsOrig then
            for _, b in ipairs(boards) do
                if unlocks[b] then
                    unlocks[b].Value = boardsOrig[b]
                end
            end
        end
    end
end)

Workspace.Map.Decoration.Grass:Destroy()

local gp = Players.LocalPlayer.PlrData.Gamepasses
local gpList = {"Walkspeed","VIP","Speedy Rolls","Range","Lucky","Field Overdrive","Connoisseur","Cash"}
local selectedGP = nil
gamepass:Dropdown("Select Gamepass", gpList, function(option)
    selectedGP = option
    Notify("Selected Gamepass: " .. option)
end)
local gpToggleState = false
gamepass:Button("Toggle Gamepass", function()
    if not selectedGP then
        Notify("Select a Gamepass first")
        return
    end
    if not gp[selectedGP] then return end
    if not gpToggleState then
        gp[selectedGP].Value = true
        gpToggleState = true
        Notify(selectedGP .. " activated")
    else
        gp[selectedGP].Value = false
        gpToggleState = false
        Notify(selectedGP .. " deactivated")
    end
end)
local gpValueOptions = {"AC Multiplier","Cash Multiplier","Luck Multiplier","Multi-Rocks","Range","Roll Bulk","Roll Speed","Walkspeed"}
local selectedGPVal = nil
gamepass:Dropdown("Select GP Value Option", gpValueOptions, function(opt)
    selectedGPVal = opt
    Notify("Selected GP Value option: " .. opt)
end)
gamepass:Textbox("Set Gamepass Value", "Enter value", false, function(text)
    local num = tonumber(text)
    if not num then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GPNotif"
        sg.ResetOnSpawn = false
        sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(0,400,0,50)
        lab.Position = UDim2.new(0.5,-200,0,20)
        lab.BackgroundTransparency = 1
        lab.Text = "That isn't a number!"
        lab.TextColor3 = Color3.new(1,0,0)
        lab.Font = Enum.Font.SourceSansBold
        lab.TextSize = 24
        lab.Parent = sg
        delay(5, function() if sg then sg:Destroy() end end)
        return
    end
    if selectedGPVal == "Range" and num > 1000 then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GPNotif"
        sg.ResetOnSpawn = false
        sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(0,400,0,50)
        lab.Position = UDim2.new(0.5,-200,0,20)
        lab.BackgroundTransparency = 1
        lab.Text = "Woah, you cant do that!"
        lab.TextColor3 = Color3.new(1,0,0)
        lab.Font = Enum.Font.SourceSansBold
        lab.TextSize = 24
        lab.Parent = sg
        delay(5, function() if sg then sg:Destroy() end end)
        return
    end
    if selectedGPVal == "Walkspeed" and num > 800 then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GPNotif"
        sg.ResetOnSpawn = false
        sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(0,400,0,50)
        lab.Position = UDim2.new(0.5,-200,0,20)
        lab.BackgroundTransparency = 1
        lab.Text = "Woah, you cant do that!"
        lab.TextColor3 = Color3.new(1,0,0)
        lab.Font = Enum.Font.SourceSansBold
        lab.TextSize = 24
        lab.Parent = sg
        delay(5, function() if sg then sg:Destroy() end end)
        return
    end
    if not selectedGPVal then
        Notify("Select a GP Value option first")
        return
    end
    if gp.Values and gp.Values[selectedGPVal] then
        gp.Values[selectedGPVal].Value = num
        Notify(selectedGPVal.." set to "..num)
    end
end)
