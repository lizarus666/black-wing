-- BLACK WINGS ULTIMATE FIX (PUSAT LAYAR & BYPASS ANTI-CHEAT)
print("🔄 [WINGS] Memulai inisialisasi script...")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local wingsActive = false
local currentWings = {}
local wingConnection = nil

-- ==================== 1. GUI BYPASS & SETUP ====================
local CoreGui = game:GetService("CoreGui")
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackWingsUltimate"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999 -- Prioritas tertinggi

-- Coba masukkan ke CoreGui (Bypass Anti-Cheat Game), jika gagal fallback ke PlayerGui
local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success or not screenGui.Parent then
    screenGui.Parent = PlayerGui
end

print("✅ [WINGS] GUI Berhasil dimuat di:", screenGui.Parent.Name)

-- ==================== 2. TOMBOL BESAR DI TENGAH LAYAR ====================
local mainButton = Instance.new("TextButton")
mainButton.Name = "WingsToggleBtn"
mainButton.Size = UDim2.new(0, 180, 0, 180) -- Ukuran Besar!
mainButton.Position = UDim2.new(0.5, -90, 0.5, -90) -- TEPAT DI TENGAH LAYAR
mainButton.AnchorPoint = Vector2.new(0, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30) -- MERAH MENCOLOK
mainButton.BackgroundTransparency = 0.1
mainButton.BorderSizePixel = 0
mainButton.Text = "🦇\nTEKAN SAYAP"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextSize = 24
mainButton.Font = Enum.Font.GothamBlack
mainButton.AutoButtonColor = true
mainButton.ZIndex = 100
mainButton.Parent = screenGui

-- Biar bulat dan ada garis tepi
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 25)
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 4
stroke.Parent = mainButton

-- Fitur Geser (Draggable) agar bisa dipindah kalau menutupi layar
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

-- ==================== 3. LOGIKA SAYAP ====================
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

local function createCustomWings()
    clearWings()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local function makeWing(name)
        local wing = Instance.new("Part")
        wing.Name = name
        wing.Size = Vector3.new(4, 0.2, 5)
        wing.Color = Color3.fromRGB(10, 10, 10)
        wing.Material = Enum.Material.Neon
        wing.CanCollide = false
        wing.Anchored = false
        wing.Massless = true
        wing.Transparency = 0.2
        wing.Parent = character
        return wing
    end

    local wingL = makeWing("Wing_L")
    local wingR = makeWing("Wing_R")
    
    wingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and rootPart and rootPart.Parent then
            wingL.CFrame = rootPart.CFrame * CFrame.new(-1.5, 1, -1) * CFrame.Angles(math.rad(15), math.rad(30), math.rad(-10))
            wingR.CFrame = rootPart.CFrame * CFrame.new(1.5, 1, -1) * CFrame.Angles(math.rad(15), math.rad(-30), math.rad(10))
        end
    end)
    
    table.insert(currentWings, wingL)
    table.insert(currentWings, wingR)
end

local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        createCustomWings()
        mainButton.Text = "✅\nSAYAP AKTIF"
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Hijau
        stroke.Color = Color3.fromRGB(0, 255, 0)
        print("✨ [WINGS] Sayap Hitam Berhasil Dipasang!")
    else
        clearWings()
        mainButton.Text = "🦇\nTEKAN SAYAP"
        mainButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30) -- Merah
        stroke.Color = Color3.fromRGB(255, 255, 255)
        print("😴 [WINGS] Sayap Dihapus.")
    end
end

-- ==================== 4. EVENT TOMBOL ====================
mainButton.MouseButton1Click:Connect(function()
    -- Animasi tekan
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
print("✅ SCRIPT BERHASIL DI-EXECUTE!")
print("👉 LIHAT TENGAH LAYAR KAMU!")
print("🔴 Tombol MERAH BESAR sudah muncul.")
print("👆 Tekan tombol tersebut untuk memunculkan sayap.")
print("========================================")
