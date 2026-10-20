local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- Unload a previous instance of this script (cleans up UI, platform, anti-afk)
if getgenv().EvadeUnload then
	getgenv().EvadeUnload()
end

-- Extra cleanup for any stale GUI or platforms from previous executions
pcall(function()
	local oldPlatform = workspace:FindFirstChild("EvadeSafePlatform")
	if oldPlatform then oldPlatform:Destroy() end
	local pGui = (gethui and gethui()) or game:GetService("CoreGui") or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"))
	local oldHud = pGui and pGui:FindFirstChild("thisoneissocoldww")
	if oldHud then oldHud:Destroy() end
	if game:GetService("CoreGui"):FindFirstChild("thisoneissocoldww") then
		game:GetService("CoreGui").thisoneissocoldww:Destroy()
	end
end)

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

-- Forward declarations for cleanup routines
local cleanupSafePlatform
local disableAntiAfk
local destroyAntiAfkHUD

getgenv().EvadeUnload = function()
	_G.Items = false
	_G.Avoid = false
	_G.AntiAfk = false
	_G.AntiAfkHUD = false

	if cleanupSafePlatform then
		cleanupSafePlatform()
	end
	if disableAntiAfk then
		disableAntiAfk()
	end
	if destroyAntiAfkHUD then
		destroyAntiAfkHUD()
	end

	Library:Unload()
end

-- =====================  SAFE PLATFORM (OUTSIDE MAP)  =====================

local safePlatform = nil
local lastKnownMapPos = nil

cleanupSafePlatform = function()
	if safePlatform then
		pcall(function()
			safePlatform:Destroy()
		end)
		safePlatform = nil
	end
end

local function getSafePosition()
	local height = (Options and Options.SafeHeight and Options.SafeHeight.Value) or 500
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")

	local posX = 0
	local posZ = 0

	if root and root.Position.Y < (height - 50) then
		lastKnownMapPos = Vector3.new(root.Position.X, 0, root.Position.Z)
	end

	if lastKnownMapPos then
		posX = lastKnownMapPos.X
		posZ = lastKnownMapPos.Z
	else
		local mapFolder = workspace:FindFirstChild("Map")
			or (workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map"))
		if mapFolder then
			pcall(function()
				if mapFolder:IsA("Model") then
					local pivot = mapFolder:GetPivot()
					posX = pivot.Position.X
					posZ = pivot.Position.Z
				end
			end)
		end
	end

	return Vector3.new(posX, height, posZ)
end

local function ensureSafePlatform(pos)
	if not safePlatform or not safePlatform.Parent or safePlatform.Parent ~= workspace then
		cleanupSafePlatform()
		local part = Instance.new("Part")
		part.Name = "EvadeSafePlatform"
		part.Size = Vector3.new(35, 2, 35)
		part.Anchored = true
		part.CanCollide = true
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(0, 170, 255)
		part.Transparency = 0.5
		part.CFrame = CFrame.new(pos - Vector3.new(0, 2, 0))
		part.Parent = workspace
		safePlatform = part
	else
		safePlatform.CFrame = CFrame.new(pos - Vector3.new(0, 2, 0))
	end
	return safePlatform
end

local function teleportToSafeSpot()
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local safePos = getSafePosition()
	ensureSafePlatform(safePos)

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = CFrame.new(safePos + Vector3.new(0, 3, 0))
end

-- =====================  ANTI-AFK (FROM EVXNCODES)  =====================

local antiAfkConn = nil
local antiAfkGui = nil
local antiAfkActive = false
local antiAfkRenderConn = nil

disableAntiAfk = function()
	if antiAfkConn then
		antiAfkConn:Disconnect()
		antiAfkConn = nil
	end
end

local function enableAntiAfk()
	disableAntiAfk()
	local VirtualUser = game:GetService("VirtualUser")
	antiAfkConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end)
end

