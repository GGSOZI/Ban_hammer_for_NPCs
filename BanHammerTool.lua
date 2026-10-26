wait(0.2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Mouse = Player:GetMouse()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")
local IS_R15 = Humanoid.RigType == Enum.HumanoidRigType.R15
local ANIMATE = Character:FindFirstChild("Animate")

local Animation_Speed = 3
local Frame_Speed = 1 / 60
local EquippedSpeed = 23
local PLAY_MUSIC = true
local MUSIC_ID = "rbxassetid://462506896"
local ACTION_NAME = "BanHammerSlam"
local BUTTON_POSITION = UDim2.new(0.5, 0, 0.1, 0)

local R15_GRIP_POS = Vector3.new(0, 1.2, 0)
local R15_SWING_DELAY = 0.3
local R15_RECOVER_TIME = 0.35

local SLAM_SLOWDOWN = 1.6
local CHARGE_TIME = 0.45
local SlamAS = Animation_Speed * SLAM_SLOWDOWN

local WHOOSH_ID = "138158731526545"
local HIT_SOUND_IDS = {"12222152", "12221944", "12222140", "71640557500285"}
local PLINK_ID = "70447807886059"
local OLD_IMPACT_SOUND = false

local HIT_FORWARD = 6
local HIT_RADIUS = 14
local MAX_TARGETS = 15
local SPIN_TIME = 1
local SPIN_REVS = Vector3.new(3, 4, 2)
local FALL_TIME = 0.18
local VOID_DISTANCE = 3000
local OWNERSHIP_CHECK = false
local OWNER_AGE_LIMIT = 0.1
local HOP_HEIGHT = 2.5
local HOP_TIME = 0.08
local SIM_RADIUS = 100
local FLING_SPEED = 700
local FLING_TIME = 2
local FLING_UP = 0.35

local SHOCKWAVE = true
local CHUNK_RINGS = {{0.22, 7}, {0.46, 11}, {0.72, 15}, {0.92, 19}}
local FLY_CHANCE = 0.45
local PEBBLES = 16
local WAVE_SPEED = 45
local BROKEN_STAY = 6
local CRACKS = 10

local STAR_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local STAR_SIZE = 9
local CAMERA_SHAKE = true

local IT, CF, VT = Instance.new, CFrame.new, Vector3.new
local RAD, ANGLES = math.rad, CFrame.Angles
local COS, SIN, ACOS = math.cos, math.sin, math.acos
local C3, BRICKC = Color3.new, BrickColor.new

local Real, HandPart, TorsoPart = {}, nil, nil
if IS_R15 then

	TorsoPart = Character:WaitForChild("UpperTorso")
	HandPart = Character:WaitForChild("RightHand")
else
	TorsoPart = Character:WaitForChild("Torso")
	Real.Root = RootPart:WaitForChild("RootJoint")
	Real.Neck = TorsoPart:WaitForChild("Neck")
	Real.RS = TorsoPart:WaitForChild("Right Shoulder")
	Real.LS = TorsoPart:WaitForChild("Left Shoulder")
	Real.RH = TorsoPart:WaitForChild("Right Hip")
	Real.LH = TorsoPart:WaitForChild("Left Hip")
	HandPart = Character:WaitForChild("Right Arm")
end

local RestReal = {}
for name, j in pairs(Real) do
	RestReal[name] = {C0 = j.C0, C1 = j.C1}
end

local ROOTC0 = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0 = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0 = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))
local NECKC1 = CF(0, -0.5, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))

local R6REST = {
	Root = {C0 = ROOTC0, C1 = ROOTC0},
	Neck = {C0 = NECKC0, C1 = NECKC1},
	RS = {C0 = CF(1, 0.5, 0) * ANGLES(0, RAD(90), 0), C1 = CF(-0.5, 0.5, 0) * ANGLES(0, RAD(90), 0)},
	LS = {C0 = CF(-1, 0.5, 0) * ANGLES(0, RAD(-90), 0), C1 = CF(0.5, 0.5, 0) * ANGLES(0, RAD(-90), 0)},
	RH = {C0 = CF(1, -1, 0) * ANGLES(0, RAD(90), 0), C1 = CF(0.5, 1, 0) * ANGLES(0, RAD(90), 0)},
	LH = {C0 = CF(-1, -1, 0) * ANGLES(0, RAD(-90), 0), C1 = CF(-0.5, 1, 0) * ANGLES(0, RAD(-90), 0)},
}

local J = {}
local HW
local function ResetVirtual()
	for k, v in pairs(R6REST) do
		J[k] = {C0 = v.C0, C1 = v.C1}
	end
	HW = CF(0, -0.8, 0) * ANGLES(RAD(-90), 0, 0)
end
ResetVirtual()

local ATTACK = false
local EQUIPPED = false
local HOLD = false
local SINE = 0
local CHANGE = 2 / Animation_Speed
local ANIM = "Idle"
local SlamToken = 0
local BoostFrames = 0
local Bst = 1

local ArtificialHB = IT("BindableEvent")
local tf = 0
RunService.Heartbeat:Connect(function(s)
	tf = tf + s
	if tf >= Frame_Speed then
		for i = 1, math.floor(tf / Frame_Speed) do
			ArtificialHB:Fire()
		end
		tf = tf - Frame_Speed * math.floor(tf / Frame_Speed)
	end
end)

local function Swait(n)
	if n == nil or n == 0 then
		ArtificialHB.Event:Wait()
	else
		for i = 1, n do ArtificialHB.Event:Wait() end
	end
end

