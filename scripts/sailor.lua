-- ======================================================
-- 👑 MxF HUB - SPEED HUB X EDITION (FINAL V19)
-- Zero Jitter Farm, Auto Summon Boss, Clean UI
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

-- Mapping complet des NPCs
local NpcIslandMap = {
	["DungeonMerchantNPC"] = "Dungeon", ["DungeonPortalsNPC"] = "Dungeon", ["ShadowMonarchBuyerNPC"] = "Dungeon", ["CidBuyer"] = "Dungeon",
	["SummonBossNPC"] = "Boss", ["ExchangeNPC"] = "Boss", ["MoonSlayerBuff"] = "Boss", ["GilgameshBuyerNPC"] = "Boss", ["SaberAlterBuyerNPC"] = "Boss", ["GrailCraftNPC"] = "Boss", ["BabylonCraftNPC"] = "Boss", ["SaberAlterMasteryNPC"] = "Boss", ["QinShiBuyer"] = "Boss", ["MoonSlayerSeller"] = "Boss", ["BlessedMaidenBuyerNPC"] = "Boss", ["BlessedMaidenMasteryNPC"] = "Boss",
	["QuestNPC4"] = "Jungle", ["QuestNPC3"] = "Jungle",
	["QuestNPC5"] = "DesertIsland", ["ObservationBuyer"] = "DesertIsland", ["QuestNPC6"] = "DesertIsland",
	["DarkBladeNPC"] = "SnowIsland", ["RagnaQuestlineBuff"] = "SnowIsland", ["RagnaBuyer"] = "SnowIsland", ["HakiQuestNPC"] = "SnowIsland", ["ArtifactsUnlocker"] = "SnowIsland", ["ArtifactMilestoneNPC"] = "SnowIsland", ["QuestNPC7"] = "SnowIsland", ["QuestNPC8"] = "SnowIsland",
	["AscendNPC"] = "Sailor", ["StorageNPC"] = "Sailor", ["TitlesNPC"] = "Sailor", ["GemFruitDealer"] = "Sailor", ["MerchantNPC"] = "Sailor", ["CoinFruitDealer"] = "Sailor", ["RerollStatNPC"] = "Sailor", ["TraitNPC"] = "Sailor", ["BossRushShopNPC"] = "Sailor", ["BossRushPortalNPC"] = "Sailor", ["BossRushMerchantNPC"] = "Sailor", ["JinwooMovesetNPC"] = "Sailor", ["AlucardBuyer"] = "Sailor",
	["GryphonBuyerNPC"] = "Shibuya", ["BlessingNPC"] = "Shibuya", ["EnchantNPC"] = "Shibuya", ["GojoMovesetNPC"] = "Shibuya", ["YujiBuyerNPC"] = "Shibuya", ["SukunaMovesetNPC"] = "Shibuya", ["QuestNPC9"] = "Shibuya", ["QuestNPC10"] = "Shibuya", ["ConquerorHakiNPC"] = "Shibuya",
	["IchigoBuyer"] = "Hollow", ["AizenQuestlineBuff"] = "Hollow", ["HogyokuQuestNPC"] = "Hollow", ["AizenMovesetNPC"] = "Hollow", ["QuestNPC11"] = "Hollow",
	["QuestNPC12"] = "Shinjuku", ["QuestNPC13"] = "Shinjuku", ["StrongestinHistoryBuyerNPC"] = "Shinjuku", ["SukunaMasteryNPC"] = "Shinjuku", ["StrongestBossSummonerNPC"] = "Shinjuku", ["GojoCraftNPC"] = "Shinjuku", ["GojoMasteryNPC"] = "Shinjuku", ["SukunaCraftNPC"] = "Shinjuku", ["StrongestofTodayBuyerNPC"] = "Shinjuku",
	["QuestNPC14"] = "Slime", ["RimuruSummonerNPC"] = "Slime", ["SkillTreeNPC"] = "Slime", ["SlimeCraftNPC"] = "Slime", ["RimuruBuyer"] = "Slime", ["RimuruMasteryNPC"] = "Slime",
	["AnosQuestNPC"] = "Academy", ["AnosBossSummonerNPC"] = "Academy", ["QuestNPC15"] = "Academy", ["AnosBuyerNPC"] = "Academy",
	["SpecPassivesNPC"] = "Judgement", ["QuestNPC16"] = "Judgement", ["YamatoBuyerNPC"] = "Judgement",
	["TrueAizenBossSummonerNPC"] = "Soul", ["TrueAizenBuyerNPC"] = "Soul", ["TrueAizenFUnlockNPC"] = "Soul", ["QuestNPC17"] = "Soul",
	["GroupRewardNPC"] = "Starter", ["QuestNPC2"] = "Starter", ["ShadowMonarchQuestlineBuff"] = "Starter", ["QuestNPC1"] = "Starter", ["Katana"] = "Starter", ["ShadowQuestlineBuff"] = "Starter", ["MadokaBuyer"] = "Starter",
	["QuestNPC18"] = "Ninja", ["StrongestShinobiMasteryNPC"] = "Ninja", ["StrongestShinobiBuyerNPC"] = "Ninja",
	["PowerNPC"] = "Lawless", ["AtomicBossSummonerNPC"] = "Lawless", ["QuestNPC19"] = "Lawless", ["AtomicBuyer"] = "Lawless", ["AtomicQuestlineBuff"] = "Lawless",
	["InfiniteTowerMerchantNPC"] = "Tower", ["InfiniteTowerPortalNPC"] = "Tower", ["InfiniteTowerStatShopNPC"] = "Tower"
}

