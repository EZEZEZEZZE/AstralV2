warn([[

Astral UI Library

Recent:
Added uninjecting

]])

getgenv().HUDColor = Color3.fromRGB(150, 0, 240)
getgenv().HUDAnimations = true
getgenv().BlurAnimations = true
getgenv().SaveDefault = "AstralConfig"
getgenv().SaveName = getgenv().SaveDefault .. ".lua"
getgenv().HUDColor = Color3.fromRGB(13, 105, 172)
getgenv().ArraylistStrokeTransparency = 0.75
getgenv().GUI = Instance.new("ScreenGui", game:GetService"CoreGui")

GUI.Enabled = false

local ArrayList = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mastadawn/AstralV2/main/Arraylist.lua", true))()

local Loaded = {}
local Binds = {}
local Tabs = 0
local TabInstances = {}
local UIS = game:GetService"UserInputService"
local HTTP = game:GetService"HttpService"
local Blur = Instance.new("BlurEffect", game:GetService"Lighting")
Blur.Enabled = false

local function AddEffect(GUIInstance, Duration)
    task.spawn(function()
        local effect = Instance.new("Frame", GUIInstance)
        effect.BorderSizePixel = 0
        effect.Transparency = 0.5
        for i = 1, 100 do
            task.wait(Duration / 100)
            effect.Size = UDim2.new(i / 100, 0, 1, 0)
            effect.Transparency = i / 100
        end
        effect:Destroy()
    end)
end

local function MakeDarker(color)
	local H, S, V = color:ToHSV()
	V = math.clamp(V / 2, 0.5, 0.5)
	return Color3.fromHSV(H, S, V)
end

local debounce = false
UIS.InputBegan:Connect(function()
	if UIS:IsKeyDown(Enum.KeyCode.RightShift) and debounce == false then
		getgenv().GUI.Enabled = not getgenv().GUI.Enabled
	end
end)

Save = function(Module)
	local Saved
	if isfile(getgenv().SaveName) then
		Saved = HTTP:JSONDecode(readfile(getgenv().SaveName))
	end
	if Saved then
		for i,v in pairs(Saved) do
			if v.Name == Module.Name then
				table.remove(Saved,i)
			end
		end
		table.insert(Saved,Module)
	else
		Saved = {}
		table.insert(Saved,Module)
	end
	writefile(getgenv().SaveName,HTTP:JSONEncode(Saved))
end

Load = function()
	if isfile(getgenv().SaveName) then
		Loaded = HTTP:JSONDecode(readfile(getgenv().SaveName))
	else
		warn("No config save detected")
	end
end

local Debounce = false

Keybinds = function()
	UIS.InputBegan:Connect(function(input)
		for i,v in pairs(Binds) do
			if v.Module.Bind ~= nil and input.KeyCode == Enum.KeyCode[v.Module.Bind] then
				v.Module.Enabled = not v.Module.Enabled
				task.wait(.1)
				task.spawn(function()
					if v.Module.Enabled == true then
						local Suffix
						for _,D in pairs(v.Module.Dropdowns) do
							if D[1] == "Selection" then
								Suffix = D[4][D[3]]
							end
						end
						ArrayList.Add(v.Module.Name,Suffix)
					else
						ArrayList.Remove(v.Module.Name)
					end
				end)
				task.spawn(function()
					repeat
						task.wait()
					until v.Module.Enabled == false
					ArrayList.Remove(v.Module.Name)
				end)
				coroutine.wrap(function()
					v.Module.Function(v.Module,v.Module.Dropdowns)
				end)()
				Save(v.Module)
			end
		end
	end)
end

Keybinds()

