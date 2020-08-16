local aiplayer = include( "sim/aiplayer" )

-- Respawn camera drone missiles

local oldUpdateTracker = aiplayer.updateTracker

function aiplayer:updateTracker( sim, ... )
	oldUpdateTracker( self, sim, ... )

	if #sim:qedGetMissilesToSpawn() > 0 then
		-- 0: disabled, 1: patrolling, 2: hunting
		local spawnAlerted = sim:getParams().difficultyOptions.qed_respawn_drones == 2
		for _, unitType in ipairs( sim:qedGetMissilesToSpawn() ) do
			self:doTrackerSpawn( sim, 1, unitType, not spawnAlerted )
		end
		sim:qedResetMissilesToSpawn()
	end
end
