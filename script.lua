-- PANAMERA v3.0 + Time Control
local id = "140207837688369"
local speed = 1
local volume = 1

local function PlaySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"..tostring(id)
    sound.Volume = volume
    sound.PlaybackSpeed = speed
    sound.Parent = game.Players.LocalPlayer:FindFirstChild("Backpack")
    sound:Play()
end

if _G.GrabConn then _G.GrabConn:Disconnect() end
_G.GrabConn = workspace.ChildAdded:Connect(function(Child)
    if Child.Name ~= "GrabParts" then return end
    
    local GrabPart = Child and Child:WaitForChild("GrabPart", 1)
    local WeldConstraint = GrabPart and GrabPart:WaitForChild("WeldConstraint", 1)
    if WeldConstraint and WeldConstraint.Part1.Parent and WeldConstraint.Part1.Parent:FindFirstChild("Humanoid") then
        local AttachSound = GrabPart and GrabPart:WaitForChild("AttachSound", 1)
        if not AttachSound then return end; AttachSound.Volume = 0
        PlaySound()
    end
end)

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local fovEnabled = false
local tpEnabled = false
local espEnabled = false
local thirdPersonEnabled = false
local antiGrabEnabled = false
local autoResetEnabled = false
local timeEnabled = false

local normalFOV = 120
local boostedFOV = 120
local guiVisible = true
local currentPage = 1

local antiGrabConn = nil
local savedCFrame = nil
local antiKickResetConnection = nil
local thirdPersonConnection = nil

local espFolder = Instance.new("Folder")
espFolder.Name = "PANAMERA_ESP"
espFolder.Parent = game.CoreGui

local espElements = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PANAMERA_GUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "PANAMERA"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

local tabsFrame = Instance.new("Frame")
tabsFrame.Parent = mainFrame
tabsFrame.BackgroundTransparency = 1
tabsFrame.Position = UDim2.new(0, 0, 0, 30)
tabsFrame.Size = UDim2.new(1, 0, 0, 30)

local tab1Button = Instance.new("TextButton")
tab1Button.Parent = tabsFrame
tab1Button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
tab1Button.Position = UDim2.new(0, 5, 0, 5)
tab1Button.Size = UDim2.new(0.5, -7.5, 0, 25)
tab1Button.Font = Enum.Font.GothamBold
tab1Button.Text = "MAIN"
tab1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Button.TextSize = 12

local tab2Button = Instance.new("TextButton")
tab2Button.Parent = tabsFrame
tab2Button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
tab2Button.Position = UDim2.new(0.5, 2.5, 0, 5)
tab2Button.Size = UDim2.new(0.5, -7.5, 0, 25)
tab2Button.Font = Enum.Font.GothamBold
tab2Button.Text = "DEFENSE"
tab2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
tab2Button.TextSize = 12

local page1 = Instance.new("Frame")
page1.Name = "Page1"
page1.Parent = mainFrame
page1.BackgroundTransparency = 1
page1.Position = UDim2.new(0, 0, 0, 65)
page1.Size = UDim2.new(1, 0, 1, -65)
page1.Visible = true

local page2 = Instance.new("Frame")
page2.Name = "Page2"
page2.Parent = mainFrame
page2.BackgroundTransparency = 1
page2.Position = UDim2.new(0, 0, 0, 65)
page2.Size = UDim2.new(1, 0, 1, -65)
page2.Visible = false

local function switchTab(tabNum)
    currentPage = tabNum
    if tabNum == 1 then
        page1.Visible = true
        page2.Visible = false
        tab1Button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tab2Button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    else
        page1.Visible = false
        page2.Visible = true
        tab1Button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        tab2Button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

tab1Button.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Button.MouseButton1Click:Connect(function() switchTab(2) end)

local function createMenuItem(parent, name, yPos)
    local indicator = Instance.new("Frame")
    indicator.Parent = parent
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    indicator.Position = UDim2.new(0, 15, 0, yPos)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    
    local status = Instance.new("TextLabel")
    status.Parent = parent
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 40, 0, yPos)
    status.Size = UDim2.new(0, 120, 0, 18)
    status.Font = Enum.Font.Gotham
    status.Text = name .. ": OFF"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextSize = 11
    
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.Position = UDim2.new(0, 165, 0, yPos - 4)
    button.Size = UDim2.new(0, 105, 0, 24)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    return indicator, status, button
end

local fovIndicator, fovStatus, fovButton = createMenuItem(page1, "FOV", 5)
local tpIndicator, tpStatus, tpButton = createMenuItem(page1, "TP", 35)
local espIndicator, espStatus, espButton = createMenuItem(page1, "ESP", 65)
local ragdollIndicator, ragdollStatus, ragdollButton = createMenuItem(page1, "Ragdoll", 95)
local thirdPersonIndicator, thirdPersonStatus, thirdPersonButton = createMenuItem(page1, "3rd Person", 125)
local timeIndicator, timeStatus, timeButton = createMenuItem(page1, "Time", 155)

local timeFrame = Instance.new("Frame")
timeFrame.Name = "TimeFrame"
timeFrame.Parent = page1
timeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
timeFrame.BackgroundTransparency = 0.8
timeFrame.Position = UDim2.new(0, 10, 0, 180)
timeFrame.Size = UDim2.new(0, 265, 0, 110)
timeFrame.Visible = false
timeFrame.ClipsDescendants = true

local timeCorner = Instance.new("UICorner")
timeCorner.CornerRadius = UDim.new(0, 8)
timeCorner.Parent = timeFrame

local timeDisplay = Instance.new("TextLabel")
timeDisplay.Name = "TimeDisplay"
timeDisplay.Parent = timeFrame
timeDisplay.BackgroundTransparency = 1
timeDisplay.Position = UDim2.new(0, 10, 0, 2)
timeDisplay.Size = UDim2.new(1, -20, 0, 24)
timeDisplay.Font = Enum.Font.GothamBold
timeDisplay.Text = "14:30"
timeDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
timeDisplay.TextSize = 18

local hourLabel = Instance.new("TextLabel")
hourLabel.Parent = timeFrame
hourLabel.BackgroundTransparency = 1
hourLabel.Position = UDim2.new(0, 10, 0, 30)
hourLabel.Size = UDim2.new(0, 40, 0, 14)
hourLabel.Font = Enum.Font.GothamBold
hourLabel.Text = "ЧАС"
hourLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
hourLabel.TextSize = 10

local hourSlider = Instance.new("Frame")
hourSlider.Parent = timeFrame
hourSlider.Position = UDim2.new(0, 50, 0, 33)
hourSlider.Size = UDim2.new(0, 195, 0, 5)
hourSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

local hourFill = Instance.new("Frame")
hourFill.Parent = hourSlider
hourFill.Size = UDim2.new(0.58, 0, 1, 0)
hourFill.BackgroundColor3 = Color3.fromRGB(200, 150, 50)

local hourButton = Instance.new("TextButton")
hourButton.Parent = hourFill
hourButton.Size = UDim2.new(0, 12, 0, 12)
hourButton.Position = UDim2.new(1, -6, 0, -3.5)
hourButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hourButton.Text = ""
hourButton.BorderSizePixel = 0

local minuteLabel = Instance.new("TextLabel")
minuteLabel.Parent = timeFrame
minuteLabel.BackgroundTransparency = 1
minuteLabel.Position = UDim2.new(0, 10, 0, 55)
minuteLabel.Size = UDim2.new(0, 40, 0, 14)
minuteLabel.Font = Enum.Font.GothamBold
minuteLabel.Text = "МИН"
minuteLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
minuteLabel.TextSize = 10

local minuteSlider = Instance.new("Frame")
minuteSlider.Parent = timeFrame
minuteSlider.Position = UDim2.new(0, 50, 0, 58)
minuteSlider.Size = UDim2.new(0, 195, 0, 5)
minuteSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

local minuteFill = Instance.new("Frame")
minuteFill.Parent = minuteSlider
minuteFill.Size = UDim2.new(0.5, 0, 1, 0)
minuteFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)

local minuteButton = Instance.new("TextButton")
minuteButton.Parent = minuteFill
minuteButton.Size = UDim2.new(0, 12, 0, 12)
minuteButton.Position = UDim2.new(1, -6, 0, -3.5)
minuteButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minuteButton.Text = ""
minuteButton.BorderSizePixel = 0

local applyTimeButton = Instance.new("TextButton")
applyTimeButton.Parent = timeFrame
applyTimeButton.Position = UDim2.new(0, 50, 0, 78)
applyTimeButton.Size = UDim2.new(0, 195, 0, 22)
applyTimeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
applyTimeButton.Text = "ПРИМЕНИТЬ"
applyTimeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyTimeButton.Font = Enum.Font.GothamBold
applyTimeButton.TextSize = 12
applyTimeButton.BorderSizePixel = 0

local timeCorner2 = Instance.new("UICorner")
timeCorner2.CornerRadius = UDim.new(0, 5)
timeCorner2.Parent = applyTimeButton

local currentHour = 14
local currentMinute = 30

local function updateTimeDisplay()
    timeDisplay.Text = string.format("%02d:%02d", currentHour, currentMinute)
end

local function updateSliders()
    hourFill.Size = UDim2.new(currentHour / 24, 0, 1, 0)
    minuteFill.Size = UDim2.new(currentMinute / 60, 0, 1, 0)
