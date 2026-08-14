local s, e = pcall(function()
local P, RS, UIS, L = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Lighting")
local pl = P.LocalPlayer 
local pg = pl:WaitForChild("PlayerGui", 5) or pl:FindFirstChild("PlayerGui")
if not pg then return end

pcall(function()
	for _, v in ipairs(pg:GetChildren()) do if v.Name == "LootifyMegaMenu" or v.Name == "LootifyOpenButton" or v.Name == "CoordViewer" then v:Destroy() end end
	local cg = game:GetService("CoreGui")
	for _, v in ipairs(cg:GetChildren()) do if v.Name == "LootifyMegaMenu" or v.Name == "LootifyOpenButton" or v.Name == "CoordViewer" then v:Destroy() end end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "LootifyMegaMenu"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 2147483647

pcall(function()
	if syn and syn.protect_gui then
		syn.protect_gui(sg)
		sg.Parent = game:GetService("CoreGui")
	elseif gethui then
		sg.Parent = gethui()
	else
		sg.Parent = game:GetService("CoreGui")
	end
end)
if not sg.Parent then sg.Parent = pg end

local openSg = Instance.new("ScreenGui")
openSg.Name = "LootifyOpenButton"
openSg.ResetOnSpawn = false
openSg.DisplayOrder = 2147483647
pcall(function() if gethui then openSg.Parent = gethui() else openSg.Parent = game:GetService("CoreGui") end end)
if not openSg.Parent then openSg.Parent = pg end

local openBtn = Instance.new("TextButton", openSg)
openBtn.Size = UDim2.new(0, 95, 0, 35)
openBtn.Position = UDim2.new(0, 15, 0, 80)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
openBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
openBtn.BorderSizePixel = 2
openBtn.Font = Enum.Font.GothamBold
openBtn.Text = "MENU ON/OFF"
openBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
openBtn.TextSize = 11
openBtn.Active = true
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

local mf = Instance.new("Frame", sg) 
mf.Name = "MainFrame"
mf.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mf.BorderColor3 = Color3.fromRGB(0, 255, 170)
mf.Size = UDim2.new(0, 220, 0, 295)
mf.Position = UDim2.new(0.2, 0, 0.2, 0) 
mf.BorderSizePixel = 2 
mf.Active = true
mf.Visible = true
mf.ZIndex = 10
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local ug = Instance.new("UIGradient", mf) 
ug.Rotation = 45 
ug.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 128)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))})

local dragging, dragInput, dragStart, startPos
mf.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mf.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

mf.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mf.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local tl = Instance.new("TextLabel", mf) 
tl.BackgroundTransparency = 1
tl.Position = UDim2.new(0, 35, 0, 5)
tl.Size = UDim2.new(1, -45, 0, 30)
tl.Font = Enum.Font.GothamBold
tl.Text = "LOOTIFY MENU"
tl.TextColor3 = Color3.fromRGB(255, 255, 255)
tl.TextSize = 16
tl.ZIndex = 11

local cb = Instance.new("TextButton", mf) 
cb.Name = "CloseButton"
cb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cb.BorderColor3 = Color3.fromRGB(255, 0, 0)
cb.Position = UDim2.new(0, 5, 0, 5)
cb.Size = UDim2.new(0, 30, 0, 30)
cb.Font = Enum.Font.GothamBold
cb.Text = "X"
cb.TextColor3 = Color3.fromRGB(255, 255, 255)
cb.TextSize = 16 
cb.ZIndex = 11
Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)

local ka, ac, aq, as, sa = false, false, false, false, true 
local lat = 0 
local spinAngle = 0

openBtn.MouseButton1Click:Connect(function() mf.Visible = not mf.Visible end)

local function getCombatTarget()
	local bestTarget = nil
	local shortestDist = 60 -- Đã tăng phạm vi tìm kiếm mục tiêu lên 60
	pcall(function()
		local c = pl.Character 
		if not c or not c:FindFirstChild("HumanoidRootPart") then return end 
		local rp = c.HumanoidRootPart 
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v ~= c then
				local hum = v:FindFirstChildOfClass("Humanoid")
				local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
				if hum and root and hum.Health > 0 then
					local isPlayer = false
					for _, p in ipairs(P:GetPlayers()) do if p.Character == v then isPlayer = true break end end
					if not isPlayer then
						local name = v.Name:lower()
						local fullName = v:GetFullName():lower()
						local isLobby = fullName:find("lobby") or fullName:find("spawn") or fullName:find("shop") or fullName:find("npc") or name:find("code")
						if not isLobby then
							local isMob = hum.MaxHealth > 5 and not name:find("dummy")
							if isMob then
								local dist = (rp.Position - root.Position).Magnitude
								if dist < shortestDist then shortestDist = dist bestTarget = root end
							end
						end
					end
				end
			end
		end
	end)
	return bestTarget
end

local function cBtn(n, y, tc) 
	local b = Instance.new("TextButton", mf) 
	b.Name = n
	b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	b.BorderColor3 = Color3.fromRGB(0, 255, 128)
	b.Position = UDim2.new(0.05, 0, 0, y)
	b.Size = UDim2.new(0, 198, 0, 32)
	b.Font = Enum.Font.GothamBold
	b.Text = n
	b.TextColor3 = tc or Color3.fromRGB(75, 255, 75)
	b.TextSize = 12
	b.AutoButtonColor = false
	b.Visible = true
	b.ZIndex = 11
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6) 
	return b 
