--[[
    SHARK MENU V4 - ELITE EDITION
    Features: Minimize System, Dynamic Dropdowns, Persistent Config, ESP Color Picker
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration State (Persistent)
local SharkConfig = {
    Fly = false,
    FlySpeed = 50,
    Speed = false,
    WalkSpeedBoost = 0.5,
    Noclip = false,
    ESP = false,
    ESPColor = Color3.fromRGB(0, 180, 255),
    Aimbot = false
}

local Connections = {}

-- ==========================================
-- 1. CORE UI SETUP
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkElite"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Restore Button (The small square when minimized)
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 40, 0, 40)
RestoreBtn.Position = UDim2.new(0, 20, 0.5, -20)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
RestoreBtn.Text = "S"
RestoreBtn.TextColor3 = Color3.new(1, 1, 1)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 20
RestoreBtn.Visible = false
RestoreBtn.Parent = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 8)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel")
Title.Text = "  SHARK MENU V4"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0.5, -15)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "✕" 
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 8)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -125, 1, -55)
Content.Position = UDim2.new(0, 120, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Tabs = {}
local function CreateTab(name)
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.CanvasSize = UDim2.new(0,0,0,0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.ScrollBarThickness = 0
    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0, 8)
    Tabs[name] = f
    return f
end

local HomeTab = CreateTab("Home")
local MoveTab = CreateTab("Movement")
local VisTab = CreateTab("Visuals")
HomeTab.Visible = true

-- ==========================================
-- 2. HELPER FUNCTIONS (Sliders & Buttons)
-- ==========================================

local function CreateSlider(parent, label, min, max, default, callback)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", SliderFrame)

    local Title = Instance.new("TextLabel", SliderFrame)
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.Text = label .. ": " .. default
    Title.TextColor3 = Color3.new(0.8,0.8,0.8)
    Title.Font = Enum.Font.Gotham
    Title.BackgroundTransparency = 1

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(0.8, 0, 0, 4)
    Bar.Position = UDim2.new(0.1, 0, 0.7, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)

    local function Update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        Title.Text = label .. ": " .. val
        callback(val)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then
            local con; con = RunService.RenderStepped:Connect(function() Update(input) end)
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType.Touch then con:Disconnect() end
            end)
        end
    end)
end

local function CreateModule(name, tabs, callback)
    local function CreateEntry(parent)
        local Container = Instance.new("Frame", parent)
        Container.Size = UDim2.new(0.95, 0, 0, 40)
        Container.BackgroundTransparency = 1
        Container.AutomaticSize = Enum.AutomaticSize.Y

        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = SharkConfig[name] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 35)
        Btn.Text = name .. (SharkConfig[name] and ": ON" or ": OFF")
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.GothamSemibold
        Instance.new("UICorner", Btn)

        local Dropdown = Instance.new("Frame", Container)
        Dropdown.Size = UDim2.new(1, 0, 0, 0)
        Dropdown.Position = UDim2.new(0, 0, 0, 40)
        Dropdown.AutomaticSize = Enum.AutomaticSize.Y
        Dropdown.BackgroundTransparency = 1
        Dropdown.Visible = SharkConfig[name]
        Instance.new("UIListLayout", Dropdown).Padding = UDim.new(0, 5)

        Btn.MouseButton1Click:Connect(function()
            SharkConfig[name] = not SharkConfig[name]
            Btn.Text = name .. (SharkConfig[name] and ": ON" or ": OFF")
            Btn.BackgroundColor3 = SharkConfig[name] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 35)
            Dropdown.Visible = SharkConfig[name]
            callback(SharkConfig[name])
        end)

        return Dropdown
    end

    local d1 = CreateEntry(HomeTab)
    local d2 = nil
    for _, tab in pairs(tabs) do d2 = CreateEntry(tab) end
    return d1, d2
end

-- ==========================================
-- 3. MODULE IMPLEMENTATION
-- ==========================================

