--]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ⚠️ GIST RAW LİNKİNİZİ BURAYA YAPIŞTIRIN:
local DATABASE_URL = "https://gist.githubusercontent.com/zBakman/c9c7124e0f1020ce0e677b340b9c9355/raw/Keys.json"

--------------------------------------------------------------------
-- 1. WATERMARK (Sol Üst İmza)
--------------------------------------------------------------------
spawn(function()
    pcall(function() game.CoreGui:FindFirstChild("zBakmanWM"):Destroy() end)
    local WM_Gui = Instance.new("ScreenGui")
    WM_Gui.Name = "zBakmanWM"
    if gethui then WM_Gui.Parent = gethui() else WM_Gui.Parent = game.CoreGui end
    
    local WM_Label = Instance.new("TextLabel", WM_Gui)
    WM_Label.BackgroundTransparency = 1.0
    WM_Label.Position = UDim2.new(0, 20, 0, 20)
    WM_Label.Size = UDim2.new(0, 200, 0, 30)
    WM_Label.Font = Enum.Font.GothamBlack
    WM_Label.Text = "zBakmanHub"
    WM_Label.TextColor3 = Color3.fromRGB(170, 85, 255)
    WM_Label.TextSize = 24.0
    WM_Label.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIStroke", WM_Label).Thickness = 2
end)

--------------------------------------------------------------------
-- 2. VERİTABANI VE GÜVENLİK KONTROLÜ
--------------------------------------------------------------------
local function GetDatabase()
    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(DATABASE_URL.. "?t=".. tostring(os.time())))
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
    Rayfield:Notify({Title = "Error ❌", Content = "Database Connection Failed!", Duration = 5})
    return
end

local IsVIP = false
if DB.vips and table.find(DB.vips, UserHWID) then IsVIP = true end

--------------------------------------------------------------------
-- 3. ARAYÜZ (UI) KURULUMU
--------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "zBakman Hub | ".. (IsVIP and "Premium 💎" or "Free"),
   LoadingTitle = "Authenticating...",
   Theme = "Amethyst",
   ConfigurationSaving = { Enabled = false },
   KeySystem = not IsVIP,
   KeySettings = {
      Title = "Gateway Verification",
      Subtitle = "Daily Key Required",
      Note = "Get your key from the Discord server.",
      FileName = "zBakmanKey_Pro",
      SaveKey = false, 
      GrabKeyFromSite = false,
      Key = {tostring(DB.current_key)}
   }
})

-- === TAB 1: DASHBOARD ===
local HomeTab = Window:CreateTab("Dashboard", 4483345998)
HomeTab:CreateSection("User Information")
HomeTab:CreateLabel("👤 Player: ".. LocalPlayer.Name)
HomeTab:CreateLabel("💎 Status: ".. (IsVIP and "VIP Access" or "Free Access"))
HomeTab:CreateLabel("🆔 HWID: ".. UserHWID)

HomeTab:CreateButton({
   Name = "Copy HWID",
   Callback = function()
      setclipboard(UserHWID)
      Rayfield:Notify({Title = "Copied", Content = "HWID copied to clipboard!", Duration = 2})
   end,
})

-- === TAB 2: UNIVERSAL (Hareket & Temel) ===
local UniTab = Window:CreateTab("Universal", 4483362458)
UniTab:CreateSlider({
   Name = "WalkSpeed", Range = {16, 300}, Increment = 1, CurrentValue = 16,
   Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end,
})
UniTab:CreateSlider({
   Name = "JumpPower", Range = {50, 500}, Increment = 1, CurrentValue = 50,
   Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end,
})
UniTab:CreateToggle({
   Name = "Noclip (Duvardan Geçme)", CurrentValue = false,
   Callback = function(v) 
       _G.Noclip = v
       RunService.Stepped:Connect(function()
           if _G.Noclip and LocalPlayer.Character then
               for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                   if p:IsA("BasePart") then p.CanCollide = false end
               end
           end
       end)
   end,
})

-- === TAB 3: TROLL & COMBAT ===
local CombatTab = Window:CreateTab("Troll & Combat", 4483364237)

local Flinging = false
CombatTab:CreateToggle({
   Name = "Fling Modu (Çarptığını Uçurur)", CurrentValue = false,
   Callback = function(Value)
       Flinging = Value
       if Flinging and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           local hrp = LocalPlayer.Character.HumanoidRootPart
           local bav = Instance.new("BodyAngularVelocity", hrp)
           bav.AngularVelocity = Vector3.new(0, 99999, 0)
           bav.MaxTorque = Vector3.new(0, math.huge, 0)
           bav.Name = "zFling"
       else
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local bav = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("zFling")
               if bav then bav:Destroy() end
           end
       end
   end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Expander (Kafadan Vurma)", Range = {2, 50}, Increment = 1, CurrentValue = 2,
   Callback = function(Value)
       _G.HitboxSize = Value
       RunService.RenderStepped:Connect(function()
           for _, v in pairs(Players:GetPlayers()) do
               if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                   v.Character.HumanoidRootPart.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                   v.Character.HumanoidRootPart.Transparency = 0.7
                   v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Bright purple")
                   v.Character.HumanoidRootPart.CanCollide = false
               end
           end
       end)
   end,
})

-- === TAB 4: PLAYERS (İzleme ve Işınlanma) ===
local PlayerTab = Window:CreateTab("Players", 4483345998)
local targetPlayer = ""

PlayerTab:CreateInput({
   Name = "Oyuncu Adını Gir", PlaceholderText = "Örn: Player123", RemoveTextAfterFocusLost = false,
   Callback = function(Text) targetPlayer = Text end,
})

PlayerTab:CreateButton({
   Name = "Oyuncuyu İzle (Spectate)",
   Callback = function()
       for _, p in pairs(Players:GetPlayers()) do
           if string.sub(string.lower(p.Name), 1, string.len(targetPlayer)) == string.lower(targetPlayer) then
               workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
               Rayfield:Notify({Title="Spectating", Content=p.Name, Duration=3})
           end
       end
   end,
})

PlayerTab:CreateButton({
   Name = "İzlemeyi Durdur",
   Callback = function()
       if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
   end,
})

PlayerTab:CreateButton({
   Name = "Oyuncuya Işınlan",
   Callback = function()
       for _, p in pairs(Players:GetPlayers()) do
           if string.sub(string.lower(p.Name), 1, string.len(targetPlayer)) == string.lower(targetPlayer) then
               if LocalPlayer.Character and p.Character then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
               end
           end
       end
   end,
})

-- === TAB 5: VISUALS ===
local VisTab = Window:CreateTab("Visuals", 4483362458)
VisTab:CreateButton({
   Name = "ESP Aç (Kırmızı Kutu)",
   Callback = function()
      for _, p in pairs(Players:GetPlayers()) do
         if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("zESP") then
            local h = Instance.new("Highlight", p.Character)
            h.Name = "zESP"
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(170, 85, 255)
         end
      end
   end,
})

Rayfield:LoadConfiguration()
