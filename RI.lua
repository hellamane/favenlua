local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")
local autofarm = serv:Channel("Autofarm")
local misc = serv:Channel("Misc")
local gamepass = serv:Channel("Gamepass")
local textbs = serv:Channel("Textboxes")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to faven.lua!")
info:Seperator()

local function checkForMods()
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find({1327199087,3404114204,417399445,476757220,17804357,432138635,100509360,28620140,199822737}, player.UserId) then
            return true
        end
    end
    return false
end

local collectRocksActive = false
local originalRocksPositions = {}
local originalRocksTransparencies = {}
local rockAddedConnection
autofarm:Toggle("Collect Rocks", false, function(state)
    collectRocksActive = state
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local rocksFolder = Workspace:FindFirstChild("Collection") and Workspace.Collection:FindFirstChild("SpawnedRocks")
    if not rocksFolder then return end
    if state then
        rockAddedConnection = rocksFolder.ChildAdded:Connect(function(child)
            local part, origCFrame, origTrans = nil, nil, {}
            if child:IsA("Model") then
                part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                if part then
                    origCFrame = child.PrimaryPart and child:GetPrimaryPartCFrame() or part.CFrame
                    for _, p in ipairs(child:GetDescendants()) do
                        if p:IsA("BasePart") then origTrans[p] = p.Transparency end
                    end
                end
            elseif child:IsA("BasePart") then
                part = child
                origCFrame = child.CFrame
                origTrans[child] = child.Transparency
            end
            if part then
                originalRocksPositions[child] = origCFrame
                originalRocksTransparencies[child] = origTrans
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
                    local part, origCFrame, origTrans = nil, nil, {}
                    if rock:IsA("Model") then
                        part = rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
                        if part then
                            if not originalRocksPositions[rock] then
                                origCFrame = rock.PrimaryPart and rock:GetPrimaryPartCFrame() or part.CFrame
                                for _, p in ipairs(rock:GetDescendants()) do
                                    if p:IsA("BasePart") then origTrans[p] = p.Transparency end
                                end
                                originalRocksPositions[rock] = origCFrame
                                originalRocksTransparencies[rock] = origTrans
                            end
                            rock:SetPrimaryPartCFrame(hrp.CFrame)
                            for _, p in ipairs(rock:GetDescendants()) do
                                if p:IsA("BasePart") then p.Transparency = 1 end
                            end
                        end
                    elseif rock:IsA("BasePart") then
                        part = rock
                        if not originalRocksPositions[rock] then
                            originalRocksPositions[rock] = rock.CFrame
                            originalRocksTransparencies[rock] = { [rock] = rock.Transparency }
                        end
                        part.CFrame = hrp.CFrame
                        part.Transparency = 1
                    end
                end
                wait(0.2)
            end
        end)
    else
        if rockAddedConnection then
            rockAddedConnection:Disconnect()
            rockAddedConnection = nil
        end
        for rock, orig in pairs(originalRocksPositions) do
            if rock and rock.Parent then
                if rock:IsA("Model") then
                    if rock.PrimaryPart then
                        rock:SetPrimaryPartCFrame(orig)
                    else
                        local part = rock:FindFirstChildWhichIsA("BasePart")
                        if part then part.CFrame = orig end
                    end
                    local transTable = originalRocksTransparencies[rock] or {}
                    for partObj, trans in pairs(transTable) do
                        if partObj and partObj.Parent then
                            partObj.Transparency = trans
                        end
                    end
                elseif rock:IsA("BasePart") then
                    rock.CFrame = orig
                    rock.Transparency = (originalRocksTransparencies[rock] and originalRocksTransparencies[rock][rock]) or 0
                end
            end
        end
        originalRocksPositions = {}
        originalRocksTransparencies = {}
    end
end)
local rollButtonActive = false
autofarm:Toggle("Roll Button", false, function(state)
    rollButtonActive = state
    if state then
        spawn(function()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local rollPart = Workspace:FindFirstChild("Roll") and Workspace.Roll:FindFirstChild("Button") and Workspace.Roll.Button:FindFirstChild("Button")
            if not rollPart then return end
            while rollButtonActive do
                hrp.CFrame = rollPart.CFrame
                wait(0.1)
            end
        end)
    end
end)

