-- ======================================================
-- 👑 MxF HUB - DESIGN "ALCHEMY STYLE"
-- Dropdowns, Smart TP, Custom UI, Color Picker
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

if targetGui:FindFirstChild("MxFHub") then targetGui.MxFHub:Destroy() end

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
local autoFarmMob, autoFarmBoss, killauraEnabled, targetPlayers = false, false, false, false

local combatCooldown, combatRadius = 0.1, 500
local mobHeight, bossHeight = 8, 8
local tweenSpeed = 150
local combatCoroutine, currentTarget = nil, nil
local noClipEnabled, flyEnabled, FLY_SPEED = false, false, 50
local noClipConnection, flyConnection, bodyVelocity, bodyGyro

-- ==========================================
-- 2. LOGIQUE DE CHEAT (SMART TP & COMBAT)
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
	local closest, minDist = nil, combatRadius
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = char.HumanoidRootPart.Position

	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for _, obj in ipairs(npcsFolder:GetDescendants()) do
			if obj:IsA("Model") and not string.find(string.lower(obj.Name), "quest") then
				local match = isSpecific and string.find(obj.Name, targetName) or true
				if match and isSpecific and targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
				if match then
					local hum = obj:FindFirstChild("Humanoid")
					local root = obj:FindFirstChild("HumanoidRootPart")
					if hum and hum.Health > 0 and root then
						local dist = (root.Position - myPos).Magnitude
						if dist <= minDist then minDist = dist; closest = obj end
					end
				end
			end
		end
	end

	if targetPlayers and not isSpecific then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local hum = p.Character:FindFirstChild("Humanoid")
				local root = p.Character:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and root then
					local dist = (root.Position - myPos).Magnitude
					if dist <= minDist then minDist = dist; closest = p.Character end
				end
			end
		end
	end
	return closest
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
					local currentHeight = autoFarmMob and mobHeight or bossHeight
					local target = getTarget(tName, true)
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, currentHeight, 0)
						local dist = (myRoot.Position - tpPos).Magnitude
						
						if dist > 15 then
							local tTime = math.clamp(dist / tweenSpeed, 0.05, 3)
							TweenService:Create(myRoot, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)}):Play()
						else
							myRoot.CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)
							pcall(function() remote:FireServer() end)
						end
					end
				elseif killauraEnabled then
					if not flyEnabled then myHum.PlatformStand = false end
					if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
						currentTarget = getTarget(nil, false)
					end
					if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
						local lPos = Vector3.new(currentTarget.HumanoidRootPart.Position.X, myRoot.Position.Y, currentTarget.HumanoidRootPart.Position.Z)
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
	if noClipEnabled then enableNoClip() end
	if flyEnabled then enableFly() end
	if autoFarmMob or autoFarmBoss or killauraEnabled then startCombatLoop() end
end)


-- ==========================================
-- 3. MOTEUR UI "ALCHEMY / MXF STYLE"
-- ==========================================
local UI = {
	Accent = Color3.fromRGB(0, 255, 150), -- Vert Menthe "Alchemy"
	ToggleKey = Enum.KeyCode.RightShift,
	ThemeElements = {}
}

local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHub"
screenGui.ResetOnSpawn = false

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 780, 0, 520)
mainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(45, 45, 45)

-- TOP BAR (Ligne accentuée + Logo)
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
topBar.BorderSizePixel = 0

local topBorder = Instance.new("Frame", topBar)
topBorder.Size = UDim2.new(1, 0, 0, 2); topBorder.Position = UDim2.new(0, 0, 1, -2)
topBorder.BackgroundColor3 = UI.Accent; topBorder.BorderSizePixel = 0
table.insert(UI.ThemeElements, {obj = topBorder, prop = "BackgroundColor3"})

local logoIcon = Instance.new("ImageLabel", topBar)
logoIcon.Size = UDim2.new(0, 30, 0, 30); logoIcon.Position = UDim2.new(0, 15, 0, 10)
logoIcon.BackgroundTransparency = 1; logoIcon.ScaleType = Enum.ScaleType.Fit
-- Intégration du Logo MxF
pcall(function()
	local githubRawUrl = "LIEN_RAW_GITHUB_ICI" -- METS TON LIEN RAW ICI
	if githubRawUrl ~= "LIEN_RAW_GITHUB_ICI" and writefile then
		local imgData = game:HttpGet(githubRawUrl)
		writefile("mxf.png", imgData)
		logoIcon.Image = getcustomasset("mxf.png")
	else
		logoIcon.Image = "rbxassetid://6026568227" -- Icone de base si fail
	end
end)

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(0, 200, 1, 0); titleLbl.Position = UDim2.new(0, 55, 0, -2)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "MxF HUB"; titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 16; titleLbl.TextXAlignment = Enum.TextXAlignment.Left

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
sidebar.Size = UDim2.new(0, 200, 1, -50); sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(26, 26, 26); sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 0
local sidebarLayout = Instance.new("UIListLayout", sidebar)