end

local function setTime(hour, minute)
    Lighting.TimeOfDay = string.format("%02d:%02d:00", hour, minute)
    if Lighting:FindFirstChild("ClockTime") then
        Lighting.ClockTime = (hour * 3600 + minute * 60) / 3600
    end
    if hour >= 6 and hour < 18 then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    else
        Lighting.Brightness = 0.5
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 60)
    end
end

local function setupSlider(sliderFill, sliderButton, maxValue, onChange)
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = sliderFill.Parent.AbsolutePosition.X
            local sliderWidth = sliderFill.Parent.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            local value = math.floor(percent * maxValue)
            if maxValue == 24 then value = math.clamp(value, 0, 23) end
            if maxValue == 60 then value = math.clamp(value, 0, 59) end
            onChange(value)
        end
    end)
end

setupSlider(hourFill, hourButton, 24, function(value)
    currentHour = value
    updateTimeDisplay()
    updateSliders()
end)

setupSlider(minuteFill, minuteButton, 60, function(value)
    currentMinute = value
    updateTimeDisplay()
    updateSliders()
end)

applyTimeButton.MouseButton1Click:Connect(function()
    setTime(currentHour, currentMinute)
    applyTimeButton.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
    task.wait(0.2)
    applyTimeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end)

local function toggleTime()
    timeEnabled = not timeEnabled
    timeFrame.Visible = timeEnabled
    if timeEnabled then
        timeIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        timeStatus.Text = "Time: ON"
        timeButton.Text = "Hide"
    else
        timeIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        timeStatus.Text = "Time: OFF"
        timeButton.Text = "Time"
    end
end

timeButton.MouseButton1Click:Connect(toggleTime)

local hintLabel1 = Instance.new("TextLabel")
hintLabel1.Parent = page1
hintLabel1.BackgroundTransparency = 1
hintLabel1.Position = UDim2.new(0, 10, 0, 275)
hintLabel1.Size = UDim2.new(0, 280, 0, 75)
hintLabel1.Font = Enum.Font.GothamBold
hintLabel1.Text = "[R] FOV  •  [Z] TP  •  [C] Ragdoll\n[V] 3rd Person  •  [L] Hide GUI\n[Tab] Switch Page"
hintLabel1.TextColor3 = Color3.fromRGB(220, 220, 220)
hintLabel1.TextSize = 12
hintLabel1.TextWrapped = true

local antiGrabIndicator, antiGrabStatus, antiGrabButton = createMenuItem(page2, "Anti Grab", 5)
local autoResetIndicator, autoResetStatus, autoResetButton = createMenuItem(page2, "Auto Reset", 35)

local hintLabel2 = Instance.new("TextLabel")
hintLabel2.Parent = page2
hintLabel2.BackgroundTransparency = 1
hintLabel2.Position = UDim2.new(0, 10, 0, 70)
hintLabel2.Size = UDim2.new(0, 280, 0, 80)
hintLabel2.Font = Enum.Font.GothamBold
hintLabel2.Text = "Anti Grab - prevents players from\ngrabbing you\n\nAuto Reset - auto respawn when\nkicked for flying"
hintLabel2.TextColor3 = Color3.fromRGB(220, 220, 220)
hintLabel2.TextSize = 12
hintLabel2.TextWrapped = true

local function toggleAntiGrab()
    antiGrabEnabled = not antiGrabEnabled
    
    if antiGrabEnabled then
        local isHeld = player:WaitForChild("IsHeld", 5)
        local struggleEvent = ReplicatedStorage:WaitForChild("CharacterEvents", 5)
        if struggleEvent then
            struggleEvent = struggleEvent:WaitForChild("Struggle", 5)
        end
        
        if not isHeld or not struggleEvent then
            antiGrabEnabled = false
            antiGrabIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            antiGrabStatus.Text = "Anti Grab: Error"
            return
        end
        
        local function onHeldChanged(heldState)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if heldState then
                if hrp then 
                    savedCFrame = hrp.CFrame
                    hrp.Anchored = true 
                end
                
                task.spawn(function()
                    while isHeld.Value and antiGrabEnabled do 
                        struggleEvent:FireServer(player)
                        task.wait() 
                    end
                    if hrp then 
                        hrp.Anchored = false 
                        if savedCFrame then hrp.CFrame = savedCFrame end
                    end
                end)
            else
                if hrp then 
                    hrp.Anchored = false 
                    if savedCFrame then hrp.CFrame = savedCFrame end
                end
            end
        end
        
        if antiGrabConn then
            antiGrabConn:Disconnect()
        end
        
        antiGrabConn = isHeld.Changed:Connect(onHeldChanged)
        
        if isHeld.Value then
            onHeldChanged(true)
        end
        
        antiGrabIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        antiGrabStatus.Text = "Anti Grab: ON"
        antiGrabButton.Text = "Disable"
    else
        if antiGrabConn then
            antiGrabConn:Disconnect()
            antiGrabConn = nil
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
        end
        
        antiGrabIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        antiGrabStatus.Text = "Anti Grab: OFF"
        antiGrabButton.Text = "Anti Grab"
    end
end

local function toggleAutoReset()
    autoResetEnabled = not autoResetEnabled
    
    if autoResetEnabled then
        local notifyEvent = ReplicatedStorage:WaitForChild("GameCorrectionEvents", 5)
        if notifyEvent then
            notifyEvent = notifyEvent:WaitForChild("GameCorrectionsNotify", 5)
        end
        
        if not notifyEvent then
            autoResetEnabled = false
            autoResetIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            autoResetStatus.Text = "Auto Reset: Error"
            return
        end
        
        antiKickResetConnection = notifyEvent.OnClientEvent:Connect(function(reason)
            if reason == "Flying" then
                local char = player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                    hum.Health = 0
                end
            end
        end)
        
        autoResetIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        autoResetStatus.Text = "Auto Reset: ON"
        autoResetButton.Text = "Disable"
    else
        if antiKickResetConnection then
            antiKickResetConnection:Disconnect()
            antiKickResetConnection = nil
        end
        
        autoResetIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        autoResetStatus.Text = "Auto Reset: OFF"
        autoResetButton.Text = "Auto Reset"
    end
end

local function toggleThirdPerson()
    thirdPersonEnabled = not thirdPersonEnabled
    
    if thirdPersonEnabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = 100
        
        thirdPersonConnection = RunService.RenderStepped:Connect(function()
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = 100
        end)
        
        thirdPersonIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        thirdPersonStatus.Text = "3rd Person: ON"
        thirdPersonButton.Text = "Disable"
    else
        if thirdPersonConnection then
            thirdPersonConnection:Disconnect()
            thirdPersonConnection = nil
        end
        
        player.CameraMode = Enum.CameraMode.LockFirstPerson
        player.CameraMaxZoomDistance = 0.5
        
        thirdPersonIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        thirdPersonStatus.Text = "3rd Person: OFF"
        thirdPersonButton.Text = "3rd Person"
    end
end

local function activateRagdoll()
    ragdollIndicator.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    ragdollStatus.Text = "Ragdoll: Working..."
    
    local char = player.Character
    local HRP = char and char:FindFirstChild("HumanoidRootPart")
    local Ragdoll = ReplicatedStorage:FindFirstChild("CharacterEvents")
    if Ragdoll then
        Ragdoll = Ragdoll:FindFirstChild("RagdollRemote")
    end
    
    if char and HRP and char:FindFirstChild("Left Leg") and char:FindFirstChild("Right Leg") and char:FindFirstChild("Torso") then
        local ll = char["Left Leg"]
        local rl = char["Right Leg"]
        local torso = char.Torso
        local void = workspace.FallenPartsDestroyHeight
        local pos = torso.CFrame
        
        workspace.FallenPartsDestroyHeight = -100
        
        if Ragdoll then
            Ragdoll:FireServer(HRP, 2)
        end
        
        task.wait(0.5)
        
        rl.CFrame = CFrame.new(0, -10000, 0)
        ll.CFrame = CFrame.new(0, -10000, 0)
        task.wait(0.3)
        
        torso.CFrame = CFrame.new(0, -9970, 0)
        task.wait(0.5)
        
        torso.CFrame = pos
        task.wait(0.5)
        
        workspace.FallenPartsDestroyHeight = void
        
        task.spawn(function()
            while char and char.Parent do
                if not char:FindFirstChild("Left Leg") and not char:FindFirstChild("Right Leg") then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        local controls = player.PlayerGui:FindFirstChild("ControlsGui")
                        if controls and controls:FindFirstChild("PCFrame") and controls.PCFrame:FindFirstChild("Stand") then
                            if controls.PCFrame.Stand.Visible == false then
                                hum.HipHeight = 2
                            else
                                hum.HipHeight = 0
                            end
                        end
                    end
                else
                    break
                end
                task.wait()
            end
        end)
        
        ragdollIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ragdollStatus.Text = "Ragdoll: Done"
        task.wait(2)
        ragdollIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ragdollStatus.Text = "Ragdoll: OFF"
    else
        ragdollIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ragdollStatus.Text = "Ragdoll: Error"
        task.wait(2)
        ragdollStatus.Text = "Ragdoll: OFF"
    end
end

