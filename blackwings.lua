-- BLACK ANGEL WINGS WITH REAL-TIME CONTROLS
print("🔄 [WINGS] Memuat script dengan kontrol real-time...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local wingConnection = nil
local wingModel = nil
local allFeathers = {}
local smokeEmitter = nil

-- Parameter yang bisa diubah
local wingScale = 1.0
local smokeRate = 30
local featherLength = 1.0

-- ==================== GUI SETUP ====================
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WingControls"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999
screenGui.Parent = playerGui

-- Frame utama kontrol
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 250, 0, 350)
controlFrame.Position = UDim2.new(0, 20, 0.5, -175)
controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
controlFrame.BackgroundTransparency = 0.1
controlFrame.BorderSizePixel = 0
controlFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = controlFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 2
stroke.Parent = controlFrame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🦇 KONTROL SAYAP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBlack
title.Parent = controlFrame

-- Fungsi buat slider
local function createSlider(name, minVal, maxVal, defaultVal, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 60)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = controlFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 5)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 5)
    
    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Size = UDim2.new(0, 20, 1, 0)
    sliderKnob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -10, 0, 0)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Text = ""
    sliderKnob.Parent = sliderBg
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 10)
    
    local value = defaultVal
    local dragging = false
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
            value = minVal + (percent * (maxVal - minVal))
            
            sliderKnob.Position = UDim2.new(percent, -10, 0, 0)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = name .. ": " .. string.format("%.1f", value)
            
            return value
        end
    end)
    
    return function() return value end
end

-- Buat slider
local getWingScale = createSlider("Ukuran Sayap", 0.5, 3.0, 1.0, 50)
local getSmokeRate = createSlider("Ketebalan Asap", 0, 50, 30, 120)
local getFeatherLength = createSlider("Panjang Bulu", 0.5, 2.0, 1.0, 190)

-- Tombol Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 260)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
toggleButton.Text = "🦇 AKTIFKAN SAYAP"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.Parent = controlFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)

-- Tombol Reset
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, -20, 0, 30)
resetButton.Position = UDim2.new(0, 10, 0, 310)
resetButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resetButton.Text = "🔄 RESET"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 14
resetButton.Font = Enum.Font.GothamBold
resetButton.Parent = controlFrame
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 8)

-- ==================== FUNGSI SAYAP ====================
local function clearWings()
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    if wingModel and wingModel.Parent then
        wingModel:Destroy()
        wingModel = nil
    end
    allFeathers = {}
    smokeEmitter = nil
end

local function updateWingSize()
    wingScale = getWingScale()
    for _, feather in pairs(allFeathers) do
        if feather and feather.Parent then
            local originalSize = feather:GetAttribute("OriginalSize")
            if originalSize then
                feather.Size = originalSize * wingScale
            end
        end
    end
end

local function updateSmokeRate()
    smokeRate = getSmokeRate()
    if smokeEmitter and smokeEmitter.Parent then
        smokeEmitter.Rate = smokeRate
    end
end

local function updateFeatherLength()
    featherLength = getFeatherLength()
    for _, feather in pairs(allFeathers) do
        if feather and feather.Parent then
            local originalSize = feather:GetAttribute("OriginalSize")
            if originalSize then
                feather.Size = Vector3.new(
                    originalSize.X * wingScale,
                    originalSize.Y * wingScale,
                    originalSize.Z * wingScale * featherLength
                )
            end
        end
    end
end

