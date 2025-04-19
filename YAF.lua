--// Collect Stars "Yeet A Friend" | Discord #steppin0nsteppas

getgenv().Star = false
local VIP_BADGE_ID = 113712192
local VIP_STAR_COLOR = Color3.fromRGB(165, 85, 19)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BadgeService = game:GetService("BadgeService")


local localPlayer = Players.LocalPlayer
if not localPlayer then
    warn("Player not found.")
    return
end

local starsFolder = Workspace:FindFirstChild("Stars")
if not starsFolder then
    warn("Folder 'Stars' not found in Workspace.")
    return
end

local starCollection = starsFolder:GetChildren()
local starCount = #starCollection

if starCount == 0 then
    warn("No stars found in the 'Stars' folder.")
    return
end

local character = nil
local humanoidRootPart = nil
local targetIndex = 1
local boundFunc = nil
local starOriginalPositions = {}
local collectedStars = {}
local isToggled = false

local function hasVIP()
    local success, result = pcall(BadgeService.UserHasBadge, BadgeService, localPlayer.UserId, VIP_BADGE_ID)
    if success then
        return result
    else
        warn("Error checking for VIP badge: " .. result)
        return false
    end
end


local function moveStar(starModel, isUp)
    if not starModel:IsA("Model") then
        warn("Skipping non-Model: " .. tostring(starModel))
        return
    end

    local rootPart = starModel:FindFirstChild("Root")
    if not rootPart or not rootPart:IsA("BasePart") then
        warn("Root part not found or is not a BasePart in model: " .. tostring(starModel))
        return
    end

    if rootPart.Color == VIP_STAR_COLOR then
        return
    end

    if not character or not humanoidRootPart then
        warn("Character or HumanoidRootPart not found.  Ensure player character is loaded.")
        return
    end

    local yOffset = 2
    local targetPosition = humanoidRootPart.Position + Vector3.new(0, (isUp and yOffset or -yOffset), 0)

    local tweenInfo = TweenInfo.new(
        0.5, -- Speed of the up/down movement
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        0,
        false
    )

    local tween = TweenService:Create(rootPart, tweenInfo, { Position = targetPosition })
    if not tween then
        warn("Failed to create tween for star: " .. tostring(starModel))
        return
    end
    tween:Play()
end

local function movePlayerToStar(starModel)
    if not starModel:IsA("Model") then
        warn("Skipping non-Model: " .. tostring(starModel))
        return
    end

    local rootPart = starModel:FindFirstChild("Root")
    if not rootPart or not rootPart:IsA("BasePart") then
        warn("Root part not found or is not a BasePart in model: " .. tostring(starModel))
        return
    end

    if rootPart.Color == VIP_STAR_COLOR and not hasVIP() then
        return
    end

    if not character or not humanoidRootPart then
        warn("Character or HumanoidRootPart not found.  Ensure player character is loaded.")
        return
    end

    local targetPosition = rootPart.Position

    local tweenInfo = TweenInfo.new(
        0.2, -- Speed of the movement - set to 0.2 seconds
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        0,
        false
    )

    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { Position = targetPosition })
    if not tween then
        warn("Failed to create tween for player to star: " .. tostring(starModel))
        return
    end

    tween:Play()

    tween.Completed:Connect(function()
        -- After the player reaches the star, check for collection and move to the next.
        checkStarCollision(rootPart)
        targetIndex = targetIndex + 1
        if targetIndex <= starCount and getgenv().Star then
            movePlayerToStar(starCollection[targetIndex])
        elseif not getgenv().Star then
            targetIndex = 1;
        end
    end)
end


local function onRenderStep()
    if getgenv().Star then
        if targetIndex <= starCount then
             movePlayerToStar(starCollection[targetIndex])
        end
    else
        for _, starModel in ipairs(starCollection) do
            local rootPart = starModel:FindFirstChild("Root")
            if rootPart and rootPart:IsA("BasePart") then  -- Check if rootPart is valid
                local originalPosition = starOriginalPositions[starModel]
                if originalPosition then
                    local tweenInfo = TweenInfo.new(
                        0.5, -- Speed of the return movement
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut,
                        0,
                        false
                    )
                    local tween = TweenService:Create(rootPart, tweenInfo, {Position = originalPosition})
                    tween:Play()
                else
                    warn("original position not found for "..tostring(starModel))
                end
            end
        end
    end
end



function toggleTeleport(enabled)
    getgenv().Star = enabled
    isToggled = enabled
    if enabled then
        character = localPlayer.Character
        if character then
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            if not humanoidRootPart then
                warn("HumanoidRootPart not found in character.")
                return
            end
        else
            warn("Character not found")
            return
        end
        if not boundFunc then
            boundFunc = RunService.RenderStepped:Connect(onRenderStep)
        end
        print("Player teleportation to stars enabled. Starting animation.")

        for _, starModel in ipairs(Workspace:GetChildren()) do
             if starsFolder:IsAncestorOf(starModel) then
                local rootPart = starModel:FindFirstChild("Root")
                if rootPart and rootPart:IsA("BasePart") then
                    starOriginalPositions[starModel] = rootPart.Position
                end
            end
        end
        collectedStars = {}
        targetIndex = 1
        if targetIndex <= starCount then
            movePlayerToStar(starCollection[targetIndex])
        end
    else
        print("Player teleportation to stars disabled.  Returning stars to original positions.")
        if boundFunc then
            RunService:UnbindFromRenderStep(boundFunc)
            boundFunc = nil
        end
    end
end

local function onCharacterAdded(char)
    print("CharacterAdded event fired.")
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart not found in character.")
        return
    end
    print("Calling toggleTeleport from CharacterAdded")
    if getgenv().Star then
        toggleTeleport(true)
    end
end



local function checkStarCollision(hit)
    if not hit:IsA("BasePart") then return end
    local starModel = hit:FindFirstAncestor("Model")
    if starModel and starsFolder:IsAncestorOf(starModel) then
        local rootPart = starModel:FindFirstChild("Root")
        if rootPart and rootPart:IsA("BasePart") then
            if rootPart.Color ~= VIP_STAR_COLOR then  -- Check for color here
                if not collectedStars[starModel] then
                    if hasVIP() then
                        print("Collected Star: ", starModel.Name)
                        collectedStars[starModel] = true
                        starModel:Destroy()
                    else
                        print("No VIP, cannot collect Star: ", starModel.Name)
                    end
                end
            end
        end
    end
end

localPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Touched:Connect(checkStarCollision)
    end
    onCharacterAdded(char)
end)

if localPlayer.Character then
    print("Player already has a character.  Setting it directly.")
    character = localPlayer.Character
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart not found in character.")
        return
    end
    print("Calling toggleTeleport because player already has character")
     if getgenv().Star then
        toggleTeleport(true)
    end
else
    print("Waiting for CharacterAdded event.")
    localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

starsFolder.ChildAdded:Connect(function(newStar)
    if getgenv().Star then
        local rootPart = newStar:FindFirstChild("Root")
        if rootPart and rootPart:IsA("BasePart") and rootPart.Color ~= VIP_STAR_COLOR then

            starOriginalPositions[newStar] = rootPart.Position;

            movePlayerToStar(newStar)
        end
    end
end)
