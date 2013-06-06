--[=[-------------------------------------------------------------------------------------------
║                              Trouble in Terrorist Town Commands                              ║
║                                   By: Skillz and Bender180                                   ║
║                              ╔═════════╗╔═════════╗╔═════════╗                               ║
║                              ║ ╔═╗ ╔═╗ ║║ ╔═╗ ╔═╗ ║║ ╔═╗ ╔═╗ ║                               ║
║                              ╚═╝ ║ ║ ╚═╝╚═╝ ║ ║ ╚═╝╚═╝ ║ ║ ╚═╝                               ║
║──────────────────────────────────║ ║────────║ ║────────║ ║───────────────────────────────────║
║──────────────────────────────────║ ║────────║ ║────────║ ║───────────────────────────────────║
║──────────────────────────────────╚═╝────────╚═╝────────╚═╝───────────────────────────────────║
║                  All code included is completely original or extracted                       ║
║            from the base ttt files that are provided with the ttt gamemode.                  ║
║                                                                                              ║
---------------------------------------------------------------------------------------------]=]
local CATEGORY_NAME  = "TTT Admin"
local gamemode_error = "The current gamemode is not trouble in terrorest town"



--[Ulx Completes]------------------------------------------------------------------------------
ulx.target_role = {}
function updateRoles()
	table.Empty( ulx.target_role )
	    
    table.insert(ulx.target_role,"traitor")
    table.insert(ulx.target_role,"detective")
    table.insert(ulx.target_role,"innocent")
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXRoleNamesUpdate", updateRoles )
updateRoles()
--[End]----------------------------------------------------------------------------------------



--[Global Helper Functions][Used by more than one command.]------------------------------------
--[[send_messages][Sends messages to player(s)]
@param  {[PlayerObject]} v       [The player(s) to send the message to.]
@param  {[String]}       message [The message that will be sent.]
--]]
function send_messages(v, message)
	if type(v) == "Players" then
		v:ChatPrint(message)
	elseif type(v) == "table" then
		for i=1, #v do
			v[i]:ChatPrint(message)
		end
	end
end

--[[corpse_find][Finds the corpse of a given player.]
@param  {[PlayerObject]} v       [The player that to find the corpse for.]
--]]
function corpse_find(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end

--[[corpse_remove][removes the corpse given.]
@param  {[Ragdoll]} corpse [The corpse to be removed.]
--]]
function corpse_remove(corpse)
	CORPSE.SetFound(corpse, false)
	if string.find(corpse:GetModel(), "zm_", 6, true) then
		corpse:Remove()
	elseif corpse.player_ragdoll then
		corpse:Remove()
	end
end
--[End]----------------------------------------------------------------------------------------