local NpcNames = {}
for npcName, _ in pairs(NpcIslandMap) do table.insert(NpcNames, npcName) end

local MobNames, BossNames, IslandNames = {}, {}, {}
for m, i in pairs(MobDatabase) do table.insert(MobNames, m); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end
for b, i in pairs(BossDatabase) do table.insert(BossNames, b); if not table.find(IslandNames, i) then table.insert(IslandNames, i) end end

local ExtraIslands = {"Dungeon", "Boss", "Sailor", "Tower", "DesertIsland", "SnowIsland"}
for _, island in ipairs(ExtraIslands) do if not table.find(IslandNames, island) then table.insert(IslandNames, island) end end

table.sort(MobNames); table.sort(BossNames); table.sort(IslandNames); table.sort(NpcNames)

-- Shop Variables
local shopItemsList = {"Dungeon Key", "Boss Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Passive Shard", "Trait Reroll", "Clan Reroll"}
local selectedShopItem = shopItemsList[1]
local shopBuyAmount = 1
local shopBuyDelay = 0
local autoBuyEnabled = false
local autoBuyCoroutine = nil

-- Auto Stats Variables
local autoStatsEnabled = false
local statPoints = {Melee = 1, Defense = 1, Sword = 1, Power = 1}
local autoStatsToggles = {Melee = false, Defense = false, Sword = false, Power = false}
local autoStatsCoroutine = nil

-- Auto Summon Boss Variables
local summonBossesList = {"SaberBoss", "QinShiBoss", "IchigoBoss", "GilgameshBoss", "BlessedMaidenBoss", "SaberAlterBoss", "MoonSlayerBoss"}
local selectedSummonBoss = summonBossesList[1]
local difficultyList = {"Normal", "Medium", "Hard", "Extreme"}
local selectedDifficulty = difficultyList[1]
local bossesWithDifficulty = { ["GilgameshBoss"] = true, ["BlessedMaidenBoss"] = true, ["SaberAlterBoss"] = true, ["MoonSlayerBoss"] = true }

-- Combat & Target Variables
local selectedMob, selectedBoss, selectedIsland, selectedNPC = MobNames[1], BossNames[1], IslandNames[1], NpcNames[1]
local autoFarmMob, autoFarmBoss, autoFarmTower, killauraEnabled = false, false, false, false
local isOnRightIsland = false 
local currentFarmIsland = ""
local selectedSkill = "All"
local autoSkillEnabled = false
local targetPlayers = false
local auraTargetsFarmMob = false 
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
	local steps = math.ceil(dist / 35)
	
	if steps > 0 then
		for i = 1, steps do
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then break end
			player.Character.HumanoidRootPart.CFrame = root.CFrame:Lerp(targetCFrame, i / steps)
			task.wait() 
		end
	end
	
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = targetCFrame
	end
