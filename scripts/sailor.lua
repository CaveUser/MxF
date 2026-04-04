-- ======================================================
-- 👑 MxF HUB - SPEED HUB X EDITION (FINAL V8)
-- All NPCs Mapped, New Islands, Anti-Cheat TP Bypass
-- ======================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

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
	WindowSize = UDim2.new(0, 720, 0, 480),
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

-- Mapping complet des NPCs fourni par l'utilisateur
local NpcIslandMap = {
	-- Dungeon
	["DungeonMerchantNPC"] = "Dungeon", ["DungeonPortalsNPC"] = "Dungeon", ["ShadowMonarchBuyerNPC"] = "Dungeon", ["CidBuyer"] = "Dungeon",
	-- Boss
	["SummonBossNPC"] = "Boss", ["ExchangeNPC"] = "Boss", ["MoonSlayerBuff"] = "Boss", ["GilgameshBuyerNPC"] = "Boss", ["SaberAlterBuyerNPC"] = "Boss", ["GrailCraftNPC"] = "Boss", ["BabylonCraftNPC"] = "Boss", ["SaberAlterMasteryNPC"] = "Boss", ["QinShiBuyer"] = "Boss", ["MoonSlayerSeller"] = "Boss", ["BlessedMaidenBuyerNPC"] = "Boss", ["BlessedMaidenMasteryNPC"] = "Boss",
	-- Jungle
	["QuestNPC4"] = "Jungle", ["QuestNPC3"] = "Jungle",
	-- DesertIsland
	["QuestNPC5"] = "DesertIsland", ["ObservationBuyer"] = "DesertIsland", ["QuestNPC6"] = "DesertIsland",
	-- SnowIsland
	["DarkBladeNPC"] = "SnowIsland", ["RagnaQuestlineBuff"] = "SnowIsland", ["RagnaBuyer"] = "SnowIsland", ["HakiQuestNPC"] = "SnowIsland", ["ArtifactsUnlocker"] = "SnowIsland", ["ArtifactMilestoneNPC"] = "SnowIsland", ["QuestNPC7"] = "SnowIsland", ["QuestNPC8"] = "SnowIsland",
	-- Sailor
	["AscendNPC"] = "Sailor", ["StorageNPC"] = "Sailor", ["TitlesNPC"] = "Sailor", ["GemFruitDealer"] = "Sailor", ["MerchantNPC"] = "Sailor", ["CoinFruitDealer"] = "Sailor", ["RerollStatNPC"] = "Sailor", ["TraitNPC"] = "Sailor", ["BossRushShopNPC"] = "Sailor", ["BossRushPortalNPC"] = "Sailor", ["BossRushMerchantNPC"] = "Sailor", ["JinwooMovesetNPC"] = "Sailor", ["AlucardBuyer"] = "Sailor",
	-- Shibuya
	["GryphonBuyerNPC"] = "Shibuya", ["BlessingNPC"] = "Shibuya", ["EnchantNPC"] = "Shibuya", ["GojoMovesetNPC"] = "Shibuya", ["YujiBuyerNPC"] = "Shibuya", ["SukunaMovesetNPC"] = "Shibuya", ["QuestNPC9"] = "Shibuya", ["QuestNPC10"] = "Shibuya", ["ConquerorHakiNPC"] = "Shibuya",
	-- Hollow
	["IchigoBuyer"] = "Hollow", ["AizenQuestlineBuff"] = "Hollow", ["HogyokuQuestNPC"] = "Hollow", ["AizenMovesetNPC"] = "Hollow", ["QuestNPC11"] = "Hollow",
	-- Shinjuku
	["QuestNPC12"] = "Shinjuku", ["QuestNPC13"] = "Shinjuku", ["StrongestinHistoryBuyerNPC"] = "Shinjuku", ["SukunaMasteryNPC"] = "Shinjuku", ["StrongestBossSummonerNPC"] = "Shinjuku", ["GojoCraftNPC"] = "Shinjuku", ["GojoMasteryNPC"] = "Shinjuku", ["SukunaCraftNPC"] = "Shinjuku", ["StrongestofTodayBuyerNPC"] = "Shinjuku",
	-- Slime
	["QuestNPC14"] = "Slime", ["RimuruSummonerNPC"] = "Slime", ["SkillTreeNPC"] = "Slime", ["SlimeCraftNPC"] = "Slime", ["RimuruBuyer"] = "Slime", ["RimuruMasteryNPC"] = "Slime",
	-- Academy
	["AnosQuestNPC"] = "Academy", ["AnosBossSummonerNPC"] = "Academy", ["QuestNPC15"] = "Academy", ["AnosBuyerNPC"] = "Academy",
	-- Judgement
	["SpecPassivesNPC"] = "Judgement", ["QuestNPC16"] = "Judgement", ["YamatoBuyerNPC"] = "Judgement",
	-- Soul
	["TrueAizenBossSummonerNPC"] = "Soul", ["TrueAizenBuyerNPC"] = "Soul", ["TrueAizenFUnlockNPC"] = "Soul", ["QuestNPC17"] = "Soul",
	-- Starter
	["GroupRewardNPC"] = "Starter", ["QuestNPC2"] = "Starter", ["ShadowMonarchQuestlineBuff"] = "Starter", ["QuestNPC1"] = "Starter", ["Katana"] = "Starter", ["ShadowQuestlineBuff"] = "Starter", ["MadokaBuyer"] = "Starter",
	-- Ninja
	["QuestNPC18"] = "Ninja", ["StrongestShinobiMasteryNPC"] = "Ninja", ["StrongestShinobiBuyerNPC"] = "Ninja",
	-- Lawless
	["PowerNPC"] = "Lawless", ["AtomicBossSummonerNPC"] = "Lawless", ["QuestNPC19"] = "Lawless", ["AtomicBuyer"] = "Lawless", ["AtomicQuestlineBuff"] = "Lawless",
	-- Tower
	["InfiniteTowerMerchantNPC"] = "Tower", ["InfiniteTowerPortalNPC"] = "Tower", ["InfiniteTowerStatShopNPC"] = "Tower"
}

