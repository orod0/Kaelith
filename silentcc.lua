local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- // Configurações Visuais (Tema)
local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Sidebar = Color3.fromRGB(15, 15, 20),
	ElementBackground = Color3.fromRGB(30, 30, 35),
	TextColor = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(65, 105, 225), -- Azul Royal (pode mudar para vermelho/roxo)
	ToggleOn = Color3.fromRGB(65, 225, 100),
	ToggleOff = Color3.fromRGB(50, 50, 50),
	CornerRadius = UDim.new(0, 6)
}

-- // Utilitários
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(object, TweenInfo.new(0.15), {Position = pos})
		Tween:Play()
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

local function CreateTween(obj, props, time)
	local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

-- // Função Principal: Criar Janela
function Library:CreateWindow(Config)
	local Title = Config.Title or "UI Library"
	local MinimizeKey = Config.Key or Enum.KeyCode.RightShift
	local AccentColor = Config.Accent or Theme.Accent
	Theme.Accent = AccentColor

	local ScreenGui = Instance.new("ScreenGui")
	
	-- Proteção contra detecção simples (se usar executor)
	if syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	elseif gethui then
		ScreenGui.Parent = gethui()
	else
		ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	end

	local MainFrame = Instance.new("Frame")
	local MainCorner = Instance.new("UICorner")
	local MainStroke = Instance.new("UIStroke")
	local Sidebar = Instance.new("Frame")
	local SidebarCorner = Instance.new("UICorner")
	local ContentArea = Instance.new("Frame")
	local TitleLabel = Instance.new("TextLabel")
	local TabContainer = Instance.new("ScrollingFrame")
	local TabListLayout = Instance.new("UIListLayout")
	local TabPadding = Instance.new("UIPadding")

	-- Configuração MainFrame
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
	MainFrame.Size = UDim2.new(0, 600, 0, 400)
	MainFrame.ClipsDescendants = true
	MakeDraggable(MainFrame, MainFrame)

	MainCorner.CornerRadius = Theme.CornerRadius
	MainCorner.Parent = MainFrame
	
	MainStroke.Color = Theme.ElementBackground
	MainStroke.Thickness = 1
	MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MainStroke.Parent = MainFrame

	-- Título
	TitleLabel.Name = "Title"
	TitleLabel.Parent = MainFrame
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 20, 0, 15)
	TitleLabel.Size = UDim2.new(0, 150, 0, 30)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Theme.Accent
	TitleLabel.TextSize = 22
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Sidebar (Barra lateral de abas)
	Sidebar.Name = "Sidebar"
	Sidebar.Parent = MainFrame
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.Position = UDim2.new(0, 0, 0, 60)
	Sidebar.Size = UDim2.new(0, 160, 1, -60)
	Sidebar.BorderSizePixel = 0

	SidebarCorner.CornerRadius = UDim.new(0, 0) -- Quadrado para encaixar
	SidebarCorner.Parent = Sidebar

	TabContainer.Name = "TabContainer"
	TabContainer.Parent = Sidebar
	TabContainer.BackgroundTransparency = 1
	TabContainer.Size = UDim2.new(1, 0, 1, 0)
	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = Theme.Accent

	TabListLayout.Parent = TabContainer
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 5)

	TabPadding.Parent = TabContainer
	TabPadding.PaddingTop = UDim.new(0, 10)
	TabPadding.PaddingLeft = UDim.new(0, 10)

	-- Content Area (Onde ficam os elementos)
	ContentArea.Name = "ContentArea"
	ContentArea.Parent = MainFrame
	ContentArea.BackgroundTransparency = 1
	ContentArea.Position = UDim2.new(0, 170, 0, 60)
	ContentArea.Size = UDim2.new(1, -180, 1, -70)

	-- Lógica de Minimizar
	local Toggled = true
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == MinimizeKey then
			Toggled = not Toggled
			if Toggled then
				MainFrame.ClipsDescendants = true
				CreateTween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5)
			else
				CreateTween(MainFrame, {Size = UDim2.new(0, 600, 0, 0)}, 0.5)
			end
		end
	end)

	local Window = {}
	local FirstTab = true

	function Window:CreateTab(TabName, TabIcon)
		local TabButton = Instance.new("TextButton")
		local TabCorner = Instance.new("UICorner")
		local TabTitle = Instance.new("TextLabel")
		local TabIndicator = Instance.new("Frame") -- Linha lateral selecionada

		local Page = Instance.new("ScrollingFrame")
		local PageLayout = Instance.new("UIListLayout")
		local PagePadding = Instance.new("UIPadding")

		-- Configuração do Botão da Aba
		TabButton.Name = TabName .. "_Btn"
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Theme.Background
		TabButton.BackgroundTransparency = 1
		TabButton.Size = UDim2.new(0, 140, 0, 35)
		TabButton.AutoButtonColor = false
		TabButton.Text = ""

		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabButton

		TabTitle.Parent = TabButton
		TabTitle.BackgroundTransparency = 1
		TabTitle.Position = UDim2.new(0, 15, 0, 0)
		TabTitle.Size = UDim2.new(1, -15, 1, 0)
		TabTitle.Font = Enum.Font.GothamMedium
		TabTitle.Text = TabName
		TabTitle.TextColor3 = Theme.TextDim
		TabTitle.TextSize = 14
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left

		TabIndicator.Parent = TabButton
		TabIndicator.BackgroundColor3 = Theme.Accent
		TabIndicator.Size = UDim2.new(0, 3, 0, 20)
		TabIndicator.Position = UDim2.new(0, 0, 0.5, -10)
		TabIndicator.BackgroundTransparency = 1 -- Invisível por padrão
		
		local IndicatorCorner = Instance.new("UICorner")
		IndicatorCorner.CornerRadius = UDim.new(0, 4)
		IndicatorCorner.Parent = TabIndicator

		-- Configuração da Página (Conteúdo)
		Page.Name = TabName .. "_Page"
		Page.Parent = ContentArea
		Page.BackgroundTransparency = 1
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Visible = false
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.ElementBackground

		PageLayout.Parent = Page
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 8)

		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 5)
		PagePadding.PaddingLeft = UDim.new(0, 5)
		PagePadding.PaddingRight = UDim.new(0, 5)
		PagePadding.PaddingBottom = UDim.new(0, 5)

		-- Lógica de Seleção
		local function UpdateTab()
			-- Reseta todas as abas
			for _, child in ipairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					CreateTween(child.TextLabel, {TextColor3 = Theme.TextDim}, 0.2)
					CreateTween(child.Frame, {BackgroundTransparency = 1}, 0.2)
					CreateTween(child, {BackgroundTransparency = 1}, 0.2)
				end
			end
			for _, child in ipairs(ContentArea:GetChildren()) do
				if child:IsA("ScrollingFrame") then
					child.Visible = false
				end
			end

			-- Ativa a atual
			CreateTween(TabTitle, {TextColor3 = Theme.TextColor}, 0.2)
			CreateTween(TabIndicator, {BackgroundTransparency = 0}, 0.2)
			CreateTween(TabButton, {BackgroundTransparency = 0.95, BackgroundColor3 = Theme.Accent}, 0.2)
			Page.Visible = true
		end

		TabButton.MouseButton1Click:Connect(UpdateTab)

		-- Selecionar a primeira aba automaticamente
		if FirstTab then
			FirstTab = false
			UpdateTab()
		end

		-- // Funções de Elementos dentro da Aba
		local Elements = {}

		function Elements:CreateLabel(Text)
			local Label = Instance.new("TextLabel")
			Label.Name = "Label"
			Label.Parent = Page
			Label.BackgroundColor3 = Theme.ElementBackground
			Label.BackgroundTransparency = 1
			Label.Size = UDim2.new(1, 0, 0, 25)
			Label.Font = Enum.Font.Gotham
			Label.Text = Text
			Label.TextColor3 = Theme.TextColor
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			
			local Padding = Instance.new("UIPadding")
			Padding.Parent = Label
			Padding.PaddingLeft = UDim.new(0, 5)
		end

		function Elements:CreateButton(Text, Callback)
			Callback = Callback or function() end
			
			local ButtonFrame = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local ButtonStroke = Instance.new("UIStroke")

			ButtonFrame.Name = "Button"
			ButtonFrame.Parent = Page
			ButtonFrame.BackgroundColor3 = Theme.ElementBackground
			ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
			ButtonFrame.Font = Enum.Font.GothamSemibold
			ButtonFrame.Text = Text
			ButtonFrame.TextColor3 = Theme.TextColor
			ButtonFrame.TextSize = 14
			ButtonFrame.AutoButtonColor = false

			ButtonCorner.CornerRadius = Theme.CornerRadius
			ButtonCorner.Parent = ButtonFrame
			
			ButtonStroke.Parent = ButtonFrame
			ButtonStroke.Thickness = 1
			ButtonStroke.Color = Theme.Background
			ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			ButtonFrame.MouseEnter:Connect(function()
				CreateTween(ButtonFrame, {BackgroundColor3 = Color3.new(Theme.ElementBackground.R + 0.1, Theme.ElementBackground.G + 0.1, Theme.ElementBackground.B + 0.1)})
			end)

			ButtonFrame.MouseLeave:Connect(function()
				CreateTween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackground})
			end)

			ButtonFrame.MouseButton1Click:Connect(function()
				-- Efeito de clique
				CreateTween(ButtonFrame, {TextSize = 12}, 0.05)
				wait(0.05)
				CreateTween(ButtonFrame, {TextSize = 14}, 0.05)
				Callback()
			end)
		end

		function Elements:CreateToggle(Text, Default, Callback)
			Callback = Callback or function() end
			local Toggled = Default or false

			local ToggleFrame = Instance.new("TextButton")
			local ToggleCorner = Instance.new("UICorner")
			local ToggleLabel = Instance.new("TextLabel")
			local ToggleSwitch = Instance.new("Frame")
			local SwitchCorner = Instance.new("UICorner")
			local SwitchCircle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")

			ToggleFrame.Name = "Toggle"
			ToggleFrame.Parent = Page
			ToggleFrame.BackgroundColor3 = Theme.ElementBackground
			ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
			ToggleFrame.AutoButtonColor = false
			ToggleFrame.Text = ""

			ToggleCorner.CornerRadius = Theme.CornerRadius
			ToggleCorner.Parent = ToggleFrame

			ToggleLabel.Parent = ToggleFrame
			ToggleLabel.BackgroundTransparency = 1
			ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
			ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
			ToggleLabel.Font = Enum.Font.GothamSemibold
			ToggleLabel.Text = Text
			ToggleLabel.TextColor3 = Theme.TextColor
			ToggleLabel.TextSize = 14
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

			ToggleSwitch.Name = "Switch"
			ToggleSwitch.Parent = ToggleFrame
			ToggleSwitch.AnchorPoint = Vector2.new(1, 0.5)
			ToggleSwitch.BackgroundColor3 = Toggled and Theme.ToggleOn or Theme.ToggleOff
			ToggleSwitch.Position = UDim2.new(1, -10, 0.5, 0)
			ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)

			SwitchCorner.CornerRadius = UDim.new(1, 0)
			SwitchCorner.Parent = ToggleSwitch

			SwitchCircle.Name = "Circle"
			SwitchCircle.Parent = ToggleSwitch
			SwitchCircle.AnchorPoint = Vector2.new(0, 0.5)
			SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SwitchCircle.Position = Toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			SwitchCircle.Size = UDim2.new(0, 16, 0, 16)

			CircleCorner.CornerRadius = UDim.new(1, 0)
			CircleCorner.Parent = SwitchCircle

			local function UpdateToggle()
				Toggled = not Toggled
				local targetColor = Toggled and Theme.ToggleOn or Theme.ToggleOff
				local targetPos = Toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)

				CreateTween(ToggleSwitch, {BackgroundColor3 = targetColor}, 0.2)
				CreateTween(SwitchCircle, {Position = targetPos}, 0.2)
				Callback(Toggled)
			end

			ToggleFrame.MouseButton1Click:Connect(UpdateToggle)
		end

		function Elements:CreateSlider(Text, Min, Max, Default, Callback)
			Callback = Callback or function() end
			local Value = Default or Min
			local Dragging = false

			local SliderFrame = Instance.new("Frame")
			local SliderCorner = Instance.new("UICorner")
			local SliderLabel = Instance.new("TextLabel")
			local ValueLabel = Instance.new("TextLabel")
			local SliderBar = Instance.new("Frame")
			local BarCorner = Instance.new("UICorner")
			local SliderFill = Instance.new("Frame")
			local FillCorner = Instance.new("UICorner")
			local SliderKnob = Instance.new("Frame") -- Detalhe visual
			local KnobCorner = Instance.new("UICorner")
			local ClickButton = Instance.new("TextButton")

			SliderFrame.Name = "Slider"
			SliderFrame.Parent = Page
			SliderFrame.BackgroundColor3 = Theme.ElementBackground
			SliderFrame.Size = UDim2.new(1, 0, 0, 50)

			SliderCorner.CornerRadius = Theme.CornerRadius
			SliderCorner.Parent = SliderFrame

			SliderLabel.Parent = SliderFrame
			SliderLabel.BackgroundTransparency = 1
			SliderLabel.Position = UDim2.new(0, 10, 0, 5)
			SliderLabel.Size = UDim2.new(1, -20, 0, 20)
			SliderLabel.Font = Enum.Font.GothamSemibold
			SliderLabel.Text = Text
			SliderLabel.TextColor3 = Theme.TextColor
			SliderLabel.TextSize = 14
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

			ValueLabel.Parent = SliderFrame
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Position = UDim2.new(0, 10, 0, 5)
			ValueLabel.Size = UDim2.new(1, -20, 0, 20)
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.Text = tostring(Value)
			ValueLabel.TextColor3 = Theme.TextDim
			ValueLabel.TextSize = 14
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

			SliderBar.Parent = SliderFrame
			SliderBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			SliderBar.Position = UDim2.new(0, 10, 0, 30)
			SliderBar.Size = UDim2.new(1, -20, 0, 6)

			BarCorner.CornerRadius = UDim.new(1, 0)
			BarCorner.Parent = SliderBar

			SliderFill.Parent = SliderBar
			SliderFill.BackgroundColor3 = Theme.Accent
			SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)

			FillCorner.CornerRadius = UDim.new(1, 0)
			FillCorner.Parent = SliderFill
			
			-- Bolinha na ponta do slider
			SliderKnob.Parent = SliderFill
			SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
			SliderKnob.Position = UDim2.new(1, 0, 0.5, 0)
			SliderKnob.Size = UDim2.new(0, 12, 0, 12)
			
			KnobCorner.CornerRadius = UDim.new(1, 0)
			KnobCorner.Parent = SliderKnob

			ClickButton.Parent = SliderBar
			ClickButton.BackgroundTransparency = 1
			ClickButton.Size = UDim2.new(1, 0, 1, 0)
			ClickButton.Text = ""

			local function UpdateSlider(input)
				local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local NewValue = math.floor(Min + ((Max - Min) * SizeX))
				
				CreateTween(SliderFill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.1)
				ValueLabel.Text = tostring(NewValue)
				Callback(NewValue)
			end

			ClickButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					CreateTween(SliderKnob, {Size = UDim2.new(0, 16, 0, 16)}, 0.1) -- Animação ao clicar
					UpdateSlider(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
					CreateTween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
		end

		function Elements:CreateDropdown(Text, Options, Callback)
			Callback = Callback or function() end
			local DropdownOpen = false

			local DropdownFrame = Instance.new("Frame")
			local DropdownCorner = Instance.new("UICorner")
			local DropdownBtn = Instance.new("TextButton")
			local DropdownLabel = Instance.new("TextLabel")
			local DropdownArrow = Instance.new("ImageLabel")
			local DropdownList = Instance.new("ScrollingFrame")
			local ListLayout = Instance.new("UIListLayout")
			local ListPadding = Instance.new("UIPadding")

			DropdownFrame.Name = "Dropdown"
			DropdownFrame.Parent = Page
			DropdownFrame.BackgroundColor3 = Theme.ElementBackground
			DropdownFrame.Size = UDim2.new(1, 0, 0, 35) -- Altura fechada
			DropdownFrame.ClipsDescendants = true

			DropdownCorner.CornerRadius = Theme.CornerRadius
			DropdownCorner.Parent = DropdownFrame

			DropdownBtn.Parent = DropdownFrame
			DropdownBtn.BackgroundTransparency = 1
			DropdownBtn.Size = UDim2.new(1, 0, 0, 35)
			DropdownBtn.Text = ""

			DropdownLabel.Parent = DropdownBtn
			DropdownLabel.BackgroundTransparency = 1
			DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
			DropdownLabel.Size = UDim2.new(1, -40, 1, 0)
			DropdownLabel.Font = Enum.Font.GothamSemibold
			DropdownLabel.Text = Text .. ": ..."
			DropdownLabel.TextColor3 = Theme.TextColor
			DropdownLabel.TextSize = 14
			DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

			DropdownArrow.Parent = DropdownBtn
			DropdownArrow.BackgroundTransparency = 1
			DropdownArrow.Position = UDim2.new(1, -30, 0.5, -10)
			DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
			DropdownArrow.Image = "rbxassetid://6031091004" -- Seta genérica
			DropdownArrow.ImageColor3 = Theme.TextDim

			DropdownList.Parent = DropdownFrame
			DropdownList.BackgroundTransparency = 1
			DropdownList.Position = UDim2.new(0, 0, 0, 40)
			DropdownList.Size = UDim2.new(1, 0, 0, 100)
			DropdownList.ScrollBarThickness = 2
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)

			ListLayout.Parent = DropdownList
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)

			ListPadding.Parent = DropdownList
			ListPadding.PaddingLeft = UDim.new(0, 10)

			local function RefreshList()
				for _, v in pairs(DropdownList:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end

				for _, option in ipairs(Options) do
					local OptionBtn = Instance.new("TextButton")
					OptionBtn.Parent = DropdownList
					OptionBtn.BackgroundColor3 = Theme.Background
					OptionBtn.BackgroundTransparency = 0.5
					OptionBtn.Size = UDim2.new(1, -10, 0, 25)
					OptionBtn.Font = Enum.Font.Gotham
					OptionBtn.Text = option
					OptionBtn.TextColor3 = Theme.TextColor
					OptionBtn.TextSize = 13
					
					local OptCorner = Instance.new("UICorner")
					OptCorner.CornerRadius = UDim.new(0, 4)
					OptCorner.Parent = OptionBtn

					OptionBtn.MouseButton1Click:Connect(function()
						DropdownLabel.Text = Text .. ": " .. option
						DropdownOpen = false
						CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
						CreateTween(DropdownArrow, {Rotation = 0}, 0.3)
						Callback(option)
					end)
				end
				
				DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
			end

			RefreshList()

			DropdownBtn.MouseButton1Click:Connect(function()
				DropdownOpen = not DropdownOpen
				if DropdownOpen then
					CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 145)}, 0.3)
					CreateTween(DropdownArrow, {Rotation = 180}, 0.3)
				else
					CreateTween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
					CreateTween(DropdownArrow, {Rotation = 0}, 0.3)
				end
			end)
		end

		return Elements
	end

	return Window
end

return Library
