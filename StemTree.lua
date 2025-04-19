local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createDiscordUI()

    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    local TextBox = Instance.new("TextBox", Frame)
    local Notification = Instance.new("TextLabel", Frame)

    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
    Frame.Active = true
    Frame.Draggable = true

    TextBox.Size = UDim2.new(0, 280, 0, 50)
    TextBox.Position = UDim2.new(0.5, -140, 0.3, -25)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Enter Script Name..."
    TextBox.TextScaled = true

    Notification.Size = UDim2.new(1, 0, 0, 50)
    Notification.Position = UDim2.new(0, 0, 1, -50)
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.BackgroundTransparency = 1
    Notification.Text = ""

    local function playDiscordSound()
        local Sound = Instance.new("Sound", game.CoreGui)
        Sound.SoundId = "rbxassetid://5159723552" -- Discord notification sound
        Sound:Play()
        Sound.Ended:Connect(function()
            Sound:Destroy()
        end)
    end

    local function executeAfterTeleport(scriptUrl)
        game.Loaded:Wait() -- Wait for the game to load after teleport
        loadstring(game:HttpGet(scriptUrl))()
    end

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = TextBox.Text:lower()

            if input == "dls" or input == "dominus" or input == "dominus lifting simulator" then
                TextBox.Text = ""
                if game.PlaceId ~= 1254185591 then
                    TeleportService:Teleport(1254185591, LocalPlayer)
                    executeAfterTeleport("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/DLS.lua")
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/DLS.lua"))()
                end

            elseif input == "erx" or input == "eternal" or input == "eternal rarities x" then
                TextBox.Text = ""
                if game.PlaceId ~= 116128963769069 then
                    TeleportService:Teleport(116128963769069, LocalPlayer)
                    executeAfterTeleport("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/ERX.lua")
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/ERX.lua"))()
                end

            elseif input == "ah" or input == "arab hoops" or input == "arab" or input == "hoops" then
                TextBox.Text = ""
                if game.PlaceId ~= 360589910 then
                    TeleportService:Teleport(360589910, LocalPlayer)
                    executeAfterTeleport("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/AH.lua")
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/AH.lua"))()
                end
            elseif input == "yaf" or input == "yeet" or input == "yeet a friend" or input == "yeeter" then
          
                TextBox.Text = ""
                if game.PlaceId ~= 11708967881 then
                    TeleportService:Teleport(11708967881, LocalPlayer)
                    executeAfterTeleport("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/YAF.lua")
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/YAF.lua"))()
                end

            else
                Notification.Text = "That script doesn't exist. Did you mean 'DLS', 'ERX', 'AH', or 'YAF'?"
                playDiscordSound()
                wait(3)
                Notification.Text = ""
            end
        end
    end)
end

createDiscordUI()
