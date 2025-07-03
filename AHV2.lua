local DiscordLib =
    loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win    = DiscordLib:Window("arab hoops part 2??")
local serv   = win:Server("Secret UI", "")
local nerdd  = serv:Channel("Assistment")
local tgls   = nerdd   -- for toggles
local sldrs  = nerdd   -- for sliders

-- SERVICES
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui          = game:GetService("StarterGui")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")

-- STATE
local aimbotEnabled   = false
local firstToggle     = true
local goaltendConn    = nil
local walkSpeed       = 16
local reachOrigProps  = {}
local reachEnabled    = false

-- UTILITY: badge notification
local function sendBadge(title, text)
    StarterGui:SetCore("SendNotification", {
        Title    = title;
        Text     = text;
        Duration = 2;
    })
end

-- AIMBOT BUTTON
nerdd:Button("Aimbot", function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        if firstToggle then
            sendBadge("Arab Hoops", "Press J to shoot")
            firstToggle = false
        else
            sendBadge("Arab Hoops", "Aimbot has been turned on")
        end
    else
        sendBadge("Arab Hoops", "Aimbot has been turned off")
    end
end)

tgls:Toggle("Goaltend", false, function(enabled)
    if enabled then
        sendBadge("Arab Hoops", "Goaltend has been turned on")

        -- wait for court, hoop, rim, and ball to exist
        local courts = workspace:WaitForChild("Courts", 5)
        local court  = courts:WaitForChild("Basketball Court 1", 5)
        local hoop   = court:WaitForChild("Home Hoop", 5)
        local rim    = hoop:WaitForChild("ActualRim", 5)
        local ball   = workspace:WaitForChild("Ball", 5)
        local pl     = Players.LocalPlayer
        local debounce = false

        goaltendConn = RunService.RenderStepped:Connect(function()
            if debounce then return end
            local char = pl.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local dBR = (ball.Position - rim.Position).Magnitude
            local dPB = (hrp.Position - ball.Position).Magnitude

            if dBR <= 4 and dPB <= 6 then
                debounce = true

                -- teleport into position
                hrp.CFrame = CFrame.new(-6, 12, 10)

                -- shoot
                VirtualInputManager:SendKeyEvent(true, "R", false, game)
                wait(0.38)
                VirtualInputManager:SendKeyEvent(false, "R", false, game)

                -- wait until ball leaves rim area
                repeat
                    RunService.RenderStepped:Wait()
                    dBR = (ball.Position - rim.Position).Magnitude
                until dBR > 4

                debounce = false
            end
        end)

    else
        if goaltendConn then
            goaltendConn:Disconnect()
            goaltendConn = nil
        end
        sendBadge("Arab Hoops", "Goaltend has been turned off")
    end
end)



-- WALK-SPEED SLIDER
sldrs:Slider(
    "Loop Walkspeed",
    0,
    100,
    walkSpeed,
    function(t)
        walkSpeed = t
    end
)

-- enforce walkspeed
RunService.RenderStepped:Connect(function()
    local pl  = Players.LocalPlayer
    local char = pl.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end
end)

-- REACH TOGGLE
tgls:Toggle("Reach", false, function(state)
    reachEnabled = state
    local pl   = Players.LocalPlayer
    local char = pl.Character or pl.CharacterAdded:Wait()

    if state then
        sendBadge("Arab Hoops", "Reach has been turned on")
        -- expand every BasePart in the character
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                reachOrigProps[part] = {
                    Size        = part.Size,
                    Transparency= part.Transparency,
                    CanCollide  = part.CanCollide
                }
                part.Size         = part.Size * 2
                part.Transparency = 1
                part.CanCollide   = false
            end
        end
    else
        sendBadge("Arab Hoops", "Reach has been turned off")
        -- restore original properties
        for part, props in pairs(reachOrigProps) do
            if part and part.Parent then
                part.Size         = props.Size
                part.Transparency = props.Transparency
                part.CanCollide   = props.CanCollide
            end
        end
        reachOrigProps = {}
    end
end)

-- AIMBOT KEY-HOOK
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard
    and input.KeyCode == Enum.KeyCode.J
    and aimbotEnabled then

        VirtualInputManager:SendKeyEvent(true, "R", false, game)
        wait(0.38)
        VirtualInputManager:SendKeyEvent(false, "R", false, game)
    end
end)