end

local function teleportToSpecificNPC(npcName)
	local targetIsland = NpcIslandMap[npcName] or "Starter"
	
	teleportToIsland(targetIsland)
	task.wait(3.5) 
	
	local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild(npcName)
	if npc and npc:FindFirstChild("HumanoidRootPart") then
		local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
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
	
	if targetPlayers and targetName ~= "NearestTower" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local hum = p.Character:FindFirstChild("Humanoid")
				local root = p.Character:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and root then
					local dist = (root.Position - myPos).Magnitude
					if dist <= combatRadius and dist < minDist then minDist = dist; closest = p.Character end
				end
			end
		end
	end
	
	return closest, minDist
end

-- ✅ COMBAT SYSTEM (ANTI-JITTER PERFECT HOLD)
local function startCombatLoop()
	if combatCoroutine then task.cancel(combatCoroutine) end
	combatCoroutine = task.spawn(function()
		local hitRemote = game:GetService("ReplicatedStorage"):WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
		
		while autoFarmMob or autoFarmBoss or autoFarmTower or killauraEnabled do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				local hum = char.Humanoid
				
				-- Création de l'Anti-Tremblote (BodyVelocity invisible)
				local farmHold = root:FindFirstChild("FarmHold")
				if not farmHold then
					farmHold = Instance.new("BodyVelocity")
					farmHold.Name = "FarmHold"
					farmHold.Velocity = Vector3.zero
					farmHold.MaxForce = Vector3.new(0, 0, 0)
					farmHold.Parent = root
				end
				
				if autoFarmMob or autoFarmBoss or autoFarmTower then
					hum.PlatformStand = true
					
					local tName = autoFarmTower and "NearestTower" or (autoFarmMob and selectedMob or selectedBoss)
					local island = autoFarmTower and "" or (autoFarmMob and MobDatabase[selectedMob] or BossDatabase[selectedBoss])
					
					if currentFarmIsland ~= island and not autoFarmTower then
						farmHold.MaxForce = Vector3.new(0, 0, 0) -- Coupe l'anti-gravité le temps de TP
						teleportToIsland(island)
						task.wait(3.5)
						currentFarmIsland = island
						continue 
					end
					
					local target, dist = getTarget(tName, true)
					currentTarget = target
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						isOnRightIsland = true 
						
						local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, mobHeight, 0)
						local targetCFrame = CFrame.new(tpPos) * CFrame.Angles(math.rad(-90), 0, 0)

						if dist > 15 then
							farmHold.MaxForce = Vector3.new(0, 0, 0)
							local tTime = math.clamp(dist / tweenSpeed, 0.05, 3)
							TweenService:Create(root, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame}):Play()
						else
							-- Active l'Anti-Tremblote (Gèle parfaitement le perso en l'air)
							farmHold.MaxForce = Vector3.new(1e5, 1e5, 1e5)
							root.CFrame = targetCFrame
							pcall(function() hitRemote:FireServer() end)
						end
					else 
						farmHold.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						if not autoFarmTower then
							if not isOnRightIsland then
								farmHold.MaxForce = Vector3.new(0, 0, 0)
								teleportToIsland(island)
								task.wait(3.5)
								isOnRightIsland = true
							else
								root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
							end
						else
							root.Velocity, root.RotVelocity = Vector3.zero, Vector3.zero
						end
					end
				elseif killauraEnabled then
					farmHold.MaxForce = Vector3.new(0, 0, 0)
					if not flyEnabled then hum.PlatformStand = false end
					
					local tName = auraTargetsFarmMob and selectedMob or nil
					local target, dist = getTarget(tName, auraTargetsFarmMob)
					currentTarget = target
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						local targetPos = target.HumanoidRootPart.Position
						root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
						pcall(function() hitRemote:FireServer() end)
					end
				end
			end
			task.wait(combatCooldown)
		end
		
		-- Nettoyage si on désactive
		if player.Character then
			local farmHold = player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("FarmHold")
			if farmHold then farmHold:Destroy() end
			if not flyEnabled and player.Character:FindFirstChild("Humanoid") then
				player.Character.Humanoid.PlatformStand = false
			end
		end
	end)
