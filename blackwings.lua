-- BLACK ANGEL WINGS EPIC VERSION (REALISTIC STRUCTURE + DRAMATIC EFFECTS)
print("🔄 [WINGS] Memuat Sayap Malaikat Hitam EPIC...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local currentWings = {}
local wingConnection = nil

-- ==================== 1. GUI SETUP ====================
local CoreGui = game:GetService("CoreGui")
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EpicBlackWings"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success or not screenGui.Parent then
    screenGui.Parent = PlayerGui
end

-- ==================== 2. TOMBOL ====================
local mainButton = Instance.new("TextButton")
mainButton.Name = "WingsToggleBtn"
mainButton.Size = UDim2.new(0, 180, 0, 180)
mainButton.Position = UDim2.new(0.5, -90, 0.5, -90)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
mainButton.BackgroundTransparency = 0.1
mainButton.BorderSizePixel = 0
mainButton.Text = "🦇\nSAYAP EPIC"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 24
mainButton.Font = Enum.Font.GothamBlack
mainButton.AutoButtonColor = true
mainButton.ZIndex = 100
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 25)
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 4
stroke.Parent = mainButton

-- Fitur Geser
local dragging, dragInput, dragStart, startPos
mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==================== 3. FUNGSI SAYAP EPIC ====================
local function clearWings()
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    for _, wing in pairs(currentWings) do
        if wing and wing.Parent then wing:Destroy() end
    end
    currentWings = {}
end

local function createWingPart(name, size, color, material, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Transparency = transparency or 0
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    return part
end

local function createFeather(parent, length, width, angle, offset, color)
    local feather = createWingPart("Feather", Vector3.new(width, 0.1, length), color, Enum.Material.Fabric, 0.2)
    feather.Parent = parent
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = parent
    weld.Part1 = feather
    weld.Parent = feather
    
    feather.CFrame = parent.CFrame * CFrame.new(offset.X, offset.Y, offset.Z) * CFrame.Angles(angle.X, angle.Y, angle.Z)
    
    -- Tambahkan glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(50, 0, 80)
    pointLight.Brightness = 0.5
    pointLight.Range = 3
    pointLight.Parent = feather
    
    return feather
end

local function createEpicWing(side)
    local wingModel = Instance.new("Model")
    wingModel.Name = "EpicWing_" .. side
    wingModel.Parent = character
    
    local multiplier = side == "L" and -1 or 1
    
    -- ===== STRUKTUR TULANG UTAMA (3 BAGIAN) =====
    -- Tulang atas (shoulder)
    local bone1 = createWingPart("Bone1", Vector3.new(0.4, 0.4, 2), Color3.fromRGB(20, 20, 20), Enum.Material.Neon, 0.1)
    bone1.Parent = wingModel
    
    -- Tulang tengah (elbow)
    local bone2 = createWingPart("Bone2", Vector3.new(0.3, 0.3, 2.5), Color3.fromRGB(30, 30, 30), Enum.Material.Neon, 0.15)
    bone2.Parent = wingModel
    
    -- Tulang bawah (wrist)
    local bone3 = createWingPart("Bone3", Vector3.new(0.2, 0.2, 2), Color3.fromRGB(40, 40, 40), Enum.Material.Neon, 0.2)
    bone3.Parent = wingModel
    
    -- Weld tulang
    local weld1 = Instance.new("WeldConstraint")
    weld1.Part0 = bone1
    weld1.Part1 = bone2
    weld1.Parent = bone2
    
    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = bone2
    weld2.Part1 = bone3
    weld2.Parent = bone3
    
    -- ===== BULU-BULU PRIMER (BESAR) =====
    local primaryFeathers = 12
    for i = 1, primaryFeathers do
        local progress = i / primaryFeathers
        local length = 4 - (progress * 1.5) -- Mengecil ke ujung
        local width = 0.8 - (progress * 0.3)
        
        -- Posisi menyebar membentuk kurva
        local offsetZ = -0.3 * i
        local offsetY = -0.2 * progress
        local offsetX = multiplier * (0.5 + (progress * 1.5))
        
        -- Rotasi mengikuti kurva sayap
        local angleX = math.rad(-10 - (progress * 20))
        local angleY = math.rad(multiplier * (10 + (progress * 30)))
        local angleZ = math.rad(multiplier * progress * 15)
        
        local feather = createFeather(bone3, length, width, 
            Vector3.new(angleX, angleY, angleZ),
            Vector3.new(offsetX, offsetY, offsetZ),
            Color3.fromRGB(10, 10, 10))
        
        table.insert(currentWings, feather)
    end
    
    -- ===== BULU-BULU SEKUNDER (MENENGAH) =====
    local secondaryFeathers = 8
    for i = 1, secondaryFeathers do
        local progress = i / secondaryFeathers
        local length = 3 - (progress * 1)
        local width = 0.6 - (progress * 0.2)
        
        local offsetZ = -0.25 * i
        local offsetY = 0.1
        local offsetX = multiplier * (0.3 + (progress * 1))
        
        local angleX = math.rad(-5 - (progress * 15))
        local angleY = math.rad(multiplier * (5 + (progress * 20)))
        local angleZ = math.rad(multiplier * progress * 10)
        
        local feather = createFeather(bone2, length, width,
            Vector3.new(angleX, angleY, angleZ),
            Vector3.new(offsetX, offsetY, offsetZ),
            Color3.fromRGB(20, 20, 20))
        
        table.insert(currentWings, feather)
    end
    
    -- ===== BULU-BULU KOVERT (KECIL) =====
    local covertFeathers = 6
    for i = 1, covertFeathers do
        local progress = i / covertFeathers
        local length = 2 - (progress * 0.5)
        local width = 0.4 - (progress * 0.1)
        
        local offsetZ = -0.2 * i
        local offsetY = 0.3
        local offsetX = multiplier * (0.2 + (progress * 0.5))
        
        local angleX = math.rad(-progress * 10)
        local angleY = math.rad(multiplier * progress * 15)
        local angleZ = math.rad(multiplier * progress * 5)
        
        local feather = createFeather(bone1, length, width,
            Vector3.new(angleX, angleY, angleZ),
            Vector3.new(offsetX, offsetY, offsetZ),
            Color3.fromRGB(30, 30, 30))
        
        table.insert(currentWings, feather)
    end
    
    -- ===== EFEK ASAP GELAP DRAMATIS =====
    local smoke1 = Instance.new("ParticleEmitter")
    smoke1.Color = ColorSequence.new(Color3.fromRGB(10, 10, 10), Color3.fromRGB(30, 30, 30))
    smoke1.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 2.5),
        NumberSequenceKeypoint.new(1, 4)
    })
    smoke1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    })
    smoke1.Lifetime = NumberRange.new(2, 3)
    smoke1.Rate = 25
    smoke1.Speed = NumberRange.new(2, 4)
    smoke1.SpreadAngle = Vector2.new(30, 30)
    smoke1.Rotation = NumberRange.new(0, 360)
    smoke1.RotSpeed = NumberRange.new(-100, 100)
    smoke1.Parent = bone1
    
    local smoke2 = Instance.new("ParticleEmitter")
    smoke2.Color = ColorSequence.new(Color3.fromRGB(20, 0, 40), Color3.fromRGB(50, 0, 80))
    smoke2.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 2)
    })
    smoke2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    smoke2.Lifetime = NumberRange.new(1.5, 2.5)
    smoke2.Rate = 15
    smoke2.Speed = NumberRange.new(1, 2)
    smoke2.SpreadAngle = Vector2.new(45, 45)
    smoke2.Parent = bone2
    
    table.insert(currentWings, bone1)
    table.insert(currentWings, bone2)
    table.insert(currentWings, bone3)
    table.insert(currentWings, wingModel)
    
    return wingModel, bone1
