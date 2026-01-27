
-- ================= CHEEM HUB SAFE MODE =================
-- SAFE MODE + ERROR PANEL
-- (Auto-generated wrapper, logic inside is unchanged)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ===== SAFE RUN =====
    local function SafeRun(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        warn("[SafeRun]", name, err)
    end
    return ok
end

SafeRun("MAIN", function()


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
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
repeat task.wait() until Player
repeat task.wait() until Player.Character

local UIVisible = true
local GlobalUI = nil

--================ MIRAGE SERVER FILTER =================--
local Lighting = game:GetService("Lighting")
local ServerEnterTick = tick()
local MIRAGE_WAIT_LIMIT = 420 -- 7 phút
local QUICK_REJECT_TIME = 5   -- reject ≤ 5s

local function IsNight()
    local t = Lighting.ClockTime
    return (t >= 18 or t <= 5)
end

local function GetMoonPercent()
    -- Trăng Mirage dựa vào MoonPhase (0 → 1)
    if Lighting:FindFirstChild("MoonPhase") then
        return Lighting.MoonPhase.Value * 100
    end
    -- fallback (ước lượng)
    return 0
end

local function IsValidMirageServer()
    if not IsNight() then return false, "DAYTIME" end
    if GetMoonPercent() < 70 then return false, "LOW_MOON" end
    return true, "OK"
end

--================ JOBID BLACKLIST =================--
local HttpService = game:GetService("HttpService")
local JobId = game.JobId

_G.MirageBlackList = _G.MirageBlackList or {}

local function IsJobBlacklisted(id)
    return _G.MirageBlackList[id] == true
end

local function AddJobBlacklist(id, reason)
    _G.MirageBlackList[id] = true
    warn("[MIRAGE BLACKLIST]", id, reason)
end

-- ================= THEME =================
local Theme = {
    Dark = {
        Background = Color3.fromRGB(25,25,25),
        Section    = Color3.fromRGB(40,40,40),
        Accent     = Color3.fromRGB(255,221,0),
        Text       = Color3.fromRGB(255,255,255)
    },
    Light = {
        Background = Color3.fromRGB(235,235,235),
        Section    = Color3.fromRGB(210,210,210),
        Accent     = Color3.fromRGB(60,180,75),
        Text       = Color3.fromRGB(30,30,30)
    }
}

local CurrentTheme = "Dark"

local function ApplyTheme(themeName)
    local t = Theme[themeName]
    if not t then return end

    for _,v in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("Frame") then
            v.BackgroundColor3 = t.Background
        elseif v:IsA("TextButton") then
            v.BackgroundColor3 = t.Section
            v.TextColor3 = t.Text
        elseif v:IsA("TextLabel") then
            v.TextColor3 = t.Text
        end
    end
end

--===== KEY SYSTEM (SAVE KEY) =====--

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local KeyFile = "CheemHub_Key.json"

local function ResetKey()
    if isfile(KeyFile) then
        delfile(KeyFile)
    end
end

local VALID_KEYS = {
    "8SSA18C72852AKXT1AS00GR",
    "5DSAH82736266AHFO655ASD",
    "2HFSD75AF74FSEGO755HDGH",
    "1SGDF44DGCF64FCSSHG75DF", 
    "8X9FQK7A2MZP4LJ6DREWHTNVC", 
    "3A7M9QKDLX2F8PZJ5HENRVCW", 
    "6PZQ8M2R7F9A4XKLDHENJVC", 
    "1R7XQ9MZP8F2K4ADLJHENVC", 
    "9KZ8P7F2XQ4MRAHENLDJVC", 
    "4X2F9Q8MZ7RPKADLJHENVC", 
    "7Q9XK8P2FZM4RDAHENLJVC", 
    "2M9QKZ7P8F4XRADHENLJVC", 
    "5F8Q9X7P2KZM4RDAHENLJVC", 
    "0X9Q7K8F2PZM4RDAHENLJVC", 
}

-- ===== Check key =====
local function IsValidKey(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then
            return true
        end
    end
    return false
end

-- ===== Load saved key =====
local function LoadSavedKey()
    if isfile(KeyFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(KeyFile))
        end)

        if success and data and data.key then
            return data.key
        end
    end
    return nil
end

-- ===== Save key =====
local function SaveKey(key)
    writefile(KeyFile, HttpService:JSONEncode({
        key = key,
        time = os.time()
    }))
end

-- ================= AUTO LOGIN =================
local savedKey = LoadSavedKey()
local KeyPassed = false

if savedKey and IsValidKey(savedKey) then
    print("CheemHub: Auto login success")
    KeyPassed = true
end

if not KeyPassed then

-- ================= KEY UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheemHub_KeyUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromScale(0.35, 0.25)
Frame.Position = UDim2.fromScale(0.325, 0.35)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.fromScale(1,0.25)
Title.BackgroundTransparency = 1
Title.Text = "Cheem Hub | Key System"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local Box = Instance.new("TextBox", Frame)
Box.Size = UDim2.fromScale(0.9,0.25)
Box.Position = UDim2.fromScale(0.05,0.35)
Box.PlaceholderText = "Key Here"
Box.Text = ""
Box.TextScaled = true
Box.ClearTextOnFocus = false
Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
Box.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", Box).CornerRadius = UDim.new(0,6)

local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.fromScale(0.5,0.22)
Btn.Position = UDim2.fromScale(0.25,0.68)
Btn.Text = "Check Key"
Btn.TextScaled = true
Btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
Btn.TextColor3 = Color3.fromRGB(0,0,0)

Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

-- ===== Button logic =====
Btn.MouseButton1Click:Connect(function()
    local key = Box.Text

    if IsValidKey(key) then
        SaveKey(key)
        ScreenGui:Destroy()
        print("CheemHub: Key verified")
    else
        Box.Text = ""
        Btn.Text = "Wrong Key"
        Btn.BackgroundColor3 = Color3.fromRGB(255,80,80)
        task.wait(1)
        Btn.Text = "Check Key"
        Btn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    end

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

local attacking = false
local lastQuest = ""

Cheem.AutoClick = false
Cheem.FastAttack = false
Cheem.AutoTrial = false
Cheem.AutoFarmBones = false
Cheem.AutoV3 = false
Cheem.AutoV4 = false

Cheem.FarmMode = "Level" -- Level | Bones
Cheem.Weapon = "Melee"      -- vũ khí dùng khi Auto Farm
Cheem.TrialWeapon = "Melee" -- vũ khí dùng khi đánh Trial

-- ================= FUNCTION CHUNG =================

local function IsFarming()
    if Cheem.FarmMode == "Level" and Cheem.AutoFarm then
        return true
    end
    if Cheem.FarmMode == "Bones" and Cheem.AutoFarmBones then
        return true
    end
    return false
end
-- ===== AUTO V3 / V4 (DÁN Ở ĐÂY) =====
local function TryEnableV3()
    if not Cheem.AutoV3 then return end
    if not IsFarming() then return end

    pcall(function()
        local char = Player.Character
        if not char then return end

        -- đa số V3 có marker Aura / Ability
        if not char:FindFirstChild("RaceV3") then
            -- giả click skill (an toàn hơn fire remote)
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    end)
end

local function TryEnableV4()
    if not Cheem.AutoV4 then return end
    if not IsFarming() then return end

    pcall(function()
        local char = Player.Character
        if not char then return end

        -- đa số V4 có Transformation / Awakening
        if char:FindFirstChild("RaceEnergy") then
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    end)
end

--// ================= SEA DETECT =================
local function GetSea()
    if game.PlaceId == 2753915549 then
        return 1
    elseif game.PlaceId == 4442272183 then
        return 2
    elseif game.PlaceId == 7449423635 then
        return 3
    end
end

local CurrentSea = GetSea()

local function UpdateSea()
    CurrentSea = GetSea()
end

--========= LOOP UPDATE SEA ======--
task.spawn(function()
    while task.wait(2) do
        UpdateSea()
    end
end)

-- ===== LOOP CHECK MAP TRIAL ==============--
local function IsInTrial()
    local place = game.PlaceId
    -- Trial V4 map
    return place == 7449423635 or place == 4442272183
end

task.spawn(function()
    while task.wait(1) do
        Cheem.InTrial = IsInTrial()
    end
end) 

--================ MISSING FUNCTIONS FIX =================--

function EquipFarmWeapon()
    local char = Player.Character
    if not char then return end

    local weapon = Cheem.InTrial and Cheem.TrialWeapon or Cheem.Weapon
    if not weapon then return end

    for _,tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if weapon == "Melee" then
                char.Humanoid:EquipTool(tool)
                return
            end
            if weapon == "Sword" and tool.ToolTip:lower():find("sword") then
                char.Humanoid:EquipTool(tool)
                return
            end
            if weapon == "Gun" and tool.ToolTip:lower():find("gun") then
                char.Humanoid:EquipTool(tool)
                return
            end
        end
    end
end

function BuyStyle(style)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buy" .. style)
    end)
end

function HopServer()
    local servers = game:GetService("HttpService"):JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    )

    for _,s in pairs(servers.data) do
        if s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
            break
        end
    end
end

function SaveConfig()
    pcall(function()
        writefile("CheemHub_Config.json", HttpService:JSONEncode(Cheem))
    end) 
end

--================ END FIX =================--

-- ================= NOCLIP =================
game:GetService("RunService").Stepped:Connect(function()
    if Cheem.Noclip then
        local char = Player.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end

-- ================= FLY =================
local FlyBV, FlyBG

game:GetService("RunService").RenderStepped:Connect(function()
    if not Cheem.Fly then
        if FlyBV then FlyBV:Destroy() FlyBV=nil end
        if FlyBG then FlyBG:Destroy() FlyBG=nil end
        return
    end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not FlyBV then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = hrp

        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        FlyBG.CFrame = hrp.CFrame
        FlyBG.Parent = hrp
    end

    local cam = workspace.CurrentCamera
    FlyBG.CFrame = cam.CFrame
    FlyBV.Velocity = cam.CFrame.LookVector * 80

--===== LOOP =======--
UserInputService.JumpRequest:Connect(function()
    if Cheem.InfJump then
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

Cheem.InTrial = false

Cheem.WalkSpeed = 16
Cheem.JumpPower = 50
Cheem.InfJump = false

Cheem.BuyChip = false
Cheem.ChipFruit = "Flame"

-- ===== AWAKEN RAID =====
Cheem.AutoAwaken = false
Cheem.AwakenSkill = "Z"
Cheem.AutoRaid = false
Cheem.RaidTeleport = true

--================= RAID TELEPORT =================
local function TeleportToRaid()
    if not Cheem.RaidTeleport then return end

    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer(
            "RaidsNpc","Select","Flame"
        )
        ReplicatedStorage.Remotes.CommF_:InvokeServer(
            "RaidsNpc","Start"
        )
    end)
end

--==================== BUY CHIP =======================
local function BuyChip()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer(
            "RaidsNpc",
            "Select",
            Cheem.ChipFruit
        )
    end)
end

--================= AUTO AWAKEN LOOP =================
task.spawn(function()
    while task.wait(0.3) do
        if not Cheem.AutoAwaken then continue end

        pcall(function()
            TeleportToRaid()
            AttackRaidMob()
        end)
    end
end)

--================ LOOP BUY CHIP ================
task.spawn(function()
    while task.wait(5) do
        if Cheem.BuyChip then
            BuyChip()
        end
    end
end)

---================ ATTACK RAID MOB (FIXED) =================--
local attackingRaid = false

function AttackRaidMob()
    if attackingRaid then return end
    attackingRaid = true

    local char = Player.Character
    if not char then attackingRaid = false return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        attackingRaid = false
        return
    end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then
        attackingRaid = false
        return
    end

    for _, mob in pairs(enemies:GetChildren()) do
        if not Cheem.AutoTrial then break end

        if mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0 then

            local mhum = mob.Humanoid
            local mhrp = mob.HumanoidRootPart

            -- 🔒 Giữ mục tiêu cho đến khi chết
            while mhum.Health > 0 and Cheem.AutoTrial do
                pcall(function()
                    hrp.CFrame = mhrp.CFrame * CFrame.new(0, 10, 0)

                -- Equip đúng vũ khí Trial
                EquipFarmWeapon()

                -- Click đánh
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0,0))

                task.wait(0.1)
            end
        end
    end

    attackingRaid = false
end

--================ AUTO FIGHT TRIAL LOOP =================--
task.spawn(function()
    while task.wait(0.3) do
        if Cheem.AutoTrial and Cheem.InTrial then
            pcall(function()
                AttackRaidMob()
        end
    end

local GameCodes = {
    "SECRET_ADMIN",
    "SUB2GAMERROBOT_EXP1",
    "SUB2NOOBMASTER123",
    "SUB2UNCLEKIZARU",
    "SUB2DAIGROCK",
    "AXIORE",
    "BIGNEWS",
    "STRAWHATMAINE",
    "TANTAI_GAMING",
    "SUB2FER999",
    "THEGREATACE",
    "KITT_RESET",
    "SUB2GAMERROBOT_RESET1",
    "FUDD10",
    "FUDD10_V2",
    "CHANDLER",
    "ENYU_IS_PRO",
    "STARCODEHEO",
    "BLUXXY",
    "JCWK",
    "MAGICBUS",
}

local RedeemedCodes = {}

local function RedeemCode(code)
    if RedeemedCodes[code] then return end

    local success = pcall(function()
    ReplicatedStorage.Remotes.Redeem:InvokeServer(code)
end)

if success then
        RedeemedCodes[code] = true
        Notify("✅ Redeem: "..code, 2)
    else
        Notify("❌ Fail: "..code, 2)
    end
end

Cheem.SmartV4 = Cheem.SmartV4 or false
Cheem.AutoHop = Cheem.AutoHop or false
Cheem.AutoBlueGear = Cheem.AutoBlueGear or false
Cheem.HopMode = Cheem.HopMode or "None"

local DefaultConfig = {
    AutoFarm = false,
    Weapon = "Melee",
    Teleport = true,
    AutoEquip = true,

    AutoHop = false,
    HopMode = "None",
    AutoBlueGear = false
}

--====================== ANTI AFK ======================--
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

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

--====================== FARM BONES LOOP (CONFIG MODE) ======================--

local BonesMobs = {
    "Reborn Skeleton",
    "Living Zombie",
    "Demonic Soul",
    "Posessed Mummy"
}

-- Haunted Castle (Sea 3)
local BonesFarmCF = CFrame.new(-9515, 142, 5535)

local function IsBonesMob(name)
    for _,v in ipairs(BonesMobs) do
        if name == v then return true end
    end
    return false
end

task.spawn(function()
    while task.wait(0.25) do
           TryEnableV3()
           TryEnableV4()
        
        -- ❌ KHÔNG đúng mode → bỏ
        if Cheem.FarmMode ~= "Bones" then continue end
        if not Cheem.AutoFarmBones then continue end
        if game.PlaceId ~= 7449423635 then continue end -- chỉ Sea 3

        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        -- Auto TP Haunted Castle
        if (hrp.Position - BonesFarmCF.Position).Magnitude > 1200 then
    TP(BonesFarmCF)
    task.wait(0.5)
end

        local enemies = workspace:FindFirstChild("Enemies")
        if not enemies then continue end

        for _,mob in pairs(enemies:GetChildren()) do
            if not Cheem.AutoFarmBones then break end
            if Cheem.FarmMode ~= "Bones" then break end

            if mob:FindFirstChild("Humanoid")
            and mob:FindFirstChild("HumanoidRootPart")
            and mob.Humanoid.Health > 0
            and IsBonesMob(mob.Name) then

                attacking = true
                EquipFarmWeapon()

                -- Mob Magnet
                if Cheem.MobMagnet then
                    pcall(function()
                        mob.HumanoidRootPart.CFrame =
                            hrp.CFrame * CFrame.new(math.random(-3,3),0,math.random(-3,3))
                    end)
                end

                hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)

                if Cheem.FastAttack then
                    for i = 1,5 do
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.01)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                    end
                else
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end

                attacking = false
            end
        end
    end
end)

--==================== END FARM BONES ====================--

-- ======== HÀM TỰ TP FARM BONES =======
local function TPToBones()
    if game.PlaceId ~= 7449423635 then return end -- chỉ Sea 3
    TP(BonesFarmCF)
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

---=============== FALLBACK ORION UI =================--
local function LoadFallbackUI()
    warn("[FALLBACK UI ACTIVE]", err)

    local OrionLib
    local ok = pcall(function()
        OrionLib = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/shlexware/Orion/main/source"
        ))()
    end)

    if not ok or not OrionLib then
        warn("Failed to load OrionLib")
        return
    end

    local Window = OrionLib:MakeWindow({
        Name = "Cheem Hub | Fallback Mode",
        HidePremium = false,
        SaveConfig = false,
        IntroEnabled = false
    })

    local Tab = Window:MakeTab({
        Name = "Emergency",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    Tab:AddParagraph(
    "SYSTEM NOTICE",
    "Hệ thống UI đang được chuyển sang chế độ an toàn.\nMột số hiệu ứng có thể bị giới hạn."
)

    -- ===== Toggle cơ bản giữ chức năng =====
    Tab:AddToggle({
        Name = "Auto Farm",
        Default = Cheem and Cheem.AutoFarm or false,
        Callback = function(v)
            Cheem.AutoFarm = v
        end
    })

    Tab:AddToggle({
        Name = "Fast Attack",
        Default = Cheem and Cheem.FastAttack or false,
        Callback = function(v)
            Cheem.FastAttack = v
        end
    })

    Tab:AddToggle({
        Name = "Auto Click",
        Default = Cheem and Cheem.AutoClick or false,
        Callback = function(v)
            Cheem.AutoClick = v
        end
    })

    -- ===== EXPOSE TOGGLE CHO ICON =====
    _G.FallbackToggle = function()
        OrionLib:ToggleUI()
    end
end
--====================================================

-- ====================================================
--CHEEM HUB UI LOADER 99.9% (NO EARLY FALLBACK)
--====================================================

repeat task.wait() until game:IsLoaded()
task.wait(0.6)

local CoreGui = game:GetService("CoreGui")

local function CoreGuiReady()
    local ok = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "__test"
        g.Parent = CoreGui
        g:Destroy()
    end)
    return ok
end

repeat task.wait(0.25) until CoreGuiReady()

-- destroy old safely
pcall(function()
    local old = CoreGui:FindFirstChild("Cheem_UI")
    if old then old:Destroy() end
    local oldIcon = CoreGui:FindFirstChild("Cheem_Icon")
    if oldIcon then oldIcon:Destroy() end
end)

_G.UI_REAL_BROKEN = false

local function LoadMainUI()
--====================================================
-- CHEEM CLEAN UI LIBRARY (DARK THEME)
-- 1 Icon – 1 UI | Slide Toggle | Tabs
-- NO ORION | NO SERVICE | NO LOGIC
--====================================================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.__index = UI

--================ ICON TOGGLE =================--
local UIVisible = true

pcall(function()
    local cg = game:GetService("CoreGui")
    local old = cg:FindFirstChild("Cheem_Icon")
    if old then old:Destroy() end
end)

local IconGui = Instance.new("ScreenGui")
IconGui.Name = "Cheem_Icon"
IconGui.ResetOnSpawn = false
IconGui.Parent = CoreGui

local Icon = Instance.new("ImageButton")
Icon.Parent = IconGui
Icon.Size = UDim2.fromOffset(50,50)
Icon.Position = UDim2.new(0,15,0.45,0)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://91311717625487"
Icon.ImageColor3 = Color3.fromRGB(255,221,0)

-- drag icon
local drag, dStart, dPos
Icon.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dStart = i.Position
		dPos = Icon.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dStart
		Icon.Position = UDim2.new(
			dPos.X.Scale, dPos.X.Offset + d.X,
			dPos.Y.Scale, dPos.Y.Offset + d.Y
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = false
	end
end)

--================ MAIN UI =================--
function UI:CreateWindow(title)
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "Cheem_UI"
	Gui.ResetOnSpawn = false
	Gui.Parent = CoreGui

    _G.MainGui = Gui

	-- ICON CLICK (CHỈ GẮN 1 LẦN)
if not Icon._Binded then
    Icon._Binded = true
    Icon.MouseButton1Click:Connect(function()
        if _G.UI_REAL_BROKEN and _G.FallbackToggle then
            _G.FallbackToggle()
        else
            UIVisible = not UIVisible
            if _G.MainGui then
                _G.MainGui.Enabled = UIVisible
            end
        end
    end)
end

	local Main = Instance.new("Frame", Gui)
	Main.Size = UDim2.fromOffset(560,340)
	Main.Position = UDim2.new(0.5,-280,0.5,-170)
	Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

	-- drag window
	local wDrag, wStart, wPos
	Main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			wDrag = true
			wStart = i.Position
			wPos = Main.Position
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if wDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - wStart
			Main.Position = UDim2.new(
				wPos.X.Scale, wPos.X.Offset + d.X,
				wPos.Y.Scale, wPos.Y.Offset + d.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			wDrag = false
		end
	end)

	-- title
	local Title = Instance.new("TextLabel", Main)
	Title.Size = UDim2.new(1,0,0,40)
	Title.BackgroundTransparency = 1
	Title.Text = title or "Cheem Hub [Premium] by Olios"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = Color3.fromRGB(255,221,0)

	-- tabs
	local Tabs = Instance.new("Frame", Main)
	Tabs.Size = UDim2.new(0,140,1,-40)
	Tabs.Position = UDim2.new(0,0,0,40)
	Tabs.BackgroundColor3 = Color3.fromRGB(15,15,15)

	local Pages = Instance.new("Frame", Main)
	Pages.Size = UDim2.new(1,-140,1,-40)
	Pages.Position = UDim2.new(0,140,0,40)
	Pages.BackgroundTransparency = 1

	local Window = {Tabs={}, Pages={}, Current=nil}

	--================ TAB =================--
	function Window:CreateTab(name)
		local Btn = Instance.new("TextButton", Tabs)
		Btn.Size = UDim2.new(1,0,0,40)
		Btn.Text = name
		Btn.Font = Enum.Font.Gotham
		Btn.TextSize = 14
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Btn.AutoButtonColor = false

		local Page = Instance.new("ScrollingFrame", Pages)
		Page.Size = UDim2.new(1,0,1,0)
		Page.ScrollBarImageTransparency = 1
		Page.Visible = false
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local list = Instance.new("UIListLayout", Page)
		list.Padding = UDim.new(0,10)

		Btn.MouseButton1Click:Connect(function()
    for _,p in pairs(Window.Pages) do p.Visible=false end
    for _,t in pairs(Window.Tabs) do t.BackgroundColor3=Color3.fromRGB(30,30,30) end
    Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Page.Visible = true
    Window.Current = Page
end)

        table.insert(Window.Tabs, Btn)
        table.insert(Window.Pages, Page)

		if not Window.Current then
			Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
			Page.Visible = true
			Window.Current = Page
		end

		local Tab = {}

		--=========== SLIDE TOGGLE ===========
		function Tab:AddSlider(opt)
    local H = Instance.new("Frame", Page)
    H.Size = UDim2.new(1,-10,0,50)
    H.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", H).CornerRadius = UDim.new(0,8)

    local L = Instance.new("TextLabel", H)
    L.Size = UDim2.new(1,-20,0,20)
    L.Position = UDim2.new(0,10,0,0)
    L.BackgroundTransparency = 1
    L.Text = opt.Name.." : "..tostring(opt.Default or opt.Min)
    L.Font = Enum.Font.Gotham
    L.TextSize = 14
    L.TextColor3 = Color3.new(1,1,1)
    L.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", H)
    Bar.Size = UDim2.new(1,-20,0,8)
    Bar.Position = UDim2.new(0,10,0,30)
    Bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame", Bar)
    Fill.BackgroundColor3 = Color3.fromRGB(255,221,0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    local min = opt.Min or 0
    local max = opt.Max or 100
    local value = opt.Default or min

    local function setVal(v)
        value = math.clamp(v, min, max)
        local pct = (value - min) / (max - min)
        Fill.Size = UDim2.new(pct,0,1,0)
        L.Text = opt.Name.." : "..math.floor(value)
        if opt.Callback then
            opt.Callback(value)
        end
    end

    setVal(value)

    local dragging = false

    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    Bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp(
                (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                0, 1
            )
            setVal(min + (max - min) * pct)
        end
    end)
end

		--=========== BUTTON ===========
		function Tab:AddButton(opt)
			local B = Instance.new("TextButton", Page)
			B.Size = UDim2.new(1,-10,0,40)
			B.Text = opt.Name
			B.Font = Enum.Font.GothamBold
			B.TextSize = 14
			B.TextColor3 = Color3.new(1,1,1)
			B.BackgroundColor3 = Color3.fromRGB(255,221,0)
			B.AutoButtonColor = false
			Instance.new("UICorner", B).CornerRadius = UDim.new(0,8)
			B.MouseButton1Click:Connect(opt.Callback)
		end
--========== DROPDOWN ==========
       function Tab:AddDropdown(opt)
    local H = Instance.new("Frame", Page)
    H.Size = UDim2.new(1,-10,0,40)
    H.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", H).CornerRadius = UDim.new(0,8)

    local Btn = Instance.new("TextButton", H)
    Btn.Size = UDim2.new(1,-20,1,0)
    Btn.Position = UDim2.new(0,10,0,0)
    Btn.Text = opt.Name..": "..opt.Default
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.BackgroundTransparency = 1

    local open = false
    local current = opt.Default

    Btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            for _,v in pairs(opt.Options) do
                local b = Instance.new("TextButton", Page)
                b:SetAttribute("DropdownItem", true)
                b.Size = UDim2.new(1,-10,0,35)
                b.Text = v
                b.BackgroundColor3 = Color3.fromRGB(45,45,45)
                b.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

                b.MouseButton1Click:Connect(function()
                    current = v
                    Btn.Text = opt.Name..": "..v
                    if opt.Callback then opt.Callback(v) end
                    for _,x in pairs(Page:GetChildren()) do
                        if x:GetAttribute("DropdownItem") then x:Destroy() 
                    end
                end
                    open = false
            end
        end
end

		return Tab
	end

	return Window
end

--================ SAFE RETRY =================--
local Window
local loaded = false

for i = 1,5 do
    local ok = pcall(function()
        Window = LoadMainUI()
    end)
    if ok and Window then
        loaded = true
        break
    end
    task.wait(0.3)
end

if not loaded then
    _G.UI_REAL_BROKEN = true
    if LoadFallbackUI then
        LoadFallbackUI()
    end
end

local ShopTab = Window:CreateTab("Tab Shop")
local PlayerTab = Window:CreateTab("Tab Player")
local SettingTab = Window:CreateTab("Setting Farm")
local FarmTab = Window:CreateTab("Farmer")
local AwakenTab = Window:CreateTab("Awaken Fruit")
local V4Tab  = Window:CreateTab("upgrade V4")
local setTab = Window:CreateTab("Setting Hub") 

setTab:AddButton({
    Name = "Reset Saved Key",
    Callback = function()
        ResetKey()
        game.Players.LocalPlayer:Kick("Key reset! Rejoin game.")
    end
})

SettingTab:AddToggle({
    Name = "Auto on V3",
    Default = false,
    Callback = function(v)
        Cheem.AutoV3 = v
    end
})

SettingTab:AddToggle({
    Name = "Auto on V4",
    Default = false,
    Callback = function(v)
        Cheem.AutoV4 = v
    end
})

SettingTab:AddToggle({
    Name = "Auto Click",
    Default = Cheem.AutoClick,
    Callback = function(v)
        Cheem.AutoClick = v
    end
})

SettingTab:AddToggle({
    Name = "Fast Attack",
    Default = Cheem.FastAttack,
    Callback = function(v)
        Cheem.FastAttack = v
    end
})

PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        Cheem.Fly = v
    end
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        Cheem.Noclip = v
    end
})

PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        Cheem.WalkSpeed = v
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v
        end
    end
})

PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        Cheem.JumpPower = v
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = v
        end
    end
})

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        Cheem.InfJump = v
    end
})

AwakenTab:AddToggle({
    Name = "Auto Buy Raid Chip",
    Default = false,
    Callback = function(v)
        Cheem.BuyChip = v
    end
})

AwakenTab:AddDropdown({
    Name = "Select Chip",
    Options = {"Flame","Ice","Light","Magma","Dark","Rumble","Buddha","Dough"},
    Default = "Flame",
    Callback = function(v)
        Cheem.ChipFruit = v
    end
})

AwakenTab:AddToggle({
    Name = "Auto Awaken (Raid)",
    Default = false,
    Callback = function(v)
        Cheem.AutoAwaken = v
        Cheem.AutoRaid = v
    end
})

AwakenTab:AddDropdown({
    Name = "Select Awaken Skill",
    Options = {"Z","X","C","V","F"},
    Default = "Z",
    Callback = function(v)
        Cheem.AwakenSkill = v
    end
})

AwakenTab:AddToggle({
    Name = "Auto Teleport Raid",
    Default = true,
    Callback = function(v)
        Cheem.RaidTeleport = v
    end
})

FarmTab:AddDropdown({
    Name = "Farm Mode",
    Default = Cheem.FarmMode,
    Options = {"Level", "Bones"},
    Callback = function(v)
        Cheem.FarmMode = v

        -- tắt hết khi đổi mode
        Cheem.AutoFarm = false
        Cheem.AutoFarmBones = false
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = Cheem.AutoFarm=,
    Callback = function(v)
        if Cheem.FarmMode ~= "Level" then
            Notify("Hãy chọn Farm Mode = Level", 2)
            return
        end
        Cheem.AutoFarm = v
        if v then
            Cheem.AutoFarmBones = false
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Bones (Sea 3)",
    Default = Cheem.AutoFarmBones,
    Callback = function(v)
        if GetSea() ~= 3 then
            Notify("Chỉ dùng Farm Bones ở Sea 3", 3)
            return
        end
        Cheem.AutoFarmBones = v
        if v then
            Cheem.AutoFarm = false
        end
    end
})

