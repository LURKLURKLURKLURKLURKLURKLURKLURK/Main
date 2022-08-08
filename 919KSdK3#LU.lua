if getgenv().pie_solutions_env then return end
local gamename = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
local supported_games = {
    4588604953, 455366377,
}
if not table.find(supported_games,game.PlaceId) and not string.find(gamename,'Criminality') then 
    loadstring(game:HttpGet('https://scripts.luawl.com/11864/Universal.lua'))()
    else 
        if game.PlaceId == 4588604953 then 
            loadstring(game:HttpGet('https://scripts.luawl.com/11829/Criminality.lua'))()
        elseif game.PlaceId == 455366377 then 
            loadstring(game:HttpGet('https://scripts.luawl.com/11488/TheStreets.lua'))()
        elseif string.find(gamename,'Criminality') then 
            loadstring(game:HttpGet('https://scripts.luawl.com/11829/Criminality.lua'))()
        end
end