local sideSeparator = Instance.new("Frame", mainFrame)
sideSeparator.Size = UDim2.new(0, 1, 1, -50); sideSeparator.Position = UDim2.new(0, 200, 0, 50)
sideSeparator.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sideSeparator.BorderSizePixel = 0

-- CONTENT AREA
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -201, 1, -50); contentArea.Position = UDim2.new(0, 201, 0, 50)
contentArea.BackgroundTransparency = 1

local Pages = {}
local activeTabBtn = nil

local function CreateTab(title, subtitle)
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1, 0, 0, 55); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.BackgroundTransparency = 1; btn.Text = ""

	local txtTitle = Instance.new("TextLabel", btn)
	txtTitle.Size = UDim2.new(1, -20, 0, 20); txtTitle.Position = UDim2.new(0, 15, 0, 10); txtTitle.BackgroundTransparency = 1
	txtTitle.Text = title; txtTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	txtTitle.Font = Enum.Font.GothamBold; txtTitle.TextSize = 13; txtTitle.TextXAlignment = Enum.TextXAlignment.Left

	local txtSub = Instance.new("TextLabel", btn)
	txtSub.Size = UDim2.new(1, -20, 0, 15); txtSub.Position = UDim2.new(0, 15, 0, 30); txtSub.BackgroundTransparency = 1
	txtSub.Text = subtitle; txtSub.TextColor3 = Color3.fromRGB(120, 120, 120)
	txtSub.Font = Enum.Font.Gotham; txtSub.TextSize = 11; txtSub.TextXAlignment = Enum.TextXAlignment.Left

	local page = Instance.new("ScrollingFrame", contentArea)
	page.Size = UDim2.new(1, -20, 1, -20); page.Position = UDim2.new(0, 10, 0, 10)
	page.BackgroundTransparency = 1; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
	page.Visible = false
	
	-- Layout Masonry (2 Colonnes)
	local leftCol = Instance.new("Frame", page); leftCol.Size = UDim2.new(0.485, 0, 1, 0); leftCol.BackgroundTransparency = 1
	local leftLayout = Instance.new("UIListLayout", leftCol); leftLayout.Padding = UDim.new(0, 10)
	local rightCol = Instance.new("Frame", page); rightCol.Size = UDim2.new(0.485, 0, 1, 0); rightCol.Position = UDim2.new(0.515, 0, 0, 0); rightCol.BackgroundTransparency = 1
	local rightLayout = Instance.new("UIListLayout", rightCol); rightLayout.Padding = UDim.new(0, 10)

	local function updateScroll() page.CanvasSize = UDim2.new(0, 0, 0, math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y) + 20) end
	leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
	rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)

	Pages[title] = page

	btn.MouseButton1Click:Connect(function()
		for n, p in pairs(Pages) do p.Visible = (n == title) end
		if activeTabBtn then TweenService:Create(activeTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
		activeTabBtn = btn
	end)

	return leftCol, rightCol, btn
end

local function CreatePanel(parent, titleText)
	local panel = Instance.new("Frame", parent)
	panel.Size = UDim2.new(1, 0, 0, 40); panel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", panel).Color = Color3.fromRGB(45, 45, 45)

	local title = Instance.new("TextLabel", panel)
	title.Size = UDim2.new(1, -20, 0, 30); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1
	title.Text = titleText; title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left

	local sep = Instance.new("Frame", panel)
	sep.Size = UDim2.new(1, 0, 0, 1); sep.Position = UDim2.new(0, 0, 0, 30); sep.BackgroundColor3 = UI.Accent; sep.BorderSizePixel = 0
	table.insert(UI.ThemeElements, {obj = sep, prop = "BackgroundColor3"})

	local content = Instance.new("Frame", panel)
	content.Size = UDim2.new(1, -20, 1, -40); content.Position = UDim2.new(0, 10, 0, 35); content.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 8)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() panel.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 45) end)
	return content
end

-- COMPOSANTS DU PANEL
local function CreateCheckbox(panel, text, default, callback)
	local state = default or false
	local frame = Instance.new("TextButton", panel)
	frame.Size = UDim2.new(1, 0, 0, 25); frame.BackgroundTransparency = 1; frame.Text = ""

	local box = Instance.new("Frame", frame)
	box.Size = UDim2.new(0, 16, 0, 16); box.Position = UDim2.new(0, 0, 0.5, -8)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame", box)
	fill.Size = UDim2.new(1, -4, 1, -4); fill.Position = UDim2.new(0, 2, 0, 2)
	fill.BackgroundColor3 = UI.Accent; fill.BackgroundTransparency = state and 0 or 1
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
	table.insert(UI.ThemeElements, {obj = fill, prop = "BackgroundColor3"})

	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -25, 1, 0); lbl.Position = UDim2.new(0, 25, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

	frame.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(fill, TweenInfo.new(0.15), {BackgroundTransparency = state and 0 or 1}):Play()
		TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)}):Play()
		if callback then callback(state) end
	end)
