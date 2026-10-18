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

				-- Collect all Nextbot positions and check if any are within 200 studs
				local nextbotPositions = {}
				local nearestDist = 200
				local hasThreat = false

				local playersFolder = workspace:FindFirstChild("Players")
				if playersFolder then
					for _, plr in pairs(playersFolder:GetChildren()) do
						if plr:GetAttribute("AI") == true and plr:FindFirstChild("HumanoidRootPart") then
							local pos = plr.HumanoidRootPart.Position
							table.insert(nextbotPositions, pos)
							local dist = (root.Position - pos).Magnitude
							if dist < nearestDist then
								hasThreat = true
							end
						end
					end
				end

				if not hasThreat then
					return
				end

				-- Get all ItemSpawns from the map
				local allSpawns = {}
				local ItemSpawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ItemSpawns")
				if ItemSpawns then
					for _, sp in pairs(ItemSpawns:GetChildren()) do
						if sp:IsA("BasePart") or sp.Name == "ItemSpawn" then
							table.insert(allSpawns, sp)
						end
					end
				end

				if #allSpawns == 0 then
					return
				end

				-- Filter spawns that are far away from all Nextbots (>= 60 studs)
				local safeSpawns = {}
				local bestSpawn, maxDist = nil, -1

				for _, sp in ipairs(allSpawns) do
					local spPos = sp.Position
					local minDistanceToNextbot = math.huge
					for _, nbPos in ipairs(nextbotPositions) do
						local d = (spPos - nbPos).Magnitude
						if d < minDistanceToNextbot then
							minDistanceToNextbot = d
						end
					end

					if minDistanceToNextbot >= 200 then
						table.insert(safeSpawns, sp)
					end

					if minDistanceToNextbot > maxDist then
						maxDist = minDistanceToNextbot
						bestSpawn = sp
					end
				end

				-- Randomly choose from safe spawns, or fallback to the furthest spawn
				local targetSpawn = nil
				if #safeSpawns > 0 then
					targetSpawn = safeSpawns[math.random(1, #safeSpawns)]
				else
					targetSpawn = bestSpawn
				end

				if targetSpawn then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					root.CFrame = targetSpawn.CFrame + Vector3.new(0, 2, 0)
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
	Tooltip = "Randomly teleports to an item spawn far from Nextbots when one approaches",
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