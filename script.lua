-- Dead Rails Utility: Manual Fly + Fullbright + Auto-Collect Aura
-- You control the movement. The script handles the noclip, protection, and auto-looting.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Auto-update character if you die/respawn
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- ============== GUI CREATION ==============
local existingGui = plr:WaitForChild("PlayerGui"):FindFirstChild("DeadRailsUtility") or CoreGui:FindFirstChild("DeadRailsUtility")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsUtility"
screenGui.ResetOnSpawn = false
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = plr:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Smooth Dragging
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
local hCover = Instance.new("Frame", header)
hCover.Size = UDim2.new(1, 0, 0, 8)
hCover.Position = UDim2.new(0, 0, 1, -8)
hCover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
hCover.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Dead Rails Utility"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Body container
local body = Instance.new("Frame", mainFrame)
body.Size = UDim2.new(1, 0, 1, -35)
body.Position = UDim2.new(0, 0, 0, 35)
body.BackgroundTransparency = 1

-- UI Button Generator Function
local function createButton(yOffset, defaultText)
    local btn = Instance.new("TextButton", body)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = defaultText .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local flyBtn = createButton(15, "Fly & Ghost Mode")
local fullbrightBtn = createButton(65, "Fullbright")
local auraBtn = createButton(115, "Auto-Collect Aura")

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ============== FLY & GHOST MODE SYSTEM ==============
local flying = false
local flySpeed = 75
local flyConnection

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly & Ghost Mode: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        if hrp then hrp.Anchored = true end
        
        flyConnection = RunService.RenderStepped:Connect(function(dt)
            if not char or not hrp then return end
            
            -- Ghost Mode / Noclip Logic
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false -- Prevents taking damage from traps/lava
                end
            end
            
            -- Smooth Fly Movement Logic
            local camCFrame = Workspace.CurrentCamera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
            
            hrp.CFrame = hrp.CFrame + (moveDir * (flySpeed * dt))
        end)
    else
        flyBtn.Text = "Fly & Ghost Mode: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        if flyConnection then flyConnection:Disconnect() end
        if hrp then hrp.Anchored = false end
        
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanTouch = true
                end
            end
        end
    end
end)

-- ============== FULLBRIGHT SYSTEM ==============
local isFullbright = false
local fullbrightConnection

fullbrightBtn.MouseButton1Click:Connect(function()
    isFullbright = not isFullbright
    if isFullbright then
        fullbrightBtn.Text = "Fullbright: ON"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Force rendering constantly (bypasses games that try to reset lighting)
        fullbrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end)
    else
        fullbrightBtn.Text = "Fullbright: OFF"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if fullbrightConnection then fullbrightConnection:Disconnect() end
        
        -- Reset to a generic default (game will naturally adapt)
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 2000
    end
end)

-- ============== AUTO-COLLECT AURA ==============
local auraEnabled = false
local collectRadius = 45 -- Will suck up anything within 45 studs of you

auraBtn.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    if auraEnabled then
        auraBtn.Text = "Auto-Collect Aura: ON"
        auraBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        auraBtn.Text = "Auto-Collect Aura: OFF"
        auraBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

task.spawn(function()
    while task.wait(0.2) do -- Scans every 0.2 seconds
        if auraEnabled and hrp then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local part = prompt.Parent
                    if part and part:IsA("BasePart") then
                        
                        -- Check if we are close enough
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= collectRadius then
                            
                            local action = prompt.ActionText:lower()
                            local objectName = prompt.ObjectText:lower()
                            local name = part.Name:lower()
                            
                            -- Is it loot or a safe/bond?
                            if action:find("collect") or action:find("search") or action:find("take") or name:find("bond") or objectName:find("bond") or name:find("safe") or name:find("cash") then
                                
                                -- Bypass anti-cheats on the prompt and force fire it instantly
                                prompt.RequiresLineOfSight = false
                                prompt.HoldDuration = 0
                                prompt.MaxActivationDistance = collectRadius + 10
                                
                                pcall(function() fireproximityprompt(prompt) end)
                                
                                -- To prevent lag from firing the same prompt hundreds of times
                                part.Name = part.Name .. "_looted"
                            end
                        end
                    end
                end
            end
        end
    end
end)

print("✅ Dead Rails Utility Loaded!")
print("Controls: W A S D to fly. SPACE to go up. LEFT-CONTROL to go down.")
