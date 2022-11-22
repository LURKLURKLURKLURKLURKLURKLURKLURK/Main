local players,runservice,replicatedstorage = game.GetService(game,'Players'),game.GetService(game,'RunService'),game.GetService(game,'ReplicatedStorage')
local camera,lp = workspace.CurrentCamera,players.LocalPlayer
local findfirstchild,findfirstchildofclass,findfirstancestor = game.FindFirstChild,game.FindFirstChildOfClass,game.FindFirstAncestor;
local wtvp, wtsp = camera.WorldToViewportPoint,camera.WorldToScreenPoint; 
local mfloor,mabs,mround,mclamp,cos,atan2,sin,rad = math.floor,math.abs,math.round,math.clamp,math.cos,math.atan2,math.sin,math.rad;
local v2,v3,cf,c3rgb,c3new,gbb = Vector2.new,Vector3.new,CFrame.new,Color3.fromRGB,Color3.new,workspace.GetBoundingBox;

local esp = {
    highlight_target = {enabled = false, color = c3rgb(255,0,0),target = ''},
    teamcheck        = false,
    enabled          = false, 
    boldtext         = false, 
    limitdistance    = false,
    renderdistance   = 50,
    outlines         = {enabled = false, color = c3rgb(0,0,0)},
    fontsize         = 13,
    font             = 2,
    text             = {enabled = false, color = c3rgb(255,255,255)},
    misc_layout      = {
        ['arrows']    = {transparency = 1, enabled = false, size = 15, color = c3rgb(255,255,255),radius = 500},
        ['box']       = {inner = false, inner_trans = 0.5, inner_color = c3rgb(0,0,0), enabled = false, color = c3rgb(255,255,255)},
        ['health']    = {enabled = false, lower = c3rgb(255,0,0),higher = c3rgb(0,255,0)},
        ['highlight'] = {enabled = false, outline = c3rgb(255,255,255),fill = c3rgb(255,255,255),outlinetrans = 0,filltrans = 0},
    },
    text_layout      = {
        ['health']   = {enabled = false},
        ['name']     = {enabled = false},
        ['distance'] = {enabled = false},
        ['tool']     = {enabled = false},
    },
    cache = {},
};

function esp.rotatev2(V2, r)
    local c = math.cos(r);
    local s = math.sin(r);
    return v2(c * V2.X - s * V2.Y, s * V2.X + c * V2.Y);
end;
function esp.getmagnitude(p1,p2)
    return (p1 - p2).Magnitude
end;
function esp.getplr_fromchar(plr)
    local found_plr
    if plr then 
        found_plr = players:GetPlayerFromCharacter(plr)
    end
    return found_plr
end;

function esp.get_char(plr)
    local CHARACTER = plr.Character
    return CHARACTER
end;

function esp.getprimarypart(model)
    local found_part = nil
    if model and esp.getplr_fromchar(model) then
        if findfirstchild(model,'HumanoidRootPart') then 
            found_part = findfirstchild(model,'HumanoidRootPart')
        end
        if found_part == nil and findfirstchild(model,'LowerTorso') then 
            found_part = findfirstchild(model,'LowerTorso') 
        end
        if found_part == nil and model.PrimaryPart then 
            found_part = model.PrimaryPart 
        end
    end
    return found_part
end;

function esp.validate(plr)
    local plr_character = esp.get_char(plr)
    
    if plr_character and findfirstchild(plr_character,'Humanoid') and esp.getprimarypart(plr_character) then 
        return true 
        else
            return false 
    end
end;

function esp.inst(instance,prop)
    local INEW = Instance.new(instance)
    
    local s, e  = pcall(function()
        for i,v in next, prop do 
            INEW[i] = v 
        end
    end)
    if not s and e then warn('pie.solutions ER: '..tostring(e)) end 
    return INEW
end;

