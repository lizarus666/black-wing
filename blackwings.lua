-- BLACK ANGEL WINGS - MULTIPLAYER VISIBLE
-- Sistem: Client kirim request → Server buat sayap → Semua player bisa lihat

print("🔄 [WINGS] Memuat sistem Multiplayer...")

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")

local wingsActive = false

-- ==================== 1. BUAT REMOTE EVENT ====================
local remoteName = "BlackWingsRemote"
local remote = repStorage:FindFirstChild(remoteName)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = remoteName
    remote.Parent = repStorage
end
print("✅ [WINGS] RemoteEvent siap")

-- ==================== 2. BUAT SERVER SCRIPT ====================
local serverScriptName = "BlackWingsServer"
local existingServer = game:GetService("ServerScriptService"):FindFirstChild(serverScriptName)

if not existingServer then
    local serverSuccess = pcall(function()
        local serverScript = Instance.new("Script")
        serverScript.Name = serverScriptName
        serverScript.Source = [[
-- SERVER SCRIPT: Membuat sayap yang terlihat semua player
local repStorage = game:GetService("ReplicatedStorage")
local remote = repStorage:WaitForChild("BlackWingsRemote")

local playerWings = {}

local function clearWings(player)
    if playerWings[player] then
        for _, obj in pairs(playerWings[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        playerWings[player] = nil
    end
end

local function createWingsOnServer(player, scale, smokeRate, featherLen)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    clearWings(player)
    playerWings[player] = {}

    local wingModel = Instance.new("Model")
    wingModel.Name = "ServerBlackWings_" .. player.Name
    wingModel.Parent = workspace
    table.insert(playerWings[player], wingModel)

    local anchor = Instance.new("Part")
    anchor.Name = "WingAnchor"
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = false
    anchor.Massless = true
    anchor.Parent = wingModel

    local weld = Instance.new("Weld")
    weld.Part0 = rootPart
    weld.Part1 = anchor
    weld.C0 = CFrame.new(0, 0.8, 1.5)
    weld.Parent = anchor

    local function makeFeather(name, size, color, pos, angles)
        local f = Instance.new("Part")
        f.Name = name
        f.Size = Vector3.new(size.X * scale, size.Y * scale, size.Z * scale * featherLen)
        f.Color = color
        f.Material = Enum.Material.Fabric
        f.Transparency = 0.15
        f.CanCollide = false
        f.Anchored = false
        f.Massless = true
        f.Parent = wingModel

        local w = Instance.new("Weld")
        w.Part0 = anchor
        w.Part1 = f
        w.C0 = CFrame.new(pos.X * scale, pos.Y * scale, pos.Z * scale * featherLen) * CFrame.Angles(angles.X, angles.Y, angles.Z)
        w.Parent = f
    end

    -- Tulang Kiri
    makeFeather("LB", Vector3.new(0.4,0.4,5), Color3.fromRGB(15,15,15), Vector3.new(-1.5,0.8,0), Vector3.new(0,math.rad(25),0))
    -- Bulu Primer Kiri
    for i = 1, 12 do
        local p = i / 12
        makeFeather("LF"..i, Vector3.new(1.2-p*0.4, 0.15, 6-p*2), Color3.fromRGB(10,10,10),
            Vector3.new(-1.5-p*3, 0.8-p*0.5, -0.4*i),
            Vector3.new(math.rad(-15-p*25), math.rad(20+p*35), math.rad(p*15)))
    end
    -- Bulu Sekunder Kiri
    for i = 1, 6 do
        local p = i / 6
        makeFeather("LS"..i, Vector3.new(0.9-p*0.3, 0.12, 4.5-p*1.5), Color3.fromRGB(20,20,20),
            Vector3.new(-1.2-p*2, 0.5-p*0.3, -0.3*i),
            Vector3.new(math.rad(-10-p*20), math.rad(15+p*25), math.rad(p*10)))
    end

    -- Tulang Kanan
    makeFeather("RB", Vector3.new(0.4,0.4,5), Color3.fromRGB(15,15,15), Vector3.new(1.5,0.8,0), Vector3.new(0,math.rad(-25),0))
    -- Bulu Primer Kanan
    for i = 1, 12 do
        local p = i / 12
        makeFeather("RF"..i, Vector3.new(1.2-p*0.4, 0.15, 6-p*2), Color3.fromRGB(10,10,10),
            Vector3.new(1.5+p*3, 0.8-p*0.5, -0.4*i),
            Vector3.new(math.rad(-15-p*25), math.rad(-20-p*35), math.rad(-p*15)))
    end
    -- Bulu Sekunder Kanan
    for i = 1, 6 do
        local p = i / 6
        makeFeather("RS"..i, Vector3.new(0.9-p*0.3, 0.12, 4.5-p*1.5), Color3.fromRGB(20,20,20),
            Vector3.new(1.2+p*2, 0.5-p*0.3, -0.3*i),
            Vector3.new(math.rad(-10-p*20), math.rad(-15-p*25), math.rad(-p*10)))
    end

    -- Asap
    local smoke = Instance.new("ParticleEmitter")
    smoke.Color = ColorSequence.new(Color3.fromRGB(5,5,5), Color3.fromRGB(30,30,30))
    smoke.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1.5),NumberSequenceKeypoint.new(0.5,4),NumberSequenceKeypoint.new(1,6)})
    smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(0.5,0.7),NumberSequenceKeypoint.new(1,1)})
    smoke.Lifetime = NumberRange.new(3,4)
    smoke.Rate = smokeRate
    smoke.Speed = NumberRange.new(2,4)
    smoke.SpreadAngle = Vector2.new(45,45)
    smoke.Rotation = NumberRange.new(0,360)
    smoke.RotSpeed = NumberRange.new(-80,80)
    smoke.Parent = anchor