-- Génération dynamique des listes
local NpcNames = {}
for npcName, _ in pairs(NpcIslandMap) do table.insert(NpcNames, npcName) end

local MobNames, BossNames, IslandNames = {}, {}, {}
for m, i in pairs(MobDatabase) do table.insert(MobNames, m); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
for b, i in pairs(BossDatabase) do table.insert(BossNames, b); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end

-- Ajout manuel des îles pour le TP (au cas où elles n'ont pas de mobs associés)
local ExtraIslands = {"Dungeon", "Boss", "Sailor", "Tower", "DesertIsland", "SnowIsland"}
for _, island in ipairs(ExtraIslands) do if not table.find(IslandNames, island) then table.insert(IslandNames, island) end end

table.sort(MobNames); table.sort(BossNames); table.sort(IslandNames); table.sort(NpcNames)

local selectedMob, selectedBoss, selectedIsland, selectedNPC = MobNames[1], BossNames[1], IslandNames[1], NpcNames[1]
local autoFarmMob, autoFarmBoss, autoFarmTower, killauraEnabled = false, false, false, false

local isOnRightIsland = false 
local selectedSkill = "All"
local autoSkillEnabled = false
local targetPlayers = false
local mobHeight, tweenSpeed, combatCooldown, combatRadius = 8, 150, 0.1, 500
local combatCoroutine, currentTarget = nil, nil

-- Player Vars
local walkSpeedEnabled, walkSpeedValue = false, 50
local flyEnabled, flySpeedValue = false, 50
local infJumpEnabled, noClipEnabled = false, false
local bodyVelocity, bodyGyro, speedConn, flyConn, noClipConn

-- ==========================================
-- 2. BACK-END LOGIC
-- ==========================================
local function teleportToIsland(islandName)
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
end

-- BYPASS ANTI-CHEAT : Step-Lerp Teleport
local function safeLerpTP(targetCFrame)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local dist = (root.Position - targetCFrame.Position).Magnitude
	local steps = math.ceil(dist / 35) -- Micro-sauts de 35 studs pour éviter le flag anti-cheat
	
	if steps > 0 then
		for i = 1, steps do
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then break end
			player.Character.HumanoidRootPart.CFrame = root.CFrame:Lerp(targetCFrame, i / steps)
			task.wait() -- Attente minime entre les sauts
		end
	end
	
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = targetCFrame
	end
end

local function teleportToSpecificNPC(npcName)
	local targetIsland = NpcIslandMap[npcName] or "Starter"
	
	-- TP initial au portail
	teleportToIsland(targetIsland)
	task.wait(3.5) -- On attend que le jeu charge la map et le dossier NPCs
	
	local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild(npcName)
	if npc and npc:FindFirstChild("HumanoidRootPart") then
		-- Position cible : 4 studs devant le PNJ
		local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
		
		-- Utilise le bypass anti-cheat pour s'y rendre
		safeLerpTP(targetCFrame)
	else
		print("Erreur : Le NPC " .. npcName .. " est introuvable sur " .. targetIsland .. " après le chargement.")
	end
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
				local match = true
				if targetName == "NearestTower" then
					match = true 
				elseif isSpecific then
					-- Ciblage STRICT
					if string.sub(obj.Name, 1, #targetName) == targetName then
						if targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
					else
						match = false
					end
				end
				
				if match then
					local hum = obj:FindFirstChild("Humanoid")
					local root = obj:FindFirstChild("HumanoidRootPart")
					if hum and hum.Health > 0 and root then
						local dist = (root.Position - myPos).Magnitude
						if not isSpecific and targetName ~= "NearestTower" and dist > combatRadius then continue end
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
		while autoFarmMob or autoFarmBoss or autoFarmTower or killauraEnabled do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				local hum = char.Humanoid
				
				if autoFarmMob or autoFarmBoss or autoFarmTower then
					hum.PlatformStand = true
					
					local tName = autoFarmTower and "NearestTower" or (autoFarmMob and selectedMob or selectedBoss)
					local island = autoFarmTower and "" or (autoFarmMob and MobDatabase[selectedMob] or BossDatabase[selectedBoss])
					local target, dist = getTarget(tName, true)
					currentTarget = target
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						isOnRightIsland = true 
						
						local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, mobHeight, 0)
						local targetCFrame = CFrame.new(tpPos) * CFrame.Angles(math.rad(-90), 0, 0)

						if dist > 15 then
							local tTime = math.clamp(dist / tweenSpeed, 0.05, 3)
							TweenService:Create(root, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame}):Play()
						else
							root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
							root.CFrame = targetCFrame
							pcall(function() remote:FireServer() end)
						end
					else 
						if not autoFarmTower then
							if not isOnRightIsland then
								teleportToIsland(island)
								task.wait(3.5)
								isOnRightIsland = true
							else
								-- Hover Wait Respawn
								root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
							end
						else
							root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
						end
					end
				elseif killauraEnabled then
					if not flyEnabled then hum.PlatformStand = false end
					local target, _ = getTarget(nil, false)
					currentTarget = target
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