function esp.draw(drawing,prop)
    local NEWDRAWING = Drawing.new(drawing)
    
    local s, e = pcall(function()
        for i,v in next, prop do 
            NEWDRAWING[i] = v 
        end
    end)
    if not s and e then warn('pie.solutions ER: '..tostring(e)) end
    return NEWDRAWING
end;

function esp.setall(array,prop,value)
    for i,v in next, array do
        if tostring(v) ~= 'Highlight' and tostring(i) ~= 'arrow' and tostring(i) ~= 'arrow_outline' then 
            v[prop] = value
        end
    end
end;

function esp.remove_plr(plr)
    if rawget(esp.cache,plr) then 
        for i,v in pairs(esp.cache[plr]) do
            v:Remove()
        end;
        esp.cache[plr] = nil ;
    end;
end;

function esp.check(char,distance)
    local check_passed = false;
    local check_passed_dist = false;
    local check_passed_team = false;
    local check_passed_health = false;
    if char then
        local real_plr = esp.getplr_fromchar(char)
        if esp.limitdistance then 
            if distance <= esp.renderdistance then 
                check_passed_dist = true 
                else 
                    check_passed_dist = false
            end
            else 
                check_passed_dist = true 
        end
        if findfirstchildofclass(char,'Humanoid').Health >= 0.2 then 
            check_passed_health = true 
            else 
                check_passed_health = false
        end;
        if esp.teamcheck then 
            if real_plr.Team ~= lp.Team then 
                check_passed_team = true 
                else 
                    check_passed_team = false
            end
            else 
                check_passed_team = true 
        end
    end;
    
    if check_passed_dist == true and check_passed_health == true and check_passed_team == true then 
        check_passed = true 
        else 
            check_passed = false 
    end;
    
    return check_passed;
end;

function esp.add_plr(plr)
    local plr_tab = {}
    plr_tab.inner_box = esp.draw('Square',{
        Filled = true,
    });
    plr_tab.box_outline = esp.draw('Square',{
        Filled = false,
        Transparency = 1,
        Thickness = 3,
    });
    plr_tab.box = esp.draw('Square',{
        Filled = false,
        Transparency = 1,
        Thickness = 1,
    });
    plr_tab.healthbar_outline = esp.draw('Line',{
        Thickness = 3,
    });
    plr_tab.healthbar = esp.draw('Line',{
        Thickness = 1,
    });
    plr_tab.name = esp.draw('Text',{
        Center = true,
    });
    plr_tab.name_bold = esp.draw('Text',{
        Center = true,
        Outline = false,
        Transparency = 1,
    });
    plr_tab.distance = esp.draw('Text',{
        Center = true,
    });
    plr_tab.distance_bold = esp.draw('Text',{
        Center = true,
        Outline = false,
    });
    plr_tab.tool = esp.draw('Text',{
        Center = true,
    });
    plr_tab.tool_bold = esp.draw('Text',{
        Center = true,
        Outline = false,
    });
    plr_tab.health = esp.draw('Text',{
        Center = false,
    });
    plr_tab.health_bold = esp.draw('Text',{
        Center = false,
        Outline = false,
    });
    plr_tab.highlight = esp.inst('Highlight',{
        
    });
    plr_tab.arrow_outline = esp.draw('Triangle',{
        Thickness = 3,
        Filled = false,
    });
    plr_tab.arrow = esp.draw('Triangle',{
        Thickness = 1,
        Filled = true,
    });
    esp.cache[plr] = plr_tab;
end