local function getCameraTargetPosition()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 500, raycastParams)
    
    if raycastResult then
        return raycastResult.Position
    else
        return camera.CFrame.Position + camera.CFrame.LookVector * 500
    end
end

local function teleportToCenter()
    if not tpEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    
    if rootPart then
        rootPart.CFrame = CFrame.new(getCameraTargetPosition())
    end
end

local function createESPForPlayer(plr)
    if espElements[plr] or plr == player then return end
    
    local function updateESP()
        local character = plr.Character
        if not character then return end
        
        local head = character:FindFirstChild("Head")
        if not head then return end
        
        if espElements[plr] then
            espElements[plr]:Destroy()
            espElements[plr] = nil
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_"..plr.Name
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = espFolder
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = plr.DisplayName or plr.Name
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.3
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16
        textLabel.TextScaled = true
        
        espElements[plr] = billboard
    end
    
    if plr.Character then
        updateESP()
    end
    
    plr.CharacterAdded:Connect(updateESP)
    plr.CharacterRemoving:Connect(function()
        if espElements[plr] then
            espElements[plr]:Destroy()
            espElements[plr] = nil
        end
    end)
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player then
                createESPForPlayer(plr)
            end
        end
        
        game.Players.PlayerAdded:Connect(function(plr)
            if plr ~= player then
                createESPForPlayer(plr)
            end
        end)
        
        game.Players.PlayerRemoving:Connect(function(plr)
            if espElements[plr] then
                espElements[plr]:Destroy()
                espElements[plr] = nil
            end
        end)
        
        espIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        espStatus.Text = "ESP: ON"
        espButton.Text = "Disable"
    else
        for _, element in pairs(espElements) do
            element:Destroy()
        end
        espElements = {}
        
        espIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        espStatus.Text = "ESP: OFF"
        espButton.Text = "ESP"
    end
end

local function toggleFOV()
    fovEnabled = not fovEnabled
    camera.FieldOfView = fovEnabled and boostedFOV or normalFOV
    
    if fovEnabled then
        fovIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fovStatus.Text = "FOV: ON ("..boostedFOV..")"
        fovButton.Text = "Disable"
    else
        fovIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fovStatus.Text = "FOV: OFF"
        fovButton.Text = "FOV"
    end
end

local function toggleTP()
    tpEnabled = not tpEnabled
    
    if tpEnabled then
        tpIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        tpStatus.Text = "TP: ON"
        tpButton.Text = "Disable"
    else
        tpIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        tpStatus.Text = "TP: OFF"
        tpButton.Text = "TP"
    end
end

local function toggleGUI()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end

fovButton.MouseButton1Click:Connect(toggleFOV)
tpButton.MouseButton1Click:Connect(toggleTP)
espButton.MouseButton1Click:Connect(toggleESP)
ragdollButton.MouseButton1Click:Connect(activateRagdoll)
thirdPersonButton.MouseButton1Click:Connect(toggleThirdPerson)
antiGrabButton.MouseButton1Click:Connect(toggleAntiGrab)
autoResetButton.MouseButton1Click:Connect(toggleAutoReset)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        toggleFOV()
    elseif input.KeyCode == Enum.KeyCode.Z then
        teleportToCenter()
    elseif input.KeyCode == Enum.KeyCode.C then
        activateRagdoll()
    elseif input.KeyCode == Enum.KeyCode.V then
        toggleThirdPerson()
    elseif input.KeyCode == Enum.KeyCode.L then
        toggleGUI()
    elseif input.KeyCode == Enum.KeyCode.Tab then
        switchTab(currentPage == 1 and 2 or 1)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if fovEnabled then
        camera.FieldOfView = boostedFOV
    end
    if thirdPersonEnabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = 100
    end
end)

print("PANAMERA v3.0 + Time Control Loaded!")
print("[R] FOV | [Z] TP | [C] Ragdoll | [V] 3rd Person")
print("[L] Hide GUI | [Tab] Switch Page")

while not game:IsLoaded() do task.wait() end
if getgenv().InventoryPlus == "V2" then 
    for _, ui in ipairs(game.CoreGui:GetChildren()) do
        if ui.Name == "InventoryPlusV2" then 
            ui:Destroy()
        end
    end
    task.wait()
end
getgenv().InventoryPlus = "V2"

for _, folder in {
    "InventoryPlusV2",
    "InventoryPlusV2/Config",
    "InventoryPlusV2/Config/FavoritesSaves"
} do
    if not isfolder(folder) then makefolder(folder) end
end

for _, file in {
    "InventoryPlusV2/Config/FavoritesSaves/Favorites.json"
} do
    if not isfile(file) then writefile(file, "") end
end

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 9e9)
local TabContents = PlayerGui:WaitForChild("MenuGui", 9e9):WaitForChild("Menu", 9e9):WaitForChild("TabContents", 9e9)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MenuToys = ReplicatedStorage.MenuToys
local SpawnToyRemoteFunction, DestroyToy, BuyToyRemoteFunction = MenuToys.SpawnToyRemoteFunction, MenuToys.DestroyToy, MenuToys.BuyToyRemoteFunction
local SpawnedInToys = workspace[LocalPlayer.Name.."SpawnedInToys"]

local CoreGui = game.CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InventoryPlusV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.DisplayOrder = -1

