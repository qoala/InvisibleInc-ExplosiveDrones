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
	if armamentType == "DISCHARGE" then
		table.insert( droneDef.abilities, "qed_dischargedrone" )
		droneDef.traits.qedMissileRespawn = nil
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

function _M.armCameraDrones()
	armDrone( guarddefs.camera_drone )
end

function _M.disarmCameraDrones()
	disarmDrone( guarddefs.camera_drone )
end

function _M.armNullDrones()
	armDrone( guarddefs.null_drone, "DISCHARGE" )
	if guarddefs.null_drone_LV2 then
		armDrone( guarddefs.null_drone_LV2, "DISCHARGE" )
	end
end

function _M.disarmNullDrones()
	disarmDrone( guarddefs.null_drone )
	if guarddefs.null_drone_LV2 then
		disarmDrone( guarddefs.null_drone_LV2 )
	end
end

function _M.armPulseDrones()
	if guarddefs.pulse_drone then
		armDrone( guarddefs.pulse_drone )
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

return _M
