-- 1. SERVICES
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Nettoyage
if playerGui:FindFirstChild("AppleAutoFarmGui") then
    playerGui.AppleAutoFarmGui:Destroy()
end

-- 2. VARIABLES
local farmActive = {f1 = false, f5 = false, f15 = false, f50 = false}
local antiAfkActive = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local farmWaitTime = 0.30

local positions = {
    f1 = Vector3.new(225.466, 8, 8.099),
    f5 = Vector3.new(225.78, 8, -71.401),
    f15 = Vector3.new(244.28, 8, -152.901),
    f50 = Vector3.new(90.266, 248.78, -232.776)
}

-- 3. INTERFACE (Base Taille 350x300)
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AppleAutoFarmGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999

local logo = Instance.new("TextButton", screenGui)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 150)
logo.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
logo.Text = "🍎"
logo.TextSize = 35
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.5, -175, 0.5, -150)
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
title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left

local headerCredit = Instance.new("TextLabel", header)
headerCredit.Size = UDim2.new(0, 100, 1, 0)
headerCredit.Position = UDim2.new(1, -140, 0, 0)
headerCredit.Text = "Made By RoScript"
headerCredit.TextColor3 = Color3.fromRGB(200, 200, 200)
headerCredit.Font = Enum.Font.Gotham; headerCredit.TextSize = 10; headerCredit.BackgroundTransparency = 1; headerCredit.TextXAlignment = Enum.TextXAlignment.Right

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -34, 0, 6)
close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(180, 40, 40); close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", close)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -85)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.CanvasSize = UDim2.new(0, 0, 0, 550); scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fonctions création UI
local function createFarmBtn(name, yPos, parent, toggleKey)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -20, 0, 35)
    container.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", container)
    lab.Size = UDim2.new(0, 150, 1, 0); lab.Text = name; lab.Font = Enum.Font.Gotham; lab.TextSize = 16; lab.TextColor3 = Color3.new(1, 1, 1); lab.BackgroundTransparency = 1; lab.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 80, 0, 30); btn.Position = UDim2.new(1, -80, 0.5, -15); btn.Text = "OFF"; btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        farmActive[toggleKey] = not farmActive[toggleKey]
        btn.Text = farmActive[toggleKey] and "ON" or "OFF"
        btn.BackgroundColor3 = farmActive[toggleKey] and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(80, 80, 80)
    end)
    return container
end

--- SECTION AUTO FARM ---
local farmSection = Instance.new("Frame", scroll)
farmSection.Size = UDim2.new(0, 310, 0, 190)
farmSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", farmSection)

local secTitleFarm = Instance.new("TextLabel", farmSection)
secTitleFarm.Size = UDim2.new(0, 100, 0, 25); secTitleFarm.Position = UDim2.new(0, 10, 0, 5); secTitleFarm.Text = "Auto Farm"; secTitleFarm.Font = Enum.Font.GothamBold; secTitleFarm.TextSize = 12; secTitleFarm.TextColor3 = Color3.fromRGB(180, 180, 180); secTitleFarm.BackgroundTransparency = 1; secTitleFarm.TextXAlignment = Enum.TextXAlignment.Left

local listFarm = Instance.new("Frame", farmSection)
listFarm.Size = UDim2.new(1, 0, 1, -30); listFarm.Position = UDim2.new(0, 0, 0, 30); listFarm.BackgroundTransparency = 1
local listL = Instance.new("UIListLayout", listFarm); listL.Padding = UDim.new(0, 5); listL.HorizontalAlignment = Enum.HorizontalAlignment.Center

createFarmBtn("+1 Wins", 0, listFarm, "f1")
createFarmBtn("+5 Wins", 0, listFarm, "f5")
createFarmBtn("+15 Wins", 0, listFarm, "f15")
createFarmBtn("+50 Wins", 0, listFarm, "f50")

--- SECTION MOVEMENT ---
local moveSection = Instance.new("Frame", scroll)
moveSection.Size = UDim2.new(0, 310, 0, 180)
moveSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", moveSection)