local function QuaternionFromCFrame(cf)
	local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components()
	local trace = m00 + m11 + m22
	if trace > 0 then
		local s = math.sqrt(1 + trace)
		local recip = 0.5 / s
		return (m21 - m12) * recip, (m02 - m20) * recip, (m10 - m01) * recip, s * 0.5
	else
		local i = 0
		if m11 > m00 then i = 1 end
		if m22 > (i == 0 and m00 or m11) then i = 2 end
		if i == 0 then
			local s = math.sqrt(m00 - m11 - m22 + 1)
			local recip = 0.5 / s
			return 0.5 * s, (m10 + m01) * recip, (m20 + m02) * recip, (m21 - m12) * recip
		elseif i == 1 then
			local s = math.sqrt(m11 - m22 - m00 + 1)
			local recip = 0.5 / s
			return (m01 + m10) * recip, 0.5 * s, (m21 + m12) * recip, (m02 - m20) * recip
		else
			local s = math.sqrt(m22 - m00 - m11 + 1)
			local recip = 0.5 / s
			return (m02 + m20) * recip, (m12 + m21) * recip, 0.5 * s, (m10 - m01) * recip
		end
	end
end

local function QuaternionToCFrame(px, py, pz, x, y, z, w)
	local xs, ys, zs = x + x, y + y, z + z
	local wx, wy, wz = w * xs, w * ys, w * zs
	local xx, xy, xz = x * xs, x * ys, x * zs
	local yy, yz, zz = y * ys, y * zs, z * zs
	return CFrame.new(px, py, pz, 1 - (yy + zz), xy - wz, xz + wy, xy + wz, 1 - (xx + zz), yz - wx, xz - wy, yz + wx, 1 - (xx + yy))
end

local function QuaternionSlerp(a, b, t)
	local cosTheta = a[1] * b[1] + a[2] * b[2] + a[3] * b[3] + a[4] * b[4]
	local startInterp, finishInterp
	if cosTheta >= 0.0001 then
		if (1 - cosTheta) > 0.0001 then
			local theta = ACOS(cosTheta)
			local invSinTheta = 1 / SIN(theta)
			startInterp = SIN((1 - t) * theta) * invSinTheta
			finishInterp = SIN(t * theta) * invSinTheta
		else
			startInterp, finishInterp = 1 - t, t
		end
	else
		if (1 + cosTheta) > 0.0001 then
			local theta = ACOS(-cosTheta)
			local invSinTheta = 1 / SIN(theta)
			startInterp = SIN((t - 1) * theta) * invSinTheta
			finishInterp = SIN(t * theta) * invSinTheta
		else
			startInterp, finishInterp = t - 1, t
		end
	end
	return a[1] * startInterp + b[1] * finishInterp, a[2] * startInterp + b[2] * finishInterp, a[3] * startInterp + b[3] * finishInterp, a[4] * startInterp + b[4] * finishInterp
end

local function Clerp(a, b, t)
	local qa = {QuaternionFromCFrame(a)}
	local qb = {QuaternionFromCFrame(b)}
	local _t = 1 - t
	return QuaternionToCFrame(_t * a.x + t * b.x, _t * a.y + t * b.y, _t * a.z + t * b.z, QuaternionSlerp(qa, qb, t))
end

local function CreateSound(ID, PARENT, VOLUME, PITCH)
	task.spawn(function()
		local s = IT("Sound")
		s.Volume = VOLUME
		s.Pitch = PITCH
		s.SoundId = "http://www.roblox.com/asset/?id=" .. ID
		s.Parent = PARENT
		Swait()
		s:Play()
		Debris:AddItem(s, 10)
	end)
end

local function SetC0(name, target, spd)
	J[name].C0 = Clerp(J[name].C0, target, math.min(1, spd * Bst / Animation_Speed))
end
local function SetC1(name, target, spd)
	J[name].C1 = Clerp(J[name].C1, target, math.min(1, spd * Bst / Animation_Speed))
end
local function SetHW(target, spd)
	HW = Clerp(HW, target, math.min(1, spd * Bst / Animation_Speed))
end

local Weapon = IT("Model")
Weapon.Name = "Ban Hammer Model"

local Tool = IT("Tool")
Tool.Name = "Ban Hammer"
Tool.ToolTip = "Slam button = hold to slam | B = teleport"
Tool.RequiresHandle = IS_R15
Tool.CanBeDropped = false
if IS_R15 then
	Tool.GripPos = R15_GRIP_POS
end
local HandlePart = IT("Part")
HandlePart.Name = "Handle"
HandlePart.Size = VT(0.2, 0.2, 0.2)
HandlePart.Transparency = 0
HandlePart.CanCollide = false
HandlePart.CanTouch = false
HandlePart.Massless = true
HandlePart.Locked = true
HandlePart.Anchored = false
HandlePart.BrickColor = BRICKC("Really black")
HandlePart.Material = Enum.Material.SmoothPlastic
HandlePart.TopSurface, HandlePart.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
HandlePart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
HandlePart.Position = RootPart.Position
HandlePart.Parent = IS_R15 and Tool or Weapon

local HandleMesh = IT("SpecialMesh", HandlePart)
HandleMesh.MeshType = Enum.MeshType.FileMesh
HandleMesh.MeshId = "http://www.roblox.com/asset/?id=10604848"
HandleMesh.TextureId = "http://www.roblox.com/asset/?id=10605252"
HandleMesh.Scale = VT(1, 1, 1)
HandleMesh.Offset = VT(0, 2.7, 0)

local HandleWeld
if not IS_R15 then
	HandleWeld = IT("Weld")
	HandleWeld.Part0 = HandPart
	HandleWeld.Part1 = HandlePart
	HandleWeld.C0 = HW
	HandleWeld.C1 = CF()
	HandleWeld.Parent = HandlePart
end

Tool.Parent = Backpack

