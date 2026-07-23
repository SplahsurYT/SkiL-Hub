local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character
local Humanoid
local RootPart

local Flying = false

local FlyAttachment
local FlyVelocity
local FlyOrientation

local FlySpeed = 70
local Acceleration = 12

local CurrentVelocity = Vector3.zero

local Input = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	Up = false,
	Down = false
}

local function LoadCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
end

LoadCharacter(Player.Character or Player.CharacterAdded:Wait())

Player.CharacterAdded:Connect(function(char)
	LoadCharacter(char)

	if Flying then
		task.wait(.5)
		StartFly()
	end
end)


function StartFly()
	if Flying or not RootPart then
		return
	end

	Flying = true

	Humanoid.PlatformStand = true

	FlyAttachment = Instance.new("Attachment")
	FlyAttachment.Name = "FlightAttachment"
	FlyAttachment.Parent = RootPart


	FlyVelocity = Instance.new("LinearVelocity")
	FlyVelocity.Name = "FlightVelocity"
	FlyVelocity.Attachment0 = FlyAttachment
	FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVelocity.MaxForce = math.huge
	FlyVelocity.VectorVelocity = Vector3.zero
	FlyVelocity.Parent = RootPart


	FlyOrientation = Instance.new("AlignOrientation")
	FlyOrientation.Name = "FlightRotation"
	FlyOrientation.Attachment0 = FlyAttachment
	FlyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	FlyOrientation.MaxTorque = math.huge
	FlyOrientation.Responsiveness = 15
	FlyOrientation.Parent = RootPart
end


function StopFly()
	Flying = false
	CurrentVelocity = Vector3.zero

	if Humanoid then
		Humanoid.PlatformStand = false
	end

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyOrientation then
		FlyOrientation:Destroy()
		FlyOrientation = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end
end


local Keybinds = {
	[Enum.KeyCode.W] = "Forward",
	[Enum.KeyCode.S] = "Backward",
	[Enum.KeyCode.A] = "Left",
	[Enum.KeyCode.D] = "Right",
	[Enum.KeyCode.Space] = "Up",
	[Enum.KeyCode.LeftControl] = "Down"
}


UserInputService.InputBegan:Connect(function(key, processed)
	if processed then
		return
	end

	local action = Keybinds[key.KeyCode]

	if action then
		Input[action] = true
	end
end)


UserInputService.InputEnded:Connect(function(key)
	local action = Keybinds[key.KeyCode]

	if action then
		Input[action] = false
	end
end)



RunService.RenderStepped:Connect(function(dt)

	if not Flying or not RootPart or not FlyVelocity then
		return
	end


	local camCF = Camera.CFrame

	local direction = Vector3.zero


	if Input.Forward then
		direction += camCF.LookVector
	end

	if Input.Backward then
		direction -= camCF.LookVector
	end

	if Input.Right then
		direction += camCF.RightVector
	end

	if Input.Left then
		direction -= camCF.RightVector
	end

	if Input.Up then
		direction += Vector3.yAxis
	end

	if Input.Down then
		direction -= Vector3.yAxis
	end


	if direction.Magnitude > 0 then
		direction = direction.Unit
	end


	local targetVelocity = direction * FlySpeed

	CurrentVelocity = CurrentVelocity:Lerp(
		targetVelocity,
		math.clamp(dt * Acceleration,0,1)
	)


	FlyVelocity.VectorVelocity = CurrentVelocity


	if FlyOrientation then
		FlyOrientation.CFrame = CFrame.lookAt(
			Vector3.zero,
			camCF.LookVector
		)
	end

end)

-- 

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
	name = "SkiL Hub",
	subtitle = "The New Hub",
	configuration = {
		autoSave = true,      -- save on change
		autoLoad = false,      -- load on first open
		fileName = "SkiL Hub",
		customFolder = "MyGame", -- optional
	},
	
})


window:ChangeTheme("cobalt")

local tag = window:CreateTag({
	text = "Beta (1.5)",
	color = Color3.fromRGB(255, 175, 15),
})

local Atag = window:CreateTag({
	text = "Working",
	color = Color3.fromRGB(52, 148, 0),
})

local Maintab = window:CreateTab({ name = "Main", icon = 93364949241311 })
local ESPtab = window:CreateTab({ name = "ESP", icon = 77947432622871 })
local Statstab = window:CreateTab({ name = "Stats", icon = 123200632228077 })
local Infotab = window:CreateTab({ name = "Info", icon = 131908375930943 })
local Misctab = window:CreateTab({ name = "Misc", icon = 131908375930943 })

