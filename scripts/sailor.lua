-- ======================================================
-- 👑 MxF HUB - SPEED HUB X EDITION (FINAL V34 - ULTIMATE)
-- Smart Boss Queue & Menu Resizer Added
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
-- 1. CONFIGURATION & VARIABLES
-- ==========================================
local API_URL = "https://accepting-newark-symposium-mortality.trycloudflare.com/verify"
local API_SECRET = "4IfE6mMxbO_flFZKyRNRt1hznL3Q3sWJRChck5C83DA"

local ConfigFileName = "MxFHub_Settings.json"
local CurrentSettings = {
	Theme = "Default",
	Font = "Gotham",
	Opacity = 0.85,
	TextSizeOffset = 1,
	MenuSize = 100, -- NOUVEAU: Taille du menu en %
	SavedKey = ""
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

local Fonts = {
	["Gotham"] = Enum.Font.GothamBold, ["Code"] = Enum.Font.Code, ["SciFi"] = Enum.Font.Michroma,
	["Arcade"] = Enum.Font.Arcade, ["Jura"] = Enum.Font.Jura, ["Nunito"] = Enum.Font.Nunito
}
local FontNames = {"Gotham", "Code", "SciFi", "Arcade", "Jura", "Nunito"}

local function SaveSettings()
	if writefile then pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(CurrentSettings)) end) end
end
local function LoadSettings()
	if readfile and isfile and isfile(ConfigFileName) then
		pcall(function()
			local data = HttpService:JSONDecode(readfile(ConfigFileName))
			for k,v in pairs(data) do CurrentSettings[k] = v end
		end)
	end
end
LoadSettings()

local UIConfig = { WindowSize = UDim2.new(0, 760, 0, 520), ToggleKey = Enum.KeyCode.Insert }

