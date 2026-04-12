-- ======================================================
-- 👑 MxF HUB - RIVALS VERSION (V.1.0.0.15 - DEV MODE)
-- Token Security: DISABLED (For testing)
-- Fixes: Removed Strict Double WallCheck breaking Aimbot/TriggerBot
-- ======================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end
if targetGui:FindFirstChild("MxFHubOverlay") then targetGui.MxFHubOverlay:Destroy() end

-- ==========================================
-- 1. CONFIGURATION & VARIABLES (FULL MEMORY)
-- ==========================================
local ConfigFileName = "MxFHub_Rivals_Settings.json"
local CurrentSettings = {
	Theme = "Default", Font = "Gotham", Opacity = 0.85, TextSizeOffset = 1, MenuSize = 100, rainbowUI = false,
	espEnabled = false, espOutlines = true, espHealthBar = false, espRainbow = false, showFovCircle = false, showTracers = false,
	espR = 255, espG = 20, espB = 20,
	aimbotEnabled = false, selectedAimPart = "Head", wallCheckEnabled = true, aimSmoothness = 5, fovRadius = 150,
	predictionEnabled = false, predictionFactor = 0.15,
	triggerBotEnabled = false, rapidFire = false, missChance = 0, teamCheck = true,
	hitboxEnabled = false, hitboxSize = 10, rainbowHitbox = false,
	walkSpeedEnabled = false, walkSpeedValue = 50, infJumpEnabled = false,
	noClipEnabled = false, flyEnabled = false, flySpeedValue = 50,
	spinbotEnabled = false, spinbotSpeed = 50,
	followTargetName = ""
}

local Themes = {
	["Default"]  = { Accent = Color3.fromRGB(255, 255, 255), Main = Color3.fromRGB(15, 16, 20), Side = Color3.fromRGB(10, 11, 14), Elem = Color3.fromRGB(22, 23, 27), Text = Color3.fromRGB(250,250,250), TextDim = Color3.fromRGB(150,150,160), Stroke = Color3.fromRGB(45, 45, 50) },
	["Diamond"]  = { Accent = Color3.fromRGB(0, 200, 255),   Main = Color3.fromRGB(10, 15, 25), Side = Color3.fromRGB(5, 10, 15),  Elem = Color3.fromRGB(15, 22, 35), Text = Color3.fromRGB(240,250,255), TextDim = Color3.fromRGB(100,150,200), Stroke = Color3.fromRGB(30, 45, 70) },
	["Banana"]   = { Accent = Color3.fromRGB(255, 210, 50),  Main = Color3.fromRGB(20, 18, 10), Side = Color3.fromRGB(15, 12, 5),  Elem = Color3.fromRGB(30, 25, 15), Text = Color3.fromRGB(255,250,230), TextDim = Color3.fromRGB(180,160,100), Stroke = Color3.fromRGB(60, 50, 20) },
	["Ruby"]     = { Accent = Color3.fromRGB(255, 60, 60),   Main = Color3.fromRGB(25, 10, 10), Side = Color3.fromRGB(15, 5, 5),   Elem = Color3.fromRGB(35, 15, 15), Text = Color3.fromRGB(255,230,230), TextDim = Color3.fromRGB(180,100,100), Stroke = Color3.fromRGB(70, 20, 20) },
	["Amethyst"] = { Accent = Color3.fromRGB(180, 80, 255),  Main = Color3.fromRGB(18, 10, 25), Side = Color3.fromRGB(10, 5, 15),  Elem = Color3.fromRGB(28, 15, 35), Text = Color3.fromRGB(245,230,255), TextDim = Color3.fromRGB(150,100,180), Stroke = Color3.fromRGB(50, 25, 70) },
	["Emerald"]  = { Accent = Color3.fromRGB(50, 255, 100),  Main = Color3.fromRGB(10, 20, 15), Side = Color3.fromRGB(5, 15, 10),  Elem = Color3.fromRGB(15, 30, 20), Text = Color3.fromRGB(230,255,240), TextDim = Color3.fromRGB(100,180,130), Stroke = Color3.fromRGB(30, 60, 40) },
	["Sapphire"] = { Accent = Color3.fromRGB(65, 105, 225),  Main = Color3.fromRGB(15, 20, 30), Side = Color3.fromRGB(10, 15, 20), Elem = Color3.fromRGB(20, 25, 35), Text = Color3.fromRGB(230,240,255), TextDim = Color3.fromRGB(120,140,180), Stroke = Color3.fromRGB(35, 45, 65) },
	["Sunset"]   = { Accent = Color3.fromRGB(255, 120, 80),  Main = Color3.fromRGB(25, 15, 15), Side = Color3.fromRGB(15, 10, 10), Elem = Color3.fromRGB(35, 20, 20), Text = Color3.fromRGB(255,240,230), TextDim = Color3.fromRGB(180,120,120), Stroke = Color3.fromRGB(70, 30, 30) },
	["Midnight"] = { Accent = Color3.fromRGB(120, 100, 255), Main = Color3.fromRGB(10, 10, 15), Side = Color3.fromRGB(5, 5, 10),   Elem = Color3.fromRGB(15, 15, 25), Text = Color3.fromRGB(230,230,255), TextDim = Color3.fromRGB(100,100,160), Stroke = Color3.fromRGB(25, 25, 45) },
	["DarkGold"] = { Accent = Color3.fromRGB(218, 165, 32),  Main = Color3.fromRGB(20, 20, 20), Side = Color3.fromRGB(12, 12, 12), Elem = Color3.fromRGB(28, 28, 28), Text = Color3.fromRGB(255,250,240), TextDim = Color3.fromRGB(160,150,130), Stroke = Color3.fromRGB(50, 45, 35) },
	["Obsidian"] = { Accent = Color3.fromRGB(180, 180, 180), Main = Color3.fromRGB(8, 8, 8),   Side = Color3.fromRGB(4, 4, 4),   Elem = Color3.fromRGB(14, 14, 14), Text = Color3.fromRGB(220,220,220), TextDim = Color3.fromRGB(120,120,120), Stroke = Color3.fromRGB(30, 30, 30) }
}
local ThemeNames = {"Default", "Diamond", "Banana", "Ruby", "Amethyst", "Emerald", "Sapphire", "Sunset", "Midnight", "DarkGold", "Obsidian"}
local Fonts = { ["Gotham"] = Enum.Font.GothamBold, ["Code"] = Enum.Font.Code, ["SciFi"] = Enum.Font.Michroma }
local FontNames = {"Gotham", "Code", "SciFi"}