--------------------[Automate Upgrades]--------------------
local automateOriginals
autofarm:Toggle("Automate", false, function(state)
    local player = Players.LocalPlayer
    local upgrades = player.PlrData.Upgrades.Automation
    if state then
        automateOriginals = {
            ["Auto-Collect"] = upgrades["Auto-Collect"].Value,
            ["Auto-Roll"] = upgrades["Auto-Roll"].Value,
            AutoBuy_Cash = upgrades.AutoBuy_Cash.Value,
            Generator_Minerals = upgrades.Generator_Minerals.Value,
            Generator_Fragments = upgrades.Generator_Fragments.Value,
            AutoBuy_Fragments = upgrades.AutoBuy_Fragments.Value,
            AutoBuy_Minerals = upgrades.AutoBuy_Minerals.Value,
        }
        upgrades["Auto-Collect"].Value = 25
        upgrades["Auto-Roll"].Value = 15
        upgrades.AutoBuy_Cash.Value = 1
        upgrades.Generator_Minerals.Value = 50
        upgrades.Generator_Fragments.Value = 50
        upgrades.AutoBuy_Fragments.Value = 1
        upgrades.AutoBuy_Minerals.Value = 1
    else
        if automateOriginals then
            upgrades["Auto-Collect"].Value = automateOriginals["Auto-Collect"]
            upgrades["Auto-Roll"].Value = automateOriginals["Auto-Roll"]
            upgrades.AutoBuy_Cash.Value = automateOriginals.AutoBuy_Cash
            upgrades.Generator_Minerals.Value = automateOriginals.Generator_Minerals
            upgrades.Generator_Fragments.Value = automateOriginals.Generator_Fragments
            upgrades.AutoBuy_Fragments.Value = automateOriginals.AutoBuy_Fragments
            upgrades.AutoBuy_Minerals.Value = automateOriginals.AutoBuy_Minerals
        end
    end
end)
local antiAFKEnabled = false
local antiAFKConnection
misc:Toggle("Anti AFK", false, function(state)
    antiAFKEnabled = state
    if state then
        antiAFKConnection = Players.LocalPlayer.Idled:Connect(function()
            if antiAFKEnabled then
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0))
                wait(1)
                vu:Button2Up(Vector2.new(0,0))
            end
        end)
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end
end)

local removedBarrier, removedInvisWall
misc:Toggle("Remove Barrier", false, function(state)
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    if state then
        if map:FindFirstChild("Decoration") then
            local barrier = map.Decoration:FindFirstChild("Barrier")
            if barrier then
                removedBarrier = barrier:Clone()
                barrier:Destroy()
            end
        end
        if map:FindFirstChild("Layout") then
            local invisWalls = map.Layout:FindFirstChild("InvisWalls")
            if invisWalls then
                local invisWallPart = invisWalls:GetChildren()[4]
                if invisWallPart then
                    removedInvisWall = invisWallPart:Clone()
                    invisWallPart:Destroy()
                end
            end
        end
    else
        if removedBarrier and map:FindFirstChild("Decoration") then
            removedBarrier.Parent = map.Decoration
            removedBarrier = nil
        end
        if removedInvisWall and map:FindFirstChild("Layout") and map.Layout:FindFirstChild("InvisWalls") then
            removedInvisWall.Parent = map.Layout.InvisWalls
            removedInvisWall = nil
        end
    end
end)

