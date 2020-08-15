local aiplayer = include( "sim/aiplayer" )

-- Respawn camera drone missiles

local oldUpdateTracker = aiplayer.updateTracker

function aiplayer:updateTracker( sim, ... )
	oldUpdateTracker( self, sim, ... )

	if #sim:qedGetMissilesToSpawn() > 0 then
		for _, unitType in ipairs( sim:qedGetMissilesToSpawn() ) do
			self:doTrackerSpawn( sim, 1, unitType, true )
		end
		sim:qedResetMissilesToSpawn()
	end
end
