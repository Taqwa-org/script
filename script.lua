-- Roblox Exploit GUI by Grok
-- Features: ESP, Full Bright, Noclip, Free Cam (Fly), Killaura
-- Fully draggable on PC (Mouse) + Mobile (Touch)
-- Minimize (-) collapses to header only | Close (X) destroys GUI
-- All toggles are ON/OFF with nice switch UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================== CREATE GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrokExploitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 60)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- ==================== HEADER ====================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GROK EXPLOIT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ==================== BODY (Scrolling) ====================
local Body = Instance.new("ScrollingFrame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -50)
Body.Position = UDim2.new(0, 0, 0, 50)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 6
Body.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.Parent = MainFrame

local BodyLayout = Instance.new("UIListLayout")
BodyLayout.Padding = UDim.new(0, 8)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Parent = Body

local BodyPadding = Instance.new("UIPadding")
BodyPadding.PaddingLeft = UDim.new(0, 10)
BodyPadding.PaddingRight = UDim.new(0, 10)
BodyPadding.PaddingTop = UDim.new(0, 10)
BodyPadding.Parent = Body

-- ==================== DRAG SYSTEM (PC + MOBILE) ====================
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Header.InputBegan:Connect(function(input)
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

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			updateDrag(input)
		end
	end
end)

-- ==================== MINIMIZE & CLOSE ====================
local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Body.Visible = false
		MainFrame.Size = UDim2.new(0, 320, 0, 50)
		MinimizeBtn.Text = "+"
	else
		Body.Visible = true
		MainFrame.Size = UDim2.new(0, 320, 0, 420)
		MinimizeBtn.Text = "-"
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- ==================== TOGGLE CREATOR ====================
local function CreateToggle(text, defaultState, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = Body
	
	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 10)
	ToggleCorner.Parent = ToggleFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.65, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextScaled = true
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	
	local Switch = Instance.new("Frame")
	Switch.Size = UDim2.new(0, 55, 0, 28)
	Switch.Position = UDim2.new(0.85, 0, 0.5, -14)
	Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Switch.Parent = ToggleFrame
	
	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = Switch
	
	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 24, 0, 24)
	Knob.Position = UDim2.new(0, 2, 0.5, -12)
	Knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	Knob.Parent = Switch
	
	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1, 0)
	KnobCorner.Parent = Knob
	
	local state = defaultState
	local function UpdateVisual()
		if state then
			Switch.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			Knob.Position = UDim2.new(1, -26, 0.5, -12)
		else
			Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Knob.Position = UDim2.new(0, 2, 0.5, -12)
		end
	end
	
	local ClickDetector = Instance.new("TextButton")
	ClickDetector.Size = UDim2.new(1, 0, 1, 0)
	ClickDetector.BackgroundTransparency = 1
	ClickDetector.Text = ""
	ClickDetector.Parent = ToggleFrame
	
	ClickDetector.MouseButton1Click:Connect(function()
		state = not state
		UpdateVisual()
		callback(state)
	end)
	
	UpdateVisual()
	if defaultState then callback(true) end
	
	return ToggleFrame
end

-- ==================== FEATURE LOGIC ====================

-- ESP
local highlights = {}
local espPlayerAddedConn = nil

local function AddESP(plr)
	if plr == player or not plr.Character then return end
	if highlights[plr] then return end
	
	local hl = Instance.new("Highlight")
	hl.Name = "GrokESP"
	hl.Adornee = plr.Character
	hl.FillColor = Color3.fromRGB(255, 50, 50)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.Parent = plr.Character
	highlights[plr] = hl
end

local function RemoveESP(plr)
	if highlights[plr] then
		highlights[plr]:Destroy()
		highlights[plr] = nil
	end
end

CreateToggle("ESP", false, function(enabled)
	if enabled then
		-- Current players
		for _, plr in ipairs(Players:GetPlayers()) do
			AddESP(plr)
		end
		-- New players
		espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function()
				AddESP(plr)
			end)
			if plr.Character then AddESP(plr) end
		end)
	else
		if espPlayerAddedConn then espPlayerAddedConn:Disconnect() end
		for plr, _ in pairs(highlights) do
			RemoveESP(plr)
		end
	end
end)

-- Full Bright
local fullBrightConn = nil
local originalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

CreateToggle("Full Bright", false, function(enabled)
	if enabled then
		fullBrightConn = RunService.RenderStepped:Connect(function()
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		end)
	else
		if fullBrightConn then fullBrightConn:Disconnect() end
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.GlobalShadows = originalLighting.GlobalShadows
		Lighting.Ambient = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
	end
end)

-- Noclip
local noclipConn = nil

CreateToggle("Noclip", false, function(enabled)
	if enabled then
		noclipConn = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		if player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end)

-- Free Cam (Simple Character Fly)
local flyConn = nil
local bodyVel = nil

CreateToggle("Free Cam", false, function(enabled)
	if enabled then
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
		
		local hrp = player.Character.HumanoidRootPart
		local hum = player.Character:FindFirstChild("Humanoid")
		
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(40000, 40000, 40000)
		bodyVel.Velocity = Vector3.new(0, 0, 0)
		bodyVel.Parent = hrp
		
		if hum then hum.PlatformStand = true end
		
		flyConn = RunService.RenderStepped:Connect(function()
			local move = Vector3.new()
			local speed = 80
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
			
			bodyVel.Velocity = move * speed
		end)
	else
		if flyConn then flyConn:Disconnect() end
		if bodyVel then bodyVel:Destroy() end
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.PlatformStand = false
		end
	end
end)

-- Killaura (Universal - prints + distance check; add your game remote here)
local killauraConn = nil

CreateToggle("Killaura", false, function(enabled)
	if enabled then
		killauraConn = RunService.Heartbeat:Connect(function()
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
			local myRoot = player.Character.HumanoidRootPart
			
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (plr.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
					if dist < 15 then
						-- PUT YOUR GAME-SPECIFIC KILL CODE HERE (e.g. remote:FireServer())
						print("Killaura hit: " .. plr.Name .. " (" .. math.floor(dist) .. " studs)")
						-- Example (won't work in most games): plr.Character.Humanoid.Health = 0
					end
				end
			end
		end)
	else
		if killauraConn then killauraConn:Disconnect() end
	end
end)

print("Grok Exploit GUI loaded! Drag the header to move. Works on mobile & PC.")
