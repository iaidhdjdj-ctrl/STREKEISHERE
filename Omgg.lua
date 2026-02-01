local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [ نظام اللغات ]
local Localization = {
    ["Arabic"] = {
        WinName = "المركز المتكامل | Ultimate Pro Hub",
        InfoTab = "تعريف / Information",
        MainTab = "اللاعب",
        VisualTab = "الرادار",
        DevTab = "أدوات المطور",
        SettingsTab = "الإعدادات",
        AboutTitle = "من نحن؟",
        AboutText = "نحن سكربت عربي تحديدا ultimate pro hub نوفر لك جميع الادوات الي تحتاجها كلاعب دون جعل هذه الادوات تخرب تجربه العب على باقي الاعبين فا نحن لا نضع spam او lag او انظمه اختراق back door شكرا لدعمنا",
        LangSelect = "اختر اللغة Alpha Beta (بنسبة كبيرة لا يعمل)"
    }
}

local curr = Localization["Arabic"]

local Window = Rayfield:CreateWindow({
   Name = curr.WinName,
   Icon = "shield-check",
   LoadingTitle = "Ultimate Pro Hub",
   LoadingSubtitle = "تم صنعه بواسطة ultimate hub team",
   ConfigurationSaving = {Enabled = false},
   DisableRayfieldPrompts = true
})

-- [ متغيرات الأنظمة ]
local player = game.Players.LocalPlayer
local flying = false
local flySpeed = 100
local espEnabled = false
local infoEnabled = false

-- [ 1. تبويب التعريف ]
local InfoTab = Window:CreateTab(curr.InfoTab, "info")
InfoTab:CreateSection(curr.AboutTitle)
InfoTab:CreateParagraph({Title = "Ultimate Pro Hub", Content = curr.AboutText .. "\n\nتم صنعه بواسطة ultimate hub team"})

-- [ 2. تبويب اللاعب ]
local MainTab = Window:CreateTab(curr.MainTab, "user")
MainTab:CreateSlider({
   Name = "سرعة المشي",
   Range = {16, 500},
   Increment = 10,
   CurrentValue = 16,
   Callback = function(v)
      if player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid.WalkSpeed = v
      end
   end,
})

MainTab:CreateToggle({
   Name = "نظام الطيران (حسب اتجاه الكاميرا)",
   CurrentValue = false,
   Callback = function(state)
      flying = state
      local char = player.Character
      local root = char and char:FindFirstChild("HumanoidRootPart")
      local hum = char and char:FindFirstChild("Humanoid")
      if flying and root and hum then
         local bv = Instance.new("BodyVelocity", root)
         bv.Name = "FlyVel"
         bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
         local bg = Instance.new("BodyGyro", root)
         bg.Name = "FlyGyro"
         bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
         hum.PlatformStand = true
         task.spawn(function()
            while flying and root and bv.Parent do
               bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * (hum.MoveDirection.Magnitude > 0 and flySpeed or 0)
               bg.CFrame = workspace.CurrentCamera.CFrame
               task.wait()
            end
            bv:Destroy() bg:Destroy()
            hum.PlatformStand = false
         end)
      end
   end,
})

-- [ 3. تبويب الرادار ]
local VisualTab = Window:CreateTab(curr.VisualTab, "eye")
local function applyESP(p)
    if p == player then return end
    local function setup(char)
        if not char then return end
        task.wait(1)
        local h = char:FindFirstChild("ESPHighlight") or Instance.new("Highlight", char)
        h.Name = "ESPHighlight"
        h.Enabled = espEnabled
        h.FillColor = Color3.fromRGB(0, 255, 150)
        local head = char:WaitForChild("Head", 10)
        if head then
            local bbg = head:FindFirstChild("ESPInfo") or Instance.new("BillboardGui", head)
            bbg.Name = "ESPInfo"
            bbg.Size = UDim2.new(0, 200, 0, 50)
            bbg.AlwaysOnTop = true
            bbg.Enabled = infoEnabled
            local label = bbg:FindFirstChild("TextLabel") or Instance.new("TextLabel", bbg)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            task.spawn(function()
                while bbg.Parent and char.Parent do
                    if infoEnabled and player.Character and char:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        label.Text = p.Name .. " [" .. math.floor(dist) .. "m]"
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
    if p.Character then setup(p.Character) end
    p.CharacterAdded:Connect(setup)
end

VisualTab:CreateToggle({
   Name = "تفعيل التحديد (Glow)",
   CurrentValue = false,
   Callback = function(state)
      espEnabled = state
      for _, p in pairs(game.Players:GetPlayers()) do
          if p.Character and p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight.Enabled = state end
      end
   end,
})

VisualTab:CreateToggle({
   Name = "إظهار الأسماء والمسافات",
   CurrentValue = false,
   Callback = function(state)
      infoEnabled = state
      for _, p in pairs(game.Players:GetPlayers()) do
          if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESPInfo") then p.Character.Head.ESPInfo.Enabled = state end
      end
   end,
})

for _, p in pairs(game.Players:GetPlayers()) do applyESP(p) end
game.Players.PlayerAdded:Connect(applyESP)

-- [ 4. تبويب أدوات المطور ]
local DevTab = Window:CreateTab(curr.DevTab, "code")
DevTab:CreateButton({ Name = "فتح Dex V3", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })

DevTab:CreateSection("إخلاء مسؤولية / Disclaimer")
DevTab:CreateButton({ 
    Name = "تشغيل Infinite Yield", 
    Callback = function() 
        Rayfield:Notify({
            Title = "تنبيه هام",
            Content = "جرب هذا السكربت على مسؤوليتك ونحن غير مسؤولين عن أي أفعال غير أخلاقية.",
            Duration = 5,
            Image = "alert-triangle"
        })
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() 
    end 
})

-- [ 5. تبويب الإعدادات ]
local SettingsTab = Window:CreateTab(curr.SettingsTab, "settings")
SettingsTab:CreateDropdown({
   Name = curr.LangSelect,
   Options = {"Arabic", "English"},
   CurrentOption = {"Arabic"},
   Callback = function(Option)
      Rayfield:Notify({Title = "Alpha Beta", Content = "هذه الخاصية لا تعمل حالياً.", Duration = 3})
   end,
})

Rayfield:Notify({
   Title = "Ultimate Pro Hub",
   Content = "تم صنعه بواسطة ultimate hub team",
   Duration = 5,
   Image = "shield-check"
})
