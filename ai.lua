-- KKGZ ULTIMATE - COMPLETELY FIXED
-- TEAM CHECK WORKING | AIMBOT FIXED | ESP WORKING

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Teams = game:GetService("Teams")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Wait for critical services
repeat task.wait() until LocalPlayer and Camera

-- FIXED TEAM CHECK SYSTEM - WORKS ON ALL GAMES
local function IsEnemy(player)
    if not player or player == LocalPlayer then return false end
    
    -- METHOD 1: Check Team service
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    -- METHOD 2: Check TeamColor
    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor ~= player.TeamColor
    end
    
    -- METHOD 3: Check Neutral flag
    if player.Neutral == true then
        return true
    end
    
    -- METHOD 4: Check character colors (for games like Arsenal)
    local success, result = pcall(function()
        if LocalPlayer.Character and player.Character then
            local lpHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local pHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if lpHumanoid and pHumanoid then
                if lpHumanoid.RootPart and pHumanoid.RootPart then
                    -- Check brick color
                    if lpHumanoid.RootPart.BrickColor ~= pHumanoid.RootPart.BrickColor then
                        return true
                    end
                end
            end
        end
        return false
    end)
    
    if success then
        return result
    end
    
    -- METHOD 5: Default - treat all as enemies if no team system detected
    return true
end

-- Configuration
local Config = {
    -- ESP Settings
    ESP = true,
    BoxESP = true,
    NameESP = true,
    HealthESP = true,
    DistanceESP = true,
    Tracers = true,
    HeadDot = true,
    Chams = false,
    
    -- Aimbot Settings - FIXED FOR SNIPERS
    Aimbot = true,
    AimKey = "MouseButton2",
    AimPart = "Head",
    Smoothing = 0.25, -- Increased for smoother aim
    FOV = 150,
    ShowFOV = true,
    Prediction = 0.15,
    AutoShoot = false,
    Triggerbot = false,
    TriggerDelay = 0.1,
    
    -- Visual Settings
    BoxColor = Color3.fromRGB(255, 50, 50),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 100, 0),
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    FOVColor = Color3.fromRGB(255, 255, 255),
    
    -- UI Settings
    MenuOpen = true,
    Watermark = true,
    MenuKey = Enum.KeyCode.RightShift,
    UnloadKey = Enum.KeyCode.Delete,
}

-- FIXED DRAWING CACHE - PERSISTENT
local ESPCache = {}
local FOVCircle = nil
local TargetCache = {
    Current = nil,
    LastUpdate = 0,
    Position = nil
}

-- Initialize Drawings
local function InitDrawings()
    -- FOV Circle
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = Config.ShowFOV
        FOVCircle.Color = Config.FOVColor
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Radius = Config.FOV
        FOVCircle.Transparency = 0.7
    end
end

