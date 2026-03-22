-- Dead Rails Safe Utility (Anti-Cheat / Rubberband Bypass)
-- 3 Buttons: Fly & Ghost (Normal Speed), True Fullbright, Auto-Collect Aura

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- ============== GUI CREATION ==============
local existingGui = plr:WaitForChild("PlayerGui"):FindFirstChild("DeadRailsSafeUtility") or CoreGui:FindFirstChild("DeadRailsSafeUtility")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSafeUtility"
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

-- CLOSE & MINIMIZE BUTTONS
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

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

-- UI BUTTON GENERATOR (EXACTLY 3 BUTTONS)
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
local fullbrightBtn = createButton(65, "True Fullbright")
local auraBtn = createButton(115, "Auto Collect")

-- ============== MOBILE FLY CONTROLS ==============
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

upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = true end end)
upBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = false end end)
downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = true end end)
downBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = false end end)

-- ============== FLY & GHOST MODE (SAFE SPEED) ==============
local flying = false
local flyConnection
local bodyVelocity, bodyGyro

-- Update character variables upon dying so the script doesn't break
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    
    -- Turn off fly if they died to prevent bugs
    if flying then
        flyBtn.Text = "Fly & Ghost Mode: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        flying = false
        mobileFlyUI.Visible = false
        if flyConnection then flyConnection:Disconnect() end
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly & Ghost Mode: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        if UserInputService.TouchEnabled then mobileFlyUI.Visible = true end
        
        if hrp and humanoid then
            hrp.Anchored = false
            humanoid.PlatformStand = true 
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = hrp
            
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bodyGyro.P = 10000
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
        end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not char or not hrp or not humanoid then return end
            
            -- Ghost Mode (Immune to touch kill-bricks, pass through walls)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CanTouch = false 
                end
            end
            
            -- NORMAL SPEED (Prevents Rubberbanding)
            -- Matches exactly how fast the game allows you to walk
            local currentSafeSpeed = humanoid.WalkSpeed 
            if currentSafeSpeed < 16 then currentSafeSpeed = 16 end 
            
            local moveVector = Vector3.new(0, 0, 0)
            pcall(function()
                local controlModule = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                moveVector = controlModule:GetMoveVector()
            end)
            
            local camCFrame = Workspace.CurrentCamera.CFrame
            local flyDir = (camCFrame.RightVector * moveVector.X) + (camCFrame.LookVector * -moveVector.Z)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or upPressed then flyDir = flyDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then flyDir = flyDir - Vector3.new(0, 1, 0) end
            
            if flyDir.Magnitude > 0 then flyDir = flyDir.Unit end
            
            if bodyVelocity and bodyGyro then
                bodyVelocity.Velocity = flyDir * currentSafeSpeed -- SAFE SPEED HERE
                bodyGyro.CFrame = camCFrame
            end
        end)
    else
        flyBtn.Text = "Fly & Ghost Mode: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        mobileFlyUI.Visible = false
        upPressed, downPressed = false, false
        
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        if humanoid then humanoid.PlatformStand = false end
        
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

-- ============== TRUE FULLBRIGHT ==============
local isFullbright = false
local fbConnection

fullbrightBtn.MouseButton1Click:Connect(function()
    isFullbright = not isFullbright
    if isFullbright then
        fullbrightBtn.Text = "True Fullbright: ON"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        fbConnection = RunService.RenderStepped:Connect(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("FogModifier") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                    v.Enabled = false
                end
            end
        end)
    else
        fullbrightBtn.Text = "True Fullbright: OFF"
        fullbrightBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if fbConnection then fbConnection:Disconnect() end
        
        Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 2000
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("FogModifier") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                v.Enabled = true
            end
        end
    end
end)

-- ============== LAG-FREE AUTO COLLECT AURA ==============
local auraEnabled = false
local collectRadius = 45 
local cachedPrompts = {}

-- Background cache generation
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then table.insert(cachedPrompts, v) end
end
Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then table.insert(cachedPrompts, v) end
end)

auraBtn.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    if auraEnabled then
        auraBtn.Text = "Auto Collect: ON"
        auraBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        auraBtn.Text = "Auto Collect: OFF"
        auraBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if auraEnabled and hrp then
            for i = #cachedPrompts, 1, -1 do
                local prompt = cachedPrompts[i]
                
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
                            table.remove(cachedPrompts, i)
                        end
                    end
                end
            end
        end
    end
end)

print("✅ Anti-Cheat Safe Mobile Utility Loaded!")
