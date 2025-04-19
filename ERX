--// Eternal Rarities OP & Get Gamepasses | Discord #steppin0nsteppas

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Ferret Hub V2")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Info")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Welcome to Ferret Hub!")
lbls:Seperator()

local gotn = serv:Channel("Autofarm")


gotn:Button("Get Gamepasses & Alot of Upgrades", function()
    local gamepasses = {
        "Auto Roll", "AutoBarn", "AutoSpawn", "ELITE", "Inf Pots", "Luck", "Mega Gamepass",
        "Power", "QLuck", "Rebirth", "Reincarnation", "Rune Dupe", "RuneLuck", "RuneRolls",
        "RuneSpeed", "RuneToken", "Speed", "VIP"
    }
    for _, gamepass in pairs(gamepasses) do
        local value = game:GetService("Players").LocalPlayer.Gamepasses:FindFirstChild(gamepass)
        if value and value:IsA("BoolValue") then
            value.Value = true
        else
            warn("Gamepass not found or not a BoolValue:", gamepass)
        end
    end

    local potions = {"RuneSpeed", "RuneLuck", "RuneBulk", "Rebirth"}
    for _, potion in pairs(potions) do
        local value = game:GetService("Players").LocalPlayer.Potions:FindFirstChild(potion)
        if value and value:IsA("NumberValue") then
            value.Value = 5000
        else
            warn("Potion not found or not a NumberValue:", potion)
        end
    end

    local upgrades = {
        "AU1", "AU10", "AU11", "AU2", "AU3", "AU4", "AU5", "AU6", "AU7", "AU8", "AU9",
        "D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "D9", "E1", "E10", "E11", "E12",
        "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "ES1", "ES10", "ES11", "ES12",
        "ES13", "ES14", "ES15", "ES16", "ES17", "ES18", "ES19", "ES2", "ES20", "ES21",
        "ES22", "ES3", "ES4", "ES5", "ES6", "ES7", "ES8", "ES9", "F1", "F2", "F3",
        "FI1", "FI2", "FI3", "FI4", "FI5", "FI6", "FI7", "FR1", "FR2", "FR3", "FR4",
        "J1", "J10", "J11", "J12", "J2", "J3", "J4", "J5", "J6", "J7", "J8", "J9",
        "M1", "M10", "M11", "M12", "M13", "M14", "M15", "M16", "M17", "M18", "M19",
        "M2", "M20", "M21", "M22", "M23", "M3", "M4", "M5", "M6", "M7", "M8", "M9",
        "MT1", "MT2", "MT3", "P1", "P2", "P3", "R1", "R2", "R3", "RF1", "RF2", "RF3",
        "RF4", "RL1", "RL2", "RL3", "RN1", "RN2", "RN3", "RN4", "RN5", "RN6", "RS1",
        "RS10", "RS11", "RS12", "RS13", "RS14", "RS15", "RS16", "RS17", "RS2", "RS3",
        "RS4", "RS5", "RS6", "RS7", "RS8", "RS9", "RT1", "RT2", "RT3", "RT4", "RT5",
        "ST0", "ST1", "ST2", "ST3", "T1", "T2", "T3", "T4", "U1", "U2", "U3"
    }
    for _, upgrade in pairs(upgrades) do
        local value = game:GetService("Players").LocalPlayer.Upgrades:FindFirstChild(upgrade)
        if value and value:IsA("StringValue") then
            value.Value = "10000"
        else
            warn("Upgrade not found or not a StringValue:", upgrade)
        end
    end

    print("Gamepasses, Potions, and Upgrades updated successfully!")
end)