local function Apply()
	for name, real in pairs(Real) do
		real.C0 = J[name].C0
		real.C1 = J[name].C1
	end
	HandleWeld.C0 = HW
end

if not IS_R15 then
	RunService.RenderStepped:Connect(function()
		if EQUIPPED then Apply() end
	end)
end

local Effects = IT("Folder")
Effects.Name = "BanHammerEffects"
Effects.Parent = workspace

local function PlaySoundAt(id, parent, volume, speed)
	local s = IT("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = volume or 1
	s.PlaybackSpeed = speed or 1
	s.Parent = parent
	s:Play()
	Debris:AddItem(s, 8)
	return s
end

local function PointPart(pos)
	local p = IT("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = 1
	p.Size = VT(0.2, 0.2, 0.2)
	p.Position = pos
	p.Parent = Effects
	Debris:AddItem(p, 8)
	return p
end

local function StopWhoosh(s)
	if not s or not s.Parent then return end
	TweenService:Create(s, TweenInfo.new(0.12), {Volume = 0}):Play()
	Debris:AddItem(s, 0.2)
end

local lastHitSound
local function PickHitSound()
	local pick
	repeat
		pick = HIT_SOUND_IDS[math.random(#HIT_SOUND_IDS)]
	until pick ~= lastHitSound or #HIT_SOUND_IDS == 1
	lastHitSound = pick
	return pick
end

local function RingEffect(pos, maxSize, thickness)
	local a = PointPart(pos)
	local bb = IT("BillboardGui")
	bb.Size = UDim2.fromScale(1, 1)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = a
	local ring = IT("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.Size = UDim2.fromScale(1, 1)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.Parent = bb
	local corner = IT("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ring
	local stroke = IT("UIStroke")
	stroke.Color = C3(1, 1, 1)
	stroke.Thickness = thickness
	stroke.Parent = ring
	TweenService:Create(bb, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromScale(maxSize, maxSize)}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Thickness = 0, Transparency = 1}):Play()
end

local function SparkBurst(pos, count, size, speed)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = STAR_TEXTURE
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.35, 0.75)
	pe.Speed = NumberRange.new(speed * 0.5, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Drag = 6
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-220, 220)
	pe.LightEmission = 1
	pe.LightInfluence = 0
	pe.Color = ColorSequence.new(C3(1, 1, 1), Color3.fromRGB(150, 210, 255))
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, size),
		NumberSequenceKeypoint.new(1, 0),
	})
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = a
	pe:Emit(count)
end

local function StarPop(pos, size, rotSpeed, rotStart)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = STAR_TEXTURE
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.65)
	pe.Speed = NumberRange.new(0)
	pe.Rotation = NumberRange.new(rotStart - 4, rotStart + 4)
	pe.RotSpeed = NumberRange.new(rotSpeed)
	pe.LightEmission = 1
	pe.LightInfluence = 0
	pe.ZOffset = 1
	pe.Color = ColorSequence.new(C3(1, 1, 1))
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, size * 1.3),
		NumberSequenceKeypoint.new(0.28, size),
		NumberSequenceKeypoint.new(1, 0),
	})
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = a
	pe:Emit(1)
end

local function FlashBall(pos, startSize, endSize, time)
	local p = IT("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = C3(1, 1, 1)
	p.Size = VT(startSize, startSize, startSize)
	p.Transparency = 0.1
	p.Position = pos
	p.Parent = Effects
	TweenService:Create(p, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = VT(endSize, endSize, endSize),
		Transparency = 1,
	}):Play()
	Debris:AddItem(p, time + 0.1)
end

local function FlashLight(pos)
	local a = PointPart(pos)
	local l = IT("PointLight")
	l.Color = Color3.fromRGB(205, 235, 255)
	l.Brightness = 8
	l.Range = 26
	l.Parent = a
	TweenService:Create(l, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0, Range = 4}):Play()
end

local function PlinkEffect(pos)
	FlashBall(pos, 2, 16, 0.3)
	FlashLight(pos)
	StarPop(pos, STAR_SIZE * 1.3, 40, 0)
	StarPop(pos, STAR_SIZE * 0.8, -70, 45)
	RingEffect(pos, 20, 8)
	task.delay(0.07, function() RingEffect(pos, 13, 5) end)
	task.delay(0.14, function() RingEffect(pos, 8, 3) end)
	SparkBurst(pos, 26, 2.6, 55)
	SparkBurst(pos, 10, 4.5, 16)
end

local function GroundRay(pos)
	local filter = {Character, Effects}
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	for _ = 1, 6 do
		params.FilterDescendantsInstances = filter
		local r = workspace:Raycast(pos, VT(0, -40, 0), params)
		if not r then return nil end
		local inst = r.Instance
		local skip = false
		if not inst:IsA("Terrain") then
			if inst.Transparency >= 1 or not inst.CanCollide or not inst.Anchored then
				skip = true
			else
				local m = inst:FindFirstAncestorOfClass("Model")
				while m do
					if m:FindFirstChildOfClass("Humanoid") then skip = true break end
					m = m:FindFirstAncestorOfClass("Model")
				end
			end
		end
		if not skip then
			local mat = r.Material
			local color
			if inst:IsA("Terrain") then
				color = workspace.Terrain:GetMaterialColor(mat)
			else
				color = inst.Color
			end
			if mat == Enum.Material.Water or mat == Enum.Material.Air then mat = Enum.Material.Slate end
			return {Position = r.Position, Normal = r.Normal, Material = mat, Color = color}
		end
		filter[#filter + 1] = inst
	end
	return nil
end

local function MakeDebris(mat, color, size, cf)
	local p = IT("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Material = mat
	p.Color = color
	p.Size = size
	p.CFrame = cf
	p.Parent = Effects
	return p
end

local function DustPuff(pos, color, count)
	local a = PointPart(pos)
	local pe = IT("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.5, 0.95)
	pe.Speed = NumberRange.new(6, 15)
	pe.SpreadAngle = Vector2.new(40, 40)
	pe.Drag = 3
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-60, 60)
	pe.LightInfluence = 1
	pe.Color = ColorSequence.new(color:Lerp(C3(1, 1, 1), 0.35))
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.5),
		NumberSequenceKeypoint.new(1, 5.5),
	})
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = a
	pe:Emit(count)
