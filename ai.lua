-- KKGZ ULTIMATE - TEAM ECHECK FIXED
-- AWM / Sniper Compatible Aimbot
-- Anti-Cheat Bypass + Enhanced UI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Teams = game:GetService("Teams")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- TEAM CHECK SYSTEM
local function IsEnemy(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
    -- Team check for eCheck / Arsenal / MM2 / etc
    if LocalPlayer.Team and player.Team then
        if LocalPlayer.Team ~= player.Team then
            return true
        else
            return false
        end
    end
    
    -- Check via team color
    if LocalPlayer.TeamColor and player.TeamColor then
        if LocalPlayer.TeamColor ~= player.TeamColor then
            return true
        else
            return false
        end
    end
    
    -- If no teams, treat all as enemies
    return true
end

-- Configuration
local Config = {
    -- ESP
    BoxESP = true,
    NameESP = true,
    HealthESP = true,
    DistanceESP = true,
    Tracers = true,
    HeadDot = true,
    Skeleton = false,
    
    -- Aimbot - FIXED FOR AWM/SNIPERS
    Aimbot = true,
    AimKey = "MouseButton2",
    AimPart = "Head", 
    Smoothing = 0.15, -- Lower = faster lock (0.1-0.2 works best for AWM)
    FOV = 200,
    ShowFOV = true,
    Prediction = 0.2, -- Bullet prediction for moving targets
    AutoShoot = false,
    Triggerbot = false,
    
    -- Visual - NEON STYLE
    BoxColor = Color3.fromRGB(255, 50, 50),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 100, 0),
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    FOVColor = Color3.fromRGB(255, 255, 255),
    
    -- UI
    MenuOpen = true,
    Watermark = true,
    Theme = "Neon Red"
}

-- Anti-Ban System
do
    local function AntiBan()
        local randomId = HttpService:GenerateGUID(false)
        pcall(function() script.Name = "Sys_" .. randomId end)
        
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" then
                    return nil
                end
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
        end
    end
    pcall(AntiBan)
end

-- NEON UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKGZ_Neon_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- MAIN FRAME - GLASS MORPHISM
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Config.MenuOpen
MainFrame.Parent = ScreenGui

-- NEON GLOW EFFECT
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 20, 1, 20)
Glow.Position = UDim2.new(0, -10, 0, -10)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5126823676"
Glow.ImageColor3 = Color3.fromRGB(255, 0, 0)
Glow.ImageTransparency = 0.7
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(10, 10, 10, 10)
Glow.Parent = MainFrame

-- CORNERS
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- TITLE BAR - GRADIENT
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
})
TitleGradient.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 KKGZ NEON | TEAM ECHECK"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- CLOSE BUTTON
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.BackgroundTransparency = 0.3
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Config.MenuOpen = false
end)

-- TABS - NEON STYLE
local Tabs = {"⚡ AIMBOT", "👁️ ESP", "⚙️ SETTINGS"}
local CurrentTab = "⚡ AIMBOT"
local TabButtons = {}
local TabFrames = {}

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 40)
TabBar.Position = UDim2.new(0, 10, 0, 55)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local function CreateTab(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 35)
    button.Position = UDim2.new(0, position * 110, 0, 0)
    button.BackgroundColor3 = (name == CurrentTab) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 25, 35)
    button.BackgroundTransparency = (name == CurrentTab) and 0 or 0.3
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = TabBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    if name == CurrentTab then
        local glow = Instance.new("UIStroke")
        glow.Color = Color3.fromRGB(255, 0, 0)
        glow.Thickness = 2
        glow.Transparency = 0.3
        glow.Parent = button
    end
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 1, -120)
    frame.Position = UDim2.new(0, 10, 0, 100)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    frame.Visible = (name == CurrentTab)
    frame.Parent = MainFrame
    
    TabButtons[name] = button
    TabFrames[name] = frame
    
    button.MouseButton1Click:Connect(function()
        CurrentTab = name
        for tabName, tabFrame in pairs(TabFrames) do
            tabFrame.Visible = (tabName == name)
            TabButtons[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 25, 35)
            TabButtons[tabName].BackgroundTransparency = (tabName == name) and 0 or 0.3
        end
    end)
    
    return frame
end

for i, tabName in ipairs(Tabs) do
    CreateTab(tabName, i-1)
end

