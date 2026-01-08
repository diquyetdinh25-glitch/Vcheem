--====================== CHEEM HUB | ALL IN ONE ======================--
-- Loader + Map Detect + Hub + SaveConfig + Anti AFK
-- Dev friendly – Không chết menu

if getgenv().CheemHubLoaded then return end
getgenv().CheemHubLoaded = true

repeat task.wait() until game:IsLoaded()

--====================== SERVICES ======================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
repeat task.wait() until Player
repeat task.wait() until Player.Character

local UIVisible = true
local GlobalUI = nil

--===== KEY SYSTEM (SAVE KEY) =====--

local HttpService = game:GetService("HttpService")
local KeyFile = "CheemHub_Key.json"

local VALID_KEYS = {
    "CHEEM-9927262626262",
    "CHEEM-81736161626262",
    "CHEEMVIP-27263681837",
    "CHEEM-38177262535262"
}

local function IsValidKey(key)
    for _,v in pairs(VALID_KEYS) do
        if key == v then
            return true
        end
    end
    return false
end

-- Đã lưu key?
if isfile(KeyFile) then
    local saved = HttpService:JSONDecode(readfile(KeyFile))
    if saved and saved.key and IsValidKey(saved.key) then
        -- KEY OK → vào hub luôn
    else
        delfile(KeyFile)
        Player:Kick("❌ Key Expired | Cheem Hub")
    end
else
    --===== UI NHẬP KEY =====--
    local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
    ScreenGui.Name = "KeyUI"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.fromScale(0.3,0.25)
    Frame.Position = UDim2.fromScale(0.35,0.35)
    Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.fromScale(0.9,0.3)
    Box.Position = UDim2.fromScale(0.05,0.25)
    Box.PlaceholderText = "Enter Key"
    Box.Text = ""
    Box.TextScaled = true

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.fromScale(0.5,0.25)
    Btn.Position = UDim2.fromScale(0.25,0.65)
    Btn.Text = "Confirm"
    Btn.TextScaled = true

    Btn.MouseButton1Click:Connect(function()
        if IsValidKey(Box.Text) then
            writefile(KeyFile, HttpService:JSONEncode({
                key = Box.Text,
                time = os.time()
            }))
            ScreenGui:Destroy()
        else
            Player:Kick("❌ Wrong Key | Cheem Hub")
        end
    end)

    repeat task.wait() until not ScreenGui.Parent
end

--====================== NOTIFY ======================--
local function Notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title = "Cheem Hub",
            Text = txt,
            Duration = t or 4
        })
    end)
end

Notify("Loading Cheem Hub...")

--====================== CONFIG ======================--
local ConfigFile = "CheemHub_Config.json"

local Cheem = {}

Cheem.SmartV4 = Cheem.SmartV4 or false
Cheem.AutoHop = Cheem.AutoHop or false
Cheem.AutoBlueGear = Cheem.AutoBlueGear or false
Cheem.HopMode = Cheem.HopMode or "None"

local DefaultConfig = {
    AutoFarm = false,
    Weapon = "Melee",
    Teleport = true,
    AutoEquip = true,

    -- HOP / MIRAGE
    AutoHop = false,
    HopMode = "None",
    AutoBlueGear = false
}

--================ AUTO SYNC CORE =================--
local SyncEvents = {}

local function RegisterSync(name, fn)
    SyncEvents[name] = SyncEvents[name] or {}
    table.insert(SyncEvents[name], fn)
end

local function SyncUI(name, value)
    if SyncEvents[name] then
        for _,fn in ipairs(SyncEvents[name]) do
            pcall(fn, value)
        end
    end
end

local function SaveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(Cheem))
end

local function LoadConfig()
    if isfile(ConfigFile) then
        local data = HttpService:JSONDecode(readfile(ConfigFile))
        for k,v in pairs(DefaultConfig) do
            Cheem[k] = data[k] ~= nil and data[k] or v
        end
    else
        Cheem = table.clone(DefaultConfig)
        SaveConfig()
    end