end

local function CreateSlider(panel, text, min, max, default, callback)
	local value = default
	local frame = Instance.new("Frame", panel)
	frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(0.5, 0, 0, 15); lbl.Position = UDim2.new(0, 0, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local valLbl = Instance.new("TextLabel", frame)
	valLbl.Size = UDim2.new(0.5, 0, 0, 15); valLbl.Position = UDim2.new(0.5, 0, 0, 0); valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(value); valLbl.TextColor3 = UI.Accent
	valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12; valLbl.TextXAlignment = Enum.TextXAlignment.Right
	table.insert(UI.ThemeElements, {obj = valLbl, prop = "TextColor3"})

	local bg = Instance.new("TextButton", frame)
	bg.Size = UDim2.new(1, 0, 0, 6); bg.Position = UDim2.new(0, 0, 0, 22)
	bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bg.Text = ""; Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = UI.Accent
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	table.insert(UI.ThemeElements, {obj = fill, prop = "BackgroundColor3"})

	local dragging = false
	bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			value = math.floor(min + ((max - min) * pos))
			fill.Size = UDim2.new(pos, 0, 1, 0); valLbl.Text = tostring(value)
			if callback then callback(value) end
		end
	end)
end

-- VRAI DROPDOWN EXTENSIBLE
local function CreateDropdown(panel, text, options, default, callback)
	local current = default or options[1]
	local container = Instance.new("Frame", panel)
	container.Size = UDim2.new(1, 0, 0, 50); container.BackgroundTransparency = 1; container.ClipsDescendants = true

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, 0, 0, 15); lbl.Position = UDim2.new(0, 0, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1, 0, 0, 30); btn.Position = UDim2.new(0, 0, 0, 20)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local selectedTxt = Instance.new("TextLabel", btn)
	selectedTxt.Size = UDim2.new(1, -30, 1, 0); selectedTxt.Position = UDim2.new(0, 10, 0, 0); selectedTxt.BackgroundTransparency = 1
	selectedTxt.Text = tostring(current); selectedTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectedTxt.Font = Enum.Font.Gotham; selectedTxt.TextSize = 12; selectedTxt.TextXAlignment = Enum.TextXAlignment.Left

	local arrow = Instance.new("TextLabel", btn)
	arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -20, 0, 0); arrow.BackgroundTransparency = 1
	arrow.Text = "▼"; arrow.TextColor3 = Color3.fromRGB(200, 200, 200); arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 12

	local listFrame = Instance.new("Frame", container)
	listFrame.Size = UDim2.new(1, 0, 0, 0); listFrame.Position = UDim2.new(0, 0, 0, 55); listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
	local listLayout = Instance.new("UIListLayout", listFrame)
	
	local isOpen = false
	btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		arrow.Text = isOpen and "▲" or "▼"
		local targetHeight = isOpen and (listLayout.AbsoluteContentSize.Y + 60) or 50
		TweenService:Create(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
		TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and listLayout.AbsoluteContentSize.Y or 0)}):Play()
	end)

	for _, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton", listFrame)
		optBtn.Size = UDim2.new(1, 0, 0, 25); optBtn.BackgroundTransparency = 1
		optBtn.Text = "  " .. tostring(opt); optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 12; optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.MouseButton1Click:Connect(function()
			current = opt; selectedTxt.Text = tostring(opt)
			isOpen = false; arrow.Text = "▼"
			TweenService:Create(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 50)}):Play()
			TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
			if callback then callback(opt) end
		end)
	end
end

local function CreateColorPicker(panel, text)
	local container = Instance.new("Frame", panel)
	container.Size = UDim2.new(1, 0, 0, 45); container.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.new(0, 0, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local hueBar = Instance.new("TextButton", container)
	hueBar.Size = UDim2.new(1, 0, 0, 15); hueBar.Position = UDim2.new(0, 0, 0, 25); hueBar.Text = ""
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)
	
	local gradient = Instance.new("UIGradient", hueBar)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})

	local cursor = Instance.new("Frame", hueBar)
	cursor.Size = UDim2.new(0, 4, 1, 4); cursor.Position = UDim2.new(0.5, -2, 0, -2)
	cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", cursor).Color = Color3.fromRGB(0,0,0)

	local dragging = false
	local function updateColor(input)
		local relativeX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		cursor.Position = UDim2.new(relativeX, -2, 0, -2)
		local newColor = Color3.fromHSV(relativeX, 1, 1)
		
		UI.Accent = newColor
		for _, item in ipairs(UI.ThemeElements) do TweenService:Create(item.obj, TweenInfo.new(0.3), {[item.prop] = newColor}):Play() end
	end

	hueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateColor(input) end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateColor(input) end end)
