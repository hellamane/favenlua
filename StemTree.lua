local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function executeScript(scriptUrl)
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not success then
        warn("Error executing script: " .. tostring(err))
    end
end

if game.PlaceId == 1254185591 then
    executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/DLS.lua")
elseif game.PlaceId == 116128963769069 then
    executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/ERX.lua")
elseif game.PlaceId == 83898177072058 then
    executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/ORE.lua")
elseif game.PlaceId == 360589910 then
    executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/AH.lua")
elseif game.PlaceId == 98848203219584 then
	executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/CMI.lua")
elseif game.PlaceId == 11708967881 then
    executeScript("https://raw.githubusercontent.com/hellamane/favenlua/refs/heads/main/YAF.lua")
else
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    local TextBox = Instance.new("TextBox", Frame)
    local Notification = Instance.new("TextLabel", Frame)
    local UICornerFrame = Instance.new("UICorner")
    local UICornerTextBox = Instance.new("UICorner")
    local JoinNotification = Instance.new("TextLabel", ScreenGui)

    Frame.Size = UDim2.new(0, 500, 0, 200)
    Frame.Position = UDim2.new(0.5, -250, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
    Frame.Active = true
    Frame.Draggable = true
    UICornerFrame.CornerRadius = UDim.new(0, 10)
    UICornerFrame.Parent = Frame

    TextBox.Size = UDim2.new(0, 300, 0, 50)
    TextBox.Position = UDim2.new(0.5, -150, 0.5, -25)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Enter Script Name..."
    TextBox.TextScaled = true
    UICornerTextBox.CornerRadius = UDim.new(0, 10)
    UICornerTextBox.Parent = TextBox

    Notification.Size = UDim2.new(1, 0, 0, 50)
    Notification.Position = UDim2.new(0, 0, 1, -50)
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.BackgroundTransparency = 1
    Notification.Text = ""

    JoinNotification.Size = UDim2.new(0, 400, 0, 50)
    JoinNotification.Position = UDim2.new(0.5, -200, 0.8, 0)
    JoinNotification.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
    JoinNotification.TextColor3 = Color3.fromRGB(255, 255, 255)
    JoinNotification.TextScaled = true
    JoinNotification.Visible = false
    JoinNotification.Text = "Universal teleport failed. Please manually join the game."
    JoinNotification.Parent = ScreenGui

    local function playDiscordSound()
        local Sound = Instance.new("Sound", game.CoreGui)
        Sound.SoundId = "rbxassetid://5159723552"
        Sound:Play()
        Sound.Ended:Connect(function()
            Sound:Destroy()
        end)
    end

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = TextBox.Text:lower()

            if input == "dls" or input == "dominus" or input == "dominus lifting simulator" then
                ScreenGui:Destroy()
                TeleportService:Teleport(1254185591, LocalPlayer)
            elseif input == "erx" or input == "eternal" or input == "eternal rarities x" then
                ScreenGui:Destroy()
                TeleportService:Teleport(116128963769069, LocalPlayer)
            elseif input == "ore" or input == "ore mining" or input == "ore mining incremental" or input == "ore incremental" then
                ScreenGui:Destroy()
                TeleportService:Teleport(83898177072058, LocalPlayer)
            elseif input == "ah" or input == "arab hoops" or input == "arab" or input == "hoops" then
                ScreenGui:Destroy()
                TeleportService:Teleport(360589910, LocalPlayer)
			elseif input == "cube" or input == "cube market" or input == "cube market incremental" then
                ScreenGui:Destroy()
                TeleportService:Teleport(98848203219584, LocalPlayer)
            elseif input == "yaf" or input == "yeet" or input == "yeet a friend" or input == "yeeter" then
                ScreenGui:Destroy()
                TeleportService:Teleport(11708967881, LocalPlayer)
            else
                Notification.Text = "That script doesn't exist. Did you mean 'DLS', 'ERX', 'AH', 'ORE', 'CMI' or 'YAF'?"
                playDiscordSound()
                wait(3)
                Notification.Text = ""
            end
        end
    end)
end
