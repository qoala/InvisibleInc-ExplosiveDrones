-- Missile Brain:
-- Non-dynamic-impass drones that behave like missiles and try to move into their targets.

local Brain = include("sim/btree/brain")                                                                                                                                    local btree = include("sim/btree/btree")
local actions = include("sim/btree/actions")
local conditions = include("sim/btree/conditions")
local simfactory = include( "sim/simfactory" )
local simdefs = include( "sim/simdefs" )
local speechdefs = include( "sim/speechdefs" )
local mathutil = include( "modules/mathutil" )
local simquery = include( "sim/simquery" )
local CommonBrain = include( "sim/btree/commonbrain" )

require("class")

local MissileCombat = function()
	return btree.Sequence("Combat",
	{
		btree.Condition(conditions.HasTarget),
		btree.Action(actions.ReactToTarget),
		actions.MoveToTarget(),
	})
end

local MissileBrain = class(Brain, function(self)
	Brain.init(self, "qedMissileBrain",
		btree.Selector(
		{
			MissileCombat(),
			CommonBrain.Investigate(),
			CommonBrain.Patrol(),
		})
	)
end)

local function createBrain()
	return MissileBrain()
end

simfactory.register(createBrain)

return MissileBrain
