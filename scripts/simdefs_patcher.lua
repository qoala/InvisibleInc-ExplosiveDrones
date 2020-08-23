local array = include( "modules/array" )
local simdefs = include( "sim/simdefs" )

-- Guard spawn options to iterate over when patching.
local SPAWN_OPTIONS = { "NONE", "FEW", "LESS", "NORMAL", "MORE", "MANY", "SWARMING" }

-- Original drone spawns from vanilla/Generation Options+
-- Top-level keys correspond to guard spawn option
local OLD_CAMERA_SPAWN_TABLE = {
	NONE = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {},
		[11] = {},
		[12] = {},
		[13] = {},
		[14] = {},
		[15] = {},
		[16] = {},
		[17] = {},
		[18] = {},
		[19] = {},
		[20] = {},
	},
	FEW = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	LESS = {
		[1] = {},
		[2] = {},
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	NORMAL = {
		[1] = {},
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	MORE = {
		[1] = {},
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	MANY = {
		[1] = {},
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	SWARMING = {
		[1] = { "CAMERA_DRONE" },
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE" },
	},
}

-- Original drone spawns in OMNI from vanilla/Generation Options+
local OLD_CAMERA_OMNI_SPAWN_TABLE = {
	NONE = {},
	FEW = {},
	LESS = { "CAMERA_DRONE" },
	NORMAL = { "CAMERA_DRONE" },
	MORE = { "CAMERA_DRONE" },
	MANY = { "CAMERA_DRONE" },
	SWARMING = { "CAMERA_DRONE" },
}
-- Original level-scaled drone spawns in OMNI from AGP
local AGP_CAMERA_OMNI_SPAWN_TABLE = {
	NONE = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {},
		[11] = {},
		[12] = {},
		[13] = {},
		[14] = {},
		[15] = {},
		[16] = {},
		[17] = {},
		[18] = {},
		[19] = {},
		[20] = {},
	},
	FEW = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	LESS = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	NORMAL = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	MORE = {
		[1] = {},
		[2] = {},
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	MANY = {
		[1] = {},
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	SWARMING = {
		[1] = { "CAMERA_DRONE" },
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
}

-- Override drone spawns for explosive drones.
-- Top-level keys correspond to this mod's camera spawn option
local NEW_CAMERA_SPAWN_TABLE = {
	MORE = {
		[1] = { "CAMERA_DRONE" },
		[2] = { "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	MANY = {
		[1] = { "CAMERA_DRONE" },
		[2] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
	SWARMING = {
		[1] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[2] = { "CAMERA_DRONE", "CAMERA_DRONE" },
		[3] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[4] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[5] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[6] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[7] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[8] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[9] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[10] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[11] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[12] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[13] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[14] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[15] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[16] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[17] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[18] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[19] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
		[20] = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	},
}

-- Override drone spawns in OMNI from explosive drones
local NEW_CAMERA_OMNI_SPAWN_TABLE = {
	MORE = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	MANY = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
	SWARMING = { "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE", "CAMERA_DRONE" },
}

-----
-- Local Helpers
-----

-- Replace the current quantity of camera drones with the specified one.
local function setSpawnList( spawnList, cameraSpawnList )
	array.removeIf( spawnList, function( spawn) return spawn == "CAMERA_DRONE" end )
	array.concat( spawnList, cameraSpawnList )
end

local function setSpawnTable( spawnOption, cameraSpawnTable )
	for i=1,20 do
		setSpawnList( simdefs.SPAWN_TABLE[spawnOption][i], cameraSpawnTable[i] )
	end
end

local function hasAgpOmniSpawnTable( spawnOption )
	local valueType = type(simdefs.OMNI_SPAWN_TABLE[spawnOption][1])
	if valueType == "nil" or valueType == "string" then
		-- each spawnOption contains a single list of guard descriptors
		return false
	elseif valueType == "table" and (type(simdefs.OMNI_SPAWN_TABLE[spawnOption][1][1]) == "nil" or type(simdefs.OMNI_SPAWN_TABLE[spawnOption][1][1]) == "string") then
		-- each spawnOption contains a list per difficulty level
		return true
	end
	-- Another mod has done something else strange here.
	assert( false)
end

local function setOmniSpawnTable( spawnOption, cameraSpawnList )
	setSpawnList( simdefs.OMNI_SPAWN_TABLE[spawnOption], cameraSpawnList )
end

-- Use the max of AGP-OMNI and our non-OMNI spawn for each difficulty level.
local function setAgpOmniSpawnTable( spawnOption, cameraSpawnTable )
	for i=1,20 do
		local chosenList
		if #(AGP_CAMERA_OMNI_SPAWN_TABLE[spawnOption][i]) > #(cameraSpawnTable[i]) then
			chosenList = AGP_CAMERA_OMNI_SPAWN_TABLE[i]
		else
			chosenList = cameraSpawnTable[i]
		end

		setSpawnList( simdefs.OMNI_SPAWN_TABLE[spawnOption][i], chosenList )
	end
end

-----
-- Exported Patcher Functions
-----

local function resetAllSpawnTables()
	for _, spawnOption in ipairs( SPAWN_OPTIONS ) do
		if simdefs.SPAWN_TABLE[spawnOption] then
			setSpawnTable( spawnOption, OLD_CAMERA_SPAWN_TABLE[spawnOption] )
			if hasAgpOmniSpawnTable( spawnOption ) then
				setOmniSpawnTable( spawnOption, AGP_CAMERA_OMNI_SPAWN_TABLE[spawnOption] )
			else
				setOmniSpawnTable( spawnOption, OLD_CAMERA_OMNI_SPAWN_TABLE[spawnOption] )
			end
		end
	end
end

local function modifyAllSpawnTables( cameraSpawnOption )
	for _, spawnOption in ipairs( SPAWN_OPTIONS ) do
		if simdefs.SPAWN_TABLE[spawnOption] then
			setSpawnTable( spawnOption, NEW_CAMERA_SPAWN_TABLE[cameraSpawnOption] )
			if hasAgpOmniSpawnTable( spawnOption ) then
				setAgpOmniSpawnTable( spawnOption, NEW_CAMERA_SPAWN_TABLE[cameraSpawnOption] )
			else
				setOmniSpawnTable( spawnOption, NEW_CAMERA_OMNI_SPAWN_TABLE[cameraSpawnOption] )
			end
		end
	end
end

return {
	resetAllSpawnTables = resetAllSpawnTables,
	modifyAllSpawnTables = modifyAllSpawnTables,
}
