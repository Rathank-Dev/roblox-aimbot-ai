local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

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
    Wallhack = true, -- See through walls
    
    -- Aimbot
    Aimbot = true,
    AimKey = "MouseButton2",
    AimPart = "Head",
    Smoothing = 0.3,
    FOV = 250,
    ShowFOV = true,
    SilentAim = false,
    Aimlock = false,
    
    -- Speed & Movement
    Speed = false,
    SpeedAmount = 32,
    Fly = false,
    FlySpeed = 50,
    JumpPower = false,
    JumpPowerAmount = 100,
    NoClip = false,
    
    -- Combat
    AutoKill = false,
    KillAll = false,
    KillRange = 50,
    OneHitKill = false,
    InfiniteAmmo = false,
    NoCooldown = false,
    
    -- Visual
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 100, 0),
    WallhackColor = Color3.fromRGB(0, 255, 255),
    
    -- Server
    ServerHop = false,
    Rejoin = false,
    CrashServer = false,
    SpamChat = false,
    ChatMessage = "KKGZ OWNED THIS SERVER",
    
    -- UI
    MenuOpen = true,
    Watermark = true
}

-- Drawing Library
local DrawingLib = {
    Fonts = {
        UI = 2,
        ESP = 1
    }
}

-- Drawing Cache
local ESP_Cache = {}
local FOV_Circle = nil
local Watermark = nil

-- Speed variables
local speedConnection = nil
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil

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
MainFrame.Size = UDim2.new(0, 400, 0, 600) -- Larger for more options
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
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
Title.Text = "KKGZ MENU - ULTIMATE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
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
local Tabs = {"ESP", "Aimbot", "Movement", "Combat", "Server", "Settings"}
local CurrentTab = "ESP"

local TabButtons = {}
local TabFrames = {}

-- Function to create tabs
local function CreateTab(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 30)
    button.Position = UDim2.new(0, 5 + (position * 80), 0, 50)
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
    frame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Extra space for scrolling
    
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
local function CreateToggle(parent, text, configKey, callback)
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
        
        if callback then
            callback(Config[configKey])
        end
    end)
    
    YPosition = YPosition + 40
end

-- Create slider function
local function CreateSlider(parent, text, configKey, min, max, isFloat)
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
            local value = min + (max - min) * percentage
            if not isFloat then
                value = math.floor(value)
            else
                value = math.floor(value * 10) / 10
            end
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

