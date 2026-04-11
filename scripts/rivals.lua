-- ======================================================
-- 👑 MxF HUB - RIVALS VERSION (V.1.0.0)
-- SECURED: Anti Direct Execution Bypass
-- Removed: Auto & Farm categories (PvP Focused)
-- ======================================================

-- ==========================================
-- 0. ANTI-BYPASS SECURITY (HANDSHAKE CHECK)
-- ==========================================
local passedToken = ...
local envToken = getgenv and getgenv().MxF_Session_Token or nil

if not passedToken or type(passedToken) ~= "string" or not envToken or passedToken ~= envToken then
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	if player then
		player:Kick("\n👑 MxF SECURITY 👑\nUnauthorized Execution detected.\nPlease use the official Loader to access this script.")
	end
	return
end

-- Nettoyage du token pour éviter qu'un autre script fouille la mémoire
if getgenv then getgenv().MxF_Session_Token = nil end
-- ==========================================

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
local ConfigFileName = "MxFHub_Rivals_Settings.json"
local CurrentSettings = {
	Theme = "Default",
	Font = "Gotham",
	Opacity = 0.85,
	TextSizeOffset = 1,
	MenuSize = 100
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
local currentScale = (tonumber(CurrentSettings.MenuSize) or 100) / 100

-- RETAINED DATABASES (For UI Teleport/Shop compatibility)
local NpcNames = {"DungeonMerchantNPC", "BossSummoner", "QuestNPC", "ShopKeeper"}
local IslandNames = {"Spawn", "Arena", "Desert", "Snow", "Tower"}
local shopItemsList = {"Weapon Skin", "Aura Reroll", "Stat Reset", "Clan Reroll"}
local selectedShopItem = shopItemsList[1]
local shopBuyAmount = 1; local shopBuyDelay = 0; local autoBuyEnabled = false; local autoBuyCoroutine = nil

local selectedIsland, selectedNPC = IslandNames[1], NpcNames[1]
local killauraEnabled = false
local combatRadius = 500
local combatCoroutine = nil
local currentTarget = nil

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
-- 2. BACK-END LOGIC (RIVALS / PVP FOCUS)
-- ==========================================
local function teleportToIsland(islandName)
	-- Remplace par le remote de teleportation de ton jeu
	pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(islandName) end)
end

local function teleportToSpecificNPC(npcName)
    -- Logique simplifiée pour la version Rivals
    print("Teleporting to NPC: " .. npcName)
end

-- Nouveau système de ciblage axé PvP (Rivals)
local function getClosestPlayer()
	local closest, minDist = nil, combatRadius
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, minDist end
	local myPos = char.HumanoidRootPart.Position

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and root then
				local dist = (root.Position - myPos).Magnitude
				if dist < minDist then minDist = dist; closest = p.Character end
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
		while killauraEnabled do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart; local hum = char.Humanoid
				
				pcall(function()
					if not char:FindFirstChildOfClass("Tool") then
						local tool = player.Backpack:FindFirstChildOfClass("Tool")
						if tool then hum:EquipTool(tool) end
					end
				end)
				
				if killauraEnabled then
					local target, dist = getClosestPlayer()
					currentTarget = target
					if target and target:FindFirstChild("HumanoidRootPart") then
						local targetRoot = target.HumanoidRootPart
						root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
						
						local currentTool = char:FindFirstChildOfClass("Tool")
						if not currentTool then
							local tool = player.Backpack:FindFirstChildOfClass("Tool")
							if tool then hum:EquipTool(tool) end
							currentTool = char:FindFirstChildOfClass("Tool")
						end

						if currentTool then
							for _, part in ipairs(currentTool:GetDescendants()) do
								if part:IsA("BasePart") and (part.Name == "Hitbox" or part.Name == "Handle" or string.find(string.lower(part.Name), "blade")) then
									part.Massless = true; part.CanCollide = false
									part.Size = Vector3.new(combatRadius, combatRadius, combatRadius)
									part.CFrame = targetRoot.CFrame
								end
							end
							
							if firetouchinterest then
								local handle = currentTool:FindFirstChild("Hitbox") or currentTool:FindFirstChild("Handle")
								if handle then
									pcall(function()
										firetouchinterest(handle, targetRoot, 0)
										firetouchinterest(handle, targetRoot, 1)
									end)
								end
							end
						end
						
						pcall(function() hitRemote:FireServer() end)
						VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
						task.wait(0.02)
						VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
					end
				end
			end
			task.wait(0.1)
		end
		
		if player.Character and not flyEnabled and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end
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
	if walkSpeedEnabled then speedConn = RunService.Heartbeat:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = walkSpeedValue end end)
	else if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end end
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
	if not flyEnabled then if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end return end
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
	
	if killauraEnabled then startCombatLoop() end
	
	if isFollowingPlayer then
		isFollowingPlayer = false
		if followConnection then followConnection:Disconnect(); followConnection = nil end
		if followToggleFunc then followToggleFunc(false) end
	end
