--// Arab Hoops (Hoops Demo) | Discord #steppin0nsteppas
getgenv().Inbound = false
getgenv().Follow = false
getgenv().Goaltend = false
getgenv().Infstamina = false
getgenv().Invisible = true
getgenv().Reach = false
getgenv().AntiFling = true
getgenv().BlockShots = false

local rimCFrames = {
    CFrame.new(-51.5, 10, 0),
    CFrame.new(51.5, 10, 0)
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Arabhoops")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Hoops Discontinued")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Fuck Synapse X lol - Hviqz")
lbls:Seperator()

local serv = win:Server("King", "")
local aimstix = serv:Channel("Assistment")

aimstix:Button("Green Shot", function()


local function simulateKeyPress(key, holdTime)
    VirtualInputManager:SendKeyEvent(true, key, false, game)

    wait(holdTime)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function shootBall()
    local ball = workspace:FindFirstChild("Basketball")
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if ball and humanoidRootPart then
        local closestRim = nil
        local minDistance = math.huge
        for _, rimCFrame in pairs(rimCFrames) do
            local distance = (humanoidRootPart.Position - rimCFrame.Position).magnitude
            if distance < minDistance then
                minDistance = distance
                closestRim = rimCFrame
            end
        end

        if closestRim then
            local direction = (closestRim.Position - ball.Position).unit
            ball.Velocity = direction * 100
        end
    end
end

local function onKeyPress(inputObject, gameProcessedEvent)
    if inputObject.KeyCode == Enum.KeyCode.G then
        simulateKeyPress(Enum.KeyCode.R, 0.52)
        shootBall()
    end
end

UserInputService.InputBegan:Connect(onKeyPress)
end)

aimstix:Label("Aimbot is FPS and physics based, press G to shoot.")
aimstix:Seperator()

aimstix:Button("Power Dunk", function()
    local strength = 100
    local Plr = Players.LocalPlayer
    if Plr.Character then
        local descs = Plr.Character:GetDescendants()
        for i = 1, #descs do
            local desc = descs[i]
            if desc:IsA("BasePart") then
                desc.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            end
        end
    end
end)

aimstix:Label("Reset to remove power dunk")
aimstix:Seperator()

aimstix:Toggle("Inf Stamina", false, function(bool)
    getgenv().Infstamina = bool
    print("Inf Stamina Is: ", bool)
    if bool then
        doInfstamina()
    end
end)

aimstix:Seperator()

aimstix:Toggle("Ball Reach", false, function(bool)
    getgenv().Reach = bool
    print("Reach Is: ", bool)
    if bool then 
        doReach()
    end
end)

aimstix:Seperator()

aimstix:Toggle("Jump & Block Shots", false, function(bool)
    getgenv().BlockShots = bool
    print("Block Shots Is: ", bool)
    if bool then 
        doBlockShots()
    end
end)

aimstix:Seperator()

aimstix:Toggle("Anti-Thaasia", false, function(bool)
    getgenv().Inbound = bool
    print("Auto Inbound Is: ", bool)
    if bool then
        doInbound()
    end
end)

aimstix:Seperator()

aimstix:Toggle("Goal Tend", false, function(bool)
    getgenv().Goaltend = bool
    print("Goal Tend Is: ", bool)
    if bool then 
        doGoaltend()
    end
end)

aimstix:Label("Jump towards the rim after someone shoots to gt")

aimstix:Seperator()

aimstix:Toggle("Follow", false, function(bool)
    getgenv().Follow = bool
    print("Follow Is: ", bool)
    if bool then 
        doFollow()
    end
end)

local ping = serv:Channel("Ping")
ping:Button("FPS Boost", function()
    local function optimizeSettings()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0

        local function removeParts(instance)
            if instance:IsA("BasePart") then
                instance.Material = Enum.Material.SmoothPlastic
                instance.Reflectance = 0
                instance.CastShadow = false
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                instance:Destroy()
            elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
                instance:Destroy()
            end
        end

        for _, instance in pairs(workspace:GetDescendants()) do
            removeParts(instance)
        end

        workspace.DescendantAdded:Connect(function(instance)
            removeParts(instance)
        end)
    end

    optimizeSettings()
end)