local Inventory = {
    Toys = {
        AlreadyHave = {},
        Spawned = {},
        ToBuy = {},
        ToysTypes = {
            Furniture = {
                "ArmChairBlue", "BathroomShower", "BathroomSink", "BedBlanketBlue", "BedFramedOrange",
                "BedFuton", "ChildrensChair", "ChildrensCouch", "ChildrensDesk", "ChildrensShelf",
                "ChildrensTable", "ChildrensTableBench", "ChildrensTableBenchSmall", "ClockAlarm", "ComputerLaptopOld",
                "CouchBlue", "CounterCorner", "CounterSink", "CounterStraight", "FactoryBench",
                "FactoryCabinet", "FactoryChair", "FactoryCouch", "FactoryDesk", "FactoryDeskMini",
                "FactoryLight", "FactoryShelf", "FactoryTable", "FanElectricLittle", "FanPaper",
                "FridgeBlack", "FutureAngularDesk", "JapaneseBanner", "JapaneseBench", "JapaneseChair",
                "JapaneseCouch", "JapaneseDeskMini", "JapaneseDresser", "JapaneseLantern", "JapaneseShelf",
                "JapaneseTable", "JukeboxBlue", "JukeboxOrange", "LadderLightBrown", "LightLampGray",
                "MachineWasher", "NormalBench", "NormalCabinet", "NormalDesk", "NormalShelves",
                "OvenRusty", "PlantPottedBonsai", "PlantPottedCactus", "PlantPottedTree", "PlantPottedTreeChristmas",
                "RedGateGong", "SpookyBench", "SpookyCabinet", "SpookyChair", "SpookyCouch",
                "SpookyDesk", "SpookyShelf", "SpookyStool", "SpookyTable", "TableLunchTable",
                "TableSmallLabTable", "TableWoodFourLegsBrown", "TableWoodTwoLegs", "TelevisionFlatscreen", "TelevisionGray",
                "ToiletGold", "ToiletWhite", "ArmChairDarkGray", "ArmChairPink", "ArmChairWhite",
                "CouchDarkGray", "CouchPink", "CouchWhite", "OvenDarkGray", "OvenMicrowaveWhite"
            },
            Lights = {
                "BallMagicLight", "Campfire", "DiscoColorBall", "FactoryLight", "FireworkSparkler",
                "JapaneseLantern", "LightLampDeskLampBent", "LightLampGray", "MineralCrystalPink", "SpookyCandle1",
                "SpookyCandle3", "SpookyCandle5", "SpotlightBlue", "SpotlightWhite", "SpotlightGreen",
                "SpotlightRed"
            },
            Food = {
                "CupMugWhite", "FoodBanana", "FoodBread", "FoodBroccoli", "FoodCakePink",
                "FoodCoconut", "FoodDippyEgg", "FoodDonut", "FoodFrenchFries", "FoodHamburger",
                "FoodHotSauce", "FoodHotdog", "FoodMayonnaise", "FoodMeatStick", "FoodMushroomPoison",
                "FoodPizzaCheese", "FoodPizzaPepperoni", "FoodPlate", "FoodSodaCan", "PoopPile",
                "PoopPileSparkle", "CupMugBrown"
            },
            Props = {
                "AnvilGray", "BallBasketball", "BellBig", "BellSmall", "BookManyPages",
                "BookNormal", "BoxCrateWood", "DiceBig", "DiceSmall", "DrawerLightBrown",
                "FlagUnitedStatesOfAmerica", "FoodPlate", "GlassBoxGray", "HayBale", "MineralCrystalPink",
                "MineralDiamond", "MineralIngotGold", "PalletLightBrown", "PoopPile", "PoopPileSparkle",
                "RedGateGong", "RollerGrayPurple", "Snowflake", "TeapotUtah", "TetracubeI",
                "TetracubeJ", "TetracubeL", "TetracubeO", "TetracubeS", "TetracubeT",
                "TetracubeZ", "ToyAnimalBear", "ToyAnimalDuck", "ToyAnimalFrog", "ToyAnimalTiger",
                "ToyAnimalUnicorn", "YouFigurine"
            },
            Toys = {
                "Airhorn", "BallSnowball", "BombBalloon", "BombDarkMatter", "BombMissile",
                "Boombox", "BubbleBlower", "BucketPaint", "Campfire", "CreatureBlobman",
                "DiscoColorBall", "FireExtinguisher", "FireworkMissile", "FireworkSmokeBomb", "FireworkSparkler",
                "FloatingIsland", "FlyingToyHelicopter", "FlyingToyPlane", "FlyingToyUfo", "FoodHotSauce",
                "InstrumentBrassBugle", "InstrumentBrassTrumpet", "InstrumentBrassVuvuzela", "InstrumentDrumBongos", "InstrumentDrumSnare",
                "InstrumentGuitarAcoustic", "InstrumentGuitarBanjo", "InstrumentGuitarLyre", "InstrumentGuitarUkulele", "InstrumentGuitarViolin",
                "InstrumentPianoKeyboard", "InstrumentPianoMelodica", "InstrumentVoiceMicrophone", "InstrumentWoodwindOcarina", "InstrumentWoodwindSaxophone",
                "JukeboxBlue", "JukeboxOrange", "MidiMaker", "MusicKeyboard", "NinjaKatana",
                "NinjaKunai", "NinjaShuriken", "NpcRobloxianMascot", "PaperPlane", "PetSnowman",
                "PetTurkeyLeg", "PlayhouseGingerbread", "PresentBig", "PresentSmall", "SantaSleigh",
                "SoundWaveMaker", "ToiletGold", "ToiletWhite", "ToolCleaver", "ToolDiggingForkRusty",
                "ToolPencil", "ToolPickaxe", "TractorGreen", "TractorOrange", "TractorRed",
                "YouDecoy", "YouLittle", "SprayCanWD"
            },
            All = {
                "Airhorn", "AnvilGray", "ArmChairBlue", "BallBasketball", "BallMagicLight",
                "BallSnowball", "BathroomShower", "BathroomSink", "BedBlanketBlue", "BedFramedOrange",
                "BedFuton", "BellBig", "BellSmall", "BombBalloon", "BombDarkMatter",
                "BombMissile", "BookManyPages", "BookNormal", "Boombox", "BoxCrateWood",
                "BubbleBlower", "BucketPaint", "Campfire", "ChildrensChair", "ChildrensCouch",
                "ChildrensDesk", "ChildrensShelf", "ChildrensTable", "ChildrensTableBench", "ChildrensTableBenchSmall",
                "ClockAlarm", "ComputerLaptopOld", "CouchBlue", "CounterCorner", "CounterSink",
                "CounterStraight", "CreatureBlobman", "CupMugWhite", "DiceBig", "DiceSmall",
                "DiscoColorBall", "DrawerLightBrown", "FactoryBench", "FactoryCabinet", "FactoryChair",
                "FactoryCouch", "FactoryDesk", "FactoryDeskMini", "FactoryLight", "FactoryShelf",
                "FactoryTable", "FanElectricLittle", "FanPaper", "FireExtinguisher", "FireworkMissile",
                "FireworkSmokeBomb", "FireworkSparkler", "FlagUnitedStatesOfAmerica", "FloatingIsland", "FlyingToyHelicopter",
                "FlyingToyPlane", "FlyingToyUfo", "FoodBanana", "FoodBread", "FoodBroccoli",
                "FoodCakePink", "FoodCoconut", "FoodDippyEgg", "FoodDonut", "FoodFrenchFries",
                "FoodHamburger", "FoodHotSauce", "FoodHotdog", "FoodMayonnaise", "FoodMeatStick",
                "FoodMushroomPoison", "FoodPizzaCheese", "FoodPizzaPepperoni", "FoodPlate", "FoodSodaCan",
                "FridgeBlack", "FutureAngularDesk", "GlassBoxGray", "HayBale", "InstrumentBrassBugle",
                "InstrumentBrassTrumpet", "InstrumentBrassVuvuzela", "InstrumentDrumBongos", "InstrumentDrumSnare", "InstrumentGuitarAcoustic",
                "InstrumentGuitarBanjo", "InstrumentGuitarLyre", "InstrumentGuitarUkulele", "InstrumentGuitarViolin", "InstrumentPianoKeyboard",
                "InstrumentPianoMelodica", "InstrumentVoiceMicrophone", "InstrumentWoodwindOcarina", "InstrumentWoodwindSaxophone", "JapaneseBanner",
                "JapaneseBench", "JapaneseChair", "JapaneseCouch", "JapaneseDeskMini", "JapaneseDresser",
                "JapaneseLantern", "JapaneseShelf", "JapaneseTable", "JukeboxBlue", "JukeboxOrange",
                "LadderLightBrown", "LightLampDeskLampBent", "LightLampGray", "MachineWasher", "MidiMaker",
                "MineralCrystalPink", "MineralDiamond", "MineralIngotGold", "MusicKeyboard", "NinjaKatana",
                "NinjaKunai", "NinjaShuriken", "NormalBench", "NormalCabinet", "NormalDesk",
                "NormalShelves", "NpcRobloxianMascot", "OvenRusty", "PalletLightBrown", "PaperPlane",
                "PetSnowman", "PetTurkeyLeg", "PlantPottedBonsai", "PlantPottedCactus", "PlantPottedTree",
                "PlantPottedTreeChristmas", "PlayhouseGingerbread", "PoopPile", "PoopPileSparkle", "PresentBig",
                "PresentSmall", "RedGateGong", "RollerGrayPurple", "SantaSleigh", "Snowflake",
                "SoundWaveMaker", "SpookyBench", "SpookyCabinet", "SpookyCandle1", "SpookyCandle3",
                "SpookyCandle5", "SpookyChair", "SpookyCouch", "SpookyDesk", "SpookyShelf",
                "SpookyStool", "SpookyTable", "SpotlightBlue", "SpotlightWhite", "TableLunchTable",
                "TableSmallLabTable", "TableWoodFourLegsBrown", "TableWoodTwoLegs", "TeapotUtah", "TelevisionFlatscreen",
                "TelevisionGray", "TetracubeI", "TetracubeJ", "TetracubeL", "TetracubeO",
                "TetracubeS", "TetracubeT", "TetracubeZ", "ToiletGold", "ToiletWhite",
                "ToolCleaver", "ToolDiggingForkRusty", "ToolPencil", "ToolPickaxe", "ToyAnimalBear",
                "ToyAnimalDuck", "ToyAnimalFrog", "ToyAnimalTiger", "ToyAnimalUnicorn", "TractorGreen",
                "TractorOrange", "TractorRed", "YouDecoy", "YouFigurine", "YouLittle",
                "ArmChairDarkGray", "ArmChairPink", "ArmChairWhite", "CouchDarkGray", "CouchPink",
                "CouchWhite", "CupMugBrown", "OvenDarkGray", "OvenMicrowaveWhite", "SpotlightGreen",
                "SpotlightRed", "SprayCanWD"
            }
        },
        RealToys = {},
        FavoriteToys = {}
    },
    Settings = {
        Line = {
            Colors = {},
            Texture = "...",
            MaxLength = "Unlimited"
        },
        UI = {
            MainColor = Color3.fromRGB(20, 20, 20),
            StrokeColor = Color3.fromRGB(20, 20, 20),
            TextColor = Color3.fromRGB(240, 240, 240),
            SubTextColor = Color3.fromRGB(100, 100, 100),
            ElementsColor = Color3.fromRGB(80, 80, 80),
            MainTransparency = 0.3,
            ElementsTransparency = 0.95,
            MainSize = UDim2.new(0, 850, 0, 550),
            ToysSize = UDim2.new(0.9, 0, 0.9, 0),
            MainPosition = UDim2.new(0.5, -425, 0.5, -300),
            ShowToyNames = false
        }
    },
    Connections = {},
    Tabs = {},
    InvisibleFrames = {},
    CurrentTab = "Your Toys",
    CurrentSubTab = "All",
    CurrentShopToy = "",
    LayoutOrderToys = -1,
    SelectingFavorites = false
}

for i, toy in TabContents.Toys.Contents:GetChildren() do
    if toy.Name == "UIGridLayout" then continue end
    Inventory.Toys.AlreadyHave[toy.Name] = {
        Name = toy.Name,
        Icon = toy.ViewItemButton.LowResImage.Image,
        RectOffset = toy.ViewItemButton.LowResImage.ImageRectOffset,
        IsDecoy = (toy.Name == "YouDecoy" or toy.Name == "YouFigurine" or toy.Name == "YouLittle") and true or false,
        RealToy = toy,
        Order = toy.LayoutOrder
    } 
end

for i, toy in TabContents.ToyShop.Contents:GetChildren() do
    if toy.Name == "UIGridLayout" then continue end
    Inventory.Toys.ToBuy[i] = {
        Name = toy.Name,
        Icon = toy.ViewItemButton.LowResImage.Image,
        IconColor = toy.ViewItemButton.LowResImage.ImageColor3,
        RectOffset = toy.ViewItemButton.LowResImage.ImageRectOffset,
        IsDecoy = (toy.Name == "YouDecoy" or toy.Name == "YouFigurine" or toy.Name == "YouLittle") and true or false,
        RealToy = toy,
        ToyDescription = toy.Parent.Parent.ToyInfoFrameHolder[toy.Name].ItemDesc.Text
    }