local function SaveSettings() pcall(function() if writefile then writefile(ConfigFileName, HttpService:JSONEncode(CurrentSettings)) end end) end
local function LoadSettings()
	if readfile and isfile and isfile(ConfigFileName) then
		pcall(function() local data = HttpService:JSONDecode(readfile(ConfigFileName)); for k,v in pairs(data) do CurrentSettings[k] = v end end)
	end
end
LoadSettings()

local UIConfig = { WindowSize = UDim2.new(0, 760, 0, 520), ToggleKey = Enum.KeyCode.Insert }
local currentScale = (tonumber(CurrentSettings.MenuSize) or 100) / 100

local bodyVelocity, bodyGyro, speedConn, flyConn, noClipConn
local isBindingAny = false
local isFollowingPlayer, followConnection = false, nil
local aimTargetOptions = {"Head", "Torso", "Legs", "Random"}
local originalHitboxSizes = {}
local tabFunctions = {} 
local hue = 0
local isMenuOpen = true 

-- DRAWING API
local fovCircle, tracerLine
if Drawing then
    fovCircle = Drawing.new("Circle"); fovCircle.Visible = false; fovCircle.Thickness = 1.5; fovCircle.Filled = false
    tracerLine = Drawing.new("Line"); tracerLine.Visible = false; tracerLine.Thickness = 1.5
end

-- ==========================================
-- 2. BACK-END LOGIC (RIVALS / PVP FOCUS)
-- ==========================================

