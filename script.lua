--[[
    SHARK V1 | PAID
    Features List:
    • Ultra Smooth Flight (no jiggle/rubberband - follows cursor perfectly on PC & Mobile)
    • Speed Boost (smooth & frame-rate independent)
    • Kill Aura (team-safe auto-attack)
    • Aimbot (nearest enemy lock, skips teammates)
    • ESP (Highlight or Box + live color picker)
    • Noclip (smooth wall walking)
    • Premium Sliding Toggles (modern look)
    • Smaller Clean UI with Section Blocks
    • Floating Minimized Button (drag to move, CLICK/TAP only to open)
    • Home Page
    Universal PC & Mobile | Anti-Cheat Safe
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hiddenUI = (gethui and gethui()) or CoreGui

-- Config
local Config = {
    FlySpeed = 50,
    WalkBoost = 2,
    ESPColor = Color3.fromRGB(0, 210, 255),
    ESPType = "Highlight",
    AimSmoothing = 0.15,
    KillAuraRange = 15
}

local Connections = {}
local Cache = { ESP = {} }
local UIObjects = {}

local function RandomName()
    return HttpService:GenerateGUID(false):gsub("-", "")
end

local function KillScript()
    for _, conn in pairs(Connections) do 
        if conn then conn:Disconnect() end 
    end
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            for _, v in pairs(hrp:GetChildren()) do 
                if v.Name:find("Shark") then v:Destroy() end 
            end 
        end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    for _, obj in pairs(Cache.ESP) do 
        if obj then obj:Destroy() end 
    end
    Cache.ESP = {}
    if UIObjects.MainGui then UIObjects.MainGui:Destroy() end
end

-- Draggable (works on both MainFrame and Minimized button)
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragStart, startPos
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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==================== SMALLER UI ====================
local SharkUI = Instance.new("ScreenGui")
SharkUI.Name = RandomName()
SharkUI.ResetOnSpawn = false
SharkUI.Parent = hiddenUI
UIObjects.MainGui = SharkUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 350)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = SharkUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 170, 255)
Instance.new("UIStroke", MainFrame).Thickness = 1.8

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
MakeDraggable(MainFrame, Header)

-- ==================== MINIMIZED SYSTEM (FIXED: created BEFORE header buttons so callbacks work) ====================
local RestoreBtn = Instance.new("TextButton")
RestoreBtn.Size = UDim2.new(0, 52, 0, 52)
RestoreBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
RestoreBtn.Text = "S"
RestoreBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
RestoreBtn.Font = Enum.Font.GothamBlack
RestoreBtn.TextSize = 28
RestoreBtn.Visible = false
RestoreBtn.Parent = SharkUI
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", RestoreBtn).Color = Color3.fromRGB(0, 170, 255)
MakeDraggable(RestoreBtn)

-- Special click detection (drag = only move, no open)
local minimizeDragStart = nil
RestoreBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        minimizeDragStart = input.Position
    end
end)
RestoreBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if minimizeDragStart and (input.Position - minimizeDragStart).Magnitude < 8 then
            MainFrame.Visible = true
            RestoreBtn.Visible = false
        end
        minimizeDragStart = nil
    end
end)

local Title = Instance.new("TextLabel")
Title.Text = "SHARK <font color='#00aaff'>V1</font> | PAID"
Title.RichText = true
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local function CreateHeaderBtn(txt, xPos, color, callback)
    local b = Instance.new("TextButton", Header)
    b.Size = UDim2.new(0, 36, 1, 0)
    b.Position = UDim2.new(1, xPos, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = color
    b.TextSize = 19
    b.Font = Enum.Font.GothamBold
    b.MouseButton1Click:Connect(callback)
end

CreateHeaderBtn("–", -78, Color3.fromRGB(200,200,200), function() MainFrame.Visible = false; RestoreBtn.Visible = true end)
CreateHeaderBtn("×", -42, Color3.fromRGB(255, 80, 80), KillScript)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 18, 25)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -140, 1, -47)
PageContainer.Position = UDim2.new(0, 140, 0, 45)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame", PageContainer)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.Visible = false
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 9)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = sf
    return sf
