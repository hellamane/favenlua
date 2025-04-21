--// Ore Mining Incremental | Discord steppin0nsteppas

local Players = game:GetService("Players")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local info = serv:Channel("Info")

info:Label("By dawid#7205 & steppin0nsteppas")
info:Seperator()
info:Label("Welcome to Ferret Hub!")
info:Seperator()

local getgood = serv:Channel("OP Features")

getgood:Textbox("WinLevel", "Enter Number", true, function(t)
    local num = tonumber(t)
    if num then
        local p = Players.LocalPlayer
        local winLevel = p:FindFirstChild("WinLevel")
        if winLevel and winLevel:IsA("NumberValue") then
            winLevel.Value = num
        else
            winLevel = Instance.new("NumberValue")
            winLevel.Name = "WinLevel"
            winLevel.Value = num
            winLevel.Parent = p
        end
    end
end)

getgood:Textbox("True Reset", "Enter Number", true, function(t)
    local num = tonumber(t)
    if num then
        local p = Players.LocalPlayer
        local trueReset = p:FindFirstChild("True Reset")
        if trueReset and trueReset:IsA("NumberValue") then
            trueReset.Value = num
        else
            trueReset = Instance.new("NumberValue")
            trueReset.Name = "True Reset"
            trueReset.Value = num
            trueReset.Parent = p
        end
    end
end)

getgood:Textbox("Multiplier", "Enter Number", true, function(t)
    local num = tonumber(t)
    if num then
        local p = Players.LocalPlayer
        local multiplier = p:FindFirstChild("Multiplier")
        if multiplier and multiplier:IsA("NumberValue") then
            multiplier.Value = num
        else
            multiplier = Instance.new("NumberValue")
            multiplier.Name = "Multiplier"
            multiplier.Value = num
            multiplier.Parent = p
        end
    end
end)

getgood:Textbox("Infinity", "Enter Number", true, function(t)
    local num = tonumber(t)
    if num then
        local p = Players.LocalPlayer
        local infinity = p:FindFirstChild("Infinity")
        if infinity and infinity:IsA("NumberValue") then
            infinity.Value = num
        else
            infinity = Instance.new("NumberValue")
            infinity.Name = "Infinity"
            infinity.Value = num
            infinity.Parent = p
        end
    end
end)
