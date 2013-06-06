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
local CATEGORY_NAME = "TTT Admin"
local gamemode_error="The current gamemode is not trouble in terrorest town"


--[[
	ulx.slaynr( calling_ply, target_plys, num_slay, should_slaynr )
	calling_ply		: PlayerObject	: The player who used the command
	target_plys		: PlayerObject	: The player(s) who will have the effects of the command applied to them.
	num_slay		: number		: Numer of rounds to add or remove the the target(s) slay total.
	should_slaynr	: boolean		: Hidden, differentiates between ulx.slaynr and, ulx.rslaynr.
	
	The slaynr command slays <target(s)> next round.
]]
function ulx.slaynr( calling_ply, target_plys, num_slay, should_slaynr )
		if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		local affected_plys = {}
	
		for i=1, #target_plys do
			v = target_plys[ i ]
	
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif num_slay == 0 then
				local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0

				if slays_left == 0 then
					ulx.fancyLogAdmin( calling_ply, "#T will not be slain next round.", target_plys )
				elseif slays_left == 1 then
					ulx.fancyLogAdmin( calling_ply, "#T will be slain next round.", target_plys )
				elseif slays_left > 1 then
					ulx.fancyLogAdmin( calling_ply, "#T will be slain for the next ".. tostring(slays_left) .." rounds." , target_plys )
				end
			elseif num_slay < 0 then
				ULib.tsayError( calling_ply, "<times> must be a positive interger.", true )
			else
				current_slay = tonumber(v:GetPData("slaynr_slays")) or 0
				if not should_slaynr then
					new_slay =current_slay + num_slay
				else
					new_slay =current_slay - num_slay
				end

				if new_slay > 0 then
					v:SetPData("slaynr_slays", new_slay)
				else
					v:RemovePData("slaynr_slays")
				end

				table.insert( affected_plys, v )
			end

			local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0
			local slays_removed = (current_slay - slays_left) or 0 

			if slays_removed > 0 and slays_left ==0 then
				chat_message = ("#A removed ".. slays_removed .." round(s) of slaying from #T. They/you will not be slain next round.")
			elseif slays_removed==0 then
				chat_message = ("#T will not be slain next round.")
			elseif slays_removed > 0 then
				chat_message = ("#A removed ".. slays_removed .." round(s) of slaying from #T.")
			elseif slays_left == 1 then
				chat_message = ("#A will slay #T next round.")
			elseif slays_left > 1 then
				chat_message = ("#A will slay #T for the next ".. tostring(slays_left) .." rounds.")
			end
		end
		ulx.fancyLogAdmin( calling_ply, chat_message, affected_plys )
	end
end
local slaynr = ulx.command( CATEGORY_NAME, "ulx slaynr", ulx.slaynr, "!slaynr" )
slaynr:addParam{ type=ULib.cmds.PlayersArg }
slaynr:addParam{ type=ULib.cmds.NumArg, default=1, hint="times, 0 to view", ULib.cmds.optional, ULib.cmds.round }
slaynr:addParam{ type=ULib.cmds.BoolArg, invisible=true }
slaynr:defaultAccess( ULib.ACCESS_ADMIN )
slaynr:help( "Slays target(s) for a number of rounds" )
slaynr:setOpposite( "ulx rslaynr", {_, _, _, true}, "!rslaynr" )

-------------------------------------------Helper functions---------------------------------------------
hook.Add("TTTBeginRound", "SlayPlayersNextRound", function()
	local affected_plys = {}

	for _,v in pairs(player.GetAll()) do
		local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0

		if v:Alive() and slays_left > 0 then
			local slays_left=slays_left -1
			if slays_left == 0 then
				v:RemovePData("slaynr_slays")
			else
				v:SetPData("slaynr_slays", slays_left)
			end

			v:Kill()
			table.insert( affected_plys, v )
		end
	end

	local slay_message = ""
	for i=1, #affected_plys do

		slay_message = ( slay_message .. affected_plys[i]:Nick())
		if i > 1 then
			slay_message = ( slay_message .. ", " )
		end
	end

	local slay_message_context
	if #affected_plys == 1 then slay_message_context ="was" else slay_message_context ="were" end
	if #affected_plys ~= 0 then
		ULib.tsay(_, slay_message .. " ".. slay_message_context .." slain.")
	end
end)

hook.Add("PlayerSpawn", "Inform" ,function(ply)
	local slays_left = tonumber(ply:GetPData("slaynr_slays")) or 0
	local chat_message =""

	if slays_left == 1 then
		chat_message = (chat_message .. "You will be slain this round.")
	end
	if slays_left > 1 then
		chat_message = (chat_message .. " and ".. (slays_left - 1) .." round(s) after the current round.")
	end
	ply:ChatPrint(chat_message)
end)
-----------------------------------------------End-------------------------------------------------