SettingTab:AddDropdown({
	Name = "Farm Weapon",
	Options = {"Melee", "Sword", "Gun"},
	Default = Cheem.Weapon or "Melee",
	Callback = function(v)
		Cheem.Weapon = v
	end
})

Cheem.MobMagnet = false

SettingTab:AddToggle({
    Name = "collect monsters",
    Default = Cheem.MobMagnet,
    Callback = function(v)
        Cheem.MobMagnet = v
    end
})

V4Tab:AddDropdown({
    Name = "Trial Weapon",
    Options = {"Melee","Sword","Gun"},
    Default = "Melee",
    Callback = function(v)
        Cheem.TrialWeapon = v
    end
})

V4Tab:AddToggle({
    Name = "Auto Fight Trial",
    Default = false,
    Callback = function(v)
        Cheem.AutoTrial = v
    end
})

V4Tab:AddToggle({
	Name = "Hop Mirage Island",
	Default = Cheem.AutoHop,
	Callback = function(v)
		Cheem.AutoHop = v
	end
})

V4Tab:AddToggle({
	Name = "Find Blue Gear",
	Default = Cheem.AutoBlueGear,
	Callback = function(v)
		Cheem.AutoBlueGear = v
	end
})

ShopTab:AddButton({
	Name = "Buy Black Leg",
	Callback = function()
		BuyStyle("BlackLeg")
	end
})