end

for i, toy in TabContents.ToyDestroy.Contents:GetChildren() do
    if toy.Name == "UIGridLayout" then continue end
    Inventory.Toys.Spawned[i] = {
        Name = toy.Name,
        Icon = toy.ViewItemButton.LowResImage.Image,
        IconColor = toy.ViewItemButton.LowResImage.ImageColor3,
        RectOffset = toy.ViewItemButton.LowResImage.ImageRectOffset,
        IsDecoy = (toy.Name == "YouDecoy" or toy.Name == "YouFigurine" or toy.Name == "YouLittle") and true or false,
        RealToy = toy,
        LayoutOrder = toy.LayoutOrder
    }
end

do
    local Data = readfile("InventoryPlusV2/Config/FavoritesSaves/Favorites.json")
    if Data ~= "" then
        Inventory.FavoriteToysNames = HttpService:JSONDecode(Data)
        for i, toy in Inventory.FavoriteToysNames do
            local RealToy = Inventory.Toys.AlreadyHave[toy.Name]
            if RealToy == nil then continue end
            Inventory.Toys.FavoriteToys[RealToy.Order] = toy.Name
        end
    end
end

local function AddConnection(Connection, Function, Name)
    local Conn = Connection:Connect(Function)
    Inventory.Connections[Name ~= nil and Name or #Inventory.Connections+1] = Conn
    return Conn
end

local function RemoveConnection(Connection)
    if Inventory.Connections[Connection] ~= nil then
        Inventory.Connections[Connection]:Disconnect()
        Inventory.Connections[Connection] = nil
    end
end

local function CreateElement(Name, Props)
    local Element = Instance.new(Name)
    for i, v in Props or {} do Element[i] = v end
    return Element
end

local function SetChildren(Parent, Children)
    for i, v in Children do v.Parent = Parent end
    return Parent
end

local function PlaySound(Name)
    PlayerGui.MenuGui[Name]:Play()
end

local function PlayTween(...)
    local ArgsFunction = {...}
    local Parent, Info, Args = table.unpack(ArgsFunction)
    Info = TweenInfo.new(typeof(Info) == "table" and table.unpack(Info) or Info)
    TweenService:Create(Parent, Info, Args):Play()
end

local function CreateMainWindow()
    local IsVisible = true
    local MainWindow = SetChildren(CreateElement("Frame", {
        Transparency = Inventory.Settings.UI.MainTransparency,
        BackgroundColor3 = Inventory.Settings.UI.MainColor,
        Size = Inventory.Settings.UI.MainSize,
        Position = Inventory.Settings.UI.MainPosition,
        Parent = ScreenGui,
        Name = "MainWindow",
        Visible = false,
        ClipsDescendants = true
    }), {
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
        CreateElement("UIStroke", {
            Color = Inventory.Settings.UI.StrokeColor,
            Thickness = 2,
            Transparency = 0.42
        }),
        SetChildren(CreateElement("Frame", {
            Transparency = 1,
            Size = UDim2.new(1, 0, 0, 60),
            Parent = ScreenGui,
            Name = "TopBar"
        }), {
            CreateElement("TextLabel", {
                Text = "Your Toys",
                Font = Enum.Font.GothamBlack,
                TextColor3 = Inventory.Settings.UI.TextColor,
                RichText = true,
                BackgroundTransparency = 1,
                TextSize = 26,
                Position = UDim2.new(0.5, 0, 0, 25),
                Name = "TabName",
                ZIndex = 2
            }),
            CreateElement("ImageButton", {
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(1, -40, 0, 12),
                BackgroundTransparency = 1,
                Name = "CloseButton",
                Image = "rbxassetid://7072725342"
            }),
            CreateElement("Frame", {
                BackgroundColor3 = Inventory.Settings.UI.StrokeColor,
                Transparency = 0.7,
                Size = UDim2.new(1, -70, 0, 0.5),
                Position = UDim2.new(0, 70, 0, 51),
                Name = "Stroke"
            }),
        })
    })

    local TabHolder = SetChildren(CreateElement("Frame", {
        Parent = MainWindow,
        Name = "TabHolder",
        Transparency = 1,
        Size = UDim2.new(0, 68, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 10
    }), {
        CreateElement("Frame", {
            BackgroundColor3 = Inventory.Settings.UI.StrokeColor,
            Transparency = 0.7,
            Size = UDim2.new(0, 0.5, 1, 0),
            Position = UDim2.new(0, 68, 0, 0),   
            Name = "Stroke"
        })
    })

    local ItemContainer = SetChildren(CreateElement("Frame", {
        BackgroundTransparency = 1,
        Name = "Container",
        Parent = MainWindow,
        Position = UDim2.new(0, 71, 0, 100),
        Size = UDim2.new(1, -70, 1, -160),
        BackgroundColor3 = Inventory.Settings.UI.MainColor,
    }), {
        CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 100)
        })
    })

    local InventoryBar = SetChildren(CreateElement("Frame", {
        Parent = MainWindow,
        Name = "InventorySpace",
        Size = UDim2.new(1, -70, 0, -50),
        Position = UDim2.new(0, 70, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }), {
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
        CreateElement("Frame", {
            BackgroundColor3 = Inventory.Settings.UI.StrokeColor,
            Transparency = 0.7,
            Size = UDim2.new(1, 0, 0, 0),
            Name = "Stroke"
        }),
        SetChildren(CreateElement("Frame", {
            Size = UDim2.new(1, -20, 0, 10),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 0.9,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        }), {
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
            CreateElement("UIStroke", {
                Color = Inventory.Settings.UI.StrokeColor,
                Thickness = 1,
                Transparency = 0.7
            }),
            SetChildren(CreateElement("Frame", {
                BackgroundColor3 = Color3.fromRGB(0, 240, 0),
                Transparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Name = "Bar"
            }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})})
        }),
        CreateElement("TextLabel", {
            Text = "Your Toys Limit",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = Inventory.Settings.UI.TextColor,
            Position = UDim2.new(0, 60, 0, 16)
        }),
        CreateElement("TextLabel", {
            Text = "0/"..tostring(LocalPlayer.ToysLimitCap.Value),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = Inventory.Settings.UI.TextColor,
            Position = UDim2.new(1, -28, 0, 16),
            Name = "Counter"
        })
    })

    local SubTabHolder = SetChildren(CreateElement("Frame", {
        Name = "SubTabHolder",
        Parent = MainWindow,
        Position = UDim2.new(0, 68, 0, 50),
        Size = UDim2.new(1, -68, 0, 52),
        Transparency = 1,
        ClipsDescendants = true
    }), {
        CreateElement("Frame", {
            Name = "Stroke",
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 0.5),
            BackgroundColor3 = Inventory.Settings.UI.StrokeColor,
            Transparency = 0.7
        })
    })

    local Watermark = SetChildren(CreateElement("Frame", {
        Name = "CoinsWatermark",
        Parent = ScreenGui,
        BackgroundColor3 = Inventory.Settings.UI.MainColor,
        Transparency = Inventory.Settings.UI.MainTransparency,
        Size = UDim2.new(0, 150, 0, 60),
        Position = UDim2.new(1, -160, 0, -50)
    }), {
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
        CreateElement("UIStroke", {
            Color = Inventory.Settings.UI.StrokeColor,
            Thickness = 1,
            Transparency = 0.95
        }),
        CreateElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = 16,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = string.format("Coins: %s\nFPS: %s\nPing: %s", PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text, "0", "0"),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(231, 226, 154)
        }),
        CreateElement("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -55, 0, 4),
            Image = "rbxassetid://10709753149",
            Visible = false,
            ImageColor3 = Color3.fromRGB(220, 50, 0)
        })
    })

    local BuyFrame = SetChildren(CreateElement("Frame", {
        Name = "BuyFrame",
        Parent = MainWindow,
        BackgroundColor3 = Inventory.Settings.UI.MainColor,
        Transparency = 0.2,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = -10
    }), {
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
        SetChildren(CreateElement("TextButton", {
            Name = "Buy",
            Size = UDim2.new(0.5, 15, 0, 30),
            Position = UDim2.new(0.5, -25, 1, -40),
            BackgroundColor3 = Color3.fromRGB(20, 115, 240),
            BackgroundTransparency = 0.5, 
            TextColor3 = Inventory.Settings.UI.TextColor,
            Font = Enum.Font.GothamBlack,
            TextSize = 20,
            Text = "Buy"
        }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})}),
        SetChildren(CreateElement("TextButton", {
            Name = "Back",
            Size = UDim2.new(0.5, -100, 0, 30),
            Position = UDim2.new(0, 68, 1, -40),
            BackgroundColor3 = Color3.fromRGB(90, 90, 90),
            BackgroundTransparency = 0.5, 
            TextColor3 = Inventory.Settings.UI.TextColor,
            Font = Enum.Font.GothamBlack,
            TextSize = 20,
            Text = "Back"
        }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})}),
        CreateElement("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 180, 0, 180),
            Position = UDim2.new(0, 100, 0.5, -90),
            Image = "rbxassetid://71634501782424",
            ImageRectSize = Vector2.new(90, 90),
            Name = "ToyImage"
        }),
        CreateElement("TextLabel", {
            Name = "ToyName",
            TextColor3 = Inventory.Settings.UI.TextColor,
            TextSize = 30,
            Font = Enum.Font.GothamBlack,
            Position = UDim2.new(0.5, 0, 0, 30)
        }),
        CreateElement("TextLabel", {
            Name = "ToyDescription",
            TextColor3 = Inventory.Settings.UI.TextColor,
            TextSize = 24,
            Font = Enum.Font.GothamBlack,
            Position = UDim2.new(0.5, -100, 0, 0),
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 90, 1, -20)
        })
    })

    AddConnection(BuyFrame.Back.MouseButton1Click, function()
        for _, frame in Inventory.InvisibleFrames do
            if frame.Name == "InventorySpace" then continue end
            frame.Visible = true
        end
        BuyFrame.Visible = false
        Inventory.InvisibleFrames = {}
    end)
    AddConnection(BuyFrame.Buy.MouseButton1Click, function()
        if BuyFrame.Buy.Text == "Buy" then
            BuyToy:InvokeServer(Inventory.CurrentShopToy)
            ChangeTab("Your Toys", TabHolder["Your Toys"])
        else
            ChangeTab("Your Toys", TabHolder["Your Toys"])
            local Tab = ItemContainer["Your Toys"]
            local Toy = Tab[Inventory.CurrentShopToy]
            local Color = Toy.BackgroundColor3
            Tab.CanvasPosition = Vector2.new(0, 0); task.wait(0.2)
            PlayTween(Tab, {0.5, Enum.EasingStyle.Quint}, {
                CanvasPosition = Vector2.new(0, Toy.AbsolutePosition.Y - (MainWindow.Size.X.Offset / 4))
            }); task.wait(0.6)
            Toy.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            for i = 1, 2 do
                PlayTween(Toy, {0.4, Enum.EasingStyle.Linear}, {
                    BackgroundTransparency = 0.2
                }); task.wait(0.4)
                PlayTween(Toy, {0.4, Enum.EasingStyle.Linear}, {
                    BackgroundTransparency = 1
                }); task.wait(0.4)
            end
            Toy.BackgroundColor3 = Color
        end
    end)
    AddConnection(MainWindow.TopBar.CloseButton.MouseButton1Click, function()
        MainWindow.Visible = false
        IsVisible = false
    end)
    AddConnection(UserInputService.InputBegan, function(input)
        if input.KeyCode == Enum.KeyCode.E then
            if UserInputService:GetFocusedTextBox() then return end
            IsVisible = not IsVisible
            task.spawn(function()
                while IsVisible do
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    task.wait()
                end
            end)
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = IsVisible
            MainWindow.Visible = IsVisible
            PlaySound(IsVisible and "Open" or "Close")
        end
    end)
    AddConnection(Watermark.TextLabel:GetPropertyChangedSignal("Text"), function()
        Watermark.Size = UDim2.new(0, Watermark.TextLabel.TextBounds.X + 20 + (Watermark.ImageLabel.Visible and 50 or 0), 0, Watermark.TextLabel.TextBounds.Y + 10)
        Watermark.Position = UDim2.new(1, -(Watermark.AbsoluteSize.X + 10), 0, -50)
    end)
    AddConnection(BuyFrame.ToyDescription:GetPropertyChangedSignal("Text"), function()
        BuyFrame.ToyDescription.Position = UDim2.new(0.5, -100, 0, 20)
    end)    

    function ChangeTab(Name, Button)
        local Tabs = {[1] = "Shop", [2] = "Your Toys", [3] = "Destroy Toys", [4] = "Settings"}
        local IndexTabs = {["Shop"] = 1, ["Your Toys"] = 2, ["Destroy Toys"] = 3, ["Settings"] = 4}
        PlaySound("Open")
        for _, frame in Inventory.InvisibleFrames do frame.Visible = true end
        for _, tabButton in TabHolder:GetChildren() do 
            if tabButton:IsA("Frame") then continue end
            PlayTween(tabButton.ImageLabel, 0.2, {ImageColor3 = Color3.fromRGB(155, 155, 155)})
        end; PlayTween(TabHolder[Name].ImageLabel, 0.2, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
        BuyFrame.Visible = false
        Inventory.InvisibleFrames = {}
        task.spawn(function()
            if Name ~= "Settings" and Name ~= "Shop" then 
                InventoryBar.Visible = true
                PlayTween(InventoryBar, {0.3, Enum.EasingStyle.Quint}, {Size = UDim2.new(1, -70, 0, -50)})
                ItemContainer.Size = UDim2.new(1, -70, 1, -160)
            else 
                PlayTween(InventoryBar, {0.3, Enum.EasingStyle.Quint}, {Size = UDim2.new(1, -70, 0, 0)}); task.wait(0.3)
                InventoryBar.Visible = false 
            end 
        end)
        task.spawn(function()
            if Name ~= "Settings" and Name ~= "Destroy Toys" then 
                SubTabHolder.Visible = true
                PlayTween(SubTabHolder, {0.3, Enum.EasingStyle.Quint}, {Size = UDim2.new(1, -68, 0, 52)})
            else 
                ItemContainer.Size = UDim2.new(1, -70, 1, -100)
                PlayTween(SubTabHolder, {0.3, Enum.EasingStyle.Quint}, {Size = UDim2.new(1, -68, 0, 0)})
                task.wait(0.3)
                SubTabHolder.Visible = false
            end 
        end)
        Inventory.Tabs[Name].Visible = true
        local ContainerPositionY = 0
        local Index = IndexTabs[Name]
        for i, tab in Tabs do if i == Index then break end; ContainerPositionY += Inventory.Tabs[tab].AbsoluteSize.Y end
        if Name == "Destroy Toys" then ContainerPositionY += 150 
        elseif Name == "Settings" then ContainerPositionY += 250 
        elseif Name == "Shop" then ContainerPositionY -= 100 
        end
        PlayTween(ItemContainer, {0.3, Enum.EasingStyle.Linear}, {Position = UDim2.new(0, 71, 0, -ContainerPositionY)})
        MainWindow.TopBar.TabName.Text = Name
        Inventory.CurrentTab = Name
    end

    function MakeTab(TabName, TabIcon, TabPosition, Order)
        local TabButton = SetChildren(CreateElement("TextButton", {
            Size = UDim2.new(0, 60, 0, 80),
            Position = TabPosition,
            BackgroundTransparency = 1,
            Name = TabName,
            Parent = TabHolder,
            Text = ""
        }), {
            SetChildren(CreateElement("ImageLabel", {
                Image = TabIcon,
                Position = UDim2.new(0, 0, 0, 10),
                Size = UDim2.new(0, 60, 0, 60),
                ImageColor3 = TabName == "Your Toys" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(155, 155, 155),
                BackgroundTransparency = 1
            }), {
                CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
                CreateElement("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2,
                    Transparency = 1
                })
            })
        })
        local TabFrame = SetChildren(CreateElement("ScrollingFrame", {
            Transparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Parent = ItemContainer,
            Name = TabName,
            CanvasSize = UDim2.new(0, 0, 0, 100),
            LayoutOrder = Order
        }), {
            CreateElement("UIGridLayout", {
                CellSize = UDim2.new(0, 75, 0, 75),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
        })
        AddConnection(TabFrame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabFrame.UIGridLayout.AbsoluteContentSize.Y)
        end)
        AddConnection(TabButton.MouseButton1Down, function()
            ChangeTab(TabName, TabButton)
        end)
        AddConnection(TabButton.MouseEnter, function() 
            PlayTween(TabButton.ImageLabel, {0.3, Enum.EasingStyle.Quint}, {
                Size = UDim2.new(0, 65, 0, 65), 
                Position = UDim2.new(0, -4, 0, 10),
                ImageColor3 = TabName ~= Inventory.CurrentTab and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
            }) 
            PlayTween(TabButton.ImageLabel.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 0.8})
        end)
        AddConnection(TabButton.MouseLeave, function() 
            PlayTween(TabButton.ImageLabel, {0.3, Enum.EasingStyle.Quint}, {
                Size = UDim2.new(0, 60, 0, 60), 
                Position = UDim2.new(0, -2, 0, 10),
                ImageColor3 = TabName ~= Inventory.CurrentTab and Color3.fromRGB(155, 155, 155) or Color3.fromRGB(255, 255, 255)
            }) 
            PlayTween(TabButton.ImageLabel.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 1})
        end)  
        Inventory.Tabs[TabName] = TabFrame
        TabFrame.Visible = true
        if TabName == "Your Toys" then ItemContainer.Position = UDim2.new(0, 71, 0, -TabFrame.AbsoluteSize.Y) end
    end

    function MakeSubTab(SubTabName, SubTabIcon, SubTabPosition)
        local SubTabButton = SetChildren(CreateElement("ImageButton", {
            Size = UDim2.new(0, 40, 0, 40),
            Position = SubTabPosition,
            BackgroundTransparency = 1,
            Image = SubTabIcon,
            Name = SubTabName,
            Parent = SubTabHolder,
            ImageColor3 = SubTabName ~= "All" and Color3.fromRGB(155, 155, 155) or Color3.fromRGB(255, 255, 255)
        }), {
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6)}),
            CreateElement("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 2,
                Transparency = 1
            })
        })
        local ToggleFrame, Toggled = nil, false
        if SubTabName == "Favorites" then
            ToggleFrame = SetChildren(CreateElement("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                Name = "ToggleFrame",
                Parent = SubTabButton,
                Transparency = 0.7,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Visible = false,
                ZIndex = -1
            }), {
                CreateElement("UICorner", {CornerRadius = UDim.new(0, 6)})
            })
        end
        AddConnection(SubTabButton.MouseButton1Down, function()
            Inventory.CurrentSubTab = SubTabName
            if SubTabName == "Favorites" then
                PlaySound("Select")
                PlayTween(ToggleFrame, {0.1, Enum.EasingStyle.Quint}, {
                    Transparency = Toggled and 1 or 0.7
                }); task.wait(0.1)
                Toggled = not Toggled
                ToggleFrame.Visible = Toggled
                Inventory.SelectingFavorites = Toggled
                if not Inventory.SelectingFavorites then
                    local Data = {}
                    for i, name in Inventory.Toys.FavoriteToys do 
                        Data[name] = {
                            Name = name,
                            LayoutOrderNonFav = Inventory.Toys.AlreadyHave[name].Order
                        }
                    end
                    writefile("InventoryPlusV2/Config/FavoritesSaves/Favorites.json", HttpService:JSONEncode(Data))
                end
            else
                PlaySound("Swap")
                for _, subTabButton in SubTabHolder:GetChildren() do
                    if subTabButton:IsA("Frame") then continue end
                    PlayTween(subTabButton, 0.2, {ImageColor3 = Color3.fromRGB(155, 155, 155)})
                end; PlayTween(SubTabHolder[SubTabName], 0.2, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
                for i, toy in ItemContainer["Your Toys"]:GetChildren() do
                    if not toy:IsA("ImageButton") then continue end
                    local AllToys = Inventory.Toys.ToysTypes[SubTabName]
                    toy.Visible = table.find(AllToys, toy.Name) and true or false
                end
                for i, toy in ItemContainer["Shop"]:GetChildren() do
                    if not toy:IsA("ImageButton") then continue end
                    local AllToys = Inventory.Toys.ToysTypes[SubTabName]
                    toy.Visible = table.find(AllToys, toy.Name) and true or false
                end
            end
        end)
        AddConnection(SubTabButton.MouseEnter, function() 
            PlayTween(SubTabButton, {0.3, Enum.EasingStyle.Quint}, {
                Size = UDim2.new(0, 45, 0, 45),
                Position = SubTabPosition - UDim2.new(0, 2.5, 0, 2.5),
                ImageColor3 = SubTabName ~= Inventory.CurrentSubTab and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
            }) 
            PlayTween(SubTabButton.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 0.8})
        end)
        AddConnection(SubTabButton.MouseLeave, function() 
            PlayTween(SubTabButton, {0.3, Enum.EasingStyle.Quint}, {
                Size = UDim2.new(0, 40, 0, 40),
                Position = SubTabPosition,
                ImageColor3 = SubTabName ~= Inventory.CurrentSubTab and Color3.fromRGB(155, 155, 155) or Color3.fromRGB(255, 255, 255)
            }) 
            PlayTween(SubTabButton.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 1})
        end)  
    end
