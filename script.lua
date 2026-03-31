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

local function clearAllESP()
    for player, _ in pairs(espBoxes) do
        removeESP(player)
    end
end

local function expandHitbox(character, size)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- use pcall in case the game blocks property changes
        pcall(function()
            hrp.Size = Vector3.new(size, size, size)
            hrp.Transparency = 1
            hrp.CanCollide = false
        end)
    end
end

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                if enabled then
                    expandHitbox(char, hitboxSize)
                end
                if espEnabled then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not espBoxes[player] then
                            createESP(player)
                        end
                        if espBoxes[player] then
                            espBoxes[player].Adornee = hrp
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

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
                        pcall(function()
                            hrp.Size = Vector3.new(2, 2, 1)
                        end)
                    end
                end
            end
        end
    end,
})

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
