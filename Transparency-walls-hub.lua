-- [[ KIRIK LUXURY HUB — FULL EDITION FOR DELTA ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создаем ScreenGui прямо в PlayerGui (чтобы не было черного экрана на Android)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryLabyrinth_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главный фрейм (Меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromHex("#050505")
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скругление углов меню
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Обводка с золотым градиентом
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local GradientStroke = Instance.new("UIGradient")
GradientStroke.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 0))
}
GradientStroke.Parent = UIStroke

-- Стильный заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK LUXURY HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Inter
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка закрытия (Крестик)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.Font = Enum.Font.Inter
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

-- Подсветка крестика при наведении/нажатии
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 85)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
end)

-- Основная кнопка Тоннеля / Прозрачности стен
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 240, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -120, 0.5, -5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Text = "WALLS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 85, 0)
ToggleButton.Font = Enum.Font.Inter
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1
ButtonStroke.Color = Color3.fromRGB(50, 50, 50)
ButtonStroke.Parent = ToggleButton

-- [[ УЛУЧШЕННОЕ СЕНСОРНОЕ ПЕРЕТАСКИВАНИЕ ДЛЯ СМАРТФОНОВ ]] --
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ УМНАЯ ЛОГИКА ПРОЗРАЧНОСТИ СТЕН ]] --
local wallsEnabled = false
local originalStates = {}

local function ModifyWall(obj)
    if obj:IsA("BasePart") and not obj:IsA("Terrain") then
        -- Игнорируем пол, спавны и самих игроков, чтобы не упасть в бездну
        if obj.Name == "Baseplate" or obj.Name == "SpawnLocation" or obj.Name == "Floor" then return end
        if obj:FindFirstAncestorOfClass("Model") and obj:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then return end
        
        -- Кэшируем первоначальные настройки стен
        if not originalStates[obj] then
            originalStates[obj] = {
                Transparency = obj.Transparency,
                CanCollide = obj.CanCollide
            }
        end
        
        if wallsEnabled then
            obj.Transparency = 0.7  -- Делаем прозрачными на 70%
            obj.CanCollide = false  -- Отключаем коллизию (ходим насквозь)
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

-- Обработка клика по кнопке
ToggleButton.MouseButton1Click:Connect(function()
    wallsEnabled = not wallsEnabled
    
    if wallsEnabled then
        ToggleButton.Text = "WALLS: ON"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(85, 255, 85)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(85, 255, 85)}):Play()
    else
        ToggleButton.Text = "WALLS: OFF"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 0)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50)}):Play()
    end
    ToggleWalls()
end)

-- Следим за динамически прогружаемыми частями лабиринта
Workspace.DescendantAdded:Connect(function(descendant)
    if wallsEnabled then
        task.wait(0.1)
        ModifyWall(descendant)
    end
end)

-- Безопасное закрытие хаба с возвращением карты в норму
CloseButton.MouseButton1Click:Connect(function()
    wallsEnabled = false
    ToggleWalls()
    ScreenGui:Destroy()
end)
