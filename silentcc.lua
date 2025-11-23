--[[
    SKECH PREMIUM UI LIBRARY
    Author: AI (Refactored based on Compkiller/Fatality)
    Theme: Skech Red/Purple Gradient + Glow
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Open = true,
    Keybind = Enum.KeyCode.RightShift, -- Tecla padrão para abrir/fechar
    Accent = Color3.fromRGB(255, 45, 45), -- Vermelho Skech
    Accent2 = Color3.fromRGB(150, 20, 20), -- Vermelho Escuro (Gradiente)
    Outline = Color3.fromRGB(40, 40, 40),
    Background = Color3.fromRGB(14, 14, 14),
    SectionColor = Color3.fromRGB(20, 20, 20),
    TextColor = Color3.fromRGB(225, 225, 225),
    TextDark = Color3.fromRGB(140, 140, 140),
    Font = Enum.Font.GothamMedium,
    OpenedFrames = {},
    Flags = {}
}

local function Tween(obj, props, time)
    local T = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    T:Play()
    return T
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

-- Proteção de GUI
local function Protect(gui)
    if syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = CoreGui
    elseif gethui then gui.Parent = gethui()
    else gui.Parent = CoreGui end
end

-- Sistema de Arrastar
local function Drag(frame, parent)
    parent = parent or frame
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(parent, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

function Library:Window(Config)
    Library.Keybind = Config.Keybind or Enum.KeyCode.RightShift
    local WindowName = Config.Name or "SKECH"

    local ScreenGui = Create("ScreenGui", {Name = "SkechUI", ZIndexBehavior = Enum.ZIndexBehavior.Global})
    Protect(ScreenGui)

    -- Main Container com Glow e Gradiente
    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui,
        BackgroundColor3 = Library.Background,
        Position = UDim2.new(0.5, -350, 0.5, -250), Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = false
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})
    
    -- Borda com Gradiente (Estilo Premium)
    local Stroke = Create("UIStroke", {
        Parent = Main, Thickness = 2, Transparency = 0
    })
    local StrokeGrad = Create("UIGradient", {
        Parent = Stroke,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 120)) -- Roxo no final
        },
        Rotation = 45
    })

    -- Glow (Sombra brilhante)
    local Glow = Create("ImageLabel", {
        Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, -30, 0, -30), Size = UDim2.new(1, 60, 1, 60),
        ZIndex = -1, Image = "rbxassetid://5028857472",
        ImageColor3 = Library.Accent, ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276)
    })

    Drag(Main)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        Size = UDim2.new(0, 180, 1, 0)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    
    -- Correção visual da sidebar
    local SideCover = Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0, Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 10, 1, 0), ZIndex = 1
    })

    -- Logo Textual
    local Logo = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15), Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font.GothamBlack, Text = WindowName,
        TextColor3 = Library.Accent, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left
    })
    -- Sombra do logo para efeito de profundidade
    local LogoShadow = Create("TextLabel", {
        Parent = Logo, BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 2), Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack, Text = WindowName,
        TextColor3 = Color3.fromRGB(0,0,0), TextTransparency = 0.5, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = -1
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, 0, 1, -100),
        ScrollBarThickness = 0
    })
    local TabLayout = Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})

    -- Pages Container
    local Pages = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 190, 0, 20), Size = UDim2.new(1, -200, 1, -40)
    })

    -- Toggle UI Logic
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Library.Keybind then
            Library.Open = not Library.Open
            ScreenGui.Enabled = Library.Open
        end
    end)

    local Tabs = {}
    local FirstTab = true

    function Tabs:Tab(Config)
        local TabName = Config.Name
        local TabIcon = Config.Icon or ""
        
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35), Text = "", AutoButtonColor = false
        })

        local SelectedBar = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Library.Accent,
            Position = UDim2.new(0, 0, 0.2, 0), Size = UDim2.new(0, 3, 0.6, 0),
            Visible = false
        })

        local Title = Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 0), Size = UDim2.new(1, -50, 1, 0),
            Font = Library.Font, Text = TabName, TextColor3 = Library.TextDark,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })

        local Icon = Create("ImageLabel", {
            Parent = TabBtn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0.5, -10), Size = UDim2.new(0, 20, 0, 20),
            Image = TabIcon, ImageColor3 = Library.TextDark
        })

        local Page = Create("ScrollingFrame", {
            Parent = Pages, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, Visible = false
        })
        
        -- Colunas
        local LeftCol = Create("Frame", {
            Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(0.48, 0, 1, 0)
        })
        local LeftLayout = Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        
        local RightCol = Create("Frame", {
            Parent = Page, BackgroundTransparency = 1, Position = UDim2.new(0.52, 0, 0, 0), Size = UDim2.new(0.48, 0, 1, 0)
        })
        local RightLayout = Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})

        local function Select()
            for _, t in pairs(TabContainer:GetChildren()) do
                if t:IsA("TextButton") then
                    Tween(t.TextLabel, {TextColor3 = Library.TextDark})
                    Tween(t.ImageLabel, {ImageColor3 = Library.TextDark})
                    t.Frame.Visible = false
                    Tween(t, {BackgroundTransparency = 1})
                end
            end
            for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
            
            Page.Visible = true
            SelectedBar.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.95, BackgroundColor3 = Library.Accent})
            Tween(Title, {TextColor3 = Color3.new(1,1,1)})
            Tween(Icon, {ImageColor3 = Color3.new(1,1,1)})
        end

        TabBtn.MouseButton1Click:Connect(Select)
        if FirstTab then FirstTab = false Select() end

        local Sections = {}

        function Sections:Section(Config)
            local Side = Config.Side or "Left"
            local ParentFrame = (Side == "Left") and LeftCol or RightCol
            
            local SectionFrame = Create("Frame", {
                Parent = ParentFrame, BackgroundColor3 = Library.Section,
                Size = UDim2.new(1, 0, 0, 0), -- Auto resize
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SectionFrame})
            Create("UIStroke", {Color = Library.Outline, Thickness = 1, Parent = SectionFrame})

            local SecTitle = Create("TextLabel", {
                Parent = SectionFrame, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8), Size = UDim2.new(1, -20, 0, 15),
                Font = Enum.Font.GothamBold, Text = Config.Name:upper(),
                TextColor3 = Library.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
            })

            local Content = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 0)
            })
            local ContentLayout = Create("UIListLayout", {Parent = Content, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
            Create("UIPadding", {Parent = Content, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Content.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 40)
            end)

            local Elements = {}

            -- === OPTION SYSTEM ===
            local function CreateOptions(ParentButton)
                local OptionFrame = Create("Frame", {
                    Parent = ScreenGui, Name = "Options", BackgroundColor3 = Library.Section,
                    Size = UDim2.new(0, 180, 0, 0), Visible = false, ZIndex = 100
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionFrame})
                Create("UIStroke", {Color = Library.Outline, Thickness = 1, Parent = OptionFrame})
                
                local OptList = Create("UIListLayout", {Parent = OptionFrame, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
                Create("UIPadding", {Parent = OptionFrame, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})

                OptList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionFrame.Size = UDim2.new(0, 180, 0, OptList.AbsoluteContentSize.Y + 16)
                end)

                -- Mostra o menu de opções ao lado do elemento
                ParentButton.MouseButton2Click:Connect(function()
                    for _, v in pairs(ScreenGui:GetChildren()) do if v.Name == "Options" then v.Visible = false end end -- fecha outros
                    OptionFrame.Position = UDim2.new(0, Mouse.X + 5, 0, Mouse.Y + 5)
                    OptionFrame.Visible = true
                end)
                
                -- Fecha ao clicar fora
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not OptionFrame.Visible then return end
                        local mPos = UserInputService:GetMouseLocation()
                        local fPos = OptionFrame.AbsolutePosition
                        local fSize = OptionFrame.AbsoluteSize
                        if mPos.X < fPos.X or mPos.X > fPos.X + fSize.X or mPos.Y < fPos.Y or mPos.Y > fPos.Y + fSize.Y then
                            OptionFrame.Visible = false
                        end
                    end
                end)

                return OptionFrame
            end

            function Elements:Toggle(Config)
                local ToggleFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)
                })
                local Btn = Create("TextButton", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    Text = "", AutoButtonColor = false
                })
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Library.Font, Text = Config.Name, TextColor3 = Library.TextColor,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Check = Create("Frame", {
                    Parent = ToggleFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Position = UDim2.new(1, -40, 0.5, -8), Size = UDim2.new(0, 36, 0, 16)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Check})
                local Circle = Create("Frame", {
                    Parent = Check, BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                    Position = UDim2.new(0, 2, 0.5, -6), Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local Toggled = Config.Default or false
                local OptionMenu = CreateOptions(Btn) -- Botão direito abre opções

                local function Update()
                    if Toggled then
                        Tween(Check, {BackgroundColor3 = Library.Accent})
                        Tween(Circle, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)})
                        Tween(Label, {TextColor3 = Color3.new(1,1,1)})
                    else
                        Tween(Check, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                        Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
                        Tween(Label, {TextColor3 = Library.TextColor})
                    end
                    if Config.Callback then Config.Callback(Toggled) end
                    Library.Flags[Config.Flag or Config.Name] = Toggled
                end

                Btn.MouseButton1Click:Connect(function() Toggled = not Toggled Update() end)
                if Toggled then Update() end

                -- Retorna funções para adicionar na Option
                local OptFuncs = {}
                function OptFuncs:ColorPicker(CConfig)
                    local ColorFrame = Create("Frame", {Parent = OptionMenu, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20)})
                    Create("TextLabel", {Parent = ColorFrame, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0), Text = CConfig.Name, Font = Library.Font, TextSize = 11, TextColor3 = Library.TextColor, TextXAlignment = Enum.TextXAlignment.Left})
                    local Prev = Create("TextButton", {Parent = ColorFrame, BackgroundColor3 = CConfig.Default, Position = UDim2.new(1, -30, 0, 2), Size = UDim2.new(0, 30, 0, 16), Text = "", AutoButtonColor = false})
                    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Prev})
                    -- (Logica simplificada de color picker)
                end
                return OptFuncs
            end

            function Elements:Slider(Config)
                local SliderFrame = Create("Frame", {
                    Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)
                })
                local Label = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Library.Font, Text = Config.Name, TextColor3 = Library.TextColor,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15),
                    Font = Library.Font, Text = tostring(Config.Default), TextColor3 = Library.TextDark,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
                })
                local BG = Create("TextButton", {
                    Parent = SliderFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 6), Text = "", AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BG})
                local Fill = Create("Frame", {
                    Parent = BG, BackgroundColor3 = Library.Accent, Size = UDim2.new(0, 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

                local Min, Max = Config.Min, Config.Max
                local Def = Config.Default or Min
                
                local function Set(val)
                    val = math.clamp(val, Min, Max)
                    local perc = (val - Min) / (Max - Min)
                    Fill.Size = UDim2.new(perc, 0, 1, 0)
                    ValueLabel.Text = tostring(math.floor(val))
                    if Config.Callback then Config.Callback(val) end
                end

                local Dragging = false
                BG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local s = math.clamp((i.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
                        Set(Min + (Max - Min) * s)
                    end
                end)
                Set(Def)
            end

            function Elements:Dropdown(Config)
                local DropFrame = Create("Frame", {Parent = Content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), ZIndex = 2})
                Create("TextLabel", {Parent = DropFrame, BackgroundTransparency = 1, Text = Config.Name, Font = Library.Font, TextSize = 12, TextColor3 = Library.TextColor, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left})
                
                local MainBtn = Create("TextButton", {
                    Parent = DropFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, 0, 0, 24),
                    Text = "   " .. (Config.Multi and "Select..." or (Config.Default or "...")),
                    Font = Library.Font, TextSize = 11, TextColor3 = Library.TextDark, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = MainBtn})
                Create("UIStroke", {Color = Library.Outline, Thickness = 1, Parent = MainBtn})

                local Holder = Create("Frame", {
                    Parent = DropFrame, BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                    Position = UDim2.new(0, 0, 1, 2), Size = UDim2.new(1, 0, 0, 0),
                    Visible = false, ZIndex = 10
                })
                Create("UIStroke", {Color = Library.Outline, Thickness = 1, Parent = Holder})
                local List = Create("UIListLayout", {Parent = Holder, SortOrder = Enum.SortOrder.LayoutOrder})

                local Open = false
                local Selected = Config.Multi and {} or Config.Default

                MainBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Holder.Visible = Open
                    local h = #Config.Options * 24
                    Holder.Size = UDim2.new(1, 0, 0, h)
                    DropFrame.ZIndex = Open and 10 or 2
                end)

                for _, opt in pairs(Config.Options) do
                    local OptBtn = Create("TextButton", {
                        Parent = Holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
                        Text = "  " .. opt, Font = Library.Font, TextSize = 11, TextColor3 = Library.TextDark, TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if Config.Multi then
                            if table.find(Selected, opt) then
                                for i,v in pairs(Selected) do if v == opt then table.remove(Selected, i) end end
                                OptBtn.TextColor3 = Library.TextDark
                            else
                                table.insert(Selected, opt)
                                OptBtn.TextColor3 = Library.Accent
                            end
                            MainBtn.Text = "   " .. table.concat(Selected, ", ")
                        else
                            Selected = opt
                            MainBtn.Text = "   " .. opt
                            Holder.Visible = false
                            Open = false
                            DropFrame.ZIndex = 2
                        end
                        if Config.Callback then Config.Callback(Selected) end
                    end)
                end
            end
            
            return Elements
        end
        return Sections
    end
    
    return Tabs
end

function Library:Watermark(Config)
    local ScreenGui = Create("ScreenGui", {Name = "Watermark", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Protect(ScreenGui)
    
    local Frame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.85, 0, 0.05, 0), Size = UDim2.new(0, 0, 0, 26)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Frame})
    Create("UIStroke", {Color = Library.Accent, Thickness = 1, Parent = Frame})
    
    local Text = Create("TextLabel", {
        Parent = Frame, BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.GothamBold, Text = Config.Text,
        TextColor3 = Color3.new(1,1,1), TextSize = 12, AutomaticSize = Enum.AutomaticSize.X
    })
    
    RunService.RenderStepped:Connect(function()
        Frame.Size = UDim2.new(0, Text.AbsoluteSize.X + 20, 0, 26)
    end)
    
    return {
        SetText = function(self, str) Text.Text = str end
    }
end

return Library
