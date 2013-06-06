function GetWeaponList(ROLE_TRAITOR, ROLE_INNOCENT, ROLE_DETECTIVE)
	local tttweaponlist = {}
	for k,v in pairs(weapons.GetList()) do
		if v.Base == "weapon_tttbase" then
			table.insert(tttweaponlist, v)
		end
	end
	return tttweaponlist
end
--^ You missed out "do" for your for loop. You really should get a linter.