end

local function FlatRing(pos, color, endDia, time, delay)
	task.delay(delay, function()
		local p = IT("Part")
		p.Shape = Enum.PartType.Cylinder
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Material = Enum.Material.Neon
		p.Color = color
		p.Size = VT(0.3, 2, 2)
		p.CFrame = CF(pos + VT(0, 0.25, 0)) * ANGLES(0, 0, RAD(90))
		p.Transparency = 0.25
		p.Parent = Effects
		TweenService:Create(p, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = VT(0.15, endDia, endDia),
			Transparency = 1,
		}):Play()
		Debris:AddItem(p, time + 0.1)
	end)
end

local Flying = {}
RunService.RenderStepped:Connect(function(dt)
	if #Flying == 0 then return end
	local grav = workspace.Gravity * 0.6
	for i = #Flying, 1, -1 do
		local f = Flying[i]
		local p = f.part
		if not p.Parent then
			table.remove(Flying, i)
		else
			f.vel = f.vel + VT(0, -grav, 0) * dt
			f.pos = f.pos + f.vel * dt
			f.rot = f.rot * ANGLES(f.av.X * dt, f.av.Y * dt, f.av.Z * dt)
			p.CFrame = CF(f.pos) * f.rot
			if f.vel.Y < 0 and f.pos.Y <= f.groundY + f.size.Y * 0.4 then
				table.remove(Flying, i)
				DustPuff(VT(f.pos.X, f.groundY + 0.3, f.pos.Z), f.color, 3)
				TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = VT(0.05, 0.05, 0.05),
					Transparency = 1,
				}):Play()
				Debris:AddItem(p, 0.4)
			end
		end
	end
end)

local function LaunchChunk(cg, size, dir, hSpeed, vSpeed)
	local p = MakeDebris(cg.Material, cg.Color, size, CF(cg.Position))
	Debris:AddItem(p, 8)
	Flying[#Flying + 1] = {
		part = p,
		pos = cg.Position + VT(0, size.Y / 2, 0),
		vel = dir * hSpeed + VT(0, vSpeed, 0),
		rot = ANGLES(math.random() * 6, math.random() * 6, math.random() * 6),
		av = VT((math.random() - 0.5) * 16, (math.random() - 0.5) * 16, (math.random() - 0.5) * 16),
		groundY = cg.Position.Y,
		size = size,
		color = cg.Color,
	}
end

local function SpawnCracks(center, g)
	for i = 1, CRACKS do
		local a = (i / CRACKS) * math.pi * 2 + (math.random() - 0.5) * 0.5
		local dir = VT(COS(a), 0, SIN(a))
		local len = HIT_RADIUS * (0.55 + math.random() * 0.4)
		local mid = center + dir * (len / 2)
		local cg = GroundRay(mid + VT(0, 4, 0)) or g
		local y = cg.Position.Y + 0.08
		local w = 0.3 + math.random() * 0.25
		local finalCF = CFrame.lookAt(VT(mid.X, y, mid.Z), VT(mid.X, y, mid.Z) + dir)
		local startPos = VT(center.X, y, center.Z) + dir * 0.1
		local p = MakeDebris(cg.Material, cg.Color:Lerp(C3(0, 0, 0), 0.65), VT(w, 0.12, 0.2), CFrame.lookAt(startPos, startPos + dir))
		Debris:AddItem(p, BROKEN_STAY + 3)
		TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = VT(w, 0.12, len),
			CFrame = finalCF,
		}):Play()
		task.delay(BROKEN_STAY + math.random() * 1.2, function()
			if p.Parent then
				TweenService:Create(p, TweenInfo.new(0.8), {Transparency = 1}):Play()
				Debris:AddItem(p, 0.9)
			end
		end)
	end
end

