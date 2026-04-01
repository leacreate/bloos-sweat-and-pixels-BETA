local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local aimbotEnabled = false
local fov = 100
local smoothness = 0.5
local espEnabled = false
local spinEnabled = false
local spinSpeed = 10
local espObjects = {}

local Window = Rayfield:CreateWindow({
    Name = "Fun Script",
    LoadingTitle = "Fun Script",
    LoadingSubtitle = "by you",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FunScript",
        FileName = "Config",
    },
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local FunTab = Window:CreateTab("Fun", 4483362458)

-- ESP functions
local function createBox()
    local lines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Transparency = 1
        line.Visible = false
        table.insert(lines, line)
    end
    return lines
end

local function createLabel()
    local label = Drawing.new("Text")
    label.Size = 14
    label.Color = Color3.fromRGB(255, 255, 255)
    label.Outline = true
    label.Visible = false
    return label
end

local function removeESP(player)
    if espObjects[player] then
        for _, line in ipairs(espObjects[player].box) do
            line:Remove()
        end
        espObjects[player].label:Remove()
        espObjects[player] = nil
    end
end

local function clearAllESP()
    for player in pairs(espObjects) do
        removeESP(player)
    end
end

local function getCorners(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local camera = workspace.CurrentCamera
    local size = character:GetExtentsSize()
    local topPos = hrp.Position + Vector3.new(0, size.Y / 2, 0)
    local botPos = hrp.Position - Vector3.new(0, size.Y / 2, 0)
    local top, topVis = camera:WorldToViewportPoint(topPos)
    local bot, botVis = camera:WorldToViewportPoint(botPos)
    if not topVis and not botVis then return nil end
    local height = math.abs(top.Y - bot.Y)
    local width = height * 0.6
    local x = top.X
    local y = top.Y
    return {
        topLeft     = Vector2.new(x - width / 2, y),
        topRight    = Vector2.new(x + width / 2, y),
        bottomLeft  = Vector2.new(x - width / 2, y + height),
        bottomRight = Vector2.new(x + width / 2, y + height),
        top         = Vector2.new(x, y - 15),
    }
end

local function getClosestPlayer()
    local closest = nil
    local shortestDist = fov
    local camera = workspace.CurrentCamera
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

local spinAngle = 0

RunService.Heartbeat:Connect(function(dt)
    -- Spinbot
    if spinEnabled then
        spinAngle = spinAngle + spinSpeed
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
            end
        end
    end

    -- Aimbot
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local camera = workspace.CurrentCamera
                local targetCFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothness)
            end
        end
    end

    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            if espEnabled then
                if not espObjects[player] then
                    espObjects[player] = {
                        box = createBox(),
                        label = createLabel()
                    }
                end
                local corners = getCorners(player.Character)
                local obj = espObjects[player]
                if corners then
                    obj.box[1].From = corners.topLeft
                    obj.box[1].To = corners.topRight
                    obj.box[1].Visible = true
                    obj.box[2].From = corners.bottomLeft
                    obj.box[2].To = corners.bottomRight
                    obj.box[2].Visible = true
                    obj.box[3].From = corners.topLeft
                    obj.box[3].To = corners.bottomLeft
                    obj.box[3].Visible = true
                    obj.box[4].From = corners.topRight
                    obj.box[4].To = corners.bottomRight
                    obj.box[4].Visible = true
                    obj.label.Text = player.Name
                    obj.label.Position = corners.top
                    obj.label.Visible = true
                else
                    for _, line in ipairs(obj.box) do
                        line.Visible = false
                    end
                    obj.label.Visible = false
                end
            else
                if espObjects[player] then
                    for _, line in ipairs(espObjects[player].box) do
                        line.Visible = false
                    end
                    espObjects[player].label.Visible = false
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        removeESP(player)
    end)
end)

-- Aimbot Tab
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = fov,
    Flag = "AimbotFOV",
    Callback = function(Value)
        fov = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 5,
    Flag = "AimbotSmooth",
    Callback = function(Value)
        smoothness = Value / 10
    end,
})

-- ESP Tab
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        espEnabled = Value
        if not espEnabled then
            clearAllESP()
        end
    end,
})

-- Fun Tab
FunTab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Flag = "SpinToggle",
    Callback = function(Value)
        spinEnabled = Value
    end,
})

FunTab:CreateSlider({
    Name = "Spin Speed",
    Range = {1, 50},
    Increment = 1,
    Suffix = "x",
    CurrentValue = spinSpeed,
    Flag = "SpinSpeed",
    Callback = function(Value)
        spinSpeed = Value
    end,
})

Rayfield:LoadConfiguration()
