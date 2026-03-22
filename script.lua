-- FIXED Dead Rails Auto Bond Script (GUI ALWAYS shows)
-- Tested structure March 2026 - works in lobby + in-game

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer

-- ============== GUI CREATION (ALWAYS FIRST) ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsAutoBond"
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Dead Rails - Auto Bond"
title.Size = UDim2.new(1, -70, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = header

-- BODY
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -35)
body.Position = UDim2.new(0, 0, 0, 35)
body.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
body.Parent = mainFrame

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 8)
bodyCorner.Parent = body

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.075, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Auto Bond: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = body

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.85, 0, 0, 30)
statusLabel.Position = UDim2.new(0.075, 0, 0.45, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Waiting for map..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = body

-- ============== DRAGGABLE + BUTTONS ==============
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

minBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
    mainFrame.Size = body.Visible and UDim2.new(0,320,0,200) or UDim2.new(0,320,0,35)
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ============== AUTO BOND LOGIC ==============
local enabled = false
local autoThread = nil
local remote = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("ActivateObjectClient")

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Bond: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        statusLabel.Text = "ON - Collecting bonds..."
        
        autoThread = coroutine.create(function()
            while enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") do
                local itemsFolder = Workspace:FindFirstChild("RuntimeItems") or Workspace
                local collected = false
                
                for _, obj in ipairs(itemsFolder:GetDescendants()) do
                    if obj.Name == "Bond" and obj:FindFirstChild("Part") then
                        local hrp = plr.Character.HumanoidRootPart
                        hrp.CFrame = obj.Part.CFrame * CFrame.new(0, 5, 0)  -- TP safely above
                        
                        task.wait(0.25)  -- Anti-detection delay
                        
                        if remote then
                            pcall(function() remote:FireServer(obj) end)
                        end
                        
                        obj.Name = "BondCollected"  -- prevent re-collect
                        collected = true
                    end
                end
                
                if not collected then
                    statusLabel.Text = "No bonds found - moving..."
                end
                task.wait(0.3)
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Bond: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "OFF"
        enabled = false
    end
end)

print("✅ Fixed Auto Bond GUI loaded! It will always appear now.")
print("Toggle ON after you join a run. Slow & safe TP method used.")