-- ==========================================
-- AUTO SKILLS LOOP
-- ==========================================
task.spawn(function()
	while task.wait(0.5) do
		if autoSkillEnabled and currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 and (autoFarmMob or autoFarmBoss or autoFarmTower or killauraEnabled) then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local tRoot = currentTarget:FindFirstChild("HumanoidRootPart")
			if root and tRoot and (root.Position - tRoot.Position).Magnitude < 40 then
				if selectedSkill == "All" then
					local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F}
					for _, k in ipairs(keys) do
						VIM:SendKeyEvent(true, k, false, game)
						task.wait(0.05)
						VIM:SendKeyEvent(false, k, false, game)
					end
				else
					local k = Enum.KeyCode[selectedSkill]
					VIM:SendKeyEvent(true, k, false, game)
					task.wait(0.05)
					VIM:SendKeyEvent(false, k, false, game)
				end
			end
		end
	end
end)

-- Movements
local function updateSpeed()
	if speedConn then speedConn:Disconnect() end
	if walkSpeedEnabled then speedConn = RunService.Heartbeat:Connect(function() if player.Character then player.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
	else if player.Character then player.Character.Humanoid.WalkSpeed = 16 end end
end

UIS.JumpRequest:Connect(function() if infJumpEnabled and player.Character then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function enableNoClip()
	if noClipConn then noClipConn:Disconnect() end
	noClipConn = RunService.Stepped:Connect(function()
		if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
	end)
end
local function disableNoClip()
	if noClipConn then noClipConn:Disconnect() noClipConn = nil end
	if player.Character then for _, p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

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

player.CharacterAdded:Connect(function()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	task.wait(0.5)
	if walkSpeedEnabled then updateSpeed() end
	if noClipEnabled then enableNoClip() end
	if flyEnabled then toggleFly() end
	if autoFarmMob or autoFarmBoss or autoFarmTower or killauraEnabled then startCombatLoop() end
end)

-- ==========================================
-- 3. MOTEUR UI
-- ==========================================
local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubPremium"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UIConfig.WindowSize
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
mainFrame.BackgroundTransparency = 0.15 
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(45, 45, 50); stroke.Thickness = 1.2

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 200, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 14)
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

-- Logo MxF
local logoImg = Instance.new("ImageLabel", sidebar)
logoImg.Size = UDim2.new(0, 40, 0, 40); logoImg.Position = UDim2.new(0, 15, 0, 15)
logoImg.BackgroundTransparency = 1; logoImg.ScaleType = Enum.ScaleType.Fit
pcall(function()
	local logoUrl = "https://i.goopics.net/lpt7p1.png"
	if writefile and getcustomasset then
		local data = game:HttpGet(logoUrl)
		writefile("mxf_logo.png", data)
		logoImg.Image = getcustomasset("mxf_logo.png")
	else
		logoImg.Image = "rbxassetid://10629237000"
	end
end)

local hubName = Instance.new("TextLabel", sidebar)
hubName.Size = UDim2.new(1, -70, 0, 40); hubName.Position = UDim2.new(0, 65, 0, 15)
hubName.BackgroundTransparency = 1; hubName.Text = "MxF HUB"; hubName.TextColor3 = Color3.fromRGB(255, 255, 255)
hubName.Font = Enum.Font.GothamBold; hubName.TextSize = 18; hubName.TextXAlignment = Enum.TextXAlignment.Left

-- Search Bar
local searchFrame = Instance.new("Frame", sidebar)
searchFrame.Size = UDim2.new(1, -30, 0, 36); searchFrame.Position = UDim2.new(0, 15, 0, 70)
searchFrame.BackgroundColor3 = Color3.fromRGB(25, 26, 30); Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)

