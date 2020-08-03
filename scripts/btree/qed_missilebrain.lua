-- Missile Brain:
-- Non-dynamic-impass drones that behave like missiles and try to move into their targets.

local Brain = include("sim/btree/brain")                                                                                                                                    local btree = include("sim/btree/btree")
local Senses = include("sim/btree/senses")                                                                                                                                    local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local simfactory = include( "sim/simfactory" )
local simdefs = include( "sim/simdefs" )
local speechdefs = include( "sim/speechdefs" )
local mathutil = include( "modules/mathutil" )
local simquery = include( "sim/simquery" )
local CommonBrain = include( "sim/btree/commonbrain" )

require("class")

-- Combat rule for missiles
local MissileCombat = function()
	return btree.Sequence("Combat",
	{
		btree.Condition(conditions.HasTarget),
		btree.Action(actions.qed_ReactToMissileTarget),
		btree.Action(actions.qed_IgnoreOtherTargets),
		actions.MoveToTarget(),
		btree.Action(actions.qed_ResetTargeting),
	})
end

-- ------------
-- MissileBrain
-- ------------

local MissileBrain = class(Brain, function(self)
	Brain.init(self, "qedMissileBrain",
		btree.Selector(
		{
			MissileCombat(),
			-- Reset combat targetting overrides if we lose the target
			btree.Not("FallThrough", btree.Always(btree.Action(actions.qed_ResetTargeting))),
			CommonBrain.Investigate(),
			CommonBrain.Patrol(),
		})
	)
end)

local function missileProcessWarpTrigger(self, sim, evData)
	Senses.processWarpTrigger(self, sim, evData)

	if (self:hasTarget(evData.unit) and self.unit and sim:canUnitSeeUnit( self.unit, evData.unit )) then
		-- We've already turned for tracking the target. Now update our knowledge of the target's location.
		local target = self.targets[evData.unit:getID()]
		target.x,target.y = evData.unit:getLocation()

		-- Update pathing for our primary target
		local destination = self.unit:getBrain():getDestination()
		if self:getCurrentTarget() == evData.unit and (target.x ~= destination.x or target.y ~= destination.y) then
			self.unit:getBrain():setDestination(evData.unit)
			self.unit:getBrain():reset()
		end
	end
end

function MissileBrain:onSpawned(sim, unit)
	Brain.onSpawned(self, sim, unit)

	self.senses.processWarpTrigger = missileProcessWarpTrigger
end

function MissileBrain:setDestination(dest)
	Brain.setDestination(self, dest)

	-- clear destination.unit, as it's only necessary for the pather call in setDestination
	-- and otherwise suppresses path display in pathrig.
	if self.destination and self.destination.unit then
		self.destination.unit = nil
	end
end

local function createBrain()
	return MissileBrain()
end

simfactory.register(createBrain)

return MissileBrain