--[Force role]---------------------------------------------------------------------------------
--[[ulx.force][Forces <target(s)> to become a specified role.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       target_role   [The role that target player(s) will have there role set to.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.force( calling_ply, target_plys, target_role, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

		local affected_plys = {}
		local starting_credits=GetConVarNumber("ttt_credits_starting")

		local role
		local role_grammar
		local role_string
		local role_credits

	    if target_role ==  "traitor"   or target_role == "t" then role = ROLE_TRAITOR;   role_grammar="a ";  role_string = "traitor"   role_credits = starting_credits end
	    if target_role ==  "detective" or target_role == "d" then role = ROLE_DETECTIVE; role_grammar="a ";  role_string = "detective" role_credits = starting_credits end
	    if target_role ==  "innocent"  or target_role == "i" then role = ROLE_INNOCENT;  role_grammar="an "; role_string = "innocent"  role_credits = 0                end
	    
	    for i=1, #target_plys do
			local v = target_plys[ i ]
			local current_role = v:GetRole()
	
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif GetRoundState() == 1 or GetRoundState() == 2 then
	    		ULib.tsayError( calling_ply, "The round has not begun!", true )
			elseif role == nil then
	    		ULib.tsayError( calling_ply, "Invalid role :\"" .. target_role .. "\" specified", true )
			elseif not v:Alive() then
				ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
			elseif current_role == role then
	    		ULib.tsayError( calling_ply, v:Nick() .. " is already " .. role_string, true )
			else
				v:ResetEquipment()
				RemoveLoadoutWeapons(v)
				RemoveBoughtWeapons(v)

	            v:SetRole(role)
	            v:SetCredits(role_credits)
	            SendFullStateUpdate()

	            GiveLoadoutItems(v)
	            GiveLoadoutWeapons(v)

	            table.insert( affected_plys, v )
	        end
	    end
	    ulx.fancyLogAdmin( calling_ply, should_silent, "#A forced #T to become the role of " .. role_grammar .."#s.", affected_plys, role_string )
	    send_messages(affected_plys, "Your role has been set to " .. role_string .. "." )
	end
end
local force = ulx.command( CATEGORY_NAME, "ulx force", ulx.force, "!force" )
force:addParam{ type=ULib.cmds.PlayersArg }
force:addParam{ type=ULib.cmds.StringArg, completes=ulx.target_role, hint="Role" }
force:addParam{ type=ULib.cmds.BoolArg, invisible=true }
force:defaultAccess( ULib.ACCESS_SUPERADMIN )
force:setOpposite( "ulx sforce", {_, _, _, true}, "!sforce", true )
force:help( "Force <target(s)> to become a specified role." )

--[Helper Functions]---------------------------------------------------------------------------
--[[GetLoadoutWeapons][Returns the loadout weapons ]
@param  {[Number]} r [The role of the loadout weapons to be returned]
@return {[table]}    [A table of loadout weapons for the given role.]
--]]
function GetLoadoutWeapons(r)
	local tbl = {
		[ROLE_INNOCENT] = {},
		[ROLE_TRAITOR]  = {},
		[ROLE_DETECTIVE]= {}
	};
	for k, w in pairs(weapons.GetList()) do
		if w and type(w.InLoadoutFor) == "table" then
			for _, wrole in pairs(w.InLoadoutFor) do
				table.insert(tbl[wrole], WEPS.GetClass(w))
			end
		end
	end
	return tbl[r]
end

--[[RemoveBoughtWeapons][Removes previously bought weapons from the shop.]
@param  {[PlayerObject]} ply [The player who will have their bought weapons removed.]
--]]
function RemoveBoughtWeapons(ply)
	for _, wep in pairs(weapons.GetList()) do
		local wep_class = WEPS.GetClass(wep)
		if wep and type(wep.CanBuy) == "table" then
			for _, weprole in pairs(wep.CanBuy) do
				if weprole == ply:GetRole() and ply:HasWeapon(wep_class) then
					ply:StripWeapon(wep_class)
				end
			end
		end
	end
end

--[[RemoveLoadoutWeapons][Removes all loadout weapons for the given player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons removed.]
--]]
function RemoveLoadoutWeapons(ply)
	local weps = GetLoadoutWeapons( GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole() )
	for _, cls in pairs(weps) do
		if ply:HasWeapon(cls) then
			ply:StripWeapon(cls)
		end
	end
end

--[[GiveLoadoutWeapons][Gives the loadout weapons for that player.]
@param  {[PlayerObject]} ply [The player who will have their loadout weapons given.]
--]]
function GiveLoadoutWeapons(ply)
	local r = GetRoundState() == ROUND_PREP and ROLE_INNOCENT or ply:GetRole()
	local weps = GetLoadoutWeapons(r)
	if not weps then return end

	for _, cls in pairs(weps) do
		if not ply:HasWeapon(cls) then
			ply:Give(cls)
		end
	end
end

--[[GiveLoadoutItems][Gives the default loadout items for that role.]
@param  {[PlayerObject]} ply [The player who the equipment will be given to.]
--]]
function GiveLoadoutItems(ply)
	local items = EquipmentItems[ply:GetRole()]
	if items then
		for _, item in pairs(items) do
			if item.loadout and item.id then
				ply:GiveEquipmentItem(item.id)
			end
		end
	end
end
--[End]----------------------------------------------------------------------------------------



