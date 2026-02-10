local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Anti-Ban Protection
do
    local function AntiBan()
        -- Generate random name for script
        local randomId = HttpService:GenerateGUID(false)
        pcall(function() script.Name = "Module_" .. randomId end)
        
        -- Hook critical functions
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            local oldIndex = mt.__index
            
            setreadonly(mt, false)
            
            -- Block kick function
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" then
                    warn("[KKGZ] Kick attempt blocked")
                    return nil
                end
                return oldNamecall(self, ...)
            end)
            
            -- Block teleport
            mt.__index = newcclosure(function(self, key)
                if tostring(key):lower() == "teleport" then
                    return function() warn("[KKGZ] Teleport blocked") end
                end
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
        end
        
        -- Randomize wait timing
        local oldWait = wait
        wait = function(t)
            return oldWait(t + math.random(-20, 20) / 1000)
        end
        
        print("[KKGZ] Anti-ban protection activated")
    end
    
    -- Execute anti-ban
    pcall(AntiBan)
end

-- Configuration
local Config = {
    -- ESP
    BoxESP = true,
    NameESP = true,
    HealthESP = true,
    DistanceESP = true,
    Tracers = true,
    
    -- Aimbot
    Aimbot = true,
    AimKey = "MouseButton2", -- "MouseButton2", "Q", "E", "LeftControl"
    AimPart = "Head", -- "Head", "HumanoidRootPart", "UpperTorso"
    Smoothing = 0.3, -- 0 = instant, 1 = smooth
    FOV = 250,
    ShowFOV = true,
    
    -- Visual
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 100, 0),
    
    -- UI
    MenuOpen = true,
    Watermark = true
}

-- Drawing Library
local DrawingLib = {
    Fonts = {
        UI = 2, -- 0: Default, 1: System, 2: Bold
        ESP = 1
    }
}

-- Drawing Cache
local ESP_Cache = {}
local FOV_Circle = nil
local Watermark = nil

-- UI Setup with better design
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKGZ_Menu_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if pcall(function() ScreenGui.Parent = CoreGui end) then
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Modern Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Config.MenuOpen
MainFrame.Parent = ScreenGui

-- Background Blur
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "KKGZ MENU"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextStrokeTransparency = 0
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Config.MenuOpen = false
end)

-- Tabs System
local Tabs = {"Visual", "Aimbot", "Misc"}
local CurrentTab = "Visual"

local TabButtons = {}
local TabFrames = {}