local function createWings()
    clearWings()
    
    local rootPart = character:WaitForChild("HumanoidRootPart")
    if not rootPart then return end
    
    wingModel = Instance.new("Model")
    wingModel.Name = "BlackAngelWings"
    wingModel.Parent = character
    
    local anchor = Instance.new("Part")
    anchor.Name = "WingAnchor"
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = false
    anchor.Massless = true
    anchor.Parent = wingModel
    
    local anchorWeld = Instance.new("Weld")
    anchorWeld.Part0 = rootPart
    anchorWeld.Part1 = anchor
    anchorWeld.C0 = CFrame.new(0, 0.8, 1.5)
    anchorWeld.Parent = anchor
    
    local function createFeather(name, size, color, position, angles)
        local feather = Instance.new("Part")
        feather.Name = name
        feather.Size = size
        feather:SetAttribute("OriginalSize", size)
        feather.Color = color
        feather.Material = Enum.Material.Fabric
        feather.Transparency = 0.15
        feather.CanCollide = false
        feather.Anchored = false
        feather.Massless = true
        feather.Parent = wingModel
        
        local weld = Instance.new("Weld")
        weld.Part0 = anchor
        weld.Part1 = feather
        weld.C0 = CFrame.new(position.X, position.Y, position.Z) * CFrame.Angles(angles.X, angles.Y, angles.Z)
        weld.Parent = feather
        
        table.insert(allFeathers, feather)
        return feather
    end
    
    -- Sayap Kiri
    createFeather("LeftBone", Vector3.new(0.4, 0.4, 5), Color3.fromRGB(15, 15, 15),
        Vector3.new(-1.5, 0.8, 0), Vector3.new(0, math.rad(25), 0))
    
    for i = 1, 12 do
        local progress = i / 12
        local length = 6 - (progress * 2)
        local width = 1.2 - (progress * 0.4)
        local offsetX = -1.5 - (progress * 3)
        local offsetY = 0.8 - (progress * 0.5)
        local offsetZ = -0.4 * i
        
        createFeather("LeftFeather" .. i, Vector3.new(width, 0.15, length), Color3.fromRGB(10, 10, 10),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-15 - progress * 25), math.rad(20 + progress * 35), math.rad(progress * 15)))
    end
    
    for i = 1, 6 do
        local progress = i / 6
        local length = 4.5 - (progress * 1.5)
        local width = 0.9 - (progress * 0.3)
        local offsetX = -1.2 - (progress * 2)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        createFeather("LeftSecondary" .. i, Vector3.new(width, 0.12, length), Color3.fromRGB(20, 20, 20),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(15 + progress * 25), math.rad(progress * 10)))
    end
    
    -- Sayap Kanan
    createFeather("RightBone", Vector3.new(0.4, 0.4, 5), Color3.fromRGB(15, 15, 15),
        Vector3.new(1.5, 0.8, 0), Vector3.new(0, math.rad(-25), 0))
    
    for i = 1, 12 do
        local progress = i / 12
        local length = 6 - (progress * 2)
        local width = 1.2 - (progress * 0.4)
        local offsetX = 1.5 + (progress * 3)
        local offsetY = 0.8 - (progress * 0.5)
        local offsetZ = -0.4 * i
        
        createFeather("RightFeather" .. i, Vector3.new(width, 0.15, length), Color3.fromRGB(10, 10, 10),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-15 - progress * 25), math.rad(-20 - progress * 35), math.rad(-progress * 15)))
    end
    
    for i = 1, 6 do
        local progress = i / 6
        local length = 4.5 - (progress * 1.5)
        local width = 0.9 - (progress * 0.3)
        local offsetX = 1.2 + (progress * 2)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        createFeather("RightSecondary" .. i, Vector3.new(width, 0.12, length), Color3.fromRGB(20, 20, 20),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(-15 - progress * 25), math.rad(-progress * 10)))
    end
    
    -- Efek Asap
    smokeEmitter = Instance.new("ParticleEmitter")
    smokeEmitter.Color = ColorSequence.new(Color3.fromRGB(5, 5, 5), Color3.fromRGB(30, 30, 30))
    smokeEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(0.5, 4),
        NumberSequenceKeypoint.new(1, 6)
    })
    smokeEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    smokeEmitter.Lifetime = NumberRange.new(3, 4)
    smokeEmitter.Rate = smokeRate
    smokeEmitter.Speed = NumberRange.new(2, 4)
    smokeEmitter.SpreadAngle = Vector2.new(45, 45)
    smokeEmitter.Rotation = NumberRange.new(0, 360)
    smokeEmitter.RotSpeed = NumberRange.new(-80, 80)
    smokeEmitter.Parent = anchor
    
    -- Animasi
    local flapAngle = 0
    local flapDirection = 1
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and anchor and anchor.Parent then
            flapAngle = flapAngle + (0.05 * flapDirection)
            if flapAngle > 0.35 or flapAngle < -0.35 then
                flapDirection = -flapDirection
            end
            anchorWeld.C0 = CFrame.new(0, 0.8, 1.5) * CFrame.Angles(math.rad(flapAngle * 25), 0, 0)
        end
    end)
    
    -- Terapkan parameter awal
    updateWingSize()
    updateFeatherLength()
end

-- ==================== EVENT HANDLERS ====================
toggleButton.MouseButton1Click:Connect(function()
    wingsActive = not wingsActive
    
    if wingsActive then
        createWings()
        toggleButton.Text = "✅ SAYAP AKTIF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        clearWings()
        toggleButton.Text = "🦇 AKTIFKAN SAYAP"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    end
end)

resetButton.MouseButton1Click:Connect(function()
    wingScale = 1.0
    smokeRate = 30
    featherLength = 1.0
    
    if wingsActive then
        updateWingSize()
        updateSmokeRate()
        updateFeatherLength()
    end
    
    print("🔄 [WINGS] Parameter direset ke default")
end)

-- Update real-time
runService.Heartbeat:Connect(function()
    if wingsActive then
        local newWingScale = getWingScale()
        local newSmokeRate = getSmokeRate()
        local newFeatherLength = getFeatherLength()
        
        if newWingScale ~= wingScale then
            wingScale = newWingScale
            updateWingSize()
        end
        
        if newSmokeRate ~= smokeRate then
            smokeRate = newSmokeRate
            updateSmokeRate()
        end
        
        if newFeatherLength ~= featherLength then
            featherLength = newFeatherLength
            updateFeatherLength()
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    clearWings()
    task.wait(0.5)
    if wingsActive then
        createWings()
    end
end)

print("========================================")
print("✅ KONTROL SAYAP SIAP!")
print("👉 Panel kontrol di KIRI layar")
print("🎚️ Geser slider untuk atur:")
print("   - Ukuran Sayap (0.5x - 3x)")
print("   - Ketebalan Asap (0 - 50)")
print("   - Panjang Bulu (0.5x - 2x)")
print("🔄 Tombol RESET untuk kembalikan ke default")
print("========================================")