local MobDatabase = {
	["AcademyTeacher"] = "Academy", ["ArenaFighter"] = "Lawless", ["Curse"] = "Shinjuku",
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
local NpcIslandMap = {
	["DungeonMerchantNPC"] = "Dungeon", ["DungeonPortalsNPC"] = "Dungeon", ["ShadowMonarchBuyerNPC"] = "Dungeon", ["CidBuyer"] = "Dungeon",
	["SummonBossNPC"] = "Boss", ["ExchangeNPC"] = "Boss", ["MoonSlayerBuff"] = "Boss", ["GilgameshBuyerNPC"] = "Boss", ["SaberAlterBuyerNPC"] = "Boss", ["GrailCraftNPC"] = "Boss", ["BabylonCraftNPC"] = "Boss", ["SaberAlterMasteryNPC"] = "Boss", ["QinShiBuyer"] = "Boss", ["MoonSlayerSeller"] = "Boss", ["BlessedMaidenBuyerNPC"] = "Boss", ["BlessedMaidenMasteryNPC"] = "Boss",
	["QuestNPC4"] = "Jungle", ["QuestNPC3"] = "Jungle",
	["QuestNPC5"] = "Desert", ["ObservationBuyer"] = "Desert", ["QuestNPC6"] = "Desert",
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
local ExtraIslands = {"Dungeon", "Boss", "Sailor", "Tower", "Desert", "SnowIsland"}
for _, island in ipairs(ExtraIslands) do if not table.find(IslandNames, island) then table.insert(IslandNames, island) end end

table.sort(MobNames); table.sort(BossNames); table.sort(IslandNames); table.sort(NpcNames)

local chestTypesList = {"All", "Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest"}
local selectedChestType = chestTypesList[1]
local chestAmountToOpen = 1
local autoChestEnabled = false; local autoChestCoroutine = nil

local shopItemsList = {"Dungeon Key", "Boss Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Passive Shard", "Trait Reroll", "Clan Reroll"}
local selectedShopItem = shopItemsList[1]
local shopBuyAmount = 1; local shopBuyDelay = 0; local autoBuyEnabled = false; local autoBuyCoroutine = nil

local autoStatsEnabled = false
local statPoints = {Melee = 1, Defense = 1, Sword = 1, Power = 1}
local autoStatsToggles = {Melee = false, Defense = false, Sword = false, Power = false}
local autoStatsCoroutine = nil

local summonBossesList = {"SaberBoss", "QinShiBoss", "IchigoBoss", "GilgameshBoss", "BlessedMaidenBoss", "SaberAlterBoss", "MoonSlayerBoss", "TrueAizenBoss", "AtomicBoss", "StrongestTodayBoss (Gojo)", "StrongestHistoryBoss (Sukuna)"}
local SummonBossConfig = {
	["SaberBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = false, TargetName = "Saber" },
	["QinShiBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = false, TargetName = "Qin" },
	["IchigoBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = false, TargetName = "Ichigo" },
	["GilgameshBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = true, TargetName = "Gilgamesh" },
	["BlessedMaidenBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = true, TargetName = "Blessed" },
	["SaberAlterBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = true, TargetName = "Saber Alter" },
	["MoonSlayerBoss"] = { RemoteType = 1, Island = "Boss", HasDiff = true, TargetName = "Moon" },
	["TrueAizenBoss"] = { RemoteType = 2, Island = "SoulDominion", HasDiff = true, TargetName = "True" },
	["AtomicBoss"] = { RemoteType = 3, Island = "Lawless", HasDiff = true, TargetName = "Atomic" },
	["StrongestTodayBoss (Gojo)"] = { RemoteType = 4, Island = "Shinjuku", HasDiff = true, PrefixArg = "StrongestToday", TargetName = "Gojo" },
	["StrongestHistoryBoss (Sukuna)"] = { RemoteType = 4, Island = "Shinjuku", HasDiff = true, PrefixArg = "StrongestHistory", TargetName = "Sukuna" }
}

local selectedSummonBoss = summonBossesList[1]
local difficultyList = {"Normal", "Medium", "Hard", "Extreme"}; local selectedDifficulty = difficultyList[1]
local summonBossAmount = 1; local currentSummonCount = 0
local autoFarmSummonBossEnabled = false; local autoFarmSummonToggleFunc = nil

local selectedMob, selectedBoss, selectedIsland, selectedNPC = MobNames[1], BossNames[1], IslandNames[1], NpcNames[1]
local autoFarmMob, autoFarmBoss, autoFarmTower, killauraEnabled = false, false, false, false
local isOnRightIsland, currentFarmIsland = false, ""
local selectedSkill = "All"; local autoSkillEnabled = false
local targetPlayers, auraTargetsFarmMob = false, false
local mobHeight, tweenSpeed, combatCooldown, combatRadius = 8, 150, 0.1, 500
local combatCoroutine, currentTarget = nil, nil

local walkSpeedEnabled, walkSpeedValue = false, 50
local flyEnabled, flySpeedValue = false, 50
local infJumpEnabled, noClipEnabled = false, false
local bodyVelocity, bodyGyro, speedConn, flyConn, noClipConn
local isBindingAny = false

-- FOLLOW PLAYER VARS
local followTargetName = ""
local isFollowingPlayer = false
local followConnection = nil
local followToggleFunc = nil
local tabFunctions = {} 

-- ==========================================
-- 2. BACK-END LOGIC
-- ==========================================
local function teleportToIsland(islandName)
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
end

local function safeLerpTP(targetCFrame)
	local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
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
	task.wait(0.5) 
	pcall(function()
		local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild(npcName)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if npc and npc:FindFirstChild("HumanoidRootPart") and root and hum then
			local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
			local dist = (root.Position - targetCFrame.Position).Magnitude
			local flyTime = dist / 110 
			hum.PlatformStand = true
			local tween = TweenService:Create(root, TweenInfo.new(flyTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
			tween:Play(); tween.Completed:Wait(); hum.PlatformStand = false
		else print("Error: NPC " .. npcName .. " not found on " .. targetIsland) end
	end)
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
				if targetName == "NearestTower" then match = true 
				elseif isSpecific then
					if string.sub(obj.Name, 1, #targetName) == targetName then
						if targetName == "Thief" and string.find(obj.Name, "Boss") then match = false end
					else match = false end
				end
				
				if match then
					local hum = obj:FindFirstChild("Humanoid"); local root = obj:FindFirstChild("HumanoidRootPart")
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

local function findTargetPlayer(name)
	if not name or name == "" then return nil end
	name = name:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and (p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name) then
			return p
		end
	end
	return nil
end

local function startCombatLoop()
	if combatCoroutine then task.cancel(combatCoroutine) end
	combatCoroutine = task.spawn(function()
		local hitRemote = game:GetService("ReplicatedStorage"):WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
		while autoFarmMob or autoFarmBoss or autoFarmTower or autoFarmSummonBossEnabled or killauraEnabled do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart; local hum = char.Humanoid
				
				pcall(function()
					if not char:FindFirstChildOfClass("Tool") then
						local tool = player.Backpack:FindFirstChildOfClass("Tool")
						if tool then hum:EquipTool(tool) end
					end
				end)
				
				local float = root:FindFirstChild("FarmFloat")
				if not float then
					float = Instance.new("BodyVelocity")
					float.Name = "FarmFloat"; float.MaxForce = Vector3.new(0, 0, 0); float.Velocity = Vector3.zero; float.Parent = root
				end
				
				if autoFarmMob or autoFarmBoss or autoFarmTower or autoFarmSummonBossEnabled then
					hum.PlatformStand = true
					local tName, island
					if autoFarmSummonBossEnabled then
						local conf = SummonBossConfig[selectedSummonBoss]
						tName = conf.TargetName; island = conf.Island
					elseif autoFarmTower then
						tName = "NearestTower"; island = ""
					else
						tName = autoFarmMob and selectedMob or selectedBoss
						island = autoFarmMob and MobDatabase[selectedMob] or BossDatabase[selectedBoss]
					end
					
					if currentFarmIsland ~= island and not autoFarmTower then
						float.MaxForce = Vector3.new(0, 0, 0)
						teleportToIsland(island); task.wait(3.5); currentFarmIsland = island; continue 
					end
					
					local target, dist = getTarget(tName, true)
					currentTarget = target
					
					if target and target:FindFirstChild("HumanoidRootPart") then
						isOnRightIsland = true 
						local tpPos = target.HumanoidRootPart.Position + Vector3.new(0, mobHeight, 0)
						local targetCFrame = CFrame.new(tpPos) * CFrame.Angles(math.rad(-90), 0, 0)

						if dist > 15 then
							float.MaxForce = Vector3.new(0, 0, 0)
							local tTime = math.clamp(dist / tweenSpeed, 0.05, 3)
							TweenService:Create(root, TweenInfo.new(tTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame}):Play()
						else
							float.MaxForce = Vector3.new(100000, 100000, 100000)
							root.CFrame = targetCFrame
							pcall(function() hitRemote:FireServer() end)
						end
					else 
						float.MaxForce = Vector3.new(100000, 100000, 100000)
						
						-- ✅ SMART SUMMON BOSS LOGIC
						if autoFarmSummonBossEnabled then
							if currentSummonCount < summonBossAmount then
								pcall(function()
									local rs = game:GetService("ReplicatedStorage")
									local conf = SummonBossConfig[selectedSummonBoss]
									if conf.RemoteType == 1 then
										local rem = rs:WaitForChild("Remotes"):WaitForChild("RequestSummonBoss")
										if conf.HasDiff then rem:FireServer(selectedSummonBoss, selectedDifficulty) else rem:FireServer(selectedSummonBoss) end
									elseif conf.RemoteType == 2 then
										rs:WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnTrueAizen"):FireServer(selectedDifficulty)
									elseif conf.RemoteType == 3 then
										rs:WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnAtomic"):FireServer(selectedDifficulty)
									elseif conf.RemoteType == 4 then
										rs:WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss"):FireServer(conf.PrefixArg, selectedDifficulty)
									end
								end)
								currentSummonCount = currentSummonCount + 1
								
								local waited = 0
								while waited < 15 do
									task.wait(1)
									waited = waited + 1
									local checkTarget = getTarget(tName, true)
									if checkTarget then break end
								end
							else
								autoFarmSummonBossEnabled = false; currentSummonCount = 0
								if autoFarmSummonToggleFunc then autoFarmSummonToggleFunc(false) end
							end
						else
							if not autoFarmTower then
								if not isOnRightIsland then teleportToIsland(island); task.wait(3.5); isOnRightIsland = true end
							end
						end
					end
					
				elseif killauraEnabled then
					float.MaxForce = Vector3.new(0, 0, 0)
					if not flyEnabled then hum.PlatformStand = false end
					
					local target, dist = getTarget(selectedMob, true)
					currentTarget = target
					if target and target:FindFirstChild("HumanoidRootPart") then
						local targetRoot = target.HumanoidRootPart
						root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
						
						local currentTool = char:FindFirstChildOfClass("Tool")
						if not currentTool then
							local tool = player.Backpack:FindFirstChildOfClass("Tool")
							if tool then hum:EquipTool(tool) end
							currentTool = tool
						end

						if currentTool then
							for _, part in ipairs(currentTool:GetDescendants()) do
								if part:IsA("BasePart") and (part.Name == "Hitbox" or part.Name == "Handle" or part.Name == "Blade") then
									part.Massless = true; part.CanCollide = false
									part.Size = Vector3.new(combatRadius, combatRadius, combatRadius)
									part.CFrame = targetRoot.CFrame
								end
							end
						end
						pcall(function() hitRemote:FireServer() end)
						VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.02); VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
					end
				end
			end
			task.wait(combatCooldown)
		end
		
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local float = player.Character.HumanoidRootPart:FindFirstChild("FarmFloat")
			if float then float:Destroy() end
		end
		if player.Character and not flyEnabled and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end
	end)
end

task.spawn(function()
	while task.wait(0.5) do
		if autoSkillEnabled and currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 and (autoFarmMob or autoFarmBoss or autoFarmTower or autoFarmSummonBossEnabled or killauraEnabled) then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local tRoot = currentTarget:FindFirstChild("HumanoidRootPart")
			if root and tRoot and (root.Position - tRoot.Position).Magnitude < 40 then
				if selectedSkill == "All" then
					local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F}
					for _, k in ipairs(keys) do VIM:SendKeyEvent(true, k, false, game); task.wait(0.05); VIM:SendKeyEvent(false, k, false, game) end
				elseif selectedSkill == "All (No V)" then
					local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.F}
					for _, k in ipairs(keys) do VIM:SendKeyEvent(true, k, false, game); task.wait(0.05); VIM:SendKeyEvent(false, k, false, game) end
				else
					local k = Enum.KeyCode[selectedSkill]; VIM:SendKeyEvent(true, k, false, game); task.wait(0.05); VIM:SendKeyEvent(false, k, false, game)
				end
			end
		end
	end
end)

local function startAutoChestLoop()
	if autoChestCoroutine then task.cancel(autoChestCoroutine) end
	autoChestCoroutine = task.spawn(function()
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseItem")
		local allChests = {"Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest"}
		while autoChestEnabled do
			pcall(function()
				if selectedChestType == "All" then
					for _, chest in ipairs(allChests) do remote:FireServer("Use", chest, tonumber(chestAmountToOpen) or 1, false); task.wait(0.4) end
				else remote:FireServer("Use", selectedChestType, tonumber(chestAmountToOpen) or 1, false) end
			end)
			task.wait(1.5)
		end
	end)
end

local function startAutoStatsLoop()
	if autoStatsCoroutine then task.cancel(autoStatsCoroutine) end
	autoStatsCoroutine = task.spawn(function()
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AllocateStat")
		while autoStatsEnabled do
			for statName, isEnabled in pairs(autoStatsToggles) do
				if isEnabled then pcall(function() remote:FireServer(statName, math.clamp(statPoints[statName] or 1, 1, 13000)) end) end
			end
			task.wait(2.5)
		end
	end)
end

local function startAutoBuyLoop()
	if autoBuyCoroutine then task.cancel(autoBuyCoroutine) end
	autoBuyCoroutine = task.spawn(function()
		local merchantRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")
		while autoBuyEnabled do
			pcall(function() merchantRemote:InvokeServer(selectedShopItem, tonumber(shopBuyAmount) or 1) end)
			task.wait(shopBuyDelay > 0 and shopBuyDelay or 0.1)
		end
	end)
end

local function updateSpeed()
	if speedConn then speedConn:Disconnect() end
	if walkSpeedEnabled then speedConn = RunService.Heartbeat:Connect(function() if player.Character then player.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
	else if player.Character then player.Character.Humanoid.WalkSpeed = 16 end end
end

UIS.JumpRequest:Connect(function() if infJumpEnabled and player.Character then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

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
	if not flyEnabled then if player.Character then player.Character.Humanoid.PlatformStand = false end return end
	local char = player.Character; if not char then return end
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
	if autoFarmMob or autoFarmBoss or autoFarmTower or autoFarmSummonBossEnabled or killauraEnabled then startCombatLoop() end
	
	if isFollowingPlayer then
		isFollowingPlayer = false
		if followConnection then followConnection:Disconnect(); followConnection = nil end
		if followToggleFunc then followToggleFunc(false) end
	end
end)

-- ==========================================
-- 3. MOTEUR UI & KEY SYSTEM (API PYTHON FIX)
-- ==========================================
local requestFunc = request or http_request or (http and http.request) or syn and syn.request
local hwid = ""
pcall(function()
	if gethwid then hwid = gethwid()
	else hwid = game:GetService("RbxAnalyticsService"):GetClientId() end
end)

local function VerifyKey(keyToTest)
	if not requestFunc then return false, "Executor not supported (missing request)" end
	if keyToTest == "" then return false, "Please enter a key" end

	local userId = tostring(player.UserId)
	local queryUrl = string.format("%s?key=%s&user_id=%s&hwid=%s", API_URL, keyToTest, userId, hwid)

	local success, response = pcall(function()
		return requestFunc({Url = queryUrl, Method = "GET", Headers = {["x-api-secret"] = API_SECRET}})
	end)

	if success and response then
		if response.StatusCode == 200 then
			local successJson, responseBody = pcall(function() return HttpService:JSONDecode(response.Body) end)
			if successJson and type(responseBody) == "table" then
				if responseBody.valid == true then return true, responseBody.message or "Success"
				else return false, responseBody.message or "Invalid key" end
			else return false, "API read error" end
		elseif response.StatusCode == 429 then return false, "Too many requests, try again later."
		else return false, "API Error (" .. tostring(response.StatusCode) .. ")" end
	end
	return false, "API connection error"
end

local overlayGui = Instance.new("ScreenGui", targetGui)
overlayGui.Name = "MxFHubOverlay"; overlayGui.DisplayOrder = 90 
local overlayFrame = Instance.new("Frame", overlayGui)
overlayFrame.Size = UDim2.new(10, 0, 10, 0); overlayFrame.Position = UDim2.new(-5, 0, -5, 0); overlayFrame.Visible = false

local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubPremium"; screenGui.DisplayOrder = 100 

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UIConfig.WindowSize; mainFrame.Position = UDim2.new(0.5, -380, 0.5, -260)
mainFrame.BorderSizePixel = 0; mainFrame:SetAttribute("BgRole", "Main")
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
mainFrame.Visible = false

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 1.2; stroke:SetAttribute("StrokeRole", "Stroke")

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 200, 1, 0); sidebar.BorderSizePixel = 0; sidebar:SetAttribute("BgRole", "Side")
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local logoImg = Instance.new("ImageLabel", sidebar)
logoImg.Size = UDim2.new(0, 45, 0, 45); logoImg.Position = UDim2.new(0, 15, 0, 15)
logoImg.BackgroundTransparency = 1; logoImg.ScaleType = Enum.ScaleType.Fit
pcall(function()
	local logoUrl = "https://i.goopics.net/lpt7p1.png"
	if writefile and getcustomasset then
		local data = game:HttpGet(logoUrl); writefile("mxf_logo.png", data)
		logoImg.Image = getcustomasset("mxf_logo.png")
	else logoImg.Image = "rbxassetid://10629237000" end
end)

local hubName = Instance.new("TextLabel", sidebar)
hubName.Size = UDim2.new(1, -70, 0, 45); hubName.Position = UDim2.new(0, 70, 0, 15)
hubName.BackgroundTransparency = 1; hubName.Text = "MxF HUB"
hubName:SetAttribute("TextRole", "Text"); hubName:SetAttribute("BaseTextSize", 20); hubName.TextXAlignment = Enum.TextXAlignment.Left

local searchFrame = Instance.new("Frame", sidebar)
searchFrame.Size = UDim2.new(1, -30, 0, 36); searchFrame.Position = UDim2.new(0, 15, 0, 75)
searchFrame:SetAttribute("BgRole", "Elem"); Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)

local searchIcon = Instance.new("ImageLabel", searchFrame)
searchIcon.Size = UDim2.new(0, 18, 0, 18); searchIcon.Position = UDim2.new(0, 10, 0.5, -9)
searchIcon.Image = "rbxassetid://7733654492"; searchIcon.BackgroundTransparency = 1; searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

local searchBox = Instance.new("TextBox", searchFrame)
searchBox.Size = UDim2.new(1, -40, 1, 0); searchBox.Position = UDim2.new(0, 35, 0, 0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""
searchBox:SetAttribute("TextRole", "Text"); searchBox:SetAttribute("BaseTextSize", 14); searchBox.TextXAlignment = Enum.TextXAlignment.Left

local navList = Instance.new("ScrollingFrame", sidebar)
navList.Size = UDim2.new(1, 0, 1, -130); navList.Position = UDim2.new(0, 0, 0, 130)
navList.BackgroundTransparency = 1; navList.ScrollBarThickness = 0
local navLayout = Instance.new("UIListLayout", navList); navLayout.Padding = UDim.new(0, 6); navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -210, 1, -20); container.Position = UDim2.new(0, 205, 0, 10); container.BackgroundTransparency = 1

local activeTabName = Instance.new("TextLabel", container)
activeTabName.Size = UDim2.new(1, 0, 0, 45); activeTabName.BackgroundTransparency = 1; activeTabName.Text = "Home"
activeTabName:SetAttribute("TextRole", "Text"); activeTabName:SetAttribute("BaseTextSize", 26); activeTabName.TextXAlignment = Enum.TextXAlignment.Left

local versionLbl = Instance.new("TextLabel", mainFrame)
versionLbl.Size = UDim2.new(0, 300, 0, 20); versionLbl.Position = UDim2.new(1, -15, 1, -10)
versionLbl.AnchorPoint = Vector2.new(1, 1); versionLbl.BackgroundTransparency = 1
versionLbl.Text = "V.1.0.0 | © MxFlow created by MxF Studio, All rights reserved."
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl:SetAttribute("TextRole", "TextDim"); versionLbl:SetAttribute("BaseTextSize", 11)

local authFrame = Instance.new("Frame", screenGui)
authFrame.Size = UDim2.new(0, 350, 0, 250); authFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
authFrame:SetAttribute("BgRole", "Main"); Instance.new("UICorner", authFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", authFrame):SetAttribute("StrokeRole", "Stroke")
authFrame.Visible = false

local authTitle = Instance.new("TextLabel", authFrame)
authTitle.Size = UDim2.new(1, 0, 0, 50); authTitle.Position = UDim2.new(0, 0, 0, 20); authTitle.BackgroundTransparency = 1
authTitle.Text = "MxF HUB KEY SYSTEM"; authTitle:SetAttribute("TextRole", "Text"); authTitle:SetAttribute("BaseTextSize", 20)

local keyInputBg = Instance.new("Frame", authFrame)
keyInputBg.Size = UDim2.new(0.8, 0, 0, 40); keyInputBg.Position = UDim2.new(0.1, 0, 0, 80)
keyInputBg:SetAttribute("BgRole", "Elem"); Instance.new("UICorner", keyInputBg).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", keyInputBg):SetAttribute("StrokeRole", "Stroke")

local keyBox = Instance.new("TextBox", keyInputBg)
keyBox.Size = UDim2.new(1, -20, 1, 0); keyBox.Position = UDim2.new(0, 10, 0, 0); keyBox.BackgroundTransparency = 1
keyBox.PlaceholderText = "Enter your Key here..."; keyBox.Text = ""
keyBox.TextXAlignment = Enum.TextXAlignment.Left; keyBox.TextTruncate = Enum.TextTruncate.AtEnd; keyBox.ClearTextOnFocus = false
keyBox:SetAttribute("TextRole", "Text"); keyBox:SetAttribute("BaseTextSize", 11)

local verifyBtn = Instance.new("TextButton", authFrame)
verifyBtn.Size = UDim2.new(0.8, 0, 0, 40); verifyBtn.Position = UDim2.new(0.1, 0, 0, 135)
verifyBtn:SetAttribute("BgRole", "AccentBg"); verifyBtn.Text = "Verify Key"
verifyBtn:SetAttribute("TextRole", "Main"); verifyBtn:SetAttribute("BaseTextSize", 15); Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

local getBtn = Instance.new("TextButton", authFrame)
getBtn.Size = UDim2.new(0.8, 0, 0, 30); getBtn.Position = UDim2.new(0.1, 0, 0, 185)
getBtn.BackgroundTransparency = 1; getBtn.Text = "Get Key (Discord)"
getBtn:SetAttribute("TextRole", "TextDim"); getBtn:SetAttribute("BaseTextSize", 12)
getBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://discord.gg/w3Dr9VzjS6") end end)

local loadFrame = Instance.new("Frame", screenGui)
loadFrame.Size = UDim2.new(0, 300, 0, 100); loadFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadFrame:SetAttribute("BgRole", "Main"); Instance.new("UICorner", loadFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", loadFrame):SetAttribute("StrokeRole", "Stroke")
loadFrame.Visible = false

local loadText = Instance.new("TextLabel", loadFrame)
loadText.Size = UDim2.new(1, 0, 0, 40); loadText.Position = UDim2.new(0, 0, 0, 15); loadText.BackgroundTransparency = 1
loadText.Text = "Authenticating..."; loadText:SetAttribute("TextRole", "Text"); loadText:SetAttribute("BaseTextSize", 16)

local barBg = Instance.new("Frame", loadFrame)
barBg.Size = UDim2.new(0.8, 0, 0, 10); barBg.Position = UDim2.new(0.1, 0, 0, 65)
barBg:SetAttribute("BgRole", "Elem"); Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0); barFill:SetAttribute("BgRole", "AccentBg"); Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local function ApplyTheme()
	pcall(function()
		local t = Themes[CurrentSettings.Theme] or Themes["Default"]
		local f = Fonts[CurrentSettings.Font] or Fonts["Gotham"]
		local offset = tonumber(CurrentSettings.TextSizeOffset) or 1
		local opacity = tonumber(CurrentSettings.Opacity) or 0.85
		local scale = (tonumber(CurrentSettings.MenuSize) or 100) / 100

		mainFrame.Size = UDim2.new(0, 760 * scale, 0, 520 * scale)
		mainFrame.BackgroundTransparency = 1 - opacity
		sidebar.BackgroundTransparency = 1 - opacity
		authFrame.BackgroundTransparency = 1 - opacity
		loadFrame.BackgroundTransparency = 1 - opacity

		for _, obj in ipairs(screenGui:GetDescendants()) do
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				obj.Font = f
				local bSize = obj:GetAttribute("BaseTextSize")
				if bSize then obj.TextSize = (tonumber(bSize) + offset) * scale end
			end

			if obj:IsA("GuiObject") then
				local txtRole = obj:GetAttribute("TextRole")
				if txtRole == "Text" then obj.TextColor3 = t.Text
				elseif txtRole == "TextDim" then obj.TextColor3 = t.TextDim 
				elseif txtRole == "Accent" then obj.TextColor3 = t.Accent
				elseif txtRole == "Main" then obj.TextColor3 = t.Main end
				
				local bgRole = obj:GetAttribute("BgRole")
				if bgRole == "Main" then obj.BackgroundColor3 = t.Main
				elseif bgRole == "Side" then obj.BackgroundColor3 = t.Side
				elseif bgRole == "Elem" then obj.BackgroundColor3 = t.Elem
				elseif bgRole == "AccentBg" then obj.BackgroundColor3 = t.Accent
				elseif bgRole == "TogglePill" then obj.BackgroundColor3 = obj:GetAttribute("ToggleState") and t.Accent or t.Stroke
				elseif bgRole == "TabBtn" then 
					obj.BackgroundTransparency = obj:GetAttribute("IsActive") and 0 or 1
					if obj:GetAttribute("IsActive") then obj.BackgroundColor3 = t.Elem end
				end
			end

			if obj:IsA("UIStroke") then
				if obj:GetAttribute("StrokeRole") == "Stroke" then obj.Color = t.Stroke end
			end
		end
	end)
end

-- UI FACTORY
local Pages = {}
local currentTab = nil

local function CreateTab(name, iconId)
	local btn = Instance.new("TextButton", navList)
	btn.Size = UDim2.new(0.9, 0, 0, 42); btn.BackgroundTransparency = 1; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	btn:SetAttribute("BgRole", "TabBtn"); btn:SetAttribute("IsActive", false)

	local icon = Instance.new("ImageLabel", btn)
	icon.Size = UDim2.new(0, 20, 0, 20); icon.Position = UDim2.new(0, 12, 0.5, -10); icon.Image = "rbxassetid://"..iconId; icon.BackgroundTransparency = 1
	icon.ImageColor3 = Color3.fromRGB(200, 200, 200)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -45, 1, 0); lbl.Position = UDim2.new(0, 40, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 16)

	local page = Instance.new("ScrollingFrame", container)
	page.Size = UDim2.new(1, 0, 1, -55); page.Position = UDim2.new(0, 0, 0, 55); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false
	local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 10)
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20) end)

	Pages[name] = page
	
	local function activate()
		for n, p in pairs(Pages) do p.Visible = (n == name) end
		if currentTab then 
			currentTab.btn:SetAttribute("IsActive", false)
			currentTab.lbl:SetAttribute("TextRole", "TextDim")
		end
		btn:SetAttribute("IsActive", true)
		lbl:SetAttribute("TextRole", "Text")
		activeTabName.Text = name; currentTab = {btn = btn, lbl = lbl, page = page}
		ApplyTheme()
	end
	
	tabFunctions[name] = activate
	btn.MouseButton1Click:Connect(activate)

	return page
end

local function CreateSection(page, text, defaultOpen)
	local section = Instance.new("Frame", page)
	section.Size = UDim2.new(1, -10, 0, 45); section.ClipsDescendants = true
	section:SetAttribute("BgRole", "Elem"); section:SetAttribute("IsSection", true)
	Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10)
	local sStroke = Instance.new("UIStroke", section); sStroke:SetAttribute("StrokeRole", "Stroke")
	
	local btn = Instance.new("TextButton", section)
	btn.Size = UDim2.new(1, 0, 0, 45); btn.BackgroundTransparency = 1; btn.Text = ""
	
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, -30, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "Text"); lbl:SetAttribute("BaseTextSize", 16)
	
	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -25, 0, 0); icon.BackgroundTransparency = 1
	icon.Text = defaultOpen and "▼" or "▶"
	icon:SetAttribute("TextRole", "TextDim"); icon:SetAttribute("BaseTextSize", 14)
	
	local content = Instance.new("Frame", section)
	content.Name = "ContentFrame"
	content.Size = UDim2.new(1, 0, 0, 0); content.Position = UDim2.new(0, 0, 0, 45); content.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local isOpen = defaultOpen == true
	local function updateSize()
		if isOpen then
			local cHeight = layout.AbsoluteContentSize.Y + 15 
			TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45 + cHeight)}):Play()
			content.Size = UDim2.new(1, 0, 0, cHeight)
		else
			TweenService:Create(section, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45)}):Play()
		end
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if isOpen then updateSize() end end)
	btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen; icon.Text = isOpen and "▼" or "▶"; updateSize()
		task.delay(0.25, function() 
			if currentTab then 
				local mL = currentTab.page:FindFirstChildOfClass("UIListLayout")
				if mL then currentTab.page.CanvasSize = UDim2.new(0, 0, 0, mL.AbsoluteContentSize.Y + 20) end
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
	lbl.Size = UDim2.new(1, 0, 1, -5); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "Text"); lbl:SetAttribute("BaseTextSize", 15)
	local line = Instance.new("Frame", frame)
	line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -2)
	line:SetAttribute("BgRole", "Stroke"); line.BorderSizePixel = 0
	return lbl
