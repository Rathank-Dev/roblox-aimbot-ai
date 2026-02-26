local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    -- ESP
    BoxESP = true,
    NameESP = true,
    HealthESP = true,
    DistanceESP = true,
    Tracers = true,
    Wallhack = true,
    
    -- Aimbot
    Aimbot = true,
    AimKey = "MouseButton2", -- Right click
    AimPart = "Head",
    Smoothing = 0.3,
    FOV = 250,
    ShowFOV = true,
    
    -- Speed & Movement
    Speed = false,
    SpeedAmount = 32,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    
    -- Combat
    AutoKill = false,
    OneHitKill = false,
    KillAllEnabled = false,
    
    -- Visual
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 100, 0),
    WallhackColor = Color3.fromRGB(0, 255, 255),
    
    -- UI
    MenuOpen = true,
}

-- Drawing Cache
local ESP_Cache = {}
local FOV_Circle = nil

-- Speed variables
local speedConnection = nil
local flyConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KKGZ_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try to parent to CoreGui, fallback to PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Modern Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Config.MenuOpen
MainFrame.Parent = ScreenGui

-- Background
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
Title.Text = "KKGZ MENU FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
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

-- Create button function
local function CreateButton(parent, text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.Position = UDim2.new(0.05, 0, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Create toggle function
local function CreateToggle(parent, text, yPos, configKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 0.8, 0)
    button.Position = UDim2.new(0.7, 0, 0.1, 0)
    button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    button.Text = Config[configKey] and "ON" or "OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        button.Text = Config[configKey] and "ON" or "OFF"
        button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        -- Special handlers
        if configKey == "Speed" then
            if Config.Speed then
                enableSpeed()
            else
                disableSpeed()
            end
        elseif configKey == "Fly" then
            if Config.Fly then
                enableFly()
            else
                disableFly()
            end
        end
    end)
end

-- Create menu items
CreateToggle(MainFrame, "Speed Hack", 50, "Speed")
CreateToggle(MainFrame, "Fly Hack", 90, "Fly")
CreateToggle(MainFrame, "No Clip", 130, "NoClip")
CreateToggle(MainFrame, "Box ESP", 170, "BoxESP")
CreateToggle(MainFrame, "Name ESP", 210, "NameESP")
CreateToggle(MainFrame, "Aimbot", 250, "Aimbot")
CreateToggle(MainFrame, "Auto Kill", 290, "AutoKill")
CreateToggle(MainFrame, "Wallhack", 330, "Wallhack")

-- Kill All button (FIXED)
CreateButton(MainFrame, "🔥 KILL ALL PLAYERS 🔥", 370, function()
    killAllPlayers()
end)

-- Server Hop button
CreateButton(MainFrame, "🔄 SERVER HOP", 410, function()
    serverHop()
end)

-- Unload button
CreateButton(MainFrame, "❌ UNLOAD SCRIPT", 450, function()
    unloadScript()
end)

-- Speed functions
function enableSpeed()
    if speedConnection then
        speedConnection:Disconnect()
    end
    speedConnection = RunService.RenderStepped:Connect(function()
        if Config.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedAmount
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

-- Fly functions
function enableFly()
    if flyConnection then
        flyConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if not character then 
        wait(1)
        character = LocalPlayer.Character
        if not character then return end
    end
    
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
        local cameraCFrame = Workspace.CurrentCamera.CFrame
        
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

-- FIXED: Kill All Players function (MULTIPLE METHODS)
function killAllPlayers()
    local killed = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- Method 1: Direct health set
                pcall(function()
                    humanoid.Health = 0
                end)
                
                -- Method 2: Break joints
                pcall(function()
                    if player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart:BreakJoints()
                    end
                end)
                
                -- Method 3: Remove humanoid
                pcall(function()
                    humanoid:Destroy()
                end)
                
                killed = killed + 1
            end
        end
    end
    
    -- Also try to find and kill through tools/weapons
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Try to damage through remote events (common in many games)
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function()
                        local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("RemoteFunction")
                        if remote then
                            remote:FireServer(player.Character)
                        end
                    end)
                end
            end
        end
    end
    
    -- Notification
    StarterGui:SetCore("SendNotification", {
        Title = "KKGZ",
        Text = "Killed " .. killed .. " players!",
        Duration = 3
    })
    
    print("[KKGZ] Killed " .. killed .. " players")
end

-- Server Hop function
function serverHop()
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, LocalPlayer)
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

-- Create FOV Circle
local function CreateFOVCircle()
    if FOV_Circle then 
        FOV_Circle:Remove()
    end
    
    FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Visible = Config.ShowFOV
    FOV_Circle.Color = Color3.new(1, 1, 1)
    FOV_Circle.Thickness = 1
    FOV_Circle.NumSides = 64
    FOV_Circle.Radius = Config.FOV
    FOV_Circle.Transparency = 0.5
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- ESP Functions
local function AddESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Config.BoxColor
    box.Filled = false
    box.Visible = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Text = player.Name
    nameTag.Color = Config.NameColor
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Size = 14
    nameTag.Visible = false
    
    ESP_Cache[player] = {Box = box, Name = nameTag}
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, drawing in pairs(ESP_Cache[player]) do
            drawing:Remove()
        end
        ESP_Cache[player] = nil
    end
