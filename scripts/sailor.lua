-- ======================================================
-- 👑 MxF HUB - "SPEED HUB X" STYLE
-- Modern UI, iOS Toggles, Infinite Jump, Auto-Farm
-- ======================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("MxFHubSpeed") then targetGui.MxFHubSpeed:Destroy() end

-- ==========================================
-- 1. BASE DE DONNÉES & VARIABLES CHEATS
-- ==========================================
local MobDatabase = {
	["AcademyTeacher"] = "Academy", ["Arena Fighter"] = "Lawless", ["Curse"] = "Shinjuku",
	["DesertBandit"] = "Desert", ["FrostRogue"] = "Snow", ["Hollow"] = "HollowIsland",
	["Monkey"] = "Jungle", ["Ninja"] = "Ninja", ["Quincy"] = "SoulDominion",
	["Slime"] = "Slime", ["Sorcerer"] = "Shibuya", ["StrongSorcerer"] = "Shinjuku",
	["Swordsman"] = "Judgement", ["Thief"] = "Starter"
}
local BossDatabase = {
	["YujiBoss"] = "Shibuya", ["SukunaBoss"] = "Shibuya", ["GojoBoss"] = "Shibuya",
	["StrongestShinobiBoss"] = "Ninja", ["AizenBoss"] = "HollowIsland", ["YamatoBoss"] = "Judgement",
	["ThiefBoss"] = "Starter"
}

local MobNames, BossNames, IslandNames = {}, {}, {}
for m, i in pairs(MobDatabase) do table.insert(MobNames, m); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
for b, i in pairs(BossDatabase) do table.insert(BossNames, b); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
table.sort(MobNames); table.sort(BossNames); table.sort(IslandNames)

local selectedMob, selectedBoss, selectedIsland = MobNames[1], BossNames[1], IslandNames[1]
local autoFarmMob, autoFarmBoss, killauraEnabled = false, false, false

local combatCooldown, combatRadius = 0.1, 500
local mobHeight, tweenSpeed = 8, 150
local combatCoroutine = nil

-- Variables Player (Self)
local noClipEnabled, flyEnabled, infJumpEnabled = false, false, false
local walkSpeedEnabled = false
local walkSpeedValue = 50
local FLY_SPEED = 50
local noClipConnection, flyConnection, speedConnection, jumpConnection
local bodyVelocity, bodyGyro

-- ==========================================
-- 2. LOGIQUE DE CHEAT (BACK-END)
-- ==========================================
local function teleportToIsland(islandName)
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
end

local function isMobRendered(targetName)
	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for _, obj in ipairs(npcsFolder:GetDescendants()) do
			if obj:IsA("Model") then
				local match = string.find(obj.Name, targetName)
				if match and targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
				if match and obj:FindFirstChild("HumanoidRootPart") then return true end
			end
		end
	end
	return false
end

local function getTarget(targetName, isSpecific)
	local closest, minDist = nil, math.huge
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, minDist end
	local myPos = char.HumanoidRootPart.Position

	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for _, obj in ipairs(npcsFolder:GetDescendants()) do
			if obj:IsA("Model") and not string.find(string.lower(obj.Name), "quest") then
				local match = true
				if isSpecific then
					if string.find(obj.Name, targetName) then
						if targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
					else match = false end
				end

				if match then
					local hum = obj:FindFirstChild("Humanoid")
					local root = obj:FindFirstChild("HumanoidRootPart")
					if hum and hum.Health > 0 and root then
						local dist = (root.Position - myPos).Magnitude
						if not isSpecific and dist > combatRadius then continue end
						if dist < minDist then minDist = dist; closest = obj end
					end
				end
			end
		end
	end
	return closest, minDist
end

local function startCombatLoop()
	if combatCoroutine then task.cancel(combatCoroutine) end
	combatCoroutine = task.spawn(function()
		local remote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
		while autoFarmMob or autoFarmBoss or killauraEnabled do
			local myChar = player.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChild("Humanoid")
			
			if myRoot and myHum then
				if autoFarmMob or autoFarmBoss then
					myHum.PlatformStand = true
					myRoot.Velocity, myRoot.RotVelocity = Vector3.zero, Vector3.zero
					
					local tName = autoFarmMob and selectedMob or selectedBoss
					local targetIsland = autoFarmMob and MobDatabase[selectedMob] or BossDatabase[selectedBoss]
					local target, distance = getTarget(tName, true)
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						if distance > 1500 then
							teleportToIsland(targetIsland); task.wait(2.5)
						else
							local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, mobHeight, 0)
							if distance > 15 then
								local tTime = math.clamp(distance / tweenSpeed, 0.05, 3)
								TweenService:Create(myRoot, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)}):Play()
							else
								myRoot.CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)
								pcall(function() remote:FireServer() end)
							end
						end
					else
						teleportToIsland(targetIsland); task.wait(2.5)
					end

				elseif killauraEnabled then
					if not flyEnabled then myHum.PlatformStand = false end
					local target, _ = getTarget(nil, false)
					if target and target:FindFirstChild("HumanoidRootPart") then
						local lPos = Vector3.new(target.HumanoidRootPart.Position.X, myRoot.Position.Y, target.HumanoidRootPart.Position.Z)
						myRoot.CFrame = CFrame.lookAt(myRoot.Position, lPos)
						pcall(function() remote:FireServer() end)
					end
				end
			end
			task.wait(combatCooldown)
		end
		local c = player.Character
		if c and c:FindFirstChild("Humanoid") and not flyEnabled then c.Humanoid.PlatformStand = false end
	end)
