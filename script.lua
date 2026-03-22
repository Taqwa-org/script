-- FIXED Dead Rails Auto Bond Script
-- 1. Strict Bond Targeting (No more flying to random map parts)
-- 2. Ghost Mode (No damage while flying)
-- 3. Instant Proximity Firing

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Auto-update character if you die/respawn
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- ============== GUI CREATION ==============
local existingGui = plr:WaitForChild("PlayerGui"):FindFirstChild("DeadRailsAutoBond") or CoreGui:FindFirstChild("DeadRailsAutoBond")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsAutoBond"
screenGui.ResetOnSpawn = false
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = plr:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

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

-- Header & Buttons
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.Parent = mainFrame
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
title.Text = "Dead Rails FAST Auto Bond"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

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

local toggleBtn = Instance.new("TextButton", body)
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Auto Bond: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", body)
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14

-- ============== STATE VARIABLES ==============
local enabled = false
local autoThread = nil
local minimized = false
local isMoving = false
local currentTween = nil
local TWEEN_SPEED = 140 -- Safe speed to avoid anti-cheat kicks

-- GUI Clicks
closeBtn.MouseButton1Click:Connect(function() enabled = false screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        body.Visible = false mainFrame.Size = UDim2.new(0, 320, 0, 35) minBtn.Text = "+"
    else
        body.Visible = true mainFrame.Size = UDim2.new(0, 320, 0, 180) minBtn.Text = "-"
    end
end)

-- ============== GHOST MODE (Prevents Damage & Sticking) ==============
local function setTouch(state)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanTouch = state -- Disables touching kill bricks / damage scripts
        end
    end
end

RunService.Stepped:Connect(function()
    if enabled and isMoving and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0) -- Stop fall damage
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ============== STRICT BOND FINDING ==============
local function findBonds()
    local candidates = {}
    -- Only look for actual interactable prompts to prevent flying to fake map parts
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local obj = prompt.Parent
            if obj then
                local name = obj.Name:lower()
                local action = prompt.ActionText:lower()
                local objectName = prompt.ObjectText:lower()
                
                -- Check if it actually looks like a loot/bond
                if name:find("bond") or name:find("bonus") or action:find("collect") or action:find("pickup") or action:find("search") or action:find("take") or objectName:find("bond") then
                    
                    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
                    if targetPart then
                        table.insert(candidates, {obj = obj, part = targetPart, prompt = prompt})
                    end
                end
            end
        end
    end
    return candidates
end

-- ============== TWEEN FUNCTION ==============
local function tweenTo(targetPart)
    if not hrp or not targetPart then return false end
    
    local distance = (hrp.Position - targetPart.Position).Magnitude
    local timeToTake = distance / TWEEN_SPEED
    if timeToTake < 0.1 then timeToTake = 0.1 end
    
    local tweenInfo = TweenInfo.new(timeToTake, Enum.EasingStyle.Linear)
    -- Tween directly to the part
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPart.CFrame})
    
    isMoving = true
    hrp.Anchored = true
    setTouch(false) -- Activate ghost mode
    
    currentTween:Play()
    
    -- Wait until completed or target disappears
    local start = tick()
    while tick() - start < timeToTake do
        if not targetPart or not targetPart.Parent then
            currentTween:Cancel()
            break
        end
        task.wait(0.1)
    end
    
    return true
end

-- ============== AUTO BOND LOGIC ==============
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Bond: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        autoThread = coroutine.create(function()
            while enabled do
                if not hrp or not hrp.Parent then task.wait(1) continue end
                
                local bonds = findBonds()
                
                if #bonds > 0 then
                    statusLabel.Text = "Collecting " .. #bonds .. " confirmed bond(s)..."
                    
                    for _, bond in bonds do
                        if not enabled or not hrp or not hrp.Parent then break end
                        if not bond.part or not bond.part.Parent then continue end
                        
                        -- Smooth fly
                        tweenTo(bond.part)
                        
                        -- FAST INSTANT COLLECT
                        if bond.prompt then
                            bond.prompt.RequiresLineOfSight = false
                            bond.prompt.MaxActivationDistance = 50
                            bond.prompt.HoldDuration = 0
                            
                            -- Fire it twice to ensure server registers it
                            pcall(function() fireproximityprompt(bond.prompt) end)
                            task.wait(0.05)
                            pcall(function() fireproximityprompt(bond.prompt) end)
                        end
                        
                        -- Mark to avoid repeating
                        if bond.obj then
                            bond.obj.Name = bond.obj.Name .. "_collected"
                            -- Safely destroy the prompt so it removes from our scan queue
                            if bond.prompt then bond.prompt:Destroy() end
                        end
                    end
                    
                    -- Reset character state
                    if hrp then hrp.Anchored = false end
                    setTouch(true)
                    isMoving = false
                else
                    if hrp then hrp.Anchored = false end
                    setTouch(true)
                    isMoving = false
                    statusLabel.Text = "No bonds found - scanning map..."
                end
                
                task.wait(0.5) -- Scan interval
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Bond: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "Status: Idle"
        
        if currentTween then currentTween:Cancel() end
        isMoving = false
        if hrp then hrp.Anchored = false end
        setTouch(true)
    end
end)
