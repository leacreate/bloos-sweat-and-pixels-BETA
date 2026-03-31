local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
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

-- Hitbox functions
local function expandHitbox(character, size)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(size, size, size)
        hrp.Transparency = 1
        hrp.CanCollide = false
    end
end

local function applyToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            expandHitbox(player.Character, hitboxSize)
        end
    end
end

-- Slider
Tab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 20},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = hitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        hitboxSize = Value
        if enabled then
            applyToAll()
        end
    end,
})

-- Toggle
Tab:CreateToggle({
    Name = "Enable Hitbox Expander",
    CurrentValue = true,
    Flag = "HitboxToggle",
    Callback = function(Value)
        enabled = Value
        if enabled then
            applyToAll()
        else
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

-- Player handling
local function onPlayerAdded(player)
    if player == localPlayer then return end

    if player.Character and enabled then
        expandHitbox(player.Character, hitboxSize)
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if enabled then
            expandHitbox(character, hitboxSize)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
