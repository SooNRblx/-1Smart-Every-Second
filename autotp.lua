-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Nettoyage
if playerGui:FindFirstChild("AppleAutoFarmGui") then
    playerGui.AppleAutoFarmGui:Destroy()
end

-- 2. VARIABLES
local autoFarmActive = false
local antiAfkActive = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local farmWaitTime = 0.30 -- Vitesse fixée à 0.30s

-- Coordonnées mises à jour
local locations = {
    Vector3.new(225.466, 8, 8.099)
}

-- 3. INTERFACE
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AppleAutoFarmGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999 
screenGui.IgnoreGuiInset = true    

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "🍎"
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 250) -- Taille ajustée (plus petite sans le slider)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Apple Incremental"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -34, 0, 6)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -55)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--- SECTION FARM ---
local farmSection = Instance.new("Frame", scroll)
farmSection.Size = UDim2.new(0, 310, 0, 70) -- Taille réduite
farmSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", farmSection)

local labelAF = Instance.new("TextLabel", farmSection)
labelAF.Size = UDim2.new(0, 150, 0, 30)
labelAF.Position = UDim2.new(0, 10, 0, 20)
labelAF.Text = "+1 Wins" 
labelAF.Font = Enum.Font.Gotham
labelAF.TextSize = 16
labelAF.TextColor3 = Color3.new(1, 1, 1)
labelAF.BackgroundTransparency = 1
labelAF.TextXAlignment = Enum.TextXAlignment.Left

local btnAF = Instance.new("TextButton", farmSection)
btnAF.Size = UDim2.new(0, 80, 0, 30)
btnAF.Position = UDim2.new(1, -90, 0, 20)
btnAF.Text = "OFF"
btnAF.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
btnAF.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnAF)

--- SECTION MOVEMENT ---
local moveSection = Instance.new("Frame", scroll)
moveSection.Size = UDim2.new(0, 310, 0, 180)
moveSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", moveSection)

-- WalkSpeed Slider UI
local labelWS = Instance.new("TextLabel", moveSection)
labelWS.Size = UDim2.new(0, 200, 0, 20)
labelWS.Position = UDim2.new(0, 10, 0, 35)
labelWS.Text = "WalkSpeed: 16"
labelWS.Font = Enum.Font.Gotham
labelWS.TextSize = 15
labelWS.TextColor3 = Color3.new(1,1,1)
labelWS.BackgroundTransparency = 1
labelWS.TextXAlignment = Enum.TextXAlignment.Left

local sliderWS = Instance.new("Frame", moveSection)
sliderWS.Size = UDim2.new(0, 260, 0, 6)
sliderWS.Position = UDim2.new(0.5, -130, 0, 65)
sliderWS.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", sliderWS)

local dotWS = Instance.new("Frame", sliderWS)
dotWS.Size = UDim2.new(0, 18, 0, 18)
dotWS.Position = UDim2.new(0, 0, 0.5, -9)
dotWS.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
Instance.new("UICorner", dotWS).CornerRadius = UDim.new(1, 0)

-- JumpPower Slider UI
local labelJP = Instance.new("TextLabel", moveSection)
labelJP.Size = UDim2.new(0, 200, 0, 20)
labelJP.Position = UDim2.new(0, 10, 0, 105)
labelJP.Text = "JumpPower: 50"
labelJP.Font = Enum.Font.Gotham
labelJP.TextSize = 15
labelJP.TextColor3 = Color3.new(1,1,1)
labelJP.BackgroundTransparency = 1
labelJP.TextXAlignment = Enum.TextXAlignment.Left

local sliderJP = Instance.new("Frame", moveSection)
sliderJP.Size = UDim2.new(0, 260, 0, 6)
sliderJP.Position = UDim2.new(0.5, -130, 0, 135)
sliderJP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", sliderJP)

local dotJP = Instance.new("Frame", sliderJP)
dotJP.Size = UDim2.new(0, 18, 0, 18)
dotJP.Position = UDim2.new(0, 0, 0.5, -9)
dotJP.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
Instance.new("UICorner", dotJP).CornerRadius = UDim.new(1, 0)

-- 4. LOGIQUE DRAG ET SLIDERS restants
local function makeDraggable(obj, target)
    target = target or obj
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = target.Position
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function() dragging = false end)
end

local function setupSlider(back, dot, min, max, callback)
    local isSliding = false
    local function update(input)
        local relPos = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        dot.Position = UDim2.new(relPos, -9, 0.5, -9)
        local val = math.floor(min + (relPos * (max - min)))
        callback(val)
    end
    back.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true scroll.ScrollingEnabled = false update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function() isSliding = false scroll.ScrollingEnabled = true end)
end

makeDraggable(logo)
makeDraggable(frame)
makeDraggable(header, frame)

setupSlider(sliderWS, dotWS, 16, 250, function(v) walkSpeedValue = v labelWS.Text = "WalkSpeed: "..v end)
setupSlider(sliderJP, dotJP, 50, 350, function(v) jumpPowerValue = v labelJP.Text = "JumpPower: "..v end)

-- 5. BOUTONS
logo.MouseButton1Up:Connect(function() frame.Visible = not frame.Visible end)
close.MouseButton1Click:Connect(function() frame.Visible = false end)

btnAF.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    btnAF.Text = autoFarmActive and "ON" or "OFF"
    btnAF.BackgroundColor3 = autoFarmActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(80, 80, 80)
end)

-- BOUCLES
RunService.Stepped:Connect(function()
    pcall(function()
        local hum = player.Character.Humanoid
        hum.WalkSpeed = walkSpeedValue
        hum.JumpPower = jumpPowerValue
    end)
end)

task.spawn(function()
    while true do
        if autoFarmActive then
            pcall(function()
                player.Character.HumanoidRootPart.CFrame = CFrame.new(locations[1])
            end)
            task.wait(farmWaitTime)
        else task.wait(0.5) end
    end
end)
