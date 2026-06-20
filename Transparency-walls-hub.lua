-- [[ KIRIK LUXURY HUB — ULTRA CLEAN FIXED ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer.PlayerGui

-- Защита от дубликатов
if _G.KirikHubInstance then
    _G.KirikHubInstance:Destroy()
end

-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryLabyrinth_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui
_G.KirikHubInstance = ScreenGui

-- Главный фрейм (Меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- #050505
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Обводка (Золотисто-оранжевый градиент)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 0))
}
UIGradient.Parent = UIStroke

-- Заголовок хаба
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK LUXURY HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSans -- Фикс ошибки
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка закрытия (Крестик)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.Font = Enum.Font.SourceSans -- Фикс ошибки
CloseButton.TextSize = 20
CloseButton.Parent = MainFrame

-- Главная кнопка мода (On/Off)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 240, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -120, 0.5, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleButton.Text = "WALLS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 85, 0)
ToggleButton.Font = Enum.Font.SourceSans -- Фикс ошибки
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1
ButtonStroke.Color = Color3.fromRGB(60, 60, 60)
ButtonStroke.Parent = ToggleButton

-- [[ БЕЗОПАСНЫЙ ДРАГ-СКРИПТ ДЛЯ СЕНСОРНЫХ ЭКРАНОВ ]] --
local dragToggle = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [[ ЛОГИКА ПРОЗРАЧНОСТИ СТЕН ]] --
local wallsEnabled = false
local originalStates = {}

local function isFloorOrPlayer(obj)
    local name = obj.Name:lower()
    if name:find("baseplate") or name:find("floor") or name:find("ground") or name:find("spawn") then
        return true
    end
    if obj:FindFirstAncestorOfClass("Model") and obj:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then
        return true
    end
    return false
end

local function ModifyWall(obj)
    if obj:IsA("BasePart") and not obj:IsA("Terrain") and not isFloorOrPlayer(obj) then
        if not originalStates[obj] then
            originalStates[obj] = {
                Transparency = obj.Transparency,
                CanCollide = obj.CanCollide
            }
        end
        
        if wallsEnabled then
            obj.Transparency = 0.7
            obj.CanCollide = false
        else
            local state = originalStates[obj]
            if state then
                obj.Transparency = state.Transparency
                obj.CanCollide = state.CanCollide
            end
        end
    end
end

local function ToggleWalls()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        ModifyWall(obj)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    wallsEnabled = not wallsEnabled
    
    if wallsEnabled then
        ToggleButton.Text = "WALLS: ON"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(85, 255, 85)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(85, 255, 85)}):Play()
    else
        ToggleButton.Text = "WALLS: OFF"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 0)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 60)}):Play()
    end
    ToggleWalls()
end)

local connection = Workspace.DescendantAdded:Connect(function(descendant)
    if wallsEnabled then
        task.wait(0.2)
        ModifyWall(descendant)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    if connection then connection:Disconnect() end
    wallsEnabled = false
    
    for obj, state in pairs(originalStates) do
        if obj and obj.Parent then
            obj.Transparency = state.Transparency
            obj.CanCollide = state.CanCollide
        end
    end
    
    _G.KirikHubInstance = nil
    ScreenGui:Destroy()
end)