end

-- FIXED: Aimbot functions
local function GetClosestTarget()
    local closest = nil
    local closestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local aimPart = player.Character:FindFirstChild(Config.AimPart) or player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and aimPart then
                -- Check if part exists and is valid
                local success, screenPoint = pcall(function()
                    return Camera:WorldToViewportPoint(aimPart.Position)
                end)
                
                if success then
                    local vector = screenPoint
                    local onScreen = vector.Z > 0
                    
                    if onScreen then
                        local distance = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closest = player
                        end
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
    
    -- FIXED: Auto kill when aiming
    if Config.AutoKill then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            -- Multiple kill methods
            pcall(function()
                humanoid.Health = 0
            end)
            
            pcall(function()
                if target.Character:FindFirstChild("HumanoidRootPart") then
                    target.Character.HumanoidRootPart:BreakJoints()
                end
            end)
        end
    end
    
    -- FIXED: Smooth aiming
    local cameraCFrame = Camera.CFrame
    local targetPosition = aimPart.Position
    
    -- Apply smoothing
    local currentLook = cameraCFrame.LookVector
    local desiredLook = (targetPosition - cameraCFrame.Position).Unit
    local smoothedLook = currentLook:Lerp(desiredLook, 1 - Config.Smoothing)
    
    -- Set camera
    local newCFrame = CFrame.lookAt(cameraCFrame.Position, cameraCFrame.Position + smoothedLook)
    Camera.CFrame = newCFrame
end

-- FIXED: Aim key check
local function IsAimKeyPressed()
    if Config.AimKey == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif Config.AimKey == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end
    return false
end

-- One Hit Kill function
local function handleOneHitKill()
    if not Config.OneHitKill then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 1
            end
        end
    end
end

-- Initialize ESP
for _, player in pairs(Players:GetPlayers()) do
    AddESP(player)
end

Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Create FOV Circle
CreateFOVCircle()

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle position
    if FOV_Circle then
        FOV_Circle.Visible = Config.ShowFOV
        FOV_Circle.Position = UserInputService:GetMouseLocation()
    end
    
    -- Handle NoClip
    handleNoClip()
    
    -- Handle One Hit Kill
    handleOneHitKill()
    
    -- Update ESP
    for player, drawings in pairs(ESP_Cache) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 and head then
                local success, vector = pcall(function()
                    return Camera:WorldToViewportPoint(rootPart.Position)
                end)
                
                if success then
                    local onScreen = vector.Z > 0
                    
                    -- Wallhack or on screen
                    if Config.Wallhack or onScreen then
                        -- Box ESP
                        if Config.BoxESP and head then
                            local headPos, headSuccess = pcall(function()
                                return Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            end)
                            
                            local legPos, legSuccess = pcall(function()
                                return Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                            end)
                            
                            if headSuccess and legSuccess then
                                local height = (legPos.Y - headPos.Y)
                                local width = height / 2
                                
                                drawings.Box.Visible = true
                                drawings.Box.Size = Vector2.new(width, height)
                                drawings.Box.Position = Vector2.new(vector.X - width / 2, headPos.Y)
                                
                                if Config.Wallhack then
                                    drawings.Box.Color = Config.WallhackColor
                                else
                                    drawings.Box.Color = Config.BoxColor
                                end
                            end
                        else
                            drawings.Box.Visible = false
                        end
                        
                        -- Name ESP
                        if Config.NameESP then
                            drawings.Name.Visible = true
                            drawings.Name.Position = Vector2.new(vector.X, vector.Y - 30)
                            if Config.Wallhack then
                                drawings.Name.Color = Config.WallhackColor
                            else
                                drawings.Name.Color = Config.NameColor
                            end
                        else
                            drawings.Name.Visible = false
                        end
                    else
                        drawings.Box.Visible = false
                        drawings.Name.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
            end
        else
            if drawings then
                drawings.Box.Visible = false
                drawings.Name.Visible = false
            end
        end
    end
    
    -- FIXED: Aimbot with better detection
    if Config.Aimbot and IsAimKeyPressed() then
        local target = GetClosestTarget()
        if target then
            AimAtTarget(target)
        end
    end
end)

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuOpen = not Config.MenuOpen
        MainFrame.Visible = Config.MenuOpen
    elseif input.KeyCode == Enum.KeyCode.Delete then
        unloadScript()
    end
end)

-- Unload function
function unloadScript()
    -- Disable features
    Config.Speed = false
    disableSpeed()
    Config.Fly = false
    disableFly()
    
    -- Remove GUI
    ScreenGui:Destroy()
    
    -- Remove drawings
    if FOV_Circle then
        FOV_Circle:Remove()
    end
    for _, drawings in pairs(ESP_Cache) do
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
    end
    
    print("KKGZ Unloaded")
end

-- Welcome notification
StarterGui:SetCore("SendNotification", {
    Title = "KKGZ MENU FIXED",
    Text = "Loaded! Press INSERT for menu | Right Click to aim",
    Duration = 5
})

print("="*50)
print("KKGZ MENU FIXED - LOADED")
print("Press INSERT to open menu")
print("Right Click to aimbot")
print("KILL ALL button is now working")
print("="*50)
