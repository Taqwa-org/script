-- Features:
-- ESP (Dropdown Menu, Dynamic Text Scaling, Toggable Info)
-- Full Bright
-- Noclip
-- Free Cam (Detached Camera, Locks Player, Mobile Friendly)

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

-- Main Frame (Height set to exactly 70% of device screen)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0.7, 0)
MainFrame.Position = UDim2.new(0.5, -155, 0.15, 0)
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

-- Shadow Layer
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "DropShadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 15, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 15)
Shadow.Size = UDim2.new(0, 340, 0.7, 30)
Shadow.Image = "rbxassetid://4731308628" 
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(35, 35, 265, 265)
Shadow.Parent = ScreenGui

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

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderPatch = Instance.new("Frame")
HeaderPatch.Size = UDim2.new(1, 0, 0, 10)
HeaderPatch.Position = UDim2.new(0, 0, 1, -10)
HeaderPatch.BackgroundColor3 = Color3.fromRGB(13, 15, 20)
HeaderPatch.BorderSizePixel = 0
HeaderPatch.Parent = Header

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
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
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

BodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Body.CanvasSize = UDim2.new(0, 0, 0, BodyLayout.AbsoluteContentSize.Y + 24)
end)

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
	local targetSize = isMinimized and UDim2.new(0, 310, 0, 45) or UDim2.new(0, 310, 0.7, 0)
	local shadowSize = isMinimized and UDim2.new(0, 340, 0, 75) or UDim2.new(0, 340, 0.7, 30)
	
	TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = shadowSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
	local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 310, 0, 0)})
	TweenService:Create(Shadow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
	t:Play()
	t.Completed:Wait()
	ScreenGui:Destroy()
end)

-- ==================== TOGGLE CREATOR ====================
local featureCallbacks = {} 

-- Updated to accept a "parent" and an "isSub" argument for smaller dropdown toggles
local function CreateToggle(text, defaultState, parent, isSub, callback)
	local ToggleFrame = Instance.new("Frame")
	local height = isSub and 38 or 48
	local width = isSub and 0.85 or 0.92
	ToggleFrame.Size = UDim2.new(width, 0, 0, height)
	ToggleFrame.BackgroundColor3 = isSub and Color3.fromRGB(18, 20, 26) or Color3.fromRGB(22, 26, 35)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = parent

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 10)
	ToggleCorner.Parent = ToggleFrame

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Color = isSub and Color3.fromRGB(35, 42, 55) or Color3.fromRGB(40, 50, 65)
	ToggleStroke.Thickness = 1
	ToggleStroke.Parent = ToggleFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.65, 0, 1, 0)
	Label.Position = UDim2.new(0.05, 0, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(220, 225, 240)
	Label.TextSize = isSub and 12 or 14
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local SwitchBg = Instance.new("Frame")
	local bgW = isSub and 36 or 44
	local bgH = isSub and 18 or 24
	SwitchBg.Size = UDim2.new(0, bgW, 0, bgH)
	SwitchBg.Position = UDim2.new(1, isSub and -45 or -55, 0.5, -(bgH/2))
	SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	SwitchBg.Parent = ToggleFrame

	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = SwitchBg

	local Knob = Instance.new("Frame")
	local kS = isSub and 14 or 18
	Knob.Size = UDim2.new(0, kS, 0, kS)
	Knob.Position = UDim2.new(0, 2, 0.5, -(kS/2))
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
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(1, -(kS + 2), 0.5, -(kS/2))}):Play()
			TweenService:Create(Label, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(ToggleStroke, tweenInfo, {Color = Color3.fromRGB(0, 120, 150)}):Play()
		else
			TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 40, 50)}):Play()
			TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -(kS/2))}):Play()
			TweenService:Create(Label, tweenInfo, {TextColor3 = Color3.fromRGB(180, 190, 205)}):Play()
			TweenService:Create(ToggleStroke, tweenInfo, {Color = isSub and Color3.fromRGB(35, 42, 55) or Color3.fromRGB(40, 50, 65)}):Play()
		end
	end

	ClickArea.MouseButton1Click:Connect(function()
		state = not state
		UpdateVisual()
		local pulse = TweenService:Create(ToggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(width - 0.02, 0, 0, height - 2)})
		pulse:Play()
		pulse.Completed:Wait()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(width, 0, 0, height)}):Play()
		callback(state)
	end)

	UpdateVisual()
	if defaultState then callback(true) end

	featureCallbacks[text] = callback
	return ToggleFrame