local function setupSlider(name, yPos, min, max, parent, callback)
    local lab = Instance.new("TextLabel", parent)
    lab.Size = UDim2.new(0, 200, 0, 20); lab.Position = UDim2.new(0, 10, 0, yPos); lab.Text = name..": "..min; lab.Font = Enum.Font.Gotham; lab.TextSize = 15; lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1; lab.TextXAlignment = Enum.TextXAlignment.Left
    local back = Instance.new("Frame", parent)
    back.Size = UDim2.new(0, 260, 0, 6); back.Position = UDim2.new(0.5, -130, 0, yPos + 30); back.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", back)
    local dot = Instance.new("Frame", back)
    dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 0, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(100, 200, 255); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local isSliding = false
    local function update(input)
        local rel = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        dot.Position = UDim2.new(rel, -9, 0.5, -9)
        local val = math.floor(min + (rel * (max - min)))
        lab.Text = name..": "..val
        callback(val)
    end
    back.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true scroll.ScrollingEnabled = false update(input) end end)
    UserInputService.InputChanged:Connect(function(input) if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    UserInputService.InputEnded:Connect(function() isSliding = false scroll.ScrollingEnabled = true end)
end

setupSlider("WalkSpeed", 35, 16, 250, moveSection, function(v) walkSpeedValue = v end)
setupSlider("JumpPower", 105, 50, 350, moveSection, function(v) jumpPowerValue = v end)

--- SECTION MISC ---
local miscSection = Instance.new("Frame", scroll)
miscSection.Size = UDim2.new(0, 310, 0, 80)
miscSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", miscSection)

local labelAA = Instance.new("TextLabel", miscSection)
labelAA.Size = UDim2.new(0, 150, 0, 30); labelAA.Position = UDim2.new(0, 10, 0, 25); labelAA.Text = "Anti-AFK"; labelAA.TextColor3 = Color3.new(1, 1, 1); labelAA.BackgroundTransparency = 1; labelAA.Font = Enum.Font.Gotham; labelAA.TextSize = 16; labelAA.TextXAlignment = Enum.TextXAlignment.Left

local btnAA = Instance.new("TextButton", miscSection)
btnAA.Size = UDim2.new(0, 80, 0, 30); btnAA.Position = UDim2.new(1, -90, 0, 25); btnAA.Text = "OFF"; btnAA.BackgroundColor3 = Color3.fromRGB(80, 80, 80); btnAA.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btnAA)

local footerVersion = Instance.new("TextLabel", frame)
footerVersion.Size = UDim2.new(0, 120, 0, 20); footerVersion.Position = UDim2.new(1, -130, 1, -25); footerVersion.Text = "v1 (Design Updated)"; footerVersion.TextColor3 = Color3.fromRGB(120, 120, 120); footerVersion.BackgroundTransparency = 1; footerVersion.Font = Enum.Font.Gotham; footerVersion.TextSize = 11; footerVersion.TextXAlignment = Enum.TextXAlignment.Right

-- 4. LOGIQUE
local function makeDraggable(obj, target)
    target = target or obj
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = target.Position end end)
    obj.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    obj.InputEnded:Connect(function() dragging = false end)
end
makeDraggable(logo); makeDraggable(header, frame)

logo.MouseButton1Up:Connect(function() frame.Visible = not frame.Visible end)
close.MouseButton1Click:Connect(function() frame.Visible = false end)
btnAA.MouseButton1Click:Connect(function() antiAfkActive = not antiAfkActive btnAA.Text = antiAfkActive and "ON" or "OFF" btnAA.BackgroundColor3 = antiAfkActive and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(80, 80, 80) end)

-- BOUCLES
RunService.Stepped:Connect(function()
    pcall(function()
        player.Character.Humanoid.WalkSpeed = walkSpeedValue
        player.Character.Humanoid.JumpPower = jumpPowerValue
    end)
end)

task.spawn(function()
    while true do
        local targetPos = nil
        if farmActive.f1 then targetPos = positions.f1
        elseif farmActive.f5 then targetPos = positions.f5
        elseif farmActive.f15 then targetPos = positions.f15
        elseif farmActive.f50 then targetPos = positions.f50 end

        if targetPos then
            pcall(function() player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos) end)
            task.wait(farmWaitTime)
        else
            task.wait(0.5)
        end
    end
end)

player.Idled:Connect(function()
    if antiAfkActive then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
end)
