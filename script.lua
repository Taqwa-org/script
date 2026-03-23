-- Features:
-- ESP (Players, Mobs, NPCs, All Entities)
-- Full Bright
-- Noclip
-- Free Cam (Detached Camera, Locks Player, Mobile Friendly)
-- Killaura
-- Clock Widget 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled

-- ==================== CREATE GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkV1GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Shadow Layer
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "DropShadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, -170, 0.5, -215)
Shadow.Size = UDim2.new(0, 340, 0, 430)
Shadow.Image = "rbxassetid://4731308628" 
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(35, 35, 265, 265)
Shadow.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 400)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
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
Header.Active = true
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
Title.TextColor3 = Color3.fromRGB(0, 225, 217)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 28
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.Parent = Header

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
Body.CanvasSize = UDim2.new(0, 0, 0, 0) -- FIX: Removes massive default empty scrolling space
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.Active = true
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

-- ==================== DRAG LOGIC ====================
local function MakeDraggable(dragArea, moveTarget, shadowTarget)
	local dragging, dragInput, dragStart, startPos

	dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = moveTarget.Position
		end
	end)

	dragArea.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local dest = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			moveTarget.Position = dest
			if shadowTarget then
				shadowTarget.Position = UDim2.new(dest.X.Scale, dest.X.Offset - 15, dest.Y.Scale, dest.Y.Offset - 15)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

MakeDraggable(Header, MainFrame, Shadow)

-- ==================== MINIMIZE & CLOSE ====================
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 310, 0, 45) or UDim2.new(0, 310, 0, 400)
	local shadowSize = isMinimized and UDim2.new(0, 340, 0, 75) or UDim2.new(0, 340, 0, 430)
	
	TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = shadowSize}):Play()
end)

-- FIX: Removed GroupTransparency which was erroring and breaking the close script
CloseBtn.MouseButton1Click:Connect(function()
	local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 310, 0, 0)})
	TweenService:Create(Shadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
	t:Play()
	t.Completed:Wait()
	ScreenGui:Destroy()
end)

-- ==================== TOGGLE CREATOR ====================
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

	local ClickArea = Instance.new("TextButton")
	ClickArea.Size = UDim2.new(1, 0, 1, 0)
	ClickArea.BackgroundTransparency = 1
	ClickArea.Text = ""
	ClickArea.Parent = ToggleFrame

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

	ClickArea.MouseButton1Click:Connect(function()
		state = not state
		UpdateVisual()
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

-- ==================== FEATURES ====================

-- Universal Entity ESP
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
								hl.FillColor = Color3.fromRGB(0, 225, 217)
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

-- ==================== MOBILE COMPATIBLE FREECAM ====================
local fcConn, fcInput
local fcCFrame = camera.CFrame
local pitch, yaw = 0, 0

local mobileMoveFlags = {F=false, B=false, L=false, R=false, U=false, D=false}
local FreecamMobileGUI = nil

local function buildMobileControls()
	if not isMobile then return end
	FreecamMobileGUI = Instance.new("ScreenGui")
	FreecamMobileGUI.Name = "FreecamControls"
	FreecamMobileGUI.Parent = ScreenGui

	local function createBtn(text, pos, flag)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 55, 0, 55)
		btn.Position = pos
		btn.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
		btn.BackgroundTransparency = 0.4
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = text
		btn.Font = Enum.Font.GothamBlack
		btn.TextSize = 22
		btn.AutoButtonColor = false
		btn.Parent = FreecamMobileGUI

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(0, 225, 217)
		stroke.Thickness = 1
		stroke.Parent = btn

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				mobileMoveFlags[flag] = true
				btn.BackgroundColor3 = Color3.fromRGB(0, 225, 217)
				btn.TextColor3 = Color3.fromRGB(13, 15, 20)
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				mobileMoveFlags[flag] = false
				btn.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end)
	end

	-- D-Pad (Left Side)
	createBtn("W", UDim2.new(0, 85, 1, -190), "F")
	createBtn("S", UDim2.new(0, 85, 1, -70), "B")
	createBtn("A", UDim2.new(0, 20, 1, -130), "L")
	createBtn("D", UDim2.new(0, 150, 1, -130), "R")
	-- Elevations (Right Side)
	createBtn("UP", UDim2.new(1, -100, 1, -190), "U")
	createBtn("DN", UDim2.new(1, -100, 1, -70), "D")
end

CreateToggle("Free Cam", false, function(enabled)
	if enabled then
		camera.CameraType = Enum.CameraType.Scriptable
		fcCFrame = camera.CFrame
		pitch, yaw, _ = fcCFrame:ToEulerAnglesYXZ()
		
		-- FIX: Lock the player entirely by Anchoring their RootPart
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.Anchored = true
		end
		
		buildMobileControls()
		
		-- Handles Panning (Right Click for PC, Swiping anywhere on screen for Mobile)
		fcInput = UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if gameProcessed then return end 
			
			local isTouch = (input.UserInputType == Enum.UserInputType.Touch)
			local isMouse = (input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
			
			if isTouch or isMouse then
				if isMouse then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition end
				yaw = yaw - math.rad(input.Delta.X * 0.25)
				pitch = pitch - math.rad(input.Delta.Y * 0.25)
				pitch = math.clamp(pitch, -math.rad(89), math.rad(89))
				fcCFrame = CFrame.new(fcCFrame.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
			else
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
		end)

		-- Handles Camera Movement
		fcConn = RunService.RenderStepped:Connect(function(dt)
			local moveVector = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) or mobileMoveFlags.F then moveVector += Vector3.new(0, 0, -1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) or mobileMoveFlags.B then moveVector += Vector3.new(0, 0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) or mobileMoveFlags.L then moveVector += Vector3.new(-1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) or mobileMoveFlags.R then moveVector += Vector3.new(1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileMoveFlags.U then moveVector += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or mobileMoveFlags.D then moveVector += Vector3.new(0, -1, 0) end
			
			-- Move at speed of 50 studs/sec
			fcCFrame = fcCFrame * CFrame.new(moveVector * (50 * dt))
			camera.CFrame = fcCFrame
		end)
	else
		if fcConn then fcConn:Disconnect() end
		if fcInput then fcInput:Disconnect() end
		if FreecamMobileGUI then FreecamMobileGUI:Destroy() end
		
		for k, v in pairs(mobileMoveFlags) do mobileMoveFlags[k] = false end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		
		camera.CameraType = Enum.CameraType.Custom
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			camera.CameraSubject = player.Character.Humanoid
		end
		
		-- FIX: Unlock the player when Freecam is disabled
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.Anchored = false
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

-- CLOCK WIDGET 
local clockFrame = nil
local clockUpdate = nil

CreateToggle("Clock Widget", false, function(enabled)
	if enabled then
		clockFrame = Instance.new("Frame")
		clockFrame.Size = UDim2.new(0, 140, 0, 50)
		clockFrame.Position = UDim2.new(1, -155, 0, 70) 
		clockFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
		clockFrame.Active = true
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

		-- Allow user to drag widget
		MakeDraggable(clockFrame, clockFrame, nil)

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

print("Shark V1 (Bugs Resolved)")