local searchIcon = Instance.new("ImageLabel", searchFrame)
searchIcon.Size = UDim2.new(0, 18, 0, 18); searchIcon.Position = UDim2.new(0, 10, 0.5, -9)
searchIcon.Image = "rbxassetid://7733654492"; searchIcon.BackgroundTransparency = 1; searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(1, -40, 1, 0); searchBox.Position = UDim2.new(0, 35, 0, 0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255); searchBox.Font = Enum.Font.GothamMedium; searchBox.TextSize = 14; searchBox.TextXAlignment = Enum.TextXAlignment.Left

-- Navigation Tabs
local navList = Instance.new("ScrollingFrame", sidebar)
navList.Size = UDim2.new(1, 0, 1, -120); navList.Position = UDim2.new(0, 0, 0, 120)
navList.BackgroundTransparency = 1; navList.ScrollBarThickness = 0
local navLayout = Instance.new("UIListLayout", navList); navLayout.Padding = UDim.new(0, 6); navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Main Content Area
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -210, 1, -20); container.Position = UDim2.new(0, 205, 0, 10)
container.BackgroundTransparency = 1

local activeTabName = Instance.new("TextLabel", container)
activeTabName.Size = UDim2.new(1, 0, 0, 45); activeTabName.BackgroundTransparency = 1; activeTabName.Text = "Home"
activeTabName.TextColor3 = Color3.fromRGB(255, 255, 255); activeTabName.Font = Enum.Font.GothamBold; activeTabName.TextSize = 26; activeTabName.TextXAlignment = Enum.TextXAlignment.Left

