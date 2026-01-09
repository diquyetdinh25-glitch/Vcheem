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

local HttpService = game:GetService("HttpService")
local KeyFile = "CheemHub_Key.json"

local VALID_KEYS = {
    "8SSA18C72852AKXT1AS00GR",
    "5DSAH82736266AHFO655ASD",
    "2HFSD75AF74FSEGO755HDGH",
    "1SGDF44DGCF64FCSSHG75DF", 
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
    Box.PlaceholderText = "Key"
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
        game:GetService("ReplicatedStorage")
            .Remotes.Redeem:InvokeServer(code)
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

    -- HOP / MIRAGE
    AutoHop = false,
    HopMode = "None",
    AutoBlueGear = false

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
--================ FALLBACK ORION CLONE =================--
local FallbackLib = {}
FallbackLib.__index = FallbackLib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ===== SYNC CORE =====
local SyncEvents = {}

function RegisterSync(name, fn)
    SyncEvents[name] = SyncEvents[name] or {}
    table.insert(SyncEvents[name], fn)
end

function SyncUI(name, value)
    if SyncEvents[name] then
        for _,fn in ipairs(SyncEvents[name]) do
            pcall(fn, value)
        end
    end
end

-- ===== WINDOW =====
function FallbackLib:MakeWindow(cfg)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Fallback_Orion"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    _G.FallbackGui = gui

    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.fromOffset(520, 330)
    Main.Position = UDim2.new(0.5,-260,0.5,-165)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    _G.FallbackMain = Main

    -- Title
    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Name or "Cheem Hub"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255,221,0)

    -- Tabs
    local TabsBar = Instance.new("Frame", Main)
    TabsBar.Size = UDim2.new(0,130,1,-40)
    TabsBar.Position = UDim2.new(0,0,0,40)
    TabsBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Pages = Instance.new("Frame", Main)
    Pages.Size = UDim2.new(1,-130,1,-40)
    Pages.Position = UDim2.new(0,130,0,40)
    Pages.BackgroundTransparency = 1

    local UI = { Tabs={}, Pages={}, Current=nil }

    -- ===== TAB =====
    function UI:MakeTab(info)
        local Btn = Instance.new("TextButton", TabsBar)
        Btn.Size = UDim2.new(1,0,0,40)
        Btn.Text = info.Name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Btn.AutoButtonColor = false

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1,0,1,0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarImageTransparency = 1
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local pad = Instance.new("UIPadding", Page)
        pad.PaddingLeft = UDim.new(0,8)
        pad.PaddingRight = UDim.new(0,8)
        pad.PaddingTop = UDim.new(0,8)

        local list = Instance.new("UIListLayout", Page)
        list.Padding = UDim.new(0,8)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(UI.Pages) do p.Visible=false end
            for _,t in pairs(UI.Tabs) do
                t.BackgroundColor3 = Color3.fromRGB(30,30,30)
            end
            Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Page.Visible = true
            UI.Current = Page
        end)

        table.insert(UI.Tabs, Btn)
        table.insert(UI.Pages, Page)

        if not UI.Current then
            Btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Page.Visible = true
            UI.Current = Page
        end

        local TabAPI = {}

        -- ===== TOGGLE (SLIDE) =====
        function TabAPI:AddToggle(opt)
            local Holder = Instance.new("Frame", Page)
            Holder.Size = UDim2.new(1,0,0,40)
            Holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,8)

            local Label = Instance.new("TextLabel", Holder)
            Label.Size = UDim2.new(1,-70,1,0)
            Label.Position = UDim2.new(0,10,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = opt.Name
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.new(1,1,1)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame", Holder)
            Switch.Size = UDim2.fromOffset(46,22)
            Switch.Position = UDim2.new(1,-56,0.5,-11)
            Switch.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

            local Knob = Instance.new("Frame", Switch)
            Knob.Size = UDim2.fromOffset(18,18)
            Knob.Position = UDim2.new(0,2,0.5,-9)
            Knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

            local state = opt.Default or false

            local function refresh()
                TweenService:Create(Knob, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
                }):Play()

                TweenService:Create(Switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(255,221,0) or Color3.fromRGB(60,60,60)
                }):Play()
            end

            refresh()

            RegisterSync(opt.Name, function(v)
                state = v
                refresh()
            end)

            Holder.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    opt.Callback(state)
                    SyncUI(opt.Name, state)
                    refresh()
                end
            end)
        end

        -- ===== BUTTON =====
        function TabAPI:AddButton(opt)
            local Btn2 = Instance.new("TextButton", Page)
            Btn2.Size = UDim2.new(1,0,0,40)
            Btn2.Text = opt.Name
            Btn2.Font = Enum.Font.GothamBold
            Btn2.TextSize = 14
            Btn2.TextColor3 = Color3.new(1,1,1)
            Btn2.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Btn2.AutoButtonColor = false
            Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0,8)

            Btn2.MouseButton1Click:Connect(opt.Callback)
        end

        return TabAPI
    end

    return UI
