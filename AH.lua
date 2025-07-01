--// Arab Hoops (Hoops Demo) | Discord #steppin0nsteppas

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

-- HITBOX EXPANDER
local HitboxExpander = { _origSizes = {} }
function HitboxExpander:Expand(part, scale)
    if not part then return end
    if not self._origSizes[part] then
        self._origSizes[part] = part.Size
    end
    part.Size       = part.Size * scale
    part.CanCollide = false
    part.Transparency = 1
end
function HitboxExpander:Reset(part)
    local orig = self._origSizes[part]
    if orig then
        part.Size       = orig
        part.CanCollide = true
        part.Transparency = 0
        self._origSizes[part] = nil
    end
end

-- ANIMATION SETUP
local function getBallControl()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("BallControl")
end
local bc = getBallControl()
local stealAnims       = {bc["Defense - Client"].Steal.Left, bc["Defense - Client"].Steal.Right}
local stealCooldown    = 1.3
local lastSteal        = 0
local blockShotAnimObj = Instance.new("Animation")
blockShotAnimObj.AnimationId = "rbxassetid://385554867"

-- UI LIB
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win   = DiscordLib:Window("Arabhoops")
local home  = win:Server("Home", "")
local lbls  = home:Channel("Hoops Discontinued")
lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Fuck Synapse X lol - Hviqz")

local king   = win:Server("King", "")
local assist = king:Channel("Assistment")

-- RIM POSITIONS
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
                if pl~=player and not exempt[pl.Name] and pl.Character and isCharInvisible(pl.Character) then
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

-- INFINITE STAMINA
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

