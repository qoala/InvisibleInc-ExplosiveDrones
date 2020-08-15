local simdefs = include( "sim/simdefs" )
local simengine = include( "sim/engine" )
local simquery = include( "sim/simquery" )

local oldScanCell = simengine.scanCell

local function isAlreadyAttacking( unit )
	local currentInterest = unit:getBrain():getSenses():getCurrentInterest()
	return currentInterest and simquery.isEnemyAgent( unit:getPlayerOwner(), currentInterest.sourceUnit, true )
end

local function handleScannedTarget( self, unit, cell, cellUnit )
	if not unit:getTraits().qedDelayedScanInterests then
		unit:getTraits().qedDelayedScanInterests = {}
	end
	table.insert( unit:getTraits().qedDelayedScanInterests, { x = cell.x, y = cell.y, unit = cellUnit } )

	if not isAlreadyAttacking( unit ) then
		-- Hold position rather than potentially move away from the target.
		unit:useMP( unit:getMP(), self )
	end
end

function simengine:scanCell( unit, cell, ignoreDisguise, scanGrenade )
	oldScanCell( self, unit, cell, ignoreDisguise, scanGrenade )

	local player = unit:getPlayerOwner()
	if unit:getTraits().qedScanMissile and player and player:isNPC() then
		for i, cellUnit in ipairs( cell.units ) do
			if simquery.isEnemyAgent( player, cellUnit, ignoreDisguise ) then
				handleScannedTarget( self, unit, cell, cellUnit )
				return
			end
		end
	end
end
