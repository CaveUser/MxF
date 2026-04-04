-- ======================================================
-- MENU UI ELITE PRO - DESIGN PREMIUM & LOGO CUSTOM
-- Checkboxes, Color Picker RGB, Auto-Farm, etc.
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

-- Variables d'état UI
local isVisible = true
local currentKeybind = Enum.KeyCode.Insert
local accentColor = Color3.fromRGB(110, 160, 255)
local isBinding = false
local themeObjects = {}

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
	["StrongestShinobiBoss"] = "Ninja", ["AizenBoss"] = "HollowIsland", ["YamatoBoss"] = "Judgement"
}

local MobNames, BossNames, IslandNames = {}, {}, {}
for m, i in pairs(MobDatabase) do table.insert(MobNames, m); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
for b, i in pairs(BossDatabase) do table.insert(BossNames, b); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
table.sort(MobNames); table.sort(BossNames); table.sort(IslandNames)

local selectedMob, selectedBoss, selectedIsland = MobNames[1], BossNames[1], IslandNames[1]
local autoFarmMob, autoFarmBoss, killauraEnabled, targetPlayers = false, false, false, false
local combatCooldown, combatRadius = 0.1, 500
local combatCoroutine, currentTarget = nil, nil
local noClipEnabled, flyEnabled, FLY_SPEED = false, false, 50
local noClipConnection, flyConnection, bodyVelocity, bodyGyro

-- ==========================================
-- 2. BACK-END (FONCTIONS DE CHEAT)
-- ==========================================
local function teleportToIsland(islandName)
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
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
				local obj = p.Character
				local hum = obj:FindFirstChild("Humanoid")
				local root = obj:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and root then
					local dist = (root.Position - myPos).Magnitude
					if dist <= minDist then minDist = dist; closest = obj end
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
					local target = getTarget(tName, true)
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, 8, 0)
						local dist = (myRoot.Position - tpPos).Magnitude
						
						if dist > 15 then
							TweenService:Create(myRoot, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)}):Play()
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
-- 3. CRÉATION DE L'INTERFACE
-- ==========================================
if targetGui:FindFirstChild("EliteProMenu") then targetGui.EliteProMenu:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EliteProMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 750, 0, 480)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = accentColor
mainStroke.Thickness = 2

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 8)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
local sidebarPadding = Instance.new("UIPadding", sidebar)
sidebarPadding.PaddingTop = UDim.new(0, 20); sidebarPadding.PaddingLeft = UDim.new(0, 12); sidebarPadding.PaddingRight = UDim.new(0, 12)

-- 🔥 CHARGEMENT DU LOGO DEPUIS GITHUB 🔥
local logoContainer = Instance.new("Frame", sidebar)
logoContainer.Size = UDim2.new(1, 0, 0, 100)
logoContainer.BackgroundTransparency = 1
logoContainer.LayoutOrder = 0

local logoIcon = Instance.new("ImageLabel", logoContainer)
logoIcon.Size = UDim2.new(0, 80, 0, 80)
logoIcon.Position = UDim2.new(0.5, -40, 0.5, -40)
logoIcon.BackgroundTransparency = 1
logoIcon.ScaleType = Enum.ScaleType.Fit

task.spawn(function()
	pcall(function()
		-- 👉 REMPLACE CE LIEN PAR LE LIEN "RAW" DE TON IMAGE SUR GITHUB
		local githubRawUrl = "LIEN_RAW_GITHUB_ICI"
		
		if githubRawUrl ~= "LIEN_RAW_GITHUB_ICI" and (writefile and getcustomasset) then
			-- Télécharge l'image en arrière-plan et la sauvegarde temporairement
			local imgData = game:HttpGet(githubRawUrl)
			writefile("mxf.png", imgData)
			logoIcon.Image = getcustomasset("mxf.png")
		else
			-- Si pas de lien ou pas de fonction (exécuteur basique), on met un texte à la place
			local txt = Instance.new("TextLabel", logoContainer)
			txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
			txt.Text = "MxF"; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
			txt.Font = Enum.Font.GothamBold; txt.TextSize = 26
		end
	end)
end)


local pages = {}
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -190, 1, -20); contentArea.Position = UDim2.new(0, 185, 0, 10)
contentArea.BackgroundTransparency = 1

local function createPage(name)
	local page = Instance.new("ScrollingFrame", contentArea)
	page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1
	page.Visible = false; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Color3.fromRGB(60,60,70)
	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 12)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20) end)
	pages[name] = page
	return page
end

local pageCombat = createPage("Combat")
local pageLocal = createPage("Local")
local pageTeleport = createPage("Teleport")
local pageConfigs = createPage("Configs")

local tabOrder = 1
local function createTab(name)
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.BackgroundTransparency = 1
	btn.Text = "  " .. name; btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.Font = Enum.Font.GothamMedium; btn.TextSize = 15; btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = tabOrder; tabOrder = tabOrder + 1
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		for _, b in ipairs(sidebar:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play() end end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		pages[name].Visible = true
	end)