local UILibrary = {
	MakeTab = function(tabname)
		local newtab = Instance.new("Frame", getgenv().GUI)
		local Line = Instance.new("Frame", newtab)
		local Title = Instance.new("TextLabel", newtab)
		newtab.Size = UDim2.new(0, 255, 0, 55)
		newtab.Position = UDim2.new(0, 20 + (262 * Tabs), 0.025, 0)
		newtab.BorderSizePixel = 0
		newtab.Active = true
		newtab.Draggable = true
		newtab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		Line.Size = UDim2.new(1, 0, 0.095, 0)
		Line.BorderSizePixel = 0
		Title.BackgroundTransparency = 1
		Title.Text = "  "..tabname
		Title.Font = Enum.Font.GothamBold
		Title.TextColor3 = Color3.fromRGB(200, 200, 200)
		Title.Size = UDim2.new(1, 0, 0.7, 0)
		Title.TextSize = Title.AbsoluteSize.X * 0.09
		Title.Position = UDim2.new(0, 0, 0.2, 0)
		Title.TextXAlignment = "Left"
		spawn(function()
			repeat
				task.wait()
				Line.BackgroundColor3 = getgenv().HUDColor
			until true == false
		end)
		Tabs = Tabs + 1
		table.insert(TabInstances, newtab)
		return newtab
	end,
	MakeModule = function(Module)

		spawn(function()
			for i,z in pairs(Loaded) do
				if z.Name == Module.Name then
					Module.Enabled = z.Enabled
					Module.Bind = z.Bind
					for i,v in pairs(z.Dropdowns) do
						for e,c in pairs(Module.Dropdowns) do
							if v[2] == c[2] then
								if c[1] == "Slider" then
									c[5] = v[5]
								elseif c[1] == "Toggle" then
									c[3] = v[3]
								elseif c[1] == "Selection" then
									c[3] = v[3]
								else
									print(v[1],"-->",c[1])
								end
							end
						end
					end
				end
			end
		end)

		spawn(function()
			local BindCooldown = false
			local Tab = Module.Tab
			local Name = Module.Name
			local DropdownOpen = false
			local Description = Module.Description
			local DropdownCount = 0
			local TemporaryObjects = { ["DropdownGUI"] = {}, ["HoverGUI"] = {} }
			for i, v in pairs(Module.Dropdowns) do DropdownCount = DropdownCount + 1 end
			local newModule = Instance.new("Frame", Tab)
			local newbutton = Instance.new("TextButton", newModule)
			newModule.Size = UDim2.new(1, 0, 1, 0)
			newModule.BorderSizePixel = 0
			newModule.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
			newModule.Position = UDim2.new(0, 0, #Tab:GetChildren() - 2, 0)
			newbutton.Size = UDim2.new(1, 0, 1, 0)
			newbutton.BackgroundTransparency = 1
			newbutton.Text = string.lower("  " .. Name)
			newbutton.TextSize = newbutton.AbsoluteSize.X * 0.075
			newbutton.Font = Enum.Font.GothamSemibold
			newbutton.TextColor3 = Color3.fromRGB(200, 200, 200)
			local function UpdateBind()
				if Module.Bind ~= nil then
					for i,v in pairs(Binds) do
						if v.Module.Name == Module.Name then
							table.remove(Binds,i)
						end
					end
					table.insert(Binds,{
						Module = Module,
						Button = newbutton,
					})
				end
			end
			task.spawn(function()
				if Module.Enabled == true then
					local Suffix
					for _,D in pairs(Module.Dropdowns) do
						if D[1] == "Selection" then
							Suffix = D[4][D[3]]
						end
					end
					ArrayList.Add(Module.Name,Suffix)
				else
					ArrayList.Remove(Module.Name)
				end
			end)
			task.spawn(function()
				repeat
					task.wait()
				until Module.Enabled == false
				Save(Module)
				ArrayList.Remove(Module.Name)
			end)
			if Module.Enabled == true then
				spawn(function()
					Module.Function(Module, Module.Dropdowns)
				end)
				spawn(function()
					repeat task.wait()
						newModule.BackgroundColor3 = getgenv().HUDColor
						task.wait()
					until Module.Enabled == false
					Save(Module)
					newModule.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				end)
			else newModule.BackgroundColor3 = Color3.fromRGB(42, 42, 42) end
			newbutton.TextXAlignment = "Left"
			local entered = false

			UpdateBind()

			newbutton.MouseEnter:Connect(function()
				entered = true
				local Hover = Instance.new("Frame", getgenv().GUI)
				Hover.Size = UDim2.new(4.35e-3 * string.len(Description), 0, 0.055, 0)
				Hover.BorderSizePixel = 0
				Hover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				local Round = Instance.new("UICorner",Hover)
				Round.CornerRadius = UDim.new(0,8)
				local Text = Instance.new("TextLabel", Hover)
				Text.Size = UDim2.new(.9, 0, 0.35, 0)
				Text.Position = UDim2.new(.035, 0, 0.025, 0)
				Text.Font = Enum.Font.GothamBold
				Text.BackgroundTransparency = 1
				Text.Text = string.lower(Name .. ":")
				Text.TextXAlignment = "Left"
				Text.TextColor3 = Color3.fromRGB(200, 200, 200)
				Text.TextSize = Text.AbsoluteSize.Y * 0.87
				local Text2 = Instance.new("TextLabel", Hover)
				Text2.Size = UDim2.new(.9, 0, 0.5, 0)
				Text2.Position = UDim2.new(.035, 0, 0.5, 0)
				Text2.Font = Enum.Font.GothamBold
				Text2.BackgroundTransparency = 1
				Text2.Text = string.lower(Description)
				Text2.TextXAlignment = "Left"
				Text2.TextColor3 = Color3.fromRGB(200, 200, 200)
				Text2.TextSize = Text.AbsoluteSize.Y * 0.8
				table.insert(TemporaryObjects.HoverGUI, Hover)
				local Side = Instance.new("Frame", Hover)
				Side.Size = UDim2.new(0.3 / string.len(Description), 0, .7, 0)
				Side.BorderSizePixel = 0
				Side.Position = UDim2.new(0.0005 * string.len(Description),0,0.15,0)
				local Round2 = Instance.new("UICorner",Side)
				Round2.CornerRadius = UDim.new(0,8)
				repeat
					if entered then
						Hover.Position = UDim2.new(0, UIS:GetMouseLocation().X, 0, UIS:GetMouseLocation().Y)
						Side.BackgroundColor3 = getgenv().HUDColor
						if Module.Enabled then Hover.BackgroundColor3 = MakeDarker(getgenv().HUDColor)
						else Hover.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
					end
					task.wait()
				until not entered or Blur.Enabled == true
				for i, v in pairs(TemporaryObjects.HoverGUI) do v:Destroy() end
			end)
			newbutton.MouseLeave:Connect(function()
				entered = false
				for i, v in pairs(TemporaryObjects.HoverGUI) do v:Destroy() end
			end)
			newbutton.MouseButton1Click:Connect(function()
				spawn(function() AddEffect(newbutton, 0.45) end)
				if Module.Enabled == false then
					Module.Enabled = true
					spawn(function()
						spawn(function()
							repeat
								task.wait()
								newModule.BackgroundColor3 = getgenv().HUDColor
							until Module.Enabled == false
							Save(Module)
							newModule.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
						end)
						Module.Function(Module, Module.Dropdowns)
					end)
				else
					Module.Enabled = false
					task.wait(0.1)
					newModule.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Module.Enabled = false
				end

				task.spawn(function()
					if Module.Enabled == true then
						local Suffix
						for _,D in pairs(Module.Dropdowns) do
							if D[1] == "Selection" then
								Suffix = D[4][D[3]]
							end
						end
						ArrayList.Add(Module.Name,Suffix)
					else
						ArrayList.Remove(Module.Name)
					end
				end)

				task.spawn(function()
					repeat
						task.wait()
					until Module.Enabled == false
					Save(Module)
					ArrayList.Remove(Module.Name)
				end)

				Save(Module)
			end)
			newbutton.MouseButton2Click:Connect(function()
				spawn(function() AddEffect(newbutton, 0.45) end)
				if DropdownOpen == false then
					local AddedObjects = 0
					DropdownOpen = true
					local DropFrame = Instance.new("Frame", newbutton)
					table.insert(TemporaryObjects.DropdownGUI, DropFrame)
					DropFrame.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
					DropFrame.Size = UDim2.new(1, 0, DropdownCount + 1, 0)
					DropFrame.BorderSizePixel = 0
					DropFrame.Position = UDim2.new(0, 0, 1, 0)
					for i, v in pairs(Tab:GetChildren()) do
						if v:IsA"Frame" and v.Position.Y.Scale > newModule.Position.Y.Scale then
							v.Position = v.Position + UDim2.new(0, 0, DropdownCount + 1, 0)
						end
					end
					for i, v in pairs(Module.Dropdowns) do
						AddedObjects = AddedObjects + 1
						local Frame1 = Instance.new("Frame", newbutton)
						Frame1.BackgroundTransparency = 0
						Frame1.BorderSizePixel = 0
						Frame1.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
						Frame1.Size = UDim2.new(1, 0, 1, 0)
						Frame1.Position = UDim2.new(0, 0, AddedObjects, 0)
						local Frame = Instance.new("Frame", Frame1)
						Frame.BackgroundTransparency = 0
						Frame.Size = UDim2.new(.9, 0, .7, 0)
						Frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
						Frame.BorderSizePixel = 0
						Frame.Position = UDim2.new(0.05, 0, 0.15, 0)
						table.insert(TemporaryObjects.DropdownGUI, Frame1)
						local Type = v[1]
						local Name = v[2]
						if v[1] == "Slider" then
							local MinValue = v[3]
							local MaxValue = v[4]
							local CurrentValue = v[5]
							local Title = Instance.new("TextLabel", Frame)
							local BarBack = Instance.new("TextButton", Frame)
							local Bar = Instance.new("TextButton", BarBack)
							Title.Size = UDim2.new(0.9, 0, 0.375, 0)
							Title.Position = UDim2.new(0.05, 0, 0.1, 0)
							Title.BackgroundTransparency = 1
							Title.TextXAlignment = "Left"
							Title.TextSize = Title.AbsoluteSize.X * 0.06
							Title.TextColor3 = Color3.fromRGB(200, 200, 200)
							Title.Font = Enum.Font.GothamSemibold
							Title.Text = string.lower(v[2] .. ": " .. math.round(CurrentValue))
							BarBack.Size = UDim2.new(0.9, 0, 0.1, 0)
							BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
							BarBack.Position = UDim2.new(0.05, 0, 0.75, 0)
							BarBack.BorderSizePixel = 0
							Bar.Size = UDim2.new(CurrentValue / MaxValue, 0, 1, 0)
							Bar.BorderSizePixel = 0
							Bar.Text = ""
							BarBack.Text = ""
							spawn(function()
								repeat
									task.wait()
									Bar.BackgroundColor3 = getgenv().HUDColor
								until not Bar
							end)
							-- Slider Code
							local dragging = false
							BarBack.MouseButton1Down:Connect(function()
								dragging = true
								repeat
									task.wait()
									local mouseL = UIS:GetMouseLocation()
									local Relative = mouseL - Bar.AbsolutePosition
									local percent = math.clamp(Relative.X / BarBack.AbsoluteSize.X, 0, 1)
									Bar.Size = UDim2.new(percent, 0, 1, 0)
									v[5] = Bar.Size.X.Scale * v[4]
									Title.Text = string.lower(v[2] .. ": " .. math.round(v[5]))
								until dragging == false
								Save(Module)
								UpdateBind()
							end)
							Bar.MouseButton1Down:Connect(function()
								dragging = true
								repeat
									task.wait()
									local mouseL = UIS:GetMouseLocation()
									local Relative = mouseL - Bar.AbsolutePosition
									local percent = math.clamp(Relative.X / BarBack.AbsoluteSize.X, 0, 1)
									Bar.Size = UDim2.new(percent, 0, 1, 0)
									v[5] = Bar.Size.X.Scale * v[4]
									Title.Text = v[2] .. ": " .. math.round(v[5])
								until dragging == false
								Save(Module)
								UpdateBind()
							end)
							UIS.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
							end)
							Bar.Size = UDim2.new(v[5] / v[4], 0, 1, 0)
						elseif v[1] == "Toggle" then
							local CurrentValue = v[3]
							local Title = Instance.new("TextButton", Frame)
							Title.Size = UDim2.new(0.95, 0, 1, 0)
							Title.Position = UDim2.new(0.015, 0, 0, 0)
							Title.TextSize = Title.AbsoluteSize.X * 0.06
							Title.TextXAlignment = "Left"
							Title.BackgroundTransparency = 1
							Title.Text = string.lower("  " .. Name)
							Title.TextColor3 = Color3.fromRGB(200, 200, 200)
							Title.Font = Enum.Font.GothamSemibold
							spawn(function()
								repeat
									task.wait()
									if v[3] == true then
										Frame.BackgroundColor3 = getgenv().HUDColor
									end
								until v[3] == false
							end)
							Title.MouseButton1Click:Connect(function()
								if v[3] == false then
									v[3] = true
									spawn(function()
										repeat
											task.wait()
											Frame.BackgroundColor3 = getgenv().HUDColor
										until v[3] == false
									end)
								else
									v[3] = false
									task.wait(.1)
									Frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
								end
								Save(Module)
								UpdateBind()
							end)
						elseif v[1] == "Selection" then
							local Click = Instance.new("TextButton", Frame)
							Click.Size = UDim2.new(0.9, 0, 0.65, 0)
							Click.BackgroundTransparency = 0
							Click.AnchorPoint = Vector2.new(0.5, 0.5)
							Click.Position = UDim2.new(0.5, 0, 0.5, 0)
							Click.Text = string.lower(" Selected mode: " .. v[4][v[3]])
							Click.TextSize = Click.AbsoluteSize.X * 0.08
							Click.TextXAlignment = "Left"
							Click.Font = Enum.Font.GothamBold
							Click.TextColor3 = Color3.fromRGB(200, 200, 200)
							Click.BorderSizePixel = 0
							Click.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
							Click.MouseButton1Click:Connect(function()
								spawn(function() AddEffect(Click, 0.45) end)
								if v[4][v[3] + 1] then
									v[3] = v[3] + 1
									Click.Text = string.lower(" Selected mode: " .. v[4][v[3]])
								else
									v[3] = 1
									Click.Text = string.lower(" Selected mode: " .. v[4][1])
								end
								Save(Module)
								UpdateBind()
							end)
							Click.MouseButton2Click:Connect(function()
								spawn(function() AddEffect(Click, 0.45) end)
								if v[4][v[3] - 1] then
									v[3] = v[3] - 1
									Click.Text = string.lower(" Selected mode: " .. v[4][v[3]])
								else
									local total = 1
									for i, v in pairs(v[4]) do total = total + 1 end
									v[3] = total
									Click.Text = string.lower(" Selected mode: " .. v[4][1])
								end
								Save(Module)
								UpdateBind()
							end)
						end
					end
					AddedObjects = AddedObjects + 1
					local Frame = Instance.new("Frame", newbutton)
					Frame.BackgroundTransparency = 1
					Frame.Size = UDim2.new(.8, 0, .7, 0)
					Frame.Position = UDim2.new(0.1, 0, AddedObjects + 0.15, 0)
					table.insert(TemporaryObjects.DropdownGUI, Frame)
					local BindText = Instance.new("TextButton", Frame)
					if Module.Bind then BindText.Text = "   Bind: " .. Module.Bind
					else BindText.Text = "   Bind: none" end
					BindText.Size = UDim2.new(1, 0, 1, 0)
					BindText.BackgroundTransparency = 1
					BindText.TextSize = BindText.AbsoluteSize.X * 0.07
					BindText.TextXAlignment = "Left"
					BindText.Font = Enum.Font.GothamBold
					BindText.TextColor3 = Color3.fromRGB(200, 200, 200)
					BindText.MouseButton1Click:Connect(function()
						BindText.Text = "   Press a key/escape to remove"
						local OriginalBind = Module.Bind
						local set
						local BindEvent = UIS.InputBegan:Connect(function(input)
							task.wait()
							if input.KeyCode ~= Enum.KeyCode.Escape then
								set = input.KeyCode
								Module.Bind = UIS:GetStringForKeyCode(input.KeyCode)
							else
								set = nil
								Module.Bind = nil
							end
							set = true
						end)
						repeat task.wait() until set
						BindEvent:Disconnect()
						if Module.Bind then BindText.Text = string.lower("   Bind: " .. Module.Bind)
						else BindText.Text = string.lower("   Bind: none") end
						Save(Module)
						UpdateBind()
					end)
				else
					DropdownOpen = false
					for i, v in pairs(Tab:GetChildren()) do
						if v:IsA"Frame" and v.Position.Y.Scale > newModule.Position.Y.Scale then
							v.Position = v.Position - UDim2.new(0, 0, DropdownCount + 1, 0)
						end
					end
					for i, v in pairs(TemporaryObjects.DropdownGUI) do v:Destroy() end
				end
			end)
		end)
	end
}

Load()

task.spawn(function()
	task.wait(4)
	repeat task.wait(1) until Uninjected == true
	for i,v in pairs(GUI:GetChildren()) do
		v:Destroy()
	end
	task.wait(1)
	GUI:Destroy()
end)

return UILibrary