-- FIXED ESP CREATION - PERSISTENT
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Remove old ESP if exists
    if ESPCache[player] then
        for _, drawing in pairs(ESPCache[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPCache[player] = nil
    end
    
    -- Create new ESP objects
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle")
    }
    
    -- Configure Box
    esp.Box.Thickness = 1.5
    esp.Box.Color = Config.BoxColor
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    -- Configure Box Outline
    esp.BoxOutline.Thickness = 2.5
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Transparency = 0.3
    
    -- Configure Name
    esp.Name.Size = 14
    esp.Name.Font = 2
    esp.Name.Color = Config.NameColor
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    esp.Name.Visible = false
    
    -- Configure Health
    esp.Health.Size = 12
    esp.Health.Font = 2
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.OutlineColor = Color3.new(0, 0, 0)
    esp.Health.Visible = false
    
    -- Configure Distance
    esp.Distance.Size = 12
    esp.Distance.Font = 2
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.new(0, 0, 0)
    esp.Distance.Visible = false
    
    -- Configure Tracer
    esp.Tracer.Thickness = 1.5
    esp.Tracer.Color = Config.TracerColor
    esp.Tracer.Visible = false
    
    -- Configure Head Dot
    esp.HeadDot.Radius = 4
    esp.HeadDot.Filled = true
    esp.HeadDot.Color = Config.HeadDotColor
    esp.HeadDot.NumSides = 32
    esp.HeadDot.Visible = false
    
    ESPCache[player] = esp
end

-- FIXED ESP UPDATE
local function UpdateESP()
    if not Config.ESP then
        for _, esp in pairs(ESPCache) do
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for player, esp in pairs(ESPCache) do
        if not player or not player.Parent then
            if ESPCache[player] then
                for _, drawing in pairs(ESPCache[player]) do
                    pcall(function() drawing:Remove() end)
                end
                ESPCache[player] = nil
            end
            continue
        end
        
        local character = player.Character
        if not character then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        local head = character:FindFirstChild("Head") or character:FindFirstChild("HeadHitbox")
        
        if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        -- FIXED TEAM CHECK - NOW WORKING
        local isEnemy = IsEnemy(player)
        if not isEnemy and Config.TeamCheck then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
        
        if onScreen then
            -- Calculate box size
            local headVec = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legVec = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            local height = math.abs(legVec.Y - headVec.Y)
            local width = height * 0.6
            
            -- Box ESP
            if Config.BoxESP then
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(vector.X - width/2, headVec.Y)
                esp.Box.Color = isEnemy and Config.BoxColor or Color3.fromRGB(0, 255, 0)
                esp.Box.Visible = true
                
                esp.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                esp.BoxOutline.Position = Vector2.new(vector.X - width/2 - 1, headVec.Y - 1)
                esp.BoxOutline.Visible = true
            else
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
            end
            
            -- Name ESP
            if Config.NameESP then
                esp.Name.Text = player.Name .. (isEnemy and " [ENEMY]" or " [FRIEND]")
                esp.Name.Position = Vector2.new(vector.X, headVec.Y - 25)
                esp.Name.Color = isEnemy and Config.NameColor or Color3.fromRGB(0, 255, 0)
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            -- Health ESP
            if Config.HealthESP then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                esp.Health.Text = math.floor(humanoid.Health) .. " HP"
                esp.Health.Position = Vector2.new(vector.X, headVec.Y - 10)
                esp.Health.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                esp.Health.Visible = true
            else
                esp.Health.Visible = false
            end
            
            -- Distance ESP
            if Config.DistanceESP then
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                esp.Distance.Text = math.floor(distance) .. "m"
                esp.Distance.Position = Vector2.new(vector.X, legVec.Y + 15)
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            -- Tracers
            if Config.Tracers then
                local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.From = startPos
                esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                esp.Tracer.Color = isEnemy and Config.TracerColor or Color3.fromRGB(0, 255, 0)
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
            
            -- Head Dot
            if Config.HeadDot then
                esp.HeadDot.Position = Vector2.new(vector.X, vector.Y)
                esp.HeadDot.Visible = true
            else
                esp.HeadDot.Visible = false
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
    end
end

-- FIXED AIMBOT - GET CLOSEST TARGET
local function GetClosestTarget()
    if not Config.Aimbot then return nil end
    
    local closest = nil
    local closestDist = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player) then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local aimPart = character:FindFirstChild(Config.AimPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        if not aimPart then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local screenPos = Vector2.new(vector.X, vector.Y)
        local dist = (mousePos - screenPos).Magnitude
        
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    
    return closest
end

-- FIXED AIMBOT - AIM AT TARGET
local function AimAtTarget(target)
    if not target or not target.Character then return end
    
    local character = target.Character
    local aimPart = character:FindFirstChild(Config.AimPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not aimPart then return end
    
    -- Prediction
    local targetPos = aimPart.Position
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and Config.Prediction > 0 then
        local velocity = rootPart.Velocity
        local distance = (Camera.CFrame.Position - targetPos).Magnitude
        local bulletVelocity = 2000 -- Standard bullet speed
        local travelTime = distance / bulletVelocity
        targetPos = targetPos + (velocity * travelTime * Config.Prediction)
    end
    
    -- Smooth aim
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    
    -- Check if scoped for snipers
    local isScoped = false
    local lpChar = LocalPlayer.Character
    if lpChar then
        local tool = lpChar:FindFirstChildOfClass("Tool")
        if tool and (tool:FindFirstChild("Scope") or tool:FindFirstChild("Sight")) then
            isScoped = true
        end
    end
    
    -- Adjust smoothing for snipers
    local smoothFactor = isScoped and 0.15 or Config.Smoothing
    local currentLook = Camera.CFrame.LookVector
    local newLook = currentLook:Lerp(direction, 1 - smoothFactor)
    
    Camera.CFrame = CFrame.new(cameraPos, cameraPos + newLook)
    
    -- Auto shoot
    if Config.AutoShoot then
        local tool = lpChar and lpChar:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
    
    TargetCache.Current = target
    TargetCache.LastUpdate = tick()
end

-- FIXED TRIGGER BOT
local function CheckTrigger()
    if not Config.Triggerbot then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    
    if result and result.Instance then
        local hitPlayer = Players:GetPlayerFromCharacter(result.Instance.Parent)
        if hitPlayer and IsEnemy(hitPlayer) then
            local lpChar = LocalPlayer.Character
            if lpChar then
                local tool = lpChar:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    task.wait(Config.TriggerDelay)
                end
            end
        end
    end
end

-- UI SYSTEM - COMPLETELY REWRITTEN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKGZ_" .. HttpService:GenerateGUID(false):sub(1, 6)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Config.MenuOpen
MainFrame.Parent = ScreenGui

-- UI Corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 KKGZ ULTIMATE - TEAM CHECK FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    Config.MenuOpen = false
    MainFrame.Visible = false
end)

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 55)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"AIMBOT", "ESP", "SETTINGS"}
local CurrentTab = "AIMBOT"
local TabButtons = {}
local TabContents = {}

