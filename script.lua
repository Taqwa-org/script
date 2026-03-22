-- Dead Rails: "Quantum Blink & Drone Scout" Utility
-- Explores with Freecam -> Uses Flicker TP to force-load chunks and bypass rubberbands!

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
local existingGui = plr:WaitForChild("PlayerGui"):FindFirstChild("DeadRailsDroneUtility") or CoreGui:FindFirstChild("DeadRailsDroneUtility")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsDroneUtility"
screenGui.ResetOnSpawn = false
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = plr:WaitForChild("PlayerGui") end

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
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
title.Text = "Dead Rails Quantum Loot"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
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
    mainFrame.Size = minimized and UDim2.new(0, 320, 0, 35) or UDim2.new(0, 320, 0, 260)
    minBtn.Text = minimized and "+" or "-"
end)

-- UI BUTTON GENERATOR
local function createButton(yOffset, defaultText, color)
    local btn = Instance.new("TextButton", body)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, yOffset)
    btn.BackgroundColor3 = color or Color3.fromRGB(200, 50, 50)
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local droneBtn = createButton(15, "Drone Scout (Freecam): OFF")
local forceTpBtn = createButton(65, "⚡ Quantum Blink & Loot", Color3.fromRGB(200, 120, 30))
local fullbrightBtn = createButton(115, "True Fullbright: OFF")
local auraBtn = createButton(165, "Auto Collect: OFF")

-- ============== MOBILE DRONE CONTROLS ==============
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

-- ============== DRONE SCOUT LOGIC ==============
local droning = false
local dronePart = nil
local droneSpeed = 150 
local droneConnection

droneBtn.MouseButton1Click:Connect(function()
    droning = not droning
    local cam = Workspace.CurrentCamera
    
    if droning then
        droneBtn.Text = "Drone Scout (Freecam): ON"
        droneBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        if UserInputService.TouchEnabled then mobileFlyUI.Visible = true end
        
        -- Lock real character in place safely
        if hrp then 
            hrp.Anchored = true 
            hrp.Velocity = Vector3.new(0,0,0)
        end
        
        dronePart = Instance.new("Part")
        dronePart.Size = Vector3.new(1, 1, 1)
        dronePart.Transparency = 1
        dronePart.CanCollide = false
        dronePart.Anchored = true
        if hrp then dronePart.CFrame = hrp.CFrame end
        dronePart.Parent = Workspace
        
        cam.CameraSubject = dronePart
        
        droneConnection = RunService.RenderStepped:Connect(function(dt)
            if not dronePart then return end
            
            local moveVector = Vector3.new(0, 0, 0)
            pcall(function()
                local controlModule = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                moveVector = controlModule:GetMoveVector()
            end)
            
            local flyDir = (cam.CFrame.RightVector * moveVector.X) + (cam.CFrame.LookVector * -moveVector.Z)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or upPressed then flyDir = flyDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then flyDir = flyDir - Vector3.new(0, 1, 0) end
            
            if flyDir.Magnitude > 0 then flyDir = flyDir.Unit end
            dronePart.Position = dronePart.Position + (flyDir * droneSpeed * dt)
        end)
    else
        droneBtn.Text = "Drone Scout (Freecam): OFF"
        droneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        mobileFlyUI.Visible = false
        upPressed, downPressed = false, false
        
        if droneConnection then droneConnection:Disconnect() end
        if dronePart then dronePart:Destroy() end
        
        if humanoid then cam.CameraSubject = humanoid end
        if hrp then hrp.Anchored = false end
    end
end)

-- ============== QUANTUM BLINK & LOOT LOGIC ==============
local isQuantumLooting = false

forceTpBtn.MouseButton1Click:Connect(function()
    if not hrp or isQuantumLooting then return end
    
    isQuantumLooting = true
    forceTpBtn.Text = "FLICKERING & LOOTING..."
    forceTpBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    
    -- Where are we, and where are we looting?
    local safeCF = hrp.CFrame
    local targetCF = dronePart and dronePart.CFrame or Workspace.CurrentCamera.CFrame
    
    -- Force Roblox to stream the target area chunks immediately
    pcall(function() plr:RequestStreamAroundAsync(targetCF.Position) end)
    
    -- Ensure player is unanchored so physics update, but immune to damage
    hrp.Anchored = false
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = false end
    end
    
    local tickCount = 0
    -- The Flicker Loop: Swaps position every single frame
    local flickerConn = RunService.Heartbeat:Connect(function()
        tickCount = tickCount + 1
        if tickCount % 2 == 0 then
            hrp.CFrame = targetCF -- Trigger loot spawn
        else
            hrp.CFrame = safeCF   -- Satisfy anti-cheat
        end
        hrp.Velocity = Vector3.new(0, 0, 0)
    end)
    
    -- While flickering, aggressively scan the target area for loot
    task.spawn(function()
        local startTick = tick()
        -- Flicker for 3.5 seconds to give items time to load and collect
        while tick() - startTick < 3.5 do
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                    local dist = (prompt.Parent.Position - targetCF.Position).Magnitude
                    if dist <= 60 then
                        local action = prompt.ActionText:lower()
                        local objectName = prompt.ObjectText:lower()
                        local name = prompt.Parent.Name:lower()
                        
                        if action:find("collect") or action:find("search") or action:find("take") or name:find("bond") or objectName:find("bond") or name:find("safe") or name:find("cash") then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = 60
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        
        -- End the Flicker Safely
        flickerConn:Disconnect()
        hrp.CFrame = safeCF
        hrp.Velocity = Vector3.new(0,0,0)
        
        -- Restore hitboxes
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = true end
        end
        
        -- If still droning, lock character back in place
        if droning then hrp.Anchored = true end
        
        isQuantumLooting = false
        forceTpBtn.Text = "⚡ Quantum Blink & Loot"
        forceTpBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 30)
    end)
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

-- ============== PASSIVE AUTO COLLECT ==============
local auraEnabled = false

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
    while task.wait(0.5) do
        if auraEnabled and hrp and not isQuantumLooting then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                    local dist = (prompt.Parent.Position - hrp.Position).Magnitude
                    if dist <= 45 then
                        local action = prompt.ActionText:lower()
                        local objectName = prompt.ObjectText:lower()
                        local name = prompt.Parent.Name:lower()
                        
                        if action:find("collect") or action:find("search") or action:find("take") or name:find("bond") or objectName:find("bond") or name:find("safe") or name:find("cash") then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = 55
                            pcall(function() fireproximityprompt(prompt) end)
                            prompt.Parent.Name = prompt.Parent.Name .. "_looted"
                        end
                    end
                end
            end
        end
    end
end)

-- Character safe reset
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if droning then
        droneBtn.Text = "Drone Scout (Freecam): OFF"
        droneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        droning = false
        mobileFlyUI.Visible = false
        if droneConnection then droneConnection:Disconnect() end
        if dronePart then dronePart:Destroy() end
    end
end)

print("✅ Quantum Blink & Drone Scout Loaded Successfully!")
