--[=[-------------------------------------------------------------------------------------------
║                              Trouble in Terrorist Town Commands                              ║
                                    By: Skillz and Bender180                                   ║
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
local CATEGORY_NAME  = "TTT Fun"
local gamemode_error = "The current gamemode is not trouble in terrorest town"

function GamemodeCheck(calling_ply)
	if not GetConVarString("gamemode") == "terrortown" then
		ULib.tsayError( calling_ply, gamemode_error, true )
		return true
	else
		return false
	end
end

--[Helper Functions]---------------------------------------------------------------------------
--[End]----------------------------------------------------------------------------------------



--[Ulx Completes]------------------------------------------------------------------------------
ulx.get_equipment = {}
function GetEquipment()
	table.Empty( ulx.get_equipment )

	for role, _ in pairs(EquipmentItems) do
		for _, item in pairs(EquipmentItems[role]) do
			if not table.HasValue(ulx.get_equipment, tostring(item.name)) then
				table.insert(ulx.get_equipment, tostring(item.name))
			end
		end
	end
end
hook.Add( "Initialize", "ULXGetEquipment", GetEquipment )
hook.Add( ULib.HOOK_UCLCHANGED, "ULXGetEquipment", GetEquipment )
--[End]----------------------------------------------------------------------------------------



--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces <target(s)> to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.equipment( calling_ply, target_plys, equipment )
	if GamemodeCheck(calling_ply) then return end

	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif GetRoundState() == 1 or GetRoundState() == 2 then
    		ULib.tsayError( calling_ply, "The round has not begun!", true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
		elseif v:HasEquipmentItem(FindEquipmentMatch(name, equipment, id )) then
			ULib.tsayError( calling_ply, v:Nick() .. " already has that equipment!", true )
		else
			local match = FindEquipmentMatch(name, equipment, id )
			if match then 
				v:GiveEquipmentItem(match)
				GiveEquipmentWeapon(v:UniqueID(), match)
			end
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A gave #T " .. equipment, affected_plys)
end
local equipment = ulx.command( CATEGORY_NAME, "ulx give equipment", ulx.equipment )
equipment:addParam{ type=ULib.cmds.PlayersArg }
equipment:addParam{ type=ULib.cmds.StringArg, completes=ulx.get_equipment, hint="Equipment", error="Invalid equpiment:\"%s\" specified", ULib.cmds.restrictToCompletes }
equipment:defaultAccess( ULib.ACCESS_SUPERADMIN )
equipment:help( "Give <target(s)> specified equpiment." )
--[Helper Functions]---------------------------------------------------------------------------
function FindEquipmentMatch(type, equipment, return_type )
	for role, _ in pairs(EquipmentItems) do
		for _, item in pairs(EquipmentItems[role]) do
			if equipment == item[type] then
				return item[return_type]
			else
				return false
			end
		end
	end
end
--[End]----------------------------------------------------------------------------------------



--[Toggle spectator]---------------------------------------------------------------------------
--[[ulx.spec][Forces <target(s)> to and from spectator.]
@param  {[PlayerObject]} calling_ply   [The player who used the command.]
@param  {[PlayerObject]} target_plys   [The player(s) who will have the effects of the command applied to them.]
--]]
function ulx.credits( calling_ply, target_plys, amount, should_silent )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
    	for i=1, #target_plys do
    	    target_plys[ i ]:AddCredits(amount)
    	end
		ulx.fancyLogAdmin( calling_ply, true, "#A gave #T #i credits", target_plys, amount )
	end
end
local credits = ulx.command( CATEGORY_NAME, "ulx credits", ulx.credits, "!credits")
credits:addParam{ type=ULib.cmds.PlayersArg }
credits:addParam{ type=ULib.cmds.NumArg, hint="Credits", ULib.cmds.round }
credits:defaultAccess( ULib.ACCESS_SUPERADMIN )
credits:setOpposite( "ulx silent credits", {_, _, _, true}, "!scredits", true )
credits:help( "Gives the <target(s)> credits." )
--[End]----------------------------------------------------------------------------------------