-- Black Wings with GUI Button (Mobile & PC) - UPGRADED & FIXED VERSION
-- Tekan tombol di layar untuk memunculkan/menghilangkan sayap

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local currentWings = {}
local wingConnection = nil

-- Konfigurasi Visual Sayap
local WING_COLOR = Color3.fromRGB(15, 15, 15) -- Warna hitam pekat
local WING_GLOW = false -- Set true jika ingin sayap menyala (Neon)

-- ==================== 1. GUI SETUP (DIPERBAIKI) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WingsToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- FIX: Agar tidak tertutup topbar Roblox
screenGui.DisplayOrder = 999 -- FIX: Agar selalu di atas UI game lain
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (bisa di-drag agar tidak terhalang UI game)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 80, 0, 80)
mainFrame.Position = UDim2.new(1, -100, 1, -100) -- Pojok kanan bawah
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Tombol
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.BackgroundTransparency = 0.2
button.BorderSizePixels = 0
button.Text = "🦇"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 40
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.ZIndex = 10
button.Parent = mainFrame

-- UI Corner & Stroke agar tombol terlihat jelas dan rapi
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 2
stroke.Parent = button

-- FITUR DRAG: Tombol bisa digeser jika terhalang UI game
local dragging, dragInput, dragStart, startPos
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==================== 2. FUNGSI SAYAP (DIPERBAIKI) ====================
local function clearWings()
    -- FIX: Putus koneksi RunService agar tidak error saat karakter mati
    if wingConnection then
        wingConnection:Disconnect()
        wingConnection = nil
    end
    for _, wing in pairs(currentWings) do
        if wing and wing.Parent then
            wing:Destroy()
        end
    end
    currentWings = {}
end

local function createCustomWings()
    clearWings()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local function createWingPart(name)
        local wing = Instance.new("Part")
        wing.Name = name
        wing.Size = Vector3.new(3.5, 0.3, 4)
        wing.Color = WING_COLOR
        wing.Material = WING_GLOW and Enum.Material.Neon or Enum.Material.SmoothPlastic
        wing.CanCollide = false
        wing.Anchored = false
        wing.Massless = true -- FIX: Agar sayap tidak memberatkan fisika karakter
        wing.Transparency = 0.1
        wing.Parent = character
        return wing
    end

    local wingL = createWingPart("BlackWing_L")
    local wingR = createWingPart("BlackWing_R")
    
    -- FIX: Gunakan Heartbeat dan hapus WeldConstraint (mencegah jitter/bug fisika)
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and rootPart and rootPart.Parent then
            -- Posisi dan rotasi sayap kiri
            wingL.CFrame = rootPart.CFrame * CFrame.new(-1.5, 0.8, -0.8) * CFrame.Angles(math.rad(10), math.rad(35), math.rad(-5))
            -- Posisi dan rotasi sayap kanan
            wingR.CFrame = rootPart.CFrame * CFrame.new(1.5, 0.8, -0.8) * CFrame.Angles(math.rad(10), math.rad(-35), math.rad(5))
        end
    end)
    
    table.insert(currentWings, wingL)
    table.insert(currentWings, wingR)
end

local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        createCustomWings()
        button.Text = "✅"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        stroke.Color = Color3.fromRGB(0, 255, 0)
    else
        clearWings()
        button.Text = "🦇"
        button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        stroke.Color = Color3.fromRGB(100, 100, 100)
    end
end

-- ==================== 3. EVENT & INPUT (DIPERBAIKI) ====================
-- FIX: Hapus TouchTap, MouseButton1Click sudah cukup untuk PC & Mobile
button.MouseButton1Click:Connect(function()
    -- Animasi tekan menggunakan TweenService (lebih halus)
    local tweenDown = tweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0.9, 0)})
    tweenDown:Play()
    task.delay(0.1, function()
        tweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    end)
    
    toggleWings()
end)

-- ==================== 4. RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    clearWings() -- Bersihkan sayap lama dan connection
    task.wait(0.5)
    if wingsActive then
        createCustomWings()
    end
end)

-- ==================== 5. NOTIFIKASI SUKSES (FITUR BARU) ====================
-- Membuat notifikasi agar user yakin script berhasil dieksekusi
local notif = Instance.new("TextLabel")
notif.Size = UDim2.new(0, 300, 0, 50)
notif.Position = UDim2.new(0.5, -150, 0.1, 0)
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(255, 255, 255)
notif.Text = "✨ Script Sayap Hitam Berhasil Dimuat! ✨\nTombol ada di pojok kanan bawah (Bisa digeser)"
notif.TextScaled = true
notif.Font = Enum.Font.GothamBold
notif.Parent = screenGui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)

task.delay(4, function()
    local tween = tweenService:Create(notif, TweenInfo.new(1), {BackgroundTransparency = 1, TextTransparency = 1})
    tween:Play()
    task.wait(1)
    notif:Destroy()
end)

print("========================================")
print("✨ SCRIPT SAYAP HITAM (UPGRADED) SIAP! ✨")
print("📱 Tombol bisa DIGESER jika terhalang UI")
print("💻 Kompatibel HP & PC")
print("========================================")
