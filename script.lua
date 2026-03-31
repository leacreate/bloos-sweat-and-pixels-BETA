local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local hitboxSize = 6
local enabled = true

local Window = Rayfield:CreateWindow({
    Name = "Hitbox Expander",
    LoadingTitle = "Hitbox Expander",
    LoadingSubtitle = "by you",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HitboxExpander",
        FileName = "Config",
    },
})

local Tab = Window:CreateTab("Settings", 4483362458)

local function expandHitbox(character, size)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(size, size, size)
        hrp.Transparency = 1
        hrp.CanCollide = false
    end
end

-- Constantly reapply every frame so it never reverts
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            expandHitbox(player.Character, hitboxSize)
        end
    end
end)

Tab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 2000},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = hitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        hitboxSize = Value
    end,
})

Tab:CreateToggle({
    Name = "Enable Hitbox Expander",
    CurrentValue = true,
    Flag = "HitboxToggle",
    Callback = function(Value)
        enabled = Value
        if not enabled then
            -- Reset hitboxes when disabled
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                    end
                end
            end
        end
    end,
})

Rayfield:LoadConfiguration()