end

-- ==========================================
-- 4. REMPLISSAGE DU MENU
-- ==========================================

-- --- ONGLET FARMING ---
local farmL, farmR, btnFarm = CreateTab("General", "Auto Farming and more")

local farmPanel = CreatePanel(farmL, "Farming")
CreateDropdown(farmPanel, "Select Monster", MobNames, selectedMob, function(v) selectedMob = v end)
CreateCheckbox(farmPanel, "Auto Farm Monster", false, function(v) 
	autoFarmMob = v
	if v then 
		autoFarmBoss, killauraEnabled = false, false
		if not isMobRendered(selectedMob) then teleportToIsland(MobDatabase[selectedMob]); task.wait(2.5) end
		startCombatLoop() 
	end 
end)

local bossPanel = CreatePanel(farmL, "All Boss")
CreateDropdown(bossPanel, "Select Boss", BossNames, selectedBoss, function(v) selectedBoss = v end)
CreateCheckbox(bossPanel, "Auto Farm Boss", false, function(v) 
	autoFarmBoss = v
	if v then 
		autoFarmMob, killauraEnabled = false, false
		if not isMobRendered(selectedBoss) then teleportToIsland(BossDatabase[selectedBoss]); task.wait(2.5) end
		startCombatLoop() 
	end 
end)

local settingsPanel = CreatePanel(farmR, "Farm Settings")
CreateSlider(settingsPanel, "Tween Speed (Approche)", 50, 500, 150, function(v) tweenSpeed = v end)
CreateSlider(settingsPanel, "Distance From Mob (Height)", 0, 20, 8, function(v) mobHeight = v end)
CreateSlider(settingsPanel, "Distance From Boss (Height)", 0, 20, 8, function(v) bossHeight = v end)

local auraPanel = CreatePanel(farmR, "Aura")
CreateCheckbox(auraPanel, "Damage Aura (KillAura)", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss = false, false; startCombatLoop() end end)
CreateSlider(auraPanel, "Damage Range", 10, 1500, 500, function(v) combatRadius = v end)
CreateSlider(auraPanel, "Attack Speed (x100ms)", 1, 100, 10, function(v) combatCooldown = v/100 end)


-- --- ONGLET MOVEMENT ---
local moveL, moveR = CreateTab("Player", "Movement and Exploits")
local exploitPanel = CreatePanel(moveL, "Local Player")
CreateCheckbox(exploitPanel, "NoClip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)
CreateCheckbox(exploitPanel, "Fly Mode", false, function(v) flyEnabled = v; if v then enableFly() else disableFly() end end)
CreateSlider(exploitPanel, "Fly Speed", 10, 200, 50, function(v) FLY_SPEED = v end)


-- --- ONGLET TELEPORT ---
local tpL, tpR = CreateTab("Teleport", "Fast Travel")
local islandPanel = CreatePanel(tpL, "Islands")
CreateDropdown(islandPanel, "Select Island", IslandNames, selectedIsland, function(v) selectedIsland = v end)
local tpBtn = Instance.new("TextButton", islandPanel)
tpBtn.Size = UDim2.new(1, 0, 0, 30); tpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpBtn.Text = "Teleport"; tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamMedium; tpBtn.TextSize = 13; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
tpBtn.MouseButton1Click:Connect(function() teleportToIsland(selectedIsland) end)


-- --- ONGLET CONFIGS ---
local cfgL, cfgR = CreateTab("Configs", "Menu Customization")
local uiPanel = CreatePanel(cfgL, "UI Settings")
CreateSlider(uiPanel, "Menu Opacity", 10, 100, 100, function(v) mainFrame.BackgroundTransparency = 1 - (v/100) end)
CreateColorPicker(uiPanel, "Theme Color")

local bindPanel = CreatePanel(cfgR, "Keybinds")
local bindBtn = Instance.new("TextButton", bindPanel)
bindBtn.Size = UDim2.new(1, 0, 0, 30); bindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bindBtn.Text = "Toggle UI : " .. UI.ToggleKey.Name; bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bindBtn.Font = Enum.Font.GothamMedium; bindBtn.TextSize = 13; Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
local isBinding = false
bindBtn.MouseButton1Click:Connect(function() isBinding = true; bindBtn.Text = "Press Key..." end)
UIS.InputBegan:Connect(function(input)
	if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
		UI.ToggleKey = input.KeyCode; bindBtn.Text = "Toggle UI : " .. UI.ToggleKey.Name; isBinding = false
	end
end)

-- Lancement initial
btnFarm.MouseButton1Click:Fire()
print("MxF Hub Chargé avec succès.")
