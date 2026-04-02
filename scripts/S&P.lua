-- ======================================================
-- HUB PREMIUM RAYFIELD - AUTO-FARM & TELEPORTS
-- ======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Chargement de la librairie Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==========================================
-- 1. BASE DE DONNÉES (MOBS & ÎLES)
-- ==========================================
local MobDatabase = {
	["AcademyTeacher"] = "Academy",
	["Arena Fighter"] = "Lawless",
	["Curse"] = "Shinjuku",
	["DesertBandit"] = "Desert",
	["FrostRogue"] = "Snow",
	["Hollow"] = "HollowIsland",
	["Monkey"] = "Jungle",
	["Ninja"] = "Ninja",
	["Quincy"] = "SoulDominion",
	["Slime"] = "Slime",
	["Sorcerer"] = "Shibuya",
	["StrongSorcerer"] = "Shinjuku",
	["Swordsman"] = "Judgement",
	["Thief"] = "Starter"
}

-- Création des listes pour les Dropdowns
local MobNames = {}
local IslandNames = {}
for mob, island in pairs(MobDatabase) do
	table.insert(MobNames, mob)
	if not table.find(IslandNames, island) then
		table.insert(IslandNames, island)
	end
end
table.sort(MobNames)
table.sort(IslandNames)

-- Variables globales du cheat
local selectedMob = MobNames[1]
local autoFarmEnabled = false
local combatCooldown = 0.1
local combatCoroutine = nil

local noClipEnabled = false
local noClipConnection = nil
local flyEnabled = false
local FLY_SPEED = 50
local flyConnection, bodyVelocity, bodyGyro

-- ==========================================
-- 2. FONCTIONS DE CHEAT ET TELEPORT
-- ==========================================

local function teleportToIsland(islandName)
	pcall(function()
		local args = { islandName }
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(unpack(args))
	end)
end

local function getSpecificMobTarget()
	local closest = nil
	local minDist = math.huge
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = char.HumanoidRootPart.Position

	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for _, obj in ipairs(npcsFolder:GetDescendants()) do
			if obj:IsA("Model") then
				-- Vérifie si le nom correspond au mob sélectionné + un chiffre de 1 à 5
				local isMatch = false
				for i = 1, 5 do
					if obj.Name == selectedMob .. tostring(i) then
						isMatch = true
						break
					end
				end

				if isMatch then
					local hum = obj:FindFirstChild("Humanoid")
					local root = obj:FindFirstChild("HumanoidRootPart")
					
					if hum and hum.Health > 0 and root then
						local dist = (root.Position - myPos).Magnitude
						if dist <= minDist then
							minDist = dist
							closest = obj
						end
					end
				end
			end
		end
	end
	return closest
end

local function startAutoFarm()
	if combatCoroutine then task.cancel(combatCoroutine) end
	
	combatCoroutine = task.spawn(function()
		local remote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
		
		while autoFarmEnabled do
			local myChar = player.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChild("Humanoid")
			
			if myRoot and myHum then
				local target = getSpecificMobTarget()
				
				if target then
					local targetRoot = target:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						-- Freeze le perso et l'allonge
						myHum.PlatformStand = true
						
						-- TP à 8 studs au-dessus
						local tpPos = targetRoot.Position + Vector3.new(0, 8, 0)
						myRoot.CFrame = CFrame.lookAt(tpPos, targetRoot.Position)
						myRoot.Velocity = Vector3.zero
						myRoot.RotVelocity = Vector3.zero
						
						-- Frapper
						pcall(function() remote:FireServer() end)
					end
				else
					-- S'il n'y a pas de cible, on fige en l'air
					myRoot.Velocity = Vector3.zero
				end
			end
			task.wait(combatCooldown)
		end
		
		-- Rétablir le joueur quand on désactive
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") and not flyEnabled then
			char.Humanoid.PlatformStand = false
		end
	end)
end

