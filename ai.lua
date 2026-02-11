-- KKG-Z UNIVERSAL AIMBOT + ESP PANEL v4.0
-- Complete GUI | Team Check | FOV System | Anti-Ban | Full ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Wait for player
repeat task.wait() until LocalPlayer

-- Anti-Ban Protection System
local AntiBan = {
    Active = true,
    SafeMode = false,
    DetectionCount = 0,
    SessionID = HttpService:GenerateGUID(false):sub(1, 8),
    
    BlockedMethods = {
        "Kick", "kick", "Ban", "ban", "Shutdown", "shutdown",
        "Crash", "crash", "Detect", "detect", "Log", "log"
    },
    
    FakeValues = {},
    
    Init = function(self)
        -- Create fake values to confuse anti-cheat
        for i = 1, 10 do
            local fake = Instance.new("StringValue")
            fake.Name = "AntiCheat_" .. math.random(1000, 9999)
            fake.Value = "Clean"
            fake.Parent = game:GetService("CoreGui")
            table.insert(self.FakeValues, fake)
        end
        
        -- Hook namecall for protection
        local oldNamecall = hookmetamethod and hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            local args = {...}
            
            for _, blocked in ipairs(self.BlockedMethods) do
                if method == blocked then
                    warn("[KKG-Z] Blocked: " .. tostring(method))
                    return nil
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        print("[KKG-Z] Anti-Ban Active | ID: " .. self.SessionID)
    end
}

-- Universal Configuration
local Config = {
    -- Menu
    MenuOpen = true,
    MenuKey = "Insert",
    
    -- Aimbot
    Aimbot = false,
    AimbotKey = "MouseButton2",
    AimbotSmooth = 0.25,
    AimPart = "Head",
    TeamCheck = true,
    VisibleCheck = true,
    MaxDistance = 1000,
    
    -- FOV System
    FOV = 90,
    FOVVisible = true,
    FOVColor = Color3.fromRGB(0, 255, 0),
    FOVTransparency = 0.7,
    
    -- ESP Box
    ESP = false,
    ESPBox = true,
    ESPBoxColor = Color3.fromRGB(255, 50, 50),
    ESPOutline = true,
    ESPBoxStyle = "2D", -- 2D, 3D, Corner
    
    -- ESP Name
    ESPName = true,
    ESPNameColor = Color3.fromRGB(255, 255, 255),
    
    -- ESP Health
    ESPHealth = true,
    ESPHealthBar = true,
    
    -- ESP Distance
    ESPDistance = true,
    
    -- ESP Weapon
    ESPWeapon = true,
    
    -- ESP Tracer
    ESPTracer = false,
    TracerColor = Color3.fromRGB(0, 255, 255),
    TracerStart = "Bottom", -- Bottom, Center, Crosshair
    
    -- ESP Chams
    ESPChams = false,
    ChamsColor = Color3.fromRGB(255, 50, 50),
    ChamsTransparency = 0.5,
    
    -- ESP Glow
    ESPGlow = false,
    
    -- Misc
    Crosshair = false,
    Watermark = true,
    FPSBoost = false
}

-- Drawing Objects Cache
local Drawings = {
    FOVCircle = Drawing.new("Circle"),
    Crosshair = Drawing.new("Square"),
    Watermark = {},
    ESP = {}
}

-- Initialize Drawings
Drawings.FOVCircle.Thickness = 1
Drawings.FOVCircle.NumSides = 60
Drawings.FOVCircle.Filled = false
Drawings.FOVCircle.Transparency = Config.FOVTransparency
Drawings.FOVCircle.Color = Config.FOVColor
Drawings.FOVCircle.Radius = Config.FOV
Drawings.FOVCircle.Visible = Config.FOVVisible

Drawings.Crosshair.Size = Vector2.new(6, 6)
Drawings.Crosshair.Filled = true
Drawings.Crosshair.Color = Color3.new(1, 1, 1)
Drawings.Crosshair.Visible = false