end

ScreenGui.Destroying:Connect(function()
	for _, callback in pairs(featureCallbacks) do
		callback(false) 
	end
end)

-- ==================== ESP SYSTEM WITH DROPDOWN ====================
local EspContainer = Instance.new("Frame")
EspContainer.Size = UDim2.new(1, 0, 0, 48) -- Starts Collapsed
EspContainer.BackgroundTransparency = 1
EspContainer.ClipsDescendants = true
EspContainer.Parent = Body

local EspLayout = Instance.new("UIListLayout")
EspLayout.Padding = UDim.new(0, 8)
EspLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EspLayout.SortOrder = Enum.SortOrder.LayoutOrder
EspLayout.Parent = EspContainer

-- ESP Settings Data
local espConfig = {
	Enabled = false,
	NameDist = true,
	HealthSpeed = true,
	WeaponDmg = true
}

-- Formats exactly what you selected in the sub-menus
local function getEntityStats(obj, dist)
	local isFriendly = false
	local plr = Players:GetPlayerFromCharacter(obj)
	
	if plr and plr.Team and player.Team and plr.Team == player.Team then
		isFriendly = true
	end
	local color = isFriendly and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 50, 50)
	
	local lines = {}
	
	if espConfig.NameDist then
		table.insert(lines, string.format("[%s] %ds", obj.Name, dist))
	end
	
	if espConfig.HealthSpeed then
		local hum = obj:FindFirstChildOfClass("Humanoid")
		local hp = hum and math.floor(hum.Health) or 0
		local maxHp = hum and math.floor(hum.MaxHealth) or 0
		local speed = hum and math.floor(hum.WalkSpeed) or 0
		table.insert(lines, string.format("HP: %d/%d | SPD: %d", hp, maxHp, speed))
	end
	
	if espConfig.WeaponDmg then
		local weaponText = "Unarmed"
		local tool = obj:FindFirstChildOfClass("Tool")
		if tool then
			local dmgVal = tool:FindFirstChild("Damage") or tool:FindFirstChild("HitDamage")
			if dmgVal and (dmgVal:IsA("NumberValue") or dmgVal:IsA("IntValue")) then
				weaponText = string.format("WEP: %s (DMG: %s)", tool.Name, tostring(dmgVal.Value))
			else
				weaponText = "WEP: " .. tool.Name
			end
		end
		table.insert(lines, weaponText)
	end
	
	return color, table.concat(lines, "\n")
end

local function cleanAllESP()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v.Name == "SharkV1_Highlight" or v.Name == "SharkV1_Billboard" then
			v:Destroy()
		end
	end
end

-- Create the Toggles inside the ESP Container
local espLoopRunning = false

