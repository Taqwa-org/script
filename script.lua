-- ==========================================
-- SHARK MENU V2 (Compact & Loaded)
-- Toggle: INSERT | Close: X Button
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- State Variables
local States = {
    Fly = false,
    Speed = false,
    ESP = false,
    Aimbot = false,
    Noclip = false
}

local Connections = {}
local Highlights = {}
local flySpeed, speedValue = 50, 50

-- ==========================================
-- 1. GUI SETUP (Compact Size: 400x280)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkV2"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 280)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Header.Parent = MainFrame
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel")
Title.Text = "  SHARK"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content
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
    f.ScrollBarThickness = 2
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
    Tabs[name] = f
    return f
end

local Home = CreateTab("Home")
local Movement = CreateTab("Movement")
local Visuals = CreateTab("Visuals")
Home.Visible = true

-- ==========================================
-- 2. MODULE LOGIC
-- ==========================================

local function GetClosestPlayer()
    local target, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < dist then dist = mag target = p end
            end
        end
    end
    return target
end

local function ToggleFeature(name, callback)
    -- Create button for specific tab and for Home
    local function makeBtn(parent)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0.9, 0, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        b.Text = name .. ": OFF"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        Instance.new("UICorner", b)
        
        b.MouseButton1Click:Connect(function()
            States[name] = not States[name]
            local active = States[name]
            b.Text = name .. ": " .. (active and "ON" or "OFF")
            b.BackgroundColor3 = active and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(40, 40, 45)
            callback(active)
        end)
    end
    
    makeBtn(Home) -- Every feature goes to Home
    if name == "Fly" or name == "Speed" or name == "Noclip" then makeBtn(Movement) end
    if name == "ESP" or name == "Aimbot" then makeBtn(Visuals) end
end

-- ==========================================
-- 3. INITIALIZE MODULES
-- ==========================================

-- FLY
ToggleFeature("Fly", function(active)
    if active then
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        Connections.Fly = RunService.RenderStepped:Connect(function()
            bv.Velocity = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -flySpeed) + (Camera.CFrame.RightVector * hum.MoveDirection.X * flySpeed)
            hrp.Velocity = Vector3.new(0,0.1,0)
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            char.Humanoid.PlatformStand = false
            if char.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") then char.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity"):Destroy() end
        end
    end
end)

-- SPEED (Anti-Rubberband)
ToggleFeature("Speed", function(active)
    if active then
        Connections.Speed = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * (speedValue/100))
            end
        end)
    elseif Connections.Speed then Connections.Speed:Disconnect() end
end)

-- NOCLIP
ToggleFeature("Noclip", function(active)
    if active then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif Connections.Noclip then Connections.Noclip:Disconnect() end
end)

-- ESP
ToggleFeature("ESP", function(active)
    if active then
        Connections.ESP = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
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
ToggleFeature("Aimbot", function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target = GetClosestPlayer()
            if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    elseif Connections.Aimbot then Connections.Aimbot:Disconnect() end
end)

-- ==========================================
-- 4. SIDEBAR & MENU NAV
-- ==========================================
local function SetupSideBtn(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.8, 0, 0, 30)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    b.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        Tabs[name].Visible = true
    end)
end

SetupSideBtn("Home")
SetupSideBtn("Movement")
SetupSideBtn("Visuals")

-- Close/Hide logic
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
end)
