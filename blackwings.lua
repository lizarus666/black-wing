-- BLACK ANGEL WINGS - SMALL BUTTON + HUGE WINGS
print("🔄 [WINGS] Memuat script dengan tombol kecil & sayap besar...")

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
screenGui.Name = "BlackWingsHuge"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999
screenGui.Parent = playerGui

-- TOMBOL KECIL
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 80, 0, 80) -- LEBIH KECIL
mainButton.Position = UDim2.new(0.5, -40, 0.5, -40) -- Sesuaikan posisi
mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
mainButton.Text = "🦇"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 40
mainButton.Font = Enum.Font.GothamBlack
mainButton.Parent = screenGui

Instance.new("UICorner", mainButton).CornerRadius = UDim.new(0, 15)

-- ==================== FUNGSI SAYAP (LEBIH BESAR) ====================
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
    print("🔨 [WINGS] Mulai membuat sayap BESAR...")
    clearWings()
    
    local rootPart = character:WaitForChild("HumanoidRootPart")
    if not rootPart then
        warn("❌ [WINGS] HumanoidRootPart tidak ditemukan!")
        return
    end
    
    wingModel = Instance.new("Model")
    wingModel.Name = "HugeBlackAngelWings"
    wingModel.Parent = character
    
    -- ===== ANCHOR PART =====
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
    anchorWeld.C0 = CFrame.new(0, 0.8, 1.5) -- Posisi lebih tinggi dan belakang
    anchorWeld.Parent = anchor
    print("✅ [WINGS] Anchor dibuat")
    
    -- ===== FUNGSI BANTUAN: BUAT BULU =====
    local function createFeather(name, size, color, position, angles)
        local feather = Instance.new("Part")
        feather.Name = name
        feather.Size = size
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
        
        return feather
    end
    
    -- ===== SAYAP KIRI (SANGAT BESAR) =====
    print("🔨 [WINGS] Membuat sayap kiri BESAR...")
    
    -- Tulang utama kiri (lebih panjang)
    local leftBone = createFeather("LeftBone", 
        Vector3.new(0.4, 0.4, 5), -- LEBIH PANJANG
        Color3.fromRGB(15, 15, 15),
        Vector3.new(-1.5, 0.8, 0), -- LEBIH JAUH
        Vector3.new(0, math.rad(25), 0))
    
    -- Bulu-bulu primer kiri (12 bulu - LEBIH BANYAK)
    for i = 1, 12 do
        local progress = i / 12
        local length = 6 - (progress * 2) -- LEBIH PANJANG (max 6 studs)
        local width = 1.2 - (progress * 0.4) -- LEBIH LEBAR
        local offsetX = -1.5 - (progress * 3) -- LEBIH JAUH (total 4.5 studs)
        local offsetY = 0.8 - (progress * 0.5)
        local offsetZ = -0.4 * i
        
        local feather = createFeather("LeftFeather" .. i,
            Vector3.new(width, 0.15, length),
            Color3.fromRGB(10, 10, 10),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-15 - progress * 25), math.rad(20 + progress * 35), math.rad(progress * 15)))
    end
    
    -- Bulu sekunder kiri (6 bulu)
    for i = 1, 6 do
        local progress = i / 6
        local length = 4.5 - (progress * 1.5)
        local width = 0.9 - (progress * 0.3)
        local offsetX = -1.2 - (progress * 2)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        local feather = createFeather("LeftSecondary" .. i,
            Vector3.new(width, 0.12, length),
            Color3.fromRGB(20, 20, 20),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(15 + progress * 25), math.rad(progress * 10)))
    end
    
    -- ===== SAYAP KANAN (SANGAT BESAR) =====
    print("🔨 [WINGS] Membuat sayap kanan BESAR...")
    
    -- Tulang utama kanan
    local rightBone = createFeather("RightBone",
        Vector3.new(0.4, 0.4, 5),
        Color3.fromRGB(15, 15, 15),
        Vector3.new(1.5, 0.8, 0),
        Vector3.new(0, math.rad(-25), 0))
    
    -- Bulu-bulu primer kanan (12 bulu)
    for i = 1, 12 do
        local progress = i / 12
        local length = 6 - (progress * 2)
        local width = 1.2 - (progress * 0.4)
        local offsetX = 1.5 + (progress * 3)
        local offsetY = 0.8 - (progress * 0.5)
        local offsetZ = -0.4 * i
        
        local feather = createFeather("RightFeather" .. i,
            Vector3.new(width, 0.15, length),
            Color3.fromRGB(10, 10, 10),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-15 - progress * 25), math.rad(-20 - progress * 35), math.rad(-progress * 15)))
    end
    
    -- Bulu sekunder kanan (6 bulu)
    for i = 1, 6 do
        local progress = i / 6
        local length = 4.5 - (progress * 1.5)
        local width = 0.9 - (progress * 0.3)
        local offsetX = 1.2 + (progress * 2)
        local offsetY = 0.5 - (progress * 0.3)
        local offsetZ = -0.3 * i
        
        local feather = createFeather("RightSecondary" .. i,
            Vector3.new(width, 0.12, length),
            Color3.fromRGB(20, 20, 20),
            Vector3.new(offsetX, offsetY, offsetZ),
            Vector3.new(math.rad(-10 - progress * 20), math.rad(-15 - progress * 25), math.rad(-progress * 10)))
    end
    
    -- ===== EFEK ASAP GELAP DRAMATIS =====
    print("💨 [WINGS] Menambahkan efek asap...")
    local smoke = Instance.new("ParticleEmitter")
    smoke.Color = ColorSequence.new(Color3.fromRGB(5, 5, 5), Color3.fromRGB(30, 30, 30))
    smoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(0.5, 4),
        NumberSequenceKeypoint.new(1, 6)
    })
    smoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    smoke.Lifetime = NumberRange.new(3, 4)
    smoke.Rate = 30
    smoke.Speed = NumberRange.new(2, 4)
    smoke.SpreadAngle = Vector2.new(45, 45)
    smoke.Rotation = NumberRange.new(0, 360)
    smoke.RotSpeed = NumberRange.new(-80, 80)
    smoke.Parent = anchor
    
    -- ===== ANIMASI MENGEPak =====
    print("🎬 [WINGS] Mengaktifkan animasi...")
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
    
    print("✅ [WINGS] Sayap BESAR berhasil dibuat!")
end

-- ==================== TOGGLE FUNCTION ====================
local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        print("🦇 [WINGS] Mengaktifkan sayap...")
        local success, err = pcall(createWings)
        if not success then
            warn("❌ [WINGS] ERROR:", err)
            wingsActive = false
            return
        end
        mainButton.Text = "✅"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        print("😴 [WINGS] Mematikan sayap...")
        clearWings()
        mainButton.Text = "🦇"
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
print("✅ SCRIPT BERHASIL!")
print("👉 Tombol KECIL di TENGAH LAYAR")
print("🦇 Sayap SANGAT BESAR & MEGAH")
print("✨ 36 bulu per sayap + efek asap dramatis")
print("========================================")