local function SpawnChunks(center, g)
	local R = HIT_RADIUS
	for _, ring in ipairs(CHUNK_RINGS) do
		local frac, n = ring[1], ring[2]
		local flyChance = math.clamp(FLY_CHANCE + (0.5 - frac) * 0.5, 0.1, 0.9)
		local offset = math.random() * math.pi * 2
		for k = 1, n do
			local a = offset + (k / n) * 2 * math.pi + (math.random() - 0.5) * (math.pi / n)
			local rr = R * frac + (math.random() - 0.5) * R * 0.1
			local dir = VT(COS(a), 0, SIN(a))
			local pos = center + dir * rr
			local flies = math.random() < flyChance
			task.delay(rr / WAVE_SPEED, function()
				local cg = GroundRay(pos + VT(0, 4, 0)) or g
				local size = VT(1.4 + math.random() * 2, 0.9 + math.random() * 0.9, 1.4 + math.random() * 2)
				DustPuff(cg.Position + VT(0, 0.3, 0), cg.Color, 3)
				if flies then
					LaunchChunk(cg, size * 0.85, dir, 5 + math.random() * 14, 45 + math.random() * 35 + (1 - frac) * 15)
				else
					local nrm = cg.Normal
					local right = nrm:Cross(dir)
					if right.Magnitude < 0.01 then right = VT(1, 0, 0) end
					local base = CFrame.fromMatrix(cg.Position, right.Unit, nrm)
					local tilt = RAD(math.random(18, 38)) * (math.random(2) == 1 and 1 or -1)
					local final = base * ANGLES(tilt, 0, 0) * ANGLES(0, RAD(math.random(-35, 35)), 0) * CF(0, size.Y * 0.2, 0)
					local p = MakeDebris(cg.Material, cg.Color, size, final * CF(0, -size.Y * 1.2, 0))
					Debris:AddItem(p, BROKEN_STAY + 4)
					TweenService:Create(p, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {CFrame = final}):Play()
					task.delay(BROKEN_STAY + math.random() * 1.5, function()
						if p.Parent then
							TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
								CFrame = final * CF(0, -size.Y * 1.2, 0),
							}):Play()
							Debris:AddItem(p, 0.6)
						end
					end)
				end
			end)
		end
	end

	for _ = 1, PEBBLES do
		local a = math.random() * math.pi * 2
		local rr = R * 0.8 * math.sqrt(math.random())
		local dir = VT(COS(a), 0, SIN(a))
		local pos = center + dir * rr
		task.delay(rr / WAVE_SPEED, function()
			local cg = GroundRay(pos + VT(0, 4, 0)) or g
			local s = 0.35 + math.random() * 0.5
			LaunchChunk(cg, VT(s, s, s), dir, 3 + math.random() * 10, 55 + math.random() * 40)
		end)
	end
end

local function ShockwaveEffect(origin)
	if not SHOCKWAVE then return end
	local g = GroundRay(origin + VT(0, 2, 0))
	if not g then return end
	local center = g.Position
	FlatRing(center, C3(1, 1, 1), HIT_RADIUS * 2.2, 0.5, 0)
	FlatRing(center, g.Color:Lerp(C3(1, 1, 1), 0.5), HIT_RADIUS * 1.6, 0.45, 0.08)
	DustPuff(center + VT(0, 0.5, 0), g.Color, 14)
	SpawnCracks(center, g)
	SpawnChunks(center, g)
end

local function Shake(intensity, duration)
	if not CAMERA_SHAKE then return end
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < duration and Humanoid.Parent do
			local k = 1 - (os.clock() - t0) / duration
			Humanoid.CameraOffset = VT((math.random() - 0.5) * intensity * k, (math.random() - 0.5) * intensity * k, 0)
			Swait()
		end
		if Humanoid.Parent then Humanoid.CameraOffset = VT(0, 0, 0) end
	end)
end

local Targeted = setmetatable({}, {__mode = "k"})

local function CenterOf(target)
	if target:IsA("Model") then
		local cf = target:GetBoundingBox()
		return cf.Position
	end
	return target.Position
end