end

LoadConfig()

--====================== ANTI AFK ======================--
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--====================== UTILS ======================--
local function TP(cf)
    if not Cheem.Teleport then return end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
    end
end

local function EquipWeapon()
    if not Cheem.AutoEquip then return end
    local char = Player.Character
    if not char then return end
    for _,tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

--====================== QUEST DATA (SEA 1) ======================--
local QuestData = {

    -- START ISLAND
    {
        Min = 1, Max = 9,
        QuestName = "BanditQuest1",
        QuestLevel = 1,
        MobName = "Bandit",
        IslandPos = CFrame.new(1060, 16, 1547)
    },
    {
        Min = 10, Max = 14,
        QuestName = "BanditQuest1",
        QuestLevel = 2,
        MobName = "Monkey",
        IslandPos = CFrame.new(-1600, 36, 150)
    },

    -- JUNGLE
    {
        Min = 15, Max = 29,
        QuestName = "JungleQuest",
        QuestLevel = 1,
        MobName = "Gorilla",
        IslandPos = CFrame.new(-1600, 36, 150)
    },
    {
        Min = 30, Max = 39,
        QuestName = "JungleQuest",
        QuestLevel = 2,
        MobName = "Gorilla King",
        IslandPos = CFrame.new(-1600, 36, 150)
    },

    -- PIRATE VILLAGE
    {
        Min = 40, Max = 59,
        QuestName = "BuggyQuest1",
        QuestLevel = 1,
        MobName = "Pirate",
        IslandPos = CFrame.new(-1100, 13, 3800)
    },
    {
        Min = 60, Max = 74,
        QuestName = "BuggyQuest1",
        QuestLevel = 2,
        MobName = "Brute",
        IslandPos = CFrame.new(-1100, 13, 3800)
    },

    -- DESERT
    {
        Min = 75, Max = 89,
        QuestName = "DesertQuest",
        QuestLevel = 1,
        MobName = "Desert Bandit",
        IslandPos = CFrame.new(930, 7, 4480)
    },
    {
        Min = 90, Max = 99,
        QuestName = "DesertQuest",
        QuestLevel = 2,
        MobName = "Desert Officer",
        IslandPos = CFrame.new(930, 7, 4480)
    },

    -- FROZEN VILLAGE
    {
        Min = 100, Max = 119,
        QuestName = "SnowQuest",
        QuestLevel = 1,
        MobName = "Snow Bandit",
        IslandPos = CFrame.new(1380, 87, -1290)
    },
    {
        Min = 120, Max = 149,
        QuestName = "SnowQuest",
        QuestLevel = 2,
        MobName = "Snowman",
        IslandPos = CFrame.new(1380, 87, -1290)
    },

    -- MARINEFORD
    {
        Min = 150, Max = 174,
        QuestName = "MarineQuest2",
        QuestLevel = 1,
        MobName = "Chief Petty Officer",
        IslandPos = CFrame.new(-5030, 29, 4325)
    },
    {
        Min = 175, Max = 189,
        QuestName = "MarineQuest2",
        QuestLevel = 2,
        MobName = "Sky Bandit",
        IslandPos = CFrame.new(-5030, 29, 4325)
    },

    -- SKY ISLAND
    {
        Min = 190, Max = 209,
        QuestName = "SkyQuest",
        QuestLevel = 1,
        MobName = "Dark Master",
        IslandPos = CFrame.new(-4850, 717, -2620)
    },

    -- PRISON
    {
        Min = 210, Max = 249,
        QuestName = "PrisonQuest",
        QuestLevel = 1,
        MobName = "Prisoner",
        IslandPos = CFrame.new(4850, 5, 735)
    },

    -- COLOSSEUM
    {
        Min = 250, Max = 299,
        QuestName = "ColosseumQuest",
        QuestLevel = 1,
        MobName = "Toga Warrior",
        IslandPos = CFrame.new(-1500, 7, -3000)
    },

    -- MAGMA VILLAGE
    {
        Min = 300, Max = 324,
        QuestName = "MagmaQuest",
        QuestLevel = 1,
        MobName = "Military Soldier",
        IslandPos = CFrame.new(-5250, 8, 8500)
    },
    {
        Min = 325, Max = 374,
        QuestName = "MagmaQuest",
        QuestLevel = 2,
        MobName = "Military Spy",
        IslandPos = CFrame.new(-5250, 8, 8500)
    },

    -- FISHMAN ISLAND
    {
        Min = 375, Max = 399,
        QuestName = "FishmanQuest",
        QuestLevel = 1,
        MobName = "Fishman Warrior",
        IslandPos = CFrame.new(61000, 18, 1560)
    },
    {
        Min = 400, Max = 449,
        QuestName = "FishmanQuest",
        QuestLevel = 2,
        MobName = "Fishman Commando",
        IslandPos = CFrame.new(61000, 18, 1560)
    },

    -- SKYPIEA
    {
        Min = 450, Max = 474,
        QuestName = "SkyExp1Quest",
        QuestLevel = 1,
        MobName = "God's Guard",
        IslandPos = CFrame.new(-4720, 845, -1950)
    },
    {
        Min = 475, Max = 524,
        QuestName = "SkyExp1Quest",
        QuestLevel = 2,
        MobName = "Shanda",
        IslandPos = CFrame.new(-4720, 845, -1950)
    },

    -- FOUNTAIN CITY
    {
        Min = 525, Max = 700,
        QuestName = "FountainQuest",
        QuestLevel = 1,
        MobName = "Galley Pirate",
        IslandPos = CFrame.new(5250, 39, 4050)
    }
}