end

local function CreateParagraph(page, text)
	local lbl = Instance.new("TextLabel", page)
	lbl.Size = UDim2.new(1, -20, 0, 60); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	return lbl
end

local function CreateRow(page, height)
	local row = Instance.new("Frame", page); row.Size = UDim2.new(1, -10, 0, height or 45); row.BackgroundTransparency = 1
	row:SetAttribute("IsRow", true); return row
end

local function CreateInput(page, text, placeholder, default, callback)
	local row = CreateRow(page, 45)
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local inputBg = Instance.new("Frame", row)
	inputBg.Size = UDim2.new(0.4, 0, 0, 32); inputBg.Position = UDim2.new(1, -10, 0.5, -16); inputBg.AnchorPoint = Vector2.new(1, 0)
	inputBg:SetAttribute("BgRole", "Main"); Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", inputBg):SetAttribute("StrokeRole", "Stroke")
	local box = Instance.new("TextBox", inputBg)
	box.Size = UDim2.new(1, -10, 1, 0); box.Position = UDim2.new(0, 5, 0, 0); box.BackgroundTransparency = 1
	box.Text = tostring(default); box.PlaceholderText = placeholder
	box:SetAttribute("TextRole", "Accent"); box:SetAttribute("BaseTextSize", 13)
	box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