local function CollectParts(target)
	local list, added = {}, {}
	local function add(p)
		if not added[p] then
			added[p] = true
			list[#list + 1] = p
		end
	end
	if target:IsA("BasePart") then
		add(target)
		-- welded / jointed pieces move together with the target, so ghost them too
		local ok, connected = pcall(function() return target:GetConnectedParts(true) end)
		if ok then
			for _, p in ipairs(connected) do add(p) end
		end
	end
	for _, d in ipairs(target:GetDescendants()) do
		if d:IsA("BasePart") then add(d) end
	end
	return list
end

-- true if this part (or anything welded/jointed to it) is an Anchored part
-- that is NOT inside `ownerModel`. Spinning such a thing would drag the map with it.
local function IsPinnedToWorld(part, ownerModel)
	local function outside(p)
		return p.Anchored and not (ownerModel and p:IsDescendantOf(ownerModel))
	end
	if outside(part) then return true end
	local ok, connected = pcall(function() return part:GetConnectedParts(true) end)
	if not ok then return false end
	for _, p in ipairs(connected) do
		if outside(p) then return true end
	end
	return false
end

local function FindTarget(part)
	local m = part:FindFirstAncestorOfClass("Model")
	while m do
		if m:FindFirstChildOfClass("Humanoid") then
			if Players:GetPlayerFromCharacter(m) then return nil end
			if IsPinnedToWorld(part, m) then return nil end
			return m
		end
		local par = m.Parent
		if par and par:IsA("Model") then
			m = par
		else
			m = par and par:FindFirstAncestorOfClass("Model") or nil
		end
	end
	if part.Anchored or IsPinnedToWorld(part, nil) then return nil end
	return part.AssemblyRootPart or part
end

local function SendToVoid(target)
	if Targeted[target] then return end
	Targeted[target] = true
	local parts = CollectParts(target)
	if #parts == 0 then return end

	local origPivot = target:GetPivot()
	local origProps = {}
	for _, p in ipairs(parts) do
		origProps[p] = {CanCollide = p.CanCollide, CanTouch = p.CanTouch}
	end

	local maxAge, ageN, apiYes, apiNo = 0, 0, 0, 0
	local function SampleOwnership()
		for _, p in ipairs(parts) do
			if p.Parent and not p.Anchored then
				if typeof(isnetworkowner) == "function" then
					local ok, res = pcall(isnetworkowner, p)
					if ok then
						if res then apiYes = apiYes + 1 else apiNo = apiNo + 1 end
					end
				end
				if p.ReceiveAge > maxAge then maxAge = p.ReceiveAge end
				ageN = ageN + 1
			end
		end
	end
	local function IsOwned()
		local owned
		if not OWNERSHIP_CHECK then
			owned = true
		elseif apiYes + apiNo > 0 then
			owned = apiYes >= apiNo
		elseif ageN > 0 then
			owned = maxAge < OWNER_AGE_LIMIT
		else
			owned = false
		end
		return owned
	end

	local function Ghost()
		for _, p in ipairs(parts) do
			if p.Parent then

				pcall(function()
					if p:CanSetNetworkOwnership() then
						p:SetNetworkOwner(Player)
					end
				end)
				if not p.Anchored then
					p.AssemblyLinearVelocity = VT(0, 0, 0)
					p.AssemblyAngularVelocity = VT(0, 0, 0)
				end

				if p.CanCollide then p.CanCollide = false end
				if p.CanTouch then p.CanTouch = false end
			end
		end
	end
	Ghost()

	local hum = target:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = true
		hum:ChangeState(Enum.HumanoidStateType.Physics)
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
				tr:Stop(0)
			end
		end
	end

	local center = CenterOf(target)
	local rel = CF(center):Inverse() * target:GetPivot()
	local sx = math.random(2) == 1 and 1 or -1
	local sy = math.random(2) == 1 and 1 or -1
	local sz = math.random(2) == 1 and 1 or -1

	local function KillAndFling()
		local hum2 = target:FindFirstChildOfClass("Humanoid")
		if hum2 then
			hum2.PlatformStand = false
			hum2.Health = 0
			pcall(function() hum2:ChangeState(Enum.HumanoidStateType.Dead) end)
		end
		local dir = (center - RootPart.Position) * VT(1, 0, 1)
		if dir.Magnitude < 0.1 then dir = RootPart.CFrame.LookVector end
		local vel = (dir.Unit + VT(0, FLING_UP, 0)).Unit * FLING_SPEED
		local tumble = VT(math.random(-40, 40), math.random(-40, 40), math.random(-40, 40))
		local started = os.clock()
		local hb
		hb = RunService.Heartbeat:Connect(function()
			if not target.Parent or os.clock() - started > FLING_TIME then
				hb:Disconnect()
				return
			end
			for _, p in ipairs(parts) do
				if p.Parent and not p.Anchored then
					p.CanCollide = false
					p.AssemblyLinearVelocity = vel
					p.AssemblyAngularVelocity = tumble
				end
			end
		end)
	end

	local t0 = os.clock()
	local sentAt
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not target.Parent then
			conn:Disconnect()
			return
		end

		Ghost()

		local t = os.clock() - t0
		local c = center
		local rot
		if t > 0.1 and t < SPIN_TIME then
			SampleOwnership()
		end
		if t < SPIN_TIME then
			local full = 2 * math.pi * ((t / SPIN_TIME) ^ 1.5)
			rot = ANGLES(full * SPIN_REVS.X * sx, full * SPIN_REVS.Y * sy, full * SPIN_REVS.Z * sz)
		else
			rot = CF()
			if not sentAt and not IsOwned() then

				conn:Disconnect()
				target:PivotTo(origPivot)
				for p, v in pairs(origProps) do
					if p.Parent then
						p.CanCollide = v.CanCollide
						p.CanTouch = v.CanTouch
					end
				end
				local h = target:FindFirstChildOfClass("Humanoid")
				if h then
					h.PlatformStand = false
					h:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
				Targeted[target] = nil
				return
			end
			if not sentAt then
				sentAt = os.clock()
				PlaySoundAt(PLINK_ID, PointPart(center), 3, 0.95 + math.random() * 0.15)
				PlinkEffect(center)
				conn:Disconnect()
				target:PivotTo(CF(center) * rel)
				KillAndFling()
				return
			end
		end
		target:PivotTo(CF(c) * rot * rel)
	end)
end

local function SlamImpact()
	if OLD_IMPACT_SOUND then
		CreateSound("147722910", RootPart, 10, 1)
	end
	local origin = (RootPart.CFrame * CF(0, 0, -HIT_FORWARD)).Position

	PlaySoundAt(PickHitSound(), PointPart(origin), 4, 1)
	ShockwaveEffect(origin)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, Effects}
	local found, seen = {}, {}
	for _, part in ipairs(workspace:GetPartBoundsInRadius(origin, HIT_RADIUS, params)) do
		local tgt = FindTarget(part)
		if tgt and not seen[tgt] and not Targeted[tgt] and #found < MAX_TARGETS then
			seen[tgt] = true
			found[#found + 1] = tgt
		end
	end

	Shake(#found > 0 and 1.6 or 1.1, 0.35)
	for _, tgt in ipairs(found) do
		local c = CenterOf(tgt)
		RingEffect(c, 9, 5)
		SparkBurst(c, 14, 1.5, 35)
		SendToVoid(tgt)
	end
end

local function SlamPose(hwY, hwRx, rootZ, rootRx, neckRx, shZ, shRx, hipSpd)
	local spd = 2 / SlamAS
	HW = Clerp(HW, CF(0, hwY, 0) * ANGLES(RAD(hwRx), RAD(-45), 0), spd)
	J.Root.C0 = Clerp(J.Root.C0, ROOTC0 * CF(0, 0, rootZ) * ANGLES(RAD(rootRx), 0, 0), spd)
	J.Neck.C0 = Clerp(J.Neck.C0, NECKC0 * ANGLES(RAD(neckRx), 0, 0), spd)
	J.RS.C0 = Clerp(J.RS.C0, CF(1, 0.5, shZ) * ANGLES(RAD(shRx), 0, RAD(-45)) * RIGHTSHOULDERC0, spd)
	J.LS.C0 = Clerp(J.LS.C0, CF(-1, 0.5, shZ) * ANGLES(RAD(shRx), 0, RAD(45)) * LEFTSHOULDERC0, spd)
	local h = hipSpd / SlamAS
	J.RH.C0 = Clerp(J.RH.C0, CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-8), 0, RAD(25)), h)
	J.LH.C0 = Clerp(J.LH.C0, CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-8), 0, RAD(25)), h)