Maintab:CreateSection({ name = "Fly", icon = 100241515849419 })

local Fly = Maintab:CreateToggle({
	name = "Fly",
	flag = "Fly",
	icon = 11433568090,
	value = false,
	callback = function(value)
		if value then
			StartFly()

			window:Toast({
				title = "Fly Activé",
				icon = 11433568090,
			})
		else
			StopFly()

			window:Toast({
				title = "Fly Désactivé",
				icon = 11433568090,
			})
		end
	end,
})

Maintab:CreateSlider({
	name = "Fly Speed",
	range = {10, 250},
	increment = 5,
	value = 50,
	suffix = " Speed",
	callback = function(value)
		FlySpeed = value
	end,
})

Maintab:CreateSection({
	name = "WalkSpeed",
	icon = 100241515849419
})

local WalkSpeedEnabled = false
local WalkSpeedValue = 50

local function SetWalkSpeed()
	local Character = game.Players.LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		if WalkSpeedEnabled then
			Humanoid.WalkSpeed = WalkSpeedValue
		else
			Humanoid.WalkSpeed = 16
		end
	end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

	if WalkSpeedEnabled then
		Humanoid.WalkSpeed = WalkSpeedValue
	end
end)


Maintab:CreateToggle({
	name = "Walk Speed",
	flag = "WalkSpeed",
	icon = 104340352139654,
	value = false,

	callback = function(value)
		WalkSpeedEnabled = value

		SetWalkSpeed()

		if value then
			window:Toast({
				title = "WalkSpeed Activé",
				icon = 104340352139654,
			})
		else
			window:Toast({
				title = "WalkSpeed Désactivé",
				icon = 104340352139654,
			})
		end
	end,
})


Maintab:CreateSlider({
	name = "Walk Speed",
	range = {10, 250},
	increment = 5,
	value = 50,
	suffix = " Speed",

	callback = function(value)
		WalkSpeedValue = value

		if WalkSpeedEnabled then
			SetWalkSpeed()
		end
	end,
})

Maintab:CreateSection({
	name = "JumpSpeed",
	icon = 100241515849419
})

local JumpSpeedEnabled = false
local JumpValue = 50

local function ApplyJump()
	local Character = game.Players.LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return
	end

	if JumpSpeedEnabled then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = JumpValue
	else
		Humanoid.JumpPower = 50
		Humanoid.JumpHeight = 7.2
	end
end


game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

	task.wait()

	if JumpSpeedEnabled then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = JumpValue
	end
end)


Maintab:CreateToggle({
	name = "Jump Speed",
	flag = "JumpSpeed",
	icon = 89110556049512,
	value = false,

	callback = function(value)
		JumpSpeedEnabled = value

		ApplyJump()

		if value then
			window:Toast({
				title = "JumpSpeed Activé",
				icon = 89110556049512,
			})
		else
			window:Toast({
				title = "JumpSpeed Désactivé",
				icon = 89110556049512,
			})
		end
	end,
})


Maintab:CreateSlider({
	name = "Jump Power",
	range = {10, 250},
	increment = 5,
	value = 50,
	suffix = " Power",

	callback = function(value)
		JumpValue = value

		if JumpSpeedEnabled then
			ApplyJump()
		end
	end,
})

Maintab:CreateSection({ name = "User", icon = 100241515849419 })

