-- RedzHub Adaptado para PC - Versión Standalone
-- Compatible con Xeno, Synapse X, KRNL, Fluxus, Codex, Delta

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Library simple (puedes usar Orion, Kavo, o Rayfield si las tienes)
-- Aquí uso una versión básica compatible con Xeno

local RedzHub = {
    Settings = {
        AutoFarm = false,
        AutoQuest = false,
        AutoStats = false,
        AutoBuso = false,
        SelectedMob = "Bandit",
        FastAttack = true,
        BringMob = true,
        AutoClick = true,
        AutoDodge = false,
        AutoKen = false,
        AutoFarmFruit = false,
        AutoFarmBoss = false,
        SelectedBoss = "",
        AutoRaid = false,
        AutoLaw = false,
        AutoSaber = false,
        AutoPole = false,
        AutoHakiColor = false,
        AutoBuyFruit = false,
        AutoStoreFruit = false,
        AutoDropFruit = false,
        AutoEquipSword = false,
        AutoEquipFruit = false,
        AutoEquipMelee = false,
        AutoSetSpawn = false,
        AntiAFK = true,
        WhiteScreen = false,
        FPSBoost = false
    }
}

-- Anti-AFK
if RedzHub.Settings.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

-- FPS Boost
if RedzHub.Settings.FPSBoost then
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
    end
end

-- White Screen
if RedzHub.Settings.WhiteScreen then
    RunService:Set3dRenderingEnabled(false)
end

-- Combat Framework (Para Fast Attack)
local CombatFramework = require(ReplicatedStorage:WaitForChild("CombatFramework"))
local CameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local CameraShakerR = getupvalues(CombatFrameworkR)[4]

-- Función Tween
function TweenTo(TargetCFrame, Speed)
    if not Speed then Speed = 300 end
    local Distance = (TargetCFrame.Position - HumanoidRootPart.Position).Magnitude
    local tweenInfo = TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = TargetCFrame})
    tween:Play()
    return tween
end

-- Auto Buso
function AutoBuso()
    while RedzHub.Settings.AutoBuso do
        wait(1)
        if not Character:FindFirstChild("HasBuso") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end
    end
end

-- Auto Ken
function AutoKen()
    while RedzHub.Settings.AutoKen do
        wait(2)
        if not Character:FindFirstChild("KenHaki") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Ken")
        end
    end
end

-- Auto Stats
function AutoStats()
    while RedzHub.Settings.AutoStats do
        wait(5)
        local Stats = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
        for _, stat in pairs(Stats) do
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, 1)
            wait(0.5)
        end
    end
end

-- Auto Quest Inteligente
function GetQuestLevel()
    local Level = Player.Data.Level.Value
    
    local Quests = {
        -- Starter Island
        {Min = 1, Max = 9, Quest = "BanditQuest1", Enemy = "Bandit", LevelReq = 1, CFrame = CFrame.new(1059.37, 16.3, 1548.43)},
        {Min = 10, Max = 14, Quest = "JungleQuest1", Enemy = "Monkey", LevelReq = 10, CFrame = CFrame.new(-1599.31, 36.9, 153.28)},
        {Min = 15, Max = 29, Quest = "JungleQuest2", Enemy = "Gorilla", LevelReq = 15, CFrame = CFrame.new(-1267.5, 11.8, -451.5)},
        -- Pirate Village
        {Min = 30, Max = 39, Quest = "BuggyQuest1", Enemy = "Pirate", LevelReq = 30, CFrame = CFrame.new(-1140.8, 5.2, 3828.1)},
        {Min = 40, Max = 59, Quest = "BuggyQuest2", Enemy = "Brute", LevelReq = 40, CFrame = CFrame.new(-1140.8, 5.2, 3828.1)},
        -- Desert
        {Min = 60, Max = 74, Quest = "DesertQuest1", Enemy = "Desert Bandit", LevelReq = 60, CFrame = CFrame.new(897.5, 6.5, 4388.5)},
        {Min = 75, Max = 89, Quest = "DesertQuest2", Enemy = "Desert Officer", LevelReq = 75, CFrame = CFrame.new(1608.6, 8.9, 4352.2)},
        -- Frozen Village
        {Min = 90, Max = 119, Quest = "SnowQuest1", Enemy = "Snowman", LevelReq = 90, CFrame = CFrame.new(1386.2, 88.5, -1298.5)},
        -- Marine Fortress
        {Min = 120, Max = 149, Quest = "MarineQuest1", Enemy = "Chief Petty Officer", LevelReq = 120, CFrame = CFrame.new(-4716.3, 88.6, 4313.7)},
        -- Sky Islands
        {Min = 150, Max = 199, Quest = "SkyQuest1", Enemy = "Sky Bandit", LevelReq = 150, CFrame = CFrame.new(-4981.5, 278.1, -2830.5)},
        -- Prison
        {Min = 190, Max = 249, Quest = "PrisonerQuest1", Enemy = "Prisoner", LevelReq = 190, CFrame = CFrame.new(4912.5, 5.9, 736.5)},
        -- Colosseum
        {Min = 225, Max = 299, Quest = "ColosseumQuest1", Enemy = "Gladiator", LevelReq = 225, CFrame = CFrame.new(-1428.6, 7.3, -3204.5)},
        -- Magma Village
        {Min = 300, Max = 374, Quest = "MagmaQuest1", Enemy = "Magma Ninja", LevelReq = 300, CFrame = CFrame.new(-5316.5, 12.2, 8517.1)},
        -- Underwater City
        {Min = 375, Max = 449, Quest = "FishmanQuest1", Enemy = "Fishman Warrior", LevelReq = 375, CFrame = CFrame.new(61122.6, 18.5, 1568.2)},
        -- Fountain City
        {Min = 450, Max = 624, Quest = "FountainQuest1", Enemy = "Galley Pirate", LevelReq = 450, CFrame = CFrame.new(5259.8, 38.5, 4050.4)},
        -- New World
        {Min = 700, Max = 724, Quest = "DressrosaQuest1", Enemy = "Swan Pirate", LevelReq = 700, CFrame = CFrame.new(834.9, 10.9, 1234.5)},
        {Min = 725, Max = 774, Quest = "DressrosaQuest2", Enemy = "Factory Staff", LevelReq = 725, CFrame = CFrame.new(-183.9, 10.9, 1234.5)},
        -- Añade más según necesites
    }
    
    for _, quest in pairs(Quests) do
        if Level >= quest.Min and Level <= quest.Max then
            return quest
        end
    end
    
    return nil
