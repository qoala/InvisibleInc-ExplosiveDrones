local simdefs = include( "sim/simdefs" )
local simengine = include( "sim/engine" )
local simquery = include( "sim/simquery" )

-- Respawn camera drone missiles

local oldInit = simengine.init

function simengine:init( params, levelData, ... )
	oldInit( self, params, levelData, ... )

	self._qedMissilesToSpawn = {}
end

function simengine:qedGetMissilesToSpawn()
	return self._qedMissilesToSpawn
end

function simengine:qedAddMissilesToSpawn( unitType )
	return table.insert( self._qedMissilesToSpawn, unitType )
end

function simengine:qedResetMissilesToSpawn()
	self._qedMissilesToSpawn = {}
end

-- Pulse Drone scan behavior

local oldScanCell = simengine.scanCell

local function isAlreadyAttacking( unit )
	local currentInterest = unit:getBrain():getSenses():getCurrentInterest()
	return currentInterest and simquery.isEnemyAgent( unit:getPlayerOwner(), currentInterest.sourceUnit, true )
end

local function handleScannedTarget( self, unit, cell, cellUnit )
	if self:getParams().difficultyOptions.qed_killer_pulse_drones then
		unit:getBrain():getSenses():addInterest( cell.x, cell.y, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, cellUnit, true )
	else
		if not unit:getTraits().qedDelayedScanInterests then
			unit:getTraits().qedDelayedScanInterests = {}
		end
		table.insert( unit:getTraits().qedDelayedScanInterests, { x = cell.x, y = cell.y, unit = cellUnit } )

		if not isAlreadyAttacking( unit ) then
			-- Hold position rather than potentially move away from the target.
			unit:useMP( unit:getMP(), self )
		end
	end
end

function simengine:scanCell( unit, cell, ignoreDisguise, scanGrenade )
	oldScanCell( self, unit, cell, ignoreDisguise, scanGrenade )

	local player = unit:getPlayerOwner()
	if unit:getTraits().qedScanMissile and player and player:isNPC() then
		for i, cellUnit in ipairs( cell.units ) do
			if simquery.isEnemyAgent( player, cellUnit, ignoreDisguise ) and not cellUnit:hasBeenInvestigated() then
				handleScannedTarget( self, unit, cell, cellUnit )
				return
			end
		end
	end
end