end

return FallbackLib

---==================================================
-- CHEEM CUSTOM UI LIB (GREEN THEME)
-- Icon Toggle + Tabs + Slide Toggle
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

--================ ICON TOGGLE =================--
local UIVisible = true

local IconGui = Instance.new("ScreenGui", CoreGui)
IconGui.Name = "CheemIconGui"
IconGui.ResetOnSpawn = false

_G.FallbackMain = Gui

local Icon = Instance.new("ImageButton", IconGui)
Icon.Size = UDim2.fromOffset(55,55)
Icon.Position = UDim2.new(0,15,0.45,0)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://91311717625487"
Icon.ImageColor3 = Color3.fromRGB(0,255,120)

-- Drag icon
local dragging, dragStart, startPos
Icon.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = Icon.Position
	end
end)

Icon.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		Icon.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--================ MAIN UI =================--
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "CheemHubUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(560,340)
Main.Position = UDim2.new(0.5,-280,0.5,-170)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- Toggle icon click
Icon.MouseButton1Click:Connect(function()
	UIVisible = not UIVisible
	Gui.Enabled = UIVisible
end)

-- Drag window
local winDrag, winStart, winPos
Main.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		winDrag = true
		winStart = i.Position
		winPos = Main.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if winDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - winStart
		Main.Position = UDim2.new(
			winPos.X.Scale,
			winPos.X.Offset + delta.X,
			winPos.Y.Scale,
			winPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		winDrag = false
	end
end)

--================ TITLE =================--
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "🇻🇳Cheem Hub [Premium] {Beta} |Blox Fruit By Olios"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(0,255,120)

--================ TABS =================--
local TabsBar = Instance.new("Frame", Main)
TabsBar.Size = UDim2.new(0,150,1,-40)
TabsBar.Position = UDim2.new(0,0,0,40)
TabsBar.BackgroundColor3 = Color3.fromRGB(14,14,14)

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-150,1,-40)
Pages.Position = UDim2.new(0,150,0,40)
Pages.BackgroundTransparency = 1

local UI = {Tabs={}, Pages={}, Current=nil}

