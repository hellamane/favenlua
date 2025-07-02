local DiscordLib =
    loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win    = DiscordLib:Window("arab hoops part 2??")
local serv   = win:Server("Secret UI", "")
local nerdd  = serv:Channel("Assistment")
local tgls   = nerdd


local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui          = game:GetService("StarterGui")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")


local aimbotEnabled   = false
local firstToggle     = true
local goaltendConn    = nil


local function sendBadge(title, text)
    StarterGui:SetCore("SendNotification", {
        Title    = title;
        Text     = text;
        Duration = 2;
    })
end


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


tgls:Toggle("Goaltend", false, function(state)
    if state then
        sendBadge("Arab Hoops", "Goaltend has been turned on")


        goaltendConn = RunService.RenderStepped:Connect(function()
            local court      = workspace.Courts and workspace.Courts["Basketball Court 1"]
            local rim        = court and court["Home Hoop"] and court["Home Hoop"].ActualRim
            local ball       = workspace:FindFirstChild("Ball")
            local player     = Players.LocalPlayer
            local char       = player.Character
            local hrp        = char and char:FindFirstChild("HumanoidRootPart")

            if rim and ball and hrp then
                local dBR = (ball.Position - rim.Position).Magnitude
                local dPB = (hrp.Position   - ball.Position).Magnitude

                if dBR <= 4 and dPB <= 6 then

                    hrp.CFrame = CFrame.new(-6, 12, 10)

                    VirtualInputManager:SendKeyEvent(true, "R", false, game)
                    wait(0.38)
                    VirtualInputManager:SendKeyEvent(false, "R", false, game)
              
                    repeat RunService.RenderStepped:Wait()
                    until (ball.Position - rim.Position).Magnitude > 4
                end
            end
        end)

    else
        -- stop the goaltend loop
        if goaltendConn then
            goaltendConn:Disconnect()
            goaltendConn = nil
        end
        sendBadge("Arab Hoops", "Goaltend has been turned off")
    end
end)


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
