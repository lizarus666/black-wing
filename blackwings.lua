-- BLACK ANGEL WINGS - FIXED & DEBUG VERSION
print("🔄 [WINGS] Memuat script...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local wingConnection = nil
local wingModel = nil

-- ==================== GUI SETUP ====================
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackWingsFixed"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999
screenGui.Parent = playerGui

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 200, 0, 200)
mainButton.Position = UDim2.new(0.5, -100, 0.5, -100)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
mainButton.Text = "🦇\nTEKAN SAYAP"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 24
mainButton.Font = Enum.Font.GothamBlack
mainButton.Parent = screenGui

Instance.new("UICorner", mainButton).CornerRadius = UDim.new(0, 25)

-- ==================== FUNGSI SAYAP (DIPERBAIKI) ====================
local function clearWings()
    print("🧹 [WINGS] Membersihkan sayap lama...")
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    if wingModel and wingModel.Parent then
        wingModel:Destroy()
        wingModel = nil
    end
end

local function createWings()
    print("🔨 [WINGS] Mulai membuat sayap...")
    clearWings()
    
    local rootPart = character:WaitForChild("HumanoidRootPart")
    if not rootPart then
        warn("❌ [WINGS] HumanoidRootPart tidak ditemukan!")
        return
    end
    
    wingModel = Instance.new("Model")
    wingModel.Name = "BlackAngelWings"
    wingModel.Parent = character
    
    -- ===== ANCHOR PART (induk semua sayap) =====
    local anchor = Instance.new("Part")
    anchor.Name = "WingAnchor"
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = false
    anchor.Massless = true
    anchor.Parent = wingModel
    
    -- Weld anchor ke HumanoidRootPart
    local anchorWeld = Instance.new("Weld")
    anchorWeld.Part0 = rootPart
    anchorWeld.Part1 = anchor
    anchorWeld.C0 = CFrame.new(0, 0.5, 1.2) -- Posisi di punggung
    anchorWeld.Parent = anchor
    print("✅ [WINGS] Anchor dibuat dan di-weld")
    
    -- ===== FUNGSI BANTUAN: BUAT BULU =====
    local function createFeather(name, size, color, position, angles)
        local feather = Instance.new("Part")
        feather.Name = name
        feather.Size = size
        feather.Color = color
        feather.Material = Enum.Material.Fabric
        feather.Transparency = 0.2
        feather.CanCollide = false
        feather.Anchored = false
        feather.Massless = true
        feather.Parent = wingModel
        
        local weld = Instance.new("Weld")
        weld.Part0 = anchor
        weld.Part1 = feather
        weld.C0 = CFrame.new(position.X, position.Y, position.Z) * CFrame.Angles(angles.X, angles.Y, angles.Z)
        weld.Parent = feather
        
        return feather
    end
    
    -- ===== BUAT SAYAP KIRI =====
    print("🔨 [WINGS] Membuat sayap kiri...")
    local leftFeathers = {}
    
    -- Tulang utama kiri
    local leftBone = createFeather("LeftBone", 
        Vector3.new(0.3, 0.3, 3), 
        Color3.fromRGB(20, 20, 20),
        Vector3.new(-1, 0.5, 0),
        Vector3.new(0, math.rad(20), 0))
    table.insert(leftFeathers, leftBone)
    
    -- Bulu-bulu primer kiri (8 bulu)
    for i = 1, 8 do
        local progress = i / 8
        local length = 3.5 - (progress * 1.2)
        local offsetX = -1 - (progress * 1.5)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        local feather = createFeather("LeftFeather" .. i,
            Vector3.new(0.6, 0.1, length),
            Color3.fromRGB(15, 15, 15),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(15 + progress * 25), math.rad(progress * 10)))
        table.insert(leftFeathers, feather)
    end
    
    -- ===== BUAT SAYAP KANAN =====
    print("🔨 [WINGS] Membuat sayap kanan...")
    local rightFeathers = {}
    
    -- Tulang utama kanan
    local rightBone = createFeather("RightBone",
        Vector3.new(0.3, 0.3, 3),
        Color3.fromRGB(20, 20, 20),
        Vector3.new(1, 0.5, 0),
        Vector3.new(0, math.rad(-20), 0))
    table.insert(rightFeathers, rightBone)
    
    -- Bulu-bulu primer kanan (8 bulu)
    for i = 1, 8 do
        local progress = i / 8
        local length = 3.5 - (progress * 1.2)
        local offsetX = 1 + (progress * 1.5)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        local feather = createFeather("RightFeather" .. i,
            Vector3.new(0.6, 0.1, length),
            Color3.fromRGB(15, 15, 15),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(-15 - progress * 25), math.rad(-progress * 10)))
        table.insert(rightFeathers, feather)
    end
    
    -- ===== EFEK ASAP GELAP =====
    print("💨 [WINGS] Menambahkan efek asap...")
    local smoke = Instance.new("ParticleEmitter")
    smoke.Color = ColorSequence.new(Color3.fromRGB(10, 10, 10), Color3.fromRGB(40, 40, 40))
    smoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 3)
    })
    smoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    smoke.Lifetime = NumberRange.new(2, 3)
    smoke.Rate = 20
    smoke.Speed = NumberRange.new(1, 3)
    smoke.SpreadAngle = Vector2.new(30, 30)
    smoke.Rotation = NumberRange.new(0, 360)
    smoke.RotSpeed = NumberRange.new(-50, 50)
    smoke.Parent = anchor
    
    -- ===== ANIMASI MENGEPak =====
    print("🎬 [WINGS] Mengaktifkan animasi...")
    local flapAngle = 0
    local flapDirection = 1
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and anchor and anchor.Parent then
            flapAngle = flapAngle + (0.04 * flapDirection)
            if flapAngle > 0.3 or flapAngle < -0.3 then
                flapDirection = -flapDirection
            end
            
            -- Update posisi anchor dengan animasi mengepak
            anchorWeld.C0 = CFrame.new(0, 0.5, 1.2) * CFrame.Angles(math.rad(flapAngle * 20), 0, 0)
        end
    end)
    
    print("✅ [WINGS] Sayap berhasil dibuat! Total parts:", #leftFeathers + #rightFeathers + 1)
end

-- ==================== TOGGLE FUNCTION ====================
local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        print("🦇 [WINGS] Mengaktifkan sayap...")
        local success, err = pcall(createWings)
        if not success then
            warn("❌ [WINGS] ERROR saat membuat sayap:", err)
            wingsActive = false
            return
        end
        mainButton.Text = "✅\nSAYAP AKTIF"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        print("😴 [WINGS] Mematikan sayap...")
        clearWings()
        mainButton.Text = "🦇\nTEKAN SAYAP"
        mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    end
end

-- ==================== EVENT TOMBOL ====================
mainButton.MouseButton1Click:Connect(function()
    print("👆 [WINGS] Tombol ditekan!")
    toggleWings()
end)

-- ==================== RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(newChar)
    print("🔄 [WINGS] Karakter respawn...")
    character = newChar
    clearWings()
    task.wait(0.5)
    if wingsActive then
        local success, err = pcall(createWings)
        if not success then
            warn("❌ [WINGS] ERROR saat respawn:", err)
        end
    end
end)

print("========================================")
print("✅ SCRIPT BERHASIL DIMUAT!")
print("👉 TEKAN TOMBOL MERAH DI TENGAH LAYAR")
print("📱 Lihat console untuk debug info")
print("========================================")
