-- ======================================================
-- 👑 MxF HUB - ULTIMATE SPEED EDITION
-- Glassmorphism, Search Bar, Smart Farm, Professional UI
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

if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end

-- ==========================================
-- 1. CONFIGURATION & VARIABLES
-- ==========================================
local UIConfig = {
	Accent = Color3.fromRGB(255, 255, 255),
	ToggleKey = Enum.KeyCode.Insert,
	WindowSize = UDim2.new(0, 650, 0, 400),
}

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
local mobHeight, tweenSpeed, combatCooldown, combatRadius = 8, 150, 0.1, 500
local combatCoroutine = nil

-- Player Vars
local walkSpeedEnabled, walkSpeedValue = false, 50
local flyEnabled, flySpeedValue = false, 50
local infJumpEnabled, noClipEnabled = false, false
local bodyVelocity, bodyGyro, speedConn, flyConn, clipConn

-- ==========================================
-- 2. BACK-END LOGIC
-- ==========================================
local function teleportToIsland(islandName)
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
end

local function isMobRendered(targetName)
	local npcs = workspace:FindFirstChild("NPCs")
	if not npcs then return false end
	for _, obj in ipairs(npcs:GetDescendants()) do
		if obj:IsA("Model") and string.find(obj.Name, targetName) then
			if targetName == "Thief" and string.find(obj.Name, "Boss") then continue end
			if obj:FindFirstChild("HumanoidRootPart") then return true end
		end
	end
	return false
end

local function getTarget(targetName, isSpecific)
	local closest, minDist = nil, math.huge
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, minDist end
	local myPos = char.HumanoidRootPart.Position
	local npcs = workspace:FindFirstChild("NPCs")

	if npcs then
		for _, obj in ipairs(npcs:GetDescendants()) do
			if obj:IsA("Model") and not string.find(string.lower(obj.Name), "quest") then
				local match = isSpecific and string.find(obj.Name, targetName) or true
				if match and isSpecific and targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
				
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
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				local hum = char.Humanoid
				
				if autoFarmMob or autoFarmBoss then
					hum.PlatformStand = true
					root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
					local tName = autoFarmMob and selectedMob or selectedBoss
					local island = autoFarmMob and MobDatabase[selectedMob] or BossDatabase[selectedBoss]
					local target, dist = getTarget(tName, true)
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						if dist > 1500 then teleportToIsland(island); task.wait(2.5)
						else
							local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, mobHeight, 0)
							if dist > 15 then
								local tTime = math.clamp(dist / tweenSpeed, 0.05, 3)
								TweenService:Create(root, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)}):Play()
							else
								root.CFrame = CFrame.lookAt(tpPos, target.HumanoidRootPart.Position)
								pcall(function() remote:FireServer() end)
							end
						end
					else teleportToIsland(island); task.wait(2.5) end
				elseif killauraEnabled then
					if not flyEnabled then hum.PlatformStand = false end
					local target = getTarget(nil, false)
					if target and target:FindFirstChild("HumanoidRootPart") then
						root.CFrame = CFrame.lookAt(root.Position, Vector3.new(target.HumanoidRootPart.Position.X, root.Position.Y, target.HumanoidRootPart.Position.Z))
						pcall(function() remote:FireServer() end)
					end
				end
			end
			task.wait(combatCooldown)
		end
		if player.Character and not flyEnabled then player.Character.Humanoid.PlatformStand = false end
	end)
end

-- Movements
local function updateSpeed()
	if speedConn then speedConn:Disconnect() end
	if walkSpeedEnabled then speedConn = RunService.Heartbeat:Connect(function() if player.Character then player.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
	else if player.Character then player.Character.Humanoid.WalkSpeed = 16 end end
end

UIS.JumpRequest:Connect(function() if infJumpEnabled and player.Character then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function toggleFly()
	if flyConn then flyConn:Disconnect() end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	if not flyEnabled then if player.Character then player.Character.Humanoid.PlatformStand = false end return end
	
	local char = player.Character
	if not char then return end
	char.Humanoid.PlatformStand = true
	bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart); bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5); bodyVelocity.Velocity = Vector3.zero
	bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart); bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bodyGyro.D = 50
	
	flyConn = RunService.RenderStepped:Connect(function()
		local dir, cf = Vector3.zero, camera.CFrame
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end
		bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeedValue or Vector3.zero
		bodyGyro.CFrame = cf
	end)
end

-- ==========================================
-- 3. MOTEUR UI (SPEED HUB X REPRODUCTION)
-- ==========================================
local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubPremium"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UIConfig.WindowSize
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
mainFrame.BackgroundTransparency = 0.2 -- Transparence
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(45, 45, 50); stroke.Thickness = 1.2

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 14)
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