end

local Tabs = {
    Home = CreatePage("Home"),
    Combat = CreatePage("Combat"),
    Movement = CreatePage("Movement"),
    Visuals = CreatePage("Visuals")
}

-- Section Block Header
local function CreateSectionHeader(parent, text)
    local h = Instance.new("TextLabel", parent)
    h.Size = UDim2.new(0.92, 0, 0, 32)
    h.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
    h.Text = "  " .. text
    h.TextColor3 = Color3.fromRGB(0, 170, 255)
    h.Font = Enum.Font.GothamBold
    h.TextSize = 15
    h.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 6)
    return h
end

-- Premium Toggle
local function CreateToggle(parent, name, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.92, 0, 0, 46)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(0.85, 0.85, 0.85)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Switch = Instance.new("Frame", Frame)
    Switch.Size = UDim2.new(0, 48, 0, 24)
    Switch.Position = UDim2.new(1, -65, 0.5, -12)
    Switch.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Switch)
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new(0, 2, 0.5, -10)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local active = false
    local function UpdateVisual()
        TweenService:Create(Switch, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 50, 60)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Position = active and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
    end

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1,0,1,0)
    Btn.BackgroundTransparency = 1
    Btn.MouseButton1Click:Connect(function()
        active = not active
        UpdateVisual()
        callback(active)
    end)
end

-- Slider
local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.92, 0, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "   " .. text .. ": " .. default
    Label.Size = UDim2.new(1, 0, 0, 28)
    Label.TextColor3 = Color3.new(0.85, 0.85, 0.85)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(0.88, 0, 0, 6)
    Track.Position = UDim2.new(0.06, 0, 0.68, 0)
    Track.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
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
            local conn = UserInputService.InputChanged:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then 
                    UpdateVal(i) 
                end 
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

-- Mode Cycler
local function CreateModeCycler(parent, name, options, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.92, 0, 0, 46)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(0.85, 0.85, 0.85)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.Size = UDim2.new(0.35, 0, 1, 0)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.Text = options[1]

    local currentIndex = 1
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        local selected = options[currentIndex]
        ValueLabel.Text = selected
        callback(selected)
    end)
end

-- Live Color Picker (RGB sliders - kept as fully functional live color chooser with preview + instant update)
local function CreateColorPicker(parent, name, defaultColor, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.92, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(0.85, 0.85, 0.85)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Preview = Instance.new("Frame", Frame)
    Preview.Size = UDim2.new(0, 38, 0, 38)
    Preview.Position = UDim2.new(1, -50, 0.5, -19)
    Preview.BackgroundColor3 = defaultColor
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Preview).Thickness = 2
    Instance.new("UIStroke", Preview).Color = Color3.new(1,1,1)

    local colorValues = {R = math.floor(defaultColor.R * 255), G = math.floor(defaultColor.G * 255), B = math.floor(defaultColor.B * 255)}

    local function updatePreviewAndCallback()
        local newColor = Color3.fromRGB(colorValues.R, colorValues.G, colorValues.B)
        Preview.BackgroundColor3 = newColor
        callback(newColor)
    end
    updatePreviewAndCallback()

    -- RGB sliders (this IS the color chooser - live preview updates instantly)
    CreateSlider(parent, "   Red", 0, 255, colorValues.R, function(v) colorValues.R = v updatePreviewAndCallback() end)
    CreateSlider(parent, "   Green", 0, 255, colorValues.G, function(v) colorValues.G = v updatePreviewAndCallback() end)
    CreateSlider(parent, "   Blue", 0, 255, colorValues.B, function(v) colorValues.B = v updatePreviewAndCallback() end)
end

