--// DMZ GUI Framework v4 (Module) - Redesigned
local DMZ = {}
DMZ.__index = DMZ

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function create(instance, props)
	local obj = Instance.new(instance)
	for i, v in pairs(props) do
		obj[i] = v
	end
	return obj
end

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

-- ╔══════════════════════════════╗
-- ║       PALETTE & STYLE        ║
-- ╚══════════════════════════════╝
local C = {
	BG        = Color3.fromRGB(13, 13, 18),
	SURFACE   = Color3.fromRGB(20, 20, 28),
	ELEVATED  = Color3.fromRGB(26, 26, 38),
	BORDER    = Color3.fromRGB(45, 45, 65),
	ACCENT    = Color3.fromRGB(108, 92, 231),
	ACCENT2   = Color3.fromRGB(0, 210, 150),
	TEXT      = Color3.fromRGB(230, 228, 245),
	MUTED     = Color3.fromRGB(120, 118, 148),
	DANGER    = Color3.fromRGB(235, 75, 75),
	TAB_ACT   = Color3.fromRGB(108, 92, 231),
	TAB_INACT = Color3.fromRGB(22, 22, 32),
	BTN       = Color3.fromRGB(22, 22, 36),
	BTN_TRACK = Color3.fromRGB(30, 30, 45),
}

local function applyStroke(parent, color, thickness, transparency)
	local s = create("UIStroke", {
		Parent = parent,
		Color = color or C.BORDER,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	return s
end

local function corner(parent, radius)
	return create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius or 8) })
end

local function pad(parent, l, r, t, b)
	return create("UIPadding", {
		Parent = parent,
		PaddingLeft  = UDim.new(0, l or 8),
		PaddingRight = UDim.new(0, r or 8),
		PaddingTop   = UDim.new(0, t or 6),
		PaddingBottom= UDim.new(0, b or 6),
	})
end