local Pages = {}
local currentTab = nil

local function CreateTab(name, iconId)
	local btn = Instance.new("TextButton", navList)
	btn.Size = UDim2.new(0.9, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.BackgroundTransparency = 1; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local icon = Instance.new("ImageLabel", btn)
	icon.Size = UDim2.new(0, 20, 0, 20); icon.Position = UDim2.new(0, 12, 0.5, -10); icon.Image = "rbxassetid://"..iconId; icon.BackgroundTransparency = 1; icon.ImageColor3 = Color3.fromRGB(200, 200, 200)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -45, 1, 0); lbl.Position = UDim2.new(0, 40, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(150, 150, 160); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local page = Instance.new("ScrollingFrame", container)
	page.Size = UDim2.new(1, 0, 1, -55); page.Position = UDim2.new(0, 0, 0, 55); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false
	local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 10)
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20) end)

	Pages[name] = page

	btn.MouseButton1Click:Connect(function()
		for n, p in pairs(Pages) do p.Visible = (n == name) end
		if currentTab then TweenService:Create(currentTab.btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play(); currentTab.lbl.TextColor3 = Color3.fromRGB(150, 150, 160) end
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play(); lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		activeTabName.Text = name; currentTab = {btn = btn, lbl = lbl, page = page}
	end)

	return page
end

local function CreateTitle(page, text)
	local frame = Instance.new("Frame", page)
	frame.Size = UDim2.new(1, -10, 0, 35); frame.BackgroundTransparency = 1
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, 0, 1, -5); lbl.BackgroundTransparency = 1; lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local line = Instance.new("Frame", frame)
	line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -2); line.BackgroundColor3 = Color3.fromRGB(50, 50, 60); line.BorderSizePixel = 0
	
	return frame
end

local function CreateRow(page, height)
	local row = Instance.new("Frame", page)
	row.Size = UDim2.new(1, -10, 0, height or 50); row.BackgroundColor3 = Color3.fromRGB(22, 23, 27); row.BackgroundTransparency = 0.2
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", row).Color = Color3.fromRGB(40, 40, 45)
	return row
end

local function CreateToggle(page, text, default, callback)
	local row = CreateRow(page, 50)
	local state = default
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""

	local pill = Instance.new("Frame", row)
	pill.Size = UDim2.new(0, 42, 0, 24); pill.Position = UDim2.new(1, -55, 0.5, -12)
	pill.BackgroundColor3 = state and UIConfig.Accent or Color3.fromRGB(45, 46, 50)
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame", pill)
	circle.Size = UDim2.new(0, 18, 0, 18); circle.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		state = not state
		local targetColor = state and UIConfig.Accent or Color3.fromRGB(45, 46, 50)
		local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
		callback(state)
	end)
end

local function CreateSlider(page, text, min, max, default, callback)
	local row = CreateRow(page, 60)
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 0, 30); lbl.Position = UDim2.new(0, 15, 0, 5); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size = UDim2.new(0.4, 0, 0, 30); valLbl.Position = UDim2.new(1, -55, 0, 5); valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(default); valLbl.TextColor3 = UIConfig.Accent; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 13; valLbl.TextXAlignment = Enum.TextXAlignment.Right
	
	local sliderBg = Instance.new("TextButton", row)
	sliderBg.Size = UDim2.new(1, -30, 0, 6); sliderBg.Position = UDim2.new(0, 15, 0, 40); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55); sliderBg.Text = ""
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

local isBindingAny = false
local function CreateKeybind(page, text, defaultKey, callback)
	local row = CreateRow(page, 50)
	local currentKey = defaultKey
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.4, 0, 0, 32); btn.Position = UDim2.new(1, -15, 0.5, -16); btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.Text = currentKey.Name; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 50)

	local isBinding = false
	btn.MouseButton1Click:Connect(function()
		isBinding = true; isBindingAny = true
		btn.Text = "Press Key..."
		btn.TextColor3 = UIConfig.Accent
	end)

	UIS.InputBegan:Connect(function(input)
		if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
			currentKey = input.KeyCode
			btn.Text = currentKey.Name
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			isBinding = false; task.wait(0.1); isBindingAny = false
			if callback then callback(currentKey) end
		end
	end)
