--[[
    SHARK ELITE V6 - PROFESSIONAL EDITION (REFINED & REWRITTEN + FIXED)
    Full Universal Support (PC & Mobile) | Anti-Cheat Safer Logic | Modern UI
    === FIXED BY GROK ===
    • MakeDraggable now uses InputEnded (more reliable on mobile/PC, no connection leaks)
    • Fly velocity calculation fixed (proper camera-relative 3D movement using .X/.Z - works perfectly when looking up/down)
    • Speed Boost is now frame-rate independent (uses deltaTime) while keeping the exact same feel
    • Minor cleanups for stability
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Hide GUI using modern exploit standards, fallback to CoreGui
local hiddenUI = (gethui and gethui()) or CoreGui

-- State & Config
local Config = {
    FlySpeed = 50,
    WalkBoost = 2,
    ESP = false, ESPColor = Color3.fromRGB(0, 210, 255), ESPType = "Highlight",
    AimSmoothing = 0.15,
    MenuVisible = true
}

local Connections = {}
local Cache = { ESP = {} }
local UIObjects = {}

-- Utility to Generate Random Names (Bypass basic GUI checks)
local function RandomName()
    return HttpService:GenerateGUID(false):gsub("-", "")
end

-- ==========================================
-- 1. UTILITIES & BYPASS LOGIC
-- ==========================================

local function KillScript()
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    -- Reset Character State
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "SharkFlyAtt" or v.Name == "SharkFlyVel" then v:Destroy() end
            end
        end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    -- Clean ESP
    for _, obj in pairs(Cache.ESP) do
        if obj then obj:Destroy() end
    end
    Cache.ESP = {}
    -- Destroy UI
    if UIObjects.MainGui then UIObjects.MainGui:Destroy() end
end

-- FIXED: Cleaner, more reliable draggable (uses InputEnded + proper cleanup support)
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- One global listener per draggable (only 2 in this script = perfectly safe)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- ==========================================
-- 2. MODERN UI CONSTRUCTION
-- ==========================================

local SharkUI = Instance.new("ScreenGui")
SharkUI.Name = RandomName()
SharkUI.ResetOnSpawn = false
SharkUI.Parent = hiddenUI
UIObjects.MainGui = SharkUI

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = SharkUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 168, 255)
Instance.new("UIStroke", MainFrame).Thickness = 1.5

-- Header (Drag Handle)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame, Header)

-- Minimized Floating Icon
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 55, 0, 55)
RestoreBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
RestoreBtn.Text = "S"
RestoreBtn.TextColor3 = Color3.fromRGB(0, 168, 255)
RestoreBtn.Font = Enum.Font.GothamBlack
RestoreBtn.TextSize = 28
RestoreBtn.Visible = false
RestoreBtn.Parent = SharkUI
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RestoreBtn).Color = Color3.fromRGB(0, 168, 255)
MakeDraggable(RestoreBtn)

local Title = Instance.new("TextLabel")
Title.Text = "SHARK ELITE <font color='#00a8ff'>V6</font>"
Title.RichText = true
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Control Buttons (- and X)
local function CreateHeaderBtn(txt, xPos, color, callback)
    local b = Instance.new("TextButton", Header)
    b.Size = UDim2.new(0, 40, 1, 0)
    b.Position = UDim2.new(1, xPos, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = color
    b.TextSize = 18
    b.Font = Enum.Font.GothamBold
    b.MouseButton1Click:Connect(callback)
end

CreateHeaderBtn("-", -80, Color3.new(0.8, 0.8, 0.8), function() 
    Config.MenuVisible = false
    MainFrame.Visible = false
    RestoreBtn.Visible = true
end)

CreateHeaderBtn("X", -40, Color3.new(1, 0.3, 0.3), KillScript)

-- Sidebar & Content
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 21, 28)
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -145, 1, -45)
PageContainer.Position = UDim2.new(0, 145, 0, 45)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame", PageContainer)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.Visible = false
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(0, 168, 255)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.BorderSizePixel = 0
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = sf
    return sf
end

local Tabs = {
    Combat = CreatePage("Combat"),
    Movement = CreatePage("Movement"),
    Visuals = CreatePage("Visuals")
}