-- UI ELEMENTS
local YPosition = 0
local function CreateToggle(parent, text, configKey, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.Position = UDim2.new(0, 5, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 50)
    button.BackgroundTransparency = 0.2
    button.Text = ""
    button.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    local statusColor = Instance.new("Frame")
    statusColor.Size = UDim2.new(0, 8, 0, 8)
    statusColor.Position = UDim2.new(0, 15, 0.5, -4)
    statusColor.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    statusColor.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusColor
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 150, 0, 20)
    title.Position = UDim2.new(0, 30, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = button
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(0, 200, 0, 16)
    desc.Position = UDim2.new(0, 30, 0, 22)
    desc.BackgroundTransparency = 1
    desc.Text = description or ""
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = button
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -55, 0.5, -10)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = Config[configKey] and "ON" or "OFF"
    valueLabel.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = button
    
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 50)
        statusColor.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        valueLabel.Text = Config[configKey] and "ON" or "OFF"
        valueLabel.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    YPosition = YPosition + 50
end

local function CreateSlider(parent, text, configKey, min, max, format)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.Position = UDim2.new(0, 5, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Config[configKey])
    valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 25)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 12)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 12)
    fillCorner.Parent = fill
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = input.Position.X - slider.AbsolutePosition.X
            local percentage = math.clamp(relativeX / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor((min + (max - min) * percentage) * 100) / 100
            Config[configKey] = value
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
        end
    end)
    
    YPosition = YPosition + 70
end

local function CreateDropdown(parent, text, configKey, options)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.Position = UDim2.new(0, 5, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, 25)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.Text = Config[configKey]
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 0, 30)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.new(1, 1, 1)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.Parent = button
    
    local dropdownOpen = false
    button.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        for _, child in pairs(frame:GetChildren()) do
            if child.Name == "DropdownItem" then
                child:Destroy()
            end
        end
        
        if dropdownOpen then
            for i, option in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Name = "DropdownItem"
                item.Size = UDim2.new(1, 0, 0, 25)
                item.Position = UDim2.new(0, 0, 0, 60 + (i * 30))
                item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                item.Text = option
                item.TextColor3 = Color3.new(1, 1, 1)
                item.Font = Enum.Font.Gotham
                item.TextSize = 13
                item.Parent = frame
                
                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 6)
                itemCorner.Parent = item
                
                item.MouseButton1Click:Connect(function()
                    Config[configKey] = option
                    button.Text = option
                    dropdownOpen = false
                    for _, child in pairs(frame:GetChildren()) do
                        if child.Name == "DropdownItem" then
                            child:Destroy()
                        end
                    end
                end)
            end
        end
    end)
    
    YPosition = YPosition + 70
end

-- POPULATE TABS
YPosition = 10
local aimbotTab = TabFrames["⚡ AIMBOT"]
CreateToggle(aimbotTab, "Aimbot", "Aimbot", "Lock onto enemies")
CreateToggle(aimbotTab, "Show FOV", "ShowFOV", "Show aimbot range")
CreateToggle(aimbotTab, "Auto Shoot", "AutoShoot", "Auto-fire when on target")
CreateToggle(aimbotTab, "Triggerbot", "Triggerbot", "Auto-fire when crosshair on enemy")
CreateSlider(aimbotTab, "Smoothing", "Smoothing", 0, 0.5, "0.00")
CreateSlider(aimbotTab, "FOV Size", "FOV", 50, 500, "0")
CreateSlider(aimbotTab, "Prediction", "Prediction", 0, 0.5, "0.00")
CreateDropdown(aimbotTab, "Aim Key", "AimKey", {"MouseButton2", "Q", "E", "LeftControl", "LeftShift"})
CreateDropdown(aimbotTab, "Aim Part", "AimPart", {"Head", "HumanoidRootPart", "UpperTorso"})

YPosition = 10
local espTab = TabFrames["👁️ ESP"]
CreateToggle(espTab, "Box ESP", "BoxESP", "Show enemy hitboxes")
CreateToggle(espTab, "Name ESP", "NameESP", "Show player names")
CreateToggle(espTab, "Health ESP", "HealthESP", "Show health bars")
CreateToggle(espTab, "Distance", "DistanceESP", "Show distance in meters")
CreateToggle(espTab, "Tracers", "Tracers", "Draw lines to enemies")
CreateToggle(espTab, "Head Dot", "HeadDot", "Show red dot on heads")