function doReach()
    spawn(function()
        while getgenv().Reach do
            wait(0.1)
            local now = os.clock()
            if now - lastSteal < stealCooldown then continue end
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                for _, other in ipairs(Players:GetPlayers()) do
                    if other~=player
                    and other.Team~=player.Team
                    and other.Character
                    and other.Character:FindFirstChild("HumanoidRootPart")
                    and (other.Character:FindFirstChild("Ball") or other.Character:FindFirstChild("Basketball")) then
                        local dist = (other.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist <= 5 then
                            local anim = stealAnims[math.random(#stealAnims)]
                            local track = hum:LoadAnimation(anim)
                            track:Play()
                            lastSteal = now
                            break
                        end
                    end
                end
            end
        end
    end)
end


-- BLOCK SHOTS
function doBlockShots()
    local origSize = nil
    spawn(function()
        while getgenv().BlockShots do
            wait(0.1)
            local char = player.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then continue end
            for _, other in ipairs(Players:GetPlayers()) do
                if other~=player and other.Team~=player.Team and other.Character then
                    local ballPart = other.Character:FindFirstChild("Ball") or other.Character:FindFirstChild("Basketball")
                    if ballPart then
                        local dist = (other.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist <= 3 then
                            hum:LoadAnimation(blockShotAnimObj):Play()
                            if not origSize then origSize = hrp.Size end
                            HitboxExpander:Expand(hrp,3)
                            wait(0.15)
                            HitboxExpander:Reset(hrp)
                            origSize = nil
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
    local function hasBall(char)
        return char:FindFirstChild("Ball") or char:FindFirstChild("Basketball")
    end
    spawn(function()
        while getgenv().Goaltend do
            wait(0.04)
            local char = player.Character
            local ball = workspace:FindFirstChild("Basketball")
            if not (char and ball) then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            for _, rc in ipairs(rimCFrames) do
                local pDist = (hrp.Position - rc.Position).Magnitude
                local bDist = (ball.Position - rc.Position).Magnitude
                if pDist <= 4 and bDist <= 4 and not hasBall(char) then
                    hrp.CFrame = CFrame.new(rc.Position)
                    break
                end
            end
        end
    end)
end

-- PRELOAD GREEN SHOT ANIMATION
local greenShotAnim = Instance.new("Animation")
greenShotAnim.AnimationId = "rbxassetid://376938580"

-- UI TOGGLES & BUTTONS
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

assist:Toggle("Ball Reach", false, function(b)
    getgenv().Reach = b
    if b then doReach() end
end)
assist:Seperator()

assist:Toggle("Block Shots", false, function(b)
    getgenv().BlockShots = b
    if b then doBlockShots() end
end)
assist:Seperator()

assist:Toggle("Auto Inbound", false, function(b)
    getgenv().Inbound = b
    doInbound()
end)
assist:Seperator()

assist:Toggle("Goal Tend", false, function(b)
    getgenv().Goaltend = b
    if b then doGoaltend() end
end)
assist:Seperator()

-- Green Shot Button
local _gsConn
assist:Button("Green Shot", function()
    if _gsConn then
        _gsConn:Disconnect()
        _gsConn = nil
        StarterGui:SetCore("SendNotification", {Title="Green Shot"; Text="Disabled"; Duration=2})
    else
        StarterGui:SetCore("SendNotification", {Title="Green Shot"; Text="Press J for perfect shot"; Duration=2})
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

-- Power Dunk Button
assist:Button("Power Dunk", function()
    local Plr = Players.LocalPlayer
    if Plr.Character then
        for _, desc in ipairs(Plr.Character:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            end
        end
    end
end)
assist:Label("Reset to remove power dunk")
assist:Seperator()

-- CHANGE ANIMATIONS TAB
local change = win:Server("Change Animations","")
local an1mat0ins = change:Channel("Change Animations")
local animIDInput = ""
an1mat0ins:Textbox("Change Animation","Type Animation ID",true,function(t) animIDInput = t end)
local animationMap = {
    sidestep_right      = bc.Shooting.Stepback.sidestep_right,
    sidestep_left       = bc.Shooting.Stepback.sidestep_left,
    UnderhandLayup_Right= bc.Shooting.Animations.UnderhandLayup["Right Arm"],
    UnderhandLayup_Left = bc.Shooting.Animations.UnderhandLayup["Left Arm"],
    Layup_Right         = bc.Shooting.Animations.Layup["Right Arm"],
    Layup_Left          = bc.Shooting.Animations.Layup["Left Arm"],
    JumpShot_Left       = bc.Shooting.Animations.JumpShot["Left Arm"],
    JumpShot_Right      = bc.Shooting.Animations.JumpShot["Right Arm"],
    Dunk_Right          = bc.Shooting.Animations.Dunk["Right Arm"],
    Dunk_Left           = bc.Shooting.Animations.Dunk["Left Arm"],
    Overhead_Right      = bc["Passing - Client"].Overhead.Right,
    Overhead_Left       = bc["Passing - Client"].Overhead.Left,
    Chest_Right         = bc["Passing - Client"].Chest.Right,
    Chest_Left          = bc["Passing - Client"].Chest.Left,
    Dribble_Steal       = bc["Dribble - Client"].Right.Steal,
    TripleThreat_Right  = bc["Dribble - Client"].Right.TripleThreat,
    SwapHands_Right     = bc["Dribble - Client"].Right.SwapHands,
    Dribble_Right       = bc["Dribble - Client"].Right.Dribble,
    BTB_Right           = bc["Dribble - Client"].Right.BTB,
    TripleThreat_Left   = bc["Dribble - Client"].Left.TripleThreat,
    SwapHands_Left      = bc["Dribble - Client"].Left.SwapHands,
    Dribble_Left        = bc["Dribble - Client"].Left.Dribble,
    BTB_Left            = bc["Dribble - Client"].Left.BTB,
    DefenseBlock        = bc["Defense - Client"].Block,
    Steal_Right         = bc["Defense - Client"].Steal.Right,
    Steal_Left          = bc["Defense - Client"].Steal.Left,
}
an1mat0ins:Dropdown("Choose Which Animation You Want To Switch.",{"sidestep_right","sidestep_left","UnderhandLayup_Right","UnderhandLayup_Left","Layup_Right","Layup_Left","JumpShot_Left","JumpShot_Right","Dunk_Right","Dunk_Left","Overhead_Right","Overhead_Left","Chest_Right","Chest_Left","Dribble_Steal","TripleThreat_Right","SwapHands_Right","Dribble_Right","BTB_Right","TripleThreat_Left","SwapHands_Left","Dribble_Left","BTB_Left","DefenseBlock","Steal_Right","Steal_Left"},function(opt)
    local animObj = animationMap[opt]
    if animObj and animIDInput~="" then animObj.AnimationId = "rbxassetid://"..animIDInput end
end)
