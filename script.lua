-- ==========================================
-- EDUCATIONAL GUI SCRIPT (Fly, ESP, Speed)
-- Features: Drop-down UI, Sliders, Mobile-friendly
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State Variables
local isFlying = false
local flySpeed = 50
local flyConnection = nil

local isESPEnabled = false
local espHighlights = {}

local isSpeedEnabled = false
local speedValue = 50 -- Default speed boost
local speedConnection = nil

-- ==========================================
-- 1. GUI CREATION & LAYOUT
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EducationalMenu"
ScreenGui.ResetOnSpawn = false

-- Fallback to PlayerGui if CoreGui is blocked
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Draggable Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 250) -- Increased size to fit everything
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Top Bar (Holds Title and Close Button)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Edu Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Container for Buttons (Uses UIListLayout for auto-stacking)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Parent = ContentFrame

-- Helper function to create buttons
local function createButton(text, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 210, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.LayoutOrder = order
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.Parent = ContentFrame
    return Btn
end

local FlyBtn = createButton("Fly: OFF", 1)
local ESPBtn = createButton("ESP: OFF", 2)
local SpeedBtn = createButton("Speed: OFF", 3)

-- ==========================================
-- 2. SPEED METER (DROP-DOWN SLIDER)
-- ==========================================
local SpeedDropdown = Instance.new("Frame")
SpeedDropdown.Size = UDim2.new(0, 210, 0, 50)
SpeedDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SpeedDropdown.LayoutOrder = 4
SpeedDropdown.Visible = false -- Hidden by default
SpeedDropdown.Parent = ContentFrame
Instance.new("UICorner", SpeedDropdown).CornerRadius = UDim.new(0, 8)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Speed Boost: " .. speedValue
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.Font = Enum.Font.Gotham
SliderLabel.TextSize = 12
SliderLabel.Parent = SpeedDropdown

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(0, 180, 0, 10)
SliderBg.Position = UDim2.new(0.5, -90, 0, 25)
SliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SliderBg.Parent = SpeedDropdown
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- Starts at 50%
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, 0, 1, 0)
SliderBtn.BackgroundTransparency = 1
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg

-- ==========================================
-- 3. DRAGGING LOGIC (Main GUI)
-- ==========================================
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 4. SPEED METER SLIDER LOGIC
-- ==========================================
local sliderDragging = false

local function updateSlider(input)
    local minSpeed, maxSpeed = 16, 200 -- Standard walkspeed is 16
    local relativePos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    
    SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
    speedValue = math.floor(minSpeed + ((maxSpeed - minSpeed) * relativePos))
    SliderLabel.Text = "Speed Boost: " .. speedValue
    
    -- If speed is currently on, update the player's speed instantly
    if isSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
    end
end

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- ==========================================
-- 5. TOGGLE LOGIC
-- ==========================================

-- SPEED
SpeedBtn.MouseButton1Click:Connect(function()
    isSpeedEnabled = not isSpeedEnabled
    SpeedBtn.Text = "Speed: " .. (isSpeedEnabled and "ON" or "OFF")
    SpeedBtn.BackgroundColor3 = isSpeedEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 55)
    
    -- Open/Close Dropdown
    SpeedDropdown.Visible = isSpeedEnabled
    
    -- Adjust MainFrame size based on Dropdown visibility
    MainFrame.Size = isSpeedEnabled and UDim2.new(0, 250, 0, 310) or UDim2.new(0, 250, 0, 250)

    -- Apply Speed Logic
    if isSpeedEnabled then
        -- We use a loop because many games constantly try to reset your walkspeed back to 16
        speedConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = speedValue
            end
        end)
    else
        if speedConnection then speedConnection:Disconnect() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16 -- Reset to default
        end
    end
end)

-- FLY
FlyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    FlyBtn.Text = "Fly: " .. (isFlying and "ON" or "OFF")
    FlyBtn.BackgroundColor3 = isFlying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 55)

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if isFlying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "EduFlyPos"
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if humanoid and humanoid.Health > 0 then
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    bv.Velocity = Camera.CFrame.LookVector * (moveDir.Z * -flySpeed) + Camera.CFrame.RightVector * (moveDir.X * flySpeed)
                    bv.Velocity = Camera.CFrame.LookVector * flySpeed -- Mobile override
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if hrp:FindFirstChild("EduFlyPos") then hrp.EduFlyPos:Destroy() end
    end
end)

-- ESP
ESPBtn.MouseButton1Click:Connect(function()
    isESPEnabled = not isESPEnabled
    ESPBtn.Text = "ESP: " .. (isESPEnabled and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = isESPEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 55)

    local function applyESP(player)
        if player == LocalPlayer then return end
        if player.Character and not espHighlights[player] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = player.Character
            espHighlights[player] = hl
        end
    end

    if isESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    else
        for p, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
            espHighlights[p] = nil
        end
    end
end)

-- CLOSE BUTTON
CloseBtn.MouseButton1Click:Connect(function()
    if isFlying then FlyBtn.MouseButton1Click:Fire() end
    if isESPEnabled then ESPBtn.MouseButton1Click:Fire() end
    if isSpeedEnabled then SpeedBtn.MouseButton1Click:Fire() end
    ScreenGui:Destroy()
end)
