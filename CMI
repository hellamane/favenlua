--// Cube Market Incremental Get Gamepasses | Discsord steppin0nsteppas

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Arabhoops")
local serv = win:Server("Home", "")
local lbls = serv:Channel("Hoops Discontinued")

lbls:Label("By dawid#7205 & steppin0nsteppas")
lbls:Seperator()
lbls:Label("Fuck Synapse X lol - Hviqz")
lbls:Seperator()

local kingServ = win:Server("King", "")
local aimstix = kingServ:Channel("Assistment")

aimstix:Button("Get Gamepasses", function()
    local intValues = {
        game:GetService("Players").LocalPlayer.Data.Cubes.AutoCollectCubesAmount,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["Instant Cube Spawn"].TimeLeft,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["Instant Cube Spawn"].Capacity,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Glyph Bulk"].TimeLeft,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Glyph Bulk"].Capacity,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Cube"].TimeLeft,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Cube"].Capacity,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Artifacts Open"].TimeLeft,
        game:GetService("Players").LocalPlayer.Data.Monetization.Potions["2x Artifacts Open"].Capacity,
    }

    for _, value in ipairs(intValues) do
        value.Value = 1000
    end

    local boolValues = {
        game:GetService("Players").LocalPlayer.Data.Extra.VIPChatTag,
        game:GetService("Players").LocalPlayer.Data.Cubes.AutoCollectCubes,
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["+3 Artifacts Equip"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["2x Glyph Tokens"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["2x Ores Damage"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Artifacts Hunter"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Artifacts Storage"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Clicks Master"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Faster Artifacts"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Faster Glyphs"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass["Glyphs Hunter"],
        game:GetService("Players").LocalPlayer.Data.Monetization.Gamepass.VIP,
    }

    for _, value in ipairs(boolValues) do
        value.Value = true
    end

    game:GetService("Players").LocalPlayer.Data.Cubes.AutoCollectCubesSpeed.Value = 0.2
    game:GetService("Players").LocalPlayer.Data.Cubes.AutoCollectCubesAmount.Value = 500

    local extraIntValues = {
        game:GetService("Players").LocalPlayer.Data.RobuxSpent,
        game:GetService("Players").LocalPlayer.Data.Extra.RobuxSpent,
        game:GetService("Players").LocalPlayer.Data.Extra.DonationSpend,
    }

    for _, value in ipairs(extraIntValues) do
        value.Value = 3584123183892131300
    end
end)
