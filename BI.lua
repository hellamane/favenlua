local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = DiscordLib:Window("faven.lua")
local serv = win:Server("Main", "")
local autofarmChannel = serv:Channel("Autofarm")

------------------------------------------------------------
-- Toggles
------------------------------------------------------------
local breadToggle = false
local crateToggle = false
local autosellToggle = false
local antiKickToggle = false
local antiKickConnection = nil

autofarmChannel:Toggle("Bread Toggle", false, function(state)
	breadToggle = state
end)

autofarmChannel:Toggle("Crate Toggle", false, function(state)
	crateToggle = state
end)

autofarmChannel:Toggle("Autosell Toggle", false, function(state)
	autosellToggle = state
end)

autofarmChannel:Toggle("Anti Kick", false, function(state)
	antiKickToggle = state
	if antiKickToggle then
		antiKickConnection = Players.LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0,0))
		end)
	else
		if antiKickConnection then
			antiKickConnection:Disconnect()
			antiKickConnection = nil
		end
	end
end)

autofarmChannel:Button("Boost FPS", function()
	if Workspace:FindFirstChild("GameModels") then
		Workspace.GameModels:Destroy()
		print("Boost FPS activated")
	end
end)

------------------------------------------------------------
-- Bread Loop
------------------------------------------------------------
spawn(function()
	local player = Players.LocalPlayer
	if not player.Character then player.CharacterAdded:Wait() end
	local function getChest(character)
		return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	end
	while wait(0.1) do
		if breadToggle then
			local character = player.Character
			if character then
				local chest = getChest(character)
				if chest then
					local cf = chest.CFrame
					local breadFolder = Workspace:FindFirstChild("Bread") and Workspace.Bread:FindFirstChild(player.Name.."Bread")
					if breadFolder then
						for _, part in ipairs(breadFolder:GetChildren()) do
							if part:IsA("MeshPart") then
								part.CFrame = cf
							end
						end
					end
				end
			end
		end
	end
end)

------------------------------------------------------------
-- Crate Loop
------------------------------------------------------------
spawn(function()
	local player = Players.LocalPlayer
	while wait(0.1) do
		if crateToggle then
			local crateFolder = Workspace:FindFirstChild("Crates") and Workspace.Crates:FindFirstChild(player.Name.."Crate")
			if crateFolder then
				local crates = crateFolder:GetChildren()
				local validFound = false
				for _, crate in ipairs(crates) do
					if not crateToggle then break end
					local base = nil
					if crate:IsA("Model") then
						base = crate:FindFirstChild("Base") or crate.PrimaryPart
					elseif crate:IsA("BasePart") then
						base = crate
					end
					if base then
						-- Process only if the base is visible (Transparency < 1) and still “closed” (has a WeldConstraint)
						if base.Transparency < 1 and base:FindFirstChildOfClass("WeldConstraint") then
							validFound = true
							local character = player.Character or player.CharacterAdded:Wait()
							local hrp = character:WaitForChild("HumanoidRootPart")
							if (hrp.Position - base.Position).Magnitude <= 50 then
								hrp.CFrame = base.CFrame * CFrame.new(0, 0, 3)
								
								-- Re-hold loop: hold "E" until at least 2 seconds have passed or the crate becomes open.
								local holdTime = 0
								VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
								while crateToggle and holdTime < 2 do
									wait(0.1)
									holdTime = holdTime + 0.1
									if base.Transparency >= 1 or not base:FindFirstChildOfClass("WeldConstraint") then
										break
									end
								end
								VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
								print("Crate prompt held for: " .. crate.Name)
								wait(0.5)
							else
								print("Crate " .. crate.Name .. " is too far.")
							end
						else
							print("Skipping crate " .. crate.Name .. " (invisible or open).")
						end
					else
						print("Crate " .. crate.Name .. " has no valid base.")
					end
				end
				if not validFound then
					wait(0.5)
				end
			end
		end
	end
end)

------------------------------------------------------------
-- Autosell Loop
------------------------------------------------------------
spawn(function()
	local player = Players.LocalPlayer
	local sellButton = Workspace:WaitForChild("Map"):WaitForChild("SellScreen"):WaitForChild("Button")
	local origCF = sellButton.CFrame
	local origCollide = sellButton.CanCollide
	while wait(0.1) do
		if autosellToggle then
			sellButton.CanCollide = false
			sellButton.Anchored = true
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
			if torso then
				sellButton.CFrame = torso.CFrame * CFrame.new(0, 0, -1)
			else
				sellButton.CFrame = origCF
			end
		else
			sellButton.CanCollide = origCollide
			sellButton.CFrame = origCF
		end
	end
end)
