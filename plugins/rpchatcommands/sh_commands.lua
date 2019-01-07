
local developerIcon = Material("vgui/wave.png")
local ooccolour = {
    ['management'] = Color(235,1,1),
    ['superadmin'] = Color(235,1,1),
    ['admin'] = Color(53,209,22),
    ['moderator'] = Color(34,88,216),
    ['donator'] = Color(212,185,9),
    ['user'] = Color(255,255,255)
}


impulse.RegisterChatCommand('ooc','Global out of character chat', function(sender, args, input, id)
    for v,k in pairs(player.GetAll()) do
        k:AddChatText(true, id, sender, Color(200,0,0), '[OOC] ', ooccolour[sender:GetUserGroup()], sender:SteamName(), Color(255,255,255), ": ", input)
    end
end)