local function GetQuest(lv)
    for _,q in pairs(QuestData) do
        if lv>=q.Min and lv<=q.Max then
            return q
        end
    end
end

--====================== FARM EFFECT ======================--
local function EnableFarmEffect()
    local char = Player.Character
    if not char then return end
    if char:FindFirstChild("CheemHighlight") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "CheemHighlight"
    hl.Parent = char
    hl.Adornee = char

    hl.FillColor = Color3.fromRGB(255, 221, 0)      -- 🟡 vàng
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
end

local function DisableFarmEffect()
    local char = Player.Character
    if not char then return end

    local hl = char:FindFirstChild("CheemHighlight")
    if hl then
        hl:Destroy()
    end
end

---====================== LOAD ORION + FALLBACK ======================--
local OrionLib
local UseFallback = false
local GlobalUI = nil

local ok = pcall(function()
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not ok or not OrionLib then
    warn("[Cheem Hub] Orion UI failed → Fallback UI enabled")
    UseFallback = true
end

--================ FALLBACK UI (CHEEM BASIC) =================--
if UseFallback then
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local FallbackGui = Instance.new("ScreenGui")
    FallbackGui.Name = "Cheem_Fallback_UI"
    FallbackGui.ResetOnSpawn = false
    FallbackGui.Parent = CoreGui
    _G.FallbackGui = FallbackGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(260, 245)
    Main.Position = UDim2.new(0.5, -130, 0.5, -120)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0
    Main.Parent = FallbackGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = "🐶 Cheem Hub | Blox Fruits"
    Title.TextColor3 = Color3.fromRGB(255,221,0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = Main

    --================ AUTO FARM =================--
    local FarmBtn = Instance.new("TextButton")
    FarmBtn.Size = UDim2.new(1,-20,0,40)
    FarmBtn.Position = UDim2.new(0,10,0,50)
    FarmBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    FarmBtn.TextColor3 = Color3.new(1,1,1)
    FarmBtn.Font = Enum.Font.Gotham
    FarmBtn.TextSize = 14
    FarmBtn.Parent = Main
    Instance.new("UICorner", FarmBtn)

    local function UpdateFarmText()
        FarmBtn.Text = "Auto Farm : " .. (Cheem.AutoFarm and "ON ✅" or "OFF ❌")
    end
    UpdateFarmText()

    RegisterSync("AutoFarm", UpdateFarmText)

    FarmBtn.MouseButton1Click:Connect(function()
        Cheem.AutoFarm = not Cheem.AutoFarm
        SaveConfig()
        SyncUI("AutoFarm", Cheem.AutoFarm)

        if Cheem.AutoFarm then
            EnableFarmEffect()
        else
            DisableFarmEffect()
        end

        UpdateFarmText()
    end)

    --================ TELEPORT =================--
    local TpBtn = Instance.new("TextButton")
    TpBtn.Size = UDim2.new(1,-20,0,40)
    TpBtn.Position = UDim2.new(0,10,0,95)
    TpBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    TpBtn.TextColor3 = Color3.new(1,1,1)
    TpBtn.Font = Enum.Font.Gotham
    TpBtn.TextSize = 14
    TpBtn.Parent = Main
    Instance.new("UICorner", TpBtn)

    local function UpdateTpText()
        TpBtn.Text = "Teleport : " .. (Cheem.Teleport and "ON 🚀" or "OFF ❌")
    end
    UpdateTpText()

    RegisterSync("Teleport", UpdateTpText)

    TpBtn.MouseButton1Click:Connect(function()
        Cheem.Teleport = not Cheem.Teleport
        SaveConfig()
        SyncUI("Teleport", Cheem.Teleport)
        UpdateTpText()
    end)

    --================ AUTO BLUE GEAR =================--
    local BGearBtn = Instance.new("TextButton")
    BGearBtn.Size = UDim2.new(1,-20,0,40)
    BGearBtn.Position = UDim2.new(0,10,0,140)
    BGearBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    BGearBtn.TextColor3 = Color3.new(1,1,1)
    BGearBtn.Font = Enum.Font.Gotham
    BGearBtn.TextSize = 14
    BGearBtn.Parent = Main
    Instance.new("UICorner", BGearBtn)

    local function UpdateBGText()
        BGearBtn.Text = "Auto Blue Gear : " .. (Cheem.AutoBlueGear and "ON 🔵" or "OFF ❌")
    end
    UpdateBGText()

    RegisterSync("AutoBlueGear", UpdateBGText)

    BGearBtn.MouseButton1Click:Connect(function()
        Cheem.AutoBlueGear = not Cheem.AutoBlueGear
        SaveConfig()
        SyncUI("AutoBlueGear", Cheem.AutoBlueGear)
        UpdateBGText()
    end)

--================ SMART V4 =================--
    local SmartBtn = Instance.new("TextButton")
    SmartBtn.Size = UDim2.new(1,-20,0,40)
    SmartBtn.Position = UDim2.new(0,10,0,185)
    SmartBtn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    SmartBtn.TextColor3 = Color3.new(1,1,1)
    SmartBtn.Font = Enum.Font.GothamBold
    SmartBtn.TextSize = 14
    SmartBtn.Parent = Main
    Instance.new("UICorner", SmartBtn)

    local function UpdateSmartText()
        SmartBtn.Text = "Smart V4 : " .. (Cheem.SmartV4 and "ON 🧠🔥" or "OFF ❌")
    end
    UpdateSmartText()

    RegisterSync("SmartV4", UpdateSmartText)

    SmartBtn.MouseButton1Click:Connect(function()
        Cheem.SmartV4 = not Cheem.SmartV4

        -- SMART GỘP LOGIC
        Cheem.AutoHop = Cheem.SmartV4
        Cheem.AutoBlueGear = Cheem.SmartV4
        Cheem.HopMode = Cheem.SmartV4 and "Mirage" or "None"

        SaveConfig()
        SyncUI("SmartV4", Cheem.SmartV4)
        SyncUI("AutoBlueGear", Cheem.AutoBlueGear)
        UpdateSmartText()
    end)
end

--====================== UI ORION ======================--
if not UseFallback then
    local Window = OrionLib:MakeWindow({
        Name = "Cheem Hub | Blox Fruits",
        HidePremium = false,
        SaveConfig = false
    })
    GlobalUI = Window
    
    local ServerTab = Window:MakeTab({Name = "Server"})
    local FarmTab   = Window:MakeTab({Name = "Farmming"})
    local MiscTab   = Window:MakeTab({Name = "Setting"})
    local UpV4Tab   = Window:MakeTab({Name = "Upgrade your tribe V4"}) 
    -- AUTO FARM
    FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = Cheem.AutoFarm,
    Callback = function(v)
        Cheem.AutoFarm = v
        SaveConfig()
        SyncUI("AutoFarm", v)

        if v then
            EnableFarmEffect()
        else
            DisableFarmEffect()
        end
    end
})

    -- WEAPON
    FarmTab:AddDropdown({
        Name = "Weapon",
        Options = {"Melee","Sword","Gun"},
        Default = Cheem.Weapon,
        Callback = function(v)
           Cheem.Weapon = v
           SaveConfig()
           SyncUI("Weapon", v)
       end
}) 

    -- TELEPORT
    MiscTab:AddToggle({
    Name="Teleport",
    Default=Cheem.Teleport,
    Callback=function(v)
        Cheem.Teleport = v
        SaveConfig()
        SyncUI("Teleport", v)
    end
})

    -- REJOIN
    ServerTab:AddButton({
        Name = "Rejoin",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, Player)
        end
    })

