--[[
    SHARK ELITE V5 - PROFESSIONAL EDITION
    Designed by Professional Standards
    Universal Mobile/PC Compatibility
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
    ESP = false, ESPColor = Color3.fromRGB(0, 210, 255),
    Aimbot = false,
    MenuVisible = true
}

local Connections = {}
local UIBlur = nil

-- ==========================================
-- 1. MODERN UI CONSTRUCTION
-- ==========================================

local SharkUI = Instance.new("ScreenGui")
SharkUI.Name = "SharkElite_V5"
SharkUI.ResetOnSpawn = false
SharkUI.DisplayOrder = 100
local targetParent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
SharkUI.Parent = targetParent

-- Utility: Smooth Dragging
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then
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

-- Main Window
local MainFrame = Instance.new("CanvasGroup") -- Allows smooth transparency fades
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SharkUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 210, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6

-- Minimize Button (The Floating Square)
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 50, 0, 50)
RestoreBtn.Position = UDim2.new(0, 50, 0, 50)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
RestoreBtn.Text = "S"
RestoreBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 24
RestoreBtn.Visible = false
RestoreBtn.Parent = SharkUI
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RestoreBtn).Color = Color3.fromRGB(0, 210, 255)
MakeDraggable(RestoreBtn, RestoreBtn)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "SHARK ELITE <font color='#00d2ff'>V5</font>"
Title.RichText = true
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local CloseIcon = Instance.new("TextButton")
CloseIcon.Size = UDim2.new(0, 30, 0, 30)
CloseIcon.Position = UDim2.new(1, -40, 0, 7)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "—"
CloseIcon.TextColor3 = Color3.fromRGB(0, 210, 255)
CloseIcon.TextSize = 20
CloseIcon.Parent = Header

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 15, 20)
Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Container
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -140, 1, -55)
PageContainer.Position = UDim2.new(0, 135, 0, 50)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local Pages = {}
local function CreatePage(name)
    local f = Instance.new("ScrollingFrame", PageContainer)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 2
    f.ScrollBarImageColor3 = Color3.fromRGB(0, 210, 255)
    f.CanvasSize = UDim2.new(0,0,0,0)
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
-- 2. PROFESSIONAL COMPONENT FACTORY
-- ==========================================

local function CreateSlider(parent, text, min, max, default, callback)
    local SFrame = Instance.new("Frame", parent)
    SFrame.Size = UDim2.new(0.95, 0, 0, 50)
    SFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
    Instance.new("UICorner", SFrame)

    local Lab = Instance.new("TextLabel", SFrame)
    Lab.Text = "  " .. text .. ": " .. default
    Lab.Size = UDim2.new(1, 0, 0, 25)
    Lab.TextColor3 = Color3.new(0.8,0.8,0.8)
    Lab.Font = Enum.Font.Gotham
    Lab.TextXAlignment = Enum.TextXAlignment.Left
    Lab.BackgroundTransparency = 1

    local SliderBar = Instance.new("Frame", SFrame)
    SliderBar.Size = UDim2.new(0.85, 0, 0, 4)
    SliderBar.Position = UDim2.new(0.07, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 45, 55)

    local Fill = Instance.new("Frame", SliderBar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)

    local function Update(input)
        local size = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(size, 0, 1, 0)
        local val = math.floor(min + (size * (max - min)))
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
        end
    end)
end

