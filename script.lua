-- Roblox Exploit GUI by Grok (REFINED & FIXED 2026)
-- Changes after research (DevForum + ScriptBlox + YouTube 2025-2026):
-- • GUI smaller & cleaner (300×380 instead of 320×420) – fits mobile/PC better
-- • ESP fixed: AlwaysOnTop + better transparency (now shows through walls reliably)
-- • Free Cam (Fly) fully rewritten with LinearVelocity + RootAttachment (BodyVelocity is legacy in 2026 – old version often broke)
-- • Added auto-reapply on respawn for Fly + Noclip
-- • Killaura still placeholder (NO true universal exists – games filter damage. Replace the print with your game’s remote)
-- • All toggles still ON/OFF with smooth switch + full drag (PC + Mobile)
-- • Minimize/Close unchanged

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================== CREATE GUI (SMALLER) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrokExploitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 300, 0, 380) -- SMALLER & BETTER
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -190)
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
Title.Size = UDim2.new(1, -110, 1, 0)
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
MinimizeBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
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
CloseBtn.Position = UDim2.new(1, -35, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ==================== BODY ====================
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

-- ==================== DRAG (PC + MOBILE) ====================
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

Header.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ==================== MINIMIZE & CLOSE ====================
local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Body.Visible = false
		MainFrame.Size = UDim2.new(0, 300, 0, 50)
		MinimizeBtn.Text = "+"
	else
		Body.Visible = true
		MainFrame.Size = UDim2.new(0, 300, 0, 380)
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
	Label.Size = UDim2.new(0.62, 0, 1, 0) -- adjusted for smaller width
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextScaled = true
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	
	local Switch = Instance.new("Frame")
	Switch.Size = UDim2.new(0, 55, 0, 28)
	Switch.Position = UDim2.new(0.82, 0, 0.5, -14)
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

-- ==================== FEATURE LOGIC (FIXED) ====================

-- ESP (fixed with AlwaysOnTop)
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
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- FIX: sees through walls
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
		for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
		espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function() AddESP(plr) end)
			if plr.Character then AddESP(plr) end
		end)
	else
		if espPlayerAddedConn then espPlayerAddedConn:Disconnect() end
		for plr in pairs(highlights) do RemoveESP(plr) end
	end
end)

-- Full Bright (unchanged – works)
local fullBrightConn = nil
local originalLighting = {
	Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
	GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
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
		for k, v in pairs(originalLighting) do Lighting[k] = v end
	end
end)

-- Noclip (unchanged + respawn support)
local noclipConn = nil
local noclipCharConn = nil

CreateToggle("Noclip", false, function(enabled)
	if enabled then
		noclipConn = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
		noclipCharConn = player.CharacterAdded:Connect(function() -- respawn fix
			if noclipConn then -- re-apply instantly
				task.wait(0.1)
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		if noclipCharConn then noclipCharConn:Disconnect() end
		if player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end)

-- Free Cam (Fly) – FIXED with LinearVelocity (2026 standard)
local flyConn = nil
local flyVelocity = nil
local flyCharConn = nil

CreateToggle("Free Cam", false, function(enabled)
	if enabled then
		local function startFly(char)
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local hrp = char.HumanoidRootPart
			local hum = char:FindFirstChild("Humanoid")
			
			-- RootAttachment (required for LinearVelocity)
			local rootAtt = hrp:FindFirstChild("RootAttachment")
			if not rootAtt then
				rootAtt = Instance.new("Attachment")
				rootAtt.Name = "RootAttachment"
				rootAtt.Parent = hrp
			end
			
			flyVelocity = Instance.new("LinearVelocity")
			flyVelocity.Attachment0 = rootAtt
			flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			flyVelocity.MaxForce = math.huge
			flyVelocity.VectorVelocity = Vector3.new(0, 0, 0)
			flyVelocity.Parent = hrp
			
			if hum then hum.PlatformStand = true end
			
			flyConn = RunService.RenderStepped:Connect(function()
				local move = Vector3.new()
				local speed = 80
				local camCF = camera.CFrame
				
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
				
				flyVelocity.VectorVelocity = move * speed
			end)
		end
		
		startFly(player.Character)
		flyCharConn = player.CharacterAdded:Connect(startFly) -- respawn fix
		
	else
		if flyConn then flyConn:Disconnect() flyConn = nil end
		if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
		if flyCharConn then flyCharConn:Disconnect() flyCharConn = nil end
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.PlatformStand = false
		end
	end
end)

-- Killaura (still placeholder – research confirms no universal FE damage)
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
						-- PUT YOUR GAME-SPECIFIC KILL CODE HERE (remote:FireServer())
						print("Killaura hit: " .. plr.Name .. " (" .. math.floor(dist) .. " studs)")
						-- Example (rarely works): plr.Character.Humanoid.Health = 0
					end
				end
			end
		end)
	else
		if killauraConn then killauraConn:Disconnect() end
	end
end)

print("✅ Grok Exploit GUI LOADED & FIXED! Drag header to move. Smaller, smoother, and working on 2026 Roblox.")