end

-- Mouvements (Self)
local function updateWalkSpeed()
	if speedConnection then speedConnection:Disconnect() end
	if walkSpeedEnabled then
		speedConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = walkSpeedValue
			end
		end)
	else
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
	end
end

jumpConnection = UIS.JumpRequest:Connect(function()
	if infJumpEnabled then
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

local function enableNoClip()
	if noClipConnection then noClipConnection:Disconnect() end
	noClipConnection = RunService.Stepped:Connect(function()
		if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
	end)
end
local function disableNoClip()
	if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
	if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

local function enableFly()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	char.Humanoid.PlatformStand = true
	bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart); bodyVelocity.Velocity = Vector3.zero; bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart); bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bodyGyro.D = 50
	flyConnection = RunService.RenderStepped:Connect(function()
		local dir, cf = Vector3.zero, camera.CFrame
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then dir = dir.Unit end
		bodyVelocity.Velocity = dir * FLY_SPEED; bodyGyro.CFrame = cf
	end)
end
local function disableFly()
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

player.CharacterAdded:Connect(function()
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	task.wait(0.5)
	if walkSpeedEnabled then updateWalkSpeed() end
	if noClipEnabled then enableNoClip() end
	if flyEnabled then enableFly() end
	if autoFarmMob or autoFarmBoss or killauraEnabled then startCombatLoop() end
end)


-- ==========================================
-- 3. MOTEUR UI "SPEED HUB X STYLE"
-- ==========================================
local UI = {
	Accent = Color3.fromRGB(255, 255, 255), -- Boutons actifs en blanc comme Speed Hub
	ToggleKey = Enum.KeyCode.RightShift,
	ThemeElements = {}
}

local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubSpeed"
screenGui.ResetOnSpawn = false

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 680, 0, 420)
mainFrame.Position = UDim2.new(0.5, -340, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 16) -- Dark pur
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(30, 30, 35)

-- TOP BAR (Invisible, juste pour drag)
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundTransparency = 1

local titleTop = Instance.new("TextLabel", topBar)
titleTop.Size = UDim2.new(1, -20, 1, 0); titleTop.Position = UDim2.new(0, 15, 0, 0)
titleTop.BackgroundTransparency = 1; titleTop.Text = "MxF Hub | Version 1.0.0"
titleTop.TextColor3 = Color3.fromRGB(100, 100, 110); titleTop.Font = Enum.Font.GothamMedium; titleTop.TextSize = 11; titleTop.TextXAlignment = Enum.TextXAlignment.Left

-- DRAG
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = mainFrame.Position end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == UI.ToggleKey then mainFrame.Visible = not mainFrame.Visible end end)

-- SIDEBAR
local sidebar = Instance.new("ScrollingFrame", mainFrame)
sidebar.Size = UDim2.new(0, 170, 1, -35); sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundTransparency = 1; sidebar.ScrollBarThickness = 0
local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 8); sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- CONTENT AREA
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -180, 1, -35); contentArea.Position = UDim2.new(0, 175, 0, 35)
contentArea.BackgroundTransparency = 1

local pageTitle = Instance.new("TextLabel", contentArea)
pageTitle.Size = UDim2.new(1, 0, 0, 40); pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Home"; pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
pageTitle.Font = Enum.Font.GothamBold; pageTitle.TextSize = 22; pageTitle.TextXAlignment = Enum.TextXAlignment.Left

local Pages = {}
local activeTabBtn = nil

