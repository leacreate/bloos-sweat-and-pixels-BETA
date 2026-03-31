local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local aimbotEnabled = false
local fov = 100
local smoothness = 0.5

local Window = Rayfield:CreateWindow({
    Name = "Aimbot",
    LoadingTitle = "Aimbot",
    LoadingSubtitle = "por pukegp",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Aimbot",
        FileName = "Config",
    },
})

local Tab = Window:CreateTab("Settings", 4483362458)

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
    if not aimbotEnabled then return end
    local target = getClosestPlayer()
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local camera = workspace.CurrentCamera
            local targetCFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothness)
        end
    end
end)

Tab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

Tab:CreateSlider({
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

Tab:CreateSlider({
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

Rayfield:LoadConfiguration()
