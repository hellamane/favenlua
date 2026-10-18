-- // Arab Hoops (Hoops Demo)
-- FLAGS
getgenv().FlingInbounder = false
getgenv().Infstamina     = false
getgenv().Reach          = false
getgenv().BlockShots     = false
getgenv().Inbound        = false
getgenv().Goaltend       = false

-- SERVICES
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- BALLCONTROL & ANIMS
local function getBallControl()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("BallControl")
end
local bc             = getBallControl()
local stealAnims     = { bc["Defense - Client"].Steal.Left, bc["Defense - Client"].Steal.Right }
local stealCooldown  = 1.0
local lastSteal      = 0

local blockShotAnimObj = Instance.new("Animation")
blockShotAnimObj.AnimationId = "rbxassetid://385554867"

local DiscordLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"
))()
local win   = DiscordLib:Window("Arabhoops")
local home  = win:Server("Home", "")
local lbls  = home:Channel("Hoops Discontinued")
      lbls:Label("By dawid#7205 & steppin0nsteppas")
      lbls:Seperator()
      lbls:Label("Modified & Fixed")

local king   = win:Server("King", "")
local assist = king:Channel("Assistment")

local rimCFrames = {
    CFrame.new(-51.5, 11, 0),
    CFrame.new(51.5, 11, 0),
}