-- Create button function
local function CreateButton(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, YPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    YPosition = YPosition + 45
end

-- Populate tabs
-- ESP Tab
YPosition = 0
local espTab = TabFrames["ESP"]
CreateToggle(espTab, "Box ESP", "BoxESP")
CreateToggle(espTab, "Name ESP", "NameESP")
CreateToggle(espTab, "Health ESP", "HealthESP")
CreateToggle(espTab, "Distance ESP", "DistanceESP")
CreateToggle(espTab, "Tracers", "Tracers")
CreateToggle(espTab, "Wallhack (See Through Walls)", "Wallhack")

-- Aimbot Tab
YPosition = 0
local aimbotTab = TabFrames["Aimbot"]
CreateToggle(aimbotTab, "Aimbot", "Aimbot")
CreateToggle(aimbotTab, "Show FOV Circle", "ShowFOV")
CreateToggle(aimbotTab, "Silent Aim", "SilentAim")
CreateToggle(aimbotTab, "Aimlock", "Aimlock")
CreateSlider(aimbotTab, "Aim Smoothing", "Smoothing", 0, 1, true)
CreateSlider(aimbotTab, "FOV Size", "FOV", 50, 500)
CreateDropdown(aimbotTab, "Aim Key", "AimKey", {"MouseButton2", "Q", "E", "LeftControl", "LeftShift"})
CreateDropdown(aimbotTab, "Aim Part", "AimPart", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"})

-- Movement Tab
YPosition = 0
local moveTab = TabFrames["Movement"]
CreateToggle(moveTab, "Speed Hack", "Speed", function(enabled)
    if enabled then
        enableSpeed()
    else
        disableSpeed()
    end
end)
CreateSlider(moveTab, "Speed Amount", "SpeedAmount", 16, 500)
CreateToggle(moveTab, "Fly Hack", "Fly", function(enabled)
    if enabled then
        enableFly()
    else
        disableFly()
    end
end)
CreateSlider(moveTab, "Fly Speed", "FlySpeed", 10, 200)
CreateToggle(moveTab, "High Jump", "JumpPower", function(enabled)
    if enabled then
        LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPowerAmount
    else
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)
CreateSlider(moveTab, "Jump Power", "JumpPowerAmount", 50, 500)
CreateToggle(moveTab, "NoClip", "NoClip")

-- Combat Tab
YPosition = 0
local combatTab = TabFrames["Combat"]
CreateToggle(combatTab, "Auto Kill (Aimbot)", "AutoKill")
CreateButton(combatTab, "KILL ALL PLAYERS", function()
    killAllPlayers()
end)
CreateSlider(combatTab, "Kill Range", "KillRange", 10, 500)
CreateToggle(combatTab, "One Hit Kill", "OneHitKill")
CreateToggle(combatTab, "Infinite Ammo", "InfiniteAmmo")
CreateToggle(combatTab, "No Cooldown", "NoCooldown")

-- Server Tab
YPosition = 0
local serverTab = TabFrames["Server"]
CreateButton(serverTab, "SERVER HOP", function()
    serverHop()
end)
CreateButton(serverTab, "REJOIN SERVER", function()
    rejoinServer()
end)
CreateButton(serverTab, "CRASH SERVER (DDOS)", function()
    crashServer()
end)
CreateToggle(serverTab, "Spam Chat", "SpamChat")
CreateDropdown(serverTab, "Chat Message", "ChatMessage", {"KKGZ OWNED THIS SERVER", "GET REKT", "SERVER CRASHED BY KKGZ", "L + RATIO + KKGZ"})

-- Settings Tab
YPosition = 0
local settingsTab = TabFrames["Settings"]
CreateToggle(settingsTab, "Watermark", "Watermark")
CreateToggle(settingsTab, "Anti-Ban Protection", "AntiBan")
CreateButton(settingsTab, "UNLOAD SCRIPT", function()
    unloadScript()
end)

-- Speed function
function enableSpeed()
    if speedConnection then
        speedConnection:Disconnect()
    end
    speedConnection = RunService.RenderStepped:Connect(function()
        if Config.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            humanoid.WalkSpeed = Config.SpeedAmount
        elseif speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
    end)
end

function disableSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

-- Fly function
function enableFly()
    if flyConnection then
        flyConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    humanoid.PlatformStand = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    flyBodyVelocity.Parent = rootPart
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    flyBodyGyro.Parent = rootPart
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Config.Fly or not LocalPlayer.Character then
            disableFly()
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        local cameraCFrame = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Config.FlySpeed
        end
        
        flyBodyVelocity.Velocity = moveDirection
        flyBodyGyro.CFrame = cameraCFrame
    end)
end

function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

-- Kill All Players function
function killAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end
    end
    print("[KKGZ] Killed all players")
end

-- Server Hop function
function serverHop()
    local x = {}
    for _, v in ipairs(Players:GetPlayers()) do
        table.insert(x, v.Name)
    end
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- Rejoin Server function
function rejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
end

-- Crash Server function
function crashServer()
    -- Method 1: Create many parts
    for i = 1, 1000 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(1000, 1000, 1000)
        part.Position = Vector3.new(math.random(-10000, 10000), math.random(-10000, 10000), math.random(-10000, 10000))
        part.Anchored = true
        part.Parent = Workspace
    end
    
    -- Method 2: Spam remote events
    for i = 1, 500 do
        local remote = Instance.new("RemoteEvent")
        remote.Name = "CrashRemote_" .. i
        remote.Parent = ReplicatedStorage
        remote:FireServer("CRASH")
    end
    
    -- Method 3: Infinite loop
    while true do
        local part = Instance.new("Part")
        part.Parent = Workspace
        task.wait()
    end
    
    print("[KKGZ] Server crash initiated")
end

-- Unload Script function
function unloadScript()
    -- Disable all features
    Config.Speed = false
    disableSpeed()
    Config.Fly = false
    disableFly()
    
    -- Clean up GUI
    ScreenGui:Destroy()
    
    -- Remove drawings
    if Watermark then Watermark:Remove() end
    if FOV_Circle then FOV_Circle:Remove() end
    for _, objects in pairs(ESP_Cache) do
        for _, drawing in pairs(objects) do
            drawing:Remove()
        end
    end
    ESP_Cache = {}
    
    print("[KKGZ] Script unloaded")
end

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
    
    -- Auto kill if enabled
    if Config.AutoKill and target.Character then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
    end
    
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

-- NoClip function
local function handleNoClip()
    if not Config.NoClip then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Infinite Ammo function
local function handleInfiniteAmmo()
    if not Config.InfiniteAmmo then return end
    
    -- This depends on the game's weapon system
    -- Generic approach: look for ammo values in tools
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local ammo = tool:FindFirstChild("Ammo")
            if ammo and ammo:IsA("NumberValue") then
                ammo.Value = 9999
            end
        end
    end
end

-- No Cooldown function
local function handleNoCooldown()
    if not Config.NoCooldown then return end
    
    -- This depends on the game's cooldown system
    -- Generic approach: look for cooldown values in player scripts
end

-- Spam Chat function
local function spamChat()
    if not Config.SpamChat then return end
    
    local chatService = game:GetService("Chat")
    for i = 1, 10 do
        chatService:Chat(LocalPlayer.Character.Head, Config.ChatMessage, Enum.ChatColor.Red)
        wait(0.1)
    end
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
    
    -- Handle NoClip
    handleNoClip()
    
    -- Handle Infinite Ammo
    handleInfiniteAmmo()
    
    -- Handle No Cooldown
    handleNoCooldown()
    
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
                
                -- Wallhack: Show ESP even if not on screen
                if Config.Wallhack then
                    onScreen = true
                end
                
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
                            
                            -- Change color for wallhack
                            if Config.Wallhack then
                                objects.Box.Color = Config.WallhackColor
                            else
                                objects.Box.Color = Config.BoxColor
                            end
                        end
                    else
                        objects.Box.Visible = false
                    end
                    
                    -- Name ESP
                    if Config.NameESP then
                        objects.Name.Visible = true
                        objects.Name.Position = Vector2.new(vector.X, vector.Y - 25)
                        if Config.Wallhack then
                            objects.Name.Color = Config.WallhackColor
                        end
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
    
    -- One Hit Kill
    if Config.OneHitKill then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.MaxHealth = 1
                end
            end
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
        unloadScript()
    end
end)

-- Final notification
local Notification = Instance.new("ScreenGui")
Notification.Name = "KKGZ_Notification"
Notification.Parent = CoreGui

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Size = UDim2.new(0, 350, 0, 120)
NotifyFrame.Position = UDim2.new(1, -360, 1, -130)
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
NotifyText.Text = "KKGZ MENU ULTIMATE LOADED\nFeatures: Speed | Fly | Wallhack | Auto Kill | Server Crash\nAimbot: Right Click | Menu: Insert | Unload: Delete"
NotifyText.TextColor3 = Color3.fromRGB(0, 255, 0)
NotifyText.Font = Enum.Font.SourceSansBold
NotifyText.TextSize = 14
NotifyText.TextWrapped = true
NotifyText.Parent = NotifyFrame

-- Auto remove notification
spawn(function()
    wait(10)
    Notification:Destroy()
end)

print("==================================")
print("KKGZ MENU ULTIMATE LOADED")
print("Aimbot Key: " .. Config.AimKey)
print("Menu: INSERT | Unload: DELETE")
print("Features: Speed, Fly, Wallhack, Auto Kill, Server Crash")
print("==================================")
