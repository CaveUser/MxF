-- ======================================================
-- 👑 MxF HUB - LOADER V1.0.1
-- Authentication, Launcher & SECURE Injection System
-- ======================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("MxFHubLoader") then targetGui.MxFHubLoader:Destroy() end

-- Configuration API
local API_URL = "https://accepting-newark-symposium-mortality.trycloudflare.com/verify"
local API_SECRET = "4IfE6mMxbO_flFZKyRNRt1hznL3Q3sWJRChck5C83DA"

local requestFunc = request or http_request or (http and http.request) or syn and syn.request
local hwid = ""
pcall(function()
	if gethwid then hwid = gethwid()
	else hwid = game:GetService("RbxAnalyticsService"):GetClientId() end
end)

local function VerifyKey(keyToTest)
	if not requestFunc then return false, "Executor not supported" end
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
			else return false, "API Error" end
		elseif response.StatusCode == 429 then return false, "Rate limited"
		else return false, "API Error (" .. tostring(response.StatusCode) .. ")" end
	end
	return false, "Connection error"
end

-- ==========================================
-- UI DESIGN (CLEAN & MODERN)
-- ==========================================
local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "MxFHubLoader"
screenGui.DisplayOrder = 999

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 280)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
mainFrame.BackgroundTransparency = 1
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(45, 45, 50)
stroke.Thickness = 1.5
stroke.Transparency = 1

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "MxF HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextTransparency = 1

-- ==========================================
-- ETAPE 1 : AUTHENTIFICATION
-- ==========================================
local authContainer = Instance.new("Frame", mainFrame)
authContainer.Size = UDim2.new(1, 0, 1, -70)
authContainer.Position = UDim2.new(0, 0, 0, 70)
authContainer.BackgroundTransparency = 1

local keyInputBg = Instance.new("Frame", authContainer)
keyInputBg.Size = UDim2.new(0.8, 0, 0, 45)
keyInputBg.Position = UDim2.new(0.1, 0, 0, 20)
keyInputBg.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
Instance.new("UICorner", keyInputBg).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", keyInputBg).Color = Color3.fromRGB(50, 50, 55)

local keyBox = Instance.new("TextBox", keyInputBg)
keyBox.Size = UDim2.new(1, -20, 1, 0)
keyBox.Position = UDim2.new(0, 10, 0, 0)
keyBox.BackgroundTransparency = 1
keyBox.PlaceholderText = "Enter your Access Key..."
keyBox.Text = ""
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.TextXAlignment = Enum.TextXAlignment.Left

local verifyBtn = Instance.new("TextButton", authContainer)
verifyBtn.Size = UDim2.new(0.8, 0, 0, 45)
verifyBtn.Position = UDim2.new(0.1, 0, 0, 80)
verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
verifyBtn.Text = "Verify Key"
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 16
verifyBtn.TextColor3 = Color3.fromRGB(15, 16, 20)
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

local lootLabsBtn = Instance.new("TextButton", authContainer)
lootLabsBtn.Size = UDim2.new(0.8, 0, 0, 30)
lootLabsBtn.Position = UDim2.new(0.1, 0, 0, 135)
lootLabsBtn.BackgroundTransparency = 1
lootLabsBtn.Text = "🔗 Get Key (LootLabs)"
lootLabsBtn.Font = Enum.Font.Gotham
lootLabsBtn.TextSize = 13
lootLabsBtn.TextColor3 = Color3.fromRGB(150, 150, 160)

local statusLbl = Instance.new("TextLabel", authContainer)
statusLbl.Size = UDim2.new(1, 0, 0, 20)
statusLbl.Position = UDim2.new(0, 0, 0, 170)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12

-- ==========================================
-- ETAPE 2 : LAUNCHER (GAME SELECTOR)
-- ==========================================
local launcherContainer = Instance.new("Frame", mainFrame)
launcherContainer.Size = UDim2.new(1, 0, 1, -70)
launcherContainer.Position = UDim2.new(1, 0, 0, 70)
launcherContainer.BackgroundTransparency = 1

local gameTile = Instance.new("TextButton", launcherContainer)
gameTile.Size = UDim2.new(0.8, 0, 0, 150)
gameTile.Position = UDim2.new(0.1, 0, 0, 20)
gameTile.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
gameTile.Text = ""
Instance.new("UICorner", gameTile).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", gameTile).Color = Color3.fromRGB(50, 50, 55)

local gameImg = Instance.new("ImageLabel", gameTile)
gameImg.Size = UDim2.new(1, 0, 0, 100)
gameImg.Position = UDim2.new(0, 0, 0, 0)
gameImg.BackgroundTransparency = 1
gameImg.Image = "rbxassetid://13524673898"
gameImg.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", gameImg).CornerRadius = UDim.new(0, 10)

local imgCover = Instance.new("Frame", gameImg)
imgCover.Size = UDim2.new(1, 0, 0, 10)
imgCover.Position = UDim2.new(0, 0, 1, -5)
imgCover.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
imgCover.BorderSizePixel = 0

local gameName = Instance.new("TextLabel", gameTile)
gameName.Size = UDim2.new(1, -20, 0, 25)
gameName.Position = UDim2.new(0, 10, 0, 105)
gameName.BackgroundTransparency = 1
gameName.Text = "Sailor Piece"
gameName.Font = Enum.Font.GothamBold
gameName.TextSize = 16
gameName.TextColor3 = Color3.fromRGB(255, 255, 255)
gameName.TextXAlignment = Enum.TextXAlignment.Left

local gameStatus = Instance.new("TextLabel", gameTile)
gameStatus.Size = UDim2.new(1, -20, 0, 15)
gameStatus.Position = UDim2.new(0, 10, 0, 130)
gameStatus.BackgroundTransparency = 1
gameStatus.Text = "● Working Script"
gameStatus.Font = Enum.Font.Gotham
gameStatus.TextSize = 12
gameStatus.TextColor3 = Color3.fromRGB(50, 255, 100)
gameStatus.TextXAlignment = Enum.TextXAlignment.Left

-- ==========================================
-- ANIMATIONS & LOGIQUE
-- ==========================================
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
TweenService:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

lootLabsBtn.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard("https://lootdest.org/s?rcveAzTf")
		statusLbl.Text = "Link copied to clipboard!"
		statusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
	end
end)

verifyBtn.MouseButton1Click:Connect(function()
	local key = keyBox.Text
	verifyBtn.Text = "Checking..."
	
	local isValid, msg = VerifyKey(key)
	
	if isValid then
		verifyBtn.Text = "Success!"
		verifyBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
		
		task.wait(0.5)
		TweenService:Create(authContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(-1, 0, 0, 70)}):Play()
		TweenService:Create(launcherContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 70)}):Play()
		title.Text = "GAMES"
	else
		verifyBtn.Text = "Verify Key"
		statusLbl.Text = msg
		statusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
	end
end)

gameTile.MouseButton1Click:Connect(function()
	local closeTw = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	closeTw:Play()
	closeTw.Completed:Wait()
	screenGui:Destroy()
	
	-- ✅ INJECTION DU MAIN SCRIPT (SECURE HANDSHAKE)
	-- On génère un Token aléatoire
	local secureToken = "MxF_" .. tostring(math.random(1000000, 9999999))
	-- On le cache dans l'environnement global de l'exécuteur
	if getgenv then getgenv().MxF_Session_Token = secureToken end
	-- On l'envoie secrètement comme argument à loadstring
	loadstring(game:HttpGet("https://raw.githubusercontent.com/CaveUser/MxF/main/scripts/sailor.lua", true))(secureToken)
end)
