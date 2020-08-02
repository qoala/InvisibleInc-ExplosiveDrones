local simdefs = include( "sim/simdefs" )
local simengine = include( "sim/engine" )
local simquery = include( "sim/simquery" )

local oldScanCell = simengine.scanCell

function simengine:scanCell( unit, cell, ignoreDisguise, scanGrenade )
	oldScanCell( self, unit, cell, ignoreDisguise, scanGrenade )

	local player = unit:getPlayerOwner()
	-- Skip if the missile already has an interest. Should go there instead.
	if unit:getTraits().pulseScanMissile and player and player:isNPC() then
		local currentInterest = unit:getBrain():getSenses():getCurrentInterest()
		if currentInterest and simquery.isEnemyAgent( player, currentInterest.sourceUnit, true ) then
			-- Don't interrupt an in-progress attack run
			return
		end
		for i, cellUnit in ipairs( cell.units ) do
			if simquery.isEnemyAgent( player, cellUnit, ignoreDisguise ) then
				unit:getBrain():getSenses():addInterest( cell.x, cell.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, cellUnit, ignoreDisguise )
				unit:useMP( unit:getMP(), self )
			end
		end
	end
end
