-- Not the best loader ever but it works ig lmao
if getgenv().pie_loading then return end 
local has_found_game = false
local plr = game.GetService(game,'Players').LocalPlayer
local game_name = game.GetService(game, 'MarketplaceService'):GetProductInfo(game.PlaceId).Name

 -- This is for games that do not use custom lobbies/servers
local supported = {
    ['4588604953'] = 'https://scripts.luawl.com/11829/Criminality.lua',
    ['455366377'] = 'https://scripts.luawl.com/13636/TheStreetsv1.0.lua',
    ['6407649031'] = 'https://scripts.luawl.com/12202/pie.solutions.noscopearcade.lua',
    ['3398014311'] = 'https://scripts.luawl.com/13673/rt2.lua',
}
 -- This is for games with custom lobbies/servers
local supported_titles = {
    ['Criminality'] = 'https://scripts.luawl.com/11829/Criminality.lua',
}

for i,v in pairs(supported) do 
    if tonumber(i) == game.PlaceId or i == game.PlaceId then
        has_found_game = true
        loadstring(game:HttpGet(v))()
        break
    end 
end

for i,v in pairs(supported_titles) do 
    if string.find(game_name,tostring(i)) and not has_found_game then
        has_found_game = true
        loadstring(game:HttpGet(v))()
        break
    end
end

if not has_found_game then 
    loadstring(game:HttpGet('https://scripts.luawl.com/11954/pie.solutions.lua'))()
end

getgenv().pie_loading = true 
