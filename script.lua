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

-- ==================== CREATE GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkV1GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 400)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 80)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Gradient Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
}
HeaderGradient.Parent = Header

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SHARK V1"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize & Close
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
MinimizeBtn.Position = UDim2.new(1, -78, 0.5, -18)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -18)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local function makeCorner(btn) 
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 9); c.Parent = btn 
end
makeCorner(MinimizeBtn)
makeCorner(CloseBtn)

-- Body
local Body = Instance.new("ScrollingFrame")
Body.Size = UDim2.new(1, 0, 1, -50)
Body.Position = UDim2.new(0, 0, 0, 50)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 5
Body.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.Parent = MainFrame

local BodyLayout = Instance.new("UIListLayout")
BodyLayout.Padding = UDim.new(0, 10)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
BodyLayout.Parent = Body

local BodyPadding = Instance.new("UIPadding")
BodyPadding.PaddingLeft = UDim.new(0, 12)
BodyPadding.PaddingRight = UDim.new(0, 12)
BodyPadding.PaddingTop = UDim.new(0, 12)
BodyPadding.Parent = Body

-- ==================== DRAG ====================
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

Header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ==================== MINIMIZE & CLOSE ====================
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Body.Visible = false
		MainFrame.Size = UDim2.new(0, 310, 0, 50)
		MinimizeBtn.Text = "+"
	else
		Body.Visible = true
		MainFrame.Size = UDim2.new(0, 310, 0, 400)
		MinimizeBtn.Text = "-"
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- ==================== TOGGLE CREATOR ====================
local featureCallbacks = {} 

local function CreateToggle(text, defaultState, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, 0, 0, 52)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = Body

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
	ToggleStroke.Thickness = 1
	ToggleStroke.Parent = ToggleFrame

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 12)
	ToggleCorner.Parent = ToggleFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.65, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextScaled = true
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local Switch = Instance.new("Frame")
	Switch.Size = UDim2.new(0, 58, 0, 30)
	Switch.Position = UDim2.new(0.82, 0, 0.5, -15)
	Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Switch.Parent = ToggleFrame

	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = Switch

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 26, 0, 26)
	Knob.Position = UDim2.new(0, 2, 0.5, -13)
	Knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	Knob.Parent = Switch

	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1, 0)
	KnobCorner.Parent = Knob

	local state = defaultState
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function UpdateVisual()
		if state then
			TweenService:Create(Switch, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 200, 80)}):Play()
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(1, -28, 0.5, -13)}):Play()
		else
			TweenService:Create(Switch, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -13)}):Play()
		end
	end

	local ClickArea = Instance.new("TextButton")
	ClickArea.Size = UDim2.new(1, 0, 1, 0)
	ClickArea.BackgroundTransparency = 1
	ClickArea.Text = ""
	ClickArea.Parent = ToggleFrame

	ClickArea.MouseButton1Click:Connect(function()
		state = not state
		UpdateVisual()
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

-- Universal Entity ESP (Players, Mobs, NPCs)
local espEnabled = false
local highlights = {}

CreateToggle("ESP", false, function(enabled)
	espEnabled = enabled
	if enabled then
		task.spawn(function()
			while espEnabled do
				for _, obj in ipairs(workspace:GetDescendants()) do
					-- Check if the object is a character model/entity
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= player.Character then
						if not highlights[obj] then
							local hl = Instance.new("Highlight")
							hl.Adornee = obj
							
							-- Red for players, Orange for NPCs/Mobs
							if Players:GetPlayerFromCharacter(obj) then
								hl.FillColor = Color3.fromRGB(255, 60, 60)
							else
								hl.FillColor = Color3.fromRGB(255, 150, 0)
							end
							
							hl.OutlineColor = Color3.fromRGB(255, 255, 255)
							hl.FillTransparency = 0.35
							hl.OutlineTransparency = 0
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							hl.Parent = obj
							highlights[obj] = hl
						end
					end
				end
				
				-- Cleanup destroyed/dead entities
				for obj, hl in pairs(highlights) do
					if not obj or not obj.Parent or not obj:FindFirstChild("Humanoid") or obj:FindFirstChild("Humanoid").Health <= 0 then
						hl:Destroy()
						highlights[obj] = nil
					end
				end
				
				task.wait(1.5) -- Scans every 1.5s to catch new mobs & prevent lag
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

-- CLOCK
local clockFrame = nil
local clockUpdate = nil

CreateToggle("Clock", false, function(enabled)
	if enabled then
		clockFrame = Instance.new("Frame")
		clockFrame.Size = UDim2.new(0, 155, 0, 62)
		clockFrame.Position = UDim2.new(1, -165, 0, 15)
		clockFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		clockFrame.Parent = ScreenGui

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 14)
		cCorner.Parent = clockFrame

		local cStroke = Instance.new("UIStroke")
		cStroke.Color = Color3.fromRGB(70, 70, 70)
		cStroke.Parent = clockFrame

		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(0.65, 0, 0.7, 0)
		timeLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		timeLabel.TextScaled = true
		timeLabel.Font = Enum.Font.GothamBold
		timeLabel.Text = "00:00"
		timeLabel.Parent = clockFrame

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0, 42, 0, 42)
		iconLabel.Position = UDim2.new(0.72, 0, 0.1, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.TextScaled = true
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
				iconLabel.TextColor3 = Color3.fromRGB(180, 210, 255)
			end
		end)
	else
		if clockUpdate then clockUpdate:Disconnect() end
		if clockFrame then clockFrame:Destroy() clockFrame = nil end
	end
end)

print("Shark V1")
