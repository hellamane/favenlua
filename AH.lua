--// Arab Hoops (Hoops Demo) | Discord #steppin0nsteppas

-- FLAGS
getgenv().InvDetect   = false
getgenv().Infstamina  = false
getgenv().Reach       = false
getgenv().BlockShots  = false
getgenv().Inbound     = false
getgenv().Goaltend    = false

-- SERVICES
local Players              = game:GetService("Players")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local VirtualInputManager  = game:GetService("VirtualInputManager")
local TweenService         = game:GetService("TweenService")
local StarterGui           = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- UI LIB
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

-- RIM POSITIONS
local rimCFrames = {
    CFrame.new(-51.5, 10, 0),
    CFrame.new(51.5, 10, 0),
}

-- INVISIBILITY DETECTOR
local exempt = { Hviqz=true, Mesuea=true, MrExors=true, BleechDrink=true }
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

-- INFINITE STAMINA
function doInfstamina()
    spawn(function()
        while getgenv().Infstamina do
            wait(0.05)
            local success, err = pcall(function()
                player.PlayerScripts.Events.Player.Stamina.Stamina.Value = 9001
            end)
            if not success then
                warn("Error setting infinite stamina: "..err)
            end
        end
    end)
end

-- BALL REACH
function doReach()
    spawn(function()
        while getgenv().Reach do
            wait(0.1)
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, other in ipairs(Players:GetPlayers()) do
                    if other~=player and other.Team~=player.Team
                    and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (other.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist <= 5 then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                            wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
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
    spawn(function()
        while getgenv().BlockShots do
            wait(0.1)
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local ball = workspace:FindFirstChild("Basketball")
            if hrp and ball then
                local dist = (ball.Position - hrp.Position).Magnitude
                if dist <= 5 then
                    local vel = ball.AssemblyLinearVelocity or ball.Velocity
                    ball.AssemblyLinearVelocity = -vel
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
    spawn(function()
        while getgenv().Goaltend do
            wait(0.04)
            local char = player.Character
            local ball = workspace:FindFirstChild("Basketball")
            if char and ball then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, rc in ipairs(rimCFrames) do
                        local pDist = (hrp.Position - rc.Position).Magnitude
                        local bDist = (ball.Position - rc.Position).Magnitude
                        if pDist <= (8*0.3048) and bDist <= (7*0.3048) then
                            local targetPos = rc.Position + Vector3.new(0, 4, 0)
                            TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                                CFrame = CFrame.new(targetPos)
                            }):Play()
                            break
                        end
                    end
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

assist:Toggle("Jump & Block Shots", false, function(b)
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
                if hum then
                    local track = hum:LoadAnimation(greenShotAnim)
                    track:Play()
                end
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