-- ESP Cache
local ESPCache = {}
local ChamsCache = {}
local GlowCache = {}

-- Create ESP for player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Corner1 = Drawing.new("Line"),
        Corner2 = Drawing.new("Line"),
        Corner3 = Drawing.new("Line"),
        Corner4 = Drawing.new("Line")
    }
    
    -- Configure Box
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Config.ESPBoxColor
    
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Transparency = 0.5
    
    -- Configure Text
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    esp.Name.Color = Config.ESPNameColor
    
    esp.Health.Size = 12
    esp.Health.Center = true
    esp.Health.Outline = true
    
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    esp.Weapon.Size = 12
    esp.Weapon.Center = true
    esp.Weapon.Outline = true
    
    -- Configure Health Bars
    esp.HealthBarBG.Filled = true
    esp.HealthBarBG.Color = Color3.fromRGB(50, 50, 50)
    esp.HealthBarBG.Transparency = 0.3
    
    esp.HealthBar.Filled = true
    
    -- Configure Tracer
    esp.Tracer.Thickness = 1
    esp.Tracer.Color = Config.TracerColor
    
    -- Configure Corners
    for i = 1, 4 do
        esp["Corner"..i].Thickness = 2
        esp["Corner"..i].Color = Config.ESPBoxColor
    end
    
    ESPCache[player] = esp
    
    -- Create Chams
    if Config.ESPChams then
        local char = player.Character
        if char then
            local highlight = Instance.new("Highlight")
            highlight.Name = "KKGZ_Chams"
            highlight.FillColor = Config.ChamsColor
            highlight.FillTransparency = Config.ChamsTransparency
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0.5
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = char
            highlight.Parent = char
            
            if Config.ESPGlow then
                local glow = Instance.new("BloomEffect")
                glow.Name = "KKGZ_Glow"
                glow.Intensity = 0.3
                glow.Size = 24
                glow.Threshold = 0.8
                glow.Parent = Lighting
            end
            
            ChamsCache[player] = highlight
        end
    end
end

-- Remove ESP
local function RemoveESP(player)
    if ESPCache[player] then
        for _, drawing in pairs(ESPCache[player]) do
            drawing:Remove()
        end
        ESPCache[player] = nil
    end
    
    if ChamsCache[player] then
        ChamsCache[player]:Destroy()
        ChamsCache[player] = nil
    end
end

