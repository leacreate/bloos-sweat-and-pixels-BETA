local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local hitboxSize = 6
local enabled = true
local espEnabled = false
local espBoxes = {}

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

-- Create a visible box highlight around a player
local function createESP(player)
    if espBoxes[player] then return end
    local box = Instance.new("SelectionBox")
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.LineThickness = 0.05
    box.SurfaceTransparency = 0.7
    box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
    box.Parent = workspace
    espBoxes[player] = box
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and espBoxes[player] then
                espBoxes[player].Adornee = hrp
            end
        end
    end
end

local function clearAllESP()
    for player, _ in pairs(espBoxes) do
        removeESP(player)
    end
end

local function expandHitbox(character, size)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(size, size, size)
        hrp.Transparency = 1
        hrp.CanCollide = false
    end
end

-- Heartbeat loop: expand hitboxes + update ESP
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            if enabled then
                expandHitbox(player.Character, hitboxSize)
            end
            if espEnabled then
                if not espBoxes[player] then
                    createESP(player)
                end
                updateESP()
            end
        end
    end
end)

-- Cleanup ESP when player leaves
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Hitbox Size Slider
Tab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 200},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = hitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        hitboxSize = Value
    end,
})

-- Enable/Disable Hitbox Toggle
Tab:CreateToggle({
    Name = "Enable Hitbox Expander",
    CurrentValue = true,
    Flag = "HitboxToggle",
    Callback = function(Value)
        enabled = Value
        if not enabled then
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

-- Hitbox ESP Toggle
Tab:CreateToggle({
    Name = "Hitbox ESP",
    CurrentValue = false,
    Flag = "HitboxESP",
    Callback = function(Value)
        espEnabled = Value
        if not espEnabled then
            clearAllESP()
        end
    end,
})

Rayfield:LoadConfiguration()
