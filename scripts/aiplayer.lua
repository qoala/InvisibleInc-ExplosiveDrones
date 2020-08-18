local aiplayer = include( "sim/aiplayer" )
local simdefs = include( "sim/simdefs" )

-- Respawn camera drone missiles

local oldUpdateTracker = aiplayer.updateTracker

function aiplayer:updateTracker( sim, ... )
	oldUpdateTracker( self, sim, ... )

	if #sim:qedGetMissilesToSpawn() > 0 then
		-- Option: 0: disabled, 1: patrolling, 2: hunting
		-- Tracker: Past this threshold, aiplayer:returnToIdleSituation forces guards to be alerted.
		local spawnAlerted = (sim:getParams().difficultyOptions.qed_respawn_drones == 2 or sim:getTracker() >= simdefs.TRACKER_MAXCOUNT)
		for _, unitType in ipairs( sim:qedGetMissilesToSpawn() ) do
			self:doTrackerSpawn( sim, 1, unitType, not spawnAlerted )
		end
		sim:qedResetMissilesToSpawn()
	end
end