end

local function UIWork()
    local ConnName = 0
    MakeTab("Shop", "rbxassetid://8657134912", UDim2.new(0, 5, 0.5, -155), 1)
    MakeTab("Your Toys", "rbxassetid://8657059521", UDim2.new(0, 5, 0.5, -80), 2)
    MakeTab("Destroy Toys", "rbxassetid://8845340609", UDim2.new(0, 5, 0.5, -5), 3)
    MakeTab("Settings", "rbxassetid://8657341581", UDim2.new(0, 5, 0.5, 70), 4)
    MakeSubTab("All", "http://www.roblox.com/asset/?id=8844782946", UDim2.new(0.5, -165, 0, 5))
    MakeSubTab("Food", "rbxassetid://8844245340", UDim2.new(0.5, -120, 0, 5))
    MakeSubTab("Furniture", "rbxassetid://8844148247", UDim2.new(0.5, -75, 0, 5))
    MakeSubTab("Lights", "rbxassetid://8844311089", UDim2.new(0.5, -30, 0, 5))
    MakeSubTab("Props", "rbxassetid://8656339114", UDim2.new(0.5, 15, 0, 5))
    MakeSubTab("Toys", "rbxassetid://8844659915", UDim2.new(0.5, 60, 0, 5))
    MakeSubTab("Favorites", "rbxassetid://10045503805", UDim2.new(1, -45, 0, 5))
    local FTAPMenu = PlayerGui:WaitForChild("MenuGui", 9e9)
    local Coins = FTAPMenu:WaitForChild("TopRight", 9e9):WaitForChild("CoinsFrame", 9e9):WaitForChild("CoinsDisplay", 9e9):WaitForChild("Coins", 9e9)
    local FTAPMenuScript = FTAPMenu.MenuAndToysNavigation
    FTAPMenuScript.Enabled, FTAPMenu.Enabled = false, false
    local InventoryV2 = CoreGui.InventoryPlusV2.MainWindow
    local SpaceUsed = InventoryV2.InventorySpace
    local SpaceUsedBar, SpaceUsedText = SpaceUsed.Frame.Bar, SpaceUsed.Counter
    local DestroyToys = InventoryV2.Container["Destroy Toys"]
    AddConnection(SpawnedInToys.ChildAdded, function(Toy1)
        local ToyButton = CreateElement("ImageButton", {
            BackgroundTransparency = 1,
            Image = Inventory.Toys.AlreadyHave[Toy1.Name].Icon,
            Name = Toy1.Name,
            Parent = DestroyToys,
            ImageRectSize = Vector2.new(90, 90),
            ImageRectOffset = Inventory.Toys.AlreadyHave[Toy1.Name].RectOffset
        }); Inventory.LayoutOrderToys -= 1; ToyButton.LayoutOrder = Inventory.LayoutOrderToys
        ConnName += 1
        AddConnection(ToyButton.MouseButton1Click, function()
            PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Trash:Play()
            DestroyToy:FireServer(Toy1)
            task.delay(0.1, function()
                ToyButton:Destroy()
            end)
            RemoveConnection("ConnectionRemoving"..tostring(ConnName))
            RemoveConnection("ConnectionDelete"..tostring(ConnName))
        end, "ConnectionRemoving"..tostring(ConnName))
        AddConnection(Toy1.Destroying, function()
            ToyButton:Destroy()
            RemoveConnection("ConnectionRemoving"..tostring(ConnName))
            RemoveConnection("ConnectionDelete"..tostring(ConnName))
        end, "ConnectionRemoving"..tostring(ConnName))
    end)
    AddConnection(LocalPlayer.UsedToyPoints.Changed, function(Value)
        SpaceUsedText.Text = tostring(Value).."/"..tostring(LocalPlayer.ToysLimitCap.Value)
        PlayTween(SpaceUsedBar, {0.6, Enum.EasingStyle.Quint}, {
            Size = UDim2.new(0, (SpaceUsedBar.Parent.AbsoluteSize.X / LocalPlayer.ToysLimitCap.Value) * Value, 1, 0)
        })
        PlayTween(SpaceUsedBar, {0.6, Enum.EasingStyle.Linear}, {
            BackgroundColor3 = Color3.fromHSV(0.333 * (1 - (Value / LocalPlayer.ToysLimitCap.Value)), 1, 1)
        })
        if Value ~= 0 then
            SpaceUsedBar.Transparency = 0.2
        else
            while SpaceUsedBar.Parent.AbsoluteSize.X > 1 do task.wait() end
            SpaceUsedBar.Transparency = 1
        end
    end)
    local UsedValue = LocalPlayer.UsedToyPoints.Value; if UsedValue ~= 0 then
        SpaceUsedBar.Transparency = 0.2
        SpaceUsedText.Text = tostring(UsedValue).."/"..tostring(LocalPlayer.ToysLimitCap.Value)
        PlayTween(SpaceUsedBar, {0.6, Enum.EasingStyle.Quint}, {
            Size = UDim2.new(0, ((SpaceUsedBar.Parent.AbsoluteSize.X / LocalPlayer.ToysLimitCap.Value) * UsedValue) + 10, 1, 0)
        })
        PlayTween(SpaceUsedBar, {0.6, Enum.EasingStyle.Linear}, {
            BackgroundColor3 = Color3.fromHSV(0.333 * (1 - (UsedValue / LocalPlayer.ToysLimitCap.Value)), 1, 1)
        })
    end
    local DataPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
    local FPS, Ping = 999, 0
    local Frames, FPSUpdateTime = 0, tick()
    local CoinsWatermark = CoreGui.InventoryPlusV2.CoinsWatermark
    local TextLabel, ImageLabel = CoinsWatermark.TextLabel, CoinsWatermark.ImageLabel
    game:GetService("RunService").RenderStepped:Connect(function(ping) 
        Ping = DataPing:GetValueString(math.round(2 / ping)):split(" ")[1]
        Frames = Frames + 1
        local last_update = tick()
        if last_update - FPSUpdateTime > 0.3 then
            FPS = math.floor(Frames / (last_update - FPSUpdateTime))
            Frames = 0
            FPSUpdateTime = last_update
        end
    end)
    task.spawn(function() while task.wait(0.5) do
        TextLabel.Text = string.format("Coins: %s\nFPS: %s\nPing: %s", Coins.Text, FPS, math.round(tonumber(Ping)))
        ImageLabel.Visible = tonumber(Ping) >= 300 and true or false
    end end)