end

function AutoQuest()
    while RedzHub.Settings.AutoQuest do
        wait(2)
        local CurrentQuest = GetQuestLevel()
        if CurrentQuest then
            RedzHub.Settings.SelectedMob = CurrentQuest.Enemy
            
            -- Ir al NPC de quest
            TweenTo(CurrentQuest.CFrame)
            wait(0.5)
            
            -- Tomar quest
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", CurrentQuest.Quest, CurrentQuest.LevelReq)
        end
    end
end

-- Auto Equip
function AutoEquip()
    while RedzHub.Settings.AutoEquipMelee do
        wait(0.5)
        for _, v in pairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Melee") then
                Humanoid:EquipTool(v)
                break
            end
        end
    end
end

-- Fast Attack / Auto Click
function FastAttack()
    while RedzHub.Settings.FastAttack do
        wait()
        pcall(function()
            CameraShakerR:Stop()
            CombatFrameworkR.activeController.hitboxMagnitude = 55
            CombatFrameworkR.activeController.increment = 3
            CombatFrameworkR.activeController:attack()
        end)
    end
end

-- Bring Mob
function BringMob()
    while RedzHub.Settings.BringMob do
        wait(0.3)
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
               and v.Humanoid.Health > 0 
               and v.Name == RedzHub.Settings.SelectedMob then
                
                v.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                v.HumanoidRootPart.Transparency = 1
                v.Humanoid.JumpPower = 0
                v.Humanoid.WalkSpeed = 0
                v.Humanoid:ChangeState(11)
                v.HumanoidRootPart.CanCollide = false
                
                if v:FindFirstChild("Head") then
                    v.Head.CanCollide = false
                end
            end
        end
    end
end

-- Auto Farm Principal
function AutoFarm()
    while RedzHub.Settings.AutoFarm do
        wait()
        
        -- Verificar si tenemos quest
        local QuestTitle = Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
        
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
               and v.Humanoid.Health > 0 then
                
                local EnemyName = v.Name
                if EnemyName == RedzHub.Settings.SelectedMob then
                    
                    local EnemyHRP = v.HumanoidRootPart
                    local EnemyHumanoid = v.Humanoid
                    
                    -- Tween al enemigo
                    TweenTo(EnemyHRP.CFrame * CFrame.new(0, 30, 0))
                    
                    -- Equipar arma
                    if RedzHub.Settings.AutoEquipMelee then
                        for _, tool in pairs(Player.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool:FindFirstChild("Melee") then
                                Humanoid:EquipTool(tool)
                                break
                            end
                        end
                    end
                    
                    -- Atacar hasta que muera
                    repeat
                        wait(0.1)
                        if RedzHub.Settings.FastAttack then
                            pcall(function()
                                CameraShakerR:Stop()
                                CombatFrameworkR.activeController:attack()
                            end)
                        end
                    until EnemyHumanoid.Health <= 0 or not RedzHub.Settings.AutoFarm
                    
                    wait(0.5)
                end
            end
        end
    end
end

-- Auto Farm Fruit
function AutoFarmFruit()
    while RedzHub.Settings.AutoFarmFruit do
        wait(1)
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name, "Fruit") then
                TweenTo(v.Handle.CFrame)
                wait(1)
            end
        end
    end
end

