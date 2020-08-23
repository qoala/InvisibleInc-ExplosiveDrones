-- load and unload patchers for exsiting guarddefs.

local array = include( "modules/array" )
local guarddefs = include( "sim/unitdefs/guarddefs" )

local _M = {}

local function removeIfPresent( tbl, elem )
	local idx = array.find( tbl, elem )
	if idx then
		table.remove( tbl, idx )
	end
end

-- General changes applicable to all patchable drones.

local function armDrone( droneDef, armamentType )
	droneDef.abilities._OVERRIDE = nil  -- DEBUG views fail with mixed key and array indices
	-- 0: unarmed, 1: explosive, 2: discharge
	if armamentType == 2 then
		table.insert( droneDef.abilities, "qed_dischargedrone" )
		-- Respawn if Discharge is lethal to self (not that this is likely a good armament).
		droneDef.traits.qedMissileRespawn = droneDef.traits.empDeath
	else
		table.insert( droneDef.abilities, "qed_explosivedrone" )
		droneDef.traits.qedMissileRespawn = true
	end
	droneDef.brain = "qedMissileBrain"
	droneDef.traits.qedVisualMissile = true
	droneDef.traits.qedMissile = true
	droneDef.traits.pacifist = nil
end

local function disarmDrone( droneDef )
	removeIfPresent( droneDef.abilities, "qed_dischargedrone" )
	removeIfPresent( droneDef.abilities, "qed_explosivedrone" )
	droneDef.brain = "PacifistBrain"
	droneDef.traits.qedVisualMissile = nil
	droneDef.traits.qedMissile = nil
	droneDef.traits.qedMissileRespawn = nil
	droneDef.traits.pacifist = true
end

-- Patchers for each drone definition.

function _M.armCameraDrones( armamentType )
	armDrone( guarddefs.camera_drone, armamentType )
end

function _M.disarmCameraDrones()
	disarmDrone( guarddefs.camera_drone )
end

function _M.armNullDrones( armamentType )
	armDrone( guarddefs.null_drone, armamentType )
	if guarddefs.null_drone_LV2 then
		armDrone( guarddefs.null_drone_LV2, armamentType )
	end
end

function _M.disarmNullDrones()
	disarmDrone( guarddefs.null_drone )
	if guarddefs.null_drone_LV2 then
		disarmDrone( guarddefs.null_drone_LV2 )
	end
end

function _M.armPulseDrones( armamentType )
	if guarddefs.pulse_drone then
		armDrone( guarddefs.pulse_drone, armamentType )
		-- Missile AI that targets via pulse scans, not sight
		guarddefs.pulse_drone.traits.qedVisualMissile = nil
		guarddefs.pulse_drone.traits.qedScanMissile = true
	end
end

function _M.disarmPulseDrones()
	if guarddefs.pulse_drone then
		disarmDrone( guarddefs.pulse_drone )
		guarddefs.pulse_drone.traits.qedScanMissile = nil
	end
end

function _M.armRefitDrones( armamentType )
	if guarddefs.refit_drone then
		armDrone( guarddefs.refit_drone, armamentType )
		if guarddefs.refit_drone.traits.qedMissileRespawn then
			-- Respawn normal camera drones instead. The valuable data just exploded.
			guarddefs.refit_drone.traits.qedMissileRespawn = 'camera_drone'
		end
	end
end

function _M.disarmRefitDrones()
	if guarddefs.refit_drone then
		disarmDrone( guarddefs.refit_drone )
	end
end

function _M.armCeCrazyDrones( armamentType )
	if guarddefs.ce_crazy_drone then
		armDrone( guarddefs.ce_crazy_drone, armamentType )
	end
end

function _M.disarmNullDrones()
	if guarddefs.ce_crazy_drone then
		disarmDrone( guarddefs.ce_crazy_drone )
	end
end

return _M