end

local function CreateToggle(page, text, default, callback)
	local row = CreateRow(page, 45); local state = default
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
	local pill = Instance.new("Frame", row)
	pill.Size = UDim2.new(0, 42, 0, 22); pill.Position = UDim2.new(1, -52, 0.5, -11)
	pill:SetAttribute("BgRole", "TogglePill"); pill:SetAttribute("ToggleState", state)
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
	local circle = Instance.new("Frame", pill)
	circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	
	btn.MouseButton1Click:Connect(function()
		state = not state; pill:SetAttribute("ToggleState", state)
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
		ApplyTheme(); callback(state)
	end)
	
	return function(newState)
		state = newState; pill:SetAttribute("ToggleState", state)
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
		ApplyTheme()
	end
end

local function CreateSlider(page, text, min, max, default, callback)
	local row = CreateRow(page, 55)
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 0, 25); lbl.Position = UDim2.new(0, 10, 0, 5); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size = UDim2.new(0.4, 0, 0, 25); valLbl.Position = UDim2.new(1, -50, 0, 5); valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(default); valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl:SetAttribute("TextRole", "Accent"); valLbl:SetAttribute("BaseTextSize", 13)
	local sliderBg = Instance.new("TextButton", row)
	sliderBg.Size = UDim2.new(1, -20, 0, 6); sliderBg.Position = UDim2.new(0, 10, 0, 35); sliderBg.Text = ""
	sliderBg:SetAttribute("BgRole", "Main"); Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame", sliderBg)
	fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	fill:SetAttribute("BgRole", "AccentBg"); Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
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

