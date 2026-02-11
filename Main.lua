--[[
    ╔══════════════════════════════════════════════════════════════╗
      zBakman HUB | FINAL EDITION
      Theme: Amethyst (Mor) | Mode: Universal
    ╚══════════════════════════════════════════════════════════════╝
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ⚠️ AĞAM GIST RAW LINKINI BURAYA YAPISTIR (Tırnakların arasına)
local DATABASE_URL = "c9c7124e0f1020ce0e677b340b9c9355" 

--------------------------------------------------------------------
-- 1. VERİTABANI BAĞLANTISI (Sessiz ve Hızlı)
--------------------------------------------------------------------
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
    Rayfield:Notify({Title = "Hata ❌", Content = "Veritabanı Bulunamadı!", Duration = 5})
    return
end

local IsVIP = false
if DB.vips and table.find(DB.vips, UserHWID) then IsVIP = true end

--------------------------------------------------------------------
-- 2. MENÜ KURULUMU (Mor Tema & Başlık)
--------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "zBakman Hub | " .. (IsVIP and "Premium 💎" or "Free"),
   LoadingTitle = "zBakman Hub Başlatılıyor...",
   LoadingSubtitle = "By Orhan & Boss",
   Theme = "Amethyst", -- 🔥 İŞTE İSTEDİĞİN MOR TEMA
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "zBakmanHub_Final",
      FileName = "Settings"
   },
   Discord = {
      Enabled = true,
      Invite = "seninlinkin", -- Discord davet kodunu buraya yaz (örn: 'gg/kod')
      RememberJoins = true 
   },
   KeySystem = not IsVIP,
   KeySettings = {
      Title = "Giriş Anahtarı (Key)",
      Subtitle = "Discord'dan Key Alınız",
      Note = "Destek için Discord'a gel!",
      FileName = "zBakmanKey_Final",
      SaveKey = false, -- Kaydetme kapalı (Güvenlik)
      GrabKeyFromSite = false,
      Key = {tostring(DB.current_key)}
   }
})

-- =================================================================
-- 🏠 SEKME 1: ANA SAYFA (Bilgi & Destek)
-- =================================================================
local HomeTab = Window:CreateTab("Ana Sayfa", 4483345998) -- Ev İkonu
local HomeSection = HomeTab:CreateSection("Kullanıcı Bilgileri")

HomeTab:CreateLabel("👤 Kullanıcı: " .. LocalPlayer.Name)
HomeTab:CreateLabel("💎 Üyelik: " .. (IsVIP and "VIP Ayrıcalıklı" or "Normal Üye"))
HomeTab:CreateLabel("🆔 HWID: " .. UserHWID)

HomeTab:CreateSection("Destek & İletişim")
HomeTab:CreateParagraph({Title = "Yardım Lazım mı?", Content = "Her türlü sorun, key alma ve VIP satın alımı için Discord sunucumuza gelmeyi unutma!"})

HomeTab:CreateButton({
   Name = "HWID Kopyala (VIP İçin At)",
   Callback = function()
      setclipboard(UserHWID)
      Rayfield:Notify({Title = "Kopyalandı", Content = "HWID panoya alındı!", Duration = 2})
   end,
})

-- =================================================================
-- 🌍 SEKME 2: EVRENSEL (Uçma, Kaçma, Hız)
-- =================================================================
local UniversalTab = Window:CreateTab("Evrensel", 4483362458) -- Dünya İkonu
local MoveSection = UniversalTab:CreateSection("Hareket")

-- HIZ AYARI
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

-- ZIPLAMA AYARI
UniversalTab:CreateSlider({
   Name = "Zıplama Gücü (JumpPower)",
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
                   
                   -- Yön Kontrolleri (W,A,S,D)
                   -- (Basit mantıkla ileri gider)
                   local moveDir = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
                   BodyVelocity.velocity = (Camera.CFrame.LookVector * moveDir.Z * -FlySpeed) + (Camera.CFrame.RightVector * moveDir.X * FlySpeed)
               end
               -- Kapatılınca Temizle
               LocalPlayer.Character.Humanoid.PlatformStand = false
               BodyGyro:Destroy()
               BodyVelocity:Destroy()
           end)
       end
   end,
})

-- DUVARDAN GEÇME (NOCLIP)
UniversalTab:CreateToggle({
   Name = "Duvardan Geç (Noclip)",
   CurrentValue = false,
   Flag = "NoclipToggle", 
   Callback = function(Value)
       _G.Noclip = Value
       RunService.Stepped:Connect(function()
           if _G.Noclip and LocalPlayer.Character then
               for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                   if part:IsA("BasePart") and part.CanCollide then
                       part.CanCollide = false
                   end
               end
           end
       end)
   end,
})

-- =================================================================
-- 👁️ SEKME 3: GÖRSEL (ESP)
-- =================================================================
local VisualsTab = Window:CreateTab("Görsel", 4483362458) -- Göz İkonu

VisualsTab:CreateButton({
   Name = "ESP Aç (Kırmızı Kutu)",
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
      Rayfield:Notify({Title = "Başarılı", Content = "ESP Aktif Edildi!", Duration = 2})
   end,
})

-- =================================================================
-- ⚙️ SEKME 4: AYARLAR
-- =================================================================
local SettingsTab = Window:CreateTab("Ayarlar", 4483364237)

SettingsTab:CreateButton({
   Name = "Menüyü Kapat (Yok Et)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
