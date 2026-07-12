-- BLACK ANGEL WINGS WITH TEXT INPUT CONTROLS (NO SLIDER BUG)
print("🔄 [WINGS] Memuat script dengan kontrol INPUT TEKS...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local wingsActive = false
local wingConnection = nil
local wingModel = nil
local allFeathers = {}
local smokeEmitter = nil
local anchorPart = nil
local anchorWeld = nil

-- Parameter default
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
controlFrame.Size = UDim2.new(0, 280, 0, 380)
controlFrame.Position = UDim2.new(0, 20, 0.5, -190)
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

-- Fungsi buat input box dengan tombol +/-
local function createInputControl(name, minVal, maxVal, defaultVal, step, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 70)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = controlFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. " (" .. minVal .. " - " .. maxVal .. ")"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Tombol MINUS
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 40, 0, 35)
    minusBtn.Position = UDim2.new(0, 0, 0, 25)
    minusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.TextSize = 20
    minusBtn.Font = Enum.Font.GothamBlack
    minusBtn.Parent = container
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 8)
    
    -- Input Box (bisa diketik)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -100, 0, 35)
    inputBox.Position = UDim2.new(0, 50, 0, 25)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.GothamBold
    inputBox.Text = tostring(defaultVal)
    inputBox.PlaceholderText = "Ketik angka..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)
    
    -- Tombol PLUS
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 40, 0, 35)
    plusBtn.Position = UDim2.new(1, -40, 0, 25)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.TextSize = 20
    plusBtn.Font = Enum.Font.GothamBlack
    plusBtn.Parent = container
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 8)
    
    local currentValue = defaultVal
    
    -- Fungsi update nilai
    local function updateValue(newValue)
        newValue = math.clamp(newValue, minVal, maxVal)
        -- Round ke step terdekat
        newValue = math.floor(newValue / step + 0.5) * step
        newValue = tonumber(string.format("%.1f", newValue))
        currentValue = newValue
        inputBox.Text = tostring(newValue)
        return newValue
    end
    
    -- Event tombol minus
    minusBtn.MouseButton1Click:Connect(function()
        updateValue(currentValue - step)
    end)
    
    -- Event tombol plus
    plusBtn.MouseButton1Click:Connect(function()
        updateValue(currentValue + step)
    end)
    
    -- Event saat user selesai mengetik
    inputBox.FocusLost:Connect(function(enterPressed)
        local numValue = tonumber(inputBox.Text)
        if numValue then
            updateValue(numValue)
        else
            inputBox.Text = tostring(currentValue)
        end
    end)
    
    -- Return function untuk mendapatkan nilai
    return function()
        return currentValue
    end, function()
        updateValue(defaultVal)
    end
end

-- Buat 3 kontrol input
local getWingScale, resetWingScale = createInputControl("Ukuran Sayap", 0.5, 3.0, 1.0, 0.1, 50)
local getSmokeRate, resetSmokeRate = createInputControl("Ketebalan Asap", 0, 100, 30, 5, 130)
local getFeatherLength, resetFeatherLength = createInputControl("Panjang Bulu", 0.5, 3.0, 1.0, 0.1, 210)

-- Tombol TERAPKAN
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(1, -20, 0, 35)
applyButton.Position = UDim2.new(0, 10, 0, 290)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
applyButton.Text = "✅ TERAPKAN PERUBAHAN"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 14
applyButton.Font = Enum.Font.GothamBlack
applyButton.Parent = controlFrame
Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 8)

-- Tombol Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.5, -5, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 335)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
toggleButton.Text = "🦇 ON/OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.Parent = controlFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

-- Tombol Reset
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.5, -5, 0, 35)
resetButton.Position = UDim2.new(0.5, -5, 0, 335)
resetButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resetButton.Text = "🔄 RESET"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 14
resetButton.Font = Enum.Font.GothamBlack
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
    anchorPart = nil
    anchorWeld = nil
end

local function updateWingSize()
    wingScale = getWingScale()
    for _, feather in pairs(allFeathers) do
        if feather and feather.Parent then
            local originalSize = feather:GetAttribute("OriginalSize")
            if originalSize then
                feather.Size = Vector3.new(
                    originalSize.X * wingScale,
                    originalSize.Y * wingScale,
                    originalSize.Z * wingScale
                )
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
    
    anchorPart = Instance.new("Part")
    anchorPart.Name = "WingAnchor"
    anchorPart.Size = Vector3.new(0.1, 0.1, 0.1)
    anchorPart.Transparency = 1
    anchorPart.CanCollide = false
    anchorPart.Anchored = false
    anchorPart.Massless = true
    anchorPart.Parent = wingModel
    
    anchorWeld = Instance.new("Weld")
    anchorWeld.Part0 = rootPart
    anchorWeld.Part1 = anchorPart
    anchorWeld.C0 = CFrame.new(0, 0.8, 1.5)
    anchorWeld.Parent = anchorPart
    
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
        weld.Part0 = anchorPart
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
    smokeEmitter.Parent = anchorPart
    
    -- Animasi
    local flapAngle = 0
    local flapDirection = 1
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and anchorPart and anchorPart.Parent then
            flapAngle = flapAngle + (0.05 * flapDirection)
            if flapAngle > 0.35 or flapAngle < -0.35 then
                flapDirection = -flapDirection
            end
            anchorWeld.C0 = CFrame.new(0, 0.8, 1.5) * CFrame.Angles(math.rad(flapAngle * 25), 0, 0)
        end
    end)
    
    print("✅ [WINGS] Sayap berhasil dibuat!")
end

-- ==================== EVENT HANDLERS ====================
applyButton.MouseButton1Click:Connect(function()
    if wingsActive then
        updateWingSize()
        updateSmokeRate()
        updateFeatherLength()
        print("✅ [WINGS] Perubahan diterapkan!")
    else
        print("⚠️ [WINGS] Aktifkan sayap dulu!")
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    wingsActive = not wingsActive
    
    if wingsActive then
        createWings()
        toggleButton.Text = "✅ AKTIF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        clearWings()
        toggleButton.Text = "🦇 ON/OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    end
end)

resetButton.MouseButton1Click:Connect(function()
    resetWingScale()
    resetSmokeRate()
    resetFeatherLength()
    
    if wingsActive then
        updateWingSize()
        updateSmokeRate()
        updateFeatherLength()
    end
    
    print("🔄 [WINGS] Parameter direset ke default")
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
print("📝 KETIK ANGKA atau tekan +/- untuk atur:")
print("   - Ukuran Sayap (0.5 - 3.0)")
print("   - Ketebalan Asap (0 - 100)")
print("   - Panjang Bulu (0.5 - 3.0)")
print("✅ Tekan TERAPKAN setelah mengubah nilai")
print("🔄 RESET untuk kembalikan ke default")
print("========================================")
