-- Dead Rails Auto Bond Script (Custom GUI + TP to Bonds)
-- Works by teleporting you to each Bond in Workspace.RuntimeItems
-- Collects via the game's official remote (safe & reliable method used by popular scripts)
-- Slow delays (0.25s per bond) to minimize detection risk from anti-cheat
-- ONLY for Dead Rails (in-game map). Tested structure from public scripts 2025-2026.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("ActivateObjectClient", 5)

if not remote then
    warn("Dead Rails remote not found - make sure you are in the in-game map!")
    return
end

-- ============== GUI CREATION ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsAutoBond"
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

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

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
header.BorderSizePixel = 0
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

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- BODY
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -35)
body.Position = UDim2.new(0, 0, 0, 35)
body.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
body.BorderSizePixel = 0
body.Parent = mainFrame

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 8)
bodyCorner.Parent = body

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0, 55)
toggleBtn.Position = UDim2.new(0.075, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Auto Bond: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = body

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- ============== DRAGGABLE ==============
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============== BUTTON FUNCTIONS ==============
local enabled = false
local autoThread = nil

minBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
    if body.Visible then
        mainFrame.Size = UDim2.new(0, 320, 0, 180)
    else
        mainFrame.Size = UDim2.new(0, 320, 0, 35)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Bond: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        autoThread = coroutine.create(function()
            while enabled do
                local itemsFolder = Workspace:FindFirstChild("RuntimeItems")
                if itemsFolder then
                    for _, bond in ipairs(itemsFolder:GetChildren()) do
                        if bond.Name == "Bond" and bond:FindFirstChild("Part") then
                            local char = plr.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local hrp = char.HumanoidRootPart
                                -- TP player directly to the bond (above it so you don't clip)
                                hrp.CFrame = bond.Part.CFrame * CFrame.new(0, 5, 0)
                            end
                            
                            task.wait(0.25) -- Safe delay (prevents fast-movement flags from anti-cheat)
                            
                            -- Collect using the exact remote other scripts use
                            pcall(function()
                                remote:FireServer(bond)
                            end)
                            
                            -- Mark as collected so we don't loop forever
                            bond.Name = "BondCollected"
                        end
                    end
                end
                task.wait(0.1) -- Small loop delay
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Bond: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        enabled = false
    end
end)

-- ============== AUTO CLEANUP ==============
plr.CharacterRemoving:Connect(function()
    if autoThread then
        enabled = false
    end
end)

print("Dead Rails Auto Bond GUI loaded! Toggle it on and let it TP + collect for you.")