--[[
	ulx.slay( calling_ply, target_plys )
	calling_ply		: PlayerObject	: The player who used the command
	target_plys		: PlayerObject	: The player(s) who will have the effects of the command applied to them.
	
	The ulx.vslaynr command returns the number of slays for the <target(s)>
]]
function ulx.vslaynr( calling_ply, target_plys )
	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
		for i=1, #target_plys do
			v = target_plys[ i ]

			local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0

			if slays_left == 0 then
				ulx.fancyLogAdmin( calling_ply,"#T will not be slain next round.", target_plys )
			elseif slays_left == 1 then
				ulx.fancyLogAdmin( calling_ply,"#T will be slain next round.", target_plys )
			elseif slays_left > 1 then
				ulx.fancyLogAdmin( calling_ply,"#T will be slain for the next ".. tostring(slays_left) .." rounds." , target_plys )
			end
		end
	end
end
local vslaynr = ulx.command( CATEGORY_NAME, "ulx vslaynr", ulx.vslaynr, "!vslaynr" )
vslaynr:addParam{ type=ULib.cmds.PlayersArg }
vslaynr:defaultAccess( ULib.ACCESS_ADMIN )
vslaynr:help( "Views the number of rounds the <target(s)> will be slain." )
-----------------------------------------------End-------------------------------------------------

------------------------------ Next Round  ------------------------------
ulx.next_round = {}
local function updateNextround()
	table.Empty( ulx.next_round ) -- Don't reassign so we don't lose our refs
    
    table.insert(ulx.next_round,"traitor") -- Add "traitor" to the table.
    table.insert(ulx.next_round,"detective") -- Add "detective" to the table.	
    table.insert(ulx.next_round,"unmark") -- Add "unmark" to the table.

end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXNextRoundUpdate", updateNextround )
updateNextround() -- Init


local PlysMarkedForTraitor = {}
local PlysMarkedForDetective = {}
function ulx.nextround( calling_ply, target_plys, next_round )
    local affected_plys = {}
	local unaffected_plys = {}
    for i=1, #target_plys do
        local v = target_plys[ i ]
        local ID = v:UniqueID()
        
        if next_round == "traitor" then
            if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true then
                ULib.tsayError( calling_ply, "that player is already marked for the next round", true )
            else
                PlysMarkedForTraitor[ID] = true
                table.insert( affected_plys, v ) 
            end
        end
        if next_round == "detective" then
            if PlysMarkedForTraitor[ID] == true or PlysMarkedForDetective[ID] == true then
                ULib.tsayError( calling_ply, "that player is already marked for the next round!", true )
            else
                PlysMarkedForDetective[ID] = true
                table.insert( affected_plys, v ) 
            end
        end
        if next_round == "unmark" then
            if PlysMarkedForTraitor[ID] == true then
                PlysMarkedForTraitor[ID] = false
                table.insert( affected_plys, v )
            end
            if PlysMarkedForDetective[ID] == true then
                PlysMarkedForDetective[ID] = false
                table.insert( affected_plys, v )
            end
        end
    end    
        
    if next_round == "unmark" then
        ulx.fancyLogAdmin( calling_ply, true, "#A has unmarked #T ", affected_plys )
    else
        ulx.fancyLogAdmin( calling_ply, true, "#A marked #T to be #s next round.", affected_plys, next_round )
    end
end        
local nxtr= ulx.command( CATEGORY_NAME, "ulx nr", ulx.nextround, "!nr" )
nxtr:addParam{ type=ULib.cmds.PlayersArg }
nxtr:addParam{ type=ULib.cmds.StringArg, completes=ulx.next_round, hint="Next Round", error="invalid role \"%s\" specified", ULib.cmds.restrictToCompletes }
nxtr:defaultAccess( ULib.ACCESS_SUPERADMIN )
nxtr:help( "Forces the target to be a detective/traitor in the following round." )

local function TraitorMarkedPlayers()
	for k, v in pairs(PlysMarkedForTraitor) do
		if v then
			ply = player.GetByUniqueID(k)
			ply:SetRole(ROLE_TRAITOR)
            ply:AddCredits(GetConVarNumber("ttt_credits_starting"))
			ply:ChatPrint("You have been made a traitor by an admin this round.")
			PlysMarkedForTraitor[k] = false
		end
	end
end
hook.Add("TTTBeginRound", "Admin_Round_Traitor", TraitorMarkedPlayers)

local function DetectiveMarkedPlayers()
	for k, v in pairs(PlysMarkedForDetective) do
		if v then
			ply = player.GetByUniqueID(k)
			ply:SetRole(ROLE_DETECTIVE)
            ply:AddCredits(GetConVarNumber("ttt_credits_starting"))
            ply:Give("weapon_ttt_wtester")
			ply:ChatPrint("You have been made a detective by an admin this round.")
			PlysMarkedForDetective[k] = false
		end
	end
end
hook.Add("TTTBeginRound", "Admin_Round_Detective", DetectiveMarkedPlayers)