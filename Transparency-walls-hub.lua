local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MazeHelper"
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 180, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Text = "Walls: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 180, 0, 40)
CloseBtn.Position = UDim2.new(0, 10, 0, 55)
CloseBtn.Text = "Close"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = MainFrame

-- Логика
local wallsOn = false

local function setTransparency(state)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "Baseplate" and not obj:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then
            obj.Transparency = state and 0.7 or 0
            obj.CanCollide = not state
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    wallsOn = not wallsOn
    ToggleBtn.Text = wallsOn and "Walls: ON" or "Walls: OFF"
    setTransparency(wallsOn)
end)

CloseBtn.MouseButton1Click:Connect(function()
    setTransparency(false)
    ScreenGui:Destroy()
end)
