local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

local freecam = {
    enabled = false,
    speed = 40,
    sprintSpeed = 90,
    sensitivity = 1,
    smoothing = 0.18,
    pos = Vector3.new(),
    yaw = 0,
    pitch = 0,
    targetYaw = 0,
    targetPitch = 0,
    lastTick = tick(),
}

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function getLookAngles()
    local look = camera.CFrame.LookVector
    local yaw = math.atan2(look.X, look.Z)
    local pitch = math.asin(clamp(look.Y, -1, 1))
    return yaw, pitch
end

local function updateFreecam()
    if not freecam.enabled then
        return
    end

    local dt = math.max(0.016, tick() - freecam.lastTick)
    freecam.lastTick = tick()

    freecam.yaw = freecam.yaw + (freecam.targetYaw - freecam.yaw) * freecam.smoothing
    freecam.pitch = freecam.pitch + (freecam.targetPitch - freecam.pitch) * freecam.smoothing

    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = Vector3.new(0, 1, 0)

    local moveX = 0
    local moveY = 0
    local moveZ = 0

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveZ += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveZ -= 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveX -= 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveX += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveY += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveY -= 1 end

    local speed = freecam.speed
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        speed = freecam.sprintSpeed
    end

    local moveVec = ((forward * moveZ) + (right * moveX) + (up * moveY))
    if moveVec.Magnitude > 0 then
        moveVec = moveVec.Unit * speed * dt
        freecam.pos = freecam.pos + moveVec
    end

    local camCFrame = CFrame.new(freecam.pos) * CFrame.Angles(freecam.pitch, freecam.yaw, 0)
    camera.CFrame = camCFrame
end

local function toggleFreecam()
    if freecam.enabled then
        freecam.enabled = false
        camera.CameraType = Enum.CameraType.Custom
        return
    end

    freecam.enabled = true
    freecam.pos = camera.CFrame.Position
    freecam.yaw, freecam.pitch = getLookAngles()
    freecam.targetYaw = freecam.yaw
    freecam.targetPitch = freecam.pitch
    camera.CameraType = Enum.CameraType.Scriptable
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F3 then
        toggleFreecam()
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed or not freecam.enabled then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        freecam.targetYaw = freecam.targetYaw - (delta.X * 0.0025 * freecam.sensitivity)
        freecam.targetPitch = clamp(freecam.targetPitch - (delta.Y * 0.0018 * freecam.sensitivity), -1.55, 1.55)
    end
end)

RunService.RenderStepped:Connect(function()
    if freecam.enabled then
        updateFreecam()
    end
end)

local function controlSetup()
    freecam.pos = camera.CFrame.Position
    freecam.yaw, freecam.pitch = getLookAngles()
    freecam.targetYaw = freecam.yaw
    freecam.targetPitch = freecam.pitch
end

controlSetup()

print("Berry Avenue-style freecam loaded. Toggle with RightShift or F3.")
print("Move: W A S D, Space / LeftControl, Sprint: LeftShift")