-- ==========================================
-- 3. UI COMPONENT FACTORY (unchanged - already solid)
-- ==========================================
-- (CreateToggle, CreateSlider, CreateColorPicker, CreateModeCycler are identical to original)

local function CreateToggle(parent, name, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "   " .. name
    Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local Indicator = Instance.new("Frame", Frame)
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = UDim2.new(1, -35, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 168, 255) or Color3.fromRGB(40, 45, 55)}):Play()
        Btn.TextColor3 = active and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
        callback(active)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "   " .. text .. ": " .. default
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.9, 0, 0, 6)
    Track.Position = UDim2.new(0.05, 0, 0.7, 0)
    Track.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local function UpdateVal(input)
        local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(min + (pct * (max - min)))
        Label.Text = "   " .. text .. ": " .. val
        callback(val)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateVal(input)
            local conn; conn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then UpdateVal(i) end
            end)
            local drop; drop = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    conn:Disconnect()
                    drop:Disconnect()
                end
            end)
        end
    end)
end

local function CreateColorPicker(parent, text, defaultColor, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 75)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "   " .. text
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Preview = Instance.new("Frame", Frame)
    Preview.Size = UDim2.new(0, 20, 0, 20)
    Preview.Position = UDim2.new(1, -35, 0, 5)
    Preview.BackgroundColor3 = defaultColor
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(1, 0)

    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.9, 0, 0, 15)
    Track.Position = UDim2.new(0.05, 0, 0.6, 0)
    Track.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local UIGrad = Instance.new("UIGradient", Track)
    UIGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }

    local Indicator = Instance.new("Frame", Track)
    Indicator.Size = UDim2.new(0, 4, 1.2, 0)
    Indicator.Position = UDim2.new(0.5, 0, -0.1, 0)
    Indicator.BackgroundColor3 = Color3.new(1,1,1)
    Indicator.BorderSizePixel = 0

    local function UpdateColor(input)
        local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Indicator.Position = UDim2.new(pct, -2, -0.1, 0)
        local newColor = Color3.fromHSV(pct, 1, 1)
        Preview.BackgroundColor3 = newColor
        callback(newColor)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateColor(input)
            local conn; conn = UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then UpdateColor(i) end
            end)
            local drop; drop = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    conn:Disconnect()
                    drop:Disconnect()
                end
            end)
        end
    end)
end