end

-- Terima request dari client
remote.OnServerEvent:Connect(function(player, action, scale, smokeRate, featherLen)
    if action == "CREATE" then
        createWingsOnServer(player, scale or 1, smokeRate or 30, featherLen or 1)
    elseif action == "REMOVE" then
        clearWings(player)
    end
end)

-- Bersihkan saat player keluar
game.Players.PlayerRemoving:Connect(function(player)
    clearWings(player)
end)

print("✅ [SERVER] Black Wings Server Script aktif!")
]]
        serverScript.Parent = game:GetService("ServerScriptService")
    end)

    if serverSuccess then
        print("✅ [WINGS] Server Script berhasil dibuat!")
    else
        print("❌ [WINGS] Gagal membuat Server Script!")
        print("⚠️ Executor kamu mungkin tidak support server-side script")
        print("⚠️ Sayap hanya akan terlihat oleh kamu sendiri (fallback ke client)")
    end
else
    print("✅ [WINGS] Server Script sudah ada")
end

-- ==================== 3. FALLBACK: CLIENT-SIDE WINGS ====================
local clientWingModel = nil
local clientWingConnection = nil
local clientFeathers = {}
local clientSmoke = nil

local function clearClientWings()
    if clientWingConnection then
        clientWingConnection:Disconnect()
        clientWingConnection = nil
    end
    if clientWingModel and clientWingModel.Parent then
        clientWingModel:Destroy()
        clientWingModel = nil
    end
    clientFeathers = {}
    clientSmoke = nil
end

