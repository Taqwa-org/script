-- Features:
-- ESP (Players, Mobs, NPCs, All Entities)
-- Full Bright
-- Noclip
-- Free Cam
-- Killaura
-- Clock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================== CREATE GUI (GORGEOUS OVERHAUL) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkV1GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Shadow Layer (Adds depth)
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "DropShadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, -170, 0.5, -215)
Shadow.Size = UDim2.new(0, 340, 0, 430)
Shadow.Image = "rbxassetid://4731308628" -- Smooth drop shadow asset
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(35, 35, 265, 265)
Shadow.Parent = ScreenGui

-- Main Frame (Deep Ocean Theme)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 400)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 20) -- Deep midnight blue
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 45, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Topbar Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 28, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 15, 20))
}
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SHARK V1"
Title.TextColor3 = Color3.fromRGB(0, 225, 217) -- Neon Cyan
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Glow Effect for Title
local TitleGlow = Title:Clone()
TitleGlow.Name = "Glow"
TitleGlow.Position = UDim2.new(0, 0, 0, 0)
TitleGlow.ZIndex = Title.ZIndex - 1
TitleGlow.TextTransparency = 0.6
TitleGlow.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleGlow.Parent = Title
local TitleBlur = Instance.new("UIStroke")
TitleBlur.Color = Color3.fromRGB(0, 225, 217)
TitleBlur.Thickness = 2
TitleBlur.Transparency = 0.8
TitleBlur.Parent = TitleGlow

-- Window Controls (Mac Style)
local function createControlBtn(name, xPos, color, hoverColor)
	local Btn = Instance.new("TextButton")
	Btn.Name = name
	Btn.Size = UDim2.new(0, 14, 0, 14)
	Btn.Position = UDim2.new(1, xPos, 0.5, -7)
	Btn.BackgroundColor3 = color
	Btn.Text = ""
	Btn.AutoButtonColor = false
	Btn.Parent = Header
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1, 0)
	Corner.Parent = Btn
	
	-- Hover Animation
	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
	end)
	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end)
	
	return Btn
end

local MinimizeBtn = createControlBtn("Minimize", -55, Color3.fromRGB(245, 166, 35), Color3.fromRGB(255, 200, 80))
local CloseBtn = createControlBtn("Close", -30, Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 130, 120))

-- Divider Line
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 1, -1)
Divider.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
Divider.BorderSizePixel = 0
Divider.Parent = Header

-- Body (Scroll Frame)
local Body = Instance.new("ScrollingFrame")
Body.Size = UDim2.new(1, 0, 1, -45)
Body.Position = UDim2.new(0, 0, 0, 45)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = Color3.fromRGB(0, 225, 217)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.Parent = MainFrame

local BodyLayout = Instance.new("UIListLayout")
BodyLayout.Padding = UDim.new(0, 8)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
BodyLayout.Parent = Body

local BodyPadding = Instance.new("UIPadding")
BodyPadding.PaddingTop = UDim.new(0, 12)
BodyPadding.PaddingBottom = UDim.new(0, 12)
BodyPadding.Parent = Body

-- ==================== INTRO ANIMATION ====================
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.GroupTransparency = 1
Shadow.ImageTransparency = 1

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 310, 0, 400),
	GroupTransparency = 0
}):Play()
TweenService:Create(Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
	ImageTransparency = 0.4
}):Play()

-- ==================== DRAG LOGIC ====================
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
	end
end)
Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		Shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 15, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 15)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ==================== MINIMIZE & CLOSE ====================
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 310, 0, 45) or UDim2.new(0, 310, 0, 400)
	local shadowSize = isMinimized and UDim2.new(0, 340, 0, 75) or UDim2.new(0, 340, 0, 430)
	
	TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = shadowSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
	-- Exit Animation
	local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 250, 0, 320), GroupTransparency = 1})
	TweenService:Create(Shadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
	t:Play()
	t.Completed:Wait()
	ScreenGui:Destroy()
end)

-- ==================== GORGEOUS TOGGLE CREATOR ====================
local featureCallbacks = {} 