end

local function LoadAll()
    local SelectedToy, AlreadySpawned = "", false
    local MainWindow = CoreGui.InventoryPlusV2.MainWindow
    local Container = MainWindow.Container
    local BuyFrame = MainWindow.BuyFrame
    for i, toy in Inventory.Toys.AlreadyHave do
        local SelectedToy = Inventory.Toys.AlreadyHave[i]
        local Toy = SetChildren(CreateElement("ImageButton", {
            BackgroundTransparency = 1,
            Image = SelectedToy.Icon,
            Name = SelectedToy.Name,
            Parent = Container["Your Toys"],
            ImageRectSize = Vector2.new(90, 90),
            ImageRectOffset = SelectedToy.RectOffset,
            LayoutOrder = SelectedToy.Order
        }), {
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)}),
            CreateElement("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 2,
                Transparency = 1
            })
        })
        Inventory.Toys.RealToys[#Inventory.Toys.RealToys+1] = Toy
        if Toy.LayoutOrder <= 1000000 or Inventory.Toys.FavoriteToys[Toy.LayoutOrder] then
            SetChildren(CreateElement("ImageLabel", {
                Name = "Favorite",
                Parent = Toy,
                Size = UDim2.new(0.7, 0, 0.7, 0),
                Position = UDim2.new(0.3, 0, 0.3, 0),
                Image = "rbxassetid://10045503805",
                BackgroundTransparency = 1
            }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})})
            Toy.LayoutOrder = Toy.LayoutOrder - 1000000
        end
        AddConnection(Toy.MouseEnter, function() 
            PlayTween(Toy, {0.1, Enum.EasingStyle.Quint}, {
                ImageRectSize = Vector2.new(85, 85),
                ImageRectOffset = SelectedToy.RectOffset + Vector2.new(2.5, 2.5)
            }) 
            PlayTween(Toy.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 0.8})
        end)
        AddConnection(Toy.MouseLeave, function() 
            PlayTween(Toy, {0.1, Enum.EasingStyle.Quint}, {
                ImageRectSize = Vector2.new(90, 90),
                ImageRectOffset = SelectedToy.RectOffset
            }) 
            PlayTween(Toy.UIStroke, {0.3, Enum.EasingStyle.Quint}, {Transparency = 1})
        end)  
        AddConnection(Toy.MouseButton1Down, function()
            if Inventory.SelectingFavorites then
                if Toy:FindFirstChild("Favorite") then
                    Toy.Favorite:Destroy()
                    PlaySound("UnFavorite")
                    Inventory.Toys.FavoriteToys[Toy.LayoutOrder+1000000] = nil
                    while Inventory.SelectingFavorites do task.wait() end
                    Toy.LayoutOrder = Toy.LayoutOrder + 1000000
                    return
                end
                SetChildren(CreateElement("ImageLabel", {
                    Name = "Favorite",
                    Parent = Toy,
                    Size = UDim2.new(0.7, 0, 0.7, 0),
                    Position = UDim2.new(0.3, 0, 0.3, 0),
                    Image = "rbxassetid://10045503805",
                    BackgroundTransparency = 1
                }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})})
                Inventory.Toys.FavoriteToys[Toy.LayoutOrder] = Toy.Name
                PlaySound("Favorite")
                while Inventory.SelectingFavorites do task.wait() end
                Toy.LayoutOrder = Toy.LayoutOrder - 1000000
                return
            end
            PlaySound("Open")
            local Character = LocalPlayer.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local Camera = workspace.CurrentCamera
            task.spawn(function()
                if AlreadySpawned then return end
                AlreadySpawned = true
                while LocalPlayer.CanSpawnToy.Value do task.wait() end
                PlayTween(MainWindow, 0.05, {Transparency = Inventory.Settings.UI.MainTransparency * 1.4})
                while not LocalPlayer.CanSpawnToy.Value do task.wait() end
                PlayTween(MainWindow, 0.05, {Transparency = Inventory.Settings.UI.MainTransparency})
                AlreadySpawned = false
            end)
            task.spawn(SpawnToyRemoteFunction.InvokeServer, SpawnToyRemoteFunction, Toy.Name, Camera.CFrame, Root and Root.Rotation or Vector3.zero)
        end)
        if SelectedToy.IsDecoy == true then
            local Clone = SelectedToy.RealToy.ViewItemButton.ViewportFrame:Clone()
            Clone.Parent = Toy
        end
    end
    for i, toy in Inventory.Toys.ToBuy do
        local SelectedToy = Inventory.Toys.ToBuy[i]
        local Toy = SetChildren(CreateElement("ImageButton", {
            BackgroundTransparency = 1,
            Image = SelectedToy.Icon,
            Name = SelectedToy.Name,
            Parent = Container["Shop"],
            ImageRectSize = Vector2.new(90, 90),
            ImageRectOffset = SelectedToy.RectOffset,
            ImageColor3 = SelectedToy.IconColor,
        }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})})
        local CoinsPrice = SelectedToy.RealToy.ViewItemButton.CoinsPrice:Clone()
        CoinsPrice.Parent = Toy
        if SelectedToy.IsDecoy == true then
            local Clone = SelectedToy.RealToy.ViewItemButton.ViewportFrame:Clone()
            Clone.Parent = Toy
        end
        AddConnection(Toy.MouseButton1Click, function()
            for _, frame in MainWindow:GetChildren() do
                if frame.Name == "TabHolder" then continue end
                if not frame:IsA("Frame") then continue end
                frame.Visible = false
                Inventory.InvisibleFrames[#Inventory.InvisibleFrames+1] = frame
            end
            BuyFrame.Visible = true
            BuyFrame.ToyImage.Image = SelectedToy.Icon
            BuyFrame.ToyImage.ImageRectOffset = SelectedToy.RectOffset
            BuyFrame.ToyImage.ImageRectSize = Vector2.new(90, 90)
            BuyFrame.ToyName.Text = SelectedToy.Name
            BuyFrame.ToyDescription.Text = SelectedToy.ToyDescription
            Inventory.CurrentShopToy = Toy.Name
            if table.find(Inventory.Toys.AlreadyHave, Toy.Name) then
                BuyFrame.Buy.BackgroundColor3 = Color3.fromRGB(20, 115, 240)
                BuyFrame.Buy.Text = "Buy"
            else
                BuyFrame.Buy.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                BuyFrame.Buy.Text = "View"
            end
        end)
    end
    for i, toy in Inventory.Toys.Spawned do
        local SelectedToy = Inventory.Toys.Spawned[i]
        local RandomConnName = tostring(math.random(10, 1000000))
        local Toy = SetChildren(CreateElement("ImageButton", {
            BackgroundTransparency = 1,
            Image = SelectedToy.Icon,
            Name = SelectedToy.Name,
            Parent = Container["Destroy Toys"],
            ImageRectSize = Vector2.new(90, 90),
            ImageRectOffset = SelectedToy.RectOffset,
            ImageColor3 = SelectedToy.IconColor,
        }), {CreateElement("UICorner", {CornerRadius = UDim.new(0, 10)})})
        if SelectedToy.IsDecoy == true then
            local Clone = SelectedToy.RealToy.ViewItemButton.ViewportFrame:Clone()
            Clone.Parent = Toy
        end
        AddConnection(Toy.MouseButton1Click, function()
            PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Trash:Play()
            DestroyToy:FireServer(SpawnedInToys:FindFirstChild(SelectedToy.RealToy.Name))
            task.delay(0.1, function()
                Toy:Destroy()
            end)
            RemoveConnection("ConnectionDelete"..RandomConnName)
            RemoveConnection("ConnectionRemoving"..RandomConnName)
        end, "ConnectionDelete"..RandomConnName)
        AddConnection(Toy.Destroying, function()
            Toy:Destroy()
            RemoveConnection("ConnectionRemoving"..RandomConnName)
            RemoveConnection("ConnectionRemoving"..RandomConnName)
        end, "ConnectionRemoving"..RandomConnName)
    end
end

CreateMainWindow()
UIWork()
LoadAll()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local function applyNearBlackEffect(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(15, 15, 15)
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
    end
end

local ePressed = false
local ePressTime = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E then
        ePressed = true
        ePressTime = tick()
        task.wait(1)
        if ePressed then
            ePressed = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if ePressed and (tick() - ePressTime) < 1 then
            _G.mySpawn = true
            _G.mySpawnTime = tick()
            ePressed = false
            task.wait(0.5)
            _G.mySpawn = false
        end
    end
end)

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "PalletLightBrown" then
        task.wait(0.1)
        if _G.mySpawn and (tick() - _G.mySpawnTime) < 0.6 then
            applyNearBlackEffect(descendant)
        end
    end
end)

local oceanFolder = workspace:FindFirstChild("Map")
    and workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
    and workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean")

local function destroyOceans(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == "Ocean" then
            child:Destroy()
        elseif #child:GetChildren() > 0 then
            destroyOceans(child)
        end
    end
end

if oceanFolder then
    destroyOceans(oceanFolder)
end
		
