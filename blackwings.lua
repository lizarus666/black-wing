-- BLACK ANGEL WINGS ULTIMATE (REALISTIC FEATHERS + DARK AURA)
print("🔄 [WINGS] Memuat Sayap Malaikat Hitam...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local currentWings = {}
local wingConnection = nil
local flapConnection = nil

-- ==================== 1. GUI BYPASS & SETUP ====================
local CoreGui = game:GetService("CoreGui")
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackAngelWings"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success or not screenGui.Parent then
    screenGui.Parent = PlayerGui
end

-- ==================== 2. TOMBOL BESAR ====================
local mainButton = Instance.new("TextButton")
mainButton.Name = "WingsToggleBtn"
mainButton.Size = UDim2.new(0, 180, 0, 180)
mainButton.Position = UDim2.new(0.5, -90, 0.5, -90)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
mainButton.BackgroundTransparency = 0.1
mainButton.BorderSizePixel = 0
mainButton.Text = "🦇\nSAYAP MALAIKAT"
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

-- ==================== 3. FUNGSI SAYAP MALAIKAT ====================
local function clearWings()
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    if flapConnection then
        flapConnection:Disconnect()
        flapConnection = nil
    end
    for _, wing in pairs(currentWings) do
        if wing and wing.Parent then wing:Destroy() end
    end
    currentWings = {}
end

local function createFeather(parent, size, position, rotation, color)
    local feather = Instance.new("Part")
    feather.Size = size
    feather.Color = color
    feather.Material = Enum.Material.ForceField
    feather.Transparency = 0.3
    feather.CanCollide = false
    feather.Anchored = false
    feather.Massless = true
    feather.Parent = parent
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = parent
    weld.Part1 = feather
    weld.Parent = feather
    
    feather.CFrame = parent.CFrame * CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
    
    return feather
end

local function createAngelWing(side)
    local wingModel = Instance.new("Model")
    wingModel.Name = "AngelWing_" .. side
    wingModel.Parent = character
    
    -- Tulang utama sayap (bone structure)
    local mainBone = Instance.new("Part")
    mainBone.Size = Vector3.new(0.3, 0.3, 4)
    mainBone.Color = Color3.fromRGB(20, 20, 20)
    mainBone.Material = Enum.Material.Neon
    mainBone.Transparency = 0.2
    mainBone.CanCollide = false
    mainBone.Anchored = false
    mainBone.Massless = true
    mainBone.Parent = wingModel
    
    -- Tambahkan efek asap gelap
    local smokeEffect = Instance.new("ParticleEmitter")
    smokeEffect.Color = ColorSequence.new(Color3.fromRGB(15, 15, 15), Color3.fromRGB(40, 40, 40))
    smokeEffect.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 2)
    })
    smokeEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    smokeEffect.Lifetime = NumberRange.new(1, 2)
    smokeEffect.Rate = 15
    smokeEffect.Speed = NumberRange.new(1, 2)
    smokeEffect.SpreadAngle = Vector2.new(20, 20)
    smokeEffect.Rotation = NumberRange.new(0, 360)
    smokeEffect.RotSpeed = NumberRange.new(-50, 50)
    smokeEffect.Parent = mainBone
    
    -- Buat bulu-bulu sayap (feathers)
    local featherCount = 8
    for i = 1, featherCount do
        local progress = i / featherCount
        local featherSize = Vector3.new(0.15, 0.8 - (progress * 0.3), 2.5 - (progress * 0.8))
        local featherPos = Vector3.new(0, 0, -0.3 * i)
        local featherRot = Vector3.new(0, 0, math.rad(side == "L" and 15 or -15) * progress)
        
        local feather = createFeather(mainBone, featherSize, featherPos, featherRot, Color3.fromRGB(10, 10, 10))
        table.insert(currentWings, feather)
    end
    
    -- Bulu sekunder (lebih kecil)
    for i = 1, 5 do
        local progress = i / 5
        local featherSize = Vector3.new(0.1, 0.5 - (progress * 0.2), 1.8 - (progress * 0.5))
        local featherPos = Vector3.new(0.2 * (side == "L" and -1 or 1), 0, -0.2 * i)
        local featherRot = Vector3.new(0, 0, math.rad(side == "L" and 25 or -25) * progress)
        
        local feather = createFeather(mainBone, featherSize, featherPos, featherRot, Color3.fromRGB(30, 30, 30))
        table.insert(currentWings, feather)
    end
    
    table.insert(currentWings, mainBone)
    return wingModel, mainBone
end

local function createCustomWings()
    clearWings()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local leftWing, leftBone = createAngelWing("L")
    local rightWing, rightBone = createAngelWing("R")
    
    -- Posisi sayap di belakang punggung
    local flapAngle = 0
    local flapDirection = 1
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and rootPart and rootPart.Parent then
            -- Posisi dasar di belakang karakter
            local baseCFrame = rootPart.CFrame * CFrame.new(0, 0.5, 1.2)
            
            -- Animasi mengepak (flapping)
            flapAngle = flapAngle + (0.03 * flapDirection)
            if flapAngle > 0.3 or flapAngle < -0.3 then
                flapDirection = -flapDirection
            end
            
            -- Sayap kiri
            leftBone.CFrame = baseCFrame * CFrame.new(-1.2, 0, 0) * CFrame.Angles(0, math.rad(20 + (flapAngle * 30)), math.rad(-10))
            
            -- Sayap kanan
            rightBone.CFrame = baseCFrame * CFrame.new(1.2, 0, 0) * CFrame.Angles(0, math.rad(-20 - (flapAngle * 30)), math.rad(10))
        end
    end)
    
    table.insert(currentWings, leftWing)
    table.insert(currentWings, rightWing)
end

local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        createCustomWings()
        mainButton.Text = "✅\nSAYAP AKTIF"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        stroke.Color = Color3.fromRGB(0, 255, 0)
        print("✨ [WINGS] Sayap Malaikat Hitam Dipasang!")
    else
        clearWings()
        mainButton.Text = "🦇\nSAYAP MALAIKAT"
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
    if wingsActive then createCustomWings() end
end)

print("========================================")
print("✅ SAYAP MALAIKAT HITAM SIAP!")
print("👉 Tombol MERAH di TENGAH LAYAR")
print("🦇 Sayap dengan bulu realistis + aura asap")
print("✨ Animasi mengepak otomatis")
print("========================================")