-- SPEED
local s1, s2 = CreateModule("Speed", {MoveTab}, function(active)
    if active then
        Connections.Speed = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * SharkConfig.WalkSpeedBoost)
            end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
    end
end)
CreateSlider(s1, "Intensity", 1, 10, 5, function(v) SharkConfig.WalkSpeedBoost = v/10 end)
CreateSlider(s2, "Intensity", 1, 10, 5, function(v) SharkConfig.WalkSpeedBoost = v/10 end)

-- FLY
local f1, f2 = CreateModule("Fly", {MoveTab}, function(active)
    if active then
        local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:WaitForChild("Humanoid")
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Name = "SharkFly"
        Connections.Fly = RunService.RenderStepped:Connect(function()
            bv.Velocity = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -SharkConfig.FlySpeed) + (Camera.CFrame.RightVector * hum.MoveDirection.X * SharkConfig.FlySpeed)
            hrp.Velocity = Vector3.new(0,0.1,0)
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            char.Humanoid.PlatformStand = false
            if char.HumanoidRootPart:FindFirstChild("SharkFly") then char.HumanoidRootPart.SharkFly:Destroy() end
        end
    end
end)
CreateSlider(f1, "Fly Speed", 10, 200, 50, function(v) SharkConfig.FlySpeed = v end)
CreateSlider(f2, "Fly Speed", 10, 200, 50, function(v) SharkConfig.FlySpeed = v end)

-- ESP & COLOR DROPDOWN
local e1, e2 = CreateModule("ESP", {VisTab}, function(active)
    if active then
        Connections.ESP = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                    hl.FillColor = SharkConfig.ESPColor
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

local function CreateColorPicker(parent)
    local ColorFrame = Instance.new("Frame", parent)
    ColorFrame.Size = UDim2.new(1, 0, 0, 30)
    ColorFrame.BackgroundTransparency = 1
    local l = Instance.new("UIListLayout", ColorFrame)
    l.FillDirection = Enum.FillDirection.Horizontal
    l.Padding = UDim.new(0, 5)

    local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0.7,1), Color3.new(1,1,1), Color3.new(1,1,0)}
    for _, col in pairs(colors) do
        local cbtn = Instance.new("TextButton", ColorFrame)
        cbtn.Size = UDim2.new(0.18, 0, 1, 0)
        cbtn.BackgroundColor3 = col
        cbtn.Text = ""
        Instance.new("UICorner", cbtn)
        cbtn.MouseButton1Click:Connect(function() SharkConfig.ESPColor = col end)
    end
end
CreateColorPicker(e1)
CreateColorPicker(e2)

-- NOCLIP & AIMBOT (Standard)
CreateModule("Noclip", {MoveTab}, function(active)
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

CreateModule("Aimbot", {VisTab}, function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target, dist = nil, 500
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < dist then dist = mag; target = p end
                    end
                end
            end
            if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    elseif Connections.Aimbot then Connections.Aimbot:Disconnect() end
end)

-- ==========================================
-- 4. MINIMIZE & DRAG LOGIC
-- ==========================================

local function ToggleMenu(visible)
    MainFrame.Visible = visible
    RestoreBtn.Visible = not visible
end

MinimizeBtn.MouseButton1Click:Connect(function() ToggleMenu(false) end)
RestoreBtn.MouseButton1Click:Connect(function() ToggleMenu(true) end)

-- Universal Dragging for MainFrame and RestoreBtn
local function MakeDraggable(obj)
    local dragStart, startPos, dragging
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then dragging = false end
    end)
end

MakeDraggable(Header)
MakeDraggable(RestoreBtn)

-- Sidebar Navigation
local function SetupNav(name, tab)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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

-- Toggle with Insert key
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Insert then ToggleMenu(not MainFrame.Visible) end
end)

print("SHARK V4 Loaded. Use 'S' button to restore menu.")