--================ TAB FUNCTION =================--
function UI:CreateTab(name)
	local TabBtn = Instance.new("TextButton", TabsBar)
	TabBtn.Size = UDim2.new(1,0,0,40)
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.TextSize = 14
	TabBtn.TextColor3 = Color3.new(1,1,1)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
	TabBtn.AutoButtonColor = false

	local Page = Instance.new("ScrollingFrame", Pages)
	Page.Size = UDim2.new(1,0,1,0)
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.ScrollBarImageTransparency = 1
	Page.Visible = false
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local pad = Instance.new("UIPadding", Page)
	pad.PaddingLeft = UDim.new(0,10)
	pad.PaddingTop = UDim.new(0,10)

	local list = Instance.new("UIListLayout", Page)
	list.Padding = UDim.new(0,10)

	TabBtn.MouseButton1Click:Connect(function()
		for _,p in pairs(UI.Pages) do p.Visible=false end
		for _,t in pairs(UI.Tabs) do
			t.BackgroundColor3 = Color3.fromRGB(25,25,25)
		end
		TabBtn.BackgroundColor3 = Color3.fromRGB(0,80,40)
		Page.Visible = true
		UI.Current = Page
	end)

	table.insert(UI.Tabs, TabBtn)
	table.insert(UI.Pages, Page)

	if not UI.Current then
		Page.Visible = true
		TabBtn.BackgroundColor3 = Color3.fromRGB(0,80,40)
		UI.Current = Page
	end

	local TabAPI = {}

	--========== TOGGLE SLIDE ==========
	function TabAPI:AddToggle(opt)
		local Holder = Instance.new("Frame", Page)
		Holder.Size = UDim2.new(1,0,0,40)
		Holder.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,8)

		local Text = Instance.new("TextLabel", Holder)
		Text.Size = UDim2.new(1,-70,1,0)
		Text.Position = UDim2.new(0,10,0,0)
		Text.BackgroundTransparency = 1
		Text.Text = opt.Name
		Text.Font = Enum.Font.Gotham
		Text.TextSize = 14
		Text.TextColor3 = Color3.new(1,1,1)
		Text.TextXAlignment = Enum.TextXAlignment.Left

		local Switch = Instance.new("Frame", Holder)
		Switch.Size = UDim2.fromOffset(46,22)
		Switch.Position = UDim2.new(1,-56,0.5,-11)
		Switch.BackgroundColor3 = Color3.fromRGB(60,60,60)
		Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

		local Knob = Instance.new("Frame", Switch)
		Knob.Size = UDim2.fromOffset(18,18)
		Knob.Position = UDim2.new(0,2,0.5,-9)
		Knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

		local state = opt.Default or false

		local function refresh()
			TweenService:Create(Knob, TweenInfo.new(0.2), {
				Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
			}):Play()
			TweenService:Create(Switch, TweenInfo.new(0.2), {
				BackgroundColor3 = state and Color3.fromRGB(0,255,120) or Color3.fromRGB(60,60,60)
			}):Play()
		end

		refresh()

		Holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				state = not state
				refresh()
				if opt.Callback then
					opt.Callback(state)
				end
			end
		end)
	end

	--========== BUTTON ==========
	function TabAPI:AddButton(opt)
		local Btn = Instance.new("TextButton", Page)
		Btn.Size = UDim2.new(1,0,0,40)
		Btn.Text = opt.Name
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 14
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.BackgroundColor3 = Color3.fromRGB(0,120,60)
		Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8)

		Btn.MouseButton1Click:Connect(opt.Callback)
	end

	return TabAPI
end

--================ DEMO =================--
local ShopTab = UI:CreateTab("Tab Shop")
local FarmTab = UI:CreateTab("Tab Farmming")
local V4Tab = UI:CreateTab({Name = "Auto V4 / Mirage"})
local MiscTab = UI:CreateTab("Setting")

FarmTab:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(v)
		print("AutoFarm:", v)
	end
})

FarmTab:AddToggle({
    Name = "Auto Equip Weapon",
    Default = Cheem.AutoWeapon,
    Callback = function(v)
        Cheem.AutoWeapon = v
    end
})

FarmTab:AddButton({
    Name = "Equip Melee",
    Callback = function()
        EquipWeapon("Melee")
    end
})

FarmTab:AddButton({
    Name = "Equip Sword",
    Callback = function()
        EquipWeapon("Sword")
    end
})
FarmTab:AddButton({
    Name = "Equip Gun",
    Callback = function()
        EquipWeapon("Gun")
    end
})

FarmTab:AddToggle({
	Name = "Auto Skill",
	Default = false,
	Callback = function(v)
		print("AutoSkill:", v)
	end
})

MiscTab:AddButton({
	Name = "Rejoin",
	Callback = function()
		Player:Kick("Rejoining...")
	end
})

V4Tab:AddToggle({
    Name = "🕹 Auto Pull Lever",
    Default = Cheem.SmartV4,
    Callback = function(v)
        Cheem.SmartV4 = v
        Cheem.AutoHop = v
        Cheem.AutoBlueGear = v
        Cheem.HopMode = v and "Mirage" or "None"

        if v then
            Notify("🧠 Auto pull lever started",3)
        else
            Notify("❌ Auto pull lever stopped",3)
        end
    end
})

-- ===== BUY STYLES =====
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

-- ===== REDEEM =====
ShopTab:AddButton({
    Name = "🎁 Redeem ALL Codes",
    Callback = function()
        for _,code in ipairs(GameCodes) do
            RedeemCode(code)
            task.wait(0.35)
        end
    end
}) 

print("✅ Cheem Custom UI Loaded")

ApplyTheme(CurrentTheme)

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