local function CreateToggle(text, defaultState, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(0.92, 0, 0, 48)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = Body

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 10)
	ToggleCorner.Parent = ToggleFrame

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Color = Color3.fromRGB(40, 50, 65)
	ToggleStroke.Thickness = 1
	ToggleStroke.Parent = ToggleFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.65, 0, 1, 0)
	Label.Position = UDim2.new(0.05, 0, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(220, 225, 240)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local SwitchBg = Instance.new("Frame")
	SwitchBg.Size = UDim2.new(0, 44, 0, 24)
	SwitchBg.Position = UDim2.new(1, -55, 0.5, -12)
	SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	SwitchBg.Parent = ToggleFrame

	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = SwitchBg

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 18, 0, 18)
	Knob.Position = UDim2.new(0, 3, 0.5, -9)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Knob.Parent = SwitchBg

	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1, 0)
	KnobCorner.Parent = Knob

	local KnobShadow = Instance.new("UIStroke")
	KnobShadow.Color = Color3.fromRGB(0, 0, 0)
	KnobShadow.Thickness = 1
	KnobShadow.Transparency = 0.8
	KnobShadow.Parent = Knob

	local ClickArea = Instance.new("TextButton")
	ClickArea.Size = UDim2.new(1, 0, 1, 0)
	ClickArea.BackgroundTransparency = 1
	ClickArea.Text = ""
	ClickArea.Parent = ToggleFrame

	-- Animations
	local state = defaultState
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function UpdateVisual()
		if state then
			TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 225, 217)}):Play()
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
			TweenService:Create(Label, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(ToggleStroke, tweenInfo, {Color = Color3.fromRGB(0, 120, 150)}):Play()
		else
			TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 40, 50)}):Play()
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
			TweenService:Create(Label, tweenInfo, {TextColor3 = Color3.fromRGB(180, 190, 205)}):Play()
			TweenService:Create(ToggleStroke, tweenInfo, {Color = Color3.fromRGB(40, 50, 65)}):Play()
		end
	end

	-- Hover effects
	ClickArea.MouseEnter:Connect(function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 33, 45)}):Play()
	end)
	ClickArea.MouseLeave:Connect(function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 26, 35)}):Play()
	end)

	ClickArea.MouseButton1Click:Connect(function()
		state = not state
		UpdateVisual()
		-- Pulse animation on click
		local pulse = TweenService:Create(ToggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0.9, 0, 0, 46)})
		pulse:Play()
		pulse.Completed:Wait()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(0.92, 0, 0, 48)}):Play()
		
		callback(state)
	end)

	UpdateVisual()
	if defaultState then callback(true) end

	featureCallbacks[text] = callback
	return ToggleFrame
end

-- ==================== AUTO CLEANUP ====================
ScreenGui.Destroying:Connect(function()
	for _, callback in pairs(featureCallbacks) do
		callback(false) 
	end
end)

-- ==================== FEATURES (UNCHANGED LOGIC) ====================

-- Universal Entity ESP (Players, Mobs, NPCs)
local espEnabled = false
local highlights = {}

CreateToggle("Entity ESP", false, function(enabled)
	espEnabled = enabled
	if enabled then
		task.spawn(function()
			while espEnabled do
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= player.Character then
						if not highlights[obj] then
							local hl = Instance.new("Highlight")
							hl.Adornee = obj
							
							if Players:GetPlayerFromCharacter(obj) then
								hl.FillColor = Color3.fromRGB(255, 60, 60)
							else
								hl.FillColor = Color3.fromRGB(0, 225, 217) -- Matches new theme
							end
							
							hl.OutlineColor = Color3.fromRGB(255, 255, 255)
							hl.FillTransparency = 0.4
							hl.OutlineTransparency = 0
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							hl.Parent = obj
							highlights[obj] = hl
						end
					end
				end
				
				for obj, hl in pairs(highlights) do
					if not obj or not obj.Parent or not obj:FindFirstChild("Humanoid") or obj:FindFirstChild("Humanoid").Health <= 0 then
						hl:Destroy()
						highlights[obj] = nil
					end
				end
				task.wait(1.5)
			end
		end)
	else
		for obj, hl in pairs(highlights) do
			if hl then hl:Destroy() end
		end
		table.clear(highlights)
	end
end)

-- Full Bright
local fbConn = nil
local originalLight = {Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient}