function esp.update_esp(plr,array)
    if esp.validate(plr) then 
        
        local character = esp.get_char(plr)
        local rootpart = esp.getprimarypart(character)
        local screenpos, onscreen = wtvp(camera, rootpart.Position)
        local scale_factor = 1 / (screenpos.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
        local width, height = math.floor(45 * scale_factor), math.floor(65 * scale_factor)
        local size = Vector2.new(width,height)
        if size.X < 3 or size.Y < 6 then 
		    size = v2(5,10) -- makes it look proper at distance 
		end
        local position = Vector2.new(screenpos.X - size.X / 2,screenpos.Y - size.Y / 2)

		position = v2(mfloor(position.X),mfloor(position.Y))
		local bottom_bounds = 0
        local top_bounds = 0 
        local bottom_offset = v2(mfloor(size.X / 2 + position.X), mfloor(size.Y + position.Y + 1))
        local top_offset = v2(mfloor(size.X / 2 + position.X), mfloor(position.Y - 16))
        
		local distance = esp.getmagnitude(rootpart.Position,camera.CFrame.p)
		local check = esp.check(character,distance)
		local s, e = pcall(function()
		    if not onscreen and check and esp.enabled then
		        if esp.misc_layout['arrows'].enabled then 
    		        local proj = camera.CFrame:PointToObjectSpace(rootpart.CFrame.p);
                    local ang  = atan2(proj.Z, proj.X);
                    local dir  = v2(cos(ang), sin(ang));
                    local a    = (dir * esp.misc_layout['arrows'].radius * .5) + camera.ViewportSize / 2;
                    local b, c = a - esp.rotatev2(dir, rad(35)) * esp.misc_layout['arrows'].size, a - esp.rotatev2(dir, -rad(35)) * esp.misc_layout['arrows'].size
                    array.arrow_outline.PointA = a;
                    array.arrow_outline.PointB = b;
                    array.arrow_outline.PointC = c;
                    
                    array.arrow.PointA = a;
                    array.arrow.PointB = b;
                    array.arrow.PointC = c;
                    array.arrow.Color = esp.misc_layout['arrows'].color 
                    array.arrow.Transparency = esp.misc_layout['arrows'].transparency 
                    
                    array.arrow.Visible = true 
                    array.arrow_outline.Visible = esp.outlines.enabled
                    array.arrow_outline.Color = esp.misc_layout['arrows'].color 
                    else 
                        array.arrow_outline.Visible = false 
                        array.arrow.Visible = false
		        end
                else 
                    array.arrow_outline.Visible = false 
                    array.arrow.Visible = false 
		    end
		    if onscreen and check and esp.enabled then
		        if esp.misc_layout['highlight'].enabled then 
		            array.highlight.Parent = game.GetService(game,'CoreGui')
		            array.highlight.Adornee = character 
		            array.highlight.Enabled = true 
		            array.highlight.FillColor = esp.misc_layout['highlight'].fill
		            array.highlight.DepthMode = 'AlwaysOnTop'
		            array.highlight.OutlineColor = esp.misc_layout['highlight'].outline
		            array.highlight.FillTransparency = esp.misc_layout['highlight'].filltrans 
		            array.highlight.OutlineTransparency = esp.misc_layout['highlight'].outlinetrans
		            else 
		                array.highlight.Enabled = false
		        end
	
		        if esp.misc_layout['box'].enabled then
		            
		            array.box.Visible = true 
		            array.box.Size = size
		            array.box.Position = position
		            if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		           array.box.Color = esp.highlight_target.color 
    		        else 
    		           array.box.Color = esp.misc_layout['box'].color 
		            end
		            
		            array.box_outline.Size = size 
		            array.box_outline.Position = position
		            array.box_outline.Visible = esp.outlines.enabled
		            array.box_outline.Color = esp.outlines.color
		            
		            array.inner_box.Size = v2(array.box.Size.X-3,array.box.Size.Y-3)
                    array.inner_box.Position = v2(position.X+1.5,position.Y+1.5)
                    array.inner_box.Transparency = esp.misc_layout['box'].inner_trans 
                    array.inner_box.Color = esp.misc_layout['box'].inner_color 
                    array.inner_box.Visible = esp.misc_layout['box'].inner
		            else
		                array.inner_box.Visible = false
		                array.box_outline.Visible = false 
		                array.box.Visible = false 
		        end
		        
		        
		        if esp.misc_layout['health'].enabled then
		            array.healthbar.Transparency = 1 
		            array.healthbar_outline.Transparency = 1
                    array.healthbar.Visible = true 
                    array.healthbar.Color = esp.misc_layout['health'].lower:lerp(esp.misc_layout['health'].higher,character.Humanoid.Health  / character.Humanoid.MaxHealth);
                    array.healthbar.From = v2((position.X - 5), position.Y + size.Y)
                    array.healthbar.To = v2(array.healthbar.From.X, array.healthbar.From.Y - (character.Humanoid.Health  / character.Humanoid.MaxHealth) * size.Y)
                    array.healthbar_outline.Visible = esp.outlines.enabled 
                    array.healthbar_outline.Color = esp.outlines.color
                    array.healthbar_outline.From = v2(array.healthbar.From.X, position.Y + size.Y + 1 )
                    array.healthbar_outline.To = v2(array.healthbar.From.X, (array.healthbar.From.Y -1 * size.Y) - 1)
                    else 
                        array.healthbar.Visible = false 
                        array.healthbar_outline.Visible = false
		        end
            
		        if esp.text.enabled then 
		            if esp.text_layout['name'].enabled then
		                array.name.Transparency = 1 
		                array.name_bold.Transparency = 0.5
		                array.name.Visible = true 
		                array.name.Text = tostring(plr)
		                array.name.Size = esp.fontsize 
		                array.name.Font = esp.font 
		                if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		               array.name.Color = esp.highlight_target.color 
    		            else 
    		               array.name.Color = esp.text.color 
		                end
		                array.name.Outline = esp.outlines.enabled 
		                array.name.OutlineColor = esp.outlines.color 
		                array.name.Position = v2(top_offset.X,top_offset.Y - (top_bounds))
		                if esp.boldtext then 
		                    array.name_bold.Visible = true 
		                    array.name_bold.Size = esp.fontsize 
		                    array.name_bold.Font = esp.font 
		                    if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		                    array.name_bold.Color = esp.highlight_target.color 
    		                    else 
    		                       array.name_bold.Color = esp.text.color 
		                    end
		                    array.name_bold.Text = array.name.Text
		                    array.name_bold.Position = v2(array.name.Position.X + 1, array.name.Position.Y)
		                    else 
		                        array.name_bold.Visible = false 
		                end
		                else 
		                    array.name.Visible = false 
		                    array.name_bold.Visible = false 
		            end
		            
		            
		            if esp.text_layout['distance'].enabled then
		                array.distance.Transparency = 1 
		                array.distance_bold.Transparency = 0.5
		                array.distance.Visible = true 
		                array.distance.Text = tostring(mfloor(distance))..'s'
		                array.distance.Size = esp.fontsize 
		                array.distance.Font = esp.font 
		                if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		                array.distance.Color = esp.highlight_target.color 
    		            else 
    		                array.distance.Color = esp.text.color 
		                end
		                array.distance.Outline = esp.outlines.enabled 
		                array.distance.OutlineColor = esp.outlines.color 
		                array.distance.Position = v2(bottom_offset.X, bottom_offset.Y + bottom_bounds)
		                bottom_bounds += 14
		                if esp.boldtext then 
		                    array.distance_bold.Visible = true 
		                    array.distance_bold.Size = esp.fontsize 
		                    array.distance_bold.Font = esp.font 
		                    if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		                    array.distance_bold.Color = esp.highlight_target.color 
    		                    else 
    		                       array.distance_bold.Color = esp.text.color 
		                    end
		                    array.distance_bold.Text = array.distance.Text
		                    array.distance_bold.Position = v2(array.distance.Position.X + 1, array.distance.Position.Y)
		                    else 
		                        array.distance_bold.Visible = false 
		                end
		                else 
		                    array.distance.Visible = false 
		                    array.distance_bold.Visible = false 
		            end
		            
		            if esp.text_layout['health'].enabled then
		                local From = Vector2.new((position.X - 5), position.Y + size.Y)
		                local To = Vector2.new(From.X, From.Y - 1 * size.Y)
		                array.health.Transparency = 1 
		                array.health_bold.Transparency = 0.5
		                array.health.Visible = true 
		                array.health.Text = tostring(mfloor(character.Humanoid.Health))
		                array.health.Size = esp.fontsize 
		                array.health.Font = esp.font 
		                array.health.Color = esp.text.color
		                array.health.Outline = esp.outlines.enabled 
		                array.health.OutlineColor = esp.outlines.color 
		                array.health.Position = Vector2.new(position.X - 30, To.Y)
		                if esp.boldtext then 
		                    array.health_bold.Visible = true 
		                    array.health_bold.Size = esp.fontsize 
		                    array.health_bold.Font = esp.font 
		                    array.health_bold.Color = array.health.Color
		                    array.health_bold.Text = array.health.Text
		                    array.health_bold.Position = v2(array.health.Position.X + 1, array.health.Position.Y)
		                    else 
		                        array.health_bold.Visible = false 
		                end
		                else 
		                    array.health.Visible = false 
		                    array.health_bold.Visible = false 
		            end
		            
		            
		            if esp.text_layout['tool'].enabled then
		                local tool_found = findfirstchildofclass(character,'Tool')
		                array.tool.Transparency = 1 
		                array.tool_bold.Transparency = 0.5
		                array.tool.Visible = true 
		                array.tool.Text = tool_found ~= nil and tool_found.Name or 'none'
		                array.tool.Size = esp.fontsize 
		                array.tool.Font = esp.font
		                if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
		                    array.tool.Color = esp.highlight_target.color 
		                    else 
		                       array.tool.Color = esp.text.color 
		                end
		                --array.tool.Color = esp.text.color 
		                array.tool.Outline = esp.outlines.enabled 
		                array.tool.OutlineColor = esp.outlines.color 
		                array.tool.Position = v2(bottom_offset.X, bottom_offset.Y + bottom_bounds)
		                bottom_bounds += 14
		                if esp.boldtext then 
		                    array.tool_bold.Visible = true 
		                    array.tool_bold.Size = esp.fontsize 
		                    array.tool_bold.Font = esp.font 
		                    if esp.highlight_target.enabled and esp.highlight_target.target == tostring(character) then
    		                    array.tool_bold.Color = esp.highlight_target.color 
    		                    else 
    		                       array.tool_bold.Color = esp.text.color 
		                    end
		                    array.tool_bold.Text = array.tool.Text
		                    array.tool_bold.Position = v2(array.tool.Position.X + 1, array.tool.Position.Y)
		                    else 
		                        array.tool_bold.Visible = false 
		                end
		                else 
		                    array.tool.Visible = false 
		                    array.tool_bold.Visible = false 
		            end
		            else 
		                array.tool.Visible = false 
		                array.tool_bold.Visible = false 
		                
		                array.health_bold.Visible = false 
		                array.health.Visible = false 
		                
		                array.name.Visible = false 
		                array.name_bold.Visible = false 
		                
		                array.distance.Visible = false 
		                array.distance_bold.Visible = false 
		                
		        end
		    else
		        array.highlight.Enabled = false
		        esp.setall(array,'Visible',false)
		    end
		end)
		if not s and e then
		    print('ESP ERROR: '..tostring(e))
		    esp.setall(array,'Visible',false)
		    array.highlight.Enabled = false
		end
        else
            array.arrow_outline.Visible = false 
            array.arrow.Visible = false
            esp.setall(array,'Visible',false)
            array.highlight.Enabled = false
    end
end


for i,plr in next, players:GetChildren() do
    if plr ~= lp then 
        esp.add_plr(plr)
    end
end
players.PlayerAdded:Connect(function(plr)
    esp.add_plr(plr)
end)
players.PlayerRemoving:Connect(function(plr)
    esp.remove_plr(plr)
end)
runservice.RenderStepped:Connect(function()
    for player, drawings in next, esp.cache do
        if drawings and player then
            esp.update_esp(player, drawings);
        end
    end
end)
getgenv().esp = esp 
return esp 