CreateToggle("Entity ESP", false, EspContainer, false, function(enabled)
	espConfig.Enabled = enabled
	
	if enabled then
		-- Drops the menu down to reveal the sub-toggles
		TweenService:Create(EspContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 186)}):Play()
		
		if not espLoopRunning then
			espLoopRunning = true
			task.spawn(function()
				while espConfig.Enabled do
					local success, err = pcall(function()
						for _, obj in ipairs(workspace:GetDescendants()) do
							if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= player.Character then
								local hum = obj:FindFirstChildOfClass("Humanoid")
								
								if hum and hum.Health > 0 then
									local root = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
									local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
									
									-- Distance Calculator
									local dist = 0
									if root and myRoot then
										dist = math.floor((myRoot.Position - root.Position).Magnitude)
									end
									
									if root then
										local hl = obj:FindFirstChild("SharkV1_Highlight")
										local bg = obj:FindFirstChild("SharkV1_Billboard")
										
										if not hl then
											hl = Instance.new("Highlight")
											hl.Name = "SharkV1_Highlight"
											hl.Adornee = obj
											hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
											hl.FillTransparency = 0.5
											hl.OutlineTransparency = 0
											hl.Parent = obj
										end
										
										if not bg then
											bg = Instance.new("BillboardGui")
											bg.Name = "SharkV1_Billboard"
											bg.Adornee = root
											bg.Size = UDim2.new(0, 300, 0, 90) 
											bg.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0) 
											bg.AlwaysOnTop = true
											bg.Parent = obj
											
											local txt = Instance.new("TextLabel")
											txt.Name = "InfoText"
											txt.Size = UDim2.new(1, 0, 1, 0)
											txt.BackgroundTransparency = 1
											txt.TextWrapped = true
											txt.TextYAlignment = Enum.TextYAlignment.Bottom
											txt.Font = Enum.Font.GothamBold
											txt.Parent = bg
											
											local stroke = Instance.new("UIStroke")
											stroke.Color = Color3.fromRGB(0,0,0)
											stroke.Thickness = 1
											stroke.Parent = txt
										end
										
										-- Get formatting
										local color, infoText = getEntityStats(obj, dist)
										
										-- UPDATE VISUALS
										hl.FillColor = color
										hl.OutlineColor = Color3.fromRGB(255, 255, 255)
										
										local txt = bg:FindFirstChild("InfoText")
										if txt then
											if infoText == "" then
												txt.Visible = false
											else
												txt.Visible = true
												txt.TextColor3 = color
												txt.Text = infoText
												
												-- ===========================================
												-- MAGIC SCALING MATH: (Close = Small | Far = Big)
												-- Limits minimum size to 11 and maximum to 26.
												-- Stops growing bigger after 150 studs.
												-- ===========================================
												local minSize = 11
												local maxSize = 26
												local dynSize = math.floor(minSize + ((maxSize - minSize) * math.clamp(dist / 150, 0, 1)))
												
												txt.TextSize = dynSize
											end
										end
									end
								elseif hum and hum.Health <= 0 then
									if obj:FindFirstChild("SharkV1_Highlight") then obj:FindFirstChild("SharkV1_Highlight"):Destroy() end
									if obj:FindFirstChild("SharkV1_Billboard") then obj:FindFirstChild("SharkV1_Billboard"):Destroy() end
								end
							end
						end
					end)
					
					if not success then warn("ESP Loop Error: ", err) end
					task.wait(0.2)
				end
				espLoopRunning = false
			end)
		end
	else
		-- Closes the menu
		TweenService:Create(EspContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 48)}):Play()
		cleanAllESP()
	end
end)

-- Create Sub Toggles inside the Dropdown
CreateToggle("Show Name & Distance", true, EspContainer, true, function(enabled) espConfig.NameDist = enabled end)
CreateToggle("Show Health & Speed", true, EspContainer, true, function(enabled) espConfig.HealthSpeed = enabled end)
CreateToggle("Show Weapon & Damage", true, EspContainer, true, function(enabled) espConfig.WeaponDmg = enabled end)


-- ==================== OTHER FEATURES ====================

CreateToggle("Full Bright", false, Body, false, function(enabled)
	if enabled then
		_G.fbConn = RunService.RenderStepped:Connect(function()
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(255,255,255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
		end)
	else
		if _G.fbConn then _G.fbConn:Disconnect() end
	end
end)

local noclipConn = nil
local noclipRespawn = nil

CreateToggle("Noclip", false, Body, false, function(enabled)
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

	createBtn("W", UDim2.new(0, 85, 1, -190), "F")
	createBtn("S", UDim2.new(0, 85, 1, -70), "B")
	createBtn("A", UDim2.new(0, 20, 1, -130), "L")
	createBtn("D", UDim2.new(0, 150, 1, -130), "R")
	createBtn("UP", UDim2.new(1, -100, 1, -190), "U")
	createBtn("DN", UDim2.new(1, -100, 1, -70), "D")
end

CreateToggle("Free Cam", false, Body, false, function(enabled)
	if enabled then
		camera.CameraType = Enum.CameraType.Scriptable
		fcCFrame = camera.CFrame
		pitch, yaw, _ = fcCFrame:ToEulerAnglesYXZ()
		
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.Anchored = true
		end
		
		buildMobileControls()
		
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

		fcConn = RunService.RenderStepped:Connect(function(dt)
			local moveVector = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) or mobileMoveFlags.F then moveVector += Vector3.new(0, 0, -1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) or mobileMoveFlags.B then moveVector += Vector3.new(0, 0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) or mobileMoveFlags.L then moveVector += Vector3.new(-1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) or mobileMoveFlags.R then moveVector += Vector3.new(1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileMoveFlags.U then moveVector += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or mobileMoveFlags.D then moveVector += Vector3.new(0, -1, 0) end
			
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
		
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.Anchored = false
		end
	end
end)

print("Shark V1 - Ultimate Version Enabled")