local function CreateTab(icon, title)
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(28, 29, 33)
	btn.BackgroundTransparency = 1; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local txtIcon = Instance.new("TextLabel", btn)
	txtIcon.Size = UDim2.new(0, 30, 1, 0); txtIcon.Position = UDim2.new(0, 5, 0, 0)
	txtIcon.BackgroundTransparency = 1; txtIcon.Text = icon; txtIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	txtIcon.Font = Enum.Font.GothamBold; txtIcon.TextSize = 14

	local txtTitle = Instance.new("TextLabel", btn)
	txtTitle.Size = UDim2.new(1, -40, 1, 0); txtTitle.Position = UDim2.new(0, 35, 0, 0)
	txtTitle.BackgroundTransparency = 1; txtTitle.Text = title; txtTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	txtTitle.Font = Enum.Font.GothamBold; txtTitle.TextSize = 13; txtTitle.TextXAlignment = Enum.TextXAlignment.Left

	local page = Instance.new("ScrollingFrame", contentArea)
	page.Size = UDim2.new(1, -15, 1, -50); page.Position = UDim2.new(0, 0, 0, 50)
	page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Color3.fromRGB(40,40,45)
	page.Visible = false
	
	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 6)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20) end)

	Pages[title] = page

	btn.MouseButton1Click:Connect(function()
		for n, p in pairs(Pages) do p.Visible = (n == title) end
		if activeTabBtn then 
			TweenService:Create(activeTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() 
			activeTabBtn.txt.TextColor3 = Color3.fromRGB(200,200,200)
		end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
		txtTitle.TextColor3 = Color3.fromRGB(255,255,255)
		activeTabBtn = {btn = btn, txt = txtTitle}
		pageTitle.Text = title
	end)

	return page
end

-- ==========================================
-- COMPOSANTS UI "SPEED HUB X" (LIGNES)
-- ==========================================
local function CreateRow(parent)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 45); row.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", row).Color = Color3.fromRGB(35, 36, 40)
	return row
end

-- TOGGLE STYLE iOS
local function CreateToggle(page, text, default, callback)
	local state = default or false
	local row = CreateRow(page)

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""

	local pill = Instance.new("Frame", row)
	pill.Size = UDim2.new(0, 36, 0, 20); pill.Position = UDim2.new(1, -50, 0.5, -10)
	pill.BackgroundColor3 = state and UI.Accent or Color3.fromRGB(45, 46, 50)
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
	table.insert(UI.ThemeElements, {obj = pill, isToggle = true, state = state})

	local circle = Instance.new("Frame", pill)
	circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		state = not state
		local targetColor = state and UI.Accent or Color3.fromRGB(45, 46, 50)
		local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
		for _, v in ipairs(UI.ThemeElements) do if v.obj == pill then v.state = state end end
		if callback then callback(state) end
	end)
end

-- TEXT INPUT (Pour le WalkSpeed par exemple)
local function CreateInput(page, text, placeholder, default, callback)
	local row = CreateRow(page)

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.4, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local inputBg = Instance.new("Frame", row)
	inputBg.Size = UDim2.new(0.5, 0, 0, 30); inputBg.Position = UDim2.new(1, -15, 0.5, -15); inputBg.AnchorPoint = Vector2.new(1, 0)
	inputBg.BackgroundColor3 = Color3.fromRGB(15, 16, 19); Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", inputBg).Color = Color3.fromRGB(35, 36, 40)

	local box = Instance.new("TextBox", inputBg)
	box.Size = UDim2.new(1, -10, 1, 0); box.Position = UDim2.new(0, 5, 0, 0); box.BackgroundTransparency = 1
	box.Text = tostring(default); box.PlaceholderText = placeholder; box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham; box.TextSize = 12

	box.FocusLost:Connect(function()
		if callback then callback(box.Text) end
	end)
end

-- DROPDOWN
local function CreateDropdown(page, text, options, default, callback)
	local current = default or options[1]
	local row = CreateRow(page)
	row.ClipsDescendants = true
	row.Size = UDim2.new(1, 0, 0, 45)

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 0, 45); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.4, 0, 0, 30); btn.Position = UDim2.new(1, -15, 0, 7); btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(15, 16, 19); btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", btn).Color = Color3.fromRGB(35, 36, 40)

	local valTxt = Instance.new("TextLabel", btn)
	valTxt.Size = UDim2.new(1, -25, 1, 0); valTxt.Position = UDim2.new(0, 10, 0, 0); valTxt.BackgroundTransparency = 1
	valTxt.Text = tostring(current); valTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
	valTxt.Font = Enum.Font.Gotham; valTxt.TextSize = 12; valTxt.TextXAlignment = Enum.TextXAlignment.Left

	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -20, 0, 0); icon.BackgroundTransparency = 1
	icon.Text = "▼"; icon.TextColor3 = Color3.fromRGB(150, 150, 150); icon.Font = Enum.Font.GothamBold; icon.TextSize = 10

	local list = Instance.new("Frame", row)
	list.Size = UDim2.new(1, -30, 0, 0); list.Position = UDim2.new(0, 15, 0, 45); list.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)

	local isOpen = false
	btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		icon.Text = isOpen and "▲" or "▼"
		local targetSize = isOpen and (layout.AbsoluteContentSize.Y + 55) or 45
		TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetSize)}):Play()
	end)

	for _, opt in ipairs(options) do
		local oBtn = Instance.new("TextButton", list)
		oBtn.Size = UDim2.new(1, 0, 0, 25); oBtn.BackgroundColor3 = Color3.fromRGB(28, 29, 33)
		oBtn.Text = "  " .. tostring(opt); oBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		oBtn.Font = Enum.Font.Gotham; oBtn.TextSize = 12; oBtn.TextXAlignment = Enum.TextXAlignment.Left
		Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 4)

		oBtn.MouseButton1Click:Connect(function()
			current = opt; valTxt.Text = tostring(opt)
			isOpen = false; icon.Text = "▼"
			TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)}):Play()
			if callback then callback(opt) end
		end)
	end