local function isVisible(targetPos)
    if not CurrentSettings.wallCheckEnabled then return true end
    local origin = camera.CFrame.Position
    local direction = (targetPos - origin)
    local raycastParams = RaycastParams.new()
    
    local ignoreList = {player.Character, camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then table.insert(ignoreList, p.Character) end
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance then
        if result.Instance.Transparency == 1 or not result.Instance.CanCollide then return true end
        return false
    end
    return true 
end

local function getSpecificPart(char)
    local partChoice = CurrentSettings.selectedAimPart
    if partChoice == "Random" then
        local choices = {"Head", "Torso", "Legs"}
        partChoice = choices[math.random(1, 3)]
    end

    local primaryPart = nil
    pcall(function()
        if partChoice == "Head" then 
            primaryPart = char:FindFirstChild("Head") or char:FindFirstChild("HeadHitbox")
        elseif partChoice == "Torso" then 
            primaryPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        elseif partChoice == "Legs" then 
            primaryPart = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("LeftLowerLeg")
        end
        if not primaryPart then primaryPart = char:FindFirstChild("HumanoidRootPart") end
    end)

    if primaryPart and isVisible(primaryPart.Position) then return primaryPart end

    local fallbackParts = {
        char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso"),
        char:FindFirstChild("RightUpperArm"), char:FindFirstChild("LeftUpperArm"),
        char:FindFirstChild("RightLowerLeg"), char:FindFirstChild("LeftLowerLeg")
    }
    
    for _, part in ipairs(fallbackParts) do
        if part and isVisible(part.Position) then return part end
    end

    return nil
end

local function getTargetForAim()
    local closestPart = nil
    local shortestDistance = CurrentSettings.fovRadius
    local centerPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if CurrentSettings.teamCheck and p.Team ~= nil and player.Team ~= nil and p.Team == player.Team then continue end
        
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetPart = getSpecificPart(p.Character)
            if targetPart then
                local checkPos = targetPart.Position
                if CurrentSettings.predictionEnabled then
                    pcall(function() checkPos = checkPos + (targetPart.AssemblyLinearVelocity * CurrentSettings.predictionFactor) end)
                end
                
                local pos, onScreen = camera:WorldToViewportPoint(checkPos)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist; closestPart = targetPart
                    end
                end
            end
        end
    end
    return closestPart
end

local function updateESP()
    hue = hue + 0.005; if hue > 1 then hue = 0 end
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    local espColor = CurrentSettings.espRainbow and rainbowColor or Color3.fromRGB(CurrentSettings.espR, CurrentSettings.espG, CurrentSettings.espB)

    if fovCircle then
        if CurrentSettings.showFovCircle then
            fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            fovCircle.Radius = CurrentSettings.fovRadius
            fovCircle.Color = espColor; fovCircle.Visible = true
        else fovCircle.Visible = false end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if CurrentSettings.teamCheck and p.Team ~= nil and player.Team ~= nil and p.Team == player.Team then 
            if p.Character then
                if p.Character:FindFirstChild("MxF_ESP") then p.Character.MxF_ESP:Destroy() end
                if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("MxF_HealthBar") then p.Character.Head.MxF_HealthBar:Destroy() end
            end
            continue 
        end

        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local hl = char:FindFirstChild("MxF_ESP")
            if CurrentSettings.espEnabled then
                if not hl then 
                    hl = Instance.new("Highlight"); hl.Name = "MxF_ESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char 
                end
                hl.FillColor = espColor; hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5; hl.OutlineTransparency = CurrentSettings.espOutlines and 0.2 or 1
            elseif hl then hl:Destroy() end

            local head = char:FindFirstChild("Head")
            if head then
                local hBar = head:FindFirstChild("MxF_HealthBar")
                if CurrentSettings.espEnabled and CurrentSettings.espHealthBar then
                    if not hBar then
                        hBar = Instance.new("BillboardGui", head); hBar.Name = "MxF_HealthBar"; hBar.Size = UDim2.new(0, 40, 0, 5); hBar.StudsOffset = Vector3.new(0, 1.2, 0); hBar.AlwaysOnTop = true
                        local bg = Instance.new("Frame", hBar); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.new(0,0,0); bg.BorderSizePixel = 0
                        local fill = Instance.new("Frame", bg); fill.Name = "Fill"; fill.Size = UDim2.new(1, 0, 1, 0); fill.BackgroundColor3 = Color3.new(0,1,0); fill.BorderSizePixel = 0
                    end
                    local fill = hBar:FindFirstChild("Frame") and hBar.Frame:FindFirstChild("Fill")
                    if fill then
                        local pct = char.Humanoid.Health / char.Humanoid.MaxHealth
                        fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = Color3.new(1 - pct, pct, 0)
                    end
                elseif hBar then hBar:Destroy() end
            end
        else
            if char then 
                if char:FindFirstChild("MxF_ESP") then char.MxF_ESP:Destroy() end
                if char:FindFirstChild("Head") and char.Head:FindFirstChild("MxF_HealthBar") then char.Head.MxF_HealthBar:Destroy() end
            end
        end
    end
end

-- --- MAIN RENDER LOOP ---
pcall(function() RunService:UnbindFromRenderStep("MxF_MasterLoop") end)
RunService:BindToRenderStep("MxF_MasterLoop", Enum.RenderPriority.Camera.Value + 50, function()
    pcall(function()
        camera = workspace.CurrentCamera
        updateESP()
        local rainbowColor = Color3.fromHSV(hue, 1, 1)

        if CurrentSettings.rainbowUI and screenGui:FindFirstChild("Frame") then
            local stroke = screenGui.Frame:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = rainbowColor end
        end

        local currentTarget = getTargetForAim()
        local predictedPos = nil

        if currentTarget then
            predictedPos = currentTarget.Position
            if CurrentSettings.predictionEnabled then
                pcall(function() predictedPos = predictedPos + (currentTarget.AssemblyLinearVelocity * CurrentSettings.predictionFactor) end)
            end
        end

        if tracerLine then
            if CurrentSettings.showTracers and predictedPos then
                local pos, onScreen = camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    tracerLine.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    tracerLine.To = Vector2.new(pos.X, pos.Y)
                    tracerLine.Color = CurrentSettings.espRainbow and rainbowColor or Color3.fromRGB(CurrentSettings.espR, CurrentSettings.espG, CurrentSettings.espB)
                    tracerLine.Visible = true
                else tracerLine.Visible = false end
            else tracerLine.Visible = false end
        end

        if isMenuOpen then return end

        -- 🚀 AIMBOT & TRIGGERBOT (SANS LE DOUBLE WALLCHECK CASSÉ) 🚀
        if CurrentSettings.aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and predictedPos then
            local targetPos = predictedPos
            if CurrentSettings.missChance > 0 and math.random(1, 100) <= CurrentSettings.missChance then 
                targetPos = targetPos + Vector3.new(math.random(-3,3), math.random(-3,3), math.random(-3,3)) 
            end

            local pos, onScreen = camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local diff = Vector2.new(pos.X - center.X, pos.Y - center.Y)
                local aimSpeed = CurrentSettings.aimSmoothness
                
                if aimSpeed == 1 then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                else
                    aimSpeed = aimSpeed * 2
                    if mousemoverel then mousemoverel(diff.X / aimSpeed, diff.Y / aimSpeed)
                    else camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), 1 / aimSpeed) end
                end
            end
        end

        if CurrentSettings.triggerBotEnabled and predictedPos then
            local pos, onScreen = camera:WorldToViewportPoint(predictedPos)
            local centerPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            if onScreen and (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude < 30 then
                if CurrentSettings.missChance > 0 and math.random(1, 100) <= CurrentSettings.missChance then return end
                
                if mouse1click then 
                    mouse1click()
                    if CurrentSettings.rapidFire then mouse1click(); mouse1click(); mouse1click() end 
                else
                    VIM:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, true, game, 0)
                    if not CurrentSettings.rapidFire then task.wait(0.01) end
                    VIM:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, false, game, 0)
                end
            end
        end
    end)
end)

-- --- HITBOX EXPANDER & SPINBOT ---
RunService.Heartbeat:Connect(function()
    pcall(function()
        if CurrentSettings.spinbotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(CurrentSettings.spinbotSpeed), 0)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            if CurrentSettings.teamCheck and p.Team ~= nil and player.Team ~= nil and p.Team == player.Team then continue end

            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if CurrentSettings.hitboxEnabled then
                        if hrp.Size.X ~= CurrentSettings.hitboxSize then originalHitboxSizes[hrp] = hrp.Size end
                        hrp.Size = Vector3.new(CurrentSettings.hitboxSize, CurrentSettings.hitboxSize, CurrentSettings.hitboxSize)
                        hrp.Transparency = 0.6; hrp.Material = Enum.Material.ForceField; hrp.CanCollide = false
                        hrp.Color = CurrentSettings.rainbowHitbox and Color3.fromHSV(hue, 1, 1) or Color3.fromRGB(CurrentSettings.espR, CurrentSettings.espG, CurrentSettings.espB)
                    else
                        if originalHitboxSizes[hrp] then
                            hrp.Size = originalHitboxSizes[hrp]; hrp.Transparency = 1; hrp.Material = Enum.Material.Plastic
                            originalHitboxSizes[hrp] = nil
                        end
                    end
                end
            end
        end
    end)
