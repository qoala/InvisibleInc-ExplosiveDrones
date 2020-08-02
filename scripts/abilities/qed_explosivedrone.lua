local util = include( "modules/util" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )

-- (copied from sim/abilities/passive_abilities)
local DEFAULT_BUFF =
{
	buffAbility = true,

	getName = function( self, sim, unit )
		return self.name
	end,

	createToolTip = function( self,sim,unit,targetUnit)
		return formatToolTip( self.name, string.format("BUFF\n%s", self.desc ) )
	end,

	canUseAbility = function( self, sim, unit )
		return false -- Passives are never 'used'
	end,

	executeAbility = nil, -- Passives by definition have no execute.
}

local VIZ_RANGE = 1.35
local SOUND_RANGE = 8

local function doExplode( sim, userUnit, target )
	sim:startTrackerQueue( true )
	sim:startDaemonQueue()

	-- Light and sound
	local x0,y0 = userUnit:getLocation()
	sim:dispatchEvent( simdefs.EV_FLASH_VIZ, {x = x0, y = y0, units = nil, range = math.floor(VIZ_RANGE) } )
	local soundRange = { path = nil, range = SOUND_RANGE }
	sim:emitSound( soundRange, x0, y0, target )

	-- Damage
	local cell = sim:getCell( x0, y0 )
	local dmgt =
	{
		damage = 1,
		ko = false,
	}
	for _, cellUnit in ipairs( cell.units ) do
		if cellUnit ~= userUnit and simquery.isAgent( cellUnit ) and cellUnit:getWounds() then
			-- Copy damage table before target-specific modifications within hitUnit.
			local localdmgt = util.tcopy( dmgt )
			sim:hitUnit( userUnit, cellUnit, dmgt )
		end
	end
	userUnit:killUnit(sim)

	sim:startTrackerQueue( false )
	sim:processDaemonQueue()

  sim:processReactions()
end

local qed_explosivedrone = util.extend( DEFAULT_BUFF )
{
	name = STRINGS.QED_REARMEDDRONES.ABILITIES.EXPLOSIVEDRONE,
	buffDesc = STRINGS.QED_REARMEDDRONES.ABILITIES.EXPLOSIVEDRONE_DESC,

	onSpawnAbility = function( self, sim, unit )
		sim:addTrigger( simdefs.TRG_UNIT_WARP, self, unit )
	end,

	onDespawnAbility = function( self, sim, unit )
		sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
	end,

	onTrigger = function( self, sim, evType, evData, userUnit )
		if evType ~= simdefs.TRG_UNIT_WARP or evData.from_cell == evData.to_cell then
			return
		end
		local player = userUnit:getPlayerOwner()
		if not userUnit:isValid() or userUnit:isDown() or not player:isNPC() then
			return
		end
		if not evData.unit:isValid() or evData.unit:isDown() then
			return
		end

		local cell = sim:getCell( userUnit:getLocation() )
		if cell == evData.to_cell then
			for _, cellUnit in ipairs( cell.units ) do
				if cellUnit and simquery.isEnemyAgent( player, cellUnit ) then
					doExplode( sim, userUnit, cellUnit )
					break
				end
			end
		end
	end,
}

return qed_explosivedrone