-- Logo MxF
local logoImg = Instance.new("ImageLabel", sidebar)
logoImg.Size = UDim2.new(0, 35, 0, 35); logoImg.Position = UDim2.new(0, 15, 0, 15)
logoImg.BackgroundTransparency = 1
pcall(function()
	local githubRaw = "https://raw.githubusercontent.com/CaveUser/MxF/main/scripts/mxf.png" -- ⚠️ METS TON LIEN RAW ICI
	if githubRaw ~= "https://raw.githubusercontent.com/CaveUser/MxF/main/scripts/mxf.png" and writefile then
		local data = game:HttpGet(githubRaw)
		writefile("mxf.png", data)
		logoImg.Image = getcustomasset("mxf.png")
	else
		logoImg.Image = "rbxassetid://6026568227"
	end
end)

local hubName = Instance.new("TextLabel", sidebar)
hubName.Size = UDim2.new(1, -60, 0, 35); hubName.Position = UDim2.new(0, 55, 0, 15)
hubName.BackgroundTransparency = 1; hubName.Text = "MxF HUB"; hubName.TextColor3 = Color3.fromRGB(255, 255, 255)
hubName.Font = Enum.Font.GothamBold; hubName.TextSize = 16; hubName.TextXAlignment = Enum.TextXAlignment.Left

-- Barre de recherche
local searchFrame = Instance.new("Frame", sidebar)
searchFrame.Size = UDim2.new(1, -20, 0, 30); searchFrame.Position = UDim2.new(0, 10, 0, 60)
searchFrame.BackgroundColor3 = Color3.fromRGB(25, 26, 30); Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)

local searchIcon = Instance.new("ImageLabel", searchFrame)
searchIcon.Size = UDim2.new(0, 16, 0, 16); searchIcon.Position = UDim2.new(0, 8, 0.5, -8)
searchIcon.Image = "rbxassetid://6031154871"; searchIcon.BackgroundTransparency = 1; searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(1, -30, 1, 0); searchBox.Position = UDim2.new(0, 30, 0, 0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255); searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12; searchBox.TextXAlignment = Enum.TextXAlignment.Left

-- Navigation
local navList = Instance.new("ScrollingFrame", sidebar)
navList.Size = UDim2.new(1, 0, 1, -100); navList.Position = UDim2.new(0, 0, 0, 100)
navList.BackgroundTransparency = 1; navList.ScrollBarThickness = 0
local navLayout = Instance.new("UIListLayout", navList); navLayout.Padding = UDim.new(0, 5); navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -190, 1, -20); container.Position = UDim2.new(0, 185, 0, 10)
container.BackgroundTransparency = 1

local activeTabName = Instance.new("TextLabel", container)
activeTabName.Size = UDim2.new(1, 0, 0, 40); activeTabName.BackgroundTransparency = 1; activeTabName.Text = "Home"
activeTabName.TextColor3 = Color3.fromRGB(255, 255, 255); activeTabName.Font = Enum.Font.GothamBold; activeTabName.TextSize = 22; activeTabName.TextXAlignment = Enum.TextXAlignment.Left

local Pages = {}
local currentTab = nil

local function CreateTab(name, iconId)
	local btn = Instance.new("TextButton", navList)
	btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.BackgroundTransparency = 1; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local icon = Instance.new("ImageLabel", btn)
	icon.Size = UDim2.new(0, 18, 0, 18); icon.Position = UDim2.new(0, 10, 0.5, -9); icon.Image = "rbxassetid://"..iconId; icon.BackgroundTransparency = 1; icon.ImageColor3 = Color3.fromRGB(200, 200, 200)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 35, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(150, 150, 160); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local page = Instance.new("ScrollingFrame", container)
	page.Size = UDim2.new(1, 0, 1, -50); page.Position = UDim2.new(0, 0, 0, 50); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false
	local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 8)
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20) end)

	Pages[name] = page

	btn.MouseButton1Click:Connect(function()
		for n, p in pairs(Pages) do p.Visible = (n == name) end
		if currentTab then TweenService:Create(currentTab.btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
		activeTabName.Text = name; currentTab = {btn = btn, page = page}
	end)

	return page
end

-- Component Helpers
local function CreateRow(page, text)
	local row = Instance.new("Frame", page)
	row.Size = UDim2.new(1, -10, 0, 45); row.BackgroundColor3 = Color3.fromRGB(22, 23, 27); row.BackgroundTransparency = 0.3
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", row).Color = Color3.fromRGB(40, 40, 45)
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	return row, lbl
end

local function CreateToggle(page, text, default, callback)
	local row, lbl = CreateRow(page, text)
	local state = default
	
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0, 36, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10); btn.BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(50,50,55); btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	
	local dot = Instance.new("Frame", btn)
	dot.Size = UDim2.new(0, 14, 0, 14); dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); dot.BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(50,50,55)}):Play()
		TweenService:Create(dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)}):Play()
		callback(state)
	end)
end

local function CreateSlider(page, text, min, max, default, callback)
	local row, lbl = CreateRow(page, text)
	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size = UDim2.new(0.3, 0, 1, 0); valLbl.Position = UDim2.new(1, -45, 0, 0); valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default); valLbl.TextColor3 = Color3.fromRGB(150,150,160); valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12; valLbl.TextXAlignment = Enum.TextXAlignment.Right
	
	local sliderBg = Instance.new("TextButton", row)
	sliderBg.Size = UDim2.new(0.4, 0, 0, 4); sliderBg.Position = UDim2.new(0.5, 0, 0.5, -2); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55); sliderBg.Text = ""
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
	
	local fill = Instance.new("Frame", sliderBg)
	fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	
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

