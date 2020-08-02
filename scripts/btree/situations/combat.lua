local CombatSituation = include("sim/btree/situations/combat")

local oldAddUnit = CombatSituation.addUnit

function CombatSituation:addUnit(unit)
	oldAddUnit(self, unit)

	if unit:getTraits().camera_drone and not unit:getTraits().pacifist then
		-- No plain "hunting" for these drones. They're armed and operational.
		unit:getTraits().thoughtVis = "combat"
	end
end
