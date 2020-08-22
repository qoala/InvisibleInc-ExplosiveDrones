local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )

local oldLastWords = abilitydefs.lookupAbility("lastWords")
local oldExecuteAbility = oldLastWords.executeAbility

local function unitWillImpactTarget( unit, target )
	local path = unit:getPather():getPath( unit )
	local x,y = target:getLocation()
	for _, node in ipairs( path.path:getNodes() ) do
		if node.location.x == x and node.location.y == y then
			return true
		end
	end
	return false
end

local function doMoveUnit( sim, unit, target )
	local path = unit:getPather():getPath( unit )
	local targetX,targetY = target:getLocation()

	-- Loosely copied from sim/actions.MoveTo:executePath
	-- Here, we skip any waiting for other units. All missiles lack dynamic impass.
	local moveTable = {}
	local prevx, prevy = unit:getLocation()
	for _, node in ipairs( path.path:getNodes() ) do
		if node.location.x ~= prevx or node.location.y ~= prevy then
			table.insert( moveTable, { x = node.location.x, y = node.location.y, lid = node.lid } )

			if node.location.x == targetX and node.location.y == targetY then
				-- Hopefully, we're there now.
				break
			end
		end
	end

	local canMoveReason, end_cell = sim:moveUnit( unit, moveTable )

	if unit:getPather():getPath( unit ) == path then
		-- Somehow, the missile is still alive. Invalidate the old path to clean things up.
		unit:GetPather():invalidatePath( unit )
	end
end

local lastWords = util.extend( oldLastWords )
{
	-- Copy colors manually. util.extend doesn't handle classes
	iconColor = oldLastWords.iconColor,
	iconColorHover = oldLastWords.iconColorHover,

	executeAbility = function( self, sim, sourceUnit, ... )
		oldExecuteAbility( self, sim, sourceUnit, ... )

		if sourceUnit and not sourceUnit:isDown() then
			-- Try moving missiles that are in overwatch
			local aiPlayer = sim:getNPC()
			local situation = aiPlayer and aiPlayer:findExistingCombatSituation(sourceUnit)
			for _, unit in pairs(situation.units) do
				if unit:getTraits().qedMissile and unit:isValid() and not unit:isDown() and unitWillImpactTarget( unit, sourceUnit ) then
					doMoveUnit( sim, unit, sourceUnit )

					if not sourceUnit or sourceUnit:isDown() then
						return
					end
				end
			end
		end
	end,
}
return lastWords