destroyAntiAfkHUD = function()
	antiAfkActive = false
	if antiAfkRenderConn then
		antiAfkRenderConn:Disconnect()
		antiAfkRenderConn = nil
	end
	if antiAfkGui then
		pcall(function() antiAfkGui:Destroy() end)
		antiAfkGui = nil
	end
	pcall(function()
		local pGui = (gethui and gethui()) or game:GetService("CoreGui") or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"))
		local old = pGui and pGui:FindFirstChild("thisoneissocoldww")
		if old then old:Destroy() end
		if game:GetService("CoreGui"):FindFirstChild("thisoneissocoldww") then
			game:GetService("CoreGui").thisoneissocoldww:Destroy()
		end
	end)
end

local function createAntiAfkHUD()
	destroyAntiAfkHUD()
	antiAfkActive = true

	local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

	local thisoneissocoldww = Instance.new("ScreenGui")
	local madebybloodofbatus = Instance.new("Frame")
	local UICornerw = Instance.new("UICorner")
	local DestroyButton = Instance.new("TextButton")
	local uselesslabelone = Instance.new("TextLabel")
	local timerlabel = Instance.new("TextLabel")
	local uselesslabeltwo = Instance.new("TextLabel")
	local fpslabel = Instance.new("TextLabel")
	local uselesslabelthree = Instance.new("TextLabel")
	local pinglabel = Instance.new("TextLabel")
	local uselessframeone = Instance.new("Frame")
	local UICornerww = Instance.new("UICorner")
	local uselesslabelfour = Instance.new("TextLabel")

	thisoneissocoldww.Name = "thisoneissocoldww"
	thisoneissocoldww.Parent = parentGui
	thisoneissocoldww.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	madebybloodofbatus.Name = "madebybloodofbatus"
	madebybloodofbatus.Parent = thisoneissocoldww
	madebybloodofbatus.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	madebybloodofbatus.Position = UDim2.new(0.0854, 0, 0.1312, 0)
	madebybloodofbatus.Size = UDim2.new(0, 225, 0, 96)

	UICornerw.Name = "UICornerw"
	UICornerw.Parent = madebybloodofbatus

	DestroyButton.Name = "DestroyButton"
	DestroyButton.Parent = madebybloodofbatus
	DestroyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	DestroyButton.BackgroundTransparency = 1.000
	DestroyButton.Position = UDim2.new(0.8717, 0, 0.0245, 0)
	DestroyButton.Size = UDim2.new(0, 27, 0, 15)
	DestroyButton.Font = Enum.Font.SourceSans
	DestroyButton.Text = "X"
	DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	DestroyButton.TextSize = 14.000

	DestroyButton.MouseButton1Click:Connect(function()
		if Toggles and Toggles.AntiAfkHUD then
			Toggles.AntiAfkHUD:SetValue(false)
		else
			destroyAntiAfkHUD()
		end
	end)

	uselesslabelone.Name = "uselesslabelone"
	uselesslabelone.Parent = madebybloodofbatus
	uselesslabelone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelone.BackgroundTransparency = 1.000
	uselesslabelone.Position = UDim2.new(0.3024, 0, 0, 0)
	uselesslabelone.Size = UDim2.new(0, 95, 0, 24)
	uselesslabelone.Font = Enum.Font.SourceSans
	uselesslabelone.Text = "Anti Afk V1 By Evxn#6765"
	uselesslabelone.TextColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelone.TextSize = 14.000

	timerlabel.Name = "timerlabel"
	timerlabel.Parent = madebybloodofbatus
	timerlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	timerlabel.BackgroundTransparency = 1.000
	timerlabel.Position = UDim2.new(0.6534, 0, 0.6819, 0)
	timerlabel.Size = UDim2.new(0, 60, 0, 24)
	timerlabel.Font = Enum.Font.SourceSans
	timerlabel.Text = "0:0:0"
	timerlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerlabel.TextSize = 14.000

	uselesslabeltwo.Name = "uselesslabeltwo"
	uselesslabeltwo.Parent = madebybloodofbatus
	uselesslabeltwo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabeltwo.BackgroundTransparency = 1.000
	uselesslabeltwo.Position = UDim2.new(0.0388, 0, 0.3738, 0)
	uselesslabeltwo.Size = UDim2.new(0, 29, 0, 24)
	uselesslabeltwo.Font = Enum.Font.SourceSans
	uselesslabeltwo.Text = "Ping: "
	uselesslabeltwo.TextColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabeltwo.TextSize = 14.000

	fpslabel.Name = "fpslabel"
	fpslabel.Parent = madebybloodofbatus
	fpslabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fpslabel.BackgroundTransparency = 1.000
	fpslabel.Position = UDim2.new(0.7242, 0, 0.3587, 0)
	fpslabel.Size = UDim2.new(0, 55, 0, 24)
	fpslabel.Font = Enum.Font.SourceSans
	fpslabel.Text = "..."
	fpslabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fpslabel.TextSize = 14.000

	uselesslabelthree.Name = "uselesslabelthree"
	uselesslabelthree.Parent = madebybloodofbatus
	uselesslabelthree.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelthree.BackgroundTransparency = 1.000
	uselesslabelthree.Position = UDim2.new(0.5069, 0, 0.3525, 0)
	uselesslabelthree.Size = UDim2.new(0, 26, 0, 24)
	uselesslabelthree.Font = Enum.Font.SourceSans
	uselesslabelthree.Text = "Fps: "
	uselesslabelthree.TextColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelthree.TextSize = 14.000

	pinglabel.Name = "pinglabel"
	pinglabel.Parent = madebybloodofbatus
	pinglabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pinglabel.BackgroundTransparency = 1.000
	pinglabel.Position = UDim2.new(0.2033, 0, 0.3715, 0)
	pinglabel.Size = UDim2.new(0, 55, 0, 24)
	pinglabel.Font = Enum.Font.SourceSans
	pinglabel.Text = "..."
	pinglabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	pinglabel.TextSize = 14.000
	pinglabel.TextWrapped = true

	uselessframeone.Name = "uselessframeone"
	uselessframeone.Parent = madebybloodofbatus
	uselessframeone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	uselessframeone.Position = UDim2.new(0.0044, 0, 0.2433, 0)
	uselessframeone.Size = UDim2.new(0, 224, 0, 5)

	UICornerww.CornerRadius = UDim.new(0, 50)
	UICornerww.Name = "UICornerww"
	UICornerww.Parent = uselessframeone

	uselesslabelfour.Name = "uselesslabelfour"
	uselesslabelfour.Parent = madebybloodofbatus
	uselesslabelfour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelfour.BackgroundTransparency = 1.000
	uselesslabelfour.Position = UDim2.new(0.0580, 0, 0.8125, 0)
	uselesslabelfour.Size = UDim2.new(0, 95, 0, 12)
	uselesslabelfour.Font = Enum.Font.SourceSans
	uselesslabelfour.Text = "Anti-Afk Auto Enabled"
	uselesslabelfour.TextColor3 = Color3.fromRGB(255, 255, 255)
	uselesslabelfour.TextSize = 14.000

	-- Smooth Dragging
	local Drag = madebybloodofbatus
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local dragging = false
	local dragInput, dragStart, startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		local SmoothDrag = {
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		}
		TweenService:Create(Drag, TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), SmoothDrag):Play()
	end

	Drag.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Drag.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Drag.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and Drag.Size then
			updateDrag(input)
		end
	end)

	-- FPS calculation
	local RunService = game:GetService("RunService")
	local sec = tick()
	local FPS = {}

	antiAfkRenderConn = RunService.RenderStepped:Connect(function()
		if not antiAfkActive or not fpslabel or not fpslabel.Parent then return end
		local fr = tick()
		for index = #FPS, 1, -1 do
			FPS[index + 1] = (FPS[index] >= fr - 1) and FPS[index] or nil
		end
		FPS[1] = fr
		local fps = (tick() - sec >= 1 and #FPS) or (#FPS / (tick() - sec))
		fpslabel.Text = tostring(math.floor(fps))
	end)

	-- Ping loop
	task.spawn(function()
		while antiAfkActive and pinglabel and pinglabel.Parent do
			task.wait(1)
			pcall(function()
				local stats = game:GetService("Stats")
				local perfStats = stats:FindFirstChild("PerformanceStats")
				if perfStats and perfStats:FindFirstChild("Ping") then
					local ping = math.floor(perfStats.Ping:GetValue())
					pinglabel.Text = tostring(ping)
				end
			end)
		end
	end)

	-- Session Timer loop
	task.spawn(function()
		local saniye = 0
		local dakika = 0
		local saat = 0
		while antiAfkActive and timerlabel and timerlabel.Parent do
			task.wait(1)
			saniye = saniye + 1
			if saniye >= 60 then
				saniye = 0
				dakika = dakika + 1
			end
			if dakika >= 60 then
				dakika = 0
				saat = saat + 1
			end
			timerlabel.Text = string.format("%d:%d:%d", saat, dakika, saniye)
		end
	end)

	antiAfkGui = thisoneissocoldww
	return thisoneissocoldww
end

-- =====================  LOGIC  =====================

local function Items()
	task.spawn(function()
		while _G.Items do
			task.wait()
			pcall(function()
				local Tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
				local hasTicket = false

				if Tickets then
					local char = game:GetService("Players").LocalPlayer.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					if root then
						local ticketChildren = Tickets:GetChildren()
						for _, ticket in pairs(ticketChildren) do
							if ticket:FindFirstChild("HumanoidRootPart") then
								hasTicket = true
								root.AssemblyLinearVelocity = Vector3.zero
								root.AssemblyAngularVelocity = Vector3.zero
								root.CFrame = ticket.HumanoidRootPart.CFrame + Vector3.new(0, 1.5, 0)
								break
							end
						end
					end
				end

				-- If no tickets remain and Avoid is enabled on Sky Platform mode, retreat to the safe platform outside the map
				if not hasTicket and _G.Avoid then
					local mode = (Options and Options.AvoidMode and Options.AvoidMode.Value) or "Sky Platform"
					if mode == "Sky Platform" then
						local char = game:GetService("Players").LocalPlayer.Character
						local root = char and char:FindFirstChild("HumanoidRootPart")
						local height = (Options and Options.SafeHeight and Options.SafeHeight.Value) or 500
						if root and root.Position.Y < (height - 50) then
							teleportToSafeSpot()
						end
					end
				end

				task.wait(0.2)
			end)
		end
	end)
end

local threatKeywords = {
	"bobo",
	"happi",
	"munci",
	"plushie",
	"jard",
	"halp",
	"galp",
	"balp",
	"vinedog",
	"vine dog",
	"amelia",
	"incursion",
	"soldier",
	"rebel",
	"mimic",
	"swarm",
	"infected",
	"nextbot",
	"hazard",
	"boss",
	"threat",
}

local threatAttributes = {
	"AI",
	"IsAI",
	"Bot",
	"IsBot",
	"Nextbot",
	"Entity",
	"Special",
	"SpecialRound",
	"Boss",
	"Threat",
	"Hazard",
	"Hostile",
	"Infected",
}

local function getSpawnCFrame(sp)
	if not sp then return nil end
	if sp:IsA("BasePart") then
		return sp.CFrame
	elseif sp:IsA("Model") then
		return sp:GetPivot()
	end
	return nil
end

local function getInstancePosition(inst)
	if not inst then return nil end
	if inst:IsA("Model") then
		local hrp = inst:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then
			return hrp.Position
		end
		if inst.PrimaryPart then
			return inst.PrimaryPart.Position
		end
		local part = inst:FindFirstChildWhichIsA("BasePart")
		if part then
			return part.Position
		end
		local pivot = inst:GetPivot()
		return pivot.Position
	elseif inst:IsA("BasePart") then
		return inst.Position
	end
	return nil
end

local function isThreat(inst, localChar)
	if not inst or inst == localChar or inst:IsDescendantOf(localChar) then
		return false
	end

	-- Exclude non-threat structures, collectibles, safe platform, and map elements
	local instName = inst.Name
	if instName == "Tickets" or instName == "Ticket" or instName == "ItemSpawns" or instName == "ItemSpawn"
		or instName == "Map" or instName == "Terrain" or instName == "Camera" or instName == "EvadeSafePlatform" then
		return false
	end

	local PlayersService = game:GetService("Players")
	local plr = PlayersService:GetPlayerFromCharacter(inst)

	if plr then
		if plr == PlayersService.LocalPlayer then
			return false
		end
		-- Check if player is infected in Infection special round
		local isInfected = inst:GetAttribute("Infected") == true
			or plr:GetAttribute("Infected") == true
			or inst:GetAttribute("Team") == "Infected"
			or (plr.Team and string.lower(plr.Team.Name) == "infected")
			or inst:GetAttribute("Role") == "Infected"
			or inst:FindFirstChild("Infected") ~= nil
		return isInfected
	end

	-- Non-player: check attributes
	for _, attr in ipairs(threatAttributes) do
		local val = inst:GetAttribute(attr)
		if val == true or (type(val) == "string" and string.lower(val) == "true") then
			return true
		end
	end

	-- Non-player: check if inside dedicated threat/entity/player folders
	local parent = inst.Parent
	if parent then
		local pName = parent.Name
		if pName == "Players" or pName == "Entities" or pName == "NPCs" or pName == "Bots"
			or pName == "Special" or pName == "SpecialRound" or pName == "Hazards" then
			return true
		end
	end

	-- Check special round keywords in name
	local lowerName = string.lower(instName)
	for _, kw in ipairs(threatKeywords) do
		if string.find(lowerName, kw, 1, true) then
			return true
		end
	end

	return false
end

local function Avoid()
	task.spawn(function()
		while _G.Avoid do
			task.wait(0.1)
			pcall(function()
				local LocalPlayer = game:GetService("Players").LocalPlayer
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not root then
					return
				end

				local mode = (Options and Options.AvoidMode and Options.AvoidMode.Value) or "Sky Platform"
				local safeHeight = (Options and Options.SafeHeight and Options.SafeHeight.Value) or 500

				-- Collect all Nextbot and special round threat positions
				local threatPositions = {}
				local nearestDist = 200
				local hasThreat = false
				local seen = {}

				local function checkAndAddThreat(inst)
					if not inst or seen[inst] then return end
					seen[inst] = true
					if isThreat(inst, char) then
						local pos = getInstancePosition(inst)
						if pos then
							table.insert(threatPositions, pos)
							local dist = (root.Position - pos).Magnitude
							if dist < nearestDist then
								hasThreat = true
							end
						end
					end
				end

				local folderNames = {
					"Players", "Entities", "NPCs", "Bots", "Special", "SpecialRound", "Hazards"
				}

				-- Search workspace folders
				for _, name in ipairs(folderNames) do
					local f = workspace:FindFirstChild(name)
					if f then
						for _, child in ipairs(f:GetChildren()) do
							checkAndAddThreat(child)
						end
					end
				end

				-- Search workspace.Game folders
				local gameFolder = workspace:FindFirstChild("Game")
				if gameFolder then
					for _, name in ipairs(folderNames) do
						local f = gameFolder:FindFirstChild(name)
						if f then
							for _, child in ipairs(f:GetChildren()) do
								checkAndAddThreat(child)
							end
						end
					end
				end

				-- Search Map folders
				local mapFolder = workspace:FindFirstChild("Map") or (gameFolder and gameFolder:FindFirstChild("Map"))
				if mapFolder then
					for _, name in ipairs({"Entities", "NPCs", "Hazards", "Special"}) do
						local f = mapFolder:FindFirstChild(name)
						if f then
							for _, child in ipairs(f:GetChildren()) do
								checkAndAddThreat(child)
							end
						end
					end
				end

				-- Search direct workspace children for loose special round entities
				for _, child in ipairs(workspace:GetChildren()) do
					if not child:IsA("Terrain") and not child:IsA("Camera") and child.Name ~= "Map" and child.Name ~= "Effects" and child.Name ~= "EvadeSafePlatform" then
						checkAndAddThreat(child)
					end
				end

				-- Handle Avoid logic by selected mode
				if mode == "Sky Platform" then
					local isBelowSafe = root.Position.Y < (safeHeight - 50)

					-- Check if Items farm is actively collecting
					local ticketsExist = false
					if _G.Items then
						local Tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
						if Tickets and #Tickets:GetChildren() > 0 then
							ticketsExist = true
						end
					end

					-- If a threat gets close, escape immediately to safe platform outside the map
					if hasThreat then
						teleportToSafeSpot()
						task.wait(0.3)
					elseif isBelowSafe and not ticketsExist then
						-- Keep the player safely outside the map on the platform
						teleportToSafeSpot()
						task.wait(0.5)
					end

				elseif mode == "On Threat (Sky)" then
					if hasThreat then
						teleportToSafeSpot()
						task.wait(0.5)
					end

				elseif mode == "Item Spawns" then
					if not hasThreat then
						return
					end

					-- Get all ItemSpawns from the map
					local allSpawns = {}
					local ItemSpawns = (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ItemSpawns"))
						or (gameFolder and gameFolder:FindFirstChild("Map") and gameFolder.Map:FindFirstChild("ItemSpawns"))
						or (gameFolder and gameFolder:FindFirstChild("ItemSpawns"))
						or workspace:FindFirstChild("ItemSpawns")

					if ItemSpawns then
						for _, sp in pairs(ItemSpawns:GetChildren()) do
							if sp:IsA("BasePart") or sp:IsA("Model") or sp.Name == "ItemSpawn" then
								table.insert(allSpawns, sp)
							end
						end
					end

					if #allSpawns == 0 then
						return
					end

					-- Filter spawns that are far away from all threats (>= 200 studs)
					local safeSpawns = {}
					local bestSpawn, maxDist = nil, -1

					for _, sp in ipairs(allSpawns) do
						local cf = getSpawnCFrame(sp)
						if cf then
							local spPos = cf.Position
							local minDistanceToThreat = math.huge
							for _, tPos in ipairs(threatPositions) do
								local d = (spPos - tPos).Magnitude
								if d < minDistanceToThreat then
									minDistanceToThreat = d
								end
							end

							if minDistanceToThreat >= 200 then
								table.insert(safeSpawns, { spawn = sp, cf = cf })
							end

							if minDistanceToThreat > maxDist then
								maxDist = minDistanceToThreat
								bestSpawn = { spawn = sp, cf = cf }
							end
						end
					end

					-- Randomly choose from safe spawns, or fallback to the furthest spawn
					local targetSpawn = nil
					if #safeSpawns > 0 then
						targetSpawn = safeSpawns[math.random(1, #safeSpawns)]
					else
						targetSpawn = bestSpawn
					end

					if targetSpawn and targetSpawn.cf then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						root.CFrame = targetSpawn.cf + Vector3.new(0, 2, 0)
						task.wait(0.5)
					end
				end
			end)
		end
	end)
end

-- =====================  UI  =====================

local Window = Library:CreateWindow({
	Title = "Snivyware",
	Footer = "Evade AUTOFARM",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Main = Window:AddTab("Main", "user")

local Left = Main:AddGroupbox({
	Side = "Left",
	Name = "Features",
})

Left:AddToggle("CollectItems", {
	Text = "Collect Items",
	Tooltip = "Teleports to event tickets and collects them",
	Default = false,
})

Left:AddToggle("AvoidNextbot", {
	Text = "Avoid Nextbot",
	Tooltip = "Goes outside the map onto a safe anchored platform away from Nextbots and hazards",
	Default = false,
})

Left:AddDropdown("AvoidMode", {
	Values = { "Sky Platform", "On Threat (Sky)", "Item Spawns" },
	Default = 1,
	Multi = false,
	Text = "Avoid Mode",
	Tooltip = "Sky Platform: Stays safely outside/above the map on an anchored platform\nOn Threat (Sky): Escapes outside only when threatened\nItem Spawns: Original spawn-hopping logic",
})

Left:AddSlider("SafeHeight", {
	Text = "Safe Platform Height",
	Default = 500,
	Min = 200,
	Max = 2000,
	Rounding = 0,
	Compact = false,
})

local Right = Main:AddGroupbox({
	Side = "Right",
	Name = "Anti AFK",
})

Right:AddToggle("AntiAfk", {
	Text = "Anti AFK",
	Tooltip = "Prevents Roblox 20-minute idle kick using VirtualUser (by evxncodes)",
	Default = true,
})

Right:AddToggle("AntiAfkHUD", {
	Text = "Show Anti-AFK HUD",
	Tooltip = "Displays the draggable HUD widget with Ping, FPS, and Session Timer from the anti-afk script",
	Default = false,
})

-- Recommended pattern: build the UI first, wire logic with OnChanged
Toggles.CollectItems:OnChanged(function()
	_G.Items = Toggles.CollectItems.Value
	print("Items: ", _G.Items)
	if _G.Items then
		Items()
	end
end)

Toggles.AvoidNextbot:OnChanged(function()
	_G.Avoid = Toggles.AvoidNextbot.Value
	print("Avoid: ", _G.Avoid)
	if _G.Avoid then
		local mode = (Options and Options.AvoidMode and Options.AvoidMode.Value) or "Sky Platform"
		if mode == "Sky Platform" then
			teleportToSafeSpot()
		end
		Avoid()
	else
		cleanupSafePlatform()
	end
end)

Options.AvoidMode:OnChanged(function()
	if _G.Avoid then
		if Options.AvoidMode.Value == "Sky Platform" then
			teleportToSafeSpot()
		else
			cleanupSafePlatform()
		end
	end
end)

Options.SafeHeight:OnChanged(function()
	if _G.Avoid and Options.AvoidMode.Value == "Sky Platform" then
		teleportToSafeSpot()
	end
end)

Toggles.AntiAfk:OnChanged(function()
	_G.AntiAfk = Toggles.AntiAfk.Value
	print("AntiAfk: ", _G.AntiAfk)
	if _G.AntiAfk then
		enableAntiAfk()
	else
		disableAntiAfk()
	end
end)

Toggles.AntiAfkHUD:OnChanged(function()
	_G.AntiAfkHUD = Toggles.AntiAfkHUD.Value
	print("AntiAfkHUD: ", _G.AntiAfkHUD)
	if _G.AntiAfkHUD then
		createAntiAfkHUD()
	else
		destroyAntiAfkHUD()
	end
end)

-- Initialize Anti-AFK default state
if Toggles.AntiAfk.Value then
	Toggles.AntiAfk:RunChanged()
end
if Toggles.AntiAfkHUD.Value then
	Toggles.AntiAfkHUD:RunChanged()
end

-- =====================  UI SETTINGS  =====================

local UISettings = Window:AddTab("UI Settings", "settings")
local MenuGroup = UISettings:AddGroupbox({
	Side = "Left",
	Name = "Menu",
})

MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	getgenv().EvadeUnload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- custom keybind for the menu