local function CreateKeybind(page, text, defaultKey, callback)
	local row = CreateRow(page, 45)
	local currentKey = defaultKey
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.4, 0, 0, 28); btn.Position = UDim2.new(1, -10, 0.5, -14); btn.AnchorPoint = Vector2.new(1, 0)
	btn:SetAttribute("BgRole", "Main"); btn.Text = currentKey.Name
	btn:SetAttribute("TextRole", "Text"); btn:SetAttribute("BaseTextSize", 12); Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", btn):SetAttribute("StrokeRole", "Stroke")
	local isBinding = false
	btn.MouseButton1Click:Connect(function()
		isBinding = true; isBindingAny = true; btn.Text = "Press Key..."; btn:SetAttribute("TextRole", "Accent")
		ApplyTheme()
	end)
	UIS.InputBegan:Connect(function(input)
		if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
			currentKey = input.KeyCode; btn.Text = currentKey.Name; btn:SetAttribute("TextRole", "Text")
			isBinding = false; task.wait(0.1); isBindingAny = false; ApplyTheme()
			if callback then callback(currentKey) end
		end
	end)
end

local function CreateDropdown(page, text, options, default, callback)
	local current = default or options[1]
	local row = CreateRow(page, 45); row.ClipsDescendants = true
	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.4, 0, 0, 45); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl:SetAttribute("TextRole", "TextDim"); lbl:SetAttribute("BaseTextSize", 14)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(0.5, 0, 0, 32); btn.Position = UDim2.new(1, -10, 0, 6); btn.AnchorPoint = Vector2.new(1, 0); btn.Text = ""
	btn:SetAttribute("BgRole", "Main"); Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", btn):SetAttribute("StrokeRole", "Stroke")
	local valTxt = Instance.new("TextLabel", btn)
	valTxt.Size = UDim2.new(1, -30, 1, 0); valTxt.Position = UDim2.new(0, 10, 0, 0); valTxt.BackgroundTransparency = 1; valTxt.TextXAlignment = Enum.TextXAlignment.Left
	valTxt:SetAttribute("TextRole", "Text"); valTxt:SetAttribute("BaseTextSize", 13)
	local icon = Instance.new("TextLabel", btn)
	icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -20, 0, 0); icon.BackgroundTransparency = 1; icon.Text = "▼"
	icon:SetAttribute("TextRole", "TextDim"); icon:SetAttribute("BaseTextSize", 11)
	local list = Instance.new("Frame", row)
	list.Size = UDim2.new(1, -20, 0, 0); list.Position = UDim2.new(0, 10, 0, 50); list.BackgroundTransparency = 1
	local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)
	local open = false
	local function updateSize()
		local targetSize = open and (layout.AbsoluteContentSize.Y + 60) or 45
		TweenService:Create(row, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
	end
	btn.MouseButton1Click:Connect(function() open = not open; icon.Text = open and "▲" or "▼"; updateSize() end)

	local DropdownAPI = {}
	function DropdownAPI:Refresh(newOptions)
		for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		current = newOptions[1] or ""; valTxt.Text = tostring(current); if callback then callback(current) end
		for _, opt in ipairs(newOptions) do
			local oBtn = Instance.new("TextButton", list); oBtn.Size = UDim2.new(1, 0, 0, 28); oBtn.Text = "  " .. opt; oBtn.TextXAlignment = Enum.TextXAlignment.Left
			oBtn:SetAttribute("BgRole", "Main"); Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 6)
			oBtn:SetAttribute("TextRole", "Text"); oBtn:SetAttribute("BaseTextSize", 13)
			oBtn.MouseButton1Click:Connect(function() current = opt; valTxt.Text = opt; open = false; icon.Text = "▼"; updateSize(); ApplyTheme(); if callback then callback(opt) end end)
		end
		if open then updateSize() end
		ApplyTheme() 
	end

	DropdownAPI:Refresh(options)
	if default and table.find(options, default) then valTxt.Text = tostring(default); if callback then callback(default) end end
	return DropdownAPI