YPosition = 10
local settingsTab = TabFrames["⚙️ SETTINGS"]
CreateToggle(settingsTab, "Watermark", "Watermark", "Show FPS counter")
CreateToggle(settingsTab, "Team Check", "MenuOpen", "Only target enemies") -- Using MenuOpen as placeholder

-- WATERMARK
local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Size = UDim2.new(0, 200, 0, 30)
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.BackgroundTransparency = 0.5
Watermark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Watermark.Text = "KKGZ NEON | FPS: 60 | TEAM ECHECK"
Watermark.TextColor3 = Color3.fromRGB(255, 100, 100)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 14
Watermark.TextStrokeTransparency = 0.8
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = ScreenGui

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 6)
WatermarkCorner.Parent = Watermark

-- FPS UPDATE
spawn(function()
    while Watermark do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        Watermark.Text = "KKGZ NEON | FPS: " .. fps .. " | TEAM ECHECK"
        wait(1)
    end
end)

-- DRAWING OBJECTS
local ESP_Cache = {}
local FOV_Circle = nil

-- FOV CIRCLE
local function CreateFOVCircle()
    if FOV_Circle then FOV_Circle:Remove() end
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Visible = Config.ShowFOV
    FOV_Circle.Color = Config.FOVColor
    FOV_Circle.Thickness = 1.5
    FOV_Circle.NumSides = 64
    FOV_Circle.Filled = false
    FOV_Circle.Radius = Config.FOV
    FOV_Circle.Position = UserInputService:GetMouseLocation()
end

-- FIXED AIMBOT FOR AWM/SNIPERS
local function GetClosestTarget()
    local closest = nil
    local closestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local aimPart = player.Character:FindFirstChild(Config.AimPart) or player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and aimPart then
                -- PREDICTION for moving targets
                local targetPos = aimPart.Position
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and Config.Prediction > 0 then
                    local velocity = rootPart.Velocity
                    targetPos = targetPos + (velocity * Config.Prediction)
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function AimAtTarget(target)
    if not target or not target.Character then return end
    
    local aimPart = target.Character:FindFirstChild(Config.AimPart) or target.Character:FindFirstChild("Head")
    if not aimPart then return end
    
    -- PREDICTION for moving targets (AWM fix)
    local targetPos = aimPart.Position
    local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
    
    if rootPart and Config.Prediction > 0 then
        local velocity = rootPart.Velocity
        -- Less prediction for AWM, more for moving targets
        targetPos = targetPos + (velocity * Config.Prediction * 0.5)
    end
    
    -- AWM ZOOM COMPENSATION
    local cameraCFrame = Camera.CFrame
    
    -- Check if scoped (for AWM)
    local isScoped = false
    local character = LocalPlayer.Character
    if character then
        local weapon = character:FindFirstChildOfClass("Tool")
        if weapon and weapon:FindFirstChild("Scope") then
            isScoped = true
        end
    end
    
    -- Smooth aiming (lower smoothing = faster lock)
    local currentLook = cameraCFrame.LookVector
    local desiredLook = (targetPos - cameraCFrame.Position).Unit
    
    -- AWM needs faster aim
    local smoothMultiplier = isScoped and 0.8 or 1
    local smoothedLook = currentLook:Lerp(desiredLook, 1 - (Config.Smoothing * smoothMultiplier))
    
    Camera.CFrame = CFrame.lookAt(cameraCFrame.Position, cameraCFrame.Position + smoothedLook)
    
    -- AUTO SHOOT
    if Config.AutoShoot then
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse1press()
            wait(0.05)
            mouse1release()
        end
    end
end

-- CHECK AIM KEY
local function IsAimKeyPressed()
    if Config.AimKey == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif Config.AimKey == "Q" then
        return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif Config.AimKey == "E" then
        return UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif Config.AimKey == "LeftControl" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    elseif Config.AimKey == "LeftShift" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    end
    return false
end

-- ESP FUNCTIONS
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for k, v in pairs(properties) do
        drawing[k] = v
    end
    return drawing
end

