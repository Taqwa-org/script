--[[
    SHARK ELITE V5 - PROFESSIONAL EDITION (REFINED)
    Refined & Enhanced Logic | Mobile & PC Universal
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration & State
local Config = {
    Fly = false, FlySpeed = 50,
    Speed = false, WalkBoost = 50,
    Noclip = false,
    ESP = false, 
    ESPR = 0, ESPG = 210, ESPB = 255, -- RGB Values
    ESPType = "Highlight", -- Highlight, Box, Hitbox
    Aimbot = false, AimSmoothing = 0.15,
    MenuVisible = true
}

local Connections = {}
local UIObjects = {}

-- ==========================================
-- 1. PROFESSIONAL UTILITIES
-- ==========================================

-- Cleanup Function (The "Kill" Logic)
local function KillScript()
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    -- Reset Player State
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("SharkFly") then hrp.SharkFly:Destroy() end
    end
    -- Clear Visuals
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("EliteHighlight") then p.Character.EliteHighlight:Destroy() end
            if p.Character:FindFirstChild("EliteBox") then p.Character.EliteBox:Destroy() end
        end
    end
    -- Destroy UI
    if UIObjects.MainGui then UIObjects.MainGui:Destroy() end
    print("SHARK ELITE V5: SCRIPT TERMINATED")
end

-- Smooth Universal Dragging
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- 2. UI CONSTRUCTION
-- ==========================================

local SharkUI = Instance.new("ScreenGui")
SharkUI.Name = "SharkElite_V5_Refined"
SharkUI.ResetOnSpawn = false
SharkUI.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
UIObjects.MainGui = SharkUI

-- Main Window
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 500, 0, 360)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SharkUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 210, 255)
MakeDraggable(MainFrame)

-- Minimized Icon
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 60, 0, 60)
RestoreBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
RestoreBtn.Text = "S"
RestoreBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 28
RestoreBtn.Visible = false
RestoreBtn.Parent = SharkUI
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RestoreBtn).Color = Color3.fromRGB(0, 210, 255)
MakeDraggable(RestoreBtn)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SHARK ELITE <font color='#00d2ff'>V5</font> | PROFESSIONAL"
Title.RichText = true
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Top Right Buttons (Minimize & Kill)
local BtnContainer = Instance.new("Frame", Header)
BtnContainer.Size = UDim2.new(0, 90, 1, 0)
BtnContainer.Position = UDim2.new(1, -95, 0, 0)
BtnContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", BtnContainer).FillDirection = Enum.FillDirection.Horizontal

local function CreateHeaderBtn(txt, color, callback)
    local b = Instance.new("TextButton", BtnContainer)
    b.Size = UDim2.new(0, 45, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = color
    b.TextSize = 20
    b.Font = Enum.Font.GothamBold
    b.MouseButton1Click:Connect(callback)
end

CreateHeaderBtn("—", Color3.new(0.8, 0.8, 0.8), function() 
    Config.MenuVisible = false
    MainFrame.Visible = false
    RestoreBtn.Visible = true
end)

CreateHeaderBtn("✕", Color3.new(1, 0.2, 0.2), KillScript)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Padding = UDim.new(0, 5)

-- Content
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -150, 1, -55)
PageContainer.Position = UDim2.new(0, 145, 0, 50)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local Pages = {}
local function CreatePage(name)
    local f = Instance.new("ScrollingFrame", PageContainer)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Color3.fromRGB(0, 210, 255)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 10)
    Pages[name] = f
    return f
end

local Home = CreatePage("Home")
local Movement = CreatePage("Movement")
local Visuals = CreatePage("Visuals")
Home.Visible = true

-- ==========================================
-- 3. COMPONENT FACTORY (MODERNIZED)
-- ==========================================

local function CreateSlider(parent, text, min, max, default, callback)
    local SFrame = Instance.new("Frame", parent)
    SFrame.Size = UDim2.new(0.95, 0, 0, 50)
    SFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 34)
    Instance.new("UICorner", SFrame)

    local Lab = Instance.new("TextLabel", SFrame)
    Lab.Text = "  " .. text .. ": " .. default
    Lab.Size = UDim2.new(1, 0, 0, 25)
    Lab.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Lab.Font = Enum.Font.Gotham
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.BackgroundTransparency = 1

    local SliderBar = Instance.new("Frame", SFrame)
    SliderBar.Size = UDim2.new(0.85, 0, 0, 6)
    SliderBar.Position = UDim2.new(0.07, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    Instance.new("UICorner", SliderBar)

    local Fill = Instance.new("Frame", SliderBar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
    Instance.new("UICorner", Fill)

    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        Lab.Text = "  " .. text .. ": " .. val
        callback(val)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then
            local move; move = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType.Touch then Update(i) end
            end)
            local release; release = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType.Touch then
                    move:Disconnect(); release:Disconnect()
                end
            end)
            Update(input)
        end
    end)
end

local function CreateToggle(name, tabs, callback)
    local function AddTo(parent)
        local Container = Instance.new("Frame", parent)
        Container.Size = UDim2.new(0.95, 0, 0, 42)
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        Btn.Text = "  " .. name
        Btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", Btn)

        local Status = Instance.new("Frame", Btn)
        Status.Size = UDim2.new(0, 12, 0, 12)
        Status.Position = UDim2.new(1, -25, 0.5, -6)
        Status.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Instance.new("UICorner", Status).CornerRadius = UDim.new(1, 0)

        local Drop = Instance.new("Frame", parent)
        Drop.Size = UDim2.new(1, 0, 0, 0)
        Drop.AutomaticSize = Enum.AutomaticSize.Y
        Drop.BackgroundTransparency = 1
        Drop.Visible = false
        Instance.new("UIListLayout", Drop).Padding = UDim.new(0, 5)

        Btn.MouseButton1Click:Connect(function()
            Config[name] = not Config[name]
            local active = Config[name]
            TweenService:Create(Status, TweenInfo.new(0.25), {BackgroundColor3 = active and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(60, 60, 60)}):Play()
            Btn.TextColor3 = active and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7)
            Drop.Visible = active
            callback(active)
        end)
        return Drop
    end

    local d1 = AddTo(Home)
    local d2; for _, t in pairs(tabs) do d2 = AddTo(t) end
    return d1, d2