-- Update ESP
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
            RemoveESP(player)
            continue
        end
        
        local char = player.Character
        if not char then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        
        if not humanoid or not root or humanoid.Health <= 0 then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Team Check
        local isEnemy = true
        if Config.TeamCheck and player.Team and LocalPlayer.Team then
            isEnemy = player.Team ~= LocalPlayer.Team
        end
        
        local boxColor = isEnemy and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        local textColor = isEnemy and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
        
        -- Get head position for box height
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HeadHitbox") or char:FindFirstChild("HitboxHead")
        local headPos = head and Camera:WorldToViewportPoint(head.Position) or pos
        
        local height = math.abs(headPos.Y - pos.Y) * 1.5
        local width = height * 0.6
        
        -- Box ESP
        if Config.ESPBox then
            if Config.ESPBoxStyle == "2D" then
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                esp.Box.Color = boxColor
                esp.Box.Visible = true
                
                if Config.ESPOutline then
                    esp.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                    esp.BoxOutline.Position = Vector2.new(pos.X - width/2 - 1, headPos.Y - 1)
                    esp.BoxOutline.Visible = true
                else
                    esp.BoxOutline.Visible = false
                end
                
                -- Hide corners
                for i = 1, 4 do
                    esp["Corner"..i].Visible = false
                end
                
            elseif Config.ESPBoxStyle == "Corner" then
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                
                -- Corner box
                local cornerLength = width / 3
                
                -- Top left
                esp.Corner1.From = Vector2.new(pos.X - width/2, headPos.Y)
                esp.Corner1.To = Vector2.new(pos.X - width/2 + cornerLength, headPos.Y)
                
                esp.Corner2.From = Vector2.new(pos.X - width/2, headPos.Y)
                esp.Corner2.To = Vector2.new(pos.X - width/2, headPos.Y + cornerLength)
                
                -- Top right
                esp.Corner3.From = Vector2.new(pos.X + width/2, headPos.Y)
                esp.Corner3.To = Vector2.new(pos.X + width/2 - cornerLength, headPos.Y)
                
                esp.Corner4.From = Vector2.new(pos.X + width/2, headPos.Y)
                esp.Corner4.To = Vector2.new(pos.X + width/2, headPos.Y + cornerLength)
                
                for i = 1, 4 do
                    esp["Corner"..i].Visible = true
                end
            end
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
            for i = 1, 4 do
                esp["Corner"..i].Visible = false
            end
        end
        
        -- Name ESP
        if Config.ESPName then
            esp.Name.Text = player.Name .. (isEnemy and " [ENEMY]" or " [TEAM]")
            esp.Name.Position = Vector2.new(pos.X, headPos.Y - 25)
            esp.Name.Color = textColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Health ESP
        if Config.ESPHealth then
            esp.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            esp.Health.Position = Vector2.new(pos.X, headPos.Y + height + 5)
            esp.Health.Color = Color3.new(1 - humanoid.Health/humanoid.MaxHealth, humanoid.Health/humanoid.MaxHealth, 0)
            esp.Health.Visible = true
            
            -- Health Bar
            if Config.ESPHealthBar then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barWidth = 50
                local barHeight = 4
                local barY = headPos.Y - 10
                
                esp.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
                esp.HealthBarBG.Position = Vector2.new(pos.X - barWidth/2, barY)
                esp.HealthBarBG.Visible = true
                
                esp.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                esp.HealthBar.Position = Vector2.new(pos.X - barWidth/2, barY)
                esp.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                esp.HealthBar.Visible = true
            else
                esp.HealthBarBG.Visible = false
                esp.HealthBar.Visible = false
            end
        else
            esp.Health.Visible = false
            esp.HealthBarBG.Visible = false
            esp.HealthBar.Visible = false
        end
        
        -- Distance ESP
        if Config.ESPDistance then
            local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
            esp.Distance.Text = distance .. " studs"
            esp.Distance.Position = Vector2.new(pos.X, headPos.Y + height + 20)
            esp.Distance.Color = Color3.new(1, 1, 1)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- Weapon ESP
        if Config.ESPWeapon then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                esp.Weapon.Text = tool.Name
            else
                esp.Weapon.Text = "No Weapon"
            end
            esp.Weapon.Position = Vector2.new(pos.X, headPos.Y + height + 35)
            esp.Weapon.Color = Color3.fromRGB(255, 255, 0)
            esp.Weapon.Visible = true
        else
            esp.Weapon.Visible = false
        end
        
        -- Tracer
        if Config.ESPTracer then
            local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            if Config.TracerStart == "Center" then
                startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif Config.TracerStart == "Crosshair" then
                startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
            
            esp.Tracer.From = startPos
            esp.Tracer.To = Vector2.new(pos.X, headPos.Y + height/2)
            esp.Tracer.Color = Config.TracerColor
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
        
        -- Update Chams
        if ChamsCache[player] then
            ChamsCache[player].FillColor = Config.ChamsColor
            ChamsCache[player].FillTransparency = Config.ChamsTransparency
            ChamsCache[player].Enabled = Config.ESPChams
        end
    end
end

-- Aimbot Functions
local Aimbot = {
    CurrentTarget = nil,
    Active = false
}

function Aimbot:GetClosest()
    if not Config.Aimbot then return nil end
    
    local closest = nil
    local closestDist = Config.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if Config.TeamCheck and player.Team and LocalPlayer.Team then
            if player.Team == LocalPlayer.Team then continue end
        end
        
        local char = player.Character
        if not char then continue end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local aimPart = char:FindFirstChild(Config.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not aimPart then continue end
        
        -- Distance check
        local distance = (aimPart.Position - Camera.CFrame.Position).Magnitude
        if distance > Config.MaxDistance then continue end
        
        -- Visibility check
        if Config.VisibleCheck then
            local ray = Ray.new(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).Unit * distance)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
            if hit and not hit:IsDescendantOf(player.Character) then
                continue
            end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local screenPos = Vector2.new(pos.X, pos.Y)
        local dist = (center - screenPos).Magnitude
        
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    
    return closest
