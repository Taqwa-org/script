-- ==========================================
-- SHARK GUI - PREMIER EDUCATIONAL MENU
-- Features: Sidebar, Tabs, Anti-Rubberband
-- Toggle Key: INSERT
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- State Variables (Persistent)
local isFlying = false
local flySpeed = 50
local flyConnection = nil

local isESPEnabled = false
local espHighlights = {}

local isSpeedEnabled = false
local speedValue = 50
local speedConnection = nil

-- ==========================================
-- 1. GUI CONSTRUCTION
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Standard dragging
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner", MainFrame)
UICorner_Main.CornerRadius = UDim.new(0, 10)

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Header.Parent = MainFrame

local UICorner_Header = Instance.new("UICorner", Header)
local SharkLabel = Instance.new("TextLabel")
SharkLabel.Size = UDim2.new(0, 100, 1, 0)
SharkLabel.Position = UDim2.new(0, 15, 0, 0)
SharkLabel.BackgroundTransparency = 1
SharkLabel.Text = "SHARK"
SharkLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
SharkLabel.TextSize = 22
SharkLabel.Font = Enum.Font.GothamBold
SharkLabel.TextXAlignment = Enum.TextXAlignment.Left
SharkLabel.Parent = Header

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Padding = UDim.new(0, 5)

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -140, 1, -55)
TabContainer.Position = UDim2.new(0, 135, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Tab Frames
local Tabs = {}
local function CreateTab(name)
    local Frame = Instance.new("Frame")
    Frame.Name = name .. "Tab"
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Visible = false
    Frame.Parent = TabContainer
    
    local Layout = Instance.new("UIListLayout", Frame)
    Layout.Padding = UDim.new(0, 10)
    
    Tabs[name] = Frame
    return Frame
end

local HomeTab = CreateTab("Home")
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
HomeTab.Visible = true -- Default

-- ==========================================
-- 2. SIDEBAR LOGIC
-- ==========================================
local function SwitchTab(name)
    for i, v in pairs(Tabs) do
        v.Visible = (i == name)
    end
end

local function CreateSidebarBtn(text)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 110, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(text)
    end)
end

CreateSidebarBtn("Home")
CreateSidebarBtn("Movement")
CreateSidebarBtn("Visuals")

-- ==========================================
-- 3. COMPONENT HELPERS
-- ==========================================
local function CreateToggleButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 340, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.Parent = parent
    Instance.new("UICorner", Btn)

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = text .. ": " .. (active and "ON" or "OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(45, 45, 50)
        callback(active)
    end)
end

-- ==========================================
-- 4. FEATURES LOGIC (Anti-Rubberband)
-- ==========================================

-- HOME TAB CONTENT
local Welcome = Instance.new("TextLabel", HomeTab)
Welcome.Size = UDim2.new(1, 0, 0, 50)
Welcome.Text = "Welcome to Shark Menu\nPress [INSERT] to hide this menu."
Welcome.TextColor3 = Color3.fromRGB(200, 200, 200)
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.GothamItalic

-- MOVEMENT: SPEED
CreateToggleButton(MovementTab, "Enhanced Speed", function(state)
    isSpeedEnabled = state
    if isSpeedEnabled then
        speedConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                -- CFrame Offset prevents rubber-banding by bypassing walkspeed physics
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedValue / 150))
            end
        end)
    else
        if speedConnection then speedConnection:Disconnect() end
    end
end)

-- MOVEMENT: FLY
CreateToggleButton(MovementTab, "Flight Mode", function(state)
    isFlying = state
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if isFlying then
        hum.PlatformStand = true -- Stops leg physics stretching
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "SharkFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "SharkGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000

        flyConnection = RunService.RenderStepped:Connect(function()
            hum:ChangeState(Enum.HumanoidStateType.Physics) -- Anti-Rubberband state
            local camCF = Camera.CFrame
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                bv.Velocity = (camCF.LookVector * moveDir.Z * -flySpeed) + (camCF.RightVector * moveDir.X * flySpeed)
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = camCF
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if hrp:FindFirstChild("SharkFly") then hrp.SharkFly:Destroy() end
        if hrp:FindFirstChild("SharkGyro") then hrp.SharkGyro:Destroy() end
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- VISUALS: ESP
CreateToggleButton(VisualsTab, "Player Highlights", function(state)
    isESPEnabled = state
    
    local function addESP(p)
        if p == LocalPlayer then return end
        if p.Character then
            local hl = Instance.new("Highlight", p.Character)
            hl.FillColor = Color3.fromRGB(0, 170, 255)
            hl.OutlineColor = Color3.new(1, 1, 1)
            espHighlights[p] = hl
        end
    end

    if isESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
    else
        for p, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        table.clear(espHighlights)
    end
end)

-- ==========================================
-- 5. MENU TOGGLE (INSERT KEY)
-- ==========================================
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end
end)

-- Keep features working even when the GUI object is closed
-- We don't destroy() anything, we just hide the MainFrame. 
-- The logic stays active in the background.

print("Shark Menu Loaded. Press INSERT to toggle.")