end)

-- --- MOVEMENT & EXPLOITS ---
local function updateSpeed()
	if speedConn then speedConn:Disconnect() end
	if CurrentSettings.walkSpeedEnabled then 
        speedConn = RunService.Heartbeat:Connect(function(dt) 
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character.Humanoid
                local hrp = player.Character.HumanoidRootPart
                if hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * ((CurrentSettings.walkSpeedValue - 16) * dt)) end
            end 
        end)
	end
end

UIS.JumpRequest:Connect(function() if CurrentSettings.infJumpEnabled and player.Character then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function enableNoClip()
	if noClipConn then noClipConn:Disconnect() end
	noClipConn = RunService.Stepped:Connect(function() if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
end
local function disableNoClip()
	if noClipConn then noClipConn:Disconnect() noClipConn = nil end
	if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

local function toggleFly()
	if flyConn then flyConn:Disconnect() end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	if not CurrentSettings.flyEnabled then if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end return end
	local char = player.Character; if not char then return end
	char.Humanoid.PlatformStand = true
	bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart); bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5); bodyVelocity.Velocity = Vector3.zero
	bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart); bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bodyGyro.D = 50
	flyConn = RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
		local dir, cf = Vector3.zero, camera.CFrame
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end
		bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * CurrentSettings.flySpeedValue or Vector3.zero; bodyGyro.CFrame = cf
	end)
end

player.CharacterAdded:Connect(function()
	if flyConn then flyConn:Disconnect() flyConn = nil end; task.wait(0.5)
	if CurrentSettings.walkSpeedEnabled then updateSpeed() end
	if CurrentSettings.noClipEnabled then enableNoClip() end
	if CurrentSettings.flyEnabled then toggleFly() end
	if isFollowingPlayer then isFollowingPlayer = false; if followConnection then followConnection:Disconnect(); followConnection = nil end end
end)

local function findTargetPlayer(name)
	if not name or name == "" then return nil end
	name = name:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and (p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name) then return p end
	end
	return nil
end

-- ==========================================
-- 3. MOTEUR UI
-- ==========================================
local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubPremium"; screenGui.DisplayOrder = 100; screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UIConfig.WindowSize; mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BorderSizePixel = 0; mainFrame:SetAttribute("BgRole", "Main"); Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
mainFrame.Visible = true; mainFrame.ClipsDescendants = true; Instance.new("UIStroke", mainFrame):SetAttribute("StrokeRole", "Stroke")

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 200, 1, 0); sidebar.BorderSizePixel = 0; sidebar:SetAttribute("BgRole", "Side"); Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local logoImg = Instance.new("ImageLabel", sidebar)
logoImg.Size = UDim2.new(0, 45, 0, 45); logoImg.Position = UDim2.new(0, 15, 0, 15); logoImg.BackgroundTransparency = 1; logoImg.ScaleType = Enum.ScaleType.Fit
pcall(function()
	local logoUrl = "https://i.goopics.net/lpt7p1.png"
	if writefile and getcustomasset then local data = game:HttpGet(logoUrl); writefile("mxf_logo.png", data); logoImg.Image = getcustomasset("mxf_logo.png") else logoImg.Image = "rbxassetid://10629237000" end
end)

local hubName = Instance.new("TextLabel", sidebar)
hubName.Size = UDim2.new(1, -70, 0, 45); hubName.Position = UDim2.new(0, 70, 0, 15); hubName.BackgroundTransparency = 1; hubName.Text = "MxFlow"
hubName:SetAttribute("TextRole", "Text"); hubName:SetAttribute("BaseTextSize", 20); hubName.TextXAlignment = Enum.TextXAlignment.Left

local searchFrame = Instance.new("Frame", sidebar)
searchFrame.Size = UDim2.new(1, -30, 0, 36); searchFrame.Position = UDim2.new(0, 15, 0, 75); searchFrame:SetAttribute("BgRole", "Elem"); Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)

local searchIcon = Instance.new("ImageLabel", searchFrame)
searchIcon.Size = UDim2.new(0, 18, 0, 18); searchIcon.Position = UDim2.new(0, 10, 0.5, -9); searchIcon.Image = "rbxassetid://7733654492"; searchIcon.BackgroundTransparency = 1; searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(1, -40, 1, 0); searchBox.Position = UDim2.new(0, 35, 0, 0); searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""; searchBox:SetAttribute("TextRole", "Text"); searchBox:SetAttribute("BaseTextSize", 14); searchBox.TextXAlignment = Enum.TextXAlignment.Left

local navList = Instance.new("ScrollingFrame", sidebar)
navList.Size = UDim2.new(1, 0, 1, -130); navList.Position = UDim2.new(0, 0, 0, 130); navList.BackgroundTransparency = 1; navList.ScrollBarThickness = 0
local navLayout = Instance.new("UIListLayout", navList); navLayout.Padding = UDim.new(0, 6); navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -210, 1, -20); container.Position = UDim2.new(0, 205, 0, 10); container.BackgroundTransparency = 1

local activeTabName = Instance.new("TextLabel", container)
activeTabName.Size = UDim2.new(1, 0, 0, 45); activeTabName.BackgroundTransparency = 1; activeTabName.Text = "Home"; activeTabName:SetAttribute("TextRole", "Text"); activeTabName:SetAttribute("BaseTextSize", 26); activeTabName.TextXAlignment = Enum.TextXAlignment.Left

