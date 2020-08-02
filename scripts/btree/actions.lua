local Actions = include("sim/btree/actions")
local btree = include("sim/btree/btree")
local simdefs = include( "sim/simdefs" )

require("class")

function Actions.ReactToMissileTarget(sim, unit)
	local result = Actions.ReactToTarget(sim, unit)
	if result ~= simdefs.BSTATE_COMPLETE then
		return result
	end

	if not unit:isAiming() then
		unit:setAiming( true )
		if sim:getCurrentPlayer() == unit:getPlayerOwner() then
			-- Missile overwatch: wait until the next turn to attack.
			return simdefs.BSTATE_WAITINGFORPCTURN
		end
	end
	local target = unit:getBrain():getTarget()
	if not target then
		-- A pulse drone that had diagonal bonus vision turned, losing vision of the target.
		-- Or something equally weird has gone wrong to "succeed" the old action without a target.
		return simdefs.BSTATE_FAILED
	end
	local targetX,targetY = target:getLocation()
	log:write( "DEBUG: TRACKING TARGET %d (%d,%d)", target:getID(), targetX, targetY )

	return result
end
