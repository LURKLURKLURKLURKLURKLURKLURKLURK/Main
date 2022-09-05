local players, tweenservice, httpservice, replicatedstorage, userinputservice, teamservice, coregui = game.GetService(game,'Players'), game.GetService(game,'TweenService'), game.GetService(game,'HttpService'), game.GetService(game,'ReplicatedStorage'),game.GetService(game,'UserInputService'),game.GetService(game,'Teams'),game.GetService(game,'CoreGui')
local debris, runservice = game.GetService(game,'Debris'), game.GetService(game,'RunService')
local lp, camera = players.LocalPlayer, workspace.CurrentCamera 
local wtvp, wtsp = camera.WorldToViewportPoint, camera.WorldToScreenPoint 
local v2, v3, ud, ud2, cf, fromrgb, newrgb = Vector2.new, Vector3.new, UDim.new, UDim2.new, CFrame.new, Color3.fromRGB, Color3.new
local findfirstchild, findfirstchildofclass, findfirstancestor, findfirstancestorofclass = game.FindFirstChild, game.FindFirstChildOfClass, game.FindFirstAncestor, game.FindFirstAncestorOfClass
local rad, round, floor,tan,atan2 = math.rad, math.Round, math.floor,math.tan,math.atan2
local drawing_classes = {'Triangle','Text','Image','Square','Quad'}
local partsFolder = Instance.new('Folder',camera)

