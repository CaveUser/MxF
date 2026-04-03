-- =====================================================================
-- 👑 IMGUI CUSTOM FRAMEWORK - NE PLUS TOUCHER CETTE PARTIE 👑
-- =====================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
-- Si utilisé dans un exécuteur, on met dans CoreGui pour être indétectable. Sinon dans PlayerGui.
local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

local Library = {
	AccentColor = Color3.fromRGB(150, 100, 255), -- Violet "Crown" par défaut
	ToggleKey = Enum.KeyCode.Insert,
	ThemeObjects = {}
}

function Library:UpdateTheme(newColor)
	Library.AccentColor = newColor
	for _, obj in ipairs(Library.ThemeObjects) do
		pcall(function() TweenService:Create(obj.inst, TweenInfo.new(0.3), {[obj.prop] = newColor}):Play() end)
	end
end

function Library:CreateWindow(title)
	local Window = {}
	local isVisible = true
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CrownMenuUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = targetGui

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 700, 0, 450)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
	
	local stroke = Instance.new("UIStroke", mainFrame)
	stroke.Color = Color3.fromRGB(40, 40, 50)
	stroke.Thickness = 1

	-- Topbar (Draggable)
	local topbar = Instance.new("Frame", mainFrame)
	topbar.Size = UDim2.new(1, 0, 0, 40)
	topbar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	topbar.BorderSizePixel = 0
	
	local titleLabel = Instance.new("TextLabel", topbar)
	titleLabel.Size = UDim2.new(1, -20, 1, 0); titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1; titleLabel.Text = title; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 14; titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Drag Logic
	local dragging, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = mainFrame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

	-- Show/Hide Menu
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Library.ToggleKey and not gameProcessed then
			isVisible = not isVisible
			mainFrame.Visible = isVisible
		end
	end)

	-- Sidebar & Content Area
	local sidebar = Instance.new("Frame", mainFrame)
	sidebar.Size = UDim2.new(0, 150, 1, -40); sidebar.Position = UDim2.new(0, 0, 0, 40)
	sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 18); sidebar.BorderSizePixel = 0
	
	local sidebarLayout = Instance.new("UIListLayout", sidebar)
	sidebarLayout.Padding = UDim.new(0, 5); sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

	local contentContainer = Instance.new("Frame", mainFrame)
	contentContainer.Size = UDim2.new(1, -150, 1, -40); contentContainer.Position = UDim2.new(0, 150, 0, 40)
	contentContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 24); contentContainer.BorderSizePixel = 0

	Window.Tabs = {}
	local activeTabBtn = nil

	function Window:CreateTab(tabName)
		local TabInfo = {}
		
		local tabBtn = Instance.new("TextButton", sidebar)
		tabBtn.Size = UDim2.new(0.9, 0, 0, 35); tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		tabBtn.BackgroundTransparency = 1; tabBtn.Text = tabName; tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		tabBtn.Font = Enum.Font.GothamSemibold; tabBtn.TextSize = 13
		Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

		local page = Instance.new("ScrollingFrame", contentContainer)
		page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1
		page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
		page.Visible = false
		local pageLayout = Instance.new("UIListLayout", page)
		pageLayout.Padding = UDim.new(0, 8); pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)

		Window.Tabs[tabName] = page

		tabBtn.MouseButton1Click:Connect(function()
			for name, p in pairs(Window.Tabs) do p.Visible = (name == tabName) end
			if activeTabBtn then
				TweenService:Create(activeTabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
			end
			TweenService:Create(tabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			activeTabBtn = tabBtn
		end)
		
		-- First tab active by default
		if #sidebar:GetChildren() == 3 then tabBtn.MouseButton1Click:Fire() end

		-- UI Components Functions
		function TabInfo:CreateSection(title)
			local lbl = Instance.new("TextLabel", page)
			lbl.Size = UDim2.new(0.95, 0, 0, 25); lbl.BackgroundTransparency = 1
			lbl.Text = title; lbl.TextColor3 = Library.AccentColor; lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
			table.insert(Library.ThemeObjects, {inst = lbl, prop = "TextColor3"})
		end

		function TabInfo:CreateToggle(text, default, callback)
			local state = default or false
			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(0.95, 0, 0, 35); frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
			lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13

			local toggleBg = Instance.new("TextButton", frame)
			toggleBg.Size = UDim2.new(0, 40, 0, 20); toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
			toggleBg.BackgroundColor3 = state and Library.AccentColor or Color3.fromRGB(40, 40, 50); toggleBg.Text = ""
			Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
			
			local circle = Instance.new("Frame", toggleBg)
			circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

			if state then table.insert(Library.ThemeObjects, {inst = toggleBg, prop = "BackgroundColor3"}) end

			toggleBg.MouseButton1Click:Connect(function()
				state = not state
				local targetColor = state and Library.AccentColor or Color3.fromRGB(40, 40, 50)
				local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				
				TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
				TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
				
				if state then table.insert(Library.ThemeObjects, {inst = toggleBg, prop = "BackgroundColor3"})
				else for i, v in ipairs(Library.ThemeObjects) do if v.inst == toggleBg then table.remove(Library.ThemeObjects, i) break end end end
				
				if callback then callback(state) end
			end)
		end

		function TabInfo:CreateSlider(text, min, max, default, callback)
			local value = default or min
			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(0.95, 0, 0, 50); frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(0.5, 0, 0, 25); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
			lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13

			local valLbl = Instance.new("TextLabel", frame)
			valLbl.Size = UDim2.new(0.5, -10, 0, 25); valLbl.Position = UDim2.new(0.5, 0, 0, 0); valLbl.BackgroundTransparency = 1
			valLbl.Text = tostring(value); valLbl.TextColor3 = Color3.fromRGB(150, 150, 150); valLbl.TextXAlignment = Enum.TextXAlignment.Right
			valLbl.Font = Enum.Font.Gotham; valLbl.TextSize = 13

			local sliderBg = Instance.new("TextButton", frame)
			sliderBg.Size = UDim2.new(1, -20, 0, 6); sliderBg.Position = UDim2.new(0, 10, 0, 32)
			sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50); sliderBg.Text = ""
			Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

			local fill = Instance.new("Frame", sliderBg)
			fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0); fill.BackgroundColor3 = Library.AccentColor
			Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
			table.insert(Library.ThemeObjects, {inst = fill, prop = "BackgroundColor3"})

			local dragging = false
			local function update(input)
				local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
				value = math.floor(min + ((max - min) * pos))
				valLbl.Text = tostring(value)
				TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
				if callback then pcall(callback, value) end
			end

			sliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end)
			UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
		end

		function TabInfo:CreateBind(text, defaultKey, callback)
			local key = defaultKey
			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(0.95, 0, 0, 35); frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
			lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13

			local btn = Instance.new("TextButton", frame)
			btn.Size = UDim2.new(0, 80, 0, 22); btn.Position = UDim2.new(1, -90, 0.5, -11)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); btn.Text = key.Name
			btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			local isBinding = false
			btn.MouseButton1Click:Connect(function()
				isBinding = true; btn.Text = "..."
			end)
			
			UIS.InputBegan:Connect(function(input)
				if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
					btn.Text = key.Name
					isBinding = false
					if callback then callback(key) end
				end
			end)
		end

		function TabInfo:CreateColorPicker(text)
			-- Un color picker simple pour le thème (Boutons prédéfinis)
			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(0.95, 0, 0, 60); frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, -10, 0, 25); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
			lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13

			local colorContainer = Instance.new("Frame", frame)
			colorContainer.Size = UDim2.new(1, -20, 0, 25); colorContainer.Position = UDim2.new(0, 10, 0, 25); colorContainer.BackgroundTransparency = 1
			local layout = Instance.new("UIListLayout", colorContainer); layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 8)

			local colors = {
				Color3.fromRGB(150, 100, 255), -- Violet
				Color3.fromRGB(255, 80, 80),   -- Rouge
				Color3.fromRGB(80, 255, 120),  -- Vert
				Color3.fromRGB(80, 180, 255),  -- Bleu
				Color3.fromRGB(255, 200, 50),  -- Or
				Color3.fromRGB(255, 255, 255)  -- Blanc
			}

			for _, col in ipairs(colors) do
				local btn = Instance.new("TextButton", colorContainer)
				btn.Size = UDim2.new(0, 25, 0, 25); btn.BackgroundColor3 = col; btn.Text = ""
				Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
				btn.MouseButton1Click:Connect(function() Library:UpdateTheme(col) end)
			end
		end

		return TabInfo
	end
	return Window
