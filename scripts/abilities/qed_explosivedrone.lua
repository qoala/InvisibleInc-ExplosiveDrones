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

	-- Light and sound, like a flash pack/shock mine
	local x0,y0 = userUnit:getLocation()
	sim:dispatchEvent( simdefs.EV_FLASH_VIZ, {x = x0, y = y0, units = nil, range = math.floor(VIZ_RANGE) } )
	local soundRange = { path = nil, range = SOUND_RANGE }
	sim:emitSound( soundRange, x0, y0, nil )

	-- Damage
	local dmgt =
	{
		damage = 1,
		ko = false,
	}
	sim:hitUnit( userUnit, target, dmgt )

	local oldCleanup = userUnit:getTraits().cleanup
	userUnit:getTraits().cleanup = false  -- No penalty if this is lethal
	userUnit:killUnit(sim)
	if userUnit and userUnit:isValid() then
		userUnit:getTraits().cleanup = oldCleanup
	end

	sim:startTrackerQueue( false )
	sim:processDaemonQueue()

	sim:processReactions()
end

local function wrapTakeControl( unit )
	local oldTakeControl = unit.takeControl

	function unit:takeControl( player, ... )
		oldTakeControl( self, player, ... )

		local sim = self:getSim()
		local cell = sim:getCell( self:getLocation() )
		for _, ability in ipairs( self._abilities ) do
			if ability.qedCheckProximityTrigger then
				ability:qedCheckProximityTrigger( sim, self, cell )
				break
			end
		end
	end
end

local qed_explosivedrone = util.extend( DEFAULT_BUFF )
{
	name = STRINGS.QED_EXPLOSIVEDRONES.ABILITIES.EXPLOSIVEDRONE,
	buffDesc = STRINGS.QED_EXPLOSIVEDRONES.ABILITIES.EXPLOSIVEDRONE_DESC,
	ghostable = true,  -- Show on fog of war ghosts

	onSpawnAbility = function( self, sim, unit )
		sim:addTrigger( simdefs.TRG_UNIT_WARP, self, unit )
		wrapTakeControl( unit )
	end,

	onDespawnAbility = function( self, sim, unit )
		sim:removeTrigger( simdefs.TRG_UNIT_WARP, self )
	end,

	onTrigger = function( self, sim, evType, evData, userUnit )
		if evType ~= simdefs.TRG_UNIT_WARP or evData.from_cell == evData.to_cell then
			return
		end
		if not evData.unit:isValid() or evData.unit:isDown() then
			return
		end

		local cell = sim:getCell( userUnit:getLocation() )
		if cell == evData.to_cell then
			self:qedCheckProximityTrigger( sim, userUnit, cell )
		end
	end,

	qedCheckProximityTrigger = function( self, sim, userUnit, cell )
		if not cell or not userUnit:isValid() or userUnit:isDown() then
			return
		end
		local player = userUnit:getPlayerOwner()
		if not player:isNPC() and not sim:getParams().difficultyOptions.qed_explosive_armed_when_hacked then
			return
		end
		for _, cellUnit in ipairs( cell.units ) do
			if cellUnit and not cellUnit:isDown() and (simquery.isEnemyAgent( player, cellUnit ) or simquery.isKnownTraitor( cellUnit, userUnit )) then
				doExplode( sim, userUnit, cellUnit )
				break
			end
		end
	end,
}

return qed_explosivedrone