local versionLbl = Instance.new("TextLabel", mainFrame)
versionLbl.Size = UDim2.new(0, 300, 0, 20); versionLbl.Position = UDim2.new(1, -15, 1, -10); versionLbl.AnchorPoint = Vector2.new(1, 1); versionLbl.BackgroundTransparency = 1
versionLbl.Text = "V.1.0.0.15 | Rivals Edition © MxFlow"; versionLbl.TextXAlignment = Enum.TextXAlignment.Right; versionLbl:SetAttribute("TextRole", "TextDim"); versionLbl:SetAttribute("BaseTextSize", 11)

local function ApplyTheme()
	pcall(function()
		local t = Themes[CurrentSettings.Theme] or Themes["Default"]; local f = Fonts[CurrentSettings.Font] or Fonts["Gotham"]; local offset = tonumber(CurrentSettings.TextSizeOffset) or 1; local opacity = tonumber(CurrentSettings.Opacity) or 0.85
		currentScale = (tonumber(CurrentSettings.MenuSize) or 100) / 100

		if mainFrame.Visible then mainFrame.Size = UDim2.new(0, 760 * currentScale, 0, 520 * currentScale) end
		mainFrame.BackgroundTransparency = 1 - opacity; sidebar.BackgroundTransparency = 1 - opacity

		for _, obj in ipairs(screenGui:GetDescendants()) do
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				obj.Font = f
				local bSize = obj:GetAttribute("BaseTextSize"); if bSize then obj.TextSize = (tonumber(bSize) + offset) * currentScale end
			end

			if obj:IsA("GuiObject") then
				local txtRole = obj:GetAttribute("TextRole")
				if txtRole == "Text" then obj.TextColor3 = t.Text elseif txtRole == "TextDim" then obj.TextColor3 = t.TextDim elseif txtRole == "Accent" then obj.TextColor3 = t.Accent elseif txtRole == "Main" then obj.TextColor3 = t.Main end
				
				local bgRole = obj:GetAttribute("BgRole")
				if bgRole == "Main" then obj.BackgroundColor3 = t.Main elseif bgRole == "Side" then obj.BackgroundColor3 = t.Side elseif bgRole == "Elem" then obj.BackgroundColor3 = t.Elem elseif bgRole == "AccentBg" then obj.BackgroundColor3 = t.Accent elseif bgRole == "TogglePill" then obj.BackgroundColor3 = obj:GetAttribute("ToggleState") and t.Accent or t.Stroke elseif bgRole == "TabBtn" then obj.BackgroundTransparency = obj:GetAttribute("IsActive") and 0 or 1 if obj:GetAttribute("IsActive") then obj.BackgroundColor3 = t.Elem end end
			end
			if obj:IsA("UIStroke") and not CurrentSettings.rainbowUI then if obj:GetAttribute("StrokeRole") == "Stroke" then obj.Color = t.Stroke end end
		end
	end)
end

-- UI FACTORY
local Pages, currentTab = {}, nil
local function CreateTab(name, iconId)
	local btn = Instance.new("TextButton", navList); btn.Size = UDim2.new(0.9, 0, 0, 42); btn.BackgroundTransparency = 1; btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10); btn:SetAttribute("BgRole", "TabBtn"); btn:SetAttribute("IsActive", false)
	local icon = Instance.new("ImageLabel", btn); icon.Size = UDim2.new(0, 20, 0, 20); icon.Position = UDim2.new(0, 12, 0.5, -10); icon.Image = "rbxassetid://"..iconId; icon.BackgroundTransparency = 1; icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
	local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -45, 1, 0); lbl.Position = UDim2.new(0, 40, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 16)
	local page = Instance.new("ScrollingFrame", container); page.Size = UDim2.new(1, 0, 1, -55); page.Position = UDim2.new(0, 0, 0, 55); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false
	local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 10)
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20) end)
	Pages[name] = page

	local function activate()
		for n, p in pairs(Pages) do p.Visible = (n == name) end
		if currentTab then currentTab.btn:SetAttribute("IsActive", false); currentTab.lbl:SetAttribute("TextRole", "TextDim") end
		btn:SetAttribute("IsActive", true); lbl:SetAttribute("TextRole", "Text"); activeTabName.Text = name; currentTab = {btn = btn, lbl = lbl, page = page}; ApplyTheme()
	end
	tabFunctions[name] = activate; btn.MouseButton1Click:Connect(activate); return page
end

local function CreateSection(page, text, defaultOpen)
	local section = Instance.new("Frame", page); section.Size = UDim2.new(1, -10, 0, 45); section.ClipsDescendants = true; section:SetAttribute("BgRole", "Elem"); section:SetAttribute("IsSection", true); Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", section):SetAttribute("StrokeRole", "Stroke")
	local btn = Instance.new("TextButton", section); btn.Size = UDim2.new(1, 0, 0, 45); btn.BackgroundTransparency = 1; btn.Text = ""
	local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -30, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "Text"); lbl:SetAttribute("BaseTextSize", 16)
	local icon = Instance.new("TextLabel", btn); icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -25, 0, 0); icon.BackgroundTransparency = 1; icon.Text = defaultOpen and "▼" or "▶"; icon:SetAttribute("TextRole", "TextDim"); icon:SetAttribute("BaseTextSize", 14)
	local content = Instance.new("Frame", section); content.Size = UDim2.new(1, 0, 0, 0); content.Position = UDim2.new(0, 0, 0, 45); content.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local isOpen = defaultOpen == true
	local function updateSize()
		if isOpen then
			local cHeight = layout.AbsoluteContentSize.Y + 15 
			TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45 + cHeight)}):Play(); content.Size = UDim2.new(1, 0, 0, cHeight)
		else TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45)}):Play() end
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if isOpen then updateSize() end end)
	btn.MouseButton1Click:Connect(function() isOpen = not isOpen; icon.Text = isOpen and "▼" or "▶"; updateSize(); task.delay(0.25, function() if currentTab then local mL = currentTab.page:FindFirstChildOfClass("UIListLayout") if mL then currentTab.page.CanvasSize = UDim2.new(0, 0, 0, mL.AbsoluteContentSize.Y + 20) end end end) end)
	task.delay(0.1, function() if defaultOpen then updateSize() end end); return content