end

local function CreateButton(page, text, callback)
	local row = CreateRow(page, 45)
	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = text
	btn:SetAttribute("TextRole", "Accent"); btn:SetAttribute("BaseTextSize", 15)
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

-- Search Logic
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local filter = string.lower(searchBox.Text)
	if currentTab then
		for _, section in ipairs(currentTab.page:GetChildren()) do
			if section:GetAttribute("IsSection") then
				local hasVisibleRow = false
				local secBtn = section:FindFirstChildOfClass("TextButton")
				local secTitleLabel = secBtn and secBtn:FindFirstChildOfClass("TextLabel")
				local titleMatches = secTitleLabel and string.find(string.lower(secTitleLabel.Text), filter) ~= nil

				for _, row in ipairs(section:GetDescendants()) do
					if row:GetAttribute("IsRow") then
						local label = row:FindFirstChildOfClass("TextLabel")
						if label then
							local rowMatches = string.find(string.lower(label.Text), filter) ~= nil
							if filter == "" or titleMatches or rowMatches then
								row.Visible = true; hasVisibleRow = true
							else
								row.Visible = false
							end
						end
					end
				end
				section.Visible = filter == "" or titleMatches or hasVisibleRow
			end
		end
		
		local pageLayout = currentTab.page:FindFirstChildOfClass("UIListLayout")
		if pageLayout then currentTab.page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20) end
	end
