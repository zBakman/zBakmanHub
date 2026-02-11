--[[
    ╔══════════════════════════════════════════════════════════════╗
      zBakman HUB | ULTIMATE FIXED EDITION
      Developed by zBakman
    ╚══════════════════════════════════════════════════════════════╝
]]

-- KÜTÜPHANELERİ YÜKLE
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ⚠️ AĞAM, GIST RAW LINKINI BU TIRNAKLARIN ARASINA YAPIŞTIR:
local DATABASE_URL = "c9c7124e0f1020ce0e677b340b9c9355" 

-- =================================================================
-- 1. ADIM: SOL ÜST MOR LOGO (WATERMARK)
-- =================================================================
spawn(function()
    pcall(function() game.CoreGui:FindFirstChild("zBakmanWM"):Destroy() end)
    local WM_Gui = Instance.new("ScreenGui")
    WM_Gui.Name = "zBakmanWM"
    if gethui then WM_Gui.Parent = gethui() else WM_Gui.Parent = game.CoreGui end
    
    local WM_Label = Instance.new("TextLabel")
    local WM_Stroke = Instance.new("UIStroke")
    
    WM_Label.Parent = WM_Gui
    WM_Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WM_Label.BackgroundTransparency = 1.000
    WM_Label.Position = UDim2.new(0, 20, 0, 20)
    WM_Label.Size = UDim2.new(0, 200, 0, 30)
    WM_Label.Font = Enum.Font.GothamBlack
    WM_Label.Text = "zBakmanHub"
    WM_Label.TextColor3 = Color3.fromRGB(170, 85, 255) -- Mor Renk
    WM_Label.TextSize = 24.000
    WM_Label.TextXAlignment = Enum.TextXAlignment.Left
    
    WM_Stroke.Parent = WM_Label
    WM_Stroke.Thickness = 2
    WM_Stroke.Color = Color3.fromRGB(10, 10, 10)
end)

-- =================================================================
-- 2. ADIM: VERİTABANI BAĞLANTISI
-- =================================================================
Rayfield:Notify({Title = "Sistem", Content = "Veriler Yükleniyor...", Duration = 2})

local function GetDatabase()
    if DATABASE_URL == "BURAYA_GIST_RAW_LINKINI_YAPISTIR" then return nil end
    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(DATABASE_URL .. "?t=" .. tostring(os.time())))
    end)
    if Success then return Result else return nil end
end

local function GetHWID()
    if gethwid then return gethwid()
    elseif request then 
        local s, r = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
        if s then return r end
    end
    return "UNKNOWN"
end

local DB = GetDatabase()
local UserHWID = GetHWID()

if not DB then
    Rayfield:Notify({Title = "HATA ❌", Content = "Veritabanı Linki Bozuk veya Girilmemiş!", Duration = 5})
    return -- Script burada durur
end

-- VIP KONTROLÜ
local IsVIP = false
if DB.vips and table.find(DB.vips, UserHWID) then IsVIP = true end

-- =================================================================
-- 3. ADIM: MENÜ TASARIMI (Rayfield)
-- =================================================================
local Window = Rayfield:CreateWindow({
   Name = "zBakman Hub | " .. (IsVIP and "Premium 💎" or "Free"),
   LoadingTitle = "zBakman Hub Başlatılıyor...",
   LoadingSubtitle = "by Orhan",
   Theme = "Amethyst", -- Mor Tema
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "zBakmanHub_Final",
      FileName = "Settings"
   },
   Discord = {
      Enabled = true,
      Invite = "seninlinkin", 
      RememberJoins = true 
   },
   KeySystem = not IsVIP, -- VIP DEĞİLSE KEY İSTE
   KeySettings = {
      Title = "Güvenlik Girişi",
      Subtitle = "Key Gerekiyor",
      Note = "Discord'dan alınız: discord.gg/seninlinkin",
      FileName = "zBakmanKey_Final",
      SaveKey = false, -- Şifreyi kaydetme (Güvenlik)
      GrabKeyFromSite = false,
      Key = {tostring(DB.current_key)}
   }
})