ping:Seperator()

ping:Button("Better Quality (rips)", function()
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true
        },
        Meshes = {
            Destroy = false,
            LowDetail = true
        },
        Images = {
            Invisible = true,
            LowDetail = false,
            Destroy = false,
        },
        ["No Particles"] = true,
        ["No Camera Effects"] = true,
        ["No Explosions"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true
    }
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
end)

function doInfstamina()
    spawn(function()
        while getgenv().Infstamina do
            wait(0.050)
            local success, errorMessage = pcall(function()
                game.Players.LocalPlayer.PlayerScripts.Events.Player.Stamina.Stamina.Value = 9001
            end)
            if not success then
                warn("Error setting infinite stamina: " .. errorMessage)
            end
        end
    end)
end

function doInbound()
    spawn(function()
        while getgenv().Inbound do
            wait(0.050)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local throwIn = workspace:FindFirstChild("ThrowIn")
            local restrictedCircle = workspace:FindFirstChild("RestrictedCircle")

            if throwIn and restrictedCircle and not restrictedCircle.CanCollide then
                local otherPlayerOnThrowIn = false

                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distanceToThrowIn = (otherPlayer.Character.HumanoidRootPart.Position - throwIn.Position).magnitude
                        if distanceToThrowIn <= 0.7 then -- Adjust the distance threshold as needed
                            otherPlayerOnThrowIn = true
                            break
                        end
                    end
                end

                if not otherPlayerOnThrowIn then
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        throwIn.CFrame = character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end)
end