UpV4Tab:AddToggle({
    Name = "🕹 Auto pull lever",
    Default = Cheem.SmartV4,
    Callback = function(v)
        Cheem.SmartV4 = v
        Cheem.AutoHop = v
        Cheem.AutoBlueGear = v
        Cheem.HopMode = v and "Mirage" or "None"

        if v then
            Notify("🧠 Auto pull lever started...", 4)
        else
            Notify("❌ Auto pull lever stopped", 3)
        end

        SaveConfig()
        SyncUI("AutoBlueGear", Cheem.AutoBlueGear)
    end
})    
   
   OrionLib:Init()
end

Notify("Cheem Hub Loaded Successfully ✅", 5)

--================ MIRAGE CHECK (REAL) =================--
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local function IsMirageIslandPresent()
    -- 1️⃣ Check ánh sáng đặc trưng
    if Lighting:FindFirstChild("Atmosphere") then
        local atm = Lighting.Atmosphere
        if atm.Density > 0.35 and atm.Haze > 1 then
            return true
        end
    end

    -- 2️⃣ Check đảo lớn giữa biển
    for _,v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart") then
            local size = v:GetExtentsSize()
            if size.X > 800 and size.Z > 800 then
                return true
            end
        end
    end

    -- 3️⃣ Check NPC đặc trưng
    local NPCs = Workspace:FindFirstChild("NPCs")
    if NPCs then
        for _,npc in pairs(NPCs:GetChildren()) do
            if npc.Name:lower():find("advanced") then
                return true
            end
        end
    end

    return false