end

-- BOUTON SIMPLE
local function CreateButton(page, text, callback)
	local row = CreateRow(page)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
	btn.Text = text; btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- ==========================================
-- 4. REMPLISSAGE DU MENU
-- ==========================================

local tabCombat = CreateTab("⚔️", "Combat")
local tabSelf = CreateTab("👤", "Self")
local tabTp = CreateTab("🗺️", "Teleport")
local tabSettings = CreateTab("⚙️", "Settings")

-- --- ONGLET COMBAT ---
CreateDropdown(tabCombat, "Select Monster", MobNames, selectedMob, function(v) selectedMob = v end)
CreateToggle(tabCombat, "Auto Farm Monster", false, function(v) 
	autoFarmMob = v
	if v then autoFarmBoss, killauraEnabled = false, false; if not isMobRendered(selectedMob) then teleportToIsland(MobDatabase[selectedMob]); task.wait(2.5) end; startCombatLoop() end 
end)

CreateDropdown(tabCombat, "Select Boss", BossNames, selectedBoss, function(v) selectedBoss = v end)
CreateToggle(tabCombat, "Auto Farm Boss", false, function(v) 
	autoFarmBoss = v
	if v then autoFarmMob, killauraEnabled = false, false; if not isMobRendered(selectedBoss) then teleportToIsland(BossDatabase[selectedBoss]); task.wait(2.5) end; startCombatLoop() end 
end)

CreateToggle(tabCombat, "KillAura (Stand)", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss = false, false; startCombatLoop() end end)


-- --- ONGLET SELF (NOUVEAUTÉS) ---
CreateInput(tabSelf, "Set Speed", "Enter WalkSpeed", walkSpeedValue, function(val)
	local num = tonumber(val)
	if num then walkSpeedValue = num; updateWalkSpeed() end
end)
CreateToggle(tabSelf, "Enable Walkspeed", false, function(v) walkSpeedEnabled = v; updateWalkSpeed() end)

CreateToggle(tabSelf, "Infinite Jump", false, function(v) infJumpEnabled = v end)
CreateToggle(tabSelf, "No Clip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)
CreateToggle(tabSelf, "Fly Mode", false, function(v) flyEnabled = v; if v then enableFly() else disableFly() end end)


-- --- ONGLET TELEPORT ---
CreateDropdown(tabTp, "Select Island", IslandNames, selectedIsland, function(v) selectedIsland = v end)
CreateButton(tabTp, "Teleport to Island", function() teleportToIsland(selectedIsland) end)


-- --- ONGLET SETTINGS ---
CreateInput(tabSettings, "Menu Keybind", "Key Name", UI.ToggleKey.Name, function(val)
	-- Trouve la touche via le nom entré (ex: Insert, F3, RightShift)
	pcall(function()
		local key = Enum.KeyCode[val]
		if key then UI.ToggleKey = key end
	end)
end)

CreateButton(tabSettings, "Unload Menu", function()
	if targetGui:FindFirstChild("MxFHubSpeed") then targetGui.MxFHubSpeed:Destroy() end
end)


-- Init du premier onglet
for _, c in ipairs(sidebar:GetChildren()) do
	if c:IsA("TextButton") then
		c.BackgroundTransparency = 0
		c:GetChildren()[2].TextColor3 = Color3.fromRGB(255,255,255)
		activeTabBtn = {btn = c, txt = c:GetChildren()[2]}
		break
	end
end
Pages["Combat"].Visible = true
pageTitle.Text = "Combat"

print("MxF Hub SpeedX Edition Chargé !")