local Reset = Maintab:CreateButton({
	name = "Reset character",
	icon = 72394126245022,
	callback = function(value)
		game.Players.LocalPlayer.Character:BreakJoints()
		
		window:Toast({
			title = "Reset character",
			icon = 72394126245022,
		})
	end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local NoclipConnection

local Noclip = Maintab:CreateToggle({
	name = "Noclip",
	flag = "noclip",
	icon = 132368088793521,
	value = false,
	callback = function(value)
		if value then
			NoclipConnection = RunService.Stepped:Connect(function()
				local Character = LocalPlayer.Character
				if Character then
					for _, Part in ipairs(Character:GetDescendants()) do
						if Part:IsA("BasePart") then
							Part.CanCollide = false
						end
					end
				end
			end)

			window:Toast({
				title = "Noclip Activé",
				icon = 132368088793521,
			})
		else
			if NoclipConnection then
				NoclipConnection:Disconnect()
				NoclipConnection = nil
			end

			local Character = LocalPlayer.Character
			if Character then
				for _, Part in ipairs(Character:GetDescendants()) do
					if Part:IsA("BasePart") then
						Part.CanCollide = true
					end
				end
			end

			window:Toast({
				title = "Noclip Désactivé",
				icon = 132368088793521,
			})
		end
	end,
})

Misctab:CreateSection({
	name = "Script Tab",
	icon = 131555145236700
})

local grid = Misctab:CreateGroup()

local left = grid:CreateGroup({
	direction = "column"
})

left:CreateButton({
	name = "Infinite Yield",

	callback = function()
		window:Popup({
			title = "Et tu sur ?",
			content = "SkiL Hub ne se tien pas responsable de l'utilisation de ce script.",
			options = {
				{ text = "Cancel" },
				{ text = "Execute", style = "danger", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end },
			},
		})
	end,
})


left:CreateButton({
	name = "Aimbot",

	callback = function()
		window:Popup({
			title = "Et tu sur ?",
			content = "SkiL Hub ne se tien pas responsable de l'utilisation de ce script.",
			options = {
				{ text = "Non Disponible" },
			},
		})
	end,
})


local right = grid:CreateGroup({
	direction = "column"
})


right:CreateButton({
	name = "Dex Explorer",

	callback = function()
		window:Popup({
			title = "Et tu sur ?",
			content = "SkiL Hub ne se tien pas responsable de l'utilisation de ce script.",
			options = {
				{ text = "Cancel" },
				{ text = "Execute", style = "danger", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end },
			},
		})
	end,
})


right:CreateButton({
	name = "Fling",

	callback = function()
		window:Popup({
			title = "Et tu sur ?",
			content = "SkiL Hub ne se tien pas responsable de l'utilisation de ce script.",
			options = {
				{ text = "Cancel" },
				{ text = "Execute", style = "danger", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/lucasilva864/fling-all/refs/heads/main/fling%20all"))() end },
			},
		})
	end,
})

Misctab:CreateSection({
	name = "Adonis Bypass",
	icon = 131908375930943
})

local BypassCount = window:Get("AdonisCompte") or 0

--[[
local BypassCompte = Misctab:CreateStat({
    name = "Bypass",
    prefix = "",
    value = BypassCount,
})

local adonis = Misctab:CreateToggle({
	name = "Adonis Bypass",
	flag = "adonisbypass",
	value = false,
	callback = function(value)

		if value then
			local success, err = pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/e1998ee/adonisb1p3ss/refs/heads/main/NeptuneScripts"))()
				BypassCompte:Set(BypassCompte.value + 1)
			end)

			if not success then
				warn(err)
			end
		end

	end,
})

]]

Misctab:CreateButton({
    name = "Adonis Bypass",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/e1998ee/adonisb1p3ss/refs/heads/main/NeptuneScripts"))()

        BypassCount += 1
        BypassCompte:Set(BypassCount)

        window:Set("AdonisCompte", BypassCount)
        window:Save()
    end,
})

local FlyTime = Statstab:CreateStat({
	name = "Fly Time",
	prefix = "",
	value = 0,
})

local WalkSpeedSeconds = 0

local WalkSpeedTime = Statstab:CreateStat({
	name = "Walk Speed Time",
	prefix = "",
	value = WalkSpeedSeconds,
})

local JumperSpeedTime = Statstab:CreateStat({
	name = "JumpeSpeed Time",
	prefix = "",
	value = 0,
})

task.spawn(function()
	while true do
		task.wait(1)

		if window.Flags.Fly then
			FlyTime:Set(FlyTime.value + 1)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(1)

		if window.Flags.WalkSpeed then
			WalkSpeedTime:Set(WalkSpeedTime.value + 1)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(1)

		if window.Flags.JumpSpeed then
			JumperSpeedTime:Set(JumperSpeedTime.value + 1)
		end
	end
end)

local exeName = (identifyexecutor and identifyexecutor()) or (getgenv().identifyexecutor and getgenv().identifyexecutor()) or "Unknown"

Infotab:CreateSection({ name = "Info Général", icon = 93364949241311 })

local playerCount = #game:GetService("Players"):GetPlayers()
local InfoGrid = Infotab:CreateGroup()

local left = InfoGrid:CreateGroup({ direction = "column" })
local ExePlayer = left:CreateStat({
    name = "Executor",
	compact = true,
    prefix = "",
    value = exeName,
})

local right = InfoGrid:CreateGroup({ direction = "column" })
local ServeurPlayer = right:CreateStat({
    name = "Players",
    compact = true,
    prefix = "",
    value = playerCount,
})