end

local function CreateDropdown(page, text, options, default, callback)
	local current = default or options[1]
	local row = CreateRow(page, 50); row.ClipsDescendants = true

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.4, 0, 0, 50); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.5, 0, 0, 34); btn.Position = UDim2.new(1, -15, 0, 8); btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 50)

	local valTxt = Instance.new("TextLabel", btn)
	valTxt.Size = UDim2.new(1, -30, 1, 0); valTxt.Position = UDim2.new(0, 10, 0, 0); valTxt.BackgroundTransparency = 1
	valTxt.Text = tostring(current); valTxt.TextColor3 = Color3.fromRGB(200, 200, 200); valTxt.Font = Enum.Font.Gotham; valTxt.TextSize = 13; valTxt.TextXAlignment = Enum.TextXAlignment.Left

	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -25, 0, 0); icon.BackgroundTransparency = 1
	icon.Text = "▼"; icon.TextColor3 = Color3.fromRGB(150, 150, 150); icon.Font = Enum.Font.GothamBold; icon.TextSize = 11

	local list = Instance.new("Frame", row)
	list.Size = UDim2.new(1, -30, 0, 0); list.Position = UDim2.new(0, 15, 0, 55); list.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)

	local open = false
	btn.MouseButton1Click:Connect(function()
		open = not open; icon.Text = open and "▲" or "▼"
		local targetSize = open and (layout.AbsoluteContentSize.Y + 65) or 50
		TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
		task.delay(0.25, function() if currentTab then currentTab.page.CanvasSize = UDim2.new(0, 0, 0, currentTab.page:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 20) end end)
	end)

	for _, opt in ipairs(options) do
		local oBtn = Instance.new("TextButton", list); oBtn.Size = UDim2.new(1, 0, 0, 28); oBtn.BackgroundColor3 = Color3.fromRGB(35, 36, 40)
		oBtn.Text = "  " .. opt; oBtn.TextColor3 = Color3.fromRGB(220, 220, 220); oBtn.Font = Enum.Font.Gotham; oBtn.TextSize = 13; oBtn.TextXAlignment = Enum.TextXAlignment.Left
		Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 4)
		oBtn.MouseButton1Click:Connect(function()
			current = opt; valTxt.Text = opt; open = false; icon.Text = "▼"
			TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 50)}):Play()
			if callback then callback(opt) end
		end)
	end
end

local function CreateButton(page, text, callback)
	local row = CreateRow(page, 50)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = text
	btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- Search Logic
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local filter = string.lower(searchBox.Text)
	if currentTab then
		for _, child in ipairs(currentTab.page:GetChildren()) do
			if child:IsA("Frame") and not child:FindFirstChild("UIListLayout") then
				local label = child:FindFirstChildOfClass("TextLabel")
				if label then child.Visible = string.find(string.lower(label.Text), filter) ~= nil end
			end
		end
	end
end)

-- ==========================================
-- 4. CONSTRUCTION DU HUB
-- ==========================================

local iconFarm = "7733674079"
local iconPlayer = "7733954760"
local iconTeleport = "7733992829"
local iconConfig = "7734068321"

local pgFarm = CreateTab("Farm", iconFarm)
local pgPlayer = CreateTab("Player", iconPlayer)
local pgTp = CreateTab("Teleport", iconTeleport)
local pgConfig = CreateTab("Configs", iconConfig)

-- --- PAGE FARM ---
CreateTitle(pgFarm, "Combat Target")
CreateDropdown(pgFarm, "Select Monster", MobNames, selectedMob, function(v) selectedMob = v end)
CreateToggle(pgFarm, "Auto Farm Monster", false, function(v) 
	autoFarmMob = v; 
	if v then 
		autoFarmBoss, autoFarmTower, killauraEnabled = false, false, false
		isOnRightIsland = false 
		startCombatLoop() 
	end 
end)

