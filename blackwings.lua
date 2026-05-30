-- Black Wings with GUI Button (Mobile & PC)
-- Tekan tombol di layar untuk memunculkan/menghilangkan sayap

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local userInputService = game:GetService("UserInputService")

local wingsActive = false
local currentWings = {}

-- Pilihan: true = pakai part custom, false = pakai aksesoris dari katalog
local USE_CUSTOM_WINGS = true
local WINGS_ID = 18467392 -- ID sayap hitam

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WingsToggleGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Buat tombol
local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 80, 0, 80)
button.Position = UDim2.new(1, -100, 1, -100) -- Pojok kanan bawah
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.BackgroundTransparency = 0.3
button.BorderSizePixels = 0
button.Parent = screenGui

-- Icon sayap (emoji atau teks)
local buttonLabel = Instance.new("TextLabel")
buttonLabel.Size = UDim2.new(1, 0, 1, 0)
buttonLabel.BackgroundTransparency = 1
buttonLabel.Text = "🦇" -- Emoji sayap/kelelawar
buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonLabel.TextSize = 40
buttonLabel.TextScaled = true
buttonLabel.Font = Enum.Font.GothamBold
buttonLabel.Parent = button

-- Efek hover/tekan
local function animateButtonPress()
    button:TweenSize(UDim2.new(0, 70, 0, 70), "Out", "Quad", 0.1)
    wait(0.1)
    button:TweenSize(UDim2.new(0, 80, 0, 80), "Out", "Quad", 0.1)
end

-- Hapus sayap
local function clearWings()
    for _, wing in pairs(currentWings) do
        if wing and wing.Parent then
            wing:Destroy()
        end
    end
    currentWings = {}
end

-- Buat sayap custom
local function createCustomWings()
    clearWings()
    
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local wingL = Instance.new("Part")
    wingL.Size = Vector3.new(3, 0.5, 4)
    wingL.BrickColor = BrickColor.new("Really black")
    wingL.Material = Enum.Material.Neon
    wingL.CanCollide = false
    wingL.Anchored = false
    wingL.Parent = character
    
    local wingR = Instance.new("Part")
    wingR.Size = Vector3.new(3, 0.5, 4)
    wingR.BrickColor = BrickColor.new("Really black")
    wingR.Material = Enum.Material.Neon
    wingR.CanCollide = false
    wingR.Anchored = false
    wingR.Parent = character
    
    local weldL = Instance.new("WeldConstraint")
    weldL.Part0 = rootPart
    weldL.Part1 = wingL
    weldL.Parent = wingL
    
    local weldR = Instance.new("WeldConstraint")
    weldR.Part0 = rootPart
    weldR.Part1 = wingR
    weldR.Parent = wingR
    
    wingL.CFrame = rootPart.CFrame * CFrame.new(-1.8, 0.5, -1) * CFrame.Angles(0, math.rad(25), 0)
    wingR.CFrame = rootPart.CFrame * CFrame.new(1.8, 0.5, -1) * CFrame.Angles(0, math.rad(-25), 0)
    
    currentWings = {wingL, wingR}
    
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if wingsActive and rootPart and rootPart.Parent then
            if wingL.Parent and wingR.Parent then
                wingL.CFrame = rootPart.CFrame * CFrame.new(-1.8, 0.5, -1) * CFrame.Angles(0, math.rad(25), 0)
                wingR.CFrame = rootPart.CFrame * CFrame.new(1.8, 0.5, -1) * CFrame.Angles(0, math.rad(-25), 0)
            end
        end
    end)
    
    table.insert(currentWings, connection)
end

-- Buat sayap dari katalog
local function equipCatalogWings()
    clearWings()
    
    local success, wings = pcall(function()
        return game:GetService("InsertService"):LoadAsset(WINGS_ID)
    end)
    
    if success and wings and wings:FindFirstChildWhichIsA("Accessory") then
        local accessory = wings:FindFirstChildWhichIsA("Accessory")
        accessory.Parent = character
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:AddAccessory(accessory)
        currentWings = {accessory}
        return true
    else
        USE_CUSTOM_WINGS = true
        createCustomWings()
        return false
    end
end

-- Toggle sayap
local function toggleWings()
    wingsActive = not wingsActive
    
    if wingsActive then
        if USE_CUSTOM_WINGS then
            createCustomWings()
        else
            equipCatalogWings()
        end
        buttonLabel.Text = "✅" -- Centang saat aktif
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        print("✨ Sayap hitam muncul!")
    else
        clearWings()
        buttonLabel.Text = "🦇" -- Kembali ke icon sayap
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        print("😴 Sayap hitam dihilangkan!")
    end
end

-- Event tombol (work di HP & PC)
button.MouseButton1Click:Connect(function()
    animateButtonPress()
    toggleWings()
end)

-- Juga support tap di mobile
button.TouchTap:Connect(function()
    animateButtonPress()
    toggleWings()
end)

-- Biar tetap bekerja setelah respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(0.5)
    if wingsActive then
        clearWings()
        if USE_CUSTOM_WINGS then
            createCustomWings()
        else
            equipCatalogWings()
        end
    end
end)

print("========================================")
print("✨ SCRIPT SAYAP HITAM SIAP! ✨")
print("📱 Tekan tombol di pojok kanan bawah layar")
print("💻 Bisa dipakai di HP maupun laptop")
print("========================================")