end

local function Phase(dur, fn, cancelled)
	for i = 0, dur, 0.1 / SlamAS do
		Swait()
		if cancelled() then return false end
		fn()
	end
	return true
end

local function WaitSec(sec, cancelled)
	local t0 = os.clock()
	while os.clock() - t0 < sec do
		Swait()
		if cancelled() then return false end
	end
	return true
end
local function BANSLAM()
	if ATTACK or not EQUIPPED then return end
	ATTACK = true
	local token = SlamToken
	local whoosh
	local function cancelled()
		local c = token ~= SlamToken or not EQUIPPED
		if c and whoosh then
			StopWhoosh(whoosh)
			whoosh = nil
		end
		return c
	end

	if IS_R15 then
		repeat
			whoosh = PlaySoundAt(WHOOSH_ID, RootPart, 2, 1)
			local swing = IT("StringValue")
			swing.Name = "toolanim"
			swing.Value = "Slash"
			swing.Parent = Tool
			if not WaitSec(R15_SWING_DELAY, cancelled) then return end
			StopWhoosh(whoosh)
			whoosh = nil
			SlamImpact()
			if not WaitSec(R15_RECOVER_TIME, cancelled) then return end
		until HOLD == false or cancelled()
		if token == SlamToken then
			ATTACK = false
		end
		return
	end
	repeat
		whoosh = PlaySoundAt(WHOOSH_ID, RootPart, 2, 1)
		if not Phase(CHARGE_TIME, function() SlamPose(-0.8, -90, 7, 0, 25, 0.5, 250, 2) end, cancelled) then return end
		if not Phase(0.08, function() SlamPose(-1, -90, 2, 75, -25, -1, 120, 0.5) end, cancelled) then return end
		if not Phase(0.08, function() SlamPose(-1, -70, 2, 75, -25, -1, 60, 0.5) end, cancelled) then return end

		StopWhoosh(whoosh)
		whoosh = nil
		SlamImpact()

		if not Phase(0.1, function() SlamPose(-1, -70, 1.8, 75, -25, -1, 60, 0.5) end, cancelled) then return end
		if HOLD then
			for i = 0, 0.08, 0.1 / SlamAS do
				Swait()
				if cancelled() then return end
				if not HOLD then break end
				SlamPose(-1, -90, 2, 75, -25, -1, 120, 0.5)
			end
		end
	until HOLD == false or cancelled()

	if token == SlamToken then
		ATTACK = false
		BoostFrames = 25
	end
end

local function OnSlamAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		HOLD = true
		if EQUIPPED and not ATTACK then
			task.spawn(BANSLAM)
		end
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		HOLD = false
	end
	return Enum.ContextActionResult.Sink
end

local music
local originalSpeed = Humanoid.WalkSpeed
local simConn

local function ApplySimRadius()
	local setHidden = sethiddenproperty or set_hidden_property or set_hidden_prop
	if setHidden then
		pcall(setHidden, Player, "SimulationRadius", SIM_RADIUS)
		pcall(setHidden, Player, "MaximumSimulationRadius", SIM_RADIUS)
	else
		pcall(function() Player.SimulationRadius = SIM_RADIUS end)
		pcall(function() Player.MaximumSimulationRadius = SIM_RADIUS end)
	end
end

local function Cleanup()
	EQUIPPED = false
	HOLD = false
	ATTACK = false
	SlamToken = SlamToken + 1
	BoostFrames = 0
	Bst = 1
	Weapon.Parent = nil
	ContextActionService:UnbindAction(ACTION_NAME)
	for name, j in pairs(Real) do
		j.C0, j.C1 = RestReal[name].C0, RestReal[name].C1
	end
	ResetVirtual()
	if ANIMATE then ANIMATE.Disabled = false end
	if music then music:Destroy() music = nil end
	if simConn then simConn:Disconnect() simConn = nil end
	if Humanoid.Parent then Humanoid.WalkSpeed = originalSpeed end
end

Tool.Equipped:Connect(function()
	if EQUIPPED or Humanoid.Health <= 0 then return end
	originalSpeed = Humanoid.WalkSpeed
	ResetVirtual()
	EQUIPPED = true
	if not IS_R15 then
		Weapon.Parent = Character
		if ANIMATE then ANIMATE.Disabled = true end
		for _, t in ipairs(Humanoid:GetPlayingAnimationTracks()) do
			t:Stop(0)
		end
	end
	Humanoid.WalkSpeed = EquippedSpeed
	if simConn then simConn:Disconnect() end
	simConn = RunService.Heartbeat:Connect(ApplySimRadius)
	ApplySimRadius()
	if PLAY_MUSIC then
		music = IT("Sound")
		music.SoundId = MUSIC_ID
		music.Looped = true
		music.Volume = 5
		music.Parent = Character
		music:Play()
	end

	ContextActionService:BindAction(ACTION_NAME, OnSlamAction, true, Enum.KeyCode.E, Enum.KeyCode.ButtonR2)
	ContextActionService:SetTitle(ACTION_NAME, "Slam")
	ContextActionService:SetPosition(ACTION_NAME, BUTTON_POSITION)
end)

Tool.Unequipped:Connect(Cleanup)

Humanoid.Died:Connect(function()
	Cleanup()
	Weapon:Destroy()
end)

task.spawn(function()
	local icon = ""
	pcall(function()
		local userId = Players:GetUserIdFromNameAsync("DuaKNo")
		icon = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	local function Notify(title, text, withIcon)
		for _ = 1, 20 do
			local ok = pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = title,
					Text = text,
					Icon = withIcon and icon or "",
					Duration = 3.5,
				})
			end)
			if ok then return end
			task.wait(0.5)
		end
	end

	Notify("Ban Hammer for NPCs", "By DuaKNo", true)
	task.wait(0.6)
	Notify("Follow on Instagram", "me_duakno", false)
	task.wait(0.6)
	Notify("Join Discord Server for more", "discord.gg/empgqd5qpq", false)