end

-- AUTO SKILLS LOOP
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

-- AUTO STATS LOOP
local function startAutoStatsLoop()
	if autoStatsCoroutine then task.cancel(autoStatsCoroutine) end
	autoStatsCoroutine = task.spawn(function()
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AllocateStat")
		while autoStatsEnabled do
			for statName, isEnabled in pairs(autoStatsToggles) do
				if isEnabled then
					pcall(function() 
						local points = math.clamp(statPoints[statName] or 1, 1, 13000)
						remote:FireServer(statName, points) 
					end)
				end
			end
			task.wait(2.5)
		end
	end)
end

-- AUTO BUY (SHOP) LOOP
local function startAutoBuyLoop()
	if autoBuyCoroutine then task.cancel(autoBuyCoroutine) end
	autoBuyCoroutine = task.spawn(function()
		local merchantRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")
		while autoBuyEnabled do
			pcall(function()
				local args = { selectedShopItem, tonumber(shopBuyAmount) or 1 }
				merchantRemote:InvokeServer(unpack(args))
			end)
			task.wait(shopBuyDelay > 0 and shopBuyDelay or 0.1)
		end
	end)
end

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
-- 3. MOTEUR UI (SECTIONS COLLAPSIBLES)
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

local function CreateSection(page, text, defaultOpen)
	local section = Instance.new("Frame", page)
	section.Size = UDim2.new(1, -10, 0, 40)
	section.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
	section.BackgroundTransparency = 0.2
	section.ClipsDescendants = true
	Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", section).Color = Color3.fromRGB(40, 40, 45)
	
	local btn = Instance.new("TextButton", section)
	btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundTransparency = 1; btn.Text = ""
	
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -30, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 15; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -25, 0, 0); icon.BackgroundTransparency = 1
	icon.Text = defaultOpen and "▼" or "▶"; icon.TextColor3 = Color3.fromRGB(200, 200, 200); icon.Font = Enum.Font.GothamBold; icon.TextSize = 12
	
	local content = Instance.new("Frame", section)
	content.Size = UDim2.new(1, 0, 0, 0); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local isOpen = defaultOpen == true
	
	local function updateSize()
		if isOpen then
			local contentHeight = layout.AbsoluteContentSize.Y + 10 
			TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 40 + contentHeight)}):Play()
			content.Size = UDim2.new(1, 0, 0, contentHeight)
		else
			TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 40)}):Play()
		end
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if isOpen then updateSize() end end)
	
	btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen; icon.Text = isOpen and "▼" or "▶"; updateSize()
		task.delay(0.25, function() 
			if currentTab then 
				local mainLayout = currentTab.page:FindFirstChildOfClass("UIListLayout")
				if mainLayout then currentTab.page.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 20) end
			end 
		end)
	end)
	
	task.delay(0.1, function() if defaultOpen then updateSize() end end)
	return content
end

local function CreateTitle(page, text)
	local frame = Instance.new("Frame", page)
	frame.Size = UDim2.new(1, -10, 0, 35); frame.BackgroundTransparency = 1
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, 0, 1, -5); lbl.BackgroundTransparency = 1; lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local line = Instance.new("Frame", frame)
	line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -2); line.BackgroundColor3 = Color3.fromRGB(50, 50, 60); line.BorderSizePixel = 0
	
	return frame
end

local function CreateRow(page, height)
	local row = Instance.new("Frame", page)
	row.Size = UDim2.new(1, -10, 0, height or 45)
	row.BackgroundTransparency = 1 
	return row
end

local function CreateInput(page, text, placeholder, default, callback)
	local row = CreateRow(page, 45)
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local inputBg = Instance.new("Frame", row)
	inputBg.Size = UDim2.new(0.4, 0, 0, 30); inputBg.Position = UDim2.new(1, -10, 0.5, -15); inputBg.AnchorPoint = Vector2.new(1, 0)
	inputBg.BackgroundColor3 = Color3.fromRGB(30, 31, 35); Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", inputBg).Color = Color3.fromRGB(45, 45, 50)

	local box = Instance.new("TextBox", inputBg)
	box.Size = UDim2.new(1, -10, 1, 0); box.Position = UDim2.new(0, 5, 0, 0); box.BackgroundTransparency = 1
	box.Text = tostring(default); box.PlaceholderText = placeholder; box.TextColor3 = UIConfig.Accent
	box.Font = Enum.Font.GothamBold; box.TextSize = 12

	box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