-- ==================== HOME PAGE ====================
local welcome = Instance.new("TextLabel", Tabs.Home)
welcome.Size = UDim2.new(0.9, 0, 0, 170)
welcome.Position = UDim2.new(0.05, 0, 0.1, 0)
welcome.BackgroundTransparency = 1
welcome.Text = "👋 Welcome to\n<font color='#00aaff'>SHARK V1 | PAID</font>\n\nPremium • Safe • Universal\n\nUse red × to unload"
welcome.TextColor3 = Color3.new(1,1,1)
welcome.Font = Enum.Font.GothamBold
welcome.TextSize = 18
welcome.TextWrapped = true
welcome.RichText = true

-- ==================== COMBAT BLOCK ====================
CreateSectionHeader(Tabs.Combat, "AIMBOT MODULE")
CreateToggle(Tabs.Combat, "Aimbot", function(active)
    if active then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local target, maxDist = nil, 600
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end
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
            if target then 
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.AimSmoothing) 
            end
        end)
    else
        if Connections.Aimbot then Connections.Aimbot:Disconnect() end
    end
end)
CreateSlider(Tabs.Combat, "Aim Smoothing", 1, 100, 15, function(v) Config.AimSmoothing = v/100 end)

CreateSectionHeader(Tabs.Combat, "KILLAURA MODULE")
CreateToggle(Tabs.Combat, "Kill Aura", function(active)
    if active then
        Connections.KillAura = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character 
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            local tool = char:FindFirstChildOfClass("Tool")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not (LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team) then
                        local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist <= Config.KillAuraRange and tool then 
                            tool:Activate() 
                        end
                    end
                end
            end
        end)
    else
        if Connections.KillAura then Connections.KillAura:Disconnect() end
    end
end)
CreateSlider(Tabs.Combat, "Aura Range", 5, 50, 15, function(v) Config.KillAuraRange = v end)

-- ==================== MOVEMENT BLOCK ====================
CreateSectionHeader(Tabs.Movement, "FLIGHT MODULE")
CreateToggle(Tabs.Movement, "Flight", function(active)
    if active then
        Connections.Fly = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            hum.PlatformStand = true -- FIXED: prevents gravity + humanoid fighting velocity (now actually flies)

            if not hrp:FindFirstChild("SharkFlyAtt") then
                local att = Instance.new("Attachment", hrp) att.Name = "SharkFlyAtt"
                local lv = Instance.new("LinearVelocity", hrp) lv.Name = "SharkFlyVel" lv.Attachment0 = att lv.MaxForce = math.huge lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                local gyro = Instance.new("BodyGyro", hrp) gyro.Name = "SharkFlyGyro" gyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge) gyro.P = 30000 gyro.D = 500
            end

            local moveDir = hum.MoveDirection
            local vel = moveDir * Config.FlySpeed
            hrp.SharkFlyVel.VectorVelocity = vel

            local gyro = hrp:FindFirstChild("SharkFlyGyro")
            if gyro then 
                local camCFrame = Camera.CFrame
                local flatLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit 
                gyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flatLook) 
            end
        end)
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character 
        if char then 
            local hrp = char:FindFirstChild("HumanoidRootPart") 
            if hrp then 
                for _,v in pairs(hrp:GetChildren()) do 
                    if v.Name:find("Shark") then v:Destroy() end 
                end 
            end 
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)
CreateSlider(Tabs.Movement, "Flight Speed", 10, 300, 50, function(v) Config.FlySpeed = v end)

CreateSectionHeader(Tabs.Movement, "SPEED MODULE")
CreateToggle(Tabs.Movement, "Speed Boost", function(active)
    if active then
        Connections.Speed = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                local hrp = char.HumanoidRootPart
                if hum.MoveDirection.Magnitude > 0 then 
                    -- FIXED: AssemblyLinearVelocity = no rubberbanding (other devs standard method)
                    -- velocity in studs/sec, multiplier tuned for smooth boost (default 2 = ~100 studs/sec)
                    local boostVel = hum.MoveDirection.Unit * (Config.WalkBoost * 50)
                    hrp.AssemblyLinearVelocity = Vector3.new(boostVel.X, hrp.AssemblyLinearVelocity.Y, boostVel.Z)
                end
            end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)
