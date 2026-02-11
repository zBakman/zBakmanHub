--[[
    zBakman HUB | ULTIMATE REPAIR
    Bu kod veri gelmese bile paneli açar, seni bekletmez.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")

-- ✅ SENİN GÜNCEL GIST LİNKİN (BİZZAT KONTROL EDİLDİ)
local DATABASE_URL = "https://gist.githubusercontent.com/zBakman/c9c7124e0f1020ce0e677b340b9c9355/raw/Keys.json"

-- Veriyi çekmeyi deneyelim
local function FetchData()
    local s, r = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(DATABASE_URL .. "?t=" .. tostring(os.time())))
    end)
    if s then return r else return nil end
end

local DB = FetchData()
local HWID = (gethwid and gethwid()) or "UNKNOWN"
local IsVIP = false

-- Eğer veritabanı varsa VIP kontrolü yap
if DB and DB.vips then
    if table.find(DB.vips, HWID) then IsVIP = true end
end

-- 🚀 PANELİ AÇIYORUZ
local Window = Rayfield:CreateWindow({
   Name = "zBakman Hub | " .. (DB and "Bağlandı ✅" or "Çevrimdışı ⚠️"),
   LoadingTitle = "zBakman Hub Yükleniyor...",
   LoadingSubtitle = "Key Sistemi Kontrol Ediliyor",
   Theme = "Amethyst",
   ConfigurationSaving = { Enabled = false },
   KeySystem = not IsVIP, 
   KeySettings = {
      Title = "Güvenlik Girişi",
      Subtitle = "Key Gerekiyor",
      Note = "Discord: discord.gg/seninlinkin",
      FileName = "zBakmanKey",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {tostring(DB and DB.current_key or "HATA")} -- Veri yoksa 'HATA' yazar
   }
})

local Tab = Window:CreateTab("Ana Menü", 4483345998)
Tab:CreateSection("Sistem Durumu")
Tab:CreateLabel("Bağlantı: " .. (DB and "Aktif ✅" or "Başarısız ❌"))
Tab:CreateLabel("VIP Durumu: " .. (IsVIP and "Aktif 💎" or "Pasif 👤"))

-- Basit Özellikler
local Universal = Window:CreateTab("Evrensel", 4483362458)
Universal:CreateSlider({
   Name = "Hız (WalkSpeed)",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end,
})

Rayfield:Notify({Title = "zBakman Hub", Content = "Sistem Hazır!", Duration = 3})
