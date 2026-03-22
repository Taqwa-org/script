-- FIXED Dead Rails Auto Vault/Bond Script
-- New Logic: Targets Banks/Vaults -> Sweeps the Vault for Loot -> Marks Visited -> Moves to Next

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Auto-update character on respawn
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

-- Header & Buttons
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
title.Text = "Dead Rails Vault Sweeper"
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
toggleBtn.Text = "Auto Sweep: OFF"
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
local isMoving = false
local currentTween = nil
local TWEEN_SPEED = 140 -- Fast but safe from anticheat
local visitedPlaces = {} -- Tracks marked banks

-- GUI Clicks
closeBtn.MouseButton1Click:Connect(function() enabled = false screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
    mainFrame.Size = body.Visible and UDim2.new(0, 320, 0, 180) or UDim2.new(0, 320, 0, 35)
    minBtn.Text = body.Visible and "-" or "+"
end)

-- ============== GHOST MODE (Prevents Damage) ==============
local function setTouch(state)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = state end
    end
end

RunService.Stepped:Connect(function()
    if enabled and isMoving and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ============== TARGETING LOGIC ==============
local function tweenTo(targetCFrame)
    if not hrp then return false end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToTake = distance / TWEEN_SPEED
    if timeToTake < 0.1 then timeToTake = 0.1 end
    
    currentTween = TweenService:Create(hrp, TweenInfo.new(timeToTake, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    
    isMoving = true
    hrp.Anchored = true
    setTouch(false)
    
    currentTween:Play()
    task.wait(timeToTake)
    return true
end

-- 1. Find the Banks / Vaults (Grouped by location)
local function getBanks()
    local places = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name == "bank" or name == "vault" or name == "safe" or name:find("treasury") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and not visitedPlaces[obj] then
                
                -- Ensure we don't grab 50 parts of the exact same bank
                local isDuplicate = false
                for _, p in ipairs(places) do
                    if (p.part.Position - part.Position).Magnitude < 150 then
                        isDuplicate = true
                        visitedPlaces[obj] = tick() -- Mark duplicates as visited silently
                        break
                    end
                end
                
                if not isDuplicate then
                    table.insert(places, {obj = obj, part = part})
                end
            end
        end
    end
    return places
end

-- 2. Sweep the area for ANY loot
local function sweepVaultLoot()
    if not hrp then return end
    
    -- Pass 1: Proximity Prompts (Open safes, grab bonds)
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local part = prompt.Parent
            if part and part:IsA("BasePart") then
                if (part.Position - hrp.Position).Magnitude < 80 then -- If it's in the vault with us
                    local action = prompt.ActionText:lower()
                    if not action:find("sit") then -- Ignore chairs
                        tweenTo(part.CFrame)
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = 50
                        prompt.HoldDuration = 0
                        
                        pcall(function() fireproximityprompt(prompt) end)
                        task.wait(0.05)
                        pcall(function() fireproximityprompt(prompt) end)
                        
                        prompt.Enabled = false
                        part.Name = part.Name .. "_looted"
                    end
                end
            end
        end
    end
    
    -- Pass 2: Touch Parts (Loose cash, dropped bonds)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("bond") or name:find("cash") or name:find("money") or name == "gold" or name:find("loot") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and (part.Position - hrp.Position).Magnitude < 80 then
                tweenTo(part.CFrame)
                pcall(function()
                    firetouchinterest(hrp, part, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, part, 1)
                end)
                obj.Name = obj.Name .. "_looted"
            end
        end
    end
end

-- ============== MAIN LOOP ==============
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Sweep: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        autoThread = coroutine.create(function()
            while enabled do
                if not hrp or not hrp.Parent then task.wait(1) continue end
                
                -- Clear cooldowns (Banks reset after 3 minutes so we can re-rob them)
                for obj, timeVisited in pairs(visitedPlaces) do
                    if tick() - timeVisited > 180 then visitedPlaces[obj] = nil end
                end
                
                statusLabel.Text = "Scanning map for Banks/Vaults..."
                local banks = getBanks()
                
                if #banks > 0 then
                    for _, bank in ipairs(banks) do
                        if not enabled or not hrp or not hrp.Parent then break end
                        
                        statusLabel.Text = "Flying to: " .. bank.obj.Name
                        
                        -- Tween inside the Bank/Vault
                        tweenTo(bank.part.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5) -- Wait for game to spawn the local vault loot
                        
                        statusLabel.Text = "Sweeping Vault for Bonds & Loot..."
                        sweepVaultLoot()
                        
                        -- Mark as fully looted
                        visitedPlaces[bank.obj] = tick()
                        task.wait(0.5)
                    end
                    
                    -- Reset physics when moving to next area
                    if hrp then hrp.Anchored = false end
                    setTouch(true)
                    isMoving = false
                else
                    if hrp then hrp.Anchored = false end
                    setTouch(true)
                    isMoving = false
                    statusLabel.Text = "All Banks marked. Waiting for respawns..."
                end
                
                task.wait(2)
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Sweep: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "Status: Idle"
        
        if currentTween then currentTween:Cancel() end
        isMoving = false
        if hrp then hrp.Anchored = false end
        setTouch(true)
    end
end)