end)

-- ==========================================
-- 3. MOTEUR UI (ANIMATED)
-- ==========================================
local overlayGui = Instance.new("ScreenGui", targetGui)
overlayGui.Name = "MxFHubOverlay"; overlayGui.DisplayOrder = 90 
local overlayFrame = Instance.new("Frame", overlayGui)
overlayFrame.Size = UDim2.new(10, 0, 10, 0); overlayFrame.Position = UDim2.new(-5, 0, -5, 0); overlayFrame.Visible = false

local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubPremium"; screenGui.DisplayOrder = 100 

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BorderSizePixel = 0; mainFrame:SetAttribute("BgRole", "Main")
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true

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
hubName.BackgroundTransparency = 1; hubName.Text = "MxFlow"
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
versionLbl.Text = "V.1.0.0 | Rivals Edition © MxFlow"
versionLbl.TextXAlignment = Enum.TextXAlignment.Right
versionLbl:SetAttribute("TextRole", "TextDim"); versionLbl:SetAttribute("BaseTextSize", 11)

local function ApplyTheme()
	pcall(function()
		local t = Themes[CurrentSettings.Theme] or Themes["Default"]
		local f = Fonts[CurrentSettings.Font] or Fonts["Gotham"]
		local offset = tonumber(CurrentSettings.TextSizeOffset) or 1
		local opacity = tonumber(CurrentSettings.Opacity) or 0.85
		currentScale = (tonumber(CurrentSettings.MenuSize) or 100) / 100

		if mainFrame.Visible then
			mainFrame.Size = UDim2.new(0, 760 * currentScale, 0, 520 * currentScale)
		end
		mainFrame.BackgroundTransparency = 1 - opacity
		sidebar.BackgroundTransparency = 1 - opacity

		for _, obj in ipairs(screenGui:GetDescendants()) do
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				obj.Font = f
				local bSize = obj:GetAttribute("BaseTextSize")
				if bSize then obj.TextSize = (tonumber(bSize) + offset) * currentScale end
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
local iconHome = "7733799795"
local iconPlayer = "7733954760"; local iconTeleport = "7733992829"; local iconShop = "6031280882"
local iconSettingsUI = "7734068321"; local iconSettings = "7733964719" 

local pgHome = CreateTab("Home", iconHome)
local pgSelf = CreateTab("Self", iconPlayer)
local pgTp = CreateTab("Teleport", iconTeleport)
local pgShop = CreateTab("Shop", iconShop)
local pgSettingsUI = CreateTab("Settings UI", iconSettingsUI)
local pgSettings = CreateTab("Settings", iconSettings)

-- --- PAGE HOME ---
local secWelcome = CreateSection(pgHome, "Welcome", true)
local welcomeTxt = CreateParagraph(secWelcome, "Welcome to MxFlow Rivals, the ultimate script for PvP.\nAuto and Farm modules have been safely removed.")
task.spawn(function() while task.wait(1.5) do TweenService:Create(welcomeTxt, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {TextTransparency = 0.5}):Play(); task.wait(1.5) end end)
local secDiscord = CreateSection(pgHome, "Discord", true)
CreateButton(secDiscord, "[Copy Discord Link]", function() if setclipboard then setclipboard("https://discord.gg/w3Dr9VzjS6") end end)

-- --- PAGE SELF ---
local secAura = CreateSection(pgSelf, "Combat Assist (Aura)", true)
CreateToggle(secAura, "KillAura (Players Only)", false, function(v) killauraEnabled = v; if v then startCombatLoop() end end)
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

-- ✅ TOGGLE UI AVEC ANIMATION
local isMenuOpen = false
UIS.InputBegan:Connect(function(input, gp) 
	if not gp and input.KeyCode == UIConfig.ToggleKey and not isBindingAny then 
		isMenuOpen = not isMenuOpen
		if isMenuOpen then
			mainFrame.Visible = true
			TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760 * currentScale, 0, 520 * currentScale)}):Play()
		else
			local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
			tw:Play()
			tw.Completed:Wait()
			mainFrame.Visible = false
		end
	end 
end)

-- INITIALISATION IMMEDIATE DU HUB
ApplyTheme()
if tabFunctions["Home"] then tabFunctions["Home"]() end
mainFrame.Visible = true
isMenuOpen = true
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760 * currentScale, 0, 520 * currentScale)}):Play()
print("MxFlow Menu V1.0.0 (Rivals Edition) Loaded Successfully!")