end)

-- ==========================================
-- 4. CONSTRUCTION DU HUB
-- ==========================================
local iconHome = "7733799795"; local iconAuto = "7734053426"; local iconFarm = "7733674079"
local iconPlayer = "7733954760"; local iconTeleport = "7733992829"; local iconShop = "6031280882"
local iconSettingsUI = "7734068321"; local iconSettings = "7733964719" 

local pgHome = CreateTab("Home", iconHome)
local pgAuto = CreateTab("Auto", iconAuto)
local pgFarm = CreateTab("Farm", iconFarm)
local pgSelf = CreateTab("Self", iconPlayer)
local pgTp = CreateTab("Teleport", iconTeleport)
local pgShop = CreateTab("Shop", iconShop)
local pgSettingsUI = CreateTab("Settings UI", iconSettingsUI)
local pgSettings = CreateTab("Settings", iconSettings)

-- --- PAGE HOME ---
local secWelcome = CreateSection(pgHome, "Welcome", true)
local welcomeTxt = CreateParagraph(secWelcome, "Welcome to MxFlow hub, the new generation of script for roblox.\nCreated by two French Founders, all rights to this menu are reserved.")
task.spawn(function() while task.wait(1.5) do TweenService:Create(welcomeTxt, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {TextTransparency = 0.5}):Play(); task.wait(1.5) end end)
local secDiscord = CreateSection(pgHome, "Discord", true)
CreateButton(secDiscord, "Copy Discord Link", function() if setclipboard then setclipboard("https://discord.gg/w3Dr9VzjS6") end end)

-- --- PAGE AUTO ---
local secAutoSkills = CreateSection(pgAuto, "Auto Skills", true)
CreateDropdown(secAutoSkills, "Select Skill", {"All", "All (No V)", "Z", "X", "C", "V", "F"}, "All", function(v) selectedSkill = v end)
CreateToggle(secAutoSkills, "Enable Auto Skills", false, function(v) autoSkillEnabled = v end)

local secSummon = CreateSection(pgAuto, "Auto Summon Boss", true)
CreateDropdown(secSummon, "Select Boss", summonBossesList, selectedSummonBoss, function(v) selectedSummonBoss = v end)
CreateDropdown(secSummon, "Select Difficulty", difficultyList, selectedDifficulty, function(v) selectedDifficulty = v end)
CreateInput(secSummon, "Amount to Summon", "Multiplier", summonBossAmount, function(v) summonBossAmount = tonumber(v) or 1 end)
CreateButton(secSummon, "Summon Boss Once (Manual)", function()
	pcall(function()
		local rs = game:GetService("ReplicatedStorage"); local conf = SummonBossConfig[selectedSummonBoss]
		if conf.RemoteType == 1 then local rem = rs:WaitForChild("Remotes"):WaitForChild("RequestSummonBoss")
			if conf.HasDiff then rem:FireServer(selectedSummonBoss, selectedDifficulty) else rem:FireServer(selectedSummonBoss) end
		elseif conf.RemoteType == 2 then rs:WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnTrueAizen"):FireServer(selectedDifficulty)
		elseif conf.RemoteType == 3 then rs:WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnAtomic"):FireServer(selectedDifficulty)
		elseif conf.RemoteType == 4 then rs:WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss"):FireServer(conf.PrefixArg, selectedDifficulty) end
	end)
end)
autoFarmSummonToggleFunc = CreateToggle(secSummon, "Auto Farm Summon Boss", false, function(v) autoFarmSummonBossEnabled = v; currentSummonCount = 0; if v then startCombatLoop() end end)

local secAutoChest = CreateSection(pgAuto, "Auto Chest", true)
CreateDropdown(secAutoChest, "Select Chest", chestTypesList, selectedChestType, function(v) selectedChestType = v end)
CreateInput(secAutoChest, "Amount to Open", "Quantity", chestAmountToOpen, function(v) chestAmountToOpen = tonumber(v) or 1 end)
CreateToggle(secAutoChest, "Auto Open Chests", false, function(v) autoChestEnabled = v; if v then startAutoChestLoop() end end)

local secAutoStatsMaster = CreateSection(pgAuto, "Auto Stats (Controls)", false)
CreateToggle(secAutoStatsMaster, "Enable Auto Stats (Loop)", false, function(v) autoStatsEnabled = v; if v then startAutoStatsLoop() end end)
CreateButton(secAutoStatsMaster, "Reset All Stats", function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ResetStats"):FireServer() end) end)

local secAutoStatsConfig = CreateSection(pgAuto, "Stats Configuration", false)
CreateTitle(secAutoStatsConfig, "Melee")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Melee, function(v) statPoints.Melee = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate", false, function(v) autoStatsToggles.Melee = v end)
CreateTitle(secAutoStatsConfig, "Defense")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Defense, function(v) statPoints.Defense = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate", false, function(v) autoStatsToggles.Defense = v end)
CreateTitle(secAutoStatsConfig, "Sword")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Sword, function(v) statPoints.Sword = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate", false, function(v) autoStatsToggles.Sword = v end)
CreateTitle(secAutoStatsConfig, "Power")
CreateInput(secAutoStatsConfig, "Points to add", "Max 13000", statPoints.Power, function(v) statPoints.Power = math.clamp(tonumber(v) or 1, 1, 13000) end)
CreateToggle(secAutoStatsConfig, "Auto Allocate", false, function(v) autoStatsToggles.Power = v end)

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
CreateToggle(secAura, "KillAura Long Range", false, function(v) killauraEnabled = v; if v then autoFarmMob, autoFarmBoss, autoFarmTower = false, false, false; startCombatLoop() end end)
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

local secPlayerTp = CreateSection(pgTp, "Player Teleport & Follow", true)
CreateInput(secPlayerTp, "Player Name", "Enter name...", followTargetName, function(v) followTargetName = v end)
followToggleFunc = CreateToggle(secPlayerTp, "Follow Player", false, function(v)
	isFollowingPlayer = v
	if v then
		local target = findTargetPlayer(followTargetName)
		if target then
			followConnection = RunService.RenderStepped:Connect(function()
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local tChar = target.Character
				local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
				
				if hrp and tHrp then
					hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0.1)
				else
					isFollowingPlayer = false
					if followConnection then followConnection:Disconnect(); followConnection = nil end
					if followToggleFunc then followToggleFunc(false) end
				end
			end)
		else
			isFollowingPlayer = false
			if followToggleFunc then followToggleFunc(false) end
		end
	else
		if followConnection then followConnection:Disconnect(); followConnection = nil end
	end
end)