-- Auto Raid
function AutoRaid()
    while RedzHub.Settings.AutoRaid do
        wait(1)
        -- Lógica para raids (requiere más implementación específica)
        if Workspace:FindFirstChild("RaidIsland") then
            for _, v in pairs(Workspace.RaidIsland:GetDescendants()) do
                if v:IsA("Humanoid") and v.Health > 0 then
                    TweenTo(v.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                end
            end
        end
    end
end

-- Auto Buy Fruit
function AutoBuyFruit()
    while RedzHub.Settings.AutoBuyFruit do
        wait(5)
        local Fruits = {"Bomb-Bomb", "Spike-Spike", "Chop-Chop", "Spring-Spring", 
                       "Smoke-Smoke", "Flame-Flame", "Ice-Ice", "Sand-Sand", 
                       "Dark-Dark", "Light-Light", "Magma-Magma", "Quake-Quake"}
        
        for _, fruit in pairs(Fruits) do
            ReplicatedStorage.Remotes.CommF_:InvokeServer("PurchaseRawFruit", fruit)
            wait(0.5)
        end
    end
end

-- Auto Store Fruit
function AutoStoreFruit()
    while RedzHub.Settings.AutoStoreFruit do
        wait(2)
        for _, v in pairs(Player.Backpack:GetChildren()) do
            if string.find(v.Name, "Fruit") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", v.Name)
            end
        end
    end
end

-- Auto Set Spawn
function AutoSetSpawn()
    while RedzHub.Settings.AutoSetSpawn do
        wait(10)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
    end
end

-- Funciones para activar/desactivar
function ToggleFeature(feature, enabled)
    RedzHub.Settings[feature] = enabled
    
    if enabled then
        if feature == "AutoFarm" then
            spawn(AutoFarm)
        elseif feature == "AutoQuest" then
            spawn(AutoQuest)
        elseif feature == "AutoStats" then
            spawn(AutoStats)
        elseif feature == "AutoBuso" then
            spawn(AutoBuso)
        elseif feature == "AutoKen" then
            spawn(AutoKen)
        elseif feature == "FastAttack" then
            spawn(FastAttack)
        elseif feature == "BringMob" then
            spawn(BringMob)
        elseif feature == "AutoEquipMelee" then
            spawn(AutoEquip)
        elseif feature == "AutoFarmFruit" then
            spawn(AutoFarmFruit)
        elseif feature == "AutoRaid" then
            spawn(AutoRaid)
        elseif feature == "AutoBuyFruit" then
            spawn(AutoBuyFruit)
        elseif feature == "AutoStoreFruit" then
            spawn(AutoStoreFruit)
        elseif feature == "AutoSetSpawn" then
            spawn(AutoSetSpawn)
        end
    end
end

-- GUI Básica (Puedes expandir con una librería como Orion)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedzHubPC"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Text = "RedzHub PC Edition"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Función para crear botones
function CreateButton(name, position, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 180, 0, 35)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.Parent = MainFrame
    
    local Enabled = false
    
    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Button.Text = name .. (Enabled and ": ON" or ": OFF")
        Button.BackgroundColor3 = Enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(50, 50, 50)
        callback(Enabled)
    end)
end

-- Crear botones
CreateButton("Auto Farm", UDim2.new(0, 10, 0, 50), function(enabled)
    ToggleFeature("AutoFarm", enabled)
    ToggleFeature("BringMob", enabled)
    ToggleFeature("FastAttack", enabled)
end)

CreateButton("Auto Quest", UDim2.new(0, 200, 0, 50), function(enabled)
    ToggleFeature("AutoQuest", enabled)
end)

CreateButton("Auto Stats", UDim2.new(0, 10, 0, 95), function(enabled)
    ToggleFeature("AutoStats", enabled)
end)

CreateButton("Auto Buso", UDim2.new(0, 200, 0, 95), function(enabled)
    ToggleFeature("AutoBuso", enabled)
end)

CreateButton("Auto Ken", UDim2.new(0, 10, 0, 140), function(enabled)
    ToggleFeature("AutoKen", enabled)
end)

CreateButton("Auto Farm Fruit", UDim2.new(0, 200, 0, 140), function(enabled)
    ToggleFeature("AutoFarmFruit", enabled)
end)

CreateButton("Auto Buy Fruit", UDim2.new(0, 10, 0, 185), function(enabled)
    ToggleFeature("AutoBuyFruit", enabled)
end)

CreateButton("Auto Store Fruit", UDim2.new(0, 200, 0, 185), function(enabled)
    ToggleFeature("AutoStoreFruit", enabled)
end)

CreateButton("Auto Set Spawn", UDim2.new(0, 10, 0, 230), function(enabled)
    ToggleFeature("AutoSetSpawn", enabled)
end)

CreateButton("FPS Boost", UDim2.new(0, 200, 0, 230), function(enabled)
    RedzHub.Settings.FPSBoost = enabled
    if enabled then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
end)

CreateButton("White Screen", UDim2.new(0, 10, 0, 275), function(enabled)
    RedzHub.Settings.WhiteScreen = enabled
    RunService:Set3dRenderingEnabled(not enabled)
end)

-- Botón para cerrar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Hacer draggable
local dragging
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("RedzHub PC Edition cargado correctamente")
print("Creado por Venice - Compatible con Xeno, Synapse X, KRNL, Fluxus")
