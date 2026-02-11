--[[
    ╔══════════════════════════════════════════════════════════════╗
      zBakman HUB | ULTIMATE PREMIUM LOADER
      Developed by Orhan for the Boss
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ⚠️ AĞAM BURAYI DOLDURMAYI UNUTMA (Gist Keys.json RAW linki)
local DATABASE_URL = "c9c7124e0f1020ce0e677b340b9c9355"

--------------------------------------------------------------------
-- 1. ADIM: SOL ÜST MOR WATERMARK (İMZA)
--------------------------------------------------------------------
spawn(function()
    -- Eğer daha önce çalıştıysa eskisini sil
    pcall(function() game.CoreGui:FindFirstChild("zBakmanWM"):Destroy() end)

    local WM_Gui = Instance.new("ScreenGui")
    local WM_Label = Instance.new("TextLabel")
    local WM_Stroke = Instance.new("UIStroke") -- Yazı kenarlığı (Daha havalı durur)

    WM_Gui.Name = "zBakmanWM"
    -- CoreGui'ye atıyoruz ki oyunun kendi arayüzünün üstünde dursun (Executor destekliyorsa)
    if syn and syn.protect_gui then
        syn.protect_gui(WM_Gui)
        WM_Gui.Parent = game.CoreGui
    elseif gethui then
        WM_Gui.Parent = gethui()
    else
        WM_Gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    WM_Label.Parent = WM_Gui
    WM_Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WM_Label.BackgroundTransparency = 1.000
    WM_Label.Position = UDim2.new(0, 25, 0, 25) -- Sol üstten biraz boşluk
    WM_Label.Size = UDim2.new(0, 200, 0, 30)
    WM_Label.Font = Enum.Font.GothamBlack -- Kalın, premium font
    WM_Label.Text = "zBakmanHub"
    WM_Label.TextColor3 = Color3.fromRGB(170, 85, 255) -- 🔥 NEON MOR RENK
    WM_Label.TextSize = 26.000
    WM_Label.TextXAlignment = Enum.TextXAlignment.Left

    WM_Stroke.Parent = WM_Label
    WM_Stroke.Thickness = 2
    WM_Stroke.Color = Color3.fromRGB(20, 20, 20) -- Siyah kenarlık
end)

--------------------------------------------------------------------
-- 2. ADIM: VERİTABANI & GÜVENLİK KONTROLÜ
--------------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Rayfield:Notify({Title = "System", Content = "Connecting to zBakman Servers...", Duration = 3})

local function GetDatabase()
    if DATABASE_URL == "BURAYA_GIST_RAW_LINKINI_YAPISTIR" then return nil end -- Link girilmemişse
    local Success, Result = pcall(function()
        -- Cache bypass için zaman damgası ekliyoruz
        return HttpService:JSONDecode(game:HttpGet(DATABASE_URL .. "?t=" .. tostring(os.time())))
    end)
    if Success then return Result else return nil end
end

local function GetHWID()
    local HWID = "UNKNOWN"
    -- Farklı executorlar için HWID alma yöntemleri
    if gethwid then HWID = gethwid()
    elseif request then 
        pcall(function() HWID = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end
    return HWID
end

local UserHWID = GetHWID()
local DB = GetDatabase()

if not DB then
    Rayfield:Notify({Title = "Error ❌", Content = "Failed to connect! Check DATABASE_URL in script.", Duration = 10})
    warn("[zBakmanHub] Gist RAW Linkini girmeyi unuttun ağam!")
    return
end

local IsVIP = false
if table.find(DB.vips, UserHWID) then IsVIP = true end

if IsVIP then
    Rayfield:Notify({Title = "Welcome Boss 💎", Content = "VIP Access Granted successfully.", Duration = 5})
else
    Rayfield:Notify({Title = "Welcome User", Content = "Key Required for access.", Duration = 5})
end

--------------------------------------------------------------------
-- 3. ADIM: PREMIUM UI TASARIMI
--------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "zBakman Hub | Ultimate Solution",
   LoadingTitle = "zBakman Hub Loading...",
   LoadingSubtitle = "Powered by OrhanAI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "zBakmanHubConfig", -- Config klasör adı
      FileName = "Settings"
   },
   Discord = {
      Enabled = false, -- Discord butonu (istersen açabiliriz)
      Invite = "seninlinkin", 
      RememberJoins = true 
   },
   KeySystem = not IsVIP, -- VIP değilse Key sor
   KeySettings = {
      Title = "Authentication Gateway",
      Subtitle = "Daily Key Required",
      Note = "Get your key from our Discord server (#access-control).",
      FileName = "zBakmanKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {DB.current_key} -- Gist'ten gelen anlık şifre
   }
})

-- === SEKME 1: MAIN (Ana Özellikler) ===
local MainTab = Window:CreateTab("Main", 4483345998) -- Ev ikonu
local MainSection = MainTab:CreateSection("Character Modifications")

MainTab:CreateSlider({
   Name = "Walk Speed Multiplier",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 16,
   Flag = "WS_Slider", 
   Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

MainTab:CreateSlider({
   Name = "Jump Power Multiplier",
   Range = {50, 1000},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JP_Slider", 
   Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
   end,
})

MainTab:CreateToggle({
   Name = "Noclip (Wall Phase)",
   CurrentValue = false,
   Flag = "NoclipToggle", 
   Callback = function(Value)
       -- Basit Noclip mantığı (Geliştirilebilir)
       _G.Noclip = Value
       game:GetService("RunService").Stepped:Connect(function()
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

-- === SEKME 2: VISUALS (Görseller - ESP vb.) ===
local VisualsTab = Window:CreateTab("Visuals", 4483362458) -- Göz ikonu
local ESPSection = VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateButton({
   Name = "Enable Player ESP (Red Box)",
   Callback = function()
      for _, p in pairs(Players:GetPlayers()) do
         if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("zBakmanHighlight") then
            local h = Instance.new("Highlight", p.Character)
            h.Name = "zBakmanHighlight"
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(170, 0, 255) -- Mor kenarlık
         end
      end
      Rayfield:Notify({Title = "Success", Content = "ESP Loaded.", Duration = 3})
   end,
})

-- === SEKME 3: MISC (Diğer) ===
local MiscTab = Window:CreateTab("Misc", 4483364237) -- Ayar ikonu
local InfoSection = MiscTab:CreateSection("User Information")

MiscTab:CreateLabel("Your HWID: " .. UserHWID)
MiscTab:CreateLabel("Status: " .. (IsVIP and "💎 VIP Active" or "👤 Free User"))

MiscTab:CreateButton({
   Name = "Copy HWID to Clipboard",
   Callback = function()
      setclipboard(UserHWID)
      Rayfield:Notify({Title = "Copied!", Content = "Send this to admin for VIP.", Duration = 3})
   end,
})

MiscTab:CreateSection("UI Settings")
MiscTab:CreateButton({
    Name = "Destroy UI (Panic Button)",
    Callback = function()
        Rayfield:Destroy()
        pcall(function() game.CoreGui:FindFirstChild("zBakmanWM"):Destroy() end) -- Watermark'ı da sil
    end,
 })

Rayfield:LoadConfiguration()