--[Respawn]------------------------------------------------------------------------------------
--[[ulx.respawn][Respawns <target(s)>]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawn( calling_ply, target_plys, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		local affected_plys = {}
	
		for i=1, #target_plys do
			local v = target_plys[ i ]
	
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif GetRoundState() == 1 then
	    		ULib.tsayError( calling_ply, "Waiting for players!", true )
			elseif v:Alive() then
				ULib.tsayError( calling_ply, v:Nick() .. " is already alive!", true )
			else
				local corpse = corpse_find(v)
				if corpse then corpse_remove(corpse) end

				v:SpawnForRound( true )
				v:SetCredits( ( (v:GetRole() == ROLE_INNOCENT) and 0 ) or GetConVarNumber("ttt_credits_starting") )
				
				table.insert( affected_plys, v )
			end
		end
		ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned #T!", affected_plys )
		send_messages(affected_plys, "You have been respawned.")
	end
end
local respawn = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn")
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:addParam{ type=ULib.cmds.BoolArg, invisible=true }
respawn:defaultAccess( ULib.ACCESS_SUPERADMIN )
respawn:setOpposite( "ulx silent respawn", {_, _, true}, "!srespawn", true )
respawn:help( "Respawns <target(s)>." )
--[End]----------------------------------------------------------------------------------------



--[Respawn teleport]---------------------------------------------------------------------------
--[[ulx.respawntp][Respawns <target(s)>]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_ply    [The player who will have the effects of the command applied to them.]
@param  {[Boolean]}      should_silent [Hidden, determines weather the output will be silent or not.]
--]]
function ulx.respawntp( calling_ply, target_ply, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

		local affected_ply = {}	
		if not calling_ply:IsValid() then
			Msg( "You are the console, you can't teleport or teleport others since you can't see the world!\n" )
			return
		elseif ulx.getExclusive( target_ply, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		elseif GetRoundState() == 1 then
	    		ULib.tsayError( calling_ply, "Waiting for players!", true )
		elseif target_ply:Alive() then
			ULib.tsayError( calling_ply, target_ply:Nick() .. " is already alive!", true )
		else
			local t  = {}
			t.start  = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
			t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
			t.filter = target_ply
			if target_ply ~= calling_ply then
				t.filter = { target_ply, calling_ply }
			end
			local tr = util.TraceEntity( t, target_ply )
		
			local pos = tr.HitPos

			local corpse = corpse_find(target_ply)
			if corpse then corpse_remove(corpse) end

			target_ply:SpawnForRound( true )
			target_ply:SetCredits( ((target_ply:GetRole() == ROLE_INNOCENT) and 0) or GetConVarNumber("ttt_credits_starting") )
		
			target_ply:SetPos( pos )
			table.insert( affected_ply, target_ply )
		end
		ulx.fancyLogAdmin( calling_ply, should_silent ,"#A respawned and teleported #T!", affected_ply )
		send_messages(affected_plys, "You have been respawned and teleported.")
	end
end
local respawntp = ulx.command( CATEGORY_NAME, "ulx respawntp", ulx.respawntp, "!respawntp")
respawntp:addParam{ type=ULib.cmds.PlayerArg }
respawntp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
respawntp:defaultAccess( ULib.ACCESS_SUPERADMIN )
respawntp:setOpposite( "ulx silent respawntp", {_, _, true}, "!srespawntp", true )
respawntp:help( "Respawns <target> to a specific location." )
--[End]----------------------------------------------------------------------------------------



--[Karma]--------------------------------------------------------------------------------------
--[[ulx.karma][Sets the <target(s)> karma to a given amount.]
@param  {[PlayerObject]} calling_ply [The player who used the command.]
@param  {[PlayerObject]} target_plys [The player(s) who will have the effects of the command applied to them.]
@param  {[Number]}       amount      [The number the target's karma will be set to.]
--]]
function ulx.karma( calling_ply, target_plys, amount )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
    	for i=1, #target_plys do
			target_plys[ i ]:SetBaseKarma( amount )
    	    target_plys[ i ]:SetLiveKarma( amount )
    	end	
  	end
	ulx.fancyLogAdmin( calling_ply, "#A set the karma for #T to #i", target_plys, amount )
end
local karma = ulx.command( CATEGORY_NAME, "ulx karma", ulx.karma, "!karma" )
karma:addParam{ type=ULib.cmds.PlayersArg }
karma:addParam{ type=ULib.cmds.NumArg, min=0, max=10000, default=1000, hint="Karma", ULib.cmds.optional, ULib.cmds.round }
karma:defaultAccess( ULib.ACCESS_ADMIN )
karma:help( "Changes the <target(s)> Karma." )
--[End]----------------------------------------------------------------------------------------



--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces <target(s)> to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.tttspec( calling_ply, target_plys, should_unspec )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else

	    for i=1, #target_plys do
			local v = target_plys[ i ]

			if should_unspec then
			    v:ConCommand("ttt_spectator_mode 0")
			else
			    v:ConCommand("ttt_spectator_mode 1")
			    v:ConCommand("ttt_cl_idlepopup")
			end
	    end
	    if should_unspec then
	   		ulx.fancyLogAdmin( calling_ply, "#A has forced #T to join the world of the living.", target_plys )
	   	else
	    	ulx.fancyLogAdmin( calling_ply, "#A has forced #T to spectate.", target_plys )
	   	end
	end
end
local tttspec = ulx.command( CATEGORY_NAME, "ulx spec", ulx.tttspec, "!fspec" )
tttspec:addParam{ type=ULib.cmds.PlayersArg }
tttspec:addParam{ type=ULib.cmds.BoolArg, invisible=true }
tttspec:defaultAccess( ULib.ACCESS_ADMIN )
tttspec:setOpposite( "ulx unspec", {_, _, true}, "!unspec" )
tttspec:help( "Forces the <target(s)> to/from spectator." )
--[End]----------------------------------------------------------------------------------------