ShopTab:AddButton({
	Name = "Buy Electro",
	Callback = function()
		BuyStyle("Electro")
	end
})

ShopTab:AddButton({
	Name = "Buy Fishman Karate",
	Callback = function()
		BuyStyle("FishmanKarate")
	end
})

ShopTab:AddButton({
	Name = "Buy Dragon Claw",
	Callback = function()
		BuyStyle("DragonClaw")
	end
})

ShopTab:AddButton({
	Name = "Redeem ALL Codes",
	Callback = function()
		for _,code in ipairs(GameCodes) do
			RedeemCode(code)
			task.wait(0.3)
		end
	end
})

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
            return
        end
    end
end)

--================ AUTO HOP MIRAGE (SMART) =================--
task.spawn(function()
    while task.wait(2) do
        if not Cheem.AutoHop then continue end
        if Cheem.HopMode ~= "Mirage" then continue end

         -- reject server đã blacklist
              if IsJobBlacklisted(JobId) then
                   Notify("⛔ Blacklisted Server → Hop", 2)
                 HopServer()
              task.wait(1) 
           continue
        end

        ServerEnterTick = tick() -- ✅ thêm dòng này
        local valid, reason = IsValidMirageServer()

        -- ===== BƯỚC 1: REJECT NHANH =====
        if not valid then
            if tick() - ServerEnterTick <= QUICK_REJECT_TIME then
                Notify("❌ Reject Server: "..reason.." → Hop", 2)
                HopServer()
                task.wait(1)
                 continue
            end
            continue
        end

        -- ===== BƯỚC 2: SERVER HỢP LỆ =====
         local NotifiedValid = false
         if not NotifiedValid then
    Notify("✅ Valid Mirage Server | Moon "..math.floor(GetMoonPercent()).."%", 3)
    NotifiedValid = true
end
        -- ===== BƯỚC 3: CHỜ MIRAGE SPAWN =====
        if IsMirageIslandPresent() then
            Notify("🏝️ MIRAGE ISLAND FOUND !!!", 6)
            Cheem.AutoHop = false
            SaveConfig()
            return
        end

        -- quá thời gian → bỏ
        if tick() - ServerEnterTick > MIRAGE_WAIT_LIMIT then
             AddJobBlacklist(JobId, "MIRAGE_TIMEOUT")
                 Notify("⌛ Timeout Mirage → Hop New Server", 3)
                 HopServer()
                 task.wait(1) 
                 continue --✅
        end
    end
end)

