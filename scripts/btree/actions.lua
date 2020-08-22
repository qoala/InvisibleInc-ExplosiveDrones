local Actions = include("sim/btree/actions")
local btree = include("sim/btree/btree")
local simdefs = include( "sim/simdefs" )

require("class")

function Actions.qed_ReactToMissileTarget(sim, unit)
	local result = Actions.ReactToTarget(sim, unit)
	if result ~= simdefs.BSTATE_COMPLETE then
		return result
	end

	local visualMissileOverwatch = not sim:getParams().difficultyOptions.qed_killer_visual_drones
	if visualMissileOverwatch and not unit:isAiming() then
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

	return result
end

-----
-- Behavior-fixes to ensure that melee units don't fail while moving towards their target
-- Copied from Advanced Guard Protocol by Cyberboy2000

local function canBeInterrupted(self)
	if self:getTraits().interrupted or self:getTraits().noInterrupt then
		return false
	end
	return self:getTraits().movePath or self:getTraits().modifyingExit or self:getTraits().lookingAround or self:getTraits().throwing
end

function Actions.qed_IgnoreOtherTargets(sim, unit)
	local x,y = unit:getBrain():getTarget():getLocation()
	unit:getBrain():getSenses():addInterest(x, y, simdefs.SENSE_SIGHT, simdefs.REASON_SHARED, unit:getBrain():getTarget())
	unit:getTraits().noPeripheralDetection = true
	unit.canBeInterrupted = canBeInterrupted
	unit:getTraits().noInterrupt = true
	return simdefs.BSTATE_COMPLETE
end

function Actions.qed_ResetTargeting(sim, unit)
	if not unit:getTraits().movePath then
		unit:getTraits().noPeripheralDetection = nil
		unit:getTraits().noInterrupt = nil
	end
	return simdefs.BSTATE_COMPLETE
end

-----