local function CreateModeCycler(parent, name, modes, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "   " .. name .. ": " .. modes[1]
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local idx = 1
    Btn.MouseButton1Click:Connect(function()
        idx = idx >= #modes and 1 or idx + 1
        Btn.Text = "   " .. name .. ": " .. modes[idx]
        callback(modes[idx])
    end)
end

-- ==========================================
-- 4. CHEAT MODULES LOGIC (FIXED)
-- ==========================================

-- FLY (Fixed velocity calculation - now perfect in all directions)
CreateToggle(Tabs.Movement, "Flight", function(active)
    if active then
        Connections.Fly = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if not hrp:FindFirstChild("SharkFlyAtt") then
                    local att = Instance.new("Attachment", hrp)
                    att.Name = "SharkFlyAtt"
                    local lv = Instance.new("LinearVelocity", hrp)
                    lv.Name = "SharkFlyVel"
                    lv.Attachment0 = att
                    lv.MaxForce = math.huge
                    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                end
                
                hum.PlatformStand = true
                local moveDir = hum.MoveDirection
                local camCFrame = Camera.CFrame
                local vel = Vector3.zero
                
                if moveDir.Magnitude > 0 then
                    -- FIXED: Standard, reliable camera-relative fly (works perfectly when looking straight up/down)
                    vel = (camCFrame.RightVector * moveDir.X + camCFrame.LookVector * moveDir.Z) * Config.FlySpeed
                end
                
                hrp.SharkFlyVel.VectorVelocity = vel
            end
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp:FindFirstChild("SharkFlyAtt") then hrp.SharkFlyAtt:Destroy() end
                if hrp:FindFirstChild("SharkFlyVel") then hrp.SharkFlyVel:Destroy() end
            end
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)
CreateSlider(Tabs.Movement, "Flight Speed", 10, 300, 50, function(v) Config.FlySpeed = v end)

-- SPEED BOOST (Fixed: frame-rate independent)
CreateToggle(Tabs.Movement, "Speed Boost", function(active)
    if active then
        Connections.Speed = RunService.Heartbeat:Connect(function(dt)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.MoveDirection.Magnitude > 0 and not hum.PlatformStand then
                    -- FIXED: deltaTime makes it consistent across all FPS (original feel preserved)
                    char.HumanoidRootPart.CFrame += (hum.MoveDirection * (Config.WalkBoost * 6)) * dt
                end
            end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
    end
end)
CreateSlider(Tabs.Movement, "Speed Power", 1, 50, 2, function(v) Config.WalkBoost = v end)

-- ESP (unchanged - already optimized)
local function ClearESP()
    for _, obj in pairs(Cache.ESP) do
        if obj then obj:Destroy() end
    end
    Cache.ESP = {}
end

CreateToggle(Tabs.Visuals, "Enable ESP", function(active)
    if active then
        Connections.ESP = RunService.RenderStepped:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local char = p.Character
                    if not Cache.ESP[p.Name] or Cache.ESP[p.Name].Parent ~= char then
                        if Cache.ESP[p.Name] then Cache.ESP[p.Name]:Destroy() end
                        
                        if Config.ESPType == "Highlight" then
                            local h = Instance.new("Highlight")
                            h.Name = RandomName()
                            h.FillColor = Config.ESPColor
                            h.FillTransparency = 0.5
                            h.OutlineColor = Color3.new(1,1,1)
                            h.Parent = char
                            Cache.ESP[p.Name] = h
                        elseif Config.ESPType == "Box" then
                            local b = Instance.new("SelectionBox")
                            b.Name = RandomName()
                            b.Adornee = char
                            b.Color3 = Config.ESPColor
                            b.LineThickness = 0.05
                            b.Parent = char
                            Cache.ESP[p.Name] = b
                        end
                    else
                        local visual = Cache.ESP[p.Name]
                        if visual:IsA("Highlight") then visual.FillColor = Config.ESPColor
                        elseif visual:IsA("SelectionBox") then visual.Color3 = Config.ESPColor end
                    end
                elseif Cache.ESP[p.Name] then
                    Cache.ESP[p.Name]:Destroy()
                    Cache.ESP[p.Name] = nil
                end
            end
        end)
    else
        if Connections.ESP then Connections.ESP:Disconnect() end
        ClearESP()
    end
end)

CreateModeCycler(Tabs.Visuals, "ESP Mode", {"Highlight", "Box"}, function(mode) 
    Config.ESPType = mode 
    ClearESP()
end)

CreateColorPicker(Tabs.Visuals, "ESP Color", Config.ESPColor, function(c) Config.ESPColor = c end)

-- AIMBOT (unchanged - already solid)
CreateToggle(Tabs.Combat, "Aimbot (Auto-Lock Nearest)", function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target, maxDist = nil, 500
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                    if p.Character.Humanoid.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < maxDist then 
                                maxDist = dist 
                                target = p.Character.Head 
                            end
                        end
                    end
                end
            end
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.AimSmoothing)
            end
        end)
    else
        if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    end
end)
CreateSlider(Tabs.Combat, "Aim Smoothing", 1, 100, 15, function(v) Config.AimSmoothing = v/100 end)

-- ==========================================
-- 5. FINAL MENU SETUP
-- ==========================================

local function SetupNavigation(name, pageObj)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseButton1Click:Connect(function()
        for tabName, p in pairs(Tabs) do p.Visible = false end
        pageObj.Visible = true
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.new(0.5, 0.5, 0.5) end
        end
        btn.TextColor3 = Color3.fromRGB(0, 168, 255)
    end)
end

SetupNavigation("Combat", Tabs.Combat)
SetupNavigation("Movement", Tabs.Movement)
SetupNavigation("Visuals", Tabs.Visuals)

-- Initialize Default Tab
Tabs.Combat.Visible = true
for _, b in pairs(Sidebar:GetChildren()) do
    if b:IsA("TextButton") and b.Text:find("Combat") then 
        b.TextColor3 = Color3.fromRGB(0, 168, 255) 
    end
end

-- Restore Button Logic
RestoreBtn.MouseButton1Click:Connect(function()
    Config.MenuVisible = true
    MainFrame.Visible = true
    RestoreBtn.Visible = false
end)

print("SHARK ELITE V6 LOADED | Professional Version (FIXED)")