end

local function createEpicWings()
    clearWings()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local leftWing, leftBone = createEpicWing("L")
    local rightWing, rightBone = createEpicWing("R")
    
    local flapAngle = 0
    local flapDirection = 1
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and rootPart and rootPart.Parent then
            -- Posisi di belakang punggung
            local baseCFrame = rootPart.CFrame * CFrame.new(0, 1, 1.5)
            
            -- Animasi mengepak lebih dramatis
            flapAngle = flapAngle + (0.04 * flapDirection)
            if flapAngle > 0.4 or flapAngle < -0.4 then
                flapDirection = -flapDirection
            end
            
            -- Sayap kiri
            leftBone.CFrame = baseCFrame * CFrame.new(-1.5, 0, 0) * CFrame.Angles(0, math.rad(25 + (flapAngle * 40)), math.rad(-15))
            
            -- Sayap kanan
            rightBone.CFrame = baseCFrame * CFrame.new(1.5, 0, 0) * CFrame.Angles(0, math.rad(-25 - (flapAngle * 40)), math.rad(15))
        end
    end)
end

local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        createEpicWings()
        mainButton.Text = "✅\nSAYAP AKTIF"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        stroke.Color = Color3.fromRGB(0, 255, 0)
        print("✨ [WINGS] Sayap Malaikat Hitam EPIC Dipasang!")
    else
        clearWings()
        mainButton.Text = "🦇\nSAYAP EPIC"
        mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        print("😴 [WINGS] Sayap Dihapus.")
    end
end

-- ==================== 4. EVENT TOMBOL ====================
mainButton.MouseButton1Click:Connect(function()
    local tweenDown = tweenService:Create(mainButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 160, 0, 160)})
    tweenDown:Play()
    task.delay(0.1, function()
        tweenService:Create(mainButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 180, 0, 180)}):Play()
    end)
    
    toggleWings()
end)

-- ==================== 5. RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    clearWings()
    task.wait(0.5)
    if wingsActive then createEpicWings() end
end)

print("========================================")
print("✅ SAYAP MALAIKAT HITAM EPIC SIAP!")
print("👉 Tombol MERAH di TENGAH LAYAR")
print("🦇 Sayap dengan struktur tulang 3 bagian")
print("✨ 26 bulu per sayap (primer + sekunder + covert)")
print("💨 Efek asap gelap dramatis + glow ungu")
print("🎬 Animasi mengepak lebih dramatis")
print("========================================")
