local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Custom Duels", "")
local channel = serv:Channel("Extender")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local HitboxEnabled = false
local BringPumpkinsEnabled = false
local Connections = {}
local OriginalSizes = {}
local OriginalPumpkinCFrames = {}
local CachedPumpkins = {}
local DescendantAddedConn = nil

local HitboxSizeX = 6
local HitboxSizeY = 6
local HitboxSizeZ = 6

local function enlargeHitboxes(char)
    if not HitboxEnabled then return end

    local parts = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        "HumanoidRootPart"
    }

    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not OriginalSizes[part] then
                OriginalSizes[part] = part.Size
            end

            part.Size = Vector3.new(HitboxSizeX, HitboxSizeY, HitboxSizeZ)
            part.Transparency = 0.85
            part.CanCollide = false
            part.Massless = true
        end
    end
end

local function restoreHitboxes(char)
    for part, size in pairs(OriginalSizes) do
        if part and part.Parent then
            part.Size = size
            part.Transparency = (part.Name == "HumanoidRootPart" and 1 or 0)
        end
    end
    OriginalSizes = {}
end

local function setupPlayer(plr)
    if plr == LocalPlayer then return end

    if plr.Character then
        enlargeHitboxes(plr.Character)
    end

    Connections[plr] = plr.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        enlargeHitboxes(char)
    end)
end

local function enableHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        setupPlayer(plr)
    end

    Connections["_PlayerAdded"] = Players.PlayerAdded:Connect(setupPlayer)
end

local function disableHitbox()
    HitboxEnabled = false

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            restoreHitboxes(plr.Character)
        end
    end

    for _, conn in pairs(Connections) do
        if conn.Disconnect then conn:Disconnect() end
    end

    Connections = {}
end

channel:Toggle("Hitbox Extender", false, function(state)
    HitboxEnabled = state
    if state then
        enableHitbox()
    else
        disableHitbox()
    end
end)

channel:Slider("Hitbox Length", 4, 30, 6, function(v)
    HitboxSizeX = v
    if HitboxEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                enlargeHitboxes(plr.Character)
            end
        end
    end
end)

channel:Slider("Hitbox Height", 4, 30, 6, function(v)
    HitboxSizeY = v
    if HitboxEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                enlargeHitboxes(plr.Character)
            end
        end
    end
end)

channel:Slider("Hitbox Width", 4, 30, 6, function(v)
    HitboxSizeZ = v
    if HitboxEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                enlargeHitboxes(plr.Character)
            end
        end
    end
end)

local function registerPumpkin(obj)
    local targetPart = nil
    if obj:IsA("BasePart") and obj.Name:lower():find("pumpkin") then
        targetPart = obj
    elseif obj:IsA("Model") and obj.Name:lower():find("pumpkin") then
        targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    
    if targetPart then
        CachedPumpkins[targetPart] = true
    end
end

channel:Toggle("Bring Pumpkins", false, function(state)
    BringPumpkinsEnabled = state
    
    if state then
        table.clear(CachedPumpkins)
        for _, desc in ipairs(workspace:GetDescendants()) do
            if (desc:IsA("Folder") or desc:IsA("Model")) and desc.Name:lower():find("pumpkin") then
                for _, child in ipairs(desc:GetChildren()) do
                    registerPumpkin(child)
                end
            elseif desc:IsA("BasePart") and desc.Name:lower():find("pumpkin") then
                registerPumpkin(desc)
            end
        end

        DescendantAddedConn = workspace.DescendantAdded:Connect(function(desc)
            registerPumpkin(desc)
        end)
    else
        if DescendantAddedConn then
            DescendantAddedConn:Disconnect()
            DescendantAddedConn = nil
        end

        for part, origCFrame in pairs(OriginalPumpkinCFrames) do
            if part and part.Parent then
                local wasAnchored = part.Anchored
                part.Anchored = false
                part.CFrame = origCFrame
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                part.Anchored = wasAnchored
            end
        end
        OriginalPumpkinCFrames = {}
        table.clear(CachedPumpkins)
    end
end)

RunService.RenderStepped:Connect(function()
    if not BringPumpkinsEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for part, _ in pairs(CachedPumpkins) do
        if part and part.Parent then
            if not part.CanCollide then
                if not OriginalPumpkinCFrames[part] then
                    OriginalPumpkinCFrames[part] = part.CFrame
                end

                local wasAnchored = part.Anchored
                part.Anchored = false
                part.CFrame = rootPart.CFrame
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                part.Anchored = wasAnchored
            end
        else
            CachedPumpkins[part] = nil
        end
    end
end)