-- ╔══════════════════════════════╗
-- ║         CREATE WINDOW        ║
-- ╚══════════════════════════════╝
function DMZ:CreateWindow(title)
	local selfObj = setmetatable({}, DMZ)

	local CoreGui = game:GetService("CoreGui")
	local ScreenGui = create("ScreenGui", {
		Parent = CoreGui,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	-- Main Frame
	local Frame = create("Frame", {
		Parent = ScreenGui,
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.3, -250, 0.3, -175),
		BackgroundColor3 = C.BG,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	corner(Frame, 12)
	applyStroke(Frame, C.ACCENT, 1.5, 0.6)

	-- ── Title Bar ──────────────────────────────────────────────────────────
	local TitleBar = create("Frame", {
		Parent = Frame,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.ELEVATED,
		BorderSizePixel = 0,
	})
	corner(TitleBar, 12)
	create("Frame", {
		Parent = TitleBar,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = C.ELEVATED,
		BorderSizePixel = 0,
	})

	create("Frame", {
		Parent = Frame,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = C.ACCENT,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
	})

	create("Frame", {
		Parent = TitleBar,
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.new(0, 10, 0.5, -8),
		BackgroundColor3 = C.ACCENT,
		BorderSizePixel = 0,
	})
	corner(create("Frame", {
		Parent = TitleBar,
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.new(0, 10, 0.5, -8),
		BackgroundColor3 = C.ACCENT,
		BorderSizePixel = 0,
	}), 4)

	local TitleText = create("TextLabel", {
		Parent = TitleBar,
		Text = title,
		Size = UDim2.new(1, -90, 1, 0),
		Position = UDim2.new(0, 22, 0, 0),
		Font = Enum.Font.GothamBold,
		TextColor3 = C.TEXT,
		TextSize = 14,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	-- ── Control Buttons ─────────────────────────────────────────────────────
	local function makeCtrlBtn(xOffset, label, bgColor, hoverColor, txtColor)
		local btn = create("TextButton", {
			Parent = TitleBar,
			Size = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(1, xOffset, 0.5, -11),
			Text = label,
			Font = Enum.Font.GothamBold,
			TextColor3 = txtColor or C.TEXT,
			TextSize = 13,
			BackgroundColor3 = bgColor,
			BorderSizePixel = 0,
		})
		corner(btn, 6)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = hoverColor }, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, { BackgroundColor3 = bgColor }, 0.12)
		end)
		return btn
	end

	local CloseButton    = makeCtrlBtn(-28, "×", Color3.fromRGB(45, 22, 28), C.DANGER, C.DANGER)
	local MinimizeButton = makeCtrlBtn(-54, "−", C.ELEVATED, C.BORDER, C.MUTED)

	-- ── Hide / Show / Destroy Logic ──────────────────────────────────────────
	-- × → hide saja (frame invisible)
	-- Right Ctrl → unhide / show kembali
	-- Right Ctrl + X → destroy permanent

	local hidden = false
	local savedSize = Frame.Size
	local savedPos  = Frame.Position

	local function hideGUI()
		savedSize = Frame.Size
		savedPos  = Frame.Position
		tween(Frame, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.25)
		task.wait(0.25)
		Frame.Visible = false
		hidden = true
	end

	local function showGUI()
		Frame.Size     = UDim2.new(0, 0, 0, 0)
		Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		Frame.Visible  = true
		tween(Frame, { Size = savedSize, Position = savedPos }, 0.25)
		hidden = false
	end

	-- Close button → hide saja
	CloseButton.MouseButton1Click:Connect(function()
		hideGUI()
	end)

	-- Keybind listener
	local rctrlHeld = false

	UserInputService.InputBegan:Connect(function(input, _gpe)
		if input.KeyCode == Enum.KeyCode.RightControl then
			rctrlHeld = true
			-- Right Ctrl → tampilkan kembali kalau sedang hidden
			if hidden then
				showGUI()
			end
		end

		-- Right Ctrl + X → destroy permanent
		if rctrlHeld and input.KeyCode == Enum.KeyCode.X then
			tween(Frame, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.25)
			task.wait(0.25)
			ScreenGui:Destroy()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.RightControl then
			rctrlHeld = false
		end
	end)

	-- ── Minimize ─────────────────────────────────────────────────────────────
	local minimized = false
	local lastSize  = Frame.Size
	local lastPos   = Frame.Position

	MinimizeButton.MouseButton1Click:Connect(function()
		if not minimized then
			lastSize = Frame.Size
			lastPos  = Frame.Position
			Frame.Size = UDim2.new(Frame.Size.X.Scale, Frame.Size.X.Offset, 0, 36)
			minimized = true
		else
			Frame.Size     = lastSize
			Frame.Position = lastPos
			minimized = false
		end
	end)

	-- ── Sidebar (Tabs) ───────────────────────────────────────────────────────
	local TabsFrame = create("Frame", {
		Parent = Frame,
		Size = UDim2.new(0, 115, 1, -46),
		Position = UDim2.new(0, 0, 0, 46),
		BackgroundColor3 = C.ELEVATED,
		BorderSizePixel = 0,
	})
	corner(TabsFrame, 0)

	create("Frame", {
		Parent = TabsFrame,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = C.BORDER,
		BorderSizePixel = 0,
	})

	local ScrollTabs = create("ScrollingFrame", {
		Parent = TabsFrame,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.ACCENT,
		BorderSizePixel = 0,
	})
	local ListTabs = create("UIListLayout", {
		Parent = ScrollTabs,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
	})
	pad(ScrollTabs, 6, 6, 8, 8)

	-- ── Content Area ─────────────────────────────────────────────────────────
	local ContentFrame = create("Frame", {
		Parent = Frame,
		Size = UDim2.new(1, -125, 1, -46),
		Position = UDim2.new(0, 125, 0, 46),
		BackgroundTransparency = 1,
	})

	local ScrollContent = create("ScrollingFrame", {
		Parent = ContentFrame,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.ACCENT,
		BorderSizePixel = 0,
	})

	local ListContent = create("UIListLayout", {
		Parent = ScrollContent,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
	})

	create("Frame", {
		Parent = ScrollContent,
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundTransparency = 1,
	})

	-- ── Drag ─────────────────────────────────────────────────────────────────
	local dragging, startPos, dragStart
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local delta = input.Position - dragStart
			Frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- ── Resize ───────────────────────────────────────────────────────────────
	local ResizeHandle = create("Frame", {
		Parent = Frame,
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		ZIndex = 2,
	})
	local grip = create("TextLabel", {
		Parent = ResizeHandle,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "⌟",
		Font = Enum.Font.GothamBold,
		TextColor3 = C.BORDER,
		TextSize = 16,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Bottom,
	})

	local resizing, startSize, startInput = false, nil, nil
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startSize = Frame.Size
			startInput = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local delta = input.Position - startInput
			Frame.Size = UDim2.new(
				startSize.X.Scale, math.max(300, startSize.X.Offset + delta.X),
				startSize.Y.Scale, math.max(200, startSize.Y.Offset + delta.Y)
			)
		end
	end)

	-- ── Responsive Text ──────────────────────────────────────────────────────
	local function updateTextSize()
		local width = Frame.AbsoluteSize.X
		local scaleFactor = math.clamp(width / 500, 0.5, 1)
		TitleText.TextSize = math.floor(14 * scaleFactor)
		CloseButton.TextSize = math.floor(13 * scaleFactor)
		MinimizeButton.TextSize = math.floor(13 * scaleFactor)
		for _, btn in ipairs(ScrollTabs:GetChildren()) do
			if btn:IsA("TextButton") then
				for _, c in ipairs(btn:GetChildren()) do
					if c:IsA("TextLabel") then
						c.TextSize = math.max(10, math.floor(13 * scaleFactor))
					end
				end
			end
		end
		for _, tabFrame in ipairs(ScrollContent:GetChildren()) do
			if tabFrame:IsA("Frame") then
				for _, item in ipairs(tabFrame:GetChildren()) do
					if item:IsA("ScrollingFrame") then
						for _, elem in ipairs(item:GetChildren()) do
							if elem:IsA("TextLabel") or elem:IsA("TextButton") then
								elem.TextSize = math.max(10, math.floor(13 * scaleFactor))
							end
						end
					end
				end
			end
		end
	end
	Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTextSize)

	-- ═══════════════════════════════════════════════════════════════════════
	--  TAB SYSTEM
	-- ═══════════════════════════════════════════════════════════════════════
	function selfObj:AddTab(name)

		local tabBtn = create("TextButton", {
			Parent = ScrollTabs,
			Text = "",
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = C.TAB_INACT,
			BorderSizePixel = 0,
			AutoButtonColor = false,
		})
		corner(tabBtn, 7)

		local tabIndicator = create("Frame", {
			Parent = tabBtn,
			Size = UDim2.new(0, 3, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			BackgroundColor3 = C.ACCENT,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		corner(tabIndicator, 2)

		local tabLabel = create("TextLabel", {
			Parent = tabBtn,
			Text = name,
			Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			Font = Enum.Font.GothamSemibold,
			TextColor3 = C.MUTED,
			TextSize = 13,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local tabFrame = create("Frame", {
			Parent = ScrollContent,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
		})
		local tabScroll = create("ScrollingFrame", {
			Parent = tabFrame,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.ACCENT,
			BorderSizePixel = 0,
		})
		local listLayout = create("UIListLayout", {
			Parent = tabScroll,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		})
		pad(tabScroll, 8, 8, 8, 8)

		tabBtn.MouseButton1Click:Connect(function()
			for _, c in pairs(ScrollContent:GetChildren()) do
				if c:IsA("Frame") then c.Visible = false end
			end
			for _, b in pairs(ScrollTabs:GetChildren()) do
				if b:IsA("TextButton") then
					b.BackgroundColor3 = C.TAB_INACT
					local lbl = b:FindFirstChildWhichIsA("TextLabel")
					if lbl then lbl.TextColor3 = C.MUTED end
					local ind = b:FindFirstChildOfClass("Frame")
					if ind then ind.BackgroundTransparency = 1 end
				end
			end
			tabFrame.Visible = true
			tabBtn.BackgroundColor3 = Color3.fromRGB(28, 24, 50)
			tabLabel.TextColor3 = C.TEXT
			tabIndicator.BackgroundTransparency = 0
		end)

		local function baseItem(height)
			local row = create("Frame", {
				Parent = tabScroll,
				Size = UDim2.new(1, 0, 0, height or 36),
				BackgroundColor3 = C.BTN,
				BorderSizePixel = 0,
			})
			corner(row, 7)
			applyStroke(row, C.BORDER, 1, 0.5)
			return row
		end

		local function rowLabel(parent, text, xOff, wOff)
			return create("TextLabel", {
				Parent = parent,
				Text = text,
				Size = UDim2.new(1, wOff or -16, 1, 0),
				Position = UDim2.new(0, xOff or 10, 0, 0),
				Font = Enum.Font.Gotham,
				TextColor3 = C.TEXT,
				TextSize = 13,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
		end

		local tabObj = {}

		-- ── AddButton ─────────────────────────────────────────────────────
		function tabObj:AddButton(name, callback)
			local btn = create("TextButton", {
				Parent = tabScroll,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = C.BTN,
				Text = "",
				BorderSizePixel = 0,
				AutoButtonColor = false,
			})
			corner(btn, 7)
			applyStroke(btn, C.BORDER, 1, 0.5)

			local stripe = create("Frame", {
				Parent = btn,
				Size = UDim2.new(0, 3, 0, 18),
				Position = UDim2.new(0, 8, 0.5, -9),
				BackgroundColor3 = C.ACCENT,
				BorderSizePixel = 0,
			})
			corner(stripe, 2)

			rowLabel(btn, name, 20, -24)

			btn.MouseEnter:Connect(function()
				tween(btn, { BackgroundColor3 = Color3.fromRGB(28, 26, 46) }, 0.1)
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, { BackgroundColor3 = C.BTN }, 0.1)
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)

			tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
			return btn
		end

		-- ── AddToggle ─────────────────────────────────────────────────────
		function tabObj:AddToggle(name, callback)
			local row = baseItem(36)
			rowLabel(row, name, 12, -60)

			local state = false

			local track = create("Frame", {
				Parent = row,
				Size = UDim2.new(0, 36, 0, 18),
				Position = UDim2.new(1, -46, 0.5, -9),
				BackgroundColor3 = C.BTN_TRACK,
				BorderSizePixel = 0,
			})
			corner(track, 9)
			applyStroke(track, C.BORDER, 1, 0.3)

			local thumb = create("Frame", {
				Parent = track,
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, 3, 0.5, -6),
				BackgroundColor3 = C.MUTED,
				BorderSizePixel = 0,
			})
			corner(thumb, 6)

			local clickArea = create("TextButton", {
				Parent = row,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
			})

			clickArea.MouseButton1Click:Connect(function()
				state = not state
				tween(track, { BackgroundColor3 = state and Color3.fromRGB(26, 50, 38) or C.BTN_TRACK }, 0.15)
				tween(thumb, {
					Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
					BackgroundColor3 = state and C.ACCENT2 or C.MUTED,
				}, 0.15)
				if callback then callback(state) end
			end)

			tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
		end

		-- ── AddSlider ─────────────────────────────────────────────────────
		function tabObj:AddSlider(name, min, max, default, callback)
			local sf = baseItem(52)

			local lbl = create("TextLabel", {
				Parent = sf,
				Text = name,
				Size = UDim2.new(1, -70, 0, 22),
				Position = UDim2.new(0, 12, 0, 4),
				Font = Enum.Font.Gotham,
				TextColor3 = C.TEXT,
				TextSize = 13,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local valLbl = create("TextLabel", {
				Parent = sf,
				Text = tostring(default),
				Size = UDim2.new(0, 50, 0, 22),
				Position = UDim2.new(1, -60, 0, 4),
				Font = Enum.Font.GothamSemibold,
				TextColor3 = C.ACCENT,
				TextSize = 13,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Right,
			})

			local track = create("Frame", {
				Parent = sf,
				Size = UDim2.new(1, -24, 0, 5),
				Position = UDim2.new(0, 12, 0, 34),
				BackgroundColor3 = C.BTN_TRACK,
				BorderSizePixel = 0,
			})
			corner(track, 3)

			local fill = create("Frame", {
				Parent = track,
				Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = C.ACCENT,
				BorderSizePixel = 0,
			})
			corner(fill, 3)

			local draggingSlider = false
			local function updateSlider(inputPosX)
				local mouseX = math.clamp(inputPosX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
				local ratio = mouseX / track.AbsoluteSize.X
				local value = min + ratio * (max - min)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				valLbl.Text = tostring(math.floor(value))
				if callback then callback(value) end
			end

			fill.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then draggingSlider = false end
					end)
				end
			end)
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					updateSlider(input.Position.X)
					draggingSlider = true
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then draggingSlider = false end
					end)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				) then
					updateSlider(input.Position.X)
				end
			end)

			tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
		end

		-- ── AddLabel ──────────────────────────────────────────────────────
		function tabObj:AddLabel(text)
			local lbl = create("TextLabel", {
				Parent = tabScroll,
				Text = text,
				Size = UDim2.new(1, 0, 0, 26),
				Font = Enum.Font.Gotham,
				TextColor3 = C.MUTED,
				TextSize = 12,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			pad(lbl, 12, 4, 0, 0)
			tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
		end

		-- ── AddDropdown ───────────────────────────────────────────────────
		function tabObj:AddDropdown(name, options, callback, choosemultiple)
			local container = create("Frame", {
				Parent = tabScroll,
				Size = UDim2.new(1, 0, 0, 110),
				BackgroundColor3 = C.BTN,
				BorderSizePixel = 0,
			})
			corner(container, 7)
			applyStroke(container, C.BORDER, 1, 0.5)

			local label = create("TextLabel", {
				Parent = container,
				Text = name,
				Size = UDim2.new(1, -12, 0, 22),
				Position = UDim2.new(0, 12, 0, 6),
				Font = Enum.Font.GothamSemibold,
				TextColor3 = C.TEXT,
				TextSize = 13,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local dropdown = create("TextButton", {
				Parent = container,
				Size = UDim2.new(1, -16, 0, 26),
				Position = UDim2.new(0, 8, 0, 30),
				Text = "Select...",
				Font = Enum.Font.Gotham,
				BackgroundColor3 = C.BTN_TRACK,
				TextColor3 = C.MUTED,
				TextSize = 12,
				BorderSizePixel = 0,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			corner(dropdown, 6)
			applyStroke(dropdown, C.BORDER, 1, 0.3)
			pad(dropdown, 10, 28, 0, 0)

			local chevron = create("TextLabel", {
				Parent = dropdown,
				Text = "▾",
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -22, 0, 0),
				Font = Enum.Font.GothamBold,
				TextColor3 = C.MUTED,
				TextSize = 12,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local submitBtn = create("TextButton", {
				Parent = container,
				Size = UDim2.new(1, -16, 0, 26),
				Position = UDim2.new(0, 8, 0, 76),
				Text = "OFF",
				Font = Enum.Font.GothamSemibold,
				BackgroundColor3 = Color3.fromRGB(30, 30, 44),
				TextColor3 = C.MUTED,
				TextSize = 12,
				BorderSizePixel = 0,
			})
			corner(submitBtn, 6)
			applyStroke(submitBtn, C.BORDER, 1, 0.3)

			local listOpen = false
			local selections = choosemultiple and {} or nil
			local isActive = false

			local optionsFrame = create("ScrollingFrame", {
				Parent = container,
				Size = UDim2.new(1, -16, 0, 100),
				Position = UDim2.new(0, 8, 0, 58),
				BackgroundColor3 = Color3.fromRGB(16, 16, 26),
				Visible = false,
				ZIndex = 10,
				CanvasSize = UDim2.new(0, 0, 0, #options * 26),
				ScrollBarThickness = 3,
				BorderSizePixel = 0,
			})
			corner(optionsFrame, 6)
			applyStroke(optionsFrame, C.BORDER, 1, 0.3)

			local listLayoutOpts = create("UIListLayout", {
				Parent = optionsFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			for _, opt in ipairs(options) do
				local btn = create("TextButton", {
					Parent = optionsFrame,
					Size = UDim2.new(1, 0, 0, 26),
					Text = opt,
					BackgroundColor3 = Color3.fromRGB(20, 20, 32),
					TextColor3 = C.TEXT,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					ZIndex = 10,
					BorderSizePixel = 0,
					AutoButtonColor = false,
				})
				btn.MouseEnter:Connect(function()
					if not (choosemultiple and table.find(selections, opt)) then
						btn.BackgroundColor3 = Color3.fromRGB(30, 28, 52)
					end
				end)
				btn.MouseLeave:Connect(function()
					if not (choosemultiple and table.find(selections, opt)) then
						btn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
					end
				end)
				btn.MouseButton1Click:Connect(function()
					if choosemultiple then
						if table.find(selections, opt) then
							for i, v in ipairs(selections) do
								if v == opt then table.remove(selections, i) break end
							end
							btn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
						else
							table.insert(selections, opt)
							btn.BackgroundColor3 = Color3.fromRGB(28, 24, 60)
						end
						dropdown.Text = (#selections > 0) and table.concat(selections, ", ") or "Select..."
						dropdown.TextColor3 = #selections > 0 and C.TEXT or C.MUTED
					else
						selections = opt
						dropdown.Text = opt
						dropdown.TextColor3 = C.TEXT
						optionsFrame.Visible = false
						listOpen = false
					end
				end)
			end

			dropdown.MouseButton1Click:Connect(function()
				listOpen = not listOpen
				optionsFrame.Visible = listOpen
			end)

			submitBtn.MouseButton1Click:Connect(function()
				isActive = not isActive
				if isActive then
					submitBtn.Text = "ON"
					tween(submitBtn, { BackgroundColor3 = Color3.fromRGB(14, 42, 28) }, 0.15)
					submitBtn.TextColor3 = C.ACCENT2
					local selectedItems = choosemultiple and selections or { selections }
					callback(selectedItems, true)
				else
					submitBtn.Text = "OFF"
					tween(submitBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 44) }, 0.15)
					submitBtn.TextColor3 = C.MUTED
					callback({}, false)
				end
			end)

			tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 120)
		end

		return tabObj
	end

	return selfObj
end

return DMZ