local utils = {}; do
    utils.beams = {}
    utils.cache = {}
    utils.Create = function(class,prop)
        if table.find(drawing_classes,class) then 
            local drawing = Drawing.new(class)
            for i,v in pairs(prop) do 
                drawing[i] = v 
            end
            return drawing
            else 
                local instance = Instance.new(class)
                for i,v in pairs(prop) do 
                    instance[i] = v 
                end
            return instance
        end
    end
    utils.getFont = function(str)
        if str then 
            if str == 'UI' then 
                return 0
            elseif str == 'System' then 
                return 1 
            elseif str == 'Plex' then 
                return 2 
            elseif str == 'Monospace' then 
                return 3 
            end
            else 
                return 0
        end
    end
    utils.getDistFromCamera = function(pos)
        if pos then 
            return (pos - camera.CFrame.p).Magnitude
            else 
                return 0
        end
    end
    utils.dynamicFOV = function(fov)
        return ((120 + camera.FieldofView) * 4) + FOV
    end
    utils.getChar = function(target)
        if not target.Character then return end 
        local character = target.Character 
        local humanoidrootpart = findfirstchild(character,'HumanoidRootPart')
        return character, humanoidrootpart
    end
    
    utils.getHealth = function(target)
        local humanoid = findfirstchildofclass(character,'Humanoid') 
        if not humanoid then return end 
        return humanoid.Health,Humanoid.MaxHealth,Humanoid.Health>0
    end
    utils.getTeam = function(target)
        if target.Neutral then 
            return true, target.TeamColor.Color
            else 
                return lp.Team ~= target.Team 
        end
    end
    utils.antialiasingXY = function(x,y)
        return v2(round(x),round(y))
    end
    utils.antialiasingp = function(pos)
        return v2(round(pos.X),round(pos.Y))
    end
    utils.calculateboxsize = function(model,position)
        local size = model:GetExtentsSize()
        local sizefactor = 1/ (position.Z * tan(rad(camera.FieldOfView /2)) * 2) * 1000 
        size = utils.antialiasingXY(sizefactor * size.X, sizefactor * size.Y)
        position = v2(position.X, position.Y)
        return utils.antialiasingp(position - size / 2), size
    end
    
    function utils.getmousepos()
        return getmouse_loc(userinputservice)
    end

    function utils.get_plr(dist)
        local closest
        local distance 
        if lp.Character and findfirstchild(lp.Character,'HumanoidRootPart') then 
            for _,v in next, getchildren(players) do 
                if v ~= lp and v.Character and findfirstchild(v.Character,'HumanoidRootPart') then 
                    local part = findfirstchild(v.Character,'HumanoidRootPart')
                    if  dist >= (lp.Character.HumanoidRootPart.Position - part.Position).Magnitude then 
                        closest = part 
                        distance = (part.Position - lp.Character.HumanoidRootPart.Position).Magnitude 
                    end
                end
            end
        end
        return closest
    end;
    
    
    function utils.get_closest_plr()
        local closest 
        local distance_tomouse
            for _, plr in next, getchildren(players) do 
                if plr ~= lp then 
                    local character = plr.Character 
                    if character then 
                    local hrp = findfirstchild(character,'HumanoidRootPart')
                    local humanoid = findfirstchild(character,'Humanoid')
                    if hrp and humanoid and (humanoid and humanoid.Health > 0) then 
                        local screenpos,onscreen = wtsp(camera,hrp.Position)
                            
                        if onscreen then 
                            local dist = (utils.getmousepos() - Vector2.new(screenpos.X,screenpos.Y)).Magnitude 
                                
                            if dist <= (distance_tomouse or (library.flags['usefov'] and fovcircle.Radius) or 2000) then 
                                closest = character[library.flags['aim_bone']] 
                                distance_tomouse = dist 
                            end
                        end
                    end
                    end
                end
            end
        return closest
    end
    
    
    utils.esp_item = function (flag, item,isbasepart,NAME)
        utils.cache[item] = {
            Text = utils.Create('Text',{
                Font = 2, 
                Size = 13, 
                Outline = true, 
                Center = true, 
            })
        }
        local screenpos, onscreen
        
        utils.cache[item].render = runservice.Heartbeat:Connect(function()
            screenpos, onscreen = wtvp(camera,isbasepart and item.Position or item)
            local distance = utils.getDistFromCamera(isbasepart and item.Position or item)
            if onscreen then 
                if utils.cache[item].Text.Visible then 
                    if library then 
                        utils.cache[item].Text.Color = library.flags[flag..' Color']
                        else 
                            utils.cache[item].Text.Color = fromrgb(255,255,255)
                    end
                    utils.cache[item].Text.Transparency = 1 
                    utils.cache[item].Text.Text = NAME .. ' - '..tostring(floor(distance)) .. ' studs'
                    utils.cache[item].Text.Position = v2(screenpos.X,screenpos.Y)
                end 
            end
            --utils.cache[item].Text.Visible = onscreen and ((library ~= nil and library.flags[flag]) or true)
            if onscreen and distance <= library.flags['misc_render'] then 
                utils.cache[item].Text.Visible = library.flags[flag]
                else 
                    utils.cache[item].Text.Visible = false 
            end
        end)
        return utils.cache[item].render
    end
    
    utils.remove_esp = function(item)
        if esp.cache[item] then 
            local esp_table = esp.cache[item]
            esp_table.render:Disconnect()
            esp_table.Text:Remove()
            esp.cache[item] = nil 
        end
    end
    utils.updateBeams = function()
		local time = tick()
		for i = #utils.beams, 1, -1 do
			if utils.beams[i].beam  then
				local transparency = (time - utils.beams[i].time) - 2
				utils.beams[i].beam.Transparency = NumberSequence.new(transparency, transparency)
			else
				table.remove(utils.beams, i)
			end
		end
    end

    utils.create_tracer = function(pos1,pos2,color)
        local origin_part = utils.Create('Part',{
            Transparency =1, 
            Size = v3(1,1,1),
            CanCollide = false, 
            Parent = partsFolder,
            Anchored = true,
            Position = pos1,
        })
        local ending_part = utils.Create('Part',{
            Transparency =1, 
            Size = v3(1,1,1),
            CanCollide = false, 
            Parent = partsFolder,
            Anchored = true,
            Position = pos2,
        })
        local origin_att = Instance.new('Attachment',origin_part)
        local ending_att = Instance.new('Attachment',ending_part)
        local beam = utils.Create('Beam',{
            Texture = 'http://www.roblox.com/asset/?id=446111271',
			TextureMode = Enum.TextureMode.Wrap,
			TextureSpeed = 8,
			LightEmission = 1,
			LightInfluence = 1,
			TextureLength = 12,
			FaceCamera = true,
			Enabled = true,
			ZOffset = -1,
			Transparency = NumberSequence.new(0,0),
			Color = ColorSequence.new(color, newrgb(0, 0, 0)),
			Attachment0 = origin_att,
			Attachment1 = ending_att,
        })
		debris:AddItem(beam, 3)
		debris:AddItem(origin_att, 3)
		debris:AddItem(ending_att, 3)
        debris:AddItem(origin_part,3)
        debris:AddItem(ending_part, 3)
		local speedtween = TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
		tweenservice:Create(beam, speedtween, { TextureSpeed = 2 }):Play()
		beam.Parent = workspace
		table.insert(utils.beams, { beam = beam, time = tick() })
		utils.updateBeams()
		return beam
    end
end

--[[
examples:
utils.esp_item('',lp.Character.Head,true,'Example Item ESP')
utils.create_tracer(lp.Character.Head.Position, lp.Character.Head.Position + v3(20,0,20),fromrgb(255,255,255))]]
getgenv().utils = utils 
return utils 
