--// Ore Mining Incremental | Discord steppin0nsteppas

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Info")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Welcome to Ferret Hub!")
lbls:Seperator()

local woogy = serv:Channel("Autofarm")

woogy:Button("Get Stupidly OP", function()
    local player = game:GetService("Players").LocalPlayer

    local function setValue(object, propertyName, newValue)
        if object and object:FindFirstChild(propertyName) and (object[propertyName]:IsA("IntValue") or object[propertyName]:IsA("NumberValue")) then
            object[propertyName].Value = newValue
            print("Set " .. propertyName .. " to " .. newValue)
        else
            warn("Failed to set " .. propertyName .. ".  Object or property not found, or not a NumberValue/IntValue. Object: " .. tostring(object) .. " Property: " .. propertyName)
        end
    end

    if player:FindFirstChild("leaderstats") and player.leaderstats:IsA("Folder") then
        setValue(player.leaderstats, "Value", 9.2125e+87)
    else
        warn("leaderstats not found")
    end

    setValue(player, "WinLevel", 100000)

    setValue(player, "True Reset", 500)

    setValue(player, "Multiplier", 2302)

    if player:FindFirstChild("Infinity") and (player.Infinity:IsA("IntValue") or player.Infinity:IsA("NumberValue")) then
        player.Infinity.Value = 213000
        print("Set Infinity to 213000")
    else
        warn("Infinity not found or incorrect type")
    end

    local child8 = player:GetChildren()[8]
    if child8 and (child8:IsA("IntValue") or child8:IsA("NumberValue")) then
        child8.Value = 213000
        print("Set 8th child (" .. child8.Name .. ") to 213000")
    else
        warn("8th child not found or incorrect type")
    end
end)
