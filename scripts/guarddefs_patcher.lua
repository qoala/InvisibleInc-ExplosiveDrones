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

local function armDrone( droneDef, armamentType, patchOpts )
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

	if patchOpts and patchOpts.reduceControlTime then
		droneDef.traits.qedOldControlTimerMax = droneDef.traits.controlTimerMax
		droneDef.traits.controlTimerMax = 1
	end
end

local function disarmDrone( droneDef )
	removeIfPresent( droneDef.abilities, "qed_dischargedrone" )
	removeIfPresent( droneDef.abilities, "qed_explosivedrone" )
	droneDef.brain = "PacifistBrain"
	droneDef.traits.qedVisualMissile = nil
	droneDef.traits.qedMissile = nil
	droneDef.traits.qedMissileRespawn = nil
	droneDef.traits.pacifist = true
	if droneDef.traits.qedOldControlTimerMax then
		droneDef.traits.controlTimerMax = droneDef.traits.qedOldControlTimerMax
		droneDef.traits.qedOldControlTimerMax = nil
	end
end

-- Patchers for each drone definition.

function _M.armCameraDrones( armamentType, patchOpts )
	armDrone( guarddefs.camera_drone, armamentType, patchOpts )
end

function _M.disarmCameraDrones()
	disarmDrone( guarddefs.camera_drone )
end

function _M.armNullDrones( armamentType, patchOpts )
	armDrone( guarddefs.null_drone, armamentType, patchOpts )
	if guarddefs.null_drone_LV2 then
		armDrone( guarddefs.null_drone_LV2, armamentType, patchOpts )
	end
end

function _M.disarmNullDrones()
	disarmDrone( guarddefs.null_drone )
	if guarddefs.null_drone_LV2 then
		disarmDrone( guarddefs.null_drone_LV2 )
	end
end

function _M.armPulseDrones( armamentType, patchOpts )
	if guarddefs.pulse_drone then
		armDrone( guarddefs.pulse_drone, armamentType, patchOpts )
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

function _M.armRefitDrones( armamentType, patchOpts )
	if guarddefs.refit_drone then
		armDrone( guarddefs.refit_drone, armamentType, patchOpts )
		local droneDef = guarddefs.refit_drone
		-- Respawn normal camera drones instead. The valuable data just exploded.
		if droneDef.traits.qedMissileRespawn then
			droneDef.traits.qedMissileRespawn = 'camera_drone'
		end
		-- Keep these controllable for longer
		if droneDef.traits.qedOldControlTimerMax then
			droneDef.traits.controlTimerMax = droneDef.traits.qedOldControlTimerMax
		end
	end
end

function _M.disarmRefitDrones()
	if guarddefs.refit_drone then
		disarmDrone( guarddefs.refit_drone )
	end
end

function _M.armCeCrazyDrones( armamentType, patchOpts )
	if guarddefs.ce_crazy_drone then
		armDrone( guarddefs.ce_crazy_drone, armamentType, patchOpts )
	end
end

function _M.disarmNullDrones()
	if guarddefs.ce_crazy_drone then
		disarmDrone( guarddefs.ce_crazy_drone )
	end
end

return _M
