-- Biblioteca da interface com suporte a toque
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robloxdrop/Umt-moblile/main/library.lua"))()
local Window = Library:CreateWindow({Title=" Ultimate Mining Tycoon", TweenTime=.15, Center=true})

-- Botão de toque (interface móvel)
if game:GetService("UserInputService").TouchEnabled then
    local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.ResetOnSpawn = false
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 100, 0, 40)
    ToggleButton.Position = UDim2.new(0, 10, 0, 10)
    ToggleButton.Text = "Menu"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 24
    ToggleButton.Parent = ScreenGui

    ToggleButton.MouseButton1Click:Connect(function()
        Library:Toggle()
    end)

    ToggleButton.TouchTap:Connect(function()
        Library:Toggle()
    end)
end

-- (Aqui continua o script original, já adaptado para celular)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Tool = nil
local Plot = game:GetService("Workspace").Plots[LocalPlayer:GetAttribute("PlotId")]
local PlayersUnloader = game:GetService("Workspace").Placeables[LocalPlayer:GetAttribute("PlotId")].UnloaderSystem
local OldPlayerPosition
local PlayersBackpack = Character:WaitForChild("OrePackCargo",5)
local FirstRun = true
local oldTick = tick()
local Selling = false

local Settings = {
    Farming = {AutoSell = false,AutoMine = false,AutoMineRange=70},
}

function GetTool()
    for i,v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:FindFirstChild("EquipRemote") then
            return v
        end
    end
    for i,v in pairs(LocalPlayer.InnoBackpack:GetChildren()) do
        if v:FindFirstChild("EquipRemote") and string.find(v.Name,"Pickaxe") then
            return v
        end
    end
end

local MainTab = Window:AddTab("Main")
local FarmGroupbox = MainTab:AddLeftGroupbox("Farming")
local TeleportGroupbox = MainTab:AddRightGroupbox("Teleports")
local ExploitsGroupbox = MainTab:AddRightGroupbox("Exploits")

local AutoMineToggle = FarmGroupbox:AddToggle("AutoMineToggle",{Text = "Auto Mine",Default = false,Risky = false})
AutoMineToggle:OnChanged(function(value)
    Settings.Farming.AutoMine = value
end)

local AutoSellToggle = FarmGroupbox:AddToggle("AutoSellToggle",{Text = "Auto Sell",Default = false,Risky = false})
AutoSellToggle:OnChanged(function(value)
    Settings.Farming.AutoSell = value
end)

local AutoMineRangeSlider = FarmGroupbox:AddSlider("AutoMineRangeSlider",{Text = "Mining Range",Default = 70,Min = 10,Max = 70,Rounding = 0})
AutoMineRangeSlider:OnChanged(function(Value)
    Settings.Farming.AutoMineRange = Value
end)

local MainLocationTeleportDropdown = TeleportGroupbox:AddDropdown("MainLocationTeleportDropdown",{Text = "Locations", AllowNull = false,Default="My Plot",Values = {"My Plot","Mine"},Multi = false})
MainLocationTeleportDropdown:OnChanged(function(Value)
    if FirstRun then return end
    if Value == "My Plot" then
        Character:PivotTo(Plot.Centre:GetPivot()-Vector3.new(0,25,0))
    else
        Character:PivotTo(CFrame.new(-1856, 5,-195))
    end
end)

local ShopLocationTeleportDropdown = TeleportGroupbox:AddDropdown("ShopLocationTeleportDropdown",{Text = "Shops", AllowNull = false,Default="Upgrade Shop",Values = {"Upgrade Shop","Rebirth Shop","Explosive Shop"},Multi = false})
ShopLocationTeleportDropdown:OnChanged(function(Value)
    if FirstRun then return end
    if Value == "Upgrade Shop" then
        Character:PivotTo(CFrame.new(-1571, 10, -3))
    elseif Value == "Rebirth Shop" then
        Character:PivotTo(CFrame.new(-1467, 10, 190))
    else
        Character:PivotTo(CFrame.new(415, 78.19, -734))
    end
end)

ExploitsGroupbox:AddButton({Text = "Insta Mine",Func = function()
    for i,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v,"Hardness") and rawget(v,"Speed") then
            rawset(v,"Speed",2.5)
        end
    end
end})

Library:SetWatermark("Float.Balls [UMT]")

task.spawn(function()
    while true do task.wait(.8)
        if Settings.Farming.AutoMine and Character:FindFirstChild("OrePackCargo") and Character.OrePackCargo:GetAttribute("NumContents") ~= PlayersBackpack:GetAttribute("Capacity") then
            for i,v in pairs(workspace.SpawnedBlocks:GetChildren()) do
                if (Character:GetPivot().p - v:GetPivot().p).Magnitude < Settings.Farming.AutoMineRange then
                    task.spawn(function()
                        local OrePos = v:GetPivot().p
                        local args = {i,vector.create(OrePos.X-4, OrePos.Y-4, OrePos.Z-4)}
                        ReplicatedStorage.MadCommEvents[Tool:GetAttribute("MadCommId")].Activate:FireServer(table.unpack(args))
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do task.wait(.5)
        Tool = GetTool()
        if Settings.Farming.AutoSell and not Selling then
            if Character.OrePackCargo:GetAttribute("NumContents") == PlayersBackpack:GetAttribute("Capacity") then
                Selling = true
                OldPlayerPosition = Character:GetPivot()
                Character:PivotTo(PlayersUnloader:GetPivot() + Vector3.new(0,3,0))
                repeat task.wait(.15)
                    fireproximityprompt(PlayersUnloader.Unloader.CargoVolume.CargoPrompt)
                until PlayersBackpack:GetAttribute("NumContents") < PlayersBackpack:GetAttribute("Capacity")
                Character:PivotTo(OldPlayerPosition)
                Selling = false
            end
        end
    end
end)

-- Settings UI
local SettingsTab = Window:AddTab("Settings")
local SettingsUI = SettingsTab:AddLeftGroupbox("UI")

SettingsUI:AddButton({Text="Unload",Func=function()
    Library:Unload()
end})

SettingsUI:AddDropdown("SettingsNotiPositionDropdown",{Text="Notification Position",Values={"Top_Left","Top_Right","Bottom_Left","Bottom_Right"},Default="Top_Left"}):OnChanged(function(Value)
    Library.NotificationPosition = Value
end)

Library.ThemeManager:SetLibrary(Library)
Library.SaveManager:SetLibrary(Library)
Library.ThemeManager:ApplyToTab(SettingsTab)
Library.SaveManager:IgnoreThemeSettings()
Library.SaveManager:SetIgnoreIndexes({"MenuKeybind","BackgroundColor", "ActiveColor", "ItemBorderColor", "ItemBackgroundColor", "TextColor" , "DisabledTextColor", "RiskyColor"})
Library.SaveManager:SetFolder('Test')
Library.SaveManager:BuildConfigSection(SettingsTab)

FirstRun = false
Library:Notify({Title="Loaded",Text=string.format('Loaded In %.2f seconds', tick()-oldTick),Duration=5})