end)

while Humanoid.Parent do
	Swait()
	if EQUIPPED and not IS_R15 then
		Bst = (BoostFrames > 0) and 4 or 1
		if BoostFrames > 0 then BoostFrames = BoostFrames - 1 end

		SINE = SINE + CHANGE
		local vel = RootPart.AssemblyLinearVelocity
		local TORSOVELOCITY = (vel * VT(1, 0, 1)).Magnitude
		local TORSOVERTICALVELOCITY = vel.Y
		local grounded = Humanoid.FloorMaterial ~= Enum.Material.Air
		local spd16 = Humanoid.WalkSpeed / 16
		local W = 6 / spd16
		local rootAngY = RootPart.AssemblyAngularVelocity.Y
		local headAngY = Head.AssemblyAngularVelocity.Y

		if not ATTACK then
			SetC0("RS", CF(1.5, 0, 0) * ANGLES(RAD(200), RAD(90), 0) * RIGHTSHOULDERC0, 0.2)
			SetHW(CF(0, -0.8, 0) * ANGLES(RAD(-90), 0, 0), 0.2)
		end

		if ANIM == "Walk" and TORSOVELOCITY > 1 and not ATTACK then
			SetC1("Root", ROOTC0 * CF(0, 0, -0.15 * COS(SINE / (W / 2))) * ANGLES(0, -rootAngY / 75, 0), 2 * spd16)
			SetC1("Neck", NECKC1 * ANGLES(RAD(2.5 * SIN(SINE / (W / 2))), 0, -headAngY / 30), 0.2 * spd16)
			SetC1("RH", CF(0.5, 0.875 - 0.125 * SIN(SINE / W), -0.125 * COS(SINE / W)) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(76 * COS(SINE / W))), 0.2 * spd16)
			SetC1("LH", CF(-0.5, 0.875 + 0.125 * SIN(SINE / W), 0.125 * COS(SINE / W)) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(76 * COS(SINE / W))), 0.2 * spd16)
		else
			SetC1("Root", ROOTC0, 0.2)
			SetC1("Neck", NECKC1, 0.2)
			SetC1("RH", CF(0.5, 1, 0) * ANGLES(0, RAD(90), 0), 0.2)
			SetC1("LH", CF(-0.5, 1, 0) * ANGLES(0, RAD(-90), 0), 0.2)
		end

		if TORSOVERTICALVELOCITY > 1 and not grounded then
			ANIM = "Jump"
			if not ATTACK then
				SetC0("Root", ROOTC0, 0.2)
				SetC0("Neck", NECKC0 * ANGLES(RAD(-20), 0, 0), 0.2)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(RAD(-40), 0, RAD(-20)) * LEFTSHOULDERC0, 0.2)
				SetC0("RH", CF(1, -1, -0.3) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-5), 0, RAD(-20)), 0.2)
				SetC0("LH", CF(-1, -1, -0.3) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-5), 0, RAD(20)), 0.2)
			end
		elseif TORSOVERTICALVELOCITY < -1 and not grounded then
			ANIM = "Fall"
			if not ATTACK then
				SetC0("Root", ROOTC0, 0.2)
				SetC0("Neck", NECKC0 * ANGLES(RAD(20), 0, 0), 0.2)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(0, 0, RAD(-60)) * LEFTSHOULDERC0, 0.2)
				SetC0("RH", CF(1, -1, 0) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(20)), 0.2)
				SetC0("LH", CF(-1, -1, 0) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(10)), 0.2)
			end
		elseif TORSOVELOCITY < 1 and grounded then
			ANIM = "Idle"
			if not ATTACK then
				SetC0("Root", ROOTC0 * CF(0, 0, 0.05 * COS(SINE / 12)), 0.15)
				SetC0("Neck", NECKC0 * ANGLES(RAD(-2.5 * SIN(SINE / 12)), 0, 0), 0.15)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(0, 0, RAD(-12)) * LEFTSHOULDERC0, 0.15)
				SetC0("RH", CF(1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(90), 0) * ANGLES(RAD(-8), 0, 0), 0.15)
				SetC0("LH", CF(-1, -1 - 0.05 * COS(SINE / 12), -0.01) * ANGLES(0, RAD(-90), 0) * ANGLES(RAD(-8), 0, 0), 0.15)
			end
		elseif TORSOVELOCITY > 1 and grounded then
			ANIM = "Walk"
			if not ATTACK then
				SetC0("Root", ROOTC0 * CF(0, 0, -0.1) * ANGLES(RAD(5), 0, 0), 0.15)
				SetC0("Neck", NECKC0 * ANGLES(RAD(5 - 8 * SIN(SINE / (W / 2))), 0, 0), 0.15)
				SetC0("LS", CF(-1.5, 0.5, 0) * ANGLES(RAD(-60 * COS(SINE / W)), 0, RAD(-5)) * LEFTSHOULDERC0, 0.35)
				SetC0("RH", CF(1, -1 - 0.15 * COS(SINE / W * 2), -0.2 + 0.2 * COS(SINE / W)) * ANGLES(0, RAD(90), 0) * ANGLES(0, 0, RAD(-15)), 2)
				SetC0("LH", CF(-1, -1 - 0.15 * COS(SINE / W * 2), -0.2 - 0.2 * COS(SINE / W)) * ANGLES(0, RAD(-90), 0) * ANGLES(0, 0, RAD(15)), 2)
			end
		end
	end
end