end

local function CreateParagraph(page, text)
	local lbl = Instance.new("TextLabel", page); lbl.Size = UDim2.new(1, -20, 0, 60); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14); return lbl
end

local function CreateRow(page, height)
	local row = Instance.new("Frame", page); row.Size = UDim2.new(1, -10, 0, height or 45); row.BackgroundTransparency = 1; row:SetAttribute("IsRow", true); return row
end

local function CreateToggle(page, text, default, callback)
	local row = CreateRow(page, 45); local state = default
	local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
	local pill = Instance.new("Frame", row); pill.Size = UDim2.new(0, 42, 0, 22); pill.Position = UDim2.new(1, -52, 0.5, -11); pill:SetAttribute("BgRole", "TogglePill"); pill:SetAttribute("ToggleState", state); Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
	local circle = Instance.new("Frame", pill); circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	
	local function applyState(newState)
		state = newState; pill:SetAttribute("ToggleState", state)
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play(); ApplyTheme()
	end
	btn.MouseButton1Click:Connect(function() applyState(not state); callback(state) end)
	if state then applyState(state) end; return applyState
end

local function CreateSlider(page, text, min, max, default, callback)
	local row = CreateRow(page, 55)
	local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.5, 0, 0, 25); lbl.Position = UDim2.new(0, 10, 0, 5); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local valLbl = Instance.new("TextLabel", row); valLbl.Size = UDim2.new(0.4, 0, 0, 25); valLbl.Position = UDim2.new(1, -50, 0, 5); valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default); valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl:SetAttribute("TextRole", "Accent"); valLbl:SetAttribute("BaseTextSize", 13)
	local sliderBg = Instance.new("TextButton", row); sliderBg.Size = UDim2.new(1, -20, 0, 6); sliderBg.Position = UDim2.new(0, 10, 0, 35); sliderBg.Text = ""; sliderBg:SetAttribute("BgRole", "Main"); Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame", sliderBg); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill:SetAttribute("BgRole", "AccentBg"); Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local dragging = false
	local function update()
		local pos = math.clamp((UIS:GetMouseLocation().X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local val = math.floor(min + ((max - min) * pos))
		fill.Size = UDim2.new(pos, 0, 1, 0); valLbl.Text = tostring(val); callback(val)
	end
	sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	RunService.RenderStepped:Connect(function() if dragging then update() end end)
end

local function CreateDropdown(page, text, options, default, callback)
	local current = default or options[1]
	local row = CreateRow(page, 45); row.ClipsDescendants = true
	local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.4, 0, 0, 45); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0.5, 0, 0, 32); btn.Position = UDim2.new(1, -10, 0, 6); btn.AnchorPoint = Vector2.new(1, 0); btn.Text = ""; btn:SetAttribute("BgRole", "Main"); Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", btn):SetAttribute("StrokeRole", "Stroke")
	local valTxt = Instance.new("TextLabel", btn); valTxt.Size = UDim2.new(1, -30, 1, 0); valTxt.Position = UDim2.new(0, 10, 0, 0); valTxt.BackgroundTransparency = 1; valTxt.TextXAlignment = Enum.TextXAlignment.Left; valTxt:SetAttribute("TextRole", "Text"); valTxt:SetAttribute("BaseTextSize", 13)
	local icon = Instance.new("TextLabel", btn); icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -20, 0, 0); icon.BackgroundTransparency = 1; icon.Text = "▼"; icon:SetAttribute("TextRole", "TextDim"); icon:SetAttribute("BaseTextSize", 11)
	local list = Instance.new("Frame", row); list.Size = UDim2.new(1, -20, 0, 0); list.Position = UDim2.new(0, 10, 0, 50); list.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)
	local open = false
	local function updateSize() TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, open and (layout.AbsoluteContentSize.Y + 60) or 45)}):Play() end
	btn.MouseButton1Click:Connect(function() open = not open; icon.Text = open and "▲" or "▼"; updateSize() end)

	local DropdownAPI = {}
	function DropdownAPI:Refresh(newOptions)
		for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		if not table.find(newOptions, current) then current = newOptions[1] or "" end
		valTxt.Text = tostring(current); if callback then callback(current) end
		for _, opt in ipairs(newOptions) do
			local oBtn = Instance.new("TextButton", list); oBtn.Size = UDim2.new(1, 0, 0, 28); oBtn.Text = "  " .. opt; oBtn.TextXAlignment = Enum.TextXAlignment.Left; oBtn:SetAttribute("BgRole", "Main"); Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 6); oBtn:SetAttribute("TextRole", "Text"); oBtn:SetAttribute("BaseTextSize", 13)
			oBtn.MouseButton1Click:Connect(function() current = opt; valTxt.Text = opt; open = false; icon.Text = "▼"; updateSize(); ApplyTheme(); if callback then callback(opt) end end)
		end
		if open then updateSize() end; ApplyTheme() 
	end
	DropdownAPI:Refresh(options)
	return DropdownAPI
end

local function CreateButton(page, text, callback)
	local row = CreateRow(page, 45)
	local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = text; btn:SetAttribute("TextRole", "Accent"); btn:SetAttribute("BaseTextSize", 15)
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