local function CreateDropdown(page, text, options, callback)
	local row, lbl = CreateRow(page, text); row.ClipsDescendants = true
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.4, 0, 0, 26); btn.Position = UDim2.new(1, -15, 0.5, -13); btn.AnchorPoint = Vector2.new(1, 0); btn.BackgroundColor3 = Color3.fromRGB(35, 36, 40); btn.Text = "Select..."; btn.TextColor3 = Color3.fromRGB(200,200,200); btn.Font = Enum.Font.Gotham; btn.TextSize = 11; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	
	local list = Instance.new("Frame", row); list.Size = UDim2.new(1, -20, 0, 0); list.Position = UDim2.new(0, 10, 0, 45); list.BackgroundTransparency = 1; Instance.new("UIListLayout", list).Padding = UDim.new(0, 3)
	local open = false
	btn.MouseButton1Click:Connect(function()
		open = not open
		TweenService:Create(row, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, open and (45 + #options * 25) or 45)}):Play()
	end)
	for _, opt in ipairs(options) do
		local oBtn = Instance.new("TextButton", list); oBtn.Size = UDim2.new(1, 0, 0, 22); oBtn.BackgroundColor3 = Color3.fromRGB(40,41,46); oBtn.Text = opt; oBtn.TextColor3 = Color3.fromRGB(200,200,200); oBtn.Font = Enum.Font.Gotham; oBtn.TextSize = 11; Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 4)
		oBtn.MouseButton1Click:Connect(function() btn.Text = opt; open = false; TweenService:Create(row, TweenInfo.new(0.3), {Size = UDim2.new(1,-10,0,45)}):Play(); callback(opt) end)
	end
end

-- Search Logic
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local filter = string.lower(searchBox.Text)
	if currentTab then
		for _, child in ipairs(currentTab.page:GetChildren()) do
			if child:IsA("Frame") then
				local label = child:FindFirstChildOfClass("TextLabel")
				child.Visible = label and string.find(string.lower(label.Text), filter) ~= nil
			end
		end
	end
end)

-- ==========================================
-- 4. CONSTRUCTION DU HUB
-- ==========================================
local pgFarm = CreateTab("Farm", "6034501995")
local pgPlayer = CreateTab("Self", "6023426915")
local pgTp = CreateTab("Teleport", "6034502922")
local pgMisc = CreateTab("Miscellaneous", "6031289224")

-- Farm
CreateDropdown(pgFarm, "Select Monster", MobNames, function(v) selectedMob = v end)
CreateToggle(pgFarm, "Auto Farm Monster", false, function(v) autoFarmMob = v; if v then autoFarmBoss, killauraEnabled = false, false; startCombatLoop() end end)
CreateDropdown(pgFarm, "Select Boss", BossNames, function(v) selectedBoss = v end)
CreateToggle(pgFarm, "Auto Farm Boss", false, function(v) autoFarmBoss = v; if v then autoFarmMob, killauraEnabled = false, false; startCombatLoop() end end)
CreateToggle(pgFarm, "KillAura", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss = false, false; startCombatLoop() end end)

-- Player
CreateSlider(pgPlayer, "WalkSpeed", 16, 250, 50, function(v) walkSpeedValue = v; updateSpeed() end)
CreateToggle(pgPlayer, "Enable WalkSpeed", false, function(v) walkSpeedEnabled = v; updateSpeed() end)
CreateSlider(pgPlayer, "Fly Speed", 10, 300, 50, function(v) flySpeedValue = v end)
CreateToggle(pgPlayer, "Fly Mode", false, function(v) flyEnabled = v; toggleFly() end)
CreateToggle(pgPlayer, "Infinite Jump", false, function(v) infJumpEnabled = v end)
CreateToggle(pgPlayer, "No Clip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)

-- Teleport
CreateDropdown(pgTp, "Select Island", IslandNames, function(v) selectedIsland = v end)
local tpRow = CreateRow(pgTp, "Execute Teleport")
local tpBtn = Instance.new("TextButton", tpRow); tpBtn.Size = UDim2.new(0.3, 0, 0, 26); tpBtn.Position = UDim2.new(1,-15,0.5,-13); tpBtn.AnchorPoint = Vector2.new(1,0); tpBtn.BackgroundColor3 = Color3.fromRGB(40,40,45); tpBtn.Text = "TP Now"; tpBtn.TextColor3 = Color3.fromRGB(255,255,255); tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 11; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,4)
tpBtn.MouseButton1Click:Connect(function() teleportToIsland(selectedIsland) end)

-- Dragging Main
local dragS, dragI, dragP, startP
mainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; dragP = input.Position; startP = mainFrame.Position end end)
UIS.InputChanged:Connect(function(input) if dragS and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragP; mainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end end)

-- Init
navList:GetChildren()[2].MouseButton1Click:Fire()
print("MxF Hub Premium Edition Chargé !")