end

-- ==========================================
-- 4. MODULE LOGIC
-- ==========================================

-- FLY
local f1, f2 = CreateToggle("Fly", {Movement}, function(active)
    if active then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
        bv.Name = "SharkFly"
        Connections.Fly = RunService.RenderStepped:Connect(function()
            bv.Velocity = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -Config.FlySpeed) + (Camera.CFrame.RightVector * hum.MoveDirection.X * Config.FlySpeed)
            hrp.Velocity = Vector3.zero
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            local b = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SharkFly")
            if b then b:Destroy() end
        end
    end
end)
CreateSlider(f1, "Fly Speed", 10, 300, 50, function(v) Config.FlySpeed = v end)

-- SPEED
local s1, s2 = CreateToggle("Speed", {Movement}, function(active)
    if active then
        Connections.Speed = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame += char.Humanoid.MoveDirection * (Config.WalkBoost/100)
            end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
    end
end)
CreateSlider(s1, "Speed Power", 10, 200, 50, function(v) Config.WalkBoost = v end)

-- ESP REWORK (Box, Hitbox, Highlight + RGB)
local e1, e2 = CreateToggle("ESP", {Visuals}, function(active)
    if active then
        Connections.ESP = RunService.Heartbeat:Connect(function()
            local color = Color3.fromRGB(Config.ESPR, Config.ESPG, Config.ESPB)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    -- Reset existing
                    if p.Character:FindFirstChild("EliteHighlight") then p.Character.EliteHighlight:Destroy() end
                    if p.Character:FindFirstChild("EliteBox") then p.Character.EliteBox:Destroy() end
                    
                    if Config.ESPType == "Highlight" then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "EliteHighlight"
                        h.FillColor = color
                        h.OutlineColor = Color3.new(1,1,1)
                    elseif Config.ESPType == "Box" then
                        local b = Instance.new("SelectionBox", p.Character)
                        b.Name = "EliteBox"
                        b.Adornee = p.Character
                        b.Color3 = color
                        b.LineThickness = 0.05
                    elseif Config.ESPType == "Hitbox" then
                        for _, v in pairs(p.Character:GetChildren()) do
                            if v:IsA("BasePart") then
                                v.Transparency = 0.5
                                v.Color = color
                            end
                        end
                    end
                end
            end
        end)
    else
        if Connections.ESP then Connections.ESP:Disconnect() end
        -- Comprehensive Cleanup
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("EliteHighlight") then p.Character.EliteHighlight:Destroy() end
                if p.Character:FindFirstChild("EliteBox") then p.Character.EliteBox:Destroy() end
                for _, v in pairs(p.Character:GetChildren()) do if v:IsA("BasePart") then v.Transparency = 0 end end
            end
        end
    end
end)

-- ESP Sub-Config
local function AddESPConfig(parent)
    -- ESP TYPE
    local ModeBtn = Instance.new("TextButton", parent)
    ModeBtn.Size = UDim2.new(0.95, 0, 0, 35)
    ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    ModeBtn.Text = "Cycle Mode: Highlight"
    ModeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", ModeBtn)
    
    local modes = {"Highlight", "Box", "Hitbox"}
    local curr = 1
    ModeBtn.MouseButton1Click:Connect(function()
        curr = curr >= #modes and 1 or curr + 1
        Config.ESPType = modes[curr]
        ModeBtn.Text = "Cycle Mode: " .. modes[curr]
    end)

    -- RGB SLIDERS
    CreateSlider(parent, "Red", 0, 255, 0, function(v) Config.ESPR = v end)
    CreateSlider(parent, "Green", 0, 255, 210, function(v) Config.ESPG = v end)
    CreateSlider(parent, "Blue", 0, 255, 255, function(v) Config.ESPB = v end)
end
AddESPConfig(e1); AddESPConfig(e2)

-- AIMBOT
local a1, a2 = CreateToggle("Aimbot", {Visuals}, function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target, dist = nil, 500
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if vis then
                            local mDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if mDist < dist then dist = mDist; target = p.Character.Head end
                        end
                    end
                end
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.AimSmoothing)
                end
            end
        end)
    else
        if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    end
end)
CreateSlider(a1, "Smoothing", 1, 100, 15, function(v) Config.AimSmoothing = v/100 end)

-- ==========================================
-- 5. FINAL SETUP
-- ==========================================

local function SetupNav(name, page)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0, 120, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    b.Text = name
    b.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then btn.TextColor3 = Color3.new(0.6,0.6,0.6) end
        end
        b.TextColor3 = Color3.fromRGB(0, 210, 255)
    end)
end

SetupNav("Home", Home)
SetupNav("Movement", Movement)
SetupNav("Visuals", Visuals)

RestoreBtn.MouseButton1Click:Connect(function()
    Config.MenuVisible = true
    MainFrame.Visible = true
    RestoreBtn.Visible = false
end)

print("SHARK ELITE V5 LOADED SUCCESSFULLY")