end

local function CreateToggle(page, text, default, callback)
	local row = CreateRow(page, 45)
	local state = default
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""

	local pill = Instance.new("Frame", row)
	pill.Size = UDim2.new(0, 38, 0, 20); pill.Position = UDim2.new(1, -48, 0.5, -10)
	pill.BackgroundColor3 = state and UIConfig.Accent or Color3.fromRGB(45, 46, 50)
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame", pill)
	circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		state = not state
		local targetColor = state and UIConfig.Accent or Color3.fromRGB(45, 46, 50)
		local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
		callback(state)
	end)
end

local function CreateSlider(page, text, min, max, default, callback)
	local row = CreateRow(page, 55)
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 0, 25); lbl.Position = UDim2.new(0, 10, 0, 5); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size = UDim2.new(0.4, 0, 0, 25); valLbl.Position = UDim2.new(1, -50, 0, 5); valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(default); valLbl.TextColor3 = UIConfig.Accent; valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12; valLbl.TextXAlignment = Enum.TextXAlignment.Right
	
	local sliderBg = Instance.new("TextButton", row)
	sliderBg.Size = UDim2.new(1, -20, 0, 4); sliderBg.Position = UDim2.new(0, 10, 0, 35); sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55); sliderBg.Text = ""
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
	local row = CreateRow(page, 45)
	local currentKey = defaultKey
	
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.4, 0, 0, 28); btn.Position = UDim2.new(1, -10, 0.5, -14); btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.Text = currentKey.Name; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 50)

	local isBinding = false
	btn.MouseButton1Click:Connect(function()
		isBinding = true; isBindingAny = true; btn.Text = "Press Key..."; btn.TextColor3 = UIConfig.Accent
	end)

	UIS.InputBegan:Connect(function(input)
		if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
			currentKey = input.KeyCode; btn.Text = currentKey.Name; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			isBinding = false; task.wait(0.1); isBindingAny = false; if callback then callback(currentKey) end
		end
	end)
end

local function CreateDropdown(page, text, options, default, callback)
	local current = default or options[1]
	local row = CreateRow(page, 45); row.ClipsDescendants = true

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.4, 0, 0, 45); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.5, 0, 0, 30); btn.Position = UDim2.new(1, -10, 0, 7); btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 31, 35); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 50)

	local valTxt = Instance.new("TextLabel", btn)
	valTxt.Size = UDim2.new(1, -30, 1, 0); valTxt.Position = UDim2.new(0, 10, 0, 0); valTxt.BackgroundTransparency = 1
	valTxt.Text = tostring(current); valTxt.TextColor3 = Color3.fromRGB(200, 200, 200); valTxt.Font = Enum.Font.Gotham; valTxt.TextSize = 12; valTxt.TextXAlignment = Enum.TextXAlignment.Left

	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -20, 0, 0); icon.BackgroundTransparency = 1
	icon.Text = "▼"; icon.TextColor3 = Color3.fromRGB(150, 150, 150); icon.Font = Enum.Font.GothamBold; icon.TextSize = 10

	local list = Instance.new("Frame", row)
	list.Size = UDim2.new(1, -20, 0, 0); list.Position = UDim2.new(0, 10, 0, 50); list.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)

	local open = false
	btn.MouseButton1Click:Connect(function()
		open = not open; icon.Text = open and "▲" or "▼"
		local targetSize = open and (layout.AbsoluteContentSize.Y + 60) or 45
		TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
	end)

	for _, opt in ipairs(options) do
		local oBtn = Instance.new("TextButton", list); oBtn.Size = UDim2.new(1, 0, 0, 25); oBtn.BackgroundColor3 = Color3.fromRGB(35, 36, 40)
		oBtn.Text = "  " .. opt; oBtn.TextColor3 = Color3.fromRGB(220, 220, 220); oBtn.Font = Enum.Font.Gotham; oBtn.TextSize = 12; oBtn.TextXAlignment = Enum.TextXAlignment.Left
		Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 4)
		oBtn.MouseButton1Click:Connect(function()
			current = opt; valTxt.Text = opt; open = false; icon.Text = "▼"
			TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45)}):Play()
			if callback then callback(opt) end
		end)
	end
