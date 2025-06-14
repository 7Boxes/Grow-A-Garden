-- Fruit Mutation UI Editor
-- By DeepSeek Chat - Updated Version

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitMutationEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -50) -- Moved down 150 pixels (from -200 to -50)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Fruit Mutation Editor"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 16
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TopBar

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = CloseButton

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 5
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentFrame

-- Toggle visibility with key (e.g., F5)
local isVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F5 and not gameProcessed then
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    isVisible = false
    MainFrame.Visible = false
end)

-- Function to get just the name from the text object
local function getCurrentName(path)
    local success, target = pcall(function()
        return loadstring("return " .. path)()
    end)
    
    if success and target then
        return target.Text
    end
    return ""
end

-- Function to set just the name to the text object
local function setName(path, newName)
    pcall(function()
        local obj = loadstring("return " .. path)()
        if obj then
            obj.Text = newName
        end
    end)
end

-- Function to create property editors
local function createPropertyEditor(label, path, defaultColor)
    local Container = Instance.new("Frame")
    Container.Name = "PropertyContainer"
    Container.Size = UDim2.new(1, 0, 0, 70) -- Reduced height since we're simplifying
    Container.BackgroundTransparency = 1
    Container.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Text = label
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Parent = Container

    local TextBox = Instance.new("TextBox")
    TextBox.Name = "TextBox"
    TextBox.PlaceholderText = "Enter " .. label:lower() .. "..."
    TextBox.Size = UDim2.new(1, -70, 0, 30) -- Adjusted width for color button
    TextBox.Position = UDim2.new(0, 0, 0, 25)
    TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.Text = getCurrentName(path)
    TextBox.Parent = Container

    local ColorPicker = Instance.new("TextButton")
    ColorPicker.Name = "ColorPicker"
    ColorPicker.Text = "Color"
    ColorPicker.Size = UDim2.new(0, 60, 0, 30)
    ColorPicker.Position = UDim2.new(1, -60, 0, 25)
    ColorPicker.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
    ColorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
    ColorPicker.Font = Enum.Font.Gotham
    ColorPicker.TextSize = 12
    ColorPicker.Parent = Container

    -- Get current color
    local success, target = pcall(function()
        return loadstring("return " .. path)()
    end)
    
    if success and target then
        ColorPicker.BackgroundColor3 = target.TextColor3
    end

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = ColorPicker
    UICorner = UICorner:Clone()
    UICorner.Parent = TextBox

    -- Apply changes
    local function applyChanges()
        local newName = TextBox.Text
        local newColor = ColorPicker.BackgroundColor3
        
        -- Set the name
        setName(path, newName)
        
        -- Set the color
        pcall(function()
            local obj = loadstring("return " .. path)()
            if obj then
                obj.TextColor3 = newColor
            end
        end)
    end

    TextBox.FocusLost:Connect(applyChanges)
    
    ColorPicker.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("TextButton")
        colorPicker.Size = UDim2.new(0, 200, 0, 200)
        colorPicker.Position = UDim2.new(0.5, -100, 0.5, -100)
        colorPicker.BackgroundColor3 = ColorPicker.BackgroundColor3
        colorPicker.BorderSizePixel = 0
        colorPicker.ZIndex = 10
        colorPicker.Parent = ScreenGui
        
        local huePicker = Instance.new("ImageButton")
        huePicker.Size = UDim2.new(0, 180, 0, 180)
        huePicker.Position = UDim2.new(0, 10, 0, 10)
        huePicker.Image = "rbxassetid://2615689005"
        huePicker.ZIndex = 11
        huePicker.Parent = colorPicker
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = colorPicker
        
        local closeButton = Instance.new("TextButton")
        closeButton.Text = "Apply"
        closeButton.Size = UDim2.new(0, 60, 0, 25)
        closeButton.Position = UDim2.new(0.5, -30, 1, -30)
        closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.ZIndex = 11
        closeButton.Parent = colorPicker
        
        local function updateColor(input)
            local relativeX = (input.Position.X - huePicker.AbsolutePosition.X) / huePicker.AbsoluteSize.X
            local relativeY = (input.Position.Y - huePicker.AbsolutePosition.Y) / huePicker.AbsoluteSize.Y
            
            relativeX = math.clamp(relativeX, 0, 1)
            relativeY = math.clamp(relativeY, 0, 1)
            
            local hue = relativeX
            local saturation = 1
            local value = 1 - relativeY
            
            local color = Color3.fromHSV(hue, saturation, value)
            colorPicker.BackgroundColor3 = color
        end
        
        huePicker.MouseButton1Down:Connect(function(input)
            updateColor(input)
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateColor(input)
                end
            end)
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            ColorPicker.BackgroundColor3 = colorPicker.BackgroundColor3
            colorPicker:Destroy()
            applyChanges()
        end)
    end)

    return Container
end

-- Create editors for each property
createPropertyEditor("Fruit Name", 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitName', Color3.fromRGB(0xAA, 0xAA, 0xAA))
createPropertyEditor("Mutation 1", 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitMutation', Color3.fromRGB(0xFA, 0xAA, 0x00))
createPropertyEditor("Mutation 2", 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitMutation', Color3.fromRGB(0x87, 0xCE, 0xFA))

-- Make draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Reset on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    ScreenGui:Destroy()
    script:Clone().Parent = LocalPlayer.Backpack
end)
