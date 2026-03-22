-- Dead Rails Mobile-Friendly Utility
-- Supports Mobile Thumbstick Fly, Touch Buttons, Minimize, Fullbright, and Lag-Free Aura

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Auto-update character on respawn
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

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 210)
mainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Touch/Mouse Smooth Dragging
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

-- HEADER
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

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame", mainFrame)
body.Size = UDim2.new(1, 0, 1, -35)
body.Position = UDim2.new(0, 0, 0, 35)
body.BackgroundTransparency = 1

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 320, 0, 35) or UDim2.new(0, 320, 0, 210)
    minBtn.Text = minimized and "+" or "-"
end)

-- UI BUTTON GENERATOR
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

-- ============== MOBILE FLY CONTROLS (ON-SCREEN) ==============
local mobileFlyUI = Instance.new("Frame", screenGui)
mobileFlyUI.Size = UDim2.new(0, 60, 0, 130)
mobileFlyUI.Position = UDim2.new(1, -80, 0.5, -65)
mobileFlyUI.BackgroundTransparency = 1
mobileFlyUI.Visible = false

local function createFlyControl(yPos, text)
    local btn = Instance.new("TextButton", mobileFlyUI)
    btn.Size = UDim2.new(1, 0, 0, 60)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local upBtn = createFlyControl(0, "⬆️")
local downBtn = createFlyControl(70, "⬇️")

local upPressed, downPressed = false, false

upBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = true end
end)
upBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = false end
end)
downBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = true end
end)
downBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = false end
end)

-- ============== FLY & GHOST MODE LOGIC ==============
local flying = false
local flySpeed = 75
local flyConnection

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly & Ghost Mode: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Show mobile buttons if on a touch device
        if UserInputService.TouchEnabled then mobileFlyUI.Visible = true end
        if hrp then hrp.Anchored = true end
        
        flyConnection = RunService.RenderStepped:Connect(function(dt)
            if not char or not hrp then return end
            
            -- Ghost Mode (Pass through walls + Immune to touch damage)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false 
                end
            end
            
            -- CROSS-PLATFORM MOVEMENT (Reads WASD and Mobile Thumbstick natively)
            local moveVector = Vector3.new(0, 0, 0)
            pcall(function()
                local controlModule = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                moveVector = controlModule:GetMoveVector()
            end)
            
            local camCFrame = Workspace.CurrentCamera.CFrame
            local flyDir = Vector3.new(0, 0, 0)
            
            if moveVector.Magnitude > 0 then
                flyDir = (camCFrame.RightVector * moveVector.X) + (camCFrame.LookVector * -moveVector.Z)
            end
            
            -- Vertical Fly (PC space/ctrl OR Mobile Buttons)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or upPressed then flyDir = flyDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then flyDir = flyDir - Vector3.new(0, 1, 0) end
            
            if flyDir.Magnitude > 0 then
                flyDir = flyDir.Unit
                hrp.CFrame = hrp.CFrame + (flyDir * (flySpeed * dt))
            end
        end)
    else
        flyBtn.Text = "Fly & Ghost Mode: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        mobileFlyUI.Visible = false
        upPressed, downPressed = false, false
        
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

-- ============== FULLBRIGHT ==============
local isFullbright = false
local fullbrightConnection

fullbrightBtn.MouseButton1Click:Connect(function()
    isFullbright = not isFullbright
    if isFullbright then
        fullbrightBtn.Text = "Fullbright: ON"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        fullbrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end)
    else
        fullbrightBtn.Text = "Fullbright: OFF"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if fullbrightConnection then fullbrightConnection:Disconnect() end
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 2000
    end
end)

-- ============== LAG-FREE MOBILE AURA ==============
local auraEnabled = false
local collectRadius = 45 

-- Cache Prompts so we don't lag mobile devices by scanning workspace constantly
local cachedPrompts = {}
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then table.insert(cachedPrompts, v) end
end
Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then table.insert(cachedPrompts, v) end
end)

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
    while task.wait(0.2) do
        if auraEnabled and hrp then
            for i = #cachedPrompts, 1, -1 do
                local prompt = cachedPrompts[i]
                
                -- Remove broken/deleted prompts from cache
                if not prompt or not prompt.Parent then
                    table.remove(cachedPrompts, i)
                    continue
                end
                
                local part = prompt.Parent
                if part and part:IsA("BasePart") then
                    local dist = (part.Position - hrp.Position).Magnitude
                    
                    if dist <= collectRadius then
                        local action = prompt.ActionText:lower()
                        local objectName = prompt.ObjectText:lower()
                        local name = part.Name:lower()
                        
                        -- Target logic
                        if action:find("collect") or action:find("search") or action:find("take") or name:find("bond") or objectName:find("bond") or name:find("safe") or name:find("cash") then
                            
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = collectRadius + 10
                            
                            pcall(function() fireproximityprompt(prompt) end)
                            
                            part.Name = part.Name .. "_looted"
                            table.remove(cachedPrompts, i) -- Stop targeting it once fired
                        end
                    end
                end
            end
        end
    end
end)

print("✅ Dead Rails Mobile Utility Loaded Successfully!")