-- FLING INBOUNDER
local function doFlingInbounder()
    spawn(function()
        while getgenv().FlingInbounder do
            task.wait(0.1)
            pcall(function()
                local throwIn = workspace:FindFirstChild("ThrowIn")
                if throwIn then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = pl.Character.HumanoidRootPart
                            if (hrp.Position - throwIn.Position).Magnitude < 6 then
                                local bav = Instance.new("BodyAngularVelocity")
                                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                                bav.AngularVelocity = Vector3.new(0, 99999, 0)
                                bav.Parent = hrp
                                task.wait(0.15)
                                bav:Destroy()
                                
                                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    hum:LoadAnimation(stealAnims[1]):Play()
                                end
                                
                                local defenseClient = bc and bc:FindFirstChild("Defense - Client")
                                if defenseClient then
                                    for _, child in ipairs(defenseClient:GetChildren()) do
                                        if child:IsA("RemoteEvent") then
                                            child:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

function doInfstamina()
    spawn(function()
        while getgenv().Infstamina do
            task.wait(0.05)
            pcall(function()
                player.PlayerScripts.Events.Player.Stamina.Stamina.Value = 9001
            end)
        end
    end)
end

local originalArmData = {}
local reachConn

local function extendArms()
    local char = player.Character
    if not char then return end
    for _, partName in ipairs({
        "RightUpperArm","LeftUpperArm",
        "RightLowerArm","LeftLowerArm",
        "RightHand","LeftHand"
    }) do
        local arm = char:FindFirstChild(partName)
        if arm and not originalArmData[arm] then
            originalArmData[arm] = {
                Size = arm.Size,
                Massless = arm.Massless,
                CanCollide = arm.CanCollide
            }
            arm.Size = arm.Size * Vector3.new(2.5, 2.5, 2.5)
            arm.Massless = true
            arm.CanCollide = false
            arm.LocalTransparencyModifier = 1
        end
    end
end

local function resetArms()
    for arm, data in pairs(originalArmData) do
        if arm and arm.Parent then
            arm.Size = data.Size
            arm.Massless = data.Massless
            arm.CanCollide = data.CanCollide
            arm.LocalTransparencyModifier = 0
        end
    end
    originalArmData = {}
end

-- BLOCK SHOTS
function doBlockShots()
    spawn(function()
        while getgenv().BlockShots do
            task.wait(0.1)
            pcall(function()
                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not (hrp and hum) then return end

                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player and other.Team ~= player.Team and other.Character then
                        local oppHRP   = other.Character:FindFirstChild("HumanoidRootPart")
                        local ballPart = other.Character:FindFirstChild("Ball")
                                      or other.Character:FindFirstChild("Basketball")
                                      or other.Character:FindFirstChildOfClass("Tool")
                        if oppHRP and hrp then
                            local dist = (oppHRP.Position - hrp.Position).Magnitude
                            if dist <= 10 then
                                hum:LoadAnimation(blockShotAnimObj):Play()
                                
                                local defenseClient = bc and bc:FindFirstChild("Defense - Client")
                                if defenseClient then
                                    for _, child in ipairs(defenseClient:GetChildren()) do
                                        if child:IsA("RemoteEvent") then
                                            child:FireServer()
                                        end
                                    end
                                end
                                
                                local ballRemote = ReplicatedStorage:FindFirstChild("Ball")
                                if ballRemote then
                                    for _, child in ipairs(ballRemote:GetChildren()) do
                                        if child:IsA("RemoteEvent") then
                                            child:FireServer()
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- AUTO INBOUND
local stored = {}
function doInbound()
    spawn(function()
        while getgenv().Inbound do
            task.wait(0.05)
            local char     = player.Character
            local throwIn  = workspace:FindFirstChild("ThrowIn")
            local restrict = workspace:FindFirstChild("RestrictedCircle")
            if char and throwIn and restrict and not restrict.CanCollide then
                if not stored.CFrame then
                    stored.CFrame     = throwIn.CFrame
                    stored.CanCollide = throwIn.CanCollide
                end
                throwIn.CanCollide = false
                local occupied = false
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        if (pl.Character.HumanoidRootPart.Position - throwIn.Position).Magnitude < 0.7 then
                            occupied = true; break
                        end
                    end
                end
                if not occupied then
                    throwIn.CFrame = char.HumanoidRootPart.CFrame
                end
            end
        end
        local ti = workspace:FindFirstChild("ThrowIn")
        if ti and stored.CFrame then
            ti.CFrame     = stored.CFrame
            ti.CanCollide = stored.CanCollide
            stored = {}
        end
    end)
end

-- GOALTEND
function doGoaltend()
    local tweenSpeed = 0.1
    local tweenInfo  = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    local function hasBall(char)
        return char:FindFirstChild("Ball") or char:FindFirstChild("Basketball")
    end

    spawn(function()
        while getgenv().Goaltend do
            task.wait(0.04)
            local char = player.Character
            local ball = workspace:FindFirstChild("Basketball")
            if not (char and ball) then continue end
            if hasBall(char) then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, rimCF in ipairs(rimCFrames) do
                local pDist = (hrp.Position - rimCF.Position).Magnitude
                local bDist = (ball.Position - rimCF.Position).Magnitude
                if pDist <= 5 and bDist <= 7 then
                    TweenService:Create(hrp, tweenInfo, {CFrame = rimCF}):Play()
                    break
                end
            end
        end
    end)
end

local greenShotAnim = Instance.new("Animation")
greenShotAnim.AnimationId = "rbxassetid://376938580"

assist:Toggle("Fling Inbounder", false, function(b)
    getgenv().FlingInbounder = b
    if b then doFlingInbounder() end
end)
assist:Seperator()

assist:Toggle("Inf Stamina", false, function(b)
    getgenv().Infstamina = b
    if b then doInfstamina() end
end)
assist:Seperator()

assist:Toggle("Ball Reach", false, function(enabled)
    getgenv().Reach = enabled
    if enabled then
        extendArms()

        if reachConn then
            reachConn:Disconnect()
        end

        reachConn = RunService.RenderStepped:Connect(function()
            local now = os.clock()
            if now - lastSteal < stealCooldown then return end

            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end

            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player
                and other.Team ~= player.Team
                and other.Character then
                    local oppHRP   = other.Character:FindFirstChild("HumanoidRootPart")
                    local ballPart = other.Character:FindFirstChild("Ball")
                                  or other.Character:FindFirstChild("Basketball")
                    if oppHRP and ballPart then
                        local dist = (oppHRP.Position - hrp.Position).Magnitude
                        if dist <= 9 then
                            local dir      = (oppHRP.Position - hrp.Position).Unit
                            local rightDot = hrp.CFrame.RightVector:Dot(dir)
                            local animObj  = (rightDot > 0) and stealAnims[2] or stealAnims[1]
                            hum:LoadAnimation(animObj):Play()
                            lastSteal = now

                            local defenseClient = bc and bc:FindFirstChild("Defense - Client")
                            if defenseClient then
                                for _, child in ipairs(defenseClient:GetChildren()) do
                                    if child:IsA("RemoteEvent") then
                                        child:FireServer()
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end)
    else
        if reachConn then
            reachConn:Disconnect()
            reachConn = nil
        end
        resetArms()
    end
end)

assist:Seperator()

assist:Toggle("Block Shots", false, function(b)
    getgenv().BlockShots = b
    if b then doBlockShots() end
end)
assist:Seperator()

assist:Toggle("Auto Inbound", false, function(b)
    getgenv().Inbound = b
    if b then doInbound() end
end)
assist:Seperator()

assist:Toggle("Goal Tend", false, function(b)
    getgenv().Goaltend = b
    if b then doGoaltend() end
end)
assist:Seperator()

-- GREEN SHOT
local _gsConn
assist:Button("Green Shot", function()
    if _gsConn then
        _gsConn:Disconnect()
        _gsConn = nil
        StarterGui:SetCore("SendNotification", {
            Title="Green Shot"; Text="Disabled"; Duration=2
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title="Green Shot"; Text="Press J for perfect shot"; Duration=2
        })
        _gsConn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.J then
                local char = player.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:LoadAnimation(greenShotAnim):Play() end
                ReplicatedStorage.Ball.StartShooting:FireServer()
                task.wait(0.5)
                ReplicatedStorage.Ball.EndShooting:InvokeServer(true, "Perfect")
            end
        end)
    end
end)
assist:Seperator()

-- POWER DUNK
assist:Button("Power Dunk", function()
    local Plr = Players.LocalPlayer
    if Plr.Character then
        for _, desc in ipairs(Plr.Character:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CustomPhysicalProperties = PhysicalProperties.new(100,0.3,0.5)
            end
        end
    end
end)
assist:Label("Reset to remove power dunk")

assist:Seperator()

assist:Button("FPS Boost", function()
    local decalsyeeted = true
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    t.WaterWaveSize     = 0
    t.WaterWaveSpeed    = 0
    t.WaterReflectance  = 0
    t.WaterTransparency = 0
    l.GlobalShadows     = false
    l.FogEnd            = 9e9
    l.Brightness        = 0
    settings().Rendering.QualityLevel = "Level01"
    for _, v in ipairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") 
        or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material    = "Plastic"
            v.Reflectance = 0
        elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius   = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material    = "Plastic"
            v.Reflectance = 0
            v.TextureID   = 10385902758728957
        end
    end
    for _, e in ipairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
        or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect")
        or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end)

local change       = win:Server("Change Animations","")
local animChannel  = change:Channel("Change Animations")
local animIDInput  = ""

animChannel:Textbox(
    "Change Animation",
    "Type Animation ID (with or without rbxassetid://)",
    true,
    function(t) animIDInput = t:match("%S+") or "" end
)

local function getAnimationObj(opt)
    local currentBC = player.Character and player.Character:FindFirstChild("BallControl")
    if not currentBC then return nil end
    
    local map = {
        sidestep_right       = function() return currentBC.Shooting.Stepback.sidestep_right end,
        sidestep_left        = function() return currentBC.Shooting.Stepback.sidestep_left end,
        UnderhandLayup_Right = function() return currentBC.Shooting.Animations.UnderhandLayup["Right Arm"] end,
        UnderhandLayup_Left  = function() return currentBC.Shooting.Animations.UnderhandLayup["Left Arm"] end,
        Layup_Right          = function() return currentBC.Shooting.Animations.Layup["Right Arm"] end,
        Layup_Left           = function() return currentBC.Shooting.Animations.Layup["Left Arm"] end,
        JumpShot_Left        = function() return currentBC.Shooting.Animations.JumpShot["Left Arm"] end,
        JumpShot_Right       = function() return currentBC.Shooting.Animations.JumpShot["Right Arm"] end,
        Dunk_Right           = function() return currentBC.Shooting.Animations.Dunk["Right Arm"] end,
        Dunk_Left            = function() return currentBC.Shooting.Animations.Dunk["Left Arm"] end,
        Overhead_Right       = function() return currentBC["Passing - Client"].Overhead.Right end,
        Overhead_Left        = function() return currentBC["Passing - Client"].Overhead.Left end,
        Chest_Right          = function() return currentBC["Passing - Client"].Chest.Right end,
        Chest_Left           = function() return currentBC["Passing - Client"].Chest.Left end,
        Dribble_Steal        = function() return currentBC["Dribble - Client"].Right.Steal end,
        TripleThreat_Right   = function() return currentBC["Dribble - Client"].Right.TripleThreat end,
        SwapHands_Right      = function() return currentBC["Dribble - Client"].Right.SwapHands end,
        Dribble_Right        = function() return currentBC["Dribble - Client"].Dribble end,
        BTB_Right            = function() return currentBC["Dribble - Client"].Right.BTB end,
        TripleThreat_Left    = function() return currentBC["Dribble - Client"].Left.TripleThreat end,
        SwapHands_Left       = function() return currentBC["Dribble - Client"].Left.SwapHands end,
        Dribble_Left         = function() return currentBC["Dribble - Client"].Left.Dribble end,
        BTB_Left             = function() return currentBC["Dribble - Client"].Left.BTB end,
        DefenseBlock         = function() return currentBC["Defense - Client"].Block end,
        Steal_Right          = function() return currentBC["Defense - Client"].Steal.Right end,
        Steal_Left           = function() return currentBC["Defense - Client"].Steal.Left end,
    }
    
    local getter = map[opt]
    if getter then
        local success, result = pcall(getter)
        if success then return result end
    end
    return nil
end

animChannel:Dropdown(
    "Choose Which Animation You Want To Switch.",
    {
      "sidestep_right","sidestep_left","UnderhandLayup_Right","UnderhandLayup_Left",
      "Layup_Right","Layup_Left","JumpShot_Left","JumpShot_Right","Dunk_Right","Dunk_Left",
      "Overhead_Right","Overhead_Left","Chest_Right","Chest_Left","Dribble_Steal",
      "TripleThreat_Right","SwapHands_Right","Dribble_Right","BTB_Right",
      "TripleThreat_Left","SwapHands_Left","Dribble_Left","BTB_Left",
      "DefenseBlock","Steal_Right","Steal_Left"
    },
    function(opt)
        local animObj = getAnimationObj(opt)
        if not animObj then
            warn("Animation object not found!")
            return
        end
        if animIDInput == "" then
            warn("No ID typed!") 
            return
        end
        local num = animIDInput:match("(%d+)")
        if not num then
            warn("Invalid ID format") 
            return
        end
        animObj.AnimationId = "rbxassetid://" .. num
        StarterGui:SetCore("SendNotification", {
            Title    = "Animation Changed",
            Text     = opt .. " → " .. num,
            Duration = 2
        })
    end
)
