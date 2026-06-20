-- [[ KIRIK LUXURY LABYRINTH BYPASS ]] --

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikWallHack_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главный фрейм (Меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromHex("#050505")
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Обводка (Золотистый градиент)
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

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK LABYRINTH HUB"
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

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 85)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
end)

-- Кнопка переключения прозрачности (On/Off)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 220, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -110, 0.5, -10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "WALLS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 85, 0)
ToggleButton.Font = Enum.Font.Inter
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Перетаскивание меню (Drag)
local UserInputService = game:GetService("UserInputService")
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

-- [[ ЛОГИКА ПРОЗРАЧНОСТИ СТЕН ]] --

local wallsEnabled = false
local originalStates = {} -- Тут храним старую прозрачность и коллизию стен

-- Функция, которая делает объект прозрачным
local function ModifyWall(obj)
    if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") and not obj:IsA("Terrain") then
        -- Пропускаем спавны и базовую плиту карты, чтобы не упасть в бездну
        if obj.Name == "Baseplate" or obj.Name == "SpawnLocation" then return end
        
        -- Запоминаем оригинал, если еще не запомнили
        if not originalStates[obj] then
            originalStates[obj] = {
                Transparency = obj.Transparency,
                CanCollide = obj.CanCollide
            }
        end
        
        if wallsEnabled then
            obj.Transparency = 0.7  -- Делаем полупрозрачным (чтобы видеть путь)
            obj.CanCollide = false  -- Отключаем коллизию (можно ходить сквозь стены)
        else
            -- Возвращаем как было
            local state = originalStates[obj]
            if state then
                obj.Transparency = state.Transparency
                obj.CanCollide = state.CanCollide
            end
        end
    end
end

-- Функция обхода всей карты
local function ToggleWalls()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        ModifyWall(obj)
    end
end

-- Логика кнопки On/Off
ToggleButton.MouseButton1Click:Connect(function()
    wallsEnabled = not wallsEnabled
    
    if wallsEnabled then
        ToggleButton.Text = "WALLS: ON"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(85, 255, 85)}):Play()
        ToggleWalls()
    else
        ToggleButton.Text = "WALLS: OFF"
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 85, 0)}):Play()
        ToggleWalls()
    end
end)

-- Авто-применение для новых объектов карты (если лабиринт подгружается по частям)
Workspace.DescendantAdded:Connect(function(descendant)
    if wallsEnabled then
        task.wait(0.1) -- Небольшая задержка, чтобы объект успел загрузиться
        ModifyWall(descendant)
    end
end)

-- Логика закрытия хаба
CloseButton.MouseButton1Click:Connect(function()
    -- Возвращаем стены в норму перед закрытием
    wallsEnabled = false
    ToggleWalls()
    ScreenGui:Destroy()
end)
