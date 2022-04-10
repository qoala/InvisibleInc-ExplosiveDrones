
local function earlyInit( modApi )
	modApi.requirements =
	{
		"Contingency Plan", "Sim Constructor", "Function Library", "Disguise Fix",
		"Advanced Guard Protocol", "Generation Options+",
		"Permadeath"  -- Replaces sim/abilities/lastWords
	}
end

local function init( modApi )
	local scriptPath = modApi:getScriptPath()

	modApi:addGenerationOption("arm_camera", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_CAMERA,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_CAMERA_TIP, {
		noUpdate=true,
		values={ 0, 1, 2, },
		value=1,
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.UNARMED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.EXPLOSIVE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISCHARGE,
		}
	})
	modApi:addGenerationOption("arm_null", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_NULL,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_NULL_TIP, {
		noUpdate=true,
		values={ 0, 1, 2, },
		value=2,  -- Null drones can survive an EMP and are more valuable remaining in place.
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.UNARMED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.EXPLOSIVE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISCHARGE,
		}
	})
	modApi:addGenerationOption("arm_pulse", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_PULSE,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_REFIT_TIP, {
		noUpdate=true,
		values={ 0, 1, 2, },
		value=1,
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.UNARMED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.EXPLOSIVE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISCHARGE,
		}
	})
	modApi:addGenerationOption("arm_refit", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_REFIT,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_REFIT_TIP, {
		noUpdate=true,
		values={ 0, 1, 2, },
		value=1,
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.UNARMED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.EXPLOSIVE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISCHARGE,
		}
	})
	modApi:addGenerationOption("arm_ce_crazy", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_CRAZY,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARM_CRAZY_TIP, {
		noUpdate=true,
		values={ 0, 1, 2, },
		value=1,
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.UNARMED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.EXPLOSIVE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISCHARGE,
		}
	})

	modApi:addGenerationOption("camera_spawns", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.CAMERA_SPAWNS,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.CAMERA_SPAWNS_TIP, {
		noUpdate=true,
		values={ "UNCHANGED", "MORE", "MANY", "SWARMING" },
		value="MORE",
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.SPAWN_UNCHANGED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.SPAWN_MORE,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.SPAWN_MANY,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.SPAWN_SWARMING,
		}
	})
	modApi:addGenerationOption("respawn_drones", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.RESPAWN_DRONES,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.RESPAWN_DRONES_TIP, {
		noUpdate=true,
		values={ 0, 1, 2 },
		value=1,
		strings={
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.DISABLED,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.PATROLLING,
			STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.HUNTING,
		}
	})

	-- modApi:addGenerationOption("armed_when_hacked", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARMED_WHEN_HACKED,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.ARMED_WHEN_HACKED_TIP, {noUpdate=true, enabled=false})
	modApi:addGenerationOption("hack_time", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.HACK_TIME,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.HACK_TIME_TIP, {noUpdate=true, enabled=true})
	modApi:addGenerationOption("killer_visual_drones", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.KILLER_CAMERA_DRONES,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.KILLER_CAMERA_DRONES_TIP, {noUpdate=true, enabled=false})
	modApi:addGenerationOption("killer_pulse_drones", STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.KILLER_PULSE_DRONES,  STRINGS.QED_EXPLOSIVEDRONES.OPTIONS.KILLER_PULSE_DRONES_TIP, {noUpdate=true, enabled=false})

	include( scriptPath .. "/aiplayer" )
	include( scriptPath .. "/engine" )
	include( scriptPath .. "/simquery" )
	include( scriptPath .. "/simunit" )
	include( scriptPath .. "/btree/situations/combat" )
	include( scriptPath .. "/btree/actions" )
	include( scriptPath .. "/btree/qed_missilebrain" )

	modApi:addAbilityDef( "lastWords", scriptPath .. "/abilities/lastWords" )
	modApi:addAbilityDef( "qed_dischargedrone", scriptPath .. "/abilities/qed_dischargedrone" )
	modApi:addAbilityDef( "qed_explosivedrone", scriptPath .. "/abilities/qed_explosivedrone" )
end

local function unload( modApi )
	local scriptPath = modApi:getScriptPath()

	local simdefs_patcher = include( scriptPath .. "/simdefs_patcher" )
	simdefs_patcher.resetAllSpawnTables()

	local guarddefs_patcher = include( scriptPath .. "/guarddefs_patcher" )
	guarddefs_patcher.disarmCameraDrones()
	guarddefs_patcher.disarmNullDrones()
	guarddefs_patcher.disarmPulseDrones()
	guarddefs_patcher.disarmRefitDrones()
end

local function load( modApi, options, params )
	local scriptPath = modApi:getScriptPath()

	unload( modApi )
	if params then
		if options["respawn_drones"] and options["respawn_drones"].value ~= 0 then
			params.qed_respawn_drones = options["respawn_drones"].value
		end
		if options["killer_visual_drones"] and options["killer_visual_drones"].enabled then
			params.qed_killer_visual_drones = true
		else
			params.qed_killer_visual_drones = false
		end
		if options["killer_pulse_drones"] and options["killer_pulse_drones"].enabled then
			params.qed_killer_pulse_drones = true
		else
			params.qed_killer_pulse_drones = false
		end
		if options["armed_when_hacked"] and options["armed_when_hacked"].enabled then
			params.qed_explosive_armed_when_hacked = true
		else
			params.qed_explosive_armed_when_hacked = false
		end
	end

	-- Update spawn tables, if requested. (UNCHANGED was handled by unload, above)
	if options["camera_spawns"] and options["camera_spawns"].value ~= "UNCHANGED" then
		local simdefs_patcher = include( scriptPath .. "/simdefs_patcher" )
		simdefs_patcher.modifyAllSpawnTables( options["camera_spawns"].value )
	end
end

local function lateLoad( modApi, options, params )
	local scriptPath = modApi:getScriptPath()

	local patchOpts = {}

	if options["hack_time"] and options["hack_time"].enabled then
		patchOpts.reduceControlTime = true
	end

	-- Patch guarddefs during lateload, after AGP has potentially saved and restored them.
	local guarddefs_patcher = include( scriptPath .. "/guarddefs_patcher" )
	if options["arm_camera"] and options["arm_camera"].value ~= 0 then
		guarddefs_patcher.armCameraDrones( options["arm_camera"].value, patchOpts )
	end
	if options["arm_null"] and options["arm_null"].value ~= 0 then
		guarddefs_patcher.armNullDrones( options["arm_null"].value, patchOpts )
	end
	if options["arm_pulse"] and options["arm_pulse"].value ~= 0 then
		guarddefs_patcher.armPulseDrones( options["arm_pulse"].value, patchOpts )
	end
	if options["arm_refit"] and options["arm_refit"].value ~= 0 then
		guarddefs_patcher.armRefitDrones( options["arm_refit"].value, patchOpts )
	end
	if options["arm_ce_crazy"] and options["arm_ce_crazy"].value ~= 0 then
		guarddefs_patcher.armCeCrazyDrones( options["arm_ce_crazy"].value, patchOpts )
	end
end

local function initStrings( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "QED_EXPLOSIVEDRONES", MOD_STRINGS)
end

return {
	earlyInit = earlyInit,
	init = init,
	load = load,
	lateLoad = lateLoad,
	unload = unload,
	initStrings = initStrings,
}
