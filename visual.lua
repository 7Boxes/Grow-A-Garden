local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitMutationEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -50)
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
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 5
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentFrame

local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Size = UDim2.new(1, -20, 0, 30)
ButtonFrame.Position = UDim2.new(0, 10, 1, -40)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = MainFrame

local RefreshButton = Instance.new("TextButton")
RefreshButton.Name = "RefreshButton"
RefreshButton.Text = "Refresh"
RefreshButton.Size = UDim2.new(0.5, -5, 1, 0)
RefreshButton.Position = UDim2.new(0, 0, 0, 0)
RefreshButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextSize = 14
RefreshButton.Parent = ButtonFrame

local SaveButton = Instance.new("TextButton")
SaveButton.Name = "SaveButton"
SaveButton.Text = "Save"
SaveButton.Size = UDim2.new(0.5, -5, 1, 0)
SaveButton.Position = UDim2.new(0.5, 5, 0, 0)
SaveButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.Gotham
SaveButton.TextSize = 14
SaveButton.Parent = ButtonFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = RefreshButton
local UICorner3 = UICorner2:Clone()
UICorner3.Parent = SaveButton

local isVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F5 and not gameProcessed then
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    isVisible = false
    MainFrame.Visible = false
end)

local function getFruitData()
    local fruitPath = 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitName'
    local mutationPath = 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitMutation'
    
    local fruitData = {}
    local mutationData = {}
    
    local success, fruitObj = pcall(function()
        return loadstring("return " .. fruitPath)()
    end)
    
    if success and fruitObj then
        fruitData.text = fruitObj.Text
        fruitData.color = fruitObj.TextColor3
    end
    
    local index = 1
    while true do
        local success, mutationObj = pcall(function()
            return loadstring("return " .. mutationPath .. ":FindFirstChild('Mutation" .. index .. "')")()
        end)
        
        if not success or not mutationObj then break end
        
        table.insert(mutationData, {
            text = mutationObj.Text,
            color = mutationObj.TextColor3
        })
        index = index + 1
    end
    
    return fruitData, mutationData
end

local function createPropertyEditor(label, index)
    local Container = Instance.new("Frame")
    Container.Name = "PropertyContainer"
    Container.Size = UDim2.new(1, 0, 0, 70)
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
    TextBox.Size = UDim2.new(0.7, -10, 0, 30)
    TextBox.Position = UDim2.new(0, 0, 0, 25)
    TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.Parent = Container

    local HexBox = Instance.new("TextBox")
    HexBox.Name = "HexBox"
    HexBox.PlaceholderText = "Hex Color"
    HexBox.Size = UDim2.new(0.3, -10, 0, 30)
    HexBox.Position = UDim2.new(0.7, 10, 0, 25)
    HexBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    HexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    HexBox.Font = Enum.Font.Gotham
    HexBox.TextSize = 14
    HexBox.Parent = Container

    local ColorPreview = Instance.new("Frame")
    ColorPreview.Name = "ColorPreview"
    ColorPreview.Size = UDim2.new(0, 20, 0, 20)
    ColorPreview.Position = UDim2.new(0.7, -25, 0, 30)
    ColorPreview.BorderSizePixel = 0
    ColorPreview.Parent = Container

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = TextBox
    UICorner:Clone().Parent = HexBox
    UICorner:Clone().Parent = ColorPreview

    return Container, TextBox, HexBox, ColorPreview, index
end

local fruitEditor, fruitTextBox, fruitHexBox, fruitColorPreview = createPropertyEditor("Fruit Name")
local mutationEditors = {}

local function updateUI()
    ContentFrame:ClearAllChildren()
    mutationEditors = {}
    
    local fruitData, mutationData = getFruitData()
    
    fruitEditor.Parent = ContentFrame
    if fruitData.text then
        fruitTextBox.Text = fruitData.text
        local hex = string.format("#%02X%02X%02X", math.floor(fruitData.color.r * 255), math.floor(fruitData.color.g * 255), math.floor(fruitData.color.b * 255))
        fruitHexBox.Text = hex
        fruitColorPreview.BackgroundColor3 = fruitData.color
    end
    
    for i, mutation in ipairs(mutationData) do
        local editor, textBox, hexBox, colorPreview = createPropertyEditor("Mutation " .. i, i)
        editor.Parent = ContentFrame
        textBox.Text = mutation.text
        local hex = string.format("#%02X%02X%02X", math.floor(mutation.color.r * 255), math.floor(mutation.color.g * 255), math.floor(mutation.color.b * 255))
        hexBox.Text = hex
        colorPreview.BackgroundColor3 = mutation.color
        
        table.insert(mutationEditors, {
            editor = editor,
            textBox = textBox,
            hexBox = hexBox,
            colorPreview = colorPreview,
            index = i
        })
    end
end

local function saveChanges()
    local fruitPath = 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitName'
    local mutationPath = 'game:GetService("Players").LocalPlayer.PlayerGui.FruitMutation_UI.Frame.FruitMutation'
    
    local function parseHex(hex)
        hex = hex:gsub("#", "")
        if #hex == 3 then
            return Color3.fromRGB(
                tonumber(hex:sub(1,1), 1) * 17,
                tonumber(hex:sub(2,2), 1) * 17,
                tonumber(hex:sub(3,3), 1) * 17
            )
        elseif #hex == 6 then
            return Color3.fromRGB(
                tonumber(hex:sub(1,2), 16),
                tonumber(hex:sub(3,4), 16),
                tonumber(hex:sub(5,6), 16)
            )
        end
        return Color3.new(1, 1, 1)
    end
    
    pcall(function()
        local fruitObj = loadstring("return " .. fruitPath)()
        if fruitObj then
            fruitObj.Text = fruitTextBox.Text
            fruitObj.TextColor3 = parseHex(fruitHexBox.Text)
        end
    end)
    
    for _, editor in ipairs(mutationEditors) do
        pcall(function()
            local mutationObj = loadstring("return " .. mutationPath .. ":FindFirstChild('Mutation" .. editor.index .. "')")()
            if mutationObj then
                mutationObj.Text = editor.textBox.Text
                mutationObj.TextColor3 = parseHex(editor.hexBox.Text)
            end
        end)
    end
end

local saveConnection
SaveButton.MouseButton1Click:Connect(function()
    if saveConnection then
        saveConnection:Disconnect()
        saveConnection = nil
        SaveButton.Text = "Save"
    else
        SaveButton.Text = "Saving..."
        saveConnection = RunService.Heartbeat:Connect(function()
            saveChanges()
        end)
    end
end)

RefreshButton.MouseButton1Click:Connect(updateUI)

fruitHexBox:GetPropertyChangedSignal("Text"):Connect(function()
    local hex = fruitHexBox.Text
    if hex:match("^#?[0-9a-fA-F]+$") then
        fruitColorPreview.BackgroundColor3 = Color3.fromHex(hex)
    end
end)

for _, editor in ipairs(mutationEditors) do
    editor.hexBox:GetPropertyChangedSignal("Text"):Connect(function()
        local hex = editor.hexBox.Text
        if hex:match("^#?[0-9a-fA-F]+$") then
            editor.colorPreview.BackgroundColor3 = Color3.fromHex(hex)
        end
    end)
end

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

LocalPlayer.CharacterAdded:Connect(function()
    ScreenGui:Destroy()
    script:Clone().Parent = LocalPlayer.Backpack
end)

updateUI()
