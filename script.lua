local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local aimbotEnabled = false
local fov = 100
local smoothness = 0.5
local espEnabled = false
local espBoxes = {}
local espNames = {}

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

local function createESP(player)
    if espBoxes[player] then return end

    -- Box around whole character
    local box = Instance.new("SelectionBox")
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.LineThickness = 0.05
    box.SurfaceTransparency = 0.7
    box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
    box.Adornee = player.Character -- set to whole character model
    box.Parent = workspace
    espBoxes[player] = box

    -- Name tag
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = hrp
        billboard.Parent = workspace
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.Text = player.Name
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = billboard
        espNames[player] = billboard
    end
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
    if espNames[player] then
        espNames[player]:Destroy()
        espNames[player] = nil
    end
end

local function clearAllESP()
    for player, _ in pairs(espBoxes) do
        removeESP(player)
    end
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

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            if espEnabled then
                if not espBoxes[player] then
                    createESP(player)
                end
                -- Update box to follow character
                if espBoxes[player] then
                    espBoxes[player].Adornee = player.Character
                end
            end
        end
    end

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
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Respawn handling
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled and espBoxes[player] then
            removeESP(player)
        end
    end)
end)

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

Rayfield:LoadConfiguration()
