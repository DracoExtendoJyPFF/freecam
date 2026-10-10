local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

local freecam = {
    enabled = false,
    pos = Vector3.new(),
    yaw = 0,
    pitch = 0,
    targetYaw = 0,
    targetPitch = 0,
    speed = 40,
    sprintSpeed = 95,
    sensitivity = 1,
    smoothness = 0.14,
    oldMouseBehavior = Enum.MouseBehavior.Default,
}

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function getCameraAngles()
    local look = camera.CFrame.LookVector
    local yaw = math.atan2(look.X, look.Z)
    local pitch = math.asin(clamp(look.Y, -1, 1))
    return yaw, pitch
end

local function setMouseBehavior(enabled)
    if enabled then
        freecam.oldMouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = freecam.oldMouseBehavior
    end
end

local function toggleFreecam()
    if freecam.enabled then
        freecam.enabled = false
        camera.CameraType = Enum.CameraType.Custom
        setMouseBehavior(false)
        return
    end

    freecam.enabled = true
    freecam.pos = camera.CFrame.Position
    freecam.yaw, freecam.pitch = getCameraAngles()
    freecam.targetYaw = freecam.yaw
    freecam.targetPitch = freecam.pitch
    camera.CameraType = Enum.CameraType.Scriptable
    setMouseBehavior(true)
end

local function updateFreecam(dt)
    if not freecam.enabled then
        return
    end

    freecam.yaw = freecam.yaw + (freecam.targetYaw - freecam.yaw) * freecam.smoothness
    freecam.pitch = freecam.pitch + (freecam.targetPitch - freecam.pitch) * freecam.smoothness

    local moveX, moveY, moveZ = 0, 0, 0

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

    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = Vector3.new(0, 1, 0)

    local moveVector = (forward * moveZ) + (right * moveX) + (up * moveY)

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * speed * dt
        freecam.pos = freecam.pos + moveVector
    end

    local camCFrame = CFrame.new(freecam.pos) * CFrame.Angles(freecam.pitch, freecam.yaw, 0)
    camera.CFrame = camCFrame
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F3 then
        toggleFreecam()
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed or not freecam.enabled then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        freecam.targetYaw = freecam.targetYaw - (delta.X * 0.0027 * freecam.sensitivity)
        freecam.targetPitch = clamp(freecam.targetPitch - (delta.Y * 0.0019 * freecam.sensitivity), -1.55, 1.55)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    updateFreecam(dt)
end)

print("Smooth Berry Avenue style freecam loaded")
print("Toggle: RightShift / F3 | Move: W A S D | Ascend: Space | Descend: LeftControl | Sprint: LeftShift")