--================ MOB MAGNET =================--
local function PullMobs(radius)
    local char = Player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _,mob in pairs(enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart")
        and mob:FindFirstChild("Humanoid")
        and mob.Humanoid.Health > 0 then

            local mhrp = mob.HumanoidRootPart
            if (mhrp.Position - hrp.Position).Magnitude <= radius then
                pcall(function()
                    mhrp.CFrame = hrp.CFrame * CFrame.new(
                        math.random(-3,3),
                        0,
                        math.random(-3,3)
                    )
            end
        end
    end
end

---===== QUEST CHECK =====
local function IsDoingQuest()
    local gui = Player.PlayerGui:FindFirstChild("Main")
    if not gui then return false end

    local quest = gui:FindFirstChild("Quest")
    return quest and quest.Visible
end

--====================== AUTO FARM LOOP (FIXED) ======================--
task.spawn(function()
    while task.wait(0.25) do
        TryEnableV3()
        TryEnableV4()
        
        if not Cheem.AutoFarm or attacking then
            task.wait(0.4)
            continue
        end

        -- MOB MAGNET
        if Cheem.MobMagnet then
            PullMobs(40)
        end

        local success, err = pcall(function()
            local char = Player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            local data = Player:FindFirstChild("Data")
            if not data then return end

            local level = data:FindFirstChild("Level")
            if not level then return end

            local q = GetQuest(level.Value)
            if not q then return end

            --===== START QUEST (FIXED) =====
            if not IsDoingQuest() or lastQuest ~= q.QuestName then
                lastQuest = q.QuestName
                TP(q.IslandPos)
                task.wait(0.4)

                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(
                        "StartQuest",
                        q.QuestName,
                        q.QuestLevel
                    )

                task.wait(0.5)
            end

            --===== FIND & ATTACK MOBS =====
            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return end

            for _, mob in pairs(enemies:GetChildren()) do
                if not Cheem.AutoFarm then break end

                if mob.Name == q.MobName
                and mob:FindFirstChild("Humanoid")
                and mob:FindFirstChild("HumanoidRootPart")
                and mob.Humanoid.Health > 0 then

                    attacking = true
                    EquipFarmWeapon()

                    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)

                    if Cheem.FastAttack then
                        for i = 1, 5 do
                            VirtualUser:Button1Down(Vector2.new(0,0))
                            task.wait(0.01)
                            VirtualUser:Button1Up(Vector2.new(0,0))
                        end
                    else
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                    end

                    attacking = false
                end
            end

        if not success then
            warn("[AutoFarm Error]:", err)
            attacking = false
            task.wait(1)
        end
    end

--========== AUTO CLICK LOOP =========
task.spawn(function()
    while task.wait(0.05) do
        if not Cheem.AutoClick then continue end

        pcall(function()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
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

--==================== END ANTI-LEAK ====================--


-- ================= END SAFE MODE =================

end)
if not ok then warn("CHEEM HUB CRASH:", err) end

end)

if not SAFE_OK then
    warn("[CheemHub SAFE MODE]", SAFE_ERR)
    -- fallback minimal gui
    local sg = Instance.new("ScreenGui")
    sg.Name = "CheemHub_Fallback"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.fromScale(0.15,0.08)
    btn.Position = UDim2.fromScale(0.02,0.4)
    btn.Text = "CheemHub"
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)
end
-- SAFE WRAPPER END

end)

if not success then
    LoadFallbackUI()
end