end

local function CreateButton(page, text, callback)
	local row = CreateRow(page, 45)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = text
	btn.TextColor3 = Color3.fromRGB(220, 220, 220); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
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

local iconAuto = "7734053426" 
local iconFarm = "7733674079"
local iconPlayer = "7733954760"
local iconTeleport = "7733992829"
local iconShop = "6031280882" 
local iconConfig = "7734068321" 

local pgAuto = CreateTab("Auto", iconAuto)
local pgFarm = CreateTab("Farm", iconFarm)
local pgSelf = CreateTab("Self", iconPlayer)
local pgTp = CreateTab("Teleport", iconTeleport)
local pgShop = CreateTab("Shop", iconShop)
local pgConfig = CreateTab("Configs", iconConfig)

-- --- PAGE AUTO ---
local secAutoSkills = CreateSection(pgAuto, "Auto Skills", true)
CreateDropdown(secAutoSkills, "Select Skill", {"All", "Z", "X", "C", "V", "F"}, "All", function(v) selectedSkill = v end)
CreateToggle(secAutoSkills, "Enable Auto Skills", false, function(v) autoSkillEnabled = v end)

local secSummon = CreateSection(pgAuto, "Auto Summon Boss", true)
CreateDropdown(secSummon, "Select Boss", summonBossesList, selectedSummonBoss, function(v) selectedSummonBoss = v end)
CreateDropdown(secSummon, "Select Difficulty", difficultyList, selectedDifficulty, function(v) selectedDifficulty = v end)
CreateButton(secSummon, "Summon Boss", function()
	pcall(function()
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss")
		if bossesWithDifficulty[selectedSummonBoss] then
			remote:FireServer(selectedSummonBoss, selectedDifficulty)
		else
			remote:FireServer(selectedSummonBoss)
		end
	end)
end)