end

--================ FIND BLUE GEAR =================--
local function FindBlueGear()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            -- đặc trưng Blue Gear
            if v.Color.B > 200
            and v.Material == Enum.Material.Neon
            and v.Size.Magnitude < 15 then
                return v
            end
        end
    end
    return nil
end

local function GoToBlueGear()
    local gear = FindBlueGear()
    if gear then
        Notify("🔵 BLUE GEAR FOUND !!!", 6)
        TP(gear.CFrame * CFrame.new(0, 5, 0))
        return true
    end
    return false
end

--================ AUTO BLUE GEAR LOOP =================--
task.spawn(function()
    while task.wait(3) do
        if not Cheem.AutoBlueGear then continue end
        if not IsMirageIslandPresent() then continue end

        if GoToBlueGear() then
            Cheem.AutoBlueGear = false
            Cheem.AutoHop = false
            SaveConfig()
            Notify("✅ DONE BLUE GEAR", 5)
        end
    end
end)

--================ AUTO HOP MIRAGE =================--
task.spawn(function()
    while task.wait(6) do
        if not Cheem.AutoHop then continue end
        if Cheem.HopMode ~= "Mirage" then continue end

        local found = false
        local ok = pcall(function()
            found = IsMirageIslandPresent()
        end)

        if found then
            Notify("🏝️ MIRAGE ISLAND FOUND !!!", 6)
            Cheem.AutoHop = false
            SaveConfig()
        else
            Notify("Not Mirage → Hop server 🔄", 3)
            HopServer()
            task.wait(10)
        end
    end
end)