function doFollow()
    spawn(function()
        while getgenv().Follow do
            wait(0.040)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local basketball = workspace:FindFirstChild("Basketball")

            if basketball and humanoidRootPart then
                local closestPlayer = nil
                local closestDistance = math.huge

                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer.Team ~= player.Team and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (otherPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude
                        if distance < closestDistance and basketball:IsDescendantOf(otherPlayer.Character) then
                            closestDistance = distance
                            closestPlayer = otherPlayer
                        end
                    end
                end

                if closestPlayer then
                    local targetPosition = closestPlayer.Character.HumanoidRootPart.Position + closestPlayer.Character.HumanoidRootPart.CFrame.LookVector * -0.3048 -- 1 foot in front of them
                    local direction = (targetPosition - humanoidRootPart.Position).unit

                    -- Determine the key to press based on the direction
                    if direction.Z > 0 then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    elseif direction.Z < 0 then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
                    else
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
                    end

                    if direction.X > 0 then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    elseif direction.X < 0 then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    else
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    end
                else
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                end
            end
        end
    end)
end

function doGoaltend()
    spawn(function()
        while getgenv().Goaltend do
            wait(0.040)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local basketball = workspace:FindFirstChild("Basketball")
            local playerNearRimDistance = 5 * 0.3048 -- 5 feet in studs
            local basketballNearRimDistance = 5 * 0.3048 -- 5 feet in studs

            if basketball and humanoidRootPart then
                for _, rimCFrame in pairs(rimCFrames) do
                    local distanceToRim = (humanoidRootPart.Position - rimCFrame.Position).magnitude
                    local distanceToBall = (basketball.Position - rimCFrame.Position).magnitude

                    if distanceToRim <= playerNearRimDistance and distanceToBall <= basketballNearRimDistance then
                        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                        local tweenGoal = { CFrame = rimCFrame }
                        local tween = TweenService:Create(humanoidRootPart, tweenInfo, tweenGoal)
                        tween:Play()
                        tween.Completed:Wait()
                        break
                    end
                end
            end
        end
    end)
end

function checkInvisibility()
    local player = Players.LocalPlayer
    local exemptUsers = { "Hviqz", "Mesuea", "MrExors", "BleechDrink" }
    
    local function isExempt(userName)
        for _, exemptName in pairs(exemptUsers) do
            if userName == exemptName then
                return true
            end
        end
        return false
    end

    local function kickPlayer(message)
        player:Kick(message)
    end

    local function isCharacterInvisible(character)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                return false
            end
        end
        return true
    end

    spawn(function()
        while getgenv().Invisible do
            wait(0.1)
            local basketball = workspace:FindFirstChild("Basketball")
            local throwIn = workspace:FindFirstChild("ThrowIn")

            if throwIn then
                if not isExempt(player.Name) and player.Character and isCharacterInvisible(player.Character) then
                    kickPlayer("You just got smoked by q3, nice invisible. :D")
                else
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and not isExempt(otherPlayer.Name) and otherPlayer.Character and isCharacterInvisible(otherPlayer.Character) then
                            wait(10)
                            basketball = workspace:FindFirstChild("Basketball")
                            if not basketball then
                                kickPlayer("Server is broken, some unemployed dude did it.")
                            end
                        end
                    end
                end
            end
        end
    end)
end

function doReach()
    spawn(function()
        while getgenv().Reach do
            wait(0.040)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local basketball = workspace:FindFirstChild("Basketball")
            local normalReachDistance = 3 * 0.3048 -- 3 feet in studs
            local opponentReachDistance = 4 * 0.3048 -- 4 feet in studs

            if basketball and humanoidRootPart then
                local ballDistance = (basketball.Position - humanoidRootPart.Position).magnitude

                if ballDistance <= normalReachDistance then
                    -- Simulate key press to steal the ball
                    local stealKey = Enum.KeyCode.Q

                    local function simulateKeyPress(key)
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                    end

                    simulateKeyPress(stealKey)
                else
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer.Team ~= player.Team and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (otherPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude

                            if distance <= opponentReachDistance and basketball:IsDescendantOf(otherPlayer.Character) then
                                -- Simulate key press to steal the ball
                                local stealKey = Enum.KeyCode.Q

                                local function simulateKeyPress(key)
                                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                                    wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                                end

                                simulateKeyPress(stealKey)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function doAntiFling()
    spawn(function()
        while getgenv().AntiFling do
            wait(0.040)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                -- Check for excessive velocity which indicates a fling
                local velocity = humanoidRootPart.Velocity
                if math.abs(velocity.X) > 50 or math.abs(velocity.Y) > 50 or math.abs(velocity.Z) > 50 then
                    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                end

                -- Make sure the HumanoidRootPart stays anchored
                humanoidRootPart.Anchored = false
            end
        end
    end)
end

function doBlockShots()
    spawn(function()
        while getgenv().BlockShots do
            wait(0.040)
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local basketball = workspace:FindFirstChild("Basketball")

            if basketball and humanoid and humanoidRootPart then
                local closestPlayer = nil
                local closestDistance = 6 * 0.3048
                
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer.Team ~= player.Team and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
                        if distance <= closestDistance and basketball:IsDescendantOf(otherPlayer.Character) then
                            closestDistance = distance
                            closestPlayer = otherPlayer
                        end
                    end
                end
                
                if closestPlayer then
                    -- Check if the opponent starts shooting
                    local function detectShot()
                        local shooting = closestPlayer.Character:FindFirstChild("Shooting") -- Replace this with the actual way to detect shooting
                        if shooting then
                            local directionToBall = (basketball.Position - humanoidRootPart.Position).unit
                            local targetPosition = basketball.Position + directionToBall * -0.3048 -- 1 foot in front of the basketball
                            humanoidRootPart.CFrame = CFrame.new(targetPosition)
                            
                            -- Simulate the jump key press (spacebar)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end
                    end

                    detectShot()
                end
            end
        end
    end)
end

function showNotification()
    StarterGui:SetCore("SendNotification", {
        Title = "Message to You";
        Text = "What's up dawg, don't try to break serv kuz I coded in a anti break script :P. (This message is shown to you personally)";
        Duration = 10;
    })
end

function checkPlayer(player)
    if player.Name == "lorez" or player.Name == "thaasia" then
        showNotification()
    end
end

Players.PlayerAdded:Connect(checkPlayer)

for _, player in pairs(Players:GetPlayers()) do
    checkPlayer(player)
	end



doInfstamina()
doInbound()
doFollow()
doGoaltend()
checkInvisibility()
doReach()
doAntiFling()
doBlockShots()