local function createClientWings(scale, smokeRate, featherLen)
    clearClientWings()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    clientWingModel = Instance.new("Model")
    clientWingModel.Name = "ClientBlackWings"
    clientWingModel.Parent = character

    local anchor = Instance.new("Part")
    anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = false
    anchor.Massless = true
    anchor.Parent = clientWingModel

    local weld = Instance.new("Weld")
    weld.Part0 = rootPart
    weld.Part1 = anchor
    weld.C0 = CFrame.new(0, 0.8, 1.5)
    weld.Parent = anchor

    local function makeF(name, size, color, pos, angles)
        local f = Instance.new("Part")
        f.Name = name
        f.Size = Vector3.new(size.X * scale, size.Y * scale, size.Z * scale * featherLen)
        f.Color = color
        f.Material = Enum.Material.Fabric
        f.Transparency = 0.15
        f.CanCollide = false
        f.Anchored = false
        f.Massless = true
        f.Parent = clientWingModel

        local w = Instance.new("Weld")
        w.Part0 = anchor
        w.Part1 = f
        w.C0 = CFrame.new(pos.X * scale, pos.Y * scale, pos.Z * scale * featherLen) * CFrame.Angles(angles.X, angles.Y, angles.Z)
        w.Parent = f
        table.insert(clientFeathers, f)
    end

    makeF("LB", Vector3.new(0.4,0.4,5), Color3.fromRGB(15,15,15), Vector3.new(-1.5,0.8,0), Vector3.new(0,math.rad(25),0))
    for i = 1, 12 do
        local p = i / 12
        makeF("LF"..i, Vector3.new(1.2-p*0.4,0.15,6-p*2), Color3.fromRGB(10,10,10),
            Vector3.new(-1.5-p*3,0.8-p*0.5,-0.4*i), Vector3.new(math.rad(-15-p*25),math.rad(20+p*35),math.rad(p*15)))
    end
    for i = 1, 6 do
        local p = i / 6
        makeF("LS"..i, Vector3.new(0.9-p*0.3,0.12,4.5-p*1.5), Color3.fromRGB(20,20,20),
            Vector3.new(-1.2-p*2,0.5-p*0.3,-0.3*i), Vector3.new(math.rad(-10-p*20),math.rad(15+p*25),math.rad(p*10)))
    end

    makeF("RB", Vector3.new(0.4,0.4,5), Color3.fromRGB(15,15,15), Vector3.new(1.5,0.8,0), Vector3.new(0,math.rad(-25),0))
    for i = 1, 12 do
        local p = i / 12
        makeF("RF"..i, Vector3.new(1.2-p*0.4,0.15,6-p*2), Color3.fromRGB(10,10,10),
            Vector3.new(1.5+p*3,0.8-p*0.5,-0.4*i), Vector3.new(math.rad(-15-p*25),math.rad(-20-p*35),math.rad(-p*15)))
    end
    for i = 1, 6 do
        local p = i / 6
        makeF("RS"..i, Vector3.new(0.9-p*0.3,0.12,4.5-p*1.5), Color3.fromRGB(20,20,20),
            Vector3.new(1.2+p*2,0.5-p*0.3,-0.3*i), Vector3.new(math.rad(-10-p*20),math.rad(-15-p*25),math.rad(-p*10)))
    end

    clientSmoke = Instance.new("ParticleEmitter")
    clientSmoke.Color = ColorSequence.new(Color3.fromRGB(5,5,5), Color3.fromRGB(30,30,30))
    clientSmoke.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1.5),NumberSequenceKeypoint.new(0.5,4),NumberSequenceKeypoint.new(1,6)})
    clientSmoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(0.5,0.7),NumberSequenceKeypoint.new(1,1)})
    clientSmoke.Lifetime = NumberRange.new(3,4)
    clientSmoke.Rate = smokeRate
    clientSmoke.Speed = NumberRange.new(2,4)
    clientSmoke.SpreadAngle = Vector2.new(45,45)
    clientSmoke.Rotation = NumberRange.new(0,360)
    clientSmoke.RotSpeed = NumberRange.new(-80,80)
    clientSmoke.Parent = anchor

    local flapAngle = 0
    local flapDir = 1
    clientWingConnection = runService.Heartbeat:Connect(function()
        if wingsActive and anchor and anchor.Parent then
            flapAngle = flapAngle + (0.05 * flapDir)
            if flapAngle > 0.35 or flapAngle < -0.35 then flapDir = -flapDir end
            weld.C0 = CFrame.new(0, 0.8, 1.5) * CFrame.Angles(math.rad(flapAngle * 25), 0, 0)
        end
    end)
end

-- ==================== 4. GUI SETUP ====================
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WingControlsMP"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 99999
screenGui.Parent = playerGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 280, 0, 380)
controlFrame.Position = UDim2.new(0, 20, 0.5, -190)
controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
controlFrame.BackgroundTransparency = 0.1
controlFrame.BorderSizePixel = 0
controlFrame.Parent = screenGui
Instance.new("UICorner", controlFrame).CornerRadius = UDim.new(0, 15)
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 100, 100)
frameStroke.Thickness = 2
frameStroke.Parent = controlFrame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🦇 SAYAP MULTIPLAYER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBlack
title.Parent = controlFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⏳ Mengecek status server..."
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = controlFrame

