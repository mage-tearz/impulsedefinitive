local function LoadEnts()
	if file.Exists( "impulse/"..string.lower(game.GetMap())..".txt", "DATA") then
		local savedEnts = util.JSONToTable( file.Read( "impulse/" .. string.lower( game.GetMap() ) .. ".txt" ) )
		for v,k in pairs(savedEnts) do
			local x = ents.Create(k.class)
			x:SetPos(k.pos)
			x:SetAngles(k.angle)
			if k.class == "prop_physics" or k.class == "prop_dynamic" then
				x:SetModel(k.model)
			end
			x.impulseSaveEnt = true
			x:Spawn()
			x:Activate()
		end
	end
end

concommand.Add("impulse_saveents", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	local savedEnts = {}

	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			table.insert(savedEnts, {pos =  k:GetPos(), angle = k:GetAngles(), class = k:GetClass(), model = k:GetModel()})
		end
	end

	file.Write("impulse/"..string.lower(game.GetMap())..".txt", util.TableToJSON(savedEnts))

	ply:AddChatText("All marked ents have been saved, all un-marked ents have been omitted from the save.")
end)

concommand.Add("impulse_reloadents", function(ply)
	if not ply:IsSuperAdmin() then return end
	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			k:Remove()
		end
	end

	LoadEnts()

	ply:AddChatText("All saved ents have been reloaded.")
end)

concommand.Add("impulse_marksaveent", function(ply)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) then
		ent.impulseSaveEnt = true
		ply:AddChatText("Marked "..ent:GetClass().." for saving.")
	end
end)

concommand.Add("impulse_removesaveent", function(ply)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) then
		ent.impulseSaveEnt = nil
		ent:Remove()
		ply:AddChatText("Removed "..ent:GetClass().." for saving.")
	end
end)

hook.Add("InitPostEntity", "impulseLoadSavedEnts", function()
	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			k:Remove()
		end
	end

	LoadEnts()
end)