local function CreateKeybind(page, text, defaultKey, callback)
	local row = CreateRow(page, 45)
	local currentKey = defaultKey
	local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0.4, 0, 0, 28); btn.Position = UDim2.new(1, -10, 0.5, -14); btn.AnchorPoint = Vector2.new(1, 0); btn:SetAttribute("BgRole", "Main"); btn.Text = currentKey.Name; btn:SetAttribute("TextRole", "Text"); btn:SetAttribute("BaseTextSize", 12); Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", btn):SetAttribute("StrokeRole", "Stroke")
	local isBinding = false
	btn.MouseButton1Click:Connect(function() isBinding = true; isBindingAny = true; btn.Text = "Press Key..."; btn:SetAttribute("TextRole", "Accent"); ApplyTheme() end)
	UIS.InputBegan:Connect(function(input)
		if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then currentKey = input.KeyCode; btn.Text = currentKey.Name; btn:SetAttribute("TextRole", "Text"); isBinding = false; task.wait(0.1); isBindingAny = false; ApplyTheme(); if callback then callback(currentKey) end end
	end)
end

-- ==========================================
-- 4. CONSTRUCTION DU HUB
-- ==========================================
local iconHome = "7733799795"; local iconVisuals = "7733779610"; local iconAim = "7733674079"
local iconPlayer = "7733954760"; local iconTeleport = "7733992829"; local iconSettings = "7733964719"

local pgHome = CreateTab("Home", iconHome)
local pgVisuals = CreateTab("Visuals", iconVisuals)
local pgAim = CreateTab("Aim", iconAim)
local pgSelf = CreateTab("Self", iconPlayer)
local pgTp = CreateTab("Teleport", iconTeleport)
local pgSettingsUI = CreateTab("Settings UI", iconSettings)
local pgSettings = CreateTab("Settings", iconSettings)

-- --- PAGE HOME ---
local secWelcome = CreateSection(pgHome, "Welcome", true)
local welcomeTxt = CreateParagraph(secWelcome, "Welcome to MxFlow Rivals.\nPrepared for tactical dominance.")

-- --- PAGE VISUALS ---
local secESP = CreateSection(pgVisuals, "Master ESP & Overlays", true)
CreateToggle(secESP, "Enable Player ESP", CurrentSettings.espEnabled, function(v) CurrentSettings.espEnabled = v; SaveSettings() end)
CreateToggle(secESP, "Show Outlines", CurrentSettings.espOutlines, function(v) CurrentSettings.espOutlines = v; SaveSettings() end)
CreateToggle(secESP, "Show Health Bar", CurrentSettings.espHealthBar, function(v) CurrentSettings.espHealthBar = v; SaveSettings() end)
CreateToggle(secESP, "Show Tracers (Target Lines)", CurrentSettings.showTracers, function(v) CurrentSettings.showTracers = v; SaveSettings() end)
CreateToggle(secESP, "Show Aimbot FOV Circle", CurrentSettings.showFovCircle, function(v) CurrentSettings.showFovCircle = v; SaveSettings() end)

local secESPColor = CreateSection(pgVisuals, "Aesthetics & Colors", true)
CreateToggle(secESPColor, "Rainbow ESP & Overlays", CurrentSettings.espRainbow, function(v) CurrentSettings.espRainbow = v; SaveSettings() end)
CreateSlider(secESPColor, "Red Color (R)", 0, 255, CurrentSettings.espR, function(v) CurrentSettings.espR = v; SaveSettings() end)
CreateSlider(secESPColor, "Green Color (G)", 0, 255, CurrentSettings.espG, function(v) CurrentSettings.espG = v; SaveSettings() end)
CreateSlider(secESPColor, "Blue Color (B)", 0, 255, CurrentSettings.espB, function(v) CurrentSettings.espB = v; SaveSettings() end)

-- --- PAGE AIM ---
local secAim = CreateSection(pgAim, "Camera Aimbot & Prediction", true)
CreateToggle(secAim, "Enable Camera Aimbot", CurrentSettings.aimbotEnabled, function(v) CurrentSettings.aimbotEnabled = v; SaveSettings() end)
CreateToggle(secAim, "Team Check (Ignore Allies)", CurrentSettings.teamCheck, function(v) CurrentSettings.teamCheck = v; SaveSettings() end)
CreateToggle(secAim, "Pro Prediction (Velocity Math)", CurrentSettings.predictionEnabled, function(v) CurrentSettings.predictionEnabled = v; SaveSettings() end)
CreateSlider(secAim, "Prediction Factor", 1, 50, CurrentSettings.predictionFactor * 100, function(v) CurrentSettings.predictionFactor = v / 100; SaveSettings() end)
CreateDropdown(secAim, "Target Part", aimTargetOptions, CurrentSettings.selectedAimPart, function(v) CurrentSettings.selectedAimPart = v; SaveSettings() end)
CreateToggle(secAim, "Wall Check (Ignore hidden players)", CurrentSettings.wallCheckEnabled, function(v) CurrentSettings.wallCheckEnabled = v; SaveSettings() end)
CreateSlider(secAim, "Smoothness (1=Snap, 50=Slow)", 1, 50, CurrentSettings.aimSmoothness, function(v) CurrentSettings.aimSmoothness = v; SaveSettings() end)
CreateSlider(secAim, "FOV Radius", 50, 500, CurrentSettings.fovRadius, function(v) CurrentSettings.fovRadius = v; SaveSettings() end)

local secTrigger = CreateSection(pgAim, "TriggerBot (Auto-Shoot)", false)
CreateToggle(secTrigger, "Enable TriggerBot", CurrentSettings.triggerBotEnabled, function(v) CurrentSettings.triggerBotEnabled = v; SaveSettings() end)
CreateToggle(secTrigger, "Rapid Fire (God-Tier Spam)", CurrentSettings.rapidFire, function(v) CurrentSettings.rapidFire = v; SaveSettings() end)
CreateSlider(secTrigger, "Miss Chance %", 0, 100, CurrentSettings.missChance, function(v) CurrentSettings.missChance = v; SaveSettings() end)