CreateDropdown(pgFarm, "Select Boss", BossNames, selectedBoss, function(v) selectedBoss = v end)
CreateToggle(pgFarm, "Auto Farm Boss", false, function(v) 
	autoFarmBoss = v; 
	if v then 
		autoFarmMob, autoFarmTower, killauraEnabled = false, false, false
		isOnRightIsland = false
		startCombatLoop() 
	end 
end)

CreateToggle(pgFarm, "Auto Farm Nearest (Tower)", false, function(v) autoFarmTower = v; if v then autoFarmMob, autoFarmBoss, killauraEnabled = false, false, false; startCombatLoop() end end)

CreateTitle(pgFarm, "Auto Skills")
CreateDropdown(pgFarm, "Select Skill", {"All", "Z", "X", "C", "V", "F"}, "All", function(v) selectedSkill = v end)
CreateToggle(pgFarm, "Enable Auto Skills", false, function(v) autoSkillEnabled = v end)

CreateTitle(pgFarm, "Settings & Speed")
CreateSlider(pgFarm, "Tween Speed (Approche)", 50, 500, 150, function(v) tweenSpeed = v end)
CreateSlider(pgFarm, "Distance From Target (Height)", 0, 30, 8, function(v) mobHeight = v end)

CreateTitle(pgFarm, "Combat Assist")
CreateToggle(pgFarm, "KillAura", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss, autoFarmTower = false, false, false; startCombatLoop() end end)
CreateSlider(pgFarm, "Attack Radius", 10, 1000, 500, function(v) combatRadius = v end)

-- --- PAGE PLAYER ---
CreateTitle(pgPlayer, "Local Player")
CreateSlider(pgPlayer, "WalkSpeed", 16, 250, 50, function(v) walkSpeedValue = v; updateSpeed() end)
CreateToggle(pgPlayer, "Enable WalkSpeed", false, function(v) walkSpeedEnabled = v; updateSpeed() end)
CreateToggle(pgPlayer, "Infinite Jump", false, function(v) infJumpEnabled = v end)

CreateTitle(pgPlayer, "Exploits")
CreateSlider(pgPlayer, "Fly Speed", 10, 300, 50, function(v) flySpeedValue = v end)
CreateToggle(pgPlayer, "Fly Mode", false, function(v) flyEnabled = v; toggleFly() end)
CreateToggle(pgPlayer, "No Clip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)

-- --- PAGE TELEPORT ---
CreateTitle(pgTp, "World Travel (Islands)")
CreateDropdown(pgTp, "Select Island", IslandNames, selectedIsland, function(v) selectedIsland = v end)
CreateButton(pgTp, "Teleport to Island", function() teleportToIsland(selectedIsland) end)

CreateTitle(pgTp, "NPC Teleport")
CreateDropdown(pgTp, "Select NPC", NpcNames, selectedNPC, function(v) selectedNPC = v end)
CreateButton(pgTp, "Teleport to NPC", function() teleportToSpecificNPC(selectedNPC) end)

-- --- PAGE CONFIGS ---
CreateTitle(pgConfig, "Menu Settings")
CreateKeybind(pgConfig, "Toggle UI Key", UIConfig.ToggleKey, function(newKey) UIConfig.ToggleKey = newKey end)
CreateSlider(pgConfig, "Menu Opacity", 10, 100, 80, function(v) mainFrame.BackgroundTransparency = 1 - (v/100) end)
CreateButton(pgConfig, "Unload Interface", function() if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end end)

-- Dragging Main
local dragS, dragP, startP
local topDrag = Instance.new("TextButton", mainFrame); topDrag.Size = UDim2.new(1,0,0,40); topDrag.BackgroundTransparency = 1; topDrag.Text = ""
topDrag.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; dragP = input.Position; startP = mainFrame.Position end end)
UIS.InputChanged:Connect(function(input) if dragS and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragP; mainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end end)

UIS.InputBegan:Connect(function(input, gp) 
	if not gp and input.KeyCode == UIConfig.ToggleKey and not isBindingAny then 
		mainFrame.Visible = not mainFrame.Visible 
	end 
end)

-- Init
navList:GetChildren()[2].MouseButton1Click:Fire()
print("MxF Hub The Ultimate Edition Chargé avec Bypass Anti-Cheat !")