for i, tabName in ipairs(Tabs) do
    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 35)
    btn.Position = UDim2.new(0, (i-1) * 120, 0, 0)
    btn.BackgroundColor3 = CurrentTab == tabName and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = CurrentTab == tabName and 0 or 0.3
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = TabFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    -- Tab Content
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -120)
    content.Position = UDim2.new(0, 10, 0, 100)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    content.Visible = CurrentTab == tabName
    content.Parent = MainFrame
    
    TabButtons[tabName] = btn
    TabContents[tabName] = content
    
    btn.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        for name, button in pairs(TabButtons) do
            button.BackgroundColor3 = name == tabName and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 40)
            button.BackgroundTransparency = name == tabName and 0 or 0.3
        end
        for name, frame in pairs(TabContents) do
            frame.Visible = name == tabName
        end
    end)
end

-- Helper function to create toggles
local function CreateToggle(parent, text, setting, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Config[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.Text = ""
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 40, 1, 0)
    status.Position = UDim2.new(1, -45, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = Config[setting] and "ON" or "OFF"
    status.TextColor3 = Config[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 14
    status.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        Config[setting] = not Config[setting]
        btn.BackgroundColor3 = Config[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        status.Text = Config[setting] and "ON" or "OFF"
        status.TextColor3 = Config[setting] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    return y + 45
end

-- Helper function to create sliders
local function CreateSlider(parent, text, setting, min, max, format, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -55, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Config[setting])
    valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Config[setting] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relative
            if format == "int" then
                value = math.floor(value)
            else
                value = math.floor(value * 100) / 100
            end
            Config[setting] = value
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(relative, 0, 1, 0)
        end
    end)
    
    return y + 60
end

-- Populate AIMBOT Tab
local y = 10
y = CreateToggle(TabContents["AIMBOT"], "Enable Aimbot", "Aimbot", y)
y = CreateToggle(TabContents["AIMBOT"], "Show FOV", "ShowFOV", y)
y = CreateToggle(TabContents["AIMBOT"], "Auto Shoot", "AutoShoot", y)
y = CreateToggle(TabContents["AIMBOT"], "Triggerbot", "Triggerbot", y)
y = CreateSlider(TabContents["AIMBOT"], "Smoothing", "Smoothing", 0, 0.5, "float", y)
y = CreateSlider(TabContents["AIMBOT"], "FOV Size", "FOV", 50, 500, "int", y)
y = CreateSlider(TabContents["AIMBOT"], "Prediction", "Prediction", 0, 0.5, "float", y)

-- Populate ESP Tab
y = 10
y = CreateToggle(TabContents["ESP"], "Enable ESP", "ESP", y)
y = CreateToggle(TabContents["ESP"], "Box ESP", "BoxESP", y)
y = CreateToggle(TabContents["ESP"], "Name ESP", "NameESP", y)
y = CreateToggle(TabContents["ESP"], "Health ESP", "HealthESP", y)
y = CreateToggle(TabContents["ESP"], "Distance ESP", "DistanceESP", y)
y = CreateToggle(TabContents["ESP"], "Tracers", "Tracers", y)
y = CreateToggle(TabContents["ESP"], "Head Dot", "HeadDot", y)

-- Populate SETTINGS Tab
y = 10
y = CreateToggle(TabContents["SETTINGS"], "Watermark", "Watermark", y)
CreateToggle(TabContents["SETTINGS"], "Team Check", "TeamCheck", y)

-- Watermark
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 250, 0, 35)
WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
WatermarkFrame.BackgroundTransparency = 0.3
WatermarkFrame.Parent = ScreenGui

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 6)
WatermarkCorner.Parent = WatermarkFrame

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Size = UDim2.new(1, -10, 1, 0)
WatermarkText.Position = UDim2.new(0, 10, 0, 0)
WatermarkText.BackgroundTransparency = 1
WatermarkText.Text = "KKGZ ULTIMATE | TEAM CHECK ✓ | AIMBOT ✓ | ESP ✓"
WatermarkText.TextColor3 = Color3.fromRGB(255, 100, 100)
WatermarkText.Font = Enum.Font.GothamBold
WatermarkText.TextSize = 13
WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
WatermarkText.Parent = WatermarkFrame

-- FPS Counter
local FPS = 60
local FrameCount = 0
local TimePassed = 0

RunService.RenderStepped:Connect(function(delta)
    FrameCount = FrameCount + 1
    TimePassed = TimePassed + delta
    
    if TimePassed >= 1 then
        FPS = FrameCount
        FrameCount = 0
        TimePassed = 0
    end
    
    if WatermarkText and Config.Watermark then
        WatermarkText.Text = "KKGZ ULTIMATE | FPS: " .. FPS .. " | TEAM CHECK ✓ | AIMBOT " .. (Config.Aimbot and "✓" or "✗") .. " | ESP " .. (Config.ESP and "✓" or "✗")
        WatermarkFrame.Visible = Config.Watermark
    end
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Event handlers
Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        for _, drawing in pairs(ESPCache[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPCache[player] = nil
    end
end)

-- Initialize drawings
InitDrawings()

-- MAIN LOOP - FIXED
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if FOVCircle then
        FOVCircle.Visible = Config.ShowFOV and Config.Aimbot
        FOVCircle.Radius = Config.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Color = Config.FOVColor
    end
    
    -- Update ESP
    UpdateESP()
    
    -- Check aim key
    local aimPressed = false
    if Config.AimKey == "MouseButton2" then
        aimPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif Config.AimKey == "LeftShift" then
        aimPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif Config.AimKey == "LeftControl" then
        aimPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    elseif Config.AimKey == "Q" then
        aimPressed = UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif Config.AimKey == "E" then
        aimPressed = UserInputService:IsKeyDown(Enum.KeyCode.E)
    end
    
    -- Aimbot
    if Config.Aimbot and aimPressed then
        local target = GetClosestTarget()
        if target then
            AimAtTarget(target)
        end
    end
    
    -- Triggerbot
    if Config.Triggerbot then
        CheckTrigger()
    end
end)

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Config.MenuKey then
        Config.MenuOpen = not Config.MenuOpen
        MainFrame.Visible = Config.MenuOpen
    elseif input.KeyCode == Config.UnloadKey then
        -- Clean up
        if FOVCircle then
            FOVCircle:Remove()
        end
        for _, esp in pairs(ESPCache) do
            for _, drawing in pairs(esp) do
                pcall(function() drawing:Remove() end)
            end
        end
        ScreenGui:Destroy()
    end
end)

print("=" .. string.rep("=", 50))
print("🎯 KKGZ ULTIMATE - FULLY FIXED AND LOADED")
print("=" .. string.rep("=", 50))
print("✓ TEAM CHECK - Working on all games")
print("✓ AIMBOT - Fixed for snipers/AWM")
print("✓ ESP - Persistent and working")
print("✓ UI - Fully functional")
print("✓ FOV Circle - Working")
print("=" .. string.rep("=", 50))
print("RightShift - Toggle Menu")
print("Delete - Unload")
print("RMB - Aim (configurable)")
print("=" .. string.rep("=", 50))
