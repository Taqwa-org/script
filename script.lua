-- ==========================================
-- EDUCATIONAL GUI SCRIPT (Fly & ESP)
-- Compatible with Mobile/PC Executors
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables for toggles
local isFlying = false
local flySpeed = 50
local flyConnection = nil
local isESPEnabled = false
local espHighlights = {}

-- ==========================================
-- 1. GUI CREATION
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EducationalMenu"
ScreenGui.ResetOnSpawn = false

-- Try to put the GUI in CoreGui to hide it from the game, fallback to PlayerGui
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Edu Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0, 200, 0, 40)
FlyBtn.Position = UDim2.new(0.5, -100, 0, 60)
FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
FlyBtn.Text = "Fly: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.Font = Enum.Font.GothamSemibold
FlyBtn.TextSize = 16
FlyBtn.Parent = MainFrame

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 8)
FlyCorner.Parent = FlyBtn

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(0, 200, 0, 40)
ESPBtn.Position = UDim2.new(0.5, -100, 0, 115)
ESPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ESPBtn.Text = "ESP: OFF"
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.Font = Enum.Font.GothamSemibold
ESPBtn.TextSize = 16
ESPBtn.Parent = MainFrame

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 8)
ESPCorner.Parent = ESPBtn

-- ==========================================
-- 2. DRAGGING LOGIC (Mobile & PC)
-- ==========================================
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 3. FLY LOGIC (Mobile Friendly)
-- ==========================================
local function toggleFly()
    isFlying = not isFlying
    FlyBtn.Text = "Fly: " .. (isFlying and "ON" or "OFF")
    FlyBtn.BackgroundColor3 = isFlying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 55)

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if isFlying then
        -- Create a BodyVelocity object to control movement in the air
        local bv = Instance.new("BodyVelocity")
        bv.Name = "EduFlyPos"
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        -- Loop every frame to update velocity based on mobile joystick / WASD
        flyConnection = RunService.RenderStepped:Connect(function()
            if humanoid and humanoid.Health > 0 then
                -- MoveDirection reads the mobile joystick or WASD keys automatically
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- Fly in the direction the camera is looking
                    bv.Velocity = Camera.CFrame.LookVector * (moveDir.Z * -flySpeed) + Camera.CFrame.RightVector * (moveDir.X * flySpeed)
                    
                    -- Simple mobile fix: Just go where the camera looks if they touch the joystick
                    bv.Velocity = Camera.CFrame.LookVector * flySpeed
                else
                    bv.Velocity = Vector3.new(0, 0, 0) -- Hover in place
                end
            end
        end)
    else
        -- Cleanup flying
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if hrp:FindFirstChild("EduFlyPos") then
            hrp.EduFlyPos:Destroy()
        end
    end
end

FlyBtn.MouseButton1Click:Connect(toggleFly)

-- ==========================================
-- 4. ESP LOGIC (Highlights)
-- ==========================================
local function addESP(player)
    if player == LocalPlayer then return end
    if player.Character and not espHighlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "EduESP"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Makes it visible through walls
        highlight.Parent = player.Character
        espHighlights[player] = highlight
    end
end

local function removeESP(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end

local function toggleESP()
    isESPEnabled = not isESPEnabled
    ESPBtn.Text = "ESP: " .. (isESPEnabled and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = isESPEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 55)

    if isESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            addESP(player)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

ESPBtn.MouseButton1Click:Connect(toggleESP)

-- Handle players joining and respawning while ESP is on
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if isESPEnabled then
            task.wait(1) -- Wait for character to fully load
            addESP(player)
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        if isESPEnabled then
            task.wait(1)
            addESP(player)
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- ==========================================
-- 5. CLOSE & CLEANUP LOGIC
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    -- Turn off Fly
    if isFlying then toggleFly() end
    
    -- Turn off ESP
    if isESPEnabled then toggleESP() end
    
    -- Destroy GUI
    ScreenGui:Destroy()
end)
