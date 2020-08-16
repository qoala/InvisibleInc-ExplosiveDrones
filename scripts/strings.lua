
-- Shared explanation of the "ARM X DRONE" tip choices.
local ARM_TIP = "UNARMED: No change (vanilla)\nEXPLOSIVE: Lethal damage to self and target.\nDISCHARGE: KO damage to self and target."

local DLC_STRINGS =
{
	ABILITIES = {
		EXPLOSIVEDRONE = "PROXIMITY EXPLOSIVE",
		EXPLOSIVEDRONE_DESC = "Detonates when an active enemy is on the same tile.\nIgnores cloak. Lethal damage. Noisy.",
		DISCHARGEDRONE = "PROXIMITY DISCHARGE",
		DISCHARGEDRONE_DESC = "KOs target and self when an active enemy is on the same tile.\nIgnores cloak. Emits noise.",
	},

	OPTIONS = {
		UNARMED = "UNARMED",
		EXPLOSIVE = "EXPLOSIVE",
		DISCHARGE = "DISCHARGE",
		ARM_CAMERA = "ARM CAMERA DRONES",
		ARM_CAMERA_TIP = "<c:FF8411>ARM CAMERA DRONES</c>\nArm camera drones with a proximity weapon and behavior.\n" .. ARM_TIP,
		ARM_NULL = "ARM NULL DRONES",
		ARM_NULL_TIP = "<c:FF8411>ARM NULL DRONES</c>\nArm null drones and null drones 2.0 with a proximity weapon and behavior.\n" .. ARM_TIP,
		ARM_PULSE = "ARM PULSE DRONES (Contingency Plan)",
		ARM_PULSE_TIP = "<c:FF8411>ARM PULSE DRONES</c>\nArm pulse drones with a proximity weapon and behavior. Pulse drones investigate their own scan results in addition to relaying them to other guards.\nNo effect without the Contingency Plan DLC\n" .. ARM_TIP,

		CAMERA_SPAWNS = "CAMERA-LIKE DRONES PER LEVEL",
		CAMERA_SPAWNS_TIP = "<c:FF8411>CAMERA-LIKE DRONES PER LEVEL</c>\nAdjust the number of camera-like drones (camera drones, pulse drones) that spawn per level. This is independent of the vanilla GUARDS PER LEVEL option and generates more drones.",
		SPAWN_UNCHANGED = "UNCHANGED",
		SPAWN_MORE = "MORE",
		SPAWN_MANY = "MANY",
		SPAWN_SWARMING = "SWARMING",

		RESPAWN_DRONES = "RESPAWN EXPLOSIVE DRONES",
		RESPAWN_DRONES_TIP = "<c:FF8411>RESPAWN EXPLOSIVE DRONES</c>\nIf enabled, drones armed with proximity explosives respawn after their destruction.\nDISABLED: No respawn.\nPATROLLING: Respawn with a random patrol, like alarm 3 & 4 guards.\nHUNTING: Respawn alerted, like enforcers.",
		DISABLED = "DISABLED",
		PATROLLING = "PATROLLING",
		HUNTING = "HUNTING",
	},
}

return DLC_STRINGS