-- Cek apakah server script berhasil
task.wait(1)
local serverExists = game:GetService("ServerScriptService"):FindFirstChild(serverScriptName)
if serverExists then
    statusLabel.Text = "🟢 SERVER AKTIF - Semua player bisa lihat!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
else
    statusLabel.Text = "🟡 CLIENT ONLY - Hanya kamu yang bisa lihat"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
end

-- Fungsi buat kontrol input
local function createInputControl(name, defaultVal, step, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 70)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = controlFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

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

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -100, 0, 35)
    inputBox.Position = UDim2.new(0, 50, 0, 25)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.GothamBold
    inputBox.Text = tostring(defaultVal)
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)

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

    local function updateValue(newValue)
        if type(newValue) == "number" and newValue == newValue then
            newValue = math.floor(newValue / step + 0.5) * step
            newValue = tonumber(string.format("%.2f", newValue))
            currentValue = newValue
            inputBox.Text = tostring(newValue)
        end
        return currentValue
    end

    minusBtn.MouseButton1Click:Connect(function() updateValue(currentValue - step) end)
    plusBtn.MouseButton1Click:Connect(function() updateValue(currentValue + step) end)
    inputBox.FocusLost:Connect(function()
        local numValue = tonumber(inputBox.Text)
        if numValue then updateValue(numValue) else inputBox.Text = tostring(currentValue) end
    end)

    return function() return currentValue end, function() updateValue(defaultVal) end
end

local getScale, resetScale = createInputControl("Ukuran Sayap (TANPA BATAS)", 1.0, 0.1, 60)
local getSmoke, resetSmoke = createInputControl("Ketebalan Asap (TANPA BATAS)", 30, 5, 130)
local getFeather, resetFeather = createInputControl("Panjang Bulu (TANPA BATAS)", 1.0, 0.1, 200)

-- Tombol TERAPKAN
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(1, -20, 0, 35)
applyButton.Position = UDim2.new(0, 10, 0, 280)
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
toggleButton.Position = UDim2.new(0, 10, 0, 325)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
toggleButton.Text = "🦇 ON/OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.Parent = controlFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

-- Tombol Reset
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.5, -5, 0, 35)
resetBtn.Position = UDim2.new(0.5, -5, 0, 325)
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resetBtn.Text = "🔄 RESET"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 14
resetBtn.Font = Enum.Font.GothamBlack
resetBtn.Parent = controlFrame
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)

-- ==================== 5. LOGIKA UTAMA ====================
local function activateWings()
    local scale = getScale()
    local smoke = getSmoke()
    local feather = getFeather()

    -- Coba kirim ke server dulu
    if serverExists then
        local success = pcall(function()
            remote:FireServer("CREATE", scale, smoke, feather)
        end)
        if success then
            print("✅ [WINGS] Request dikirim ke SERVER - Semua player bisa lihat!")
            return
        end
    end

    -- Fallback ke client
    print("⚠️ [WINGS] Server tidak tersedia, menggunakan CLIENT mode")
    createClientWings(scale, smoke, feather)
end

local function deactivateWings()
    -- Coba hapus dari server
    if serverExists then
        pcall(function()
            remote:FireServer("REMOVE")
        end)
    end
    -- Hapus dari client juga
    clearClientWings()
end

-- ==================== 6. EVENT HANDLERS ====================
applyButton.MouseButton1Click:Connect(function()
    if wingsActive then
        deactivateWings()
        activateWings()
        print("✅ [WINGS] Perubahan diterapkan!")
    else
        print("⚠️ [WINGS] Aktifkan sayap dulu!")
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    wingsActive = not wingsActive

    if wingsActive then
        activateWings()
        toggleButton.Text = "✅ AKTIF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        deactivateWings()
        toggleButton.Text = "🦇 ON/OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    resetScale()
    resetSmoke()
    resetFeather()
    if wingsActive then
        deactivateWings()
        activateWings()
    end
    print("🔄 [WINGS] Reset ke default")
end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if wingsActive then
        activateWings()
    end
end)

print("========================================")
print("✅ SAYAP MULTIPLAYER SIAP!")
print("🟢 Jika SERVER AKTIF = semua player bisa lihat")
print("🟡 Jika CLIENT ONLY = hanya kamu yang lihat")
print("📝 Panel kontrol di KIRI layar")
print("========================================")