local secAutoStatsMaster = CreateSection(pgAuto, "Auto Stats (Controls)", false)
CreateToggle(secAutoStatsMaster, "Enable Auto Stats (Loop)", false, function(v) autoStatsEnabled = v; if v then startAutoStatsLoop() end end)
CreateButton(secAutoStatsMaster, "Reset All Stats", function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ResetStats"):FireServer() end) end)

local secAutoStatsConfig = CreateSection(pgAuto, "Stats Configuration", false)
CreateTitle(secAutoStatsConfig, "Melee")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Melee, function(v) statPoints.Melee = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate Melee", false, function(v) autoStatsToggles.Melee = v end)

CreateTitle(secAutoStatsConfig, "Defense")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Defense, function(v) statPoints.Defense = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate Defense", false, function(v) autoStatsToggles.Defense = v end)

CreateTitle(secAutoStatsConfig, "Sword")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Sword, function(v) statPoints.Sword = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate Sword", false, function(v) autoStatsToggles.Sword = v end)

CreateTitle(secAutoStatsConfig, "Power")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Power, function(v) statPoints.Power = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate Power", false, function(v) autoStatsToggles.Power = v end)

-- --- PAGE FARM ---
local secFarmTarget = CreateSection(pgFarm, "Auto Farm", true)
CreateDropdown(secFarmTarget, "Select Monster", MobNames, selectedMob, function(v) selectedMob = v; currentFarmIsland = "" end)
CreateToggle(secFarmTarget, "Auto Farm Monster", false, function(v) autoFarmMob = v; if v then autoFarmBoss, autoFarmTower, killauraEnabled = false, false, false; startCombatLoop() end end)

CreateDropdown(secFarmTarget, "Select Boss", BossNames, selectedBoss, function(v) selectedBoss = v; currentFarmIsland = "" end)
CreateToggle(secFarmTarget, "Auto Farm Boss", false, function(v) autoFarmBoss = v; if v then autoFarmMob, autoFarmTower, killauraEnabled = false, false, false; startCombatLoop() end end)

CreateToggle(secFarmTarget, "Auto Farm Nearest (Tower)", false, function(v) autoFarmTower = v; if v then autoFarmMob, autoFarmBoss, killauraEnabled = false, false, false; startCombatLoop() end end)

local secFarmSet = CreateSection(pgFarm, "Settings & Speed", false)
CreateSlider(secFarmSet, "Tween Speed (Approche)", 50, 500, 150, function(v) tweenSpeed = v end)
CreateSlider(secFarmSet, "Distance From Target (Height)", 0, 30, 8, function(v) mobHeight = v end)

-- --- PAGE SELF ---
local secAura = CreateSection(pgSelf, "Combat Assist (Aura)", true)
CreateToggle(secAura, "KillAura (Focus Selected Mob)", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss, autoFarmTower = false, false, false; startCombatLoop() end end)
CreateSlider(secAura, "Aura Range (Studs)", 10, 1000, 500, function(v) combatRadius = v end)

local secPlayer = CreateSection(pgSelf, "Local Player", false)
CreateSlider(secPlayer, "WalkSpeed", 16, 250, 50, function(v) walkSpeedValue = v; updateSpeed() end)
CreateToggle(secPlayer, "Enable WalkSpeed", false, function(v) walkSpeedEnabled = v; updateSpeed() end)
CreateToggle(secPlayer, "Infinite Jump", false, function(v) infJumpEnabled = v end)

local secExploits = CreateSection(pgSelf, "Exploits", false)
CreateSlider(secExploits, "Fly Speed", 10, 300, 50, function(v) flySpeedValue = v end)
CreateToggle(secExploits, "Fly Mode", false, function(v) flyEnabled = v; toggleFly() end)
CreateToggle(secExploits, "No Clip", false, function(v) noClipEnabled = v; if v then enableNoClip() else disableNoClip() end end)

-- --- PAGE TELEPORT ---
local secWorld = CreateSection(pgTp, "World Travel (Islands)", true)
CreateDropdown(secWorld, "Select Island", IslandNames, selectedIsland, function(v) selectedIsland = v end)
CreateButton(secWorld, "Teleport to Island", function() teleportToIsland(selectedIsland) end)

local secNPC = CreateSection(pgTp, "NPC Teleport", true)
CreateDropdown(secNPC, "Select NPC", NpcNames, selectedNPC, function(v) selectedNPC = v end)
CreateButton(secNPC, "Teleport to NPC", function() teleportToSpecificNPC(selectedNPC) end)

-- --- PAGE SHOP ---
local secShop = CreateSection(pgShop, "Merchant Shop", true)
CreateDropdown(secShop, "Select Item", shopItemsList, selectedShopItem, function(v) selectedShopItem = v end)
CreateInput(secShop, "Amount to Buy", "Max Quantity", shopBuyAmount, function(v) shopBuyAmount = tonumber(v) or 1 end)
CreateInput(secShop, "Delay To Buy (Seconds)", "Delay", shopBuyDelay, function(v) shopBuyDelay = tonumber(v) or 0 end)
CreateToggle(secShop, "Auto Buy Merchant", false, function(v) autoBuyEnabled = v; if v then startAutoBuyLoop() end end)
CreateButton(secShop, "Buy Once", function() 
	pcall(function() 
		local args = { selectedShopItem, tonumber(shopBuyAmount) or 1 }
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem"):InvokeServer(unpack(args))
	end) 
end)

-- --- PAGE CONFIGS ---
local secConfig = CreateSection(pgConfig, "Menu Settings", true)
CreateKeybind(secConfig, "Toggle UI Key", UIConfig.ToggleKey, function(newKey) UIConfig.ToggleKey = newKey end)
CreateSlider(secConfig, "Menu Opacity", 10, 100, 80, function(v) mainFrame.BackgroundTransparency = 1 - (v/100) end)
CreateButton(secConfig, "Unload Interface", function() if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end end)

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
navList:GetChildren()[1].MouseButton1Click:Fire()
print("MxF Hub The Ultimate Edition Chargé !")