-- === SEKME 1: ANA SAYFA ===
local HomeTab = Window:CreateTab("Ana Sayfa", 4483345998)
HomeTab:CreateSection("Kullanıcı Bilgisi")
HomeTab:CreateLabel("👤 İsim: " .. LocalPlayer.Name)
HomeTab:CreateLabel("💎 Durum: " .. (IsVIP and "VIP ÜYE" or "Normal Üye"))
HomeTab:CreateLabel("🆔 HWID: " .. UserHWID)

HomeTab:CreateButton({
   Name = "HWID Kopyala",
   Callback = function()
      setclipboard(UserHWID)
      Rayfield:Notify({Title = "Başarılı", Content = "HWID Kopyalandı!", Duration = 2})
   end,
})

-- === SEKME 2: EVRENSEL (Universal) ===
local UniversalTab = Window:CreateTab("Evrensel", 4483362458)

-- HIZ
UniversalTab:CreateSlider({
   Name = "Koşma Hızı (WalkSpeed)",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider", 
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

-- ZIPLAMA
UniversalTab:CreateSlider({
   Name = "Zıplama (JumpPower)",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpSlider", 
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.JumpPower = Value
       end
   end,
})

-- UÇMA (FLY)
local FlyToggle = false
local FlySpeed = 50
UniversalTab:CreateToggle({
   Name = "Uçma Modu (Fly)",
   CurrentValue = false,
   Flag = "FlyToggle", 
   Callback = function(Value)
       FlyToggle = Value
       if FlyToggle then
           local BodyGyro = Instance.new("BodyGyro", LocalPlayer.Character.HumanoidRootPart)
           local BodyVelocity = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
           BodyGyro.P = 9e4
           BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
           BodyGyro.cframe = LocalPlayer.Character.HumanoidRootPart.CFrame
           BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
           BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
           spawn(function()
               while FlyToggle do
                   RunService.RenderStepped:Wait()
                   if not LocalPlayer.Character then break end
                   LocalPlayer.Character.Humanoid.PlatformStand = true
                   local Camera = workspace.CurrentCamera
                   BodyGyro.cframe = Camera.CoordinateFrame
                   BodyVelocity.velocity = Vector3.new()
                   local moveDir = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
                   BodyVelocity.velocity = (Camera.CFrame.LookVector * moveDir.Z * -FlySpeed) + (Camera.CFrame.RightVector * moveDir.X * FlySpeed)
               end
               if LocalPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand = false end
               BodyGyro:Destroy()
               BodyVelocity:Destroy()
           end)
       end
   end,
})

-- === SEKME 3: GÖRSEL (ESP) ===
local VisualsTab = Window:CreateTab("Görsel", 4483362458)

VisualsTab:CreateButton({
   Name = "ESP Aç (Kırmızı)",
   Callback = function()
      for _, p in pairs(Players:GetPlayers()) do
         if p ~= LocalPlayer and p.Character then
            if not p.Character:FindFirstChild("zBakmanESP") then
                local h = Instance.new("Highlight", p.Character)
                h.Name = "zBakmanESP"
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(170, 0, 255)
            end
         end
      end
      Rayfield:Notify({Title = "ESP", Content = "Aktif Edildi!", Duration = 2})
   end,
})

-- === SEKME 4: AYARLAR ===
local SettingsTab = Window:CreateTab("Ayarlar", 4483364237)
SettingsTab:CreateButton({
   Name = "Arayüzü Kapat (Destroy UI)",
   Callback = function()
      Rayfield:Destroy()
      pcall(function() game.CoreGui:FindFirstChild("zBakmanWM"):Destroy() end)
   end,
})

Rayfield:LoadConfiguration()
