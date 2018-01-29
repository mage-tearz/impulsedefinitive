/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

function IMPULSE:ForceDermaSkin()
	return "impulse"
end

local blur = Material( "pp/blurscreen" )

function impulse.blur( panel, layers, density, alpha )
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

local impulseVars = {}

function meta:getIVar(var)
    local vars = impulseVars[self:UserID()]
    return vars and vars[var] or nil
end

local function RetrievePlayerVar(userID, var, value)
    local ply = Player(userID)
    impulseVars[userID] = impulseVars[userID] or {}

    hook.Call("impulseVarChanged", nil, ply, var, impulseVars[userID][var], value)
    impulseVars[userID][var] = value

    -- Backwards compatibility
    if IsValid(ply) then
        ply.impulseVars = impulseVars[userID]
    end
end

local function doRetrieve()
    local userID = net.ReadUInt(16)
    local var, value = impulse.readNetimpulseVar()

    RetrievePlayerVar(userID, var, value)
end
net.Receive("impulse_PlayerVar", doRetrieve)

local function doRetrieveRemoval()
    local userID = net.ReadUInt(16)
    local vars = impulseVars[userID] or {}
    local var = impulse.readNetimpulseVarRemoval()
    local ply = Player(userID)

    hook.Call("impulseVarChanged", nil, ply, var, vars[var], nil)

    vars[var] = nil
end
net.Receive("impulse_PlayerVarRemoval", doRetrieveRemoval)

local function InitializeimpulseVars(len)
    local plyCount = net.ReadUInt(8)

    for i = 1, plyCount, 1 do
        local userID = net.ReadUInt(16)
        local varCount = net.ReadUInt(impulse.impulse_ID_BITS + 2)

        for j = 1, varCount, 1 do
            local var, value = impulse.readNetimpulseVar()
            RetrievePlayerVar(userID, var, value)
        end
    end
end
net.Receive("impulse_InitializeVars", InitializeimpulseVars)
timer.Simple(0, fp{RunConsoleCommand, "_sendimpulsevars"})

net.Receive("impulse_impulseVarDisconnect", function(len)
    local userID = net.ReadUInt(16)
    impulseVars[userID] = nil
end)

timer.Create("impulseCheckifitcamethrough", 15, 0, function()
    for _, v in ipairs(player.GetAll()) do
        if v:getIVar("rpname") then continue end

        RunConsoleCommand("_sendimpulsevars")
        return
    end

    timer.Remove("impulseCheckifitcamethrough")
end)

function IMPULSE:ContextMenuOpen()
	return false
end