local function AddESP(player)
    if player == LocalPlayer then return end
    
    local Objects = {
        Box = CreateDrawing("Square", {
            Thickness = 1.5,
            Color = Config.BoxColor,
            Filled = false,
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Text = player.Name,
            Color = Config.NameColor,
            Center = true,
            Outline = true,
            Visible = false,
            Size = 14,
            OutlineColor = Color3.new(0, 0, 0)
        }),
        Health = CreateDrawing("Text", {
            Text = "100 HP",
            Color = Color3.new(0, 1, 0),
            Center = true,
            Outline = true,
            Visible = false,
            Size = 12
        }),
        Distance = CreateDrawing("Text", {
            Text = "0m",
            Color = Color3.new(1, 1, 0),
            Center = true,
            Outline = true,
            Visible = false,
            Size = 12
        }),
        Tracer = CreateDrawing("Line", {
            Thickness = 1.5,
            Color = Config.TracerColor,
            Visible = false
        }),
        HeadDot = CreateDrawing("Circle", {
            Radius = 4,
            Color = Config.HeadDotColor,
            Filled = true,
            Visible = false,
            NumSides = 32
        })
    }
    
    ESP_Cache[player] = Objects
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, drawing in pairs(ESP_Cache[player]) do
            drawing:Remove()
        end
        ESP_Cache[player] = nil
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if FOV_Circle then
        FOV_Circle.Visible = Config.ShowFOV
        FOV_Circle.Radius = Config.FOV
        FOV_Circle.Position = UserInputService:GetMouseLocation()
    end
    
    -- Update Watermark
    if Watermark then
        Watermark.Visible = Config.Watermark
    end
    
    -- Update ESP
    for player, objects in pairs(ESP_Cache) do
        if not IsEnemy(player) then
            for _, drawing in pairs(objects) do
                drawing.Visible = false
            end
            continue
        end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Box ESP
                    if Config.BoxESP then
                        local headVec = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legVec = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                        local height = legVec.Y - headVec.Y
                        local width = height / 2
                        
                        objects.Box.Visible = true
                        objects.Box.Size = Vector2.new(width, height)
                        objects.Box.Position = Vector2.new(vector.X - width / 2, headVec.Y)
                    else
                        objects.Box.Visible = false
                    end
                    
                    -- Name ESP
                    if Config.NameESP then
                        objects.Name.Visible = true
                        objects.Name.Position = Vector2.new(vector.X, headVec.Y - 25)
                        objects.Name.Text = player.Name .. (IsEnemy(player) and " [ENEMY]" or " [FRIEND]")
                    else
                        objects.Name.Visible = false
                    end
                    
                    -- Health ESP
                    if Config.HealthESP then
                        objects.Health.Text = math.floor(humanoid.Health) .. " HP"
                        objects.Health.Visible = true
                        objects.Health.Position = Vector2.new(vector.X, headVec.Y - 10)
                        objects.Health.Color = Color3.new(1 - humanoid.Health/100, humanoid.Health/100, 0)
                    else
                        objects.Health.Visible = false
                    end
                    
                    -- Distance ESP
                    if Config.DistanceESP then
                        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                        objects.Distance.Text = math.floor(distance) .. "m"
                        objects.Distance.Visible = true
                        objects.Distance.Position = Vector2.new(vector.X, legVec.Y + 10)
                    else
                        objects.Distance.Visible = false
                    end
                    
                    -- Tracers
                    if Config.Tracers then
                        objects.Tracer.Visible = true
                        objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        objects.Tracer.To = Vector2.new(vector.X, vector.Y)
                    else
                        objects.Tracer.Visible = false
                    end
                    
                    -- Head Dot
                    if Config.HeadDot then
                        objects.HeadDot.Visible = true
                        objects.HeadDot.Position = Vector2.new(vector.X, vector.Y)
                    else
                        objects.HeadDot.Visible = false
                    end
                else
                    for _, drawing in pairs(objects) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(objects) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(objects) do
                drawing.Visible = false
            end
        end
    end
    
    -- AIMBOT (Fixed for AWM/Snipers)
    if Config.Aimbot and IsAimKeyPressed() then
        local target = GetClosestTarget()
        if target then
            AimAtTarget(target)
        end
    end
end)

-- Initialize
for _, player in pairs(Players:GetPlayers()) do
    AddESP(player)
end

Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

CreateFOVCircle()

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.MenuOpen = not Config.MenuOpen
        MainFrame.Visible = Config.MenuOpen
    elseif input.KeyCode == Enum.KeyCode.Delete then
        ScreenGui:Destroy()
        if FOV_Circle then FOV_Circle:Remove() end
        for _, objects in pairs(ESP_Cache) do
            for _, drawing in pairs(objects) do
                drawing:Remove()
            end
        end
        ESP_Cache = {}
    end
end)

print("==================================")
print("KKGZ NEON LOADED")
print("==================================")