-- Fly et NoClip
local function enableNoClip()
	if noClipConnection then noClipConnection:Disconnect() end
	noClipConnection = RunService.Stepped:Connect(function()
		if player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
end

local function disableNoClip()
	if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
	if player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

local function enableFly()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	humanoid.PlatformStand = true
	bodyVelocity = Instance.new("BodyVelocity", rootPart)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro = Instance.new("BodyGyro", rootPart)
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.D = 50

	flyConnection = RunService.RenderStepped:Connect(function()
		local direction = Vector3.zero
		local cf = camera.CFrame
		if UIS:IsKeyDown(Enum.KeyCode.W) then direction += cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then direction += cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then direction += Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then direction -= Vector3.new(0, 1, 0) end
		if direction.Magnitude > 0 then direction = direction.Unit end
		bodyVelocity.Velocity = direction * FLY_SPEED
		bodyGyro.CFrame = cf
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
	if autoFarmEnabled then startAutoFarm() end
end)


-- ==========================================
-- 3. CRÉATION DE L'INTERFACE RAYFIELD
-- ==========================================
local Window = Rayfield:CreateWindow({
   Name = "⚔️ Anime Farm Hub",
   LoadingTitle = "Chargement...",
   LoadingSubtitle = "par Studio",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "FarmHub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true 
   },
   KeySystem = false
})

-- ================== ONGLET FARM ==================
local TabFarm = Window:CreateTab("Auto Farm", 4483345998) -- Icône d'épée

TabFarm:CreateSection("Sélection de la Cible")

TabFarm:CreateDropdown({
   Name = "Choisir le Mob à Farmer",
   Options = MobNames,
   CurrentOption = {selectedMob},
   MultipleOptions = false,
   Flag = "MobDropdown",
   Callback = function(Option)
      selectedMob = Option[1]
      print("Cible choisie :", selectedMob, "| Île :", MobDatabase[selectedMob])
   end,
})

TabFarm:CreateToggle({
   Name = "Activer l'Auto Farm (TP & Kill)",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      autoFarmEnabled = Value
      if Value then
          -- 1. Récupérer l'île associée au mob
          local targetIsland = MobDatabase[selectedMob]
          
          -- 2. Se téléporter sur l'île
          Rayfield:Notify({Title = "Auto Farm", Content = "Téléportation vers " .. targetIsland .. " en cours...", Duration = 3})
          teleportToIsland(targetIsland)
          
          -- 3. Attendre la fin du TP puis lancer le Farm
          task.wait(2)
          startAutoFarm()
      else
          if combatCoroutine then task.cancel(combatCoroutine) end
          local char = player.Character
          if char and char:FindFirstChild("Humanoid") and not flyEnabled then
              char.Humanoid.PlatformStand = false
          end
      end
   end,
})

TabFarm:CreateSlider({
   Name = "Délai de Frappe (Secondes)",
   Range = {0.05, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.1,
   Flag = "CooldownSlider",
   Callback = function(Value)
      combatCooldown = Value
   end,
})


-- ================== ONGLET TELEPORTS ==================
local TabTeleport = Window:CreateTab("Téléportation", 4483345998) -- Icône Map

TabTeleport:CreateSection("Voyage Rapide")

local selectedIsland = IslandNames[1]

TabTeleport:CreateDropdown({
   Name = "Choisir l'Île",
   Options = IslandNames,
   CurrentOption = {selectedIsland},
   MultipleOptions = false,
   Flag = "IslandDropdown",
   Callback = function(Option)
      selectedIsland = Option[1]
   end,
})

TabTeleport:CreateButton({
   Name = "Se Téléporter",
   Callback = function()
      Rayfield:Notify({Title = "Téléportation", Content = "Envoi vers : " .. selectedIsland, Duration = 3})
      teleportToIsland(selectedIsland)
   end,
})


-- ================== ONGLET JOUEUR ==================
local TabPlayer = Window:CreateTab("Joueur", 4483345998) -- Icône User

TabPlayer:CreateSection("Mouvements")

TabPlayer:CreateToggle({
   Name = "NoClip (Traverser les murs)",
   CurrentValue = false,
   Flag = "ToggleNoclip",
   Callback = function(Value)
      noClipEnabled = Value
      if Value then enableNoClip() else disableNoClip() end
   end,
})

TabPlayer:CreateToggle({
   Name = "Fly (Voler - WASD+QE)",
   CurrentValue = false,
   Flag = "ToggleFly",
   Callback = function(Value)
      flyEnabled = Value
      if Value then enableFly() else disableFly() end
   end,
})

TabPlayer:CreateSlider({
   Name = "Vitesse de Vol",
   Range = {10, 300},
   Increment = 10,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FLY_SPEED = Value
   end,
})

Rayfield:Notify({
   Title = "Menu Chargé",
   Content = "Auto-Farm et TP prêts à l'utilisation.",
   Duration = 5,
   Image = 4483362458,
})