local fpsBoostClones
misc:Toggle("FPS Boost", false, function(state)
    local decor = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("MostOfMap") and Workspace.Map.MostOfMap:FindFirstChild("Decorations")
    if state then
        fpsBoostClones = {}
        if decor then
            local toRemove = {"Rocks","Trees","Lantern_Pole","Fences"}
            for _, name in ipairs(toRemove) do
                local obj = decor:FindFirstChild(name)
                if obj then
                    fpsBoostClones[name] = obj:Clone()
                    obj:Destroy()
                end
            end
        end
    else
        if fpsBoostClones and decor then
            for name, clone in pairs(fpsBoostClones) do
                if not decor:FindFirstChild(name) then
                    clone.Parent = decor
                end
            end
            fpsBoostClones = nil
        end
    end
end)

local boardsOriginals
misc:Toggle("See All Boards", false, function(state)
    local unlocks = Players.LocalPlayer.PlrData.Unlocks
    local boardNames = {"The Reset","Sedimentation","Factory","Cash Upgrades V2","Automation V2","Automation"}
    if state then
        boardsOriginals = {}
        for _, board in ipairs(boardNames) do
            if unlocks[board] then
                boardsOriginals[board] = unlocks[board].Value
                if unlocks[board].Value == false then unlocks[board].Value = true end
            end
        end
    else
        if boardsOriginals then
            for _, board in ipairs(boardNames) do
                if unlocks[board] then unlocks[board].Value = boardsOriginals[board] end
            end
        end
    end
end)

Workspace.Map.Decoration.Grass:Destroy()

local gpOptions = {"Walkspeed","VIP","Speedy Rolls","Range","Field Overdrive","Lucky","Connoisseur","Cash"}
local selectedGPOptions = {}
local selectedGPNumbers = {}
local gpDropdown = gamepass:Dropdown("Pick Gamepasses", gpOptions, function(opt)
    if table.find(selectedGPOptions, opt) then
        for i,v in ipairs(selectedGPOptions) do
            if v == opt then table.remove(selectedGPOptions, i) break end
        end
    else
        table.insert(selectedGPOptions, opt)
    end
end)
local gpNumDropdown = gamepass:Dropdown("Pick Gamepass Numbers", gpOptions, function(opt)
    if table.find(selectedGPNumbers, opt) then
        for i,v in ipairs(selectedGPNumbers) do
            if v == opt then table.remove(selectedGPNumbers, i) break end
        end
    else
        table.insert(selectedGPNumbers, opt)
    end
end)
local originalGPBool = {}
gamepass:Toggle("Get Gamepass", false, function(state)
    local gp = Players.LocalPlayer.PlrData.Gamepasses
    if state then
        for _, opt in ipairs(selectedGPOptions) do
            if gp[opt] then
                originalGPBool[opt] = gp[opt].Value
                gp[opt].Value = true
            end
        end
    else
        for _, opt in ipairs(selectedGPOptions) do
            if gp[opt] then
                if originalGPBool[opt] ~= nil then
                    gp[opt].Value = originalGPBool[opt]
                else
                    gp[opt].Value = false
                end
            end
        end
    end
end)
textbs:Textbox("Set Gamepass Value", "Enter a number (max 500)", true, function(t)
    local num = tonumber(t)
    if num and num <= 500 then
        local gp = Players.LocalPlayer.PlrData.Gamepasses
        for _, opt in ipairs(selectedGPNumbers) do
            if gp[opt] then
                gp[opt].Value = num
            end
        end
    else
        local sg = Instance.new("ScreenGui")
        sg.Name = "GPValueNotif"
        sg.ResetOnSpawn = false
        sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(0,400,0,50)
        lab.Position = UDim2.new(0.5,-200,0,0)
        lab.BackgroundTransparency = 1
        lab.Text = "Woah, you cant do that!"
        lab.TextColor3 = Color3.new(1,0,0)
        lab.Font = Enum.Font.SourceSansBold
        lab.TextSize = 24
        lab.Parent = sg
        delay(5, function() if sg then sg:Destroy() end end)
    end
end)
