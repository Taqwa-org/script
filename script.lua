-- FIXED Dead Rails Auto Bond Script (GUI ALWAYS shows)
-- Fully integrated GUI & Improved bond detection

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
-- Clean up old GUI if it already exists
local existingGui = plr:WaitForChild("PlayerGui"):FindFirstChild("DeadRailsAutoBond") or CoreGui:FindFirstChild("DeadRailsAutoBond")
if existingGui then
    existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsAutoBond"
screenGui.ResetOnSpawn = false
-- Protect GUI if executor supports it, otherwise put in PlayerGui
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = plr:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Smooth Dragging Logic
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

-- Fix bottom corners of header
local headerBottomCover = Instance.new("Frame")
headerBottomCover.Size = UDim2.new(1, 0, 0, 8)
headerBottomCover.Position = UDim2.new(0, 0, 1, -8)
headerBottomCover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
headerBottomCover.BorderSizePixel = 0
headerBottomCover.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Dead Rails Auto Bond"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- Body Container
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -35)
body.Position = UDim2.new(0, 0, 0, 35)
body.BackgroundTransparency = 1
body.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Auto Bond: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Parent = body

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.Parent = body

-- State variables
local enabled = false
local autoThread = nil
local minimized = false

-- GUI Click Logic
closeBtn.MouseButton1Click:Connect(function()
    enabled = false
    screenGui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        body.Visible = false
        mainFrame.Size = UDim2.new(0, 320, 0, 35)
        minBtn.Text = "+"
    else
        body.Visible = true
        mainFrame.Size = UDim2.new(0, 320, 0, 180)
        minBtn.Text = "-"
    end
end)

-- ============== Remote fallback / guess ==============
local remote
do
    local pkg = ReplicatedStorage:FindFirstChild("Packages")
    if pkg then
        remote = pkg:FindFirstChild("ActivateObjectClient")
    end
    if not remote then
        for _, v in ReplicatedStorage:GetDescendants() do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("collect") or v.Name:lower():find("pickup") or v.Name:lower():find("interact") or v.Name:lower():find("activate")) then
                remote = v
                break
            end
        end
    end
end

-- ============== Better bond finding logic ==============
local function findBonds()
    local candidates = {}
    local searchFolders = {
        Workspace:FindFirstChild("RuntimeItems"),
        Workspace:FindFirstChild("Loot"),
        Workspace:FindFirstChild("Map"),
        Workspace,
    }
    
    for _, folder in searchFolders do
        if not folder then continue end
        for _, obj in folder:GetDescendants() do
            local name = obj.Name:lower()
            if name:find("bond") or name:find("bonus") or name:find("treasury") or name == "bond" 
                or obj:IsA("Tool") or obj:FindFirstChildOfClass("ProximityPrompt") 
                or obj:FindFirstChildOfClass("ClickDetector") then
                
                local targetPart = obj:IsA("BasePart") and obj 
                    or obj:FindFirstChildWhichIsA("BasePart") 
                    or obj.PrimaryPart
                    
                if targetPart then
                    table.insert(candidates, {obj = obj, part = targetPart})
                end
            end
        end
    end
    return candidates
end

-- ============== AUTO BOND LOGIC ==============
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Bond: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        statusLabel.Text = "ON - Searching bonds..."
        
        autoThread = coroutine.create(function()
            while enabled do
                -- Check if character is currently alive & spawned
                if not hrp or not hrp.Parent then
                    task.wait(1)
                    continue
                end
                
                local bonds = findBonds()
                
                if #bonds > 0 then
                    statusLabel.Text = "Found " .. #bonds .. " bond(s) - collecting..."
                    
                    for _, bond in bonds do
                        if not enabled or not hrp or not hrp.Parent then break end
                        
                        -- Safe tp above
                        hrp.CFrame = bond.part.CFrame * CFrame.new(0, 4.5, 0)
                        task.wait(0.35) 
                        
                        -- Try remote fire
                        if remote then
                            pcall(function() remote:FireServer(bond.obj) end)
                        end
                        
                        -- Fallback: fire proximity / click if exists
                        local prompt = bond.obj:FindFirstChildOfClass("ProximityPrompt") or bond.part:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                        
                        -- Mark to avoid re-collect spam
                        bond.obj.Name = bond.obj.Name .. "_collected"
                        
                        task.wait(0.4)
                    end
                else
                    statusLabel.Text = "No bonds found - scanning map..."
                end
                
                task.wait(0.6)  -- main loop delay
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Bond: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "Status: Idle"
    end
end)

print("✅ Improved Auto Bond GUI loaded successfully!")
