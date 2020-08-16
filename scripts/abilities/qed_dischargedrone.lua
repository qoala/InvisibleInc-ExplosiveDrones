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
local SOUND_RANGE = 4
local KO_DAMAGE = 3
local SELF_KO_DAMAGE = 2  -- If triggered on the corp turn, this ticks immediately.

local function doExplode( sim, userUnit, target )
	sim:startTrackerQueue( true )
	sim:startDaemonQueue()

	-- Light and sound, like an EMP
	local x0,y0 = userUnit:getLocation()
	sim:dispatchEvent( simdefs.EV_OVERLOAD_VIZ, {x = x0, y = y0, units = { userUnit, target }, range = math.floor(VIZ_RANGE) } )
	sim:emitSound( simdefs.SOUND_SMALL, x0, y0, nil )

	-- KO/EMP target
	target:processEMP( KO_DAMAGE, true )
	if not target:getTraits().isDrone then
		local damage = KO_DAMAGE
		if sim:isVersion("0.17.5") then
			damage = target:processKOresist( damage )
		end
		target:setKO( sim, damage )
	end
	-- KO/EMP self
	userUnit:processEMP( SELF_KO_DAMAGE, true )

	sim:startTrackerQueue( false )
	sim:processDaemonQueue()

	sim:processReactions()
end

local qed_dischargedrone = util.extend( DEFAULT_BUFF )
{
	name = STRINGS.QED_REARMEDDRONES.ABILITIES.DISCHARGEDRONE,
	buffDesc = STRINGS.QED_REARMEDDRONES.ABILITIES.DISCHARGEDRONE_DESC,
	ghostable = true,  -- Show on fog of war ghosts

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
				if cellUnit and simquery.isEnemyAgent( player, cellUnit ) and not cellUnit:isDown() then
					doExplode( sim, userUnit, cellUnit )
					break
				end
			end
		end
	end,
}

return qed_dischargedrone
