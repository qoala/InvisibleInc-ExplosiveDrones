local mathutil = include( "modules/mathutil" )
local simdefs = include( "sim/simdefs" )
local simunit = include( "sim/simunit" )

-- Respawn camera drone missiles

local oldKillUnit = simunit.killUnit

function simunit:killUnit( sim, ... )
	oldKillUnit( self, sim, ... )

	if self:getTraits().corpseTemplate and self:getTraits().qedMissileRespawn then
		sim:qedAddMissilesToSpawn( self:getUnitData().id )
	end
end

-- Pulse Drone scan behavior

local oldOnEndTurn = simunit.onEndTurn

function simunit:onEndTurn( sim, ... )
	oldOnEndTurn( self, sim, ... )

	if self:getTraits().qedDelayedScanInterests and #self:getTraits().qedDelayedScanInterests > 0 then
		if self:canAct() and self:getLocation() and self:getPlayerOwner() and self:getPlayerOwner():isNPC() then
			local x0, y0 = self:getLocation()
			local bestDist, bestTarget
			for _, target in ipairs(self:getTraits().qedDelayedScanInterests) do
				local dist = mathutil.dist2d( x0, y0, target.x, target.y )
				if not bestDist or dist < bestDist then
					bestDist = dist
					bestTarget = target
				end
			end
			if bestTarget then
				self:getBrain():getSenses():addInterest(bestTarget.x, bestTarget.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, bestTarget.unit, true )
				sim:processReactions( self )
			end
		end

		-- Clear interests regardless of whether or not we were able to add them.
		self:getTraits().qedDelayedScanInterests = {}
	end
end