end

local b1 = cBtn("vip unltra", 40, Color3.fromRGB(75, 255, 75))
local ri = Instance.new("ImageLabel", b1) ri.Name = "RonaldoDecor" ri.BackgroundTransparency = 1 ri.Position = UDim2.new(1, -35, 0.5, -15) ri.Size = UDim2.new(0, 30, 0, 30) ri.Image = "rbxassetid://10487246132" ri.ZIndex = 12 Instance.new("UICorner", ri).CornerRadius = UDim.new(1, 0)
local b2 = cBtn("Auto Mở Rương (Chest)", 76, Color3.fromRGB(255, 215, 0))
local b3 = cBtn("Auto Nhận Nhiệm Vụ (Quest)", 112, Color3.fromRGB(0, 255, 255))
local b4 = cBtn("Fix Lag (Clean)", 148, Color3.fromRGB(255, 255, 0))
local b5 = cBtn("Chống (Anti-Stun/Chịu Đòn)", 184, Color3.fromRGB(0, 180, 255))
local al = false

cb.MouseButton1Click:Connect(function() sa = false sg:Destroy() openSg:Destroy() end)

b1.MouseButton1Click:Connect(function() 
	ka = not ka 
	b1.TextColor3 = ka and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(75, 255, 75) 
	b1.BorderColor3 = ka and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0) 
end)

b2.MouseButton1Click:Connect(function() 
	ac = not ac 
	b2.TextColor3 = ac and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(255, 215, 0) 
	b2.BorderColor3 = ac and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 128) 
end)

b3.MouseButton1Click:Connect(function() 
	aq = not aq 
	b3.TextColor3 = aq and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(0, 255, 255) 
	b3.BorderColor3 = aq and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 128) 
end)

b4.MouseButton1Click:Connect(function()
	al = not al 
	b4.TextColor3 = al and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(255, 255, 0)
	b4.BorderColor3 = al and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 128) 
	pcall(function()
		L.GlobalShadows = not al
		L.Brightness = al and 1 or 2
		for _, v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v.Enabled = not al end end
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = not al 
			elseif v:IsA("BasePart") and al then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
		end
	end)
end)

b5.MouseButton1Click:Connect(function() as = not as b5.TextColor3 = as and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(0, 180, 255) b5.BorderColor3 = as and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 128) end)

task.spawn(function()
	while sa do
		pcall(function()
			local c = pl.Character
			if c and c:FindFirstChild("HumanoidRootPart") then
				local rp = c.HumanoidRootPart
				
				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("ProximityPrompt") then
						local name = v.Parent and v.Parent.Name:lower() or ""
						local fullName = v.Parent and v.Parent:GetFullName():lower() or ""
						local pPart = v.Parent
						if pPart and pPart:IsA("BasePart") then
							local dist = (rp.Position - pPart.Position).Magnitude
							if ac and (name:find("chest") or name:find("box") or name:find("ruong") or fullName:find("chest") or fullName:find("ruong")) and dist <= 120 then
								v.HoldDuration = 0 
								if fireproximityprompt then fireproximityprompt(v) end
							end
							if aq and (name:find("quest") or name:find("mission") or name:find("task") or name:find("nhiemvu") or fullName:find("quest") or fullName:find("mission")) then
								if dist > 8 then
									pcall(function() rp.CFrame = pPart.CFrame + Vector3.new(0, 3, 0) end)
								end
								v.HoldDuration = 0 
								if fireproximityprompt then fireproximityprompt(v) end
							end
						end
					end
				end
			end
		end)
		task.wait(0.4)
	end
end)

RS.Heartbeat:Connect(function() 
	if not sa then return end 
	pcall(function()
		local cc = pl.Character 
		if not cc then return end 
		local hm, rp = cc:FindFirstChildOfClass("Humanoid"), cc:FindFirstChild("HumanoidRootPart") 
		
		if as and cc then 
			pcall(function() 
				for _, ch in ipairs(cc:GetChildren()) do 
					if ch:IsA("Folder") or ch:IsA("StringValue") or ch:IsA("BoolValue") then 
						local n = ch.Name:lower() 
						if n:find("stun") or n:find("slow") or n:find("ragdoll") or n:find("knockback") or n:find("freeze") then ch:Destroy() end 
					end 
				end 
				if hm and hm.PlatformStand then hm.PlatformStand = false end 
			end) 
		end 

		if ka and rp and hm and hm.Health > 0 then 
			local tn = getCombatTarget() 
			if tn and tn.Parent then 
				local th = tn.Parent:FindFirstChildOfClass("Humanoid") 
				if th and th.Health > 0 then 
					pcall(function() hm:MoveTo(tn.Position) end)
					if tick() - lat >= 0.15 then 
						local tl = cc:FindFirstChildOfClass("Tool") 
						if tl then tl:Activate() end 
						th:TakeDamage(50) 
						lat = tick() 
					end 
				end 
			else
				spinAngle = (spinAngle + 12) % 360
				rp.CFrame = CFrame.new(rp.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
			end 
		end
	end)
end)

end) if not s then warn(e) end