end

function Aimbot:Update()
    if not Config.Aimbot then 
        self.Active = false
        self.CurrentTarget = nil
        return 
    end
    
    -- Check activation key
    if Config.AimbotKey == "MouseButton2" then
        self.Active = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif Config.AimbotKey == "LeftShift" then
        self.Active = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif Config.AimbotKey == "Q" then
        self.Active = UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif Config.AimbotKey == "E" then
        self.Active = UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif Config.AimbotKey == "V" then
        self.Active = UserInputService:IsKeyDown(Enum.KeyCode.V)
    elseif Config.AimbotKey == "X" then
        self.Active = UserInputService:IsKeyDown(Enum.KeyCode.X)
    end
    
    if not self.Active then
        self.CurrentTarget = nil
        return
    end
    
    -- Get target
    if not self.CurrentTarget or not self.CurrentTarget.Parent then
        self.CurrentTarget = self:GetClosest()
    end
    
    if not self.CurrentTarget then return end
    
    local char = self.CurrentTarget.Character
    if not char then 
        self.CurrentTarget = nil
        return 
    end
    
    local aimPart = char:FindFirstChild(Config.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not aimPart then 
        self.CurrentTarget = nil
        return 
    end
    
    -- Smooth aim
    local targetPos = aimPart.Position
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    
    local currentLook = Camera.CFrame.LookVector
    local newDirection = currentLook:Lerp(direction, Config.AimbotSmooth)
    
    Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
end

-- Create Watermark
local function CreateWatermark()
    local watermark = {
        BG = Drawing.new("Square"),
        Text = Drawing.new("Text"),
        FPS = Drawing.new("Text")
    }
    
    watermark.BG.Filled = true
    watermark.BG.Color = Color3.fromRGB(0, 0, 0)
    watermark.BG.Transparency = 0.8
    
    watermark.Text.Size = 14
    watermark.Text.Font = 3
    watermark.Text.Outline = true
    watermark.Text.OutlineColor = Color3.new(0, 0, 0)
    watermark.Text.Color = Color3.fromRGB(0, 255, 255)
    watermark.Text.Text = "KKG-Z v4.0 | Universal"
    
    watermark.FPS.Size = 12
    watermark.FPS.Font = 2
    watermark.FPS.Outline = true
    watermark.FPS.Color = Color3.fromRGB(0, 255, 0)
    
    local frameCount = 0
    local lastTime = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastTime))
            watermark.FPS.Text = "FPS: " .. fps .. " | " .. Config.GameType or "Roblox"
            frameCount = 0
            lastTime = currentTime
        end
        
        if Config.Watermark then
            watermark.BG.Size = Vector2.new(watermark.Text.TextBounds.X + 20, 50)
            watermark.BG.Position = Vector2.new(10, 10)
            watermark.BG.Visible = true
            
            watermark.Text.Position = Vector2.new(20, 15)
            watermark.Text.Visible = true
            
            watermark.FPS.Position = Vector2.new(20, 35)
            watermark.FPS.Visible = true
        else
            watermark.BG.Visible = false
            watermark.Text.Visible = false
            watermark.FPS.Visible = false
        end
    end)
    
    Drawings.Watermark = watermark
end

