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

local function armDrone( droneDef )
	table.insert( droneDef.abilities, "qed_explosivedrone" )
	droneDef.traits.pacifist = nil
end

local function disarmDrone( droneDef )
	removeIfPresent( droneDef.abilities, "qed_explosivedrone" )
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
	armDrone( guarddefs.null_drone )
	if guarddefs.null_drone_LV2 then
		armDrone( guarddefs.null_drone_LV2 )
	end
end

function _M.disarmNullDrones()
	disarmDrone( guarddefs.null_drone )
	if guarddefs.null_drone_LV2 then
		disarmDrone( guarddefs.null_drone_LV2 )
	end
end

function _M.armPulseDrones()
	armDrone( guarddefs.pulse_drone )
end

function _M.disarmPulseDrones()
	disarmDrone( guarddefs.pulse_drone )
end

return _M