end


-- =====================================================================
-- 🛠️ UTILISATION DE L'INTERFACE (C'EST ICI QUE TU CODES TES SYSTÈMES) 🛠️
-- =====================================================================

-- 1. Initialisation de la fenêtre principale
local Menu = Library:CreateWindow("👑 CROWN MENU")

-- 2. Création des catégories (Onglets)
local TabPvP = Menu:CreateTab("PvP")
local TabVisuals = Menu:CreateTab("Visuals")
local TabPlayer = Menu:CreateTab("Player")
local TabMisc = Menu:CreateTab("Misc")
local TabConfigs = Menu:CreateTab("Configs")


-- ================= SECTION PVP =================
TabPvP:CreateSection("Combat Assist")

TabPvP:CreateToggle("KillAura", false, function(state)
    -- Mets la logique de ton KillAura ici !
    if state then
        print("KillAura Activé")
    else
        print("KillAura Désactivé")
    end
end)

TabPvP:CreateSlider("KillAura Distance", 5, 100, 20, function(value)
    -- Logique pour régler la portée
    print("Portée configurée sur :", value)
end)


-- ================= SECTION VISUALS =================
TabVisuals:CreateSection("ESP & Chams")

TabVisuals:CreateToggle("Enable ESP", false, function(state)
    -- Logique ESP
end)


-- ================= SECTION PLAYER =================
TabPlayer:CreateSection("Local Player")

TabPlayer:CreateToggle("NoClip", false, function(state)
    -- Logique du NoClip
end)

TabPlayer:CreateSlider("WalkSpeed", 16, 200, 16, function(value)
    -- Exemple: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)


-- ================= SECTION MISC =================
TabMisc:CreateSection("Automatisation")

TabMisc:CreateToggle("Auto Farm (NPCs)", false, function(state)
    -- Colle ton système de téléportation AutoFarm ici !
    if state then
        print("Démarrage de l'Auto Farm...")
    else
        print("Arrêt de l'Auto Farm.")
    end
end)

TabMisc:CreateToggle("Auto Quest", false, function(state)
    -- Logique de prise de quête automatique
end)


-- ================= SECTION CONFIGS =================
TabConfigs:CreateSection("Personnalisation de l'UI")

-- Ce bouton gère le système interne du framework tout seul !
TabConfigs:CreateColorPicker("Couleur du Thème")

TabConfigs:CreateSection("Raccourcis du Menu")

TabConfigs:CreateBind("Touche Afficher/Cacher", Library.ToggleKey, function(newKey)
    -- Modifie la touche d'ouverture globale
    Library.ToggleKey = newKey
end)