-- Create Complete GUI Panel
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KKGZ_Universal_" .. AntiBan.SessionID
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 500)
    Main.Position = UDim2.new(0.5, -300, 0.5, -250)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 2
    Main.BorderColor3 = Color3.fromRGB(0, 150, 255)
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    
    -- Title Bar
    local Title = Instance.new("Frame")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    Title.BorderSizePixel = 0
    Title.Parent = Main
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "🎯 KKG-Z UNIVERSAL | AIMBOT + ESP | Anti-Ban Lv.3"
    TitleText.TextColor3 = Color3.new(1, 1, 1)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = Title
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.Parent = Title
    
    CloseBtn.MouseButton1Click:Connect(function()
        Config.MenuOpen = false
        ScreenGui.Enabled = false
    end)
    
    -- Tab System
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -35)
    TabFrame.Position = UDim2.new(0, 0, 0, 35)
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = Main
    
    -- Tab Buttons
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(0, 150, 1, 0)
    TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabButtons.BorderSizePixel = 0
    TabButtons.Parent = TabFrame
    
    local TabContents = Instance.new("Frame")
    TabContents.Size = UDim2.new(1, -150, 1, 0)
    TabContents.Position = UDim2.new(0, 150, 0, 0)
    TabContents.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabContents.BorderSizePixel = 0
    TabContents.Parent = TabFrame
    
    local tabs = {"AIMBOT", "FOV", "ESP BOX", "ESP TEXT", "TRACER", "CHAMS", "MISC"}
    local currentTab = "AIMBOT"
    local tabButtons = {}
    local tabPanels = {}
    
    -- Create Tab Panels
    for i, tabName in ipairs(tabs) do
        -- Tab Button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 40)
        btn.BackgroundColor3 = currentTab == tabName and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(40, 40, 40)
        btn.Text = tabName
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = TabButtons
        
        -- Tab Panel
        local panel = Instance.new("ScrollingFrame")
        panel.Size = UDim2.new(1, -20, 1, -20)
        panel.Position = UDim2.new(0, 10, 0, 10)
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel = 0
        panel.ScrollBarThickness = 4
        panel.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
        panel.Visible = currentTab == tabName
        panel.Parent = TabContents
        
        tabButtons[tabName] = btn
        tabPanels[tabName] = panel
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tabName
            for name, button in pairs(tabButtons) do
                button.BackgroundColor3 = name == tabName and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(40, 40, 40)
            end
            for name, pane in pairs(tabPanels) do
                pane.Visible = name == tabName
            end
        end)
    end
    
    -- Aimbot Tab Content
    local yPos = 0
    
    local function CreateToggle(parent, text, configKey, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3, -5, 0, 25)
        btn.Position = UDim2.new(0.7, 5, 0, 5)
        btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        btn.Text = Config[configKey] and "ON" or "OFF"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            btn.Text = Config[configKey] and "ON" or "OFF"
            btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        end)
        
        return y + 40
    end
    
    local function CreateSlider(parent, text, configKey, min, max, format, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 45)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. (format == "percent" and (Config[configKey] * 100).."%" or Config[configKey])
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.7, -5, 0, 4)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0.3, -5, 0, 20)
        valueDisplay.Position = UDim2.new(0.7, 5, 0, 5)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = Config[configKey]
        valueDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextSize = 14
        valueDisplay.Parent = frame
        
        local dragging = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position.X
                local absolutePos = slider.AbsolutePosition.X
                local absoluteSize = slider.AbsoluteSize.X
                
                local relative = math.clamp((mousePos - absolutePos) / absoluteSize, 0, 1)
                local value = min + (max - min) * relative
                
                if format == "percent" then
                    Config[configKey] = value
                    label.Text = text .. ": " .. math.floor(value * 100) .. "%"
                    valueDisplay.Text = math.floor(value * 100) .. "%"
                else
                    Config[configKey] = math.floor(value)
                    label.Text = text .. ": " .. math.floor(value)
                    valueDisplay.Text = math.floor(value)
                end
                
                fill.Size = UDim2.new(relative, 0, 1, 0)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return y + 50
    end
    
    local function CreateDropdown(parent, text, configKey, options, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(0.5, -5, 0, 25)
        dropdown.Position = UDim2.new(0.5, 5, 0, 5)
        dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdown.Text = Config[configKey]
        dropdown.TextColor3 = Color3.new(1, 1, 1)
        dropdown.Font = Enum.Font.Gotham
        dropdown.TextSize = 12
        dropdown.Parent = frame
        
        local index = 1
        for i, opt in ipairs(options) do
            if opt == Config[configKey] then
                index = i
                break
            end
        end
        
        dropdown.MouseButton1Click:Connect(function()
            index = index % #options + 1
            local selected = options[index]
            Config[configKey] = selected
            dropdown.Text = selected
        end)
        
        return y + 40
    end
    
    local function CreateColorPicker(parent, text, configKey, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.Position = UDim2.new(0, 10, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0.3, -5, 0, 20)
        colorDisplay.Position = UDim2.new(0.7, 5, 0, 7)
        colorDisplay.BackgroundColor3 = Config[configKey]
        colorDisplay.BorderSizePixel = 1
        colorDisplay.BorderColor3 = Color3.new(1, 1, 1)
        colorDisplay.Parent = frame
        
        return y + 40
    end
    
    -- AIMBOT Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["AIMBOT"], "Enable Aimbot", "Aimbot", yPos)
    yPos = CreateDropdown(tabPanels["AIMBOT"], "Aim Key", "AimbotKey", {"MouseButton2", "LeftShift", "Q", "E", "V", "X"}, yPos)
    yPos = CreateToggle(tabPanels["AIMBOT"], "Team Check", "TeamCheck", yPos)
    yPos = CreateToggle(tabPanels["AIMBOT"], "Visibility Check", "VisibleCheck", yPos)
    yPos = CreateSlider(tabPanels["AIMBOT"], "Smoothness", "AimbotSmooth", 0, 1, "percent", yPos)
    yPos = CreateDropdown(tabPanels["AIMBOT"], "Aim Part", "AimPart", {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, yPos)
    yPos = CreateSlider(tabPanels["AIMBOT"], "Max Distance", "MaxDistance", 100, 2000, "", yPos)
    
    -- FOV Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["FOV"], "Show FOV Circle", "FOVVisible", yPos)
    yPos = CreateSlider(tabPanels["FOV"], "FOV Size", "FOV", 30, 360, "", yPos)
    yPos = CreateColorPicker(tabPanels["FOV"], "FOV Color", "FOVColor", yPos)
    yPos = CreateSlider(tabPanels["FOV"], "FOV Transparency", "FOVTransparency", 0, 1, "percent", yPos)
    
    -- ESP BOX Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["ESP BOX"], "Enable ESP", "ESP", yPos)
    yPos = CreateToggle(tabPanels["ESP BOX"], "ESP Box", "ESPBox", yPos)
    yPos = CreateDropdown(tabPanels["ESP BOX"], "Box Style", "ESPBoxStyle", {"2D", "Corner"}, yPos)
    yPos = CreateToggle(tabPanels["ESP BOX"], "Box Outline", "ESPOutline", yPos)
    yPos = CreateColorPicker(tabPanels["ESP BOX"], "Box Color", "ESPBoxColor", yPos)
    
    -- ESP TEXT Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["ESP TEXT"], "Show Name", "ESPName", yPos)
    yPos = CreateColorPicker(tabPanels["ESP TEXT"], "Name Color", "ESPNameColor", yPos)
    yPos = CreateToggle(tabPanels["ESP TEXT"], "Show Health", "ESPHealth", yPos)
    yPos = CreateToggle(tabPanels["ESP TEXT"], "Health Bar", "ESPHealthBar", yPos)
    yPos = CreateToggle(tabPanels["ESP TEXT"], "Show Distance", "ESPDistance", yPos)
    yPos = CreateToggle(tabPanels["ESP TEXT"], "Show Weapon", "ESPWeapon", yPos)
    
    -- TRACER Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["TRACER"], "Enable Tracers", "ESPTracer", yPos)
    yPos = CreateDropdown(tabPanels["TRACER"], "Tracer Start", "TracerStart", {"Bottom", "Center", "Crosshair"}, yPos)
    yPos = CreateColorPicker(tabPanels["TRACER"], "Tracer Color", "TracerColor", yPos)
    
    -- CHAMS Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["CHAMS"], "Enable Chams", "ESPChams", yPos)
    yPos = CreateColorPicker(tabPanels["CHAMS"], "Chams Color", "ChamsColor", yPos)
    yPos = CreateSlider(tabPanels["CHAMS"], "Chams Transparency", "ChamsTransparency", 0, 1, "percent", yPos)
    yPos = CreateToggle(tabPanels["CHAMS"], "Enable Glow", "ESPGlow", yPos)
    
    -- MISC Tab
    yPos = 10
    yPos = CreateToggle(tabPanels["MISC"], "Show Watermark", "Watermark", yPos)
    yPos = CreateToggle(tabPanels["MISC"], "Show Crosshair", "Crosshair", yPos)
    yPos = CreateToggle(tabPanels["MISC"], "FPS Boost", "FPSBoost", yPos)
    
    -- Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Size = UDim2.new(1, 0, 0, 30)
    StatusBar.Position = UDim2.new(0, 0, 1, -30)
    StatusBar.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = Main
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -10, 1, 0)
    StatusText.Position = UDim2.new(0, 5, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "🛡️ ANTI-BAN ACTIVE | TEAM CHECK ON | FOV: " .. Config.FOV .. " | ESP: " .. (Config.ESP and "ON" or "OFF")
    StatusText.TextColor3 = Color3.new(1, 1, 1)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 12
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusBar
    
    return ScreenGui
end

-- Initialize Everything
local function Init()
    -- Start Anti-Ban
    AntiBan:Init()
    
    -- Create GUI
    local GUI = CreateGUI()
    GUI.Enabled = Config.MenuOpen
    
    -- Create Watermark
    CreateWatermark()
    
    -- Setup ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Player Added
    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        CreateESP(player)
    end)
    
    -- Player Removed
    Players.PlayerRemoving:Connect(RemoveESP)
    
    -- Character Added
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            RemoveESP(player)
            CreateESP(player)
        end)
    end)
    
    -- Menu Toggle
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode[Config.MenuKey] then
            Config.MenuOpen = not Config.MenuOpen
            GUI.Enabled = Config.MenuOpen
        end
    end)
    
    -- Main Loop
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle
        Drawings.FOVCircle.Visible = Config.FOVVisible
        Drawings.FOVCircle.Color = Config.FOVColor
        Drawings.FOVCircle.Radius = Config.FOV
        Drawings.FOVCircle.Transparency = Config.FOVTransparency
        Drawings.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- Update Crosshair
        if Config.Crosshair then
            Drawings.Crosshair.Position = Vector2.new(Camera.ViewportSize.X / 2 - 3, Camera.ViewportSize.Y / 2 - 3)
            Drawings.Crosshair.Visible = true
        else
            Drawings.Crosshair.Visible = false
        end
        
        -- Update Aimbot
        Aimbot:Update()
        
        -- Update ESP
        UpdateESP()
        
        -- FPS Boost
        if Config.FPSBoost then
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
        else
            Lighting.GlobalShadows = true
        end
    end)
    
    print("=" .. string.rep("=", 50))
    print("🎯 KKG-Z UNIVERSAL v4.0 LOADED SUCCESSFULLY")
    print("=" .. string.rep("=", 50))
    print("📱 Press INSERT to toggle menu")
    print("🛡️ Anti-Ban: Active | ID: " .. AntiBan.SessionID)
    print("👁️ ESP: Box | Name | Health | Distance | Weapon")
    print("🎯 Aimbot: Team Check | FOV | Smoothing")
    print("📊 Game: " .. tostring(game.PlaceId))
    print("=" .. string.rep("=", 50))
end

-- Start
local success, err = pcall(Init)
if not success then
    warn("[KKG-Z] Error: " .. tostring(err))
    
    -- Fallback initialization
    AntiBan.Active = true
    Config.SmoothAim = 0.3
    Config.FOVVisible = true
    
    pcall(Init)
end