-- Function to create tabs
local function CreateTab(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0, 10 + (position * 105), 0, 50)
    button.BackgroundColor3 = (name == CurrentTab) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansSemibold
    button.TextSize = 14
    button.Parent = MainFrame
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 1, -100)
    frame.Position = UDim2.new(0, 10, 0, 90)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 2
    frame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    frame.Visible = (name == CurrentTab)
    frame.Parent = MainFrame
    
    TabButtons[name] = button
    TabFrames[name] = frame
    
    button.MouseButton1Click:Connect(function()
        CurrentTab = name
        for tabName, tabFrame in pairs(TabFrames) do
            tabFrame.Visible = (tabName == name)
            TabButtons[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
        end
    end)
    
    return frame
end

-- Create all tabs
for i, tabName in ipairs(Tabs) do
    CreateTab(tabName, i-1)
end

-- Create toggle function
local YPosition = 0
local function CreateToggle(parent, text, configKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    button.Text = "  " .. text .. ": " .. (Config[configKey] and "ON" or "OFF")
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        button.Text = "  " .. text .. ": " .. (Config[configKey] and "ON" or "OFF")
        button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
    
    YPosition = YPosition + 40
end

-- Create slider function
local function CreateSlider(parent, text, configKey, min, max)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. Config[configKey]
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
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
            local value = math.floor((min + (max - min) * percentage) * 10) / 10
            Config[configKey] = value
            label.Text = text .. ": " .. value
            fill.Size = UDim2.new(percentage, 0, 1, 0)
        end
    end)
    
    YPosition = YPosition + 55
end

-- Create dropdown function
local function CreateDropdown(parent, text, configKey, options)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = Config[configKey]
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    local dropdownOpen = false
    button.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        -- Clear previous dropdown
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
                item.Position = UDim2.new(0, 0, 0, 55 + (i * 30))
                item.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                item.Text = option
                item.TextColor3 = Color3.new(1, 1, 1)
                item.Font = Enum.Font.SourceSans
                item.TextSize = 12
                item.Parent = frame
                
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
    
    YPosition = YPosition + 45
end

-- Populate tabs
-- Visual Tab
YPosition = 0
local visualTab = TabFrames["Visual"]
CreateToggle(visualTab, "Box ESP", "BoxESP")
CreateToggle(visualTab, "Name ESP", "NameESP")
CreateToggle(visualTab, "Health ESP", "HealthESP")
CreateToggle(visualTab, "Distance ESP", "DistanceESP")
CreateToggle(visualTab, "Tracers", "Tracers")

-- Aimbot Tab
YPosition = 0
local aimbotTab = TabFrames["Aimbot"]
CreateToggle(aimbotTab, "Aimbot", "Aimbot")
CreateToggle(aimbotTab, "Show FOV Circle", "ShowFOV")
CreateSlider(aimbotTab, "Aim Smoothing", "Smoothing", 0, 1)
CreateSlider(aimbotTab, "FOV Size", "FOV", 50, 500)
CreateDropdown(aimbotTab, "Aim Key", "AimKey", {"MouseButton2", "Q", "E", "LeftControl", "LeftShift"})
CreateDropdown(aimbotTab, "Aim Part", "AimPart", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"})

-- Misc Tab
YPosition = 0
local miscTab = TabFrames["Misc"]
CreateToggle(miscTab, "Watermark", "Watermark")
CreateToggle(miscTab, "Anti-Ban Protection", "MenuOpen") -- Using MenuOpen as placeholder

-- Create FOV Circle
local function CreateFOVCircle()
    if FOV_Circle then FOV_Circle:Remove() end
    
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Visible = Config.ShowFOV
    FOV_Circle.Color = Color3.new(1, 1, 1)
    FOV_Circle.Thickness = 1
    FOV_Circle.NumSides = 64
    FOV_Circle.Filled = false
    FOV_Circle.Radius = Config.FOV
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- ESP Functions
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
            Thickness = 1,
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
            Size = 14
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
            Thickness = 1,
            Color = Config.TracerColor,
            Visible = false
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

-- Aimbot Functions
local function GetClosestTarget()
    local closest = nil
    local closestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local aimPart = player.Character:FindFirstChild(Config.AimPart) or player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                
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
    
    -- Calculate aim direction
    local cameraCFrame = Camera.CFrame
    local targetPosition = aimPart.Position + Vector3.new(0, 0.2, 0) -- Small offset for head
    
    -- Smooth aiming
    local currentLook = cameraCFrame.LookVector
    local desiredLook = (targetPosition - cameraCFrame.Position).Unit
    local smoothedLook = currentLook:Lerp(desiredLook, 1 - Config.Smoothing)
    
    -- Apply aim
    Camera.CFrame = CFrame.lookAt(cameraCFrame.Position, cameraCFrame.Position + smoothedLook)
end

-- Check if aim key is pressed
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

-- Main Update Loop
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
        if not player.Parent then
            RemoveESP(player)
            continue
        end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character.HumanoidRootPart
            
            if humanoid and humanoid.Health > 0 then
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    -- Box ESP
                    if Config.BoxESP then
                        local head = character:FindFirstChild("Head")
                        if head then
                            local headVec = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legVec = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                            local height = legVec.Y - headVec.Y
                            local width = height / 2
                            
                            objects.Box.Visible = true
                            objects.Box.Size = Vector2.new(width, height)
                            objects.Box.Position = Vector2.new(vector.X - width / 2, headVec.Y)
                        end
                    else
                        objects.Box.Visible = false
                    end
                    
                    -- Name ESP
                    if Config.NameESP then
                        objects.Name.Visible = true
                        objects.Name.Position = Vector2.new(vector.X, vector.Y - 25)
                    else
                        objects.Name.Visible = false
                    end
                    
                    -- Health ESP
                    if Config.HealthESP then
                        objects.Health.Text = math.floor(humanoid.Health) .. " HP"
                        objects.Health.Visible = true
                        objects.Health.Position = Vector2.new(vector.X, vector.Y - 10)
                        objects.Health.Color = Color3.new(1 - humanoid.Health/100, humanoid.Health/100, 0)
                    else
                        objects.Health.Visible = false
                    end
                    
                    -- Distance ESP
                    if Config.DistanceESP then
                        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                        objects.Distance.Text = math.floor(distance) .. "m"
                        objects.Distance.Visible = true
                        objects.Distance.Position = Vector2.new(vector.X, vector.Y + 15)
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
    
    -- Aimbot
    if Config.Aimbot and IsAimKeyPressed() then
        local target = GetClosestTarget()
        if target then
            AimAtTarget(target)
        end
    end
end)

-- Player Events
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Initialize ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    AddESP(player)
end

-- Initialize drawing objects
CreateFOVCircle()

-- Menu Toggle Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuOpen = not Config.MenuOpen
        MainFrame.Visible = Config.MenuOpen
    elseif input.KeyCode == Enum.KeyCode.Delete then
        -- Clean exit
        ScreenGui:Destroy()
        if Watermark then Watermark:Remove() end
        if FOV_Circle then FOV_Circle:Remove() end
        for _, objects in pairs(ESP_Cache) do
            for _, drawing in pairs(objects) do
                drawing:Remove()
            end
        end
        ESP_Cache = {}
        print("KKGZ MENU unloaded")
    end
end)

-- Final notification
local Notification = Instance.new("ScreenGui")
Notification.Name = "KKGZ_Notification"
Notification.Parent = CoreGui

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Size = UDim2.new(0, 300, 0, 80)
NotifyFrame.Position = UDim2.new(1, -310, 1, -90)
NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotifyFrame.BorderSizePixel = 0
NotifyFrame.Parent = Notification

local NotifyCorner = Instance.new("UICorner")
NotifyCorner.CornerRadius = UDim.new(0, 8)
NotifyCorner.Parent = NotifyFrame

local NotifyStroke = Instance.new("UIStroke")
NotifyStroke.Color = Color3.fromRGB(255, 0, 0)
NotifyStroke.Thickness = 2
NotifyStroke.Parent = NotifyFrame

local NotifyText = Instance.new("TextLabel")
NotifyText.Size = UDim2.new(1, -10, 1, -10)
NotifyText.Position = UDim2.new(0, 5, 0, 5)
NotifyText.BackgroundTransparency = 1
NotifyText.Text = "KKGZ MENU LOADED\nAimbot: Right Click\nESP: Enabled\nAnti-Ban: Active\nMenu: Insert"
NotifyText.TextColor3 = Color3.fromRGB(0, 255, 0)
NotifyText.Font = Enum.Font.SourceSansBold
NotifyText.TextSize = 14
NotifyText.Parent = NotifyFrame

-- Auto remove notification
spawn(function()
    wait(8)
    Notification:Destroy()
end)

print("==================================")
print("KKGZ MENU LOADED")
print("Aimbot Key: " .. Config.AimKey)
print("==================================")