CreateToggle("Full Bright", false, function(enabled)
	if enabled then
		fbConn = RunService.RenderStepped:Connect(function()
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(255,255,255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
		end)
	else
		if fbConn then fbConn:Disconnect() end
		for k,v in pairs(originalLight) do Lighting[k] = v end
	end
end)

-- Noclip
local noclipConn = nil
local noclipRespawn = nil

CreateToggle("Noclip", false, function(enabled)
	if enabled then
		noclipConn = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
		noclipRespawn = player.CharacterAdded:Connect(function(char)
			task.wait(0.2)
			if enabled and char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		if noclipRespawn then noclipRespawn:Disconnect() end
		if player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end)

-- Free Cam
local flyConn = nil
local flyVelocity = nil
local flyRespawn = nil

CreateToggle("Free Cam", false, function(enabled)
	if enabled then
		local function startFlying(char)
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local hrp = char.HumanoidRootPart
			local hum = char:FindFirstChild("Humanoid")

			local att = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment")
			att.Name = "RootAttachment"
			att.Parent = hrp

			flyVelocity = Instance.new("LinearVelocity")
			flyVelocity.Attachment0 = att
			flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			flyVelocity.MaxForce = math.huge
			flyVelocity.VectorVelocity = Vector3.zero
			flyVelocity.Parent = hrp

			if hum then hum.PlatformStand = true end

			flyConn = RunService.RenderStepped:Connect(function()
				local humDir = (hum and hum.MoveDirection) or Vector3.zero
				local vertical = Vector3.zero

				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = vertical + Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = vertical - Vector3.new(0,1,0) end

				local totalMove = humDir + vertical
				flyVelocity.VectorVelocity = totalMove * 85
			end)
		end

		startFlying(player.Character)
		flyRespawn = player.CharacterAdded:Connect(startFlying)
	else
		if flyConn then flyConn:Disconnect() end
		if flyVelocity then flyVelocity:Destroy() end
		if flyRespawn then flyRespawn:Disconnect() end
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.PlatformStand = false
		end
	end
end)

-- Killaura
local auraConn = nil

CreateToggle("Killaura", false, function(enabled)
	if enabled then
		auraConn = RunService.Heartbeat:Connect(function()
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
			local root = player.Character.HumanoidRootPart
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
					if dist < 15 then
						-- ←←← PUT YOUR GAME REMOTE HERE
					end
				end
			end
		end)
	else
		if auraConn then auraConn:Disconnect() end
	end
end)

-- CLOCK (Overhauled Design)
local clockFrame = nil
local clockUpdate = nil

CreateToggle("Clock Widget", false, function(enabled)
	if enabled then
		clockFrame = Instance.new("Frame")
		clockFrame.Size = UDim2.new(0, 140, 0, 50)
		clockFrame.Position = UDim2.new(1, -155, 0, 15)
		clockFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
		clockFrame.Parent = ScreenGui

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 12)
		cCorner.Parent = clockFrame

		local cStroke = Instance.new("UIStroke")
		cStroke.Color = Color3.fromRGB(0, 225, 217)
		cStroke.Thickness = 1.5
		cStroke.Parent = clockFrame

		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(0.65, 0, 1, 0)
		timeLabel.Position = UDim2.new(0.08, 0, 0, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		timeLabel.TextSize = 18
		timeLabel.Font = Enum.Font.GothamBlack
		timeLabel.Text = "00:00"
		timeLabel.TextXAlignment = Enum.TextXAlignment.Left
		timeLabel.Parent = clockFrame

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0, 30, 0, 30)
		iconLabel.Position = UDim2.new(0.7, 0, 0.5, -15)
		iconLabel.BackgroundTransparency = 1
		iconLabel.TextSize = 20
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.Parent = clockFrame

		clockUpdate = RunService.Heartbeat:Connect(function()
			local t = os.date("*t")
			timeLabel.Text = string.format("%02d:%02d", t.hour, t.min)

			local ct = Lighting.ClockTime % 24
			if ct >= 6 and ct <= 18 then
				iconLabel.Text = "☀️"
				iconLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
			else
				iconLabel.Text = "🌙"
				iconLabel.TextColor3 = Color3.fromRGB(0, 225, 217)
			end
		end)
		
		-- Startup Widget Bounce
		clockFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(clockFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Size = UDim2.new(0, 140, 0, 50)}):Play()
	else
		if clockUpdate then clockUpdate:Disconnect() end
		if clockFrame then
			local t = TweenService:Create(clockFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
			t:Play()
			t.Completed:Wait()
			clockFrame:Destroy() 
			clockFrame = nil 
		end
	end
end)

print("Shark V1")
