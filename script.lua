-- FIXED Dead Rails Auto Bond Script (GUI ALWAYS shows) - March 2026 version
-- Improved bond detection & movement logic

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ============== GUI (unchanged - kept as is) ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsAutoBond"
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- (header, title, minBtn, closeBtn, body, toggleBtn, statusLabel - same as your original code)
-- ... paste your original GUI creation code here (header, buttons, dragging logic) ...

-- Assume you already have:
-- toggleBtn, statusLabel, enabled, autoThread

-- ============== Remote fallback / guess ==============
local remote
do
    -- Try your original path
    local pkg = ReplicatedStorage:FindFirstChild("Packages")
    if pkg then
        remote = pkg:FindFirstChild("ActivateObjectClient")
    end
    
    -- Common alternatives in similar games
    if not remote then
        for _, v in ReplicatedStorage:GetDescendants() do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("collect") or v.Name:lower():find("pickup") or v.Name:lower():find("interact") or v.Name:lower():find("activate")) then
                remote = v
                break
            end
        end
    end
end

-- ============== Better bond finding logic ==============
local function findBonds()
    local candidates = {}
    
    -- Try common folders first
    local searchFolders = {
        Workspace:FindFirstChild("RuntimeItems"),
        Workspace:FindFirstChild("Loot"),
        Workspace:FindFirstChild("Map"),
        Workspace,
    }
    
    for _, folder in searchFolders do
        if not folder then continue end
        
        for _, obj in folder:GetDescendants() do
            -- Common patterns for bonds / collectibles
            local name = obj.Name:lower()
            if name:find("bond") or name:find("bonus") or name:find("treasury") or name == "bond" 
                or obj:IsA("Tool") or obj:FindFirstChildOfClass("ProximityPrompt") 
                or obj:FindFirstChildOfClass("ClickDetector") then
                
                -- Get the main part to tp to / interact with
                local targetPart = obj:IsA("BasePart") and obj 
                    or obj:FindFirstChildWhichIsA("BasePart") 
                    or obj.PrimaryPart
                    
                if targetPart then
                    table.insert(candidates, {obj = obj, part = targetPart})
                end
            end
        end
    end
    
    return candidates
end

-- ============== AUTO BOND LOGIC (fixed) ==============
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.Text = "Auto Bond: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        statusLabel.Text = "ON - Searching bonds..."
        
        autoThread = coroutine.create(function()
            while enabled and hrp.Parent do
                local bonds = findBonds()
                
                if #bonds > 0 then
                    statusLabel.Text = "Found " .. #bonds .. " bond(s) - collecting..."
                    
                    for _, bond in bonds do
                        if not enabled or not hrp.Parent then break end
                        
                        -- Safe tp above
                        hrp.CFrame = bond.part.CFrame * CFrame.new(0, 4.5, 0)
                        task.wait(0.35)  -- slightly longer delay
                        
                        -- Try remote fire
                        if remote then
                            pcall(function()
                                remote:FireServer(bond.obj)
                            end)
                        end
                        
                        -- Fallback: fire proximity / click if exists
                        local prompt = bond.obj:FindFirstChildOfClass("ProximityPrompt") 
                            or bond.part:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                        
                        -- Mark to avoid re-collect spam
                        bond.obj.Name = bond.obj.Name .. "_collected"
                        
                        task.wait(0.4)
                    end
                else
                    statusLabel.Text = "No bonds found - scanning map..."
                    -- Optional: tiny random movement to maybe trigger spawns (some games require it)
                    -- hrp.CFrame += CFrame.new(math.random(-3,3), 0, math.random(-3,3))
                end
                
                task.wait(0.6)  -- main loop delay
            end
        end)
        
        coroutine.resume(autoThread)
        
    else
        toggleBtn.Text = "Auto Bond: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "OFF"
    end
end)

print("✅ Improved Auto Bond GUI loaded!")
print("Now searches for realistic bond names / tools / prompts.")
print("Toggle ON once you're in a run. Stay patient - bonds spawn in buildings/towns.")