end

local function createSection(parent, title)
	local label = Instance.new("TextLabel", parent)
	label.Size = UDim2.new(1, -10, 0, 30); label.BackgroundTransparency = 1
	label.Text = " " .. title:upper(); label.TextColor3 = Color3.fromRGB(120, 120, 130)
	label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.GothamBold; label.TextSize = 12
end

local function createCheckbox(page, text, default, callback)
	local state = default or false
	local container = Instance.new("TextButton", page)
	container.Size = UDim2.new(1, -20, 0, 45); container.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	container.Text = ""; Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", container).Color = Color3.fromRGB(40, 40, 48)

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14

	local box = Instance.new("Frame", container)
	box.Size = UDim2.new(0, 22, 0, 22); box.Position = UDim2.new(1, -35, 0.5, -11)
	box.BackgroundColor3 = state and accentColor or Color3.fromRGB(30, 30, 35)
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", box).Color = Color3.fromRGB(60, 60, 70)
	table.insert(themeObjects, {obj = box, isCheckbox = true, state = state})

	local check = Instance.new("TextLabel", box)
	check.Size = UDim2.new(1, 0, 1, 0); check.BackgroundTransparency = 1
	check.Text = "✓"; check.TextColor3 = Color3.fromRGB(255, 255, 255)
	check.Font = Enum.Font.GothamBold; check.TextSize = 14; check.TextTransparency = state and 0 or 1

	container.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = state and accentColor or Color3.fromRGB(30, 30, 35)}):Play()
		TweenService:Create(check, TweenInfo.new(0.15), {TextTransparency = state and 0 or 1}):Play()
		TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)}):Play()
		for _, v in ipairs(themeObjects) do if v.obj == box then v.state = state end end
		if callback then callback(state) end
	end)
end

local function createSlider(page, text, min, max, default, callback)
	local value = default
	local container = Instance.new("Frame", page)
	container.Size = UDim2.new(1, -20, 0, 60); container.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", container).Color = Color3.fromRGB(40, 40, 48)

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(0.5, 0, 0, 25); lbl.Position = UDim2.new(0, 15, 0, 5); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14

	local valLbl = Instance.new("TextLabel", container)
	valLbl.Size = UDim2.new(0.5, -15, 0, 25); valLbl.Position = UDim2.new(0.5, 0, 0, 5); valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(value); valLbl.TextColor3 = accentColor
	valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 13
	table.insert(themeObjects, {obj = valLbl, isText = true})

	local bg = Instance.new("TextButton", container)
	bg.Size = UDim2.new(1, -30, 0, 8); bg.Position = UDim2.new(0, 15, 0, 38)
	bg.BackgroundColor3 = Color3.fromRGB(15, 15, 18); bg.Text = ""; Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = accentColor
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	table.insert(themeObjects, {obj = fill, isSlider = true})

	local dragging = false
	bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			value = math.floor(min + ((max - min) * pos))
			fill.Size = UDim2.new(pos, 0, 1, 0)
			valLbl.Text = tostring(value)
			if callback then callback(value) end
		end
	end)
end

local function createCycle(page, text, options, default, callback)
	local index = table.find(options, default) or 1
	local container = Instance.new("TextButton", page)
	container.Size = UDim2.new(1, -20, 0, 45); container.BackgroundColor3 = Color3.fromRGB(22, 22, 26); container.Text = ""
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", container).Color = Color3.fromRGB(40, 40, 48)

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14

	local valLbl = Instance.new("TextLabel", container)
	valLbl.Size = UDim2.new(0.5, -15, 1, 0); valLbl.Position = UDim2.new(0.5, 0, 0, 0); valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(options[index]) .. " ⯈"; valLbl.TextColor3 = accentColor
	valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 13
	table.insert(themeObjects, {obj = valLbl, isText = true})

	container.MouseButton1Click:Connect(function()
		index = index + 1; if index > #options then index = 1 end
		valLbl.Text = tostring(options[index]) .. " ⯈"
		if callback then callback(options[index]) end
	end)
end

local function createButton(page, text, callback)
	local btn = Instance.new("TextButton", page)
	btn.Size = UDim2.new(1, -20, 0, 45); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(50, 50, 60)
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

