if (player!= Stavros) exitWith {hint "Only the Commander can order to rest"};
_presente = false;

{
if ((side _x == malos) or (side _x == muyMalos)) then
	{
	if ([500,1,_x,"GREENFORSpawn"] call distanceUnits) then {_presente = true};
	};
} forEach allUnits;
if (_presente) exitWith {hint "You cannot rest with enemies near our units"};
if ("AtaqueAAF" in misiones) exitWith {hint "You cannot rest while NATO or CSAT is counterattacking"};
if ("DEF_HQ" in misiones) exitWith {hint "You cannot rest while your HQ is under attack"};

_chequeo = false;
_posHQ = getMarkerPos "respawn_guerrila";
{
if (_x distance _posHQ > 100) then {_chequeo = true};
} forEach (allPlayers - hcArray);

if (_chequeo) exitWith {hint "All player must be in a 100mts radius from HQ to be able to rest"};

[[],"resourcecheckSkipTime"] call BIS_fnc_MP;


