-- // Arab Hoops (Hoops Demo) | Discord #steppin0nsteppas

-- FLAGS
getgenv().InvDetect   = false
getgenv().Infstamina  = false
getgenv().Reach       = false
getgenv().BlockShots  = false
getgenv().Inbound     = false
getgenv().Goaltend    = false

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
local stealCooldown  = 1.3
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
      lbls:Label("Fuck Synapse X lol - Hviqz")

local king   = win:Server("King", "")
local assist = king:Channel("Assistment")


local rimCFrames = {
    CFrame.new(-51.5, 11, 0),
    CFrame.new(51.5, 11, 0),
}

-- INVISIBILITY DETECTOR
local exempt = { Hviqz=true, Mesuea=true, True9931=true, MrExors=true, BleechDrink=true }
local function isCharInvisible(char)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then
            return false
        end
    end
    return true
end
local function checkInvisibility()
    spawn(function()
        while getgenv().InvDetect do
            wait(0.1)
            local char = player.Character
            if char and not exempt[player.Name] and isCharInvisible(char) then
                player:Kick("You just got smoked by q3, nice invisible. :D")
                return
            end
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl~=player and not exempt[pl.Name]
                and pl.Character and isCharInvisible(pl.Character) then
                    wait(10)
                    if not workspace:FindFirstChild("Basketball") then
                        player:Kick("Server is broken, some unemployed dude did it.")
                        return
                    end
                end
            end
        end
    end)
end


function doInfstamina()
    spawn(function()
        while getgenv().Infstamina do
            wait(0.05)
            pcall(function()
                player.PlayerScripts.Events.Player.Stamina.Stamina.Value = 9001
            end)
        end
    end)
end

local originalArmSizes = {}
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
        if arm and not originalArmSizes[arm] then
            originalArmSizes[arm] = arm.Size
            arm.Size = arm.Size * Vector3.new(2.4, 2.4, 2.4)
            arm.LocalTransparencyModifier = 1
        end
    end
end

local function resetArms()
    for arm, size in pairs(originalArmSizes) do
        if arm and arm.Parent then
            arm.Size = size
            arm.LocalTransparencyModifier = 0
        end
    end
    originalArmSizes = {}
end

-- BLOCK SHOTS
function doBlockShots()
    spawn(function()
        while getgenv().BlockShots do
            wait(0.1)
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then continue end

            for _, other in ipairs(Players:GetPlayers()) do
                if other~=player and other.Team~=player.Team and other.Character then
                    local oppHRP   = other.Character:FindFirstChild("HumanoidRootPart")
                    local ballPart = other.Character:FindFirstChild("Ball")
                                  or other.Character:FindFirstChild("Basketball")
                    if ballPart and oppHRP then
                        local dist = (oppHRP.Position - hrp.Position).Magnitude
                        if dist <= 5 then
                            hum:LoadAnimation(blockShotAnimObj):Play()
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- AUTO INBOUND
local stored = {}
function doInbound()
    spawn(function()
        while getgenv().Inbound do
            wait(0.05)
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
                    if pl~=player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
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
            wait(0.04)
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


assist:Toggle("Invisible Detector", false, function(b)
    getgenv().InvDetect = b
    if b then checkInvisibility() end
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

        -- Disconnect previous if it exists
        if reachConn then
            reachConn:Disconnect()
        end

        -- Every frame, try to steal if cooldown passed
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
                        if dist <= 6 then
                            local dir      = (oppHRP.Position - hrp.Position).Unit
                            local rightDot = hrp.CFrame.RightVector:Dot(dir)
                            local animObj  = (rightDot > 0) and stealAnims[2] or stealAnims[1]
                            hum:LoadAnimation(animObj):Play()
                            lastSteal = now
                            break
                        end
                    end
                end
            end
        end)

    else
        -- clean up
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
                wait(0.5)
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
local animChannel = change:Channel("Change Animations")
local animIDInput = ""

animChannel:Textbox(
    "Change Animation",
    "Type Animation ID (with or without rbxassetid://)",
    true,
    function(t) animIDInput = t:match("%S+") or "" end
)

local animationMap = {
    sidestep_right       = bc.Shooting.Stepback.sidestep_right,
    sidestep_left        = bc.Shooting.Stepback.sidestep_left,
    UnderhandLayup_Right = bc.Shooting.Animations.UnderhandLayup["Right Arm"],
    UnderhandLayup_Left  = bc.Shooting.Animations.UnderhandLayup["Left Arm"],
    Layup_Right          = bc.Shooting.Animations.Layup["Right Arm"],
    Layup_Left           = bc.Shooting.Animations.Layup["Left Arm"],
    JumpShot_Left        = bc.Shooting.Animations.JumpShot["Left Arm"],
    JumpShot_Right       = bc.Shooting.Animations.JumpShot["Right Arm"],
    Dunk_Right           = bc.Shooting.Animations.Dunk["Right Arm"],
    Dunk_Left            = bc.Shooting.Animations.Dunk["Left Arm"],
    Overhead_Right       = bc["Passing - Client"].Overhead.Right,
    Overhead_Left        = bc["Passing - Client"].Overhead.Left,
    Chest_Right          = bc["Passing - Client"].Chest.Right,
    Chest_Left           = bc["Passing - Client"].Chest.Left,
    Dribble_Steal        = bc["Dribble - Client"].Right.Steal,
    TripleThreat_Right   = bc["Dribble - Client"].Right.TripleThreat,
    SwapHands_Right      = bc["Dribble - Client"].Right.SwapHands,
    Dribble_Right        = bc["Dribble - Client"].Right.Dribble,
    BTB_Right            = bc["Dribble - Client"].Right.BTB,
    TripleThreat_Left    = bc["Dribble - Client"].Left.TripleThreat,
    SwapHands_Left       = bc["Dribble - Client"].Left.SwapHands,
    Dribble_Left         = bc["Dribble - Client"].Left.Dribble,
    BTB_Left             = bc["Dribble - Client"].Left.BTB,
    DefenseBlock         = bc["Defense - Client"].Block,
    Steal_Right          = bc["Defense - Client"].Steal.Right,
    Steal_Left           = bc["Defense - Client"].Steal.Left,
}

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
        local animObj = animationMap[opt]
        if not animObj then return end
        if animIDInput == "" then
            warn("No ID typed!") return
        end
        local num = animIDInput:match("(%d+)")
        if not num then
            warn("Invalid ID format") return
        end
        animObj.AnimationId = "rbxassetid://" .. num
        StarterGui:SetCore("SendNotification", {
            Title    = "Animation Changed",
            Text     = opt .. " → " .. num,
            Duration = 2
        })
    end
)
