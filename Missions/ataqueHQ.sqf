if (!isServer and hasInterface) exitWith{};

_posicion = getMarkerPos "respawn_guerrila";

_pilotos = [];
_vehiculos = [];
_grupos = [];
_soldados = [];

if ({(_x distance _posicion < 500) and (typeOf _x == staticAABuenos)} count staticsToSave > 4) exitWith {};

_aeropuertos = aeropuertos select {(not(_x in mrkSDK)) and (spawner getVariable _x == 2)};
if (count _aeropuertos == 0) exitWith {};
_aeropuerto = [_aeropuertos,_posicion] call BIS_fnc_nearestPosition;
_posOrigen = getMarkerPos _aeropuerto;
_lado = if (_aeropuerto in mrkNATO) then {malos} else {muyMalos};

_tsk = ["DEF_HQ",[buenos,civilian],["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill Maru. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track","Defend Maru","respawn_guerrila"],_posicion,"CREATED",5,true,true,"Defend"] call BIS_fnc_setTask;
misiones pushBack _tsk; publicVariable "misiones";
_tsk1 = ["DEF_HQ1",[_lado],["We know Syndikat HQ coordinates. We have sent a SpecOp Squad in order to kill his leader Maru. Help the SpecOp team","Kill Maru","respawn_guerrila"],_posicion,"CREATED",5,true,true,"Attack"] call BIS_fnc_setTask;
_tiposVeh = if (_lado == malos) then {vehNATOAttackHelis} else {vehCSATAttackHelis};
_tiposVeh = _tiposVeh select {[_x] call vehAvailable};

if (count _tiposVeh > 0) then
	{
	_tipoVeh = selectRandom _tiposVeh;
	//_pos = [_posicion, distanciaSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_posOrigen, 0, _tipoVeh, _lado] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_grupoheli = _vehicle select 2;
	_pilotos = _pilotos + _heliCrew;
	_grupos pushBack _grupoheli;
	_vehiculos pushBack _heli;
	{[_x] call NATOinit} forEach _heliCrew;
	[_heli] call AIVEHinit;
	_wp1 = _grupoheli addWaypoint [_posicion, 0];
	_wp1 setWaypointType "SAD";
	[_heli,"Air Attack"] spawn inmuneConvoy;
	sleep 30;
	};
_tiposVeh = if (_lado == malos) then {vehNATOTransportHelis} else {vehCSATTransportHelis};
_tipoGrupo = if (_lado == malos) then {NATOSpecOp} else {CSATSpecOp};

for "_i" from 0 to (round random 2) do
	{
	_tipoVeh = selectRandom _tiposVeh;
	//_pos = [_posicion, distanciaSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_posOrigen, 0, _tipoVeh, _lado] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_grupoheli = _vehicle select 2;
	_pilotos = _pilotos + _heliCrew;
	_grupos pushBack _grupoheli;
	_vehiculos pushBack _heli;

	{_x setBehaviour "CARELESS";} forEach units _grupoheli;
	_grupo = [_posOrigen, _lado, _tipoGrupo] call spawnGroup;
	{_x assignAsCargo _heli; _x moveInCargo _heli; _soldados pushBack _x; [_x] call NATOinit} forEach units _grupo;
	_grupos pushBack _grupo;
	[_heli,"Air Transport"] spawn inmuneConvoy;
	[_heli,_grupo,_posicion,_posOrigen,_grupoHeli] spawn fastrope;
	sleep 10;
	};

waitUntil {sleep 1;({not (captive _x)} count _soldados < {captive _x} count _soldados) or ({alive _x} count _soldados < {fleeing _x} count _soldados) or ({alive _x} count _soldados == 0) or (_posicion distance getMarkerPos "respawn_guerrila" > 999) or (!alive petros)};

if (!alive petros) then
	{
	_tsk = ["DEF_HQ",[buenos,civilian],["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill Maru. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track","Defend Maru","respawn_guerrila"],_posicion,"FAILED",5,true,true,"Defend"] call BIS_fnc_setTask;
	_tsk1 = ["DEF_HQ1",[_lado],["We know Syndikat HQ coordinates. We have sent a SpecOp Squad in order to kill his leader Maru. Help the SpecOp team","Kill Maru","respawn_guerrila"],_posicion,"SUCCEEDED",5,true,true,"Attack"] call BIS_fnc_setTask;
	}
else
	{
	if (_posicion distance getMarkerPos "respawn_guerrila" > 999) then
		{
		_tsk = ["DEF_HQ",[buenos,civilian],["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill Maru. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track","Defend Maru","respawn_guerrila"],_posicion,"SUCCEEDED",5,true,true,"Defend"] call BIS_fnc_setTask;
		_tsk1 = ["DEF_HQ1",[_lado],["We know Syndikat HQ coordinates. We have sent a SpecOp Squad in order to kill his leader Maru. Help the SpecOp team","Kill Maru","respawn_guerrila"],_posicion,"FAILED",5,true,true,"Attack"] call BIS_fnc_setTask;
		}
	else
		{
		_tsk = ["DEF_HQ",[buenos,civilian],["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill Maru. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track","Defend Maru","respawn_guerrila"],_posicion,"SUCCEEDED",5,true,true,"Defend"] call BIS_fnc_setTask;
		_tsk1 = ["DEF_HQ1",[_lado],["We know Syndikat HQ coordinates. We have sent a SpecOp Squad in order to kill his leader Maru. Help the SpecOp team","Kill Maru","respawn_guerrila"],_posicion,"FAILED",5,true,true,"Attack"] call BIS_fnc_setTask;
		[0,3] remoteExec ["prestige",2];
		[0,300] remoteExec ["resourcesFIA",2];
		//[-5,5,_posicion] remoteExec ["citySupportChange",2];
		{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_posicion,"GREENFORSpawn"] call distanceUnits);
		};
	};

_nul = [1200,_tsk] spawn borrarTask;
sleep 60;
_nul = [0,_tsk1] spawn borrarTask;

{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x};
} forEach _vehiculos;
{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x; _soldados = _soldados - [_x]};
} forEach _soldados;
{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x; _pilotos = _pilotos - [_x]};
} forEach _pilotos;

if (count _soldados > 0) then
	{
	{
	_veh = _x;
	waitUntil {sleep 1; !([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)};
	deleteVehicle _veh;
	} forEach _soldados;
	};

if (count _pilotos > 0) then
	{
	{
	_veh = _x;
	waitUntil {sleep 1; !([distanciaSPWN,1,_x,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)};
	deleteVehicle _veh;
	} forEach _pilotos;
	};
{deleteGroup _x} forEach _grupos;