--====================== AUTO FARM LOOP (CHUẨN DEV) ======================--
task.spawn(function()
    while task.wait(0.3) do
        if not Cheem.AutoFarm then
            task.wait(0.5)
            continue
        end

        local success, err = pcall(function()
            -- CHECK CHARACTER
            local char = Player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            -- GET LEVEL
            local data = Player:FindFirstChild("Data")
            if not data then return end

            local level = data:FindFirstChild("Level")
            if not level then return end

            local q = GetQuest(level.Value)
            if not q then return end

            -- QUEST GUI
            local gui = Player:FindFirstChild("PlayerGui")
            if not gui then return end

            local main = gui:FindFirstChild("Main")
            if not main then return end

            local questGui = main:FindFirstChild("Quest")

            -- START QUEST
            if not questGui or not questGui.Visible then
                TP(q.IslandPos)
                task.wait(0.4)

                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(
                        "StartQuest",
                        q.QuestName,
                        q.QuestLevel
                    )
                end)

                task.wait(0.4)
            end

            -- ATTACK MOB
            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return end

            for _, m in pairs(enemies:GetChildren()) do
                if not Cheem.AutoFarm then break end

                if m.Name == q.MobName
                and m:FindFirstChild("HumanoidRootPart")
                and m:FindFirstChild("Humanoid")
                and m.Humanoid.Health > 0 then

                    EquipWeapon()
                    hrp.CFrame = m.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)

                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end
            end
        end)

        if not success then
            warn("[Cheem Hub | AutoFarm Error]:", err)
            task.wait(1)
        end
    end
end)

--================ ICON NỔI TOGGLE UI (GLOBAL) =================--
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local IconGui = Instance.new("ScreenGui")
IconGui.Name = "Cheem_Toggle_UI"
IconGui.ResetOnSpawn = false
IconGui.Parent = CoreGui

local Btn = Instance.new("ImageButton")
Btn.Size = UDim2.fromOffset(55,55)
Btn.Position = UDim2.new(0,15,0.45,0)
Btn.BackgroundTransparency = 1
Btn.Image = "rbxassetid://91311717625487" -- icon tròn
Btn.ImageColor3 = Color3.fromRGB(255, 221, 0) -- Yelow Cheem 🟡
Btn.Parent = IconGui

-- DRAG ICON
local dragging, dragStart, startPos
Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Btn.Position
    end
end)

Btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Btn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- TOGGLE UI
Btn.MouseButton1Click:Connect(function()
    local UIVisible = true

    -- ORION UI
    for _,v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("Orion") then
            v.Enabled = UIVisible
        end
    end

    -- FALLBACK UI (nếu sau này có)
    if _G.FallbackGui then
        _G.FallbackGui.Enabled = UIVisible
    end
end)



--==================== CHEEM HUB ANTI-LEAK (SAFE FIX) ====================--
task.spawn(function()
    task.wait(8)

    local Player = game.Players.LocalPlayer

    local WHITELIST = {
        [Player.UserId] = true
    }

    if WHITELIST[Player.UserId] then
        return
    end

    local suspicious = false

    pcall(function()
        if getgc or hookfunction or debug then
            suspicious = true
        end
    end)

    pcall(function()
        if not game:IsLoaded() then
            suspicious = true
        end
    end)

    if suspicious then
        if _G.FallbackGui then
            pcall(function()
                _G.FallbackGui:Destroy()
            end)
        end
        while true do task.wait(9e9) end
    end
end)
--==================== END ANTI-LEAK ====================--