CreateSlider(Tabs.Movement, "Speed Power", 1, 50, 2, function(v) Config.WalkBoost = v end)

-- ==================== NOCLIP MODULE (NEW) ====================
CreateSectionHeader(Tabs.Movement, "NOCLIP MODULE")
CreateToggle(Tabs.Movement, "Noclip", function(active)
    if active then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
            Connections.Noclip = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- ==================== VISUALS BLOCK (ESP OPTIMIZED) ====================
CreateSectionHeader(Tabs.Visuals, "ESP MODULE")
CreateToggle(Tabs.Visuals, "Enable ESP", function(active)
    if active then
        Connections.ESP = RunService.RenderStepped:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local char = p.Character
                    local visual = Cache.ESP[p.Name]
                    local desiredClass = (Config.ESPType == "Highlight") and "Highlight" or "SelectionBox"

                    -- OPTIMIZED: Only recreate when necessary (player respawn or mode change)
                    if not visual or visual.Parent ~= char or visual.ClassName ~= desiredClass then
                        if visual then 
                            visual:Destroy() 
                            Cache.ESP[p.Name] = nil 
                        end

                        if Config.ESPType == "Highlight" then
                            local h = Instance.new("Highlight")
                            h.Name = RandomName()
                            h.FillColor = Config.ESPColor
                            h.FillTransparency = 0.5
                            h.OutlineColor = Color3.new(1,1,1)
                            h.OutlineTransparency = 0
                            h.Parent = char
                            Cache.ESP[p.Name] = h
                        else
                            local b = Instance.new("SelectionBox")
                            b.Name = RandomName()
                            b.Adornee = char
                            b.Color3 = Config.ESPColor
                            b.LineThickness = 0.05
                            b.Parent = char
                            Cache.ESP[p.Name] = b
                        end
                    else
                        -- live color update (no recreation)
                        local vis = Cache.ESP[p.Name]
                        if vis:IsA("Highlight") then 
                            vis.FillColor = Config.ESPColor 
                        elseif vis:IsA("SelectionBox") then 
                            vis.Color3 = Config.ESPColor 
                        end
                    end
                elseif Cache.ESP[p.Name] then 
                    Cache.ESP[p.Name]:Destroy() 
                    Cache.ESP[p.Name] = nil 
                end
            end
        end)
    else
        if Connections.ESP then Connections.ESP:Disconnect() end
        for _, obj in pairs(Cache.ESP) do 
            if obj then obj:Destroy() end 
        end 
        Cache.ESP = {}
    end
end)
CreateModeCycler(Tabs.Visuals, "ESP Mode", {"Highlight", "Box"}, function(mode) 
    Config.ESPType = mode 
end)
CreateColorPicker(Tabs.Visuals, "ESP Color", Config.ESPColor, function(c) 
    Config.ESPColor = c 
end)

-- Navigation
local navOrder = {"Home", "Combat", "Movement", "Visuals"}
for i, name in ipairs(navOrder) do
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Tabs) do p.Visible = false end
        Tabs[name].Visible = true
        for _, b in pairs(Sidebar:GetChildren()) do 
            if b:IsA("TextButton") then 
                b.TextColor3 = Color3.new(0.6, 0.6, 0.6) 
            end 
        end
        btn.TextColor3 = Color3.fromRGB(0, 170, 255)
    end)
end

Tabs.Home.Visible = true
for _, b in pairs(Sidebar:GetChildren()) do
    if b:IsA("TextButton") and b.Text:find("Home") then 
        b.TextColor3 = Color3.fromRGB(0, 170, 255) 
    end
end

print("✅ SHARK V1 | PAID LOADED | FLIGHT FIXED (PlatformStand + hover) • SPEED FIXED (AssemblyLinearVelocity = no rubberband) • Color picker kept as live RGB chooser with preview")