-- --- PAGE SHOP ---
local secShop = CreateSection(pgShop, "Merchant Shop", true)
CreateDropdown(secShop, "Select Item", shopItemsList, selectedShopItem, function(v) selectedShopItem = v end)
CreateInput(secShop, "Amount to Buy", "Max Quantity", shopBuyAmount, function(v) shopBuyAmount = tonumber(v) or 1 end)
CreateInput(secShop, "Delay To Buy (Seconds)", "Delay", shopBuyDelay, function(v) shopBuyDelay = tonumber(v) or 0 end)
CreateToggle(secShop, "Auto Buy Merchant", false, function(v) autoBuyEnabled = v; if v then startAutoBuyLoop() end end)
CreateButton(secShop, "Buy Once", function() pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem"):InvokeServer(selectedShopItem, tonumber(shopBuyAmount) or 1) end) end)

-- --- PAGE SETTINGS UI ---
local secTheme = CreateSection(pgSettingsUI, "Theme", true)
CreateDropdown(secTheme, "Select Theme", ThemeNames, CurrentSettings.Theme, function(v) CurrentSettings.Theme = v; SaveSettings(); ApplyTheme() end)

local secCustom = CreateSection(pgSettingsUI, "Custom UI", true)
CreateSlider(secCustom, "Menu Size (%)", 70, 150, tonumber(CurrentSettings.MenuSize) or 100, function(v) CurrentSettings.MenuSize = v; SaveSettings(); ApplyTheme() end)
CreateSlider(secCustom, "Menu Opacity", 10, 100, CurrentSettings.Opacity * 100, function(v) CurrentSettings.Opacity = v/100; SaveSettings(); ApplyTheme() end)
CreateDropdown(secCustom, "Select Font", FontNames, CurrentSettings.Font, function(v) CurrentSettings.Font = v; SaveSettings(); ApplyTheme() end)
CreateSlider(secCustom, "Text Size Offset", -2, 6, tonumber(CurrentSettings.TextSizeOffset) or 1, function(v) CurrentSettings.TextSizeOffset = v; SaveSettings(); ApplyTheme() end)

local secScreen = CreateSection(pgSettingsUI, "Screen Overlay", false)
local isBlack, isWhite = false, false
CreateToggle(secScreen, "Black Screen", false, function(v) isBlack = v; if v then isWhite = false; overlayFrame.BackgroundColor3 = Color3.new(0,0,0); overlayFrame.Visible = true else overlayFrame.Visible = isWhite end end)
CreateToggle(secScreen, "White Screen", false, function(v) isWhite = v; if v then isBlack = false; overlayFrame.BackgroundColor3 = Color3.new(1,1,1); overlayFrame.Visible = true else overlayFrame.Visible = isBlack end end)

-- --- PAGE SETTINGS ---
local secSystem = CreateSection(pgSettings, "System Settings", true)
CreateKeybind(secSystem, "Toggle UI Key", UIConfig.ToggleKey, function(newKey) UIConfig.ToggleKey = newKey end)
CreateButton(secSystem, "Rejoin Server", function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
CreateButton(secSystem, "Server Hop", function()
	pcall(function()
		local Http = game:GetService("HttpService"); local TPS = game:GetService("TeleportService")
		local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local function ListServers(cursor) return Http:JSONDecode(game:HttpGet(Api .. ((cursor and "&cursor="..cursor) or ""))) end
		local Server, Next; repeat local Servers = ListServers(Next); Server = Servers.data[math.random(1, #Servers.data)]; Next = Servers.nextPageCursor until Server.playing < Server.maxPlayers and Server.id ~= game.JobId
		TPS:TeleportToPlaceInstance(game.PlaceId, Server.id, player)
	end)
end)
CreateButton(secSystem, "Unload Interface", function() 
	if targetGui:FindFirstChild("MxFHubPremium") then targetGui.MxFHubPremium:Destroy() end 
	if targetGui:FindFirstChild("MxFHubOverlay") then targetGui.MxFHubOverlay:Destroy() end
end)

-- Dragging Main
local dragS, dragP, startP
local topDrag = Instance.new("TextButton", mainFrame); topDrag.Size = UDim2.new(1,0,0,40); topDrag.BackgroundTransparency = 1; topDrag.Text = ""
topDrag.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = true; dragP = input.Position; startP = mainFrame.Position end end)
UIS.InputChanged:Connect(function(input) if dragS and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragP; mainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end end)
UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == UIConfig.ToggleKey and not isBindingAny then if authFrame.Visible or loadFrame.Visible then return end mainFrame.Visible = not mainFrame.Visible end end)

-- ==========================================
-- 5. INITIALISATION (KEY SYSTEM FLOW)
-- ==========================================
local function ShowMainMenu()
	ApplyTheme()
	if tabFunctions["Home"] then tabFunctions["Home"]() end
	mainFrame.Visible = true
	print("MxFlow Menu Edition Loaded!")
end

if CurrentSettings.SavedKey ~= "" then
	local isValid = VerifyKey(CurrentSettings.SavedKey)
	if isValid then ShowMainMenu() else authFrame.Visible = true end
else
	authFrame.Visible = true
end

verifyBtn.MouseButton1Click:Connect(function()
	local key = keyBox.Text
	authFrame.Visible = false
	loadFrame.Visible = true
	
	local tween = TweenService:Create(barFill, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 1, 0)})
	tween:Play()
	
	local isValid, msg = VerifyKey(key)
	tween.Completed:Wait()
	
	if isValid then
		CurrentSettings.SavedKey = key; SaveSettings()
		loadFrame.Visible = false; ShowMainMenu()
	else
		loadText.Text = "Error: " .. msg; loadText.TextColor3 = Color3.fromRGB(255, 50, 50)
		task.wait(2)
		barFill.Size = UDim2.new(0, 0, 1, 0); loadText.Text = "Authenticating..."
		loadText.TextColor3 = Themes[CurrentSettings.Theme].Text or Color3.new(1,1,1)
		loadFrame.Visible = false; authFrame.Visible = true
	end
end)

ApplyTheme()
