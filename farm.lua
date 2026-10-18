local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- Unload a previous instance of this script (replaces the old CoreGui destroy check)
if getgenv().EvadeUnload then
	getgenv().EvadeUnload()
end

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

getgenv().EvadeUnload = function()
	_G.Items = false
	_G.Avoid = false
	Library:Unload()
end

-- =====================  LOGIC  =====================

local function Items()
	task.spawn(function()
		while _G.Items do
			task.wait()
			pcall(function()
				local Tickets = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
				if not Tickets then
					task.wait(0.2)
					return
				end

				local char = game:GetService("Players").LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not root then
					return
				end

				for _, ticket in pairs(Tickets:GetChildren()) do
					if ticket:FindFirstChild("HumanoidRootPart") then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						root.CFrame = ticket.HumanoidRootPart.CFrame + Vector3.new(0, 1.5, 0)
						break
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

	-- Exclude non-threat structures, collectibles, and map elements
	local instName = inst.Name
	if instName == "Tickets" or instName == "Ticket" or instName == "ItemSpawns" or instName == "ItemSpawn"
		or instName == "Map" or instName == "Terrain" or instName == "Camera" then
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
					if not child:IsA("Terrain") and not child:IsA("Camera") and child.Name ~= "Map" and child.Name ~= "Effects" then
						checkAndAddThreat(child)
					end
				end

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
					task.wait(0.5) -- Cool down to prevent rapid repeated teleports
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
	Tooltip = "Randomly teleports to an item spawn far from Nextbots and special round threats when one approaches",
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
		Avoid()
	end
end)

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
