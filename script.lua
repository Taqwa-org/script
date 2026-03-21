--[[
    SHARK MENU V3 - UNIVERSAL (PC/MOBILE)
    Tabs: Home, Movement, Visuals
    Modules: Fly, Speed, Noclip, ESP, Aimbot
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- State Management
local Toggles = {Fly = false, Speed = false, ESP = false, Aimbot = false, Noclip = false}
local Connections = {}
local flySpeed, speedValue = 50, 0.5

-- ==========================================
-- 1. GUI ENGINE (Mobile Compatible Dragging)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkMobile"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Frame (Smaller: 380x250)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 380, 0, 250)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel")
Title.Text = "  SHARK MENU"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- X Icon Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕" -- Clean X Icon
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

-- Mobile Toggle Button (Floating)
local MobileToggle = Instance.new("TextButton")
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0, 10, 0.5, 0)
MobileToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
MobileToggle.Text = "S"
MobileToggle.TextColor3 = Color3.new(1,1,1)
MobileToggle.Visible = false -- Only show if needed
MobileToggle.Parent = ScreenGui
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -110, 1, -45)
Content.Position = UDim2.new(0, 105, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Tabs = {}
local function CreateTab(name)
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.CanvasSize = UDim2.new(0,0,2,0)
    f.ScrollBarThickness = 0
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    Tabs[name] = f
    return f
end

local HomeTab = CreateTab("Home")
local MoveTab = CreateTab("Movement")
local VisTab = CreateTab("Visuals")
HomeTab.Visible = true

-- ==========================================
-- 2. DRAG SCRIPT (Universal)
-- ==========================================
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then dragging = false end
end)

-- ==========================================
-- 3. MODULE COMPONENTS
-- ==========================================

local function CreateModule(name, tabList, callback)
    local function makeButton(parent)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.Text = name .. ": OFF"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        Instance.new("UICorner", b)
        
        b.MouseButton1Click:Connect(function()
            Toggles[name] = not Toggles[name]
            b.Text = name .. ": " .. (Toggles[name] and "ON" or "OFF")
            b.BackgroundColor3 = Toggles[name] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 45)
            callback(Toggles[name])
        end)
    end

    makeButton(HomeTab) -- Add to home
    for _, tab in pairs(tabList) do makeButton(tab) end
end

-- ==========================================
-- 4. MODULE LOGIC
-- ==========================================

-- FLY
CreateModule("Fly", {MoveTab}, function(active)
    if active then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "SharkFly"
        
        Connections.Fly = RunService.RenderStepped:Connect(function()
            bv.Velocity = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -flySpeed) + (Camera.CFrame.RightVector * hum.MoveDirection.X * flySpeed)
            hrp.Velocity = Vector3.new(0,0.1,0)
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("SharkFly") then hrp.SharkFly:Destroy() end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end
end)

-- SPEED
CreateModule("Speed", {MoveTab}, function(active)
    if active then
        Connections.Speed = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * speedValue)
            end
        end)
    elseif Connections.Speed then Connections.Speed:Disconnect() end
end)

-- NOCLIP (Wallthrough)
CreateModule("Noclip", {MoveTab}, function(active)
    if active then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    elseif Connections.Noclip then Connections.Noclip:Disconnect() end
end)

-- ESP
CreateModule("ESP", {VisTab}, function(active)
    if active then
        Connections.ESP = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.FillColor = Color3.fromRGB(0, 180, 255)
                end
            end
        end)
    else
        if Connections.ESP then Connections.ESP:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
        end
    end
end)

-- AIMBOT
CreateModule("Aimbot", {VisTab}, function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target, closestDist = nil, 500
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < closestDist then closestDist = mag; target = p end
                    end
                end
            end
            if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    elseif Connections.Aimbot then Connections.Aimbot:Disconnect() end
end)

-- ==========================================
-- 5. NAVIGATION & TOGGLES
-- ==========================================

local function SetupNav(name, tab)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = name
    b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        tab.Visible = true
    end)
end

SetupNav("Home", HomeTab)
SetupNav("Movement", MoveTab)
SetupNav("Visuals", VisTab)

-- Close Button logic
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Keybind Toggle
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
end)

print("SHARK Loaded. Compatible with PC and Mobile executors.")