local function CreateToggle(name, tabs, callback)
    local function AddTo(parent)
        local Container = Instance.new("Frame", parent)
        Container.Size = UDim2.new(0.95, 0, 0, 40)
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Container)
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
        Btn.Text = "  " .. name
        Btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", Btn)

        local Status = Instance.new("Frame", Btn)
        Status.Size = UDim2.new(0, 10, 0, 10)
        Status.Position = UDim2.new(1, -25, 0.5, -5)
        Status.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Instance.new("UICorner", Status).CornerRadius = UDim.new(1, 0)

        local Drop = Instance.new("Frame", Container)
        Drop.Size = UDim2.new(1, 0, 0, 0)
        Drop.Position = UDim2.new(0, 0, 0, 42)
        Drop.AutomaticSize = Enum.AutomaticSize.Y
        Drop.BackgroundTransparency = 1
        Drop.Visible = false
        Instance.new("UIListLayout", Drop).Padding = UDim.new(0, 5)

        Btn.MouseButton1Click:Connect(function()
            Config[name] = not Config[name]
            local active = Config[name]
            TweenService:Create(Status, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(50, 50, 50)}):Play()
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
-- 3. MODULE LOGIC
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
        bv.Name = "SharkDrive"
        Connections.Fly = RunService.RenderStepped:Connect(function()
            bv.Velocity = (Camera.CFrame.LookVector * hum.MoveDirection.Z * -Config.FlySpeed) + (Camera.CFrame.RightVector * hum.MoveDirection.X * Config.FlySpeed)
            hrp.Velocity = Vector3.new(0,0.1,0)
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.Humanoid.PlatformStand = false
            local b = char.HumanoidRootPart:FindFirstChild("SharkDrive")
            if b then b:Destroy() end
        end
    end
end)
CreateSlider(f1, "Fly Speed", 10, 300, 50, function(v) Config.FlySpeed = v end)
CreateSlider(f2, "Fly Speed", 10, 300, 50, function(v) Config.FlySpeed = v end)

-- SPEED
local s1, s2 = CreateToggle("Speed", {Movement}, function(active)
    if active then
        Connections.Speed = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame += (char.Humanoid.MoveDirection * (Config.WalkBoost/100))
            end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
    end
end)
CreateSlider(s1, "Speed Power", 10, 200, 50, function(v) Config.WalkBoost = v end)
CreateSlider(s2, "Speed Power", 10, 200, 50, function(v) Config.WalkBoost = v end)

-- NOCLIP
CreateToggle("Noclip", {Movement}, function(active)
    if active then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() end
    end
end)

-- ESP
local e1, e2 = CreateToggle("ESP", {Visuals}, function(active)
    if active then
        Connections.ESP = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                    h.FillColor = Config.ESPColor
                    h.OutlineTransparency = 0
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

local function AddColorPicker(p)
    local Grid = Instance.new("Frame", p)
    Grid.Size = UDim2.new(1, 0, 0, 35)
    Grid.BackgroundTransparency = 1
    local gl = Instance.new("UIListLayout", Grid)
    gl.FillDirection = Enum.FillDirection.Horizontal
    gl.Padding = UDim.new(0, 5)
    local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.fromRGB(0,210,255), Color3.new(1,1,1), Color3.new(1,0,1)}
    for _, c in pairs(colors) do
        local b = Instance.new("TextButton", Grid)
        b.Size = UDim2.new(0.18, 0, 1, 0)
        b.BackgroundColor3 = c
        b.Text = ""
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() Config.ESPColor = c end)
    end
end
AddColorPicker(e1); AddColorPicker(e2)

-- AIMBOT
CreateToggle("Aimbot", {Visuals}, function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target, dist = nil, 400
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mDist < dist then dist = mDist; target = p end
                    end
                end
            end
            if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    else
        if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    end
end)

-- ==========================================
-- 4. NAVIGATION & FINAL POLISH
-- ==========================================

local function SetupNav(name, page)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0, 110, 0, 35)
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

-- Toggle Menu Logic
local function ToggleUI(state)
    Config.MenuVisible = state
    if state then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()
        RestoreBtn.Visible = false
    else
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {GroupTransparency = 1})
        t:Play()
        t.Completed:Connect(function() 
            if not Config.MenuVisible then 
                MainFrame.Visible = false 
                RestoreBtn.Visible = true
            end 
        end)
    end
end

CloseIcon.MouseButton1Click:Connect(function() ToggleUI(false) end)
RestoreBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Insert then ToggleUI(not Config.MenuVisible) end
end)

MakeDraggable(MainFrame, Header)
print("SHARK ELITE V5 LOADED SUCCESSFULLY")
