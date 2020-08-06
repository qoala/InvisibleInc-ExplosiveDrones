local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )

-- Returns true if the unit knows or suspects the target unit is in its current location.
-- If not, we force missile-like drones to path around like normal dynamicImpass guards,
-- giving the player a chance to react before the drone explodes.
local function knowsAboutTargetUnit( sim, unit, targetUnit )
	local x,y = targetUnit:getLocation()
	if unit:getBrain():getSenses():hasTarget(targetUnit) then
		local target = unit:getBrain():getSenses().targets[targetUnit:getID()]
		if target.x == x and target.y == y then
			return true
		end
	end
	for _, interest in ipairs( unit:getBrain():getSenses().interests ) do
		if interest.sourceUnit == targetUnit and interest.x == x and interest.y == y then
			return true
		end
	end
	return false
end

local oldCanMoveUnit = simquery.canMoveUnit

function simquery.canMoveUnit( sim, unit, x, y, ... )
	local canMove, canMoveReason = oldCanMoveUnit( sim, unit, x, y, ... )

	if canMove and unit:getTraits().qedVisualMissile and unit:getBrain() then
		local player = unit:getPlayerOwner()
		local endCell = sim:getCell( x, y )
		for _, cellUnit  in ipairs( endCell.units ) do
			if (simquery.isEnemyAgent( player, cellUnit )
				and simquery.couldUnitSee( sim, unit, cellUnit, true )
				and not knowsAboutTargetUnit( sim, unit, cellUnit )) then
				-- Trying to diagonally step into an agent around cover. Force a repath.
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			end
		end
	end

	return canMove, canMoveReason
end

local oldCanSoftPath = simquery.canSoftPath

function simquery.canSoftPath( sim, unit, startcell, endcell, ... )
	local isDiagonal = (startcell.x + 1 == endcell.x or startcell.x - 1 == endcell.x) and (startcell.y + 1 == endcell.y or startcell.y - 1 == endcell.y)
	if isDiagonal and unit:getTraits().qedVisualMissile and unit:getBrain() then
		-- Don't plan diagonal moves that would be blocked by the above canMoveUnit
		local player = unit:getPlayerOwner()
		for _, cellUnit in ipairs( endcell.units ) do
			if (simquery.isEnemyAgent( player, cellUnit )
					and simquery.couldUnitSee( sim, unit, cellUnit, true )
					and not knowsAboutTargetUnit( sim, unit, cellUnit )) then
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			end
		end
	end

	return oldCanSoftPath( sim, unit, startcell, endcell, ... )
end