local secHitbox = CreateSection(pgAim, "Hitbox Modding", false)
CreateToggle(secHitbox, "Enable Hitbox Expander", CurrentSettings.hitboxEnabled, function(v) CurrentSettings.hitboxEnabled = v; SaveSettings() end)
CreateToggle(secHitbox, "Rainbow Hitboxes (ForceField)", CurrentSettings.rainbowHitbox, function(v) CurrentSettings.rainbowHitbox = v; SaveSettings() end)
CreateSlider(secHitbox, "Hitbox Size", 5, 50, CurrentSettings.hitboxSize, function(v) CurrentSettings.hitboxSize = v; SaveSettings() end)

-- --- PAGE SELF ---
local secPlayer = CreateSection(pgSelf, "Movement Bypass", true)
CreateToggle(secPlayer, "Enable CFrame Speed", CurrentSettings.walkSpeedEnabled, function(v) CurrentSettings.walkSpeedEnabled = v; updateSpeed(); SaveSettings() end)
CreateSlider(secPlayer, "Speed Value", 16, 150, CurrentSettings.walkSpeedValue, function(v) CurrentSettings.walkSpeedValue = v; updateSpeed(); SaveSettings() end)
CreateToggle(secPlayer, "Infinite Jump", CurrentSettings.infJumpEnabled, function(v) CurrentSettings.infJumpEnabled = v; SaveSettings() end)

local secSpin = CreateSection(pgSelf, "Anti-Aim (Spinbot)", true)
CreateToggle(secSpin, "Enable Spinbot 360", CurrentSettings.spinbotEnabled, function(v) CurrentSettings.spinbotEnabled = v; SaveSettings() end)
CreateSlider(secSpin, "Spin Speed", 10, 100, CurrentSettings.spinbotSpeed, function(v) CurrentSettings.spinbotSpeed = v; SaveSettings() end)

local secExploits = CreateSection(pgSelf, "Exploits", false)
CreateToggle(secExploits, "No Clip", CurrentSettings.noClipEnabled, function(v) CurrentSettings.noClipEnabled = v; if v then enableNoClip() else disableNoClip() end; SaveSettings() end)
CreateToggle(secExploits, "Fly Mode", CurrentSettings.flyEnabled, function(v) CurrentSettings.flyEnabled = v; toggleFly(); SaveSettings() end)
CreateSlider(secExploits, "Fly Speed", 10, 300, CurrentSettings.flySpeedValue, function(v) CurrentSettings.flySpeedValue = v; SaveSettings() end)

-- --- PAGE TELEPORT ---
local secPlayerTp = CreateSection(pgTp, "Player Teleport", true)
local function getActivePlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end
    if #list == 0 then table.insert(list, "No Players Found") end
    return list
end

local playerDropdown = CreateDropdown(secPlayerTp, "Select Player", getActivePlayers(), CurrentSettings.followTargetName, function(v) CurrentSettings.followTargetName = v; SaveSettings() end)
CreateButton(secPlayerTp, "Refresh Player List", function() playerDropdown:Refresh(getActivePlayers()) end)
CreateButton(secPlayerTp, "Teleport to Player", function()
    local target = findTargetPlayer(CurrentSettings.followTargetName)
    local char = player.Character
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)

-- --- PAGE SETTINGS UI ---
local secTheme = CreateSection(pgSettingsUI, "Theme", true)
CreateDropdown(secTheme, "Select Theme", ThemeNames, CurrentSettings.Theme, function(v) CurrentSettings.Theme = v; SaveSettings(); ApplyTheme() end)
CreateToggle(secTheme, "Rainbow UI Outline", CurrentSettings.rainbowUI, function(v) CurrentSettings.rainbowUI = v; SaveSettings() end)

local secCustom = CreateSection(pgSettingsUI, "Custom UI", true)
CreateSlider(secCustom, "Menu Size (%)", 70, 150, tonumber(CurrentSettings.MenuSize) or 100, function(v) CurrentSettings.MenuSize = v; SaveSettings(); ApplyTheme() end)
CreateSlider(secCustom, "Menu Opacity", 10, 100, CurrentSettings.Opacity * 100, function(v) CurrentSettings.Opacity = v/100; SaveSettings(); ApplyTheme() end)

-- --- PAGE SETTINGS ---
local secSystem = CreateSection(pgSettings, "System Settings", true)
CreateKeybind(secSystem, "Toggle UI Key", UIConfig.ToggleKey, function(newKey) UIConfig.ToggleKey = newKey end)
CreateButton(secSystem, "Unload Interface", function() 
	pcall(function() RunService:UnbindFromRenderStep("MxF_MasterLoop") end)
	if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end 
end)

-- Dragging Main
local dragS, dragP, startP
local topDrag = Instance.new("TextButton", mainFrame); topDrag.Size = UDim2.new(1,0,0,40); topDrag.BackgroundTransparency = 1; topDrag.Text = ""
topDrag.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; dragP = input.Position; startP = mainFrame.Position end end)
UIS.InputChanged:Connect(function(input) if dragS and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragP; mainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end end)

-- ✅ TOGGLE UI ANIMATION
UIS.InputBegan:Connect(function(input, gp) 
	if not gp and input.KeyCode == UIConfig.ToggleKey and not isBindingAny then 
		isMenuOpen = not isMenuOpen
		if isMenuOpen then
			mainFrame.Visible = true
			TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760 * currentScale, 0, 520 * currentScale)}):Play()
		else
			local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
			tw:Play(); tw.Completed:Wait(); mainFrame.Visible = false
		end
	end 
end)

-- INIT
ApplyTheme()
if tabFunctions["Home"] then tabFunctions["Home"]() end
print("MxFlow Menu V1.0.0.15 (Aim Fix Update) Loaded Successfully!")
