
local function earlyInit( modApi )
	modApi.requirements =
	{
		"Contingency Plan", "Sim Constructor", "Function Library", "Disguise Fix",
		"Advanced Guard Protocol", "Generation Options+"
	}
end

local function init( modApi )
	local scriptPath = modApi:getScriptPath()

	include( scriptPath .. "/aiplayer" )
	include( scriptPath .. "/engine" )
	include( scriptPath .. "/simquery" )
	include( scriptPath .. "/simunit" )
	include( scriptPath .. "/btree/situations/combat" )
	include( scriptPath .. "/btree/actions" )
	include( scriptPath .. "/btree/qed_missilebrain" )

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
end

local function load( modApi, options, params )
	local scriptPath = modApi:getScriptPath()

	local simdefs_patcher = include( scriptPath .. "/simdefs_patcher" )
	simdefs_patcher.modifyAllSpawnTables( "SWARMING" )

	local guarddefs_patcher = include( scriptPath .. "/guarddefs_patcher" )
	guarddefs_patcher.armCameraDrones()
	guarddefs_patcher.armNullDrones()
	guarddefs_patcher.armPulseDrones()
end

local function initStrings( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "QED_REARMEDDRONES", MOD_STRINGS)
end

return {
	earlyInit = earlyInit,
	init = init,
	load = load,
	unload = unload,
	initStrings = initStrings,
}