local function createColorPicker(page, text)
	local container = Instance.new("Frame", page)
	container.Size = UDim2.new(1, -20, 0, 65); container.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", container).Color = Color3.fromRGB(40, 40, 48)

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, -20, 0, 25); lbl.Position = UDim2.new(0, 15, 0, 5); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14

	local hueBar = Instance.new("TextButton", container)
	hueBar.Size = UDim2.new(1, -30, 0, 15); hueBar.Position = UDim2.new(0, 15, 0, 35)
	hueBar.Text = ""; Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)
	
	local gradient = Instance.new("UIGradient", hueBar)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})

	local cursor = Instance.new("Frame", hueBar)
	cursor.Size = UDim2.new(0, 4, 1, 6); cursor.Position = UDim2.new(0.5, -2, 0, -3)
	cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", cursor).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", cursor).Color = Color3.fromRGB(0,0,0)

	local dragging = false
	local function updateColor(input)
		local relativeX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		cursor.Position = UDim2.new(relativeX, -2, 0, -3)
		local newColor = Color3.fromHSV(relativeX, 1, 1)
		
		accentColor = newColor
		mainStroke.Color = newColor
		for _, item in ipairs(themeObjects) do
			if item.isCheckbox and item.state then item.obj.BackgroundColor3 = newColor
			elseif item.isSlider then item.obj.BackgroundColor3 = newColor
			elseif item.isText then item.obj.TextColor3 = newColor end
		end
	end

	hueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateColor(input) end end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateColor(input) end end)
end

-- Drag Flottant
local draggingUI, dragStartUI, startPosUI
sidebar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingUI = true; dragStartUI = input.Position; startPosUI = mainFrame.Position end
end)
UIS.InputChanged:Connect(function(input)
	if draggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStartUI
		mainFrame.Position = UDim2.new(startPosUI.X.Scale, startPosUI.X.Offset + delta.X, startPosUI.Y.Scale, startPosUI.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingUI = false end end)

-- ==========================================
-- 4. REMPLISSAGE DES PAGES
-- ==========================================

createSection(pageCombat, "Système Auto Farm")
createCycle(pageCombat, "Cible (Mob)", MobNames, selectedMob, function(v) selectedMob = v end)
createCheckbox(pageCombat, "Auto Farm Mobs", false, function(v) autoFarmMob = v; if v then autoFarmBoss, killauraEnabled = false, false; teleportToIsland(MobDatabase[selectedMob]); task.wait(2); startCombatLoop() end end)

createCycle(pageCombat, "Cible (Boss)", BossNames, selectedBoss, function(v) selectedBoss = v end)
createCheckbox(pageCombat, "Auto Farm Boss", false, function(v) autoFarmBoss = v; if v then autoFarmMob, killauraEnabled = false, false; teleportToIsland(BossDatabase[selectedBoss]); task.wait(2); startCombatLoop() end end)

createSection(pageCombat, "Combat Assist (Sol)")
createCheckbox(pageCombat, "KillAura", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss = false, false; startCombatLoop() end end)
createCheckbox(pageCombat, "Cibler les Joueurs", false, function(v) targetPlayers = v; currentTarget = nil end)
createSlider(pageCombat, "Portée (Studs)", 10, 2000, 500, function(v) combatRadius = v end)

createSection(pageLocal, "Exploits Mouvement")
createCheckbox(pageLocal, "NoClip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)
createCheckbox(pageLocal, "Fly Mode", false, function(v) flyEnabled = v; if v then enableFly() else disableFly() end end)
createSlider(pageLocal, "Vitesse de Vol", 10, 200, 50, function(v) FLY_SPEED = v end)

createSection(pageTeleport, "Voyage Rapide")
createCycle(pageTeleport, "Destination", IslandNames, selectedIsland, function(v) selectedIsland = v end)
createButton(pageTeleport, "Se Téléporter", function() teleportToIsland(selectedIsland) end)

createSection(pageConfigs, "Raccourcis & Transparence")
local keybindBtn = Instance.new("TextButton", pageConfigs)
keybindBtn.Size = UDim2.new(1, -20, 0, 45); keybindBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
keybindBtn.Text = "Touche Menu : " .. currentKeybind.Name; keybindBtn.TextColor3 = accentColor
keybindBtn.Font = Enum.Font.GothamBold; keybindBtn.TextSize = 14; Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", keybindBtn).Color = Color3.fromRGB(40, 40, 48)
table.insert(themeObjects, {obj = keybindBtn, isText = true})

keybindBtn.MouseButton1Click:Connect(function() isBinding = true; keybindBtn.Text = "... Appuyez sur une touche ..." end)
UIS.InputBegan:Connect(function(input)
	if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
		currentKeybind = input.KeyCode; keybindBtn.Text = "Touche Menu : " .. currentKeybind.Name; isBinding = false
	elseif input.KeyCode == currentKeybind and not isBinding then
		isVisible = not isVisible; mainFrame.Visible = isVisible
	end
end)

createSlider(pageConfigs, "Opacité du Menu", 10, 100, 90, function(v) mainFrame.BackgroundTransparency = 1 - (v/100) end)

createSection(pageConfigs, "Couleur du Thème")
createColorPicker(pageConfigs, "Sélecteur RGB (Arc-en-ciel)")

createTab("Combat")
createTab("Local")
createTab("Teleport")
createTab("Configs")

for _, child in ipairs(sidebar:GetChildren()) do
	if child:IsA("TextButton") and child.Text == "  Combat" then
		child.BackgroundTransparency = 0.85
		child.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end
pages.Combat.Visible = true

print("Menu Elite Pro Injecté. Logo custom et Color Picker fonctionnels.")
