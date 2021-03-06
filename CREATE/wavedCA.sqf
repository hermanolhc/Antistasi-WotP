if (!isServer and hasInterface) exitWith {};

private ["_posorigen","_tipogrupo","_nombreorig","_markTsk","_wp1","_soldados","_landpos","_pad","_vehiculos","_wp0","_wp3","_wp4","_wp2","_grupo","_grupos","_tipoveh","_vehicle","_heli","_heliCrew","_grupoheli","_pilotos","_rnd","_resourcesAAF","_nVeh","_tam","_roads","_Vwp1","_road","_veh","_vehCrew","_grupoVeh","_Vwp0","_size","_Hwp0","_grupo1","_uav","_grupouav","_uwp0","_tsk","_vehiculo","_soldado","_piloto","_mrkdestino","_posdestino","_prestigeCSAT","_mrkOrigen","_aeropuerto","_nombredest","_tiempo","_solMax","_nul","_coste","_tipo","_threatEvalAir","_threatEvalLand","_pos","_timeOut","_lado","_waves","_cuenta"];

bigAttackInProgress = true;
publicVariable "bigAttackInProgress";
_firstWave = true;
_mrkDestino = _this select 0;
_mrkOrigen = _this select 1;
_waves = _this select 2;
if (_waves <= 0) then {_waves = -1};
_size = [_mrkDestino] call sizeMarker;
diag_log format ["Antistasi: Waved attack from %1 to %2. Waves: %3",_mrkOrigen,_mrkDestino,_waves];

_posDestino = getMarkerPos _mrkDestino;
_posOrigen = getMarkerPos _mrkOrigen;

_grupos = [];
_soldadosTotal = [];
_pilotos = [];
_vehiculos = [];
_forced = [];

_nombredest = [_mrkDestino] call localizar;
_nombreorig = [_mrkOrigen] call localizar;

_lado = malos;
_ladosTsk = [buenos,civilian,muyMalos];
_ladosTsk1 = [malos];
_nombreEny = "NATO";
//_config = cfgNATOInf;
if (_mrkOrigen in mrkCSAT) then
	{
	_lado = muymalos;
	_nombreEny = "CSAT";
	//_config = cfgCSATInf;
	_ladosTsk = [buenos,civilian,malos];
	_ladosTsk1 = [muyMalos];
	};
_esSDK = if (_mrkDestino in mrkSDK) then {true} else {false};
_SDKShown = false;
if (_esSDK) then
	{
	_ladosTsk = [buenos,civilian,malos,muyMalos] - [_lado];
	}
else
	{
	/*
	if (_lado == malos) then
		{
		_forced = (controles + puestos + aeropuertos) select {(_x in mrkCSAT) and (getMarkerPos _x distance _posDestino < distanciaSPWN)};
		}
	else
		{
		_forced = (controles + puestos + aeropuertos) select {(_x in mrkNATO) and (getMarkerPos _x distance _posDestino < distanciaSPWN)};
		};
	*/
	if (not(_mrkDestino in _forced)) then {_forced pushBack _mrkDestino};
	};

//forcedSpawn = forcedSpawn + _forced; publicVariable "forcedSpawn";
forcedSpawn pushBack _mrkDestino; publicVariable "forcedSpawn";
diag_log format ["Antistasi: Side attacker: %1. Side defender (false, the other AI side):  %2",_lado,_esSDK];
_nombreDest = [_mrkDestino] call localizar;

_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkOrigen],getMarkerPos _mrkOrigen,"CREATED",10,true,true,"Defend"] call BIS_fnc_setTask;
misiones pushbackUnique "AtaqueAAF"; publicVariable "misiones";
_tsk1 = ["AtaqueAAF1",_ladosTsk1,[format ["We are attacking %2 from the %1. Help the operation if you can",_nombreorig,_nombreDest],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"CREATED",10,true,true,"Attack"] call BIS_fnc_setTask;

_tiempo = time + 3600;

while {(_waves != 0)} do
	{
	_soldados = [];
	_nVeh = 3 + (round random 1);

	if (_posOrigen distance _posDestino < 5000) then
		{
		if ([_mrkDestino,true] call fogCheck < 0.3) then {_nveh = 2*_nveh};
		_indice = aeropuertos find _mrkOrigen;
		_spawnPoint = spawnPoints select _indice;
		_pos = getMarkerPos _spawnPoint;
		/*
		_roads = [];
		_tam = [_mrkOrigen] call sizeMarker;
		while {true} do
			{
			_roads = _posOrigen nearRoads _tam;
			if (count _roads < _nVeh) then {_tam = _tam + 50};
			if (count _roads >= _nVeh) exitWith {};
			};
		*/
		_vehPool = if (_lado == malos) then {vehNATOAttack} else {vehCSATAttack};
		if (_esSDK) then
			{
			_rnd = random 100;
			if (_lado == malos) then
				{
				if (_rnd > prestigeNATO) then
					{
					_vehPool = _vehPool - [vehNATOTank];
					};
				}
			else
				{
				if (_rnd > prestigeCSAT) then
					{
					_vehPool = _vehPool - [vehCSATTank];
					};
				};
			};
		if (count _vehPool == 0) then {if (_lado == malos) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
		_cuenta = 1;
		while {_cuenta <= _nVeh} do
			{
			_tipoVeh = selectRandom _vehPool;
			if (not([_tipoVeh] call vehAvailable)) then
				{
				_tipoVeh = if (_lado == malos) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
				_vehPool = _vehPool - [_tipoVeh];
				if (count _vehPool == 0) then {if (_lado == malos) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
				};
			if ((_cuenta == _nVeh) and (_tipoVeh in vehTanks)) then
				{
				_tipoVeh = if (_lado == malos) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
				};
			//_road = _roads select (_i -1);
			_timeOut = 0;
			_pos = _pos findEmptyPosition [0,100,_tipoveh];
			while {_timeOut < 60} do
				{
				if (count _pos > 0) exitWith {};
				_timeOut = _timeOut + 1;
				_pos = _pos findEmptyPosition [0,100,_tipoveh];
				sleep 1;
				};
			if (count _pos == 0) then {_pos = getMarkerPos _spawnPoint};
			_vehicle=[_pos, markerDir _spawnPoint,_tipoVeh, _lado] call bis_fnc_spawnvehicle;
			_veh = _vehicle select 0;
			_vehCrew = _vehicle select 1;
			{[_x] call NATOinit} forEach _vehCrew;
			[_veh] call AIVEHinit;
			_grupoVeh = _vehicle select 2;
			_soldados append _vehCrew;
			_soldadosTotal append _vehCrew;
			_grupos pushBack _grupoVeh;
			_vehiculos pushBack _veh;
			_landPos = [_posDestino,_pos] call findSafeRoadToUnload;
			if (not(_tipoVeh in vehTanks)) then
				{
				_tipogrupo = [_tipoVeh,_lado] call cargoSeats;
				_grupo = [_posorigen,_lado, _tipogrupo] call spawnGroup;
				{_x assignAsCargo _veh;_x moveInCargo _veh; _soldados pushBack _x;_soldadosTotal pushBack _x;[_x] call NATOinit} forEach units _grupo;
				if (not(_tipoVeh in vehTrucks)) then
					{
					_grupo setVariable ["mrkAttack",_mrkDestino];
					_grupos pushBack _grupo;
					if ((_mrkOrigen == "airport") or (_mrkOrigen == "airport_2")) then {[_mrkOrigen,_landPos,_grupoVeh] call WPCreate};
					_Vwp0 = (wayPoints _grupoVeh) select 0;
					_Vwp0 setWaypointBehaviour "SAFE";
					_Vwp0 = _grupoVeh addWaypoint [_landPos, count (wayPoints _grupoVeh)];
					_Vwp0 setWaypointType "TR UNLOAD";
					_Vwp0 setWayPointCompletionRadius (10*_cuenta);
					//_Vwp0 setWaypointStatements ["true", "[vehicle this] call smokeCoverAuto"];
					_Vwp1 = _grupoVeh addWaypoint [_posdestino, 1];
					_Vwp1 setWaypointType "SAD";
					_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_Vwp1 setWaypointBehaviour "COMBAT";
					_Vwp2 = _grupo addWaypoint [_landPos, 0];
					_Vwp2 setWaypointType "GETOUT";
					_Vwp0 synchronizeWaypoint [_Vwp2];
					_Vwp2 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
					/*
					_Vwp3 = _grupo addWaypoint [_posdestino, 1];
					_Vwp3 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_Vwp3 = _grupo addWaypoint [_posdestino, 1];
					_Vwp3 setWaypointType "SAD";
					*/
					_veh allowCrewInImmobile true;
					[_veh,"APC"] spawn inmuneConvoy;
					}
				else
					{
					{[_x] join _grupoVeh} forEach units _grupo;
					deleteGroup _grupo;
					_grupoVeh setVariable ["mrkAttack",_mrkDestino];
					/*
					for "_i" from 1 to 8 do
						{
						_tipoSoldado = if (_lado == malos) then {NATOGrunt} else {CSATGrunt};
						_soldado = _grupoVeh createUnit [_tipoSoldado, _posorigen, [],0, "NONE"];
						_soldado assignAsCargo _veh;
						_soldado moveInCargo _veh;
						_soldados pushBack _soldado;
						[_soldado] call NATOinit;
						};
					*/
					_grupoVeh selectLeader (units _grupoVeh select 1);
					if ((_mrkOrigen == "airport") or (_mrkOrigen == "airport_2")) then {[_mrkOrigen,_landPos,_grupoVeh] call WPCreate};
					_Vwp0 = (wayPoints _grupoVeh) select 0;
					_Vwp0 setWaypointBehaviour "SAFE";
					_Vwp0 = (wayPoints _grupoVeh) select ((count wayPoints _grupoVeh) - 1);
					_Vwp0 setWaypointType "GETOUT";
					_Vwp0 = _grupoVeh addWaypoint [_landPos, count (wayPoints _grupoVeh)];
					_Vwp0 setWaypointType "MOVE";
					_Vwp0 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
					/*
					_Vwp1 = _grupoVeh addWaypoint [_posDestino, count (wayPoints _grupoVeh)];
					_Vwp1 setWaypointType "MOVE";
					_Vwp1 setWaypointBehaviour "COMBAT";
					_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_Vwp1 = _grupoVeh addWaypoint [_posDestino, count (wayPoints _grupoVeh)];
					_Vwp1 setWaypointType "SAD";
					*/
					[_veh,"Inf Truck."] spawn inmuneConvoy;
					};
				}
			else
				{
				if ((_mrkOrigen == "airport") or (_mrkOrigen == "airport_2")) then {[_mrkOrigen,_posDestino,_grupoVeh] call WPCreate};
				_Vwp0 = (wayPoints _grupoVeh) select 0;
				_Vwp0 setWaypointBehaviour "SAFE";
				_Vwp0 = _grupoVeh addWaypoint [_posDestino, count (wayPoints _grupoVeh)];
				_Vwp0 setWaypointType "MOVE";
				_Vwp0 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
				_Vwp0 = _grupoVeh addWaypoint [_posDestino, count (wayPoints _grupoVeh)];
				_Vwp0 setWaypointType "SAD";
				[_veh,"Tank"] spawn inmuneConvoy;
				_veh allowCrewInImmobile true;
				};
			sleep 10;
			_cuenta = _cuenta + 1;
			};
		}
	else
		{
		_nVeh = 2*_nVeh;
		};

	_esMar = false;

	for "_i" from 0 to 3 do
		{
		_pos = _posDestino getPos [1000,(_i*90)];
		if (surfaceIsWater _pos) exitWith
			{
			if (_lado == malos) then
				{
				if ({_x in mrkNATO} count puertos > 1) then
					{
					_esMar = true;
					};
				}
			else
				{
				if ({_x in mrkCSAT} count puertos > 1) then
					{
					_esMar = true;
					};
				};
			};
		};

	if ((_esMar) and (_firstWave)) then
		{
		//_ang = [_landpos,_posDestino] call BIS_fnc_dirTo;
		//_ang = _ang - 180;
		//_pos = _landPos getPos [1200,_ang];
		//_pos = [_landPos, 800, 2000, 10, 2, 0.3, 0] call BIS_Fnc_findSafePos;
		_pos = getMarkerPos ([seaAttackSpawn,_posDestino] call BIS_fnc_nearestPosition);
		if (count _pos > 0) then
			{
			_vehPool = if (_lado == malos) then {vehNATOBoats} else {vehCSATBoats};
			_cuenta = 0;
			while {_cuenta < 3} do
				{
				_tipoVeh = selectRandom _vehPool;
				if (not([_tipoVeh] call vehAvailable)) then
					{
					_tipoVeh = if (_lado == malos) then {vehNATORBoat} else {vehCSATRBoat};
					_vehPool = _vehPool - [_tipoVeh];
					};
				if ((_tipoVeh == vehNATOBoat) or (_tipoVeh == vehCSATBoat)) then
					{
					_landPos = [_posDestino, 10, 1000, 10, 2, 0.3, 0] call BIS_Fnc_findSafePos;
					}
				else
					{
					_tipogrupo = [_tipoVeh,_lado] call cargoSeats;
					_landPos = [_posDestino, 10, 1000, 10, 2, 0.3, 1] call BIS_Fnc_findSafePos;
					if (debug) then
						{
						_mrkfin = createMarker [format ["%1", random 100], _landpos];
						_mrkfin setMarkerShape "ICON";
						_mrkfin setMarkerType "hd_destroy";
						};
					};
				if (count _landPos > 0) then
					{
					_vehicle=[_pos, random 360,_tipoveh, _lado] call bis_fnc_spawnvehicle;
					_veh = _vehicle select 0;
					_vehCrew = _vehicle select 1;
					_grupoVeh = _vehicle select 2;
					_pilotos append _vehCrew;
					_grupos pushBack _grupoVeh;
					_vehiculos pushBack _veh;
					diag_log format ["Antistasi: Sea Attack %1 spawned. Number of vehicles %2",_tipoVeh,count _vehiculos];
					{[_x] call NATOinit} forEach units _grupoVeh;
					[_veh] call AIVEHinit;
					if ((_tipoVeh == vehNATOBoat) or (_tipoVeh == vehCSATBoat)) then
						{
						_wp0 = _grupoVeh addWaypoint [_landpos, 0];
						_wp0 setWaypointType "SAD";
						[_veh,"Boat"] spawn inmuneConvoy;
						}
					else
						{
						_grupo = [_posorigen,_lado, _tipogrupo] call BIS_Fnc_spawnGroup;
						{_x assignAsCargo _veh;_x moveInCargo _veh; _soldados pushBack _x;_soldadosTotal pushBack _x;[_x] call NATOinit} forEach units _grupo;
						if (_tipoVeh in vehAPCs) then
							{
							_grupos pushBack _grupo;
							_Vwp = _grupoVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointType "MOVE";
							_Vwp setWaypointSpeed "FULL";
							_Vwp0 = _grupoVeh addWaypoint [_landPos, 0];
							//_Vwp0 setWaypointBehaviour "SAFE";
							_Vwp0 setWaypointType "TR UNLOAD";
							//_Vwp0 setWaypointSpeed "FULL";
							//_Vwp0 setWayPointCompletionRadius (10*_i);
							//_Vwp0 setWaypointStatements ["true", "[vehicle this] call smokeCoverAuto"];
							_Vwp1 = _grupoVeh addWaypoint [_posdestino, 1];
							_Vwp1 setWaypointType "SAD";
							_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							_Vwp1 setWaypointBehaviour "COMBAT";
							_Vwp2 = _grupo addWaypoint [_landPos, 0];
							_Vwp2 setWaypointType "GETOUT";
							_grupo setVariable ["mrkAttack",_mrkDestino];
							_Vwp2 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
							_Vwp0 synchronizeWaypoint [_Vwp2];
							_Vwp3 = _grupo addWaypoint [_posdestino, 1];
							_Vwp3 setWaypointType "MOVE";
							_Vwp3 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							_Vwp3 = _grupo addWaypoint [_posdestino, 1];
							_Vwp3 setWaypointType "SAD";
							_veh allowCrewInImmobile true;
							[_veh,"APC"] spawn inmuneConvoy;
							}
						else
							{
							{[_x] join _grupoVeh} forEach units _grupo;
							deleteGroup _grupo;
							_grupoVeh selectLeader (units _grupoVeh select 1);
							_Vwp = _grupoVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointType "MOVE";
							_Vwp0 = _grupoVeh addWaypoint [_landPos, 0];
							_Vwp0 setWaypointSpeed "FULL";
							//_Vwp0 setWaypointBehaviour "SAFE";
							_Vwp0 setWaypointType "GETOUT";
							_grupoVeh setVariable ["mrkAttack",_mrkDestino];
							_Vwp0 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
							//_Vwp0 setWaypointSpeed "FULL";
							_Vwp1 = _grupoVeh addWaypoint [_posDestino, 1];
							_Vwp1 setWaypointType "MOVE";
							_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							_Vwp1 setWaypointBehaviour "COMBAT";
							_Vwp1 = _grupoVeh addWaypoint [_posDestino, 1];
							_Vwp1 setWaypointType "SAD";
							[_veh,"Boat"] spawn inmuneConvoy;
							};
						};
					};
				sleep 15;
				_cuenta = _cuenta + 1;
				};
			};
		};
	if (([_mrkDestino,true] call fogCheck >= 0.3) or (_waves < 0)) then
		{
		if (_posOrigen distance _posDestino < 5000) then {sleep ((_posOrigen distance _posDestino)/30)};
		_posSuelo = [_posOrigen select 0,_posorigen select 1,0];
		_posOrigen set [2,300];
		_tipoVeh = if (_lado == malos) then {vehNATOUAV} else {vehCSATUAV};

		_uav = createVehicle [_tipoVeh, _posorigen, [], 0, "FLY"];
		_vehiculos pushBack _uav;
		[_uav,"UAV"] spawn inmuneConvoy;
		[_uav,_mrkDestino,_lado] spawn VANTinfo;
		createVehicleCrew _uav;
		_pilotos append (crew _uav);
		_grupouav = group (crew _uav select 0);
		_grupos pushBack _grupouav;
		{[_x] call NATOinit} forEach units _grupoUav;
		[_uav] call AIVEHinit;
		_uwp0 = _grupouav addWayPoint [_posdestino,0];
		_uwp0 setWaypointBehaviour "AWARE";
		_uwp0 setWaypointType "SAD";
		if (not(_mrkDestino in aeropuertos)) then {_uav removeMagazines "6Rnd_LG_scalpel"};
		diag_log format ["Antistasi: UAV %1 spawned. Number of vehicles %2",_tipoVeh,count _vehiculos];
		sleep 5;

		_vehPool = if (_lado == malos) then {vehNATOAir select {[_x] call vehAvailable}} else {vehCSATAir select {[_x] call vehAvailable}};
		if (_esSDK) then
			{
			_rnd = random 100;
			if (_lado == malos) then
				{
				if (_rnd > prestigeNATO) then
					{
					_vehPool = _vehPool - [vehNATOPlane];
					};
				}
			else
				{
				if (_rnd > prestigeCSAT) then
					{
					_vehPool = _vehPool - [vehCSATPlane];
					};
				};
			};
		if ((_waves != 1) and (_firstWave)) then
			{
			if (count (_vehPool - vehTransportAir) != 0) then {_vehPool = _vehPool - vehTransportAir};
			};
		_cuenta = 1;
		_pos = _posOrigen;
		_ang = 0;
		_size = [_mrkOrigen] call sizeMarker;
		_buildings = nearestObjects [_posOrigen, ["Land_LandMark_F","Land_runway_edgelight"], _size / 2];
		if (count _buildings > 1) then
			{
			_pos1 = getPos (_buildings select 0);
			_pos2 = getPos (_buildings select 1);
			_ang = [_pos1, _pos2] call BIS_fnc_DirTo;
			_pos = [_pos1, 5,_ang] call BIS_fnc_relPos;
			};

		while {_cuenta <= _nVeh} do
			{
			_tipoVeh = selectRandom _vehPool;
			/*if (not([_tipoVeh] call vehAvailable)) then
				{
				_tipoVeh = if (_lado == malos) then {selectRandom vehNATOTransportHelis} else {selectRandom vehCSATTransportHelis};
				_vehPool = _vehPool - [_tipoVeh];
				};*/
			if (_cuenta == _nVeh) then
				{
				_tipoVeh = if (_lado == malos) then {selectRandom vehNATOTransportHelis} else {selectRandom vehCSATTransportHelis};
				};
			/*
			_timeOut = 0;
			_pos = _posorigen findEmptyPosition [0,100,_tipoveh];
			while {_timeOut < 60} do
				{
				if (count _pos > 0) exitWith {};
				_timeOut = _timeOut + 1;
				_pos = _posorigen findEmptyPosition [0,100,_tipoveh];
				sleep 1;
				};
			if (count _pos == 0) then {_pos = _posorigen};
			*/
			_vehicle=[_pos, _ang + 90,_tipoveh, _lado] call bis_fnc_spawnvehicle;
			_veh = _vehicle select 0;
			_vehCrew = _vehicle select 1;
			_grupoVeh = _vehicle select 2;
			_pilotos append _vehCrew;
			_vehiculos pushBack _veh;
			diag_log format ["Antistasi Debug wavedCA: %1 spawned, total amount %2, _cuenta: %3, _nVeh %4",_tipoVeh,count _vehiculos,_cuenta,_nVeh];
			{[_x] call NATOinit} forEach units _grupoVeh;
			[_veh] call AIVEHinit;
			if (not (_tipoVeh in vehTransportAir)) then
				{
				{[_x] joinSilent _grupoUav} forEach units _grupoVeh;
				deleteGroup _grupoVeh;
				[_veh,"Air Attack"] spawn inmuneConvoy;
				}
			else
				{
				_grupos pushBack _grupoVeh;
				_tipogrupo = [_tipoVeh,_lado] call cargoSeats;
				_grupo = [_posSuelo,_lado, _tipoGrupo] call spawnGroup;
				_grupos pushBack _grupo;
				{_x assignAsCargo _veh;_x moveInCargo _veh; _soldados pushBack _x;_soldadosTotal pushBack _x;[_x] call NATOinit} forEach units _grupo;
				if (/*(_mrkDestino in aeropuertos) or*/ !(_veh isKindOf "Helicopter")) then
					{
					{removebackpack _x; _x addBackpack "B_Parachute"} forEach units _grupo;
					[_veh,_grupo,_mrkDestino,_mrkOrigen] spawn airdrop;
					}
				else
					{
					_proceder = true;
					/*
					if (_esSDK) then
						{
						if (((count(garrison getVariable _mrkDestino)) < 10) and (_tipoVeh in vehFastRope)) then
							{
							_proceder = false;
							[_veh,_grupo,_posDestino,_posOrigen,_grupoVeh] spawn fastrope;
							};
						};
					*/
					if (_proceder) then
						{
						//{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _grupoVeh;
						_pos = _posDestino getPos [(random 500) + 300, random 360];
						/*_landPos = _pos findEmptyPosition [0,100,_tipoveh];
						if (count _landPos > 0) then
							{
							_isFlatEmpty = !(_landPos isFlatEmpty  [1, -1, 0.1, 15, -1, false, objNull] isEqualTo []);
							if (!_isFlatEmpty) then
								{
								_landPos = [];
								};
							};

						if (count _landPos > 0) then
							*/
						//here! magic!!!
						_landPos = [_posDestino, 200, 350, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
						if !(_landPos isEqualTo [0,0,0]) then
							{
							_landPos set [2, 0];
							_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
							_vehiculos pushBack _pad;
							_wp0 = _grupoVeh addWaypoint [_landpos, 0];
							_wp0 setWaypointType "TR UNLOAD";
							_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';[vehicle this] call smokeCoverAuto"];
							_wp0 setWaypointBehaviour "CARELESS";
							_wp3 = _grupo addWaypoint [_landpos, 0];
							_wp3 setWaypointType "GETOUT";
							_grupo setVariable ["mrkAttack",_mrkDestino];
							_wp3 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
							_wp0 synchronizeWaypoint [_wp3];
							_wp4 = _grupo addWaypoint [_posDestino, 1];
							_wp4 setWaypointType "MOVE";
							_wp4 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							_wp4 = _grupo addWaypoint [_posDestino, 1];
							_wp4 setWaypointType "SAD";
							_wp2 = _grupoVeh addWaypoint [_posOrigen, 1];
							_wp2 setWaypointType "MOVE";
							_wp2 setWaypointStatements ["true", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
							[_grupoVeh,1] setWaypointBehaviour "AWARE";
							}
						else
							{
							{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _grupoVeh;
							if ((_tipoVeh in vehFastRope) and ((count(garrison getVariable _mrkDestino)) < 10)) then
								{
								_grupo setVariable ["mrkAttack",_mrkDestino];
								[_veh,_grupo,_posDestino,_posOrigen,_grupoVeh] spawn fastrope;
								}
							else
								{
								{removebackpack _x; _x addBackpack "B_Parachute"} forEach units _grupo;
								[_veh,_grupo,_mrkDestino,_mrkOrigen] spawn airdrop;
								}
							};
						};
					};
				};
			sleep 1;
			_pos = [_pos, 80,_ang] call BIS_fnc_relPos;
			_cuenta = _cuenta + 1;
			};
		};
	_plane = if (_lado == malos) then {vehNATOPlane} else {vehCSATPlane};
	if (_lado == malos) then
		{
		if ((not(_mrkDestino in puestos)) and (not(_mrkDestino in puertos))) then
			{
			[_mrkOrigen,_mrkDestino] spawn artilleria;
			diag_log "Antistasi: Arty Spawned";
			if (([_plane] call vehAvailable) and (not(_mrkDestino in ciudades)) and _firstWave) then
				{
				sleep 60;
				_rnd = if (_mrkDestino in aeropuertos) then {round random 4} else {round random 2};
				for "_i" from 0 to _rnd do
					{
					diag_log "Antistasi: Airstrike Spawned";
					if (_i == 0) then
						{
						if (_mrkDestino in aeropuertos) then
							{
							_nul = [_mrkdestino,_lado,"HE"] spawn airstrike;
							}
						else
							{
							_nul = [_mrkdestino,_lado,selectRandom ["HE","CLUSTER","NAPALM"]] spawn airstrike;
							};
						}
					else
						{
						_nul = [_mrkdestino,_lado,selectRandom ["HE","CLUSTER","NAPALM"]] spawn airstrike;
						};
					sleep 30;
					};
				};
			};
		}
	else
		{
		if ((not(_mrkDestino in recursos)) and (not(_mrkDestino in puertos))) then
			{
			[_mrkOrigen,_mrkDestino] spawn artilleria;
			diag_log "Antistasi: Arty Spawned";
			if (([_plane] call vehAvailable) and (_firstWave)) then
				{
				sleep 60;
				_rnd = if (_mrkDestino in aeropuertos) then {if ({_x in mrkCSAT} count aeropuertos == 1) then {8} else {round random 4}} else {round random 2};
				for "_i" from 0 to _rnd do
					{
					diag_log "Antistasi: Airstrike Spawned";
					if (_i == 0) then
						{
						if (_mrkDestino in aeropuertos) then
							{
							_nul = [_mrkdestino,_lado,"HE"] spawn airstrike;
							}
						else
							{
							_nul = [_mrkdestino,_lado,selectRandom ["HE","CLUSTER","NAPALM"]] spawn airstrike;
							};
						}
					else
						{
						_nul = [_posDestino,_lado,selectRandom ["HE","CLUSTER","NAPALM"]] spawn airstrike;
						};
					sleep 30;
					};
				};
			};
		};

	if (!_SDKShown) then
		{
		_SDKShown = [true] call FIAradio;
		if (_SDKShown) then
			{
			sleep 60;
			["TaskSucceeded", ["", "Attack Destination Updated"]] remoteExec ["BIS_fnc_showNotification",buenos];
			_tsk = ["AtaqueAAF",buenos,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"CREATED",10,true,true,"Defend"] call BIS_fnc_setTask;
			};
		};

	_waves = _waves -1;
	_firstWave = false;
	_solMax = round ((count _soldados)*0.6);
	diag_log format ["Antistasi: Reached end of spawning attack, wave %1",_waves];
	if (_lado == malos) then
		{
		waitUntil {sleep 5; (({(captive _x) or (!alive _x) or (lifeState _x == "INCAPACITATED")} count _soldados) >= _solMax) /*or ({alive _x} count _soldados < _solMax) */or (time > _tiempo) or (_mrkDestino in mrkNATO) or (({(alive _x) and (!captive _x) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count _soldados) > 3*({(alive _x) and (!captive _x) and (side _x != _lado) and (side _x != civilian) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count allUnits))};
		if  ((({(alive _x) and (!captive _x) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count _soldados) > 3*({(alive _x) and (!captive _x) and (side _x != _lado) and (side _x != civilian) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count allUnits)) or (_mrkDestino in mrkNATO)) then
			{
			_waves = 0;
			if (not(_mrkDestino in mrkNATO)) then {["BLUFORSpawn",_mrkDestino] remoteExec ["markerChange",2]};
			_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkOrigen],getMarkerPos _mrkOrigen,"FAILED",10,true,true,"Defend"] call BIS_fnc_setTask;
			_tsk1 = ["AtaqueAAF1",_ladosTsk1,[format ["We are attacking an %2 from the %1. Help the operation if you can",_nombreorig,_nombreDest],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"SUCEEDED",10,true,true,"Attack"] call BIS_fnc_setTask;
			if (_mrkDestino in ciudades) then
				{
				[0,-100,_mrkDestino] remoteExec ["citySupportChange",2];
				["TaskFailed", ["", format ["%1 joined NATO",[_mrkDestino, false] call fn_location]]] remoteExec ["BIS_fnc_showNotification",buenos];
				mrkNATO = mrkNATO + [_mrkDestino];
				mrkSDK = mrkSDK - [_mrkDestino];
				publicVariable "mrkNATO";
				publicVariable "mrkSDK";
				_nul = [-5,0] remoteExec ["prestige",2];
				_mrkD = format ["Dum%1",_mrkDestino];
				_mrkD setMarkerColor colorMalos;
				garrison setVariable [_mrkDestino,[],true];
				};
			};
		sleep 10;
		if (!(_mrkDestino in mrkNATO)) then
			{
			_tiempo = time + 3600;
			if (_mrkOrigen in mrkNATO) then
				{
				_killZones = killZones getVariable _mrkOrigen;
				_killZones append [_mrkDestino,_mrkDestino,_mrkDestino];
				killZones setVariable [_mrkOrigen,_killZones,true];
				};
			if ((_waves == 0) or (!(_mrkOrigen in mrkNATO))) then
				{
				{_x doMove _posorigen} forEach _soldadosTotal;
				if (_waves == 0) then {[_mrkDestino,_mrkOrigen] call minefieldAAF};
				_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkOrigen],getMarkerPos _mrkOrigen,"SUCCEEDED",10,true,true,"Defend"] call BIS_fnc_setTask;
				_tsk1 = ["AtaqueAAF1",_ladosTsk1,[format ["We are attacking an %2 from the %1. Help the operation if you can",_nombreorig,_nombreDest],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"FAILED",10,true,true,"Attack"] call BIS_fnc_setTask;
				};
			};
		}
	else
		{
		waitUntil {sleep 5; (({(captive _x) or (!alive _x) or (lifeState _x == "INCAPACITATED")} count _soldados) >= _solMax)/* or ({alive _x} count _soldados < _solMax)*/ or (time > _tiempo) or (_mrkDestino in mrkCSAT) or (({(alive _x) and (!captive _x) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count _soldados) > 3*({(alive _x) and (!captive _x) and (side _x != _lado) and (side _x != civilian) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count allUnits))};
		if  ((({(alive _x) and (!captive _x) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count _soldados) > 3*({(alive _x) and (!captive _x) and (side _x != _lado) and (side _x != civilian) and /*(_x distance _posDestino <= _size)*/(_x inArea _mrkDestino)} count allUnits)) or (_mrkDestino in mrkCSAT))  then
			{
			_waves = 0;
			if (not(_mrkDestino in mrkCSAT)) then {["OPFORSpawn",_mrkDestino] remoteExec ["markerChange",2]};
			_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkOrigen],getMarkerPos _mrkOrigen,"FAILED",10,true,true,"Defend"] call BIS_fnc_setTask;
			_tsk1 = ["AtaqueAAF1",_ladosTsk1,[format ["We are attacking an %2 from the %1. Help the operation if you can",_nombreorig,_nombreDest],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"SUCCEEDED",10,true,true,"Attack"] call BIS_fnc_setTask;
			};
		sleep 10;
		if (!(_mrkDestino in mrkCSAT)) then
			{
			_tiempo = time + 3600;
			diag_log format ["Antistasi debug wavedCA: Wave number %1 on wavedCA lost",_waves];
			if (_mrkOrigen in mrkCSAT) then
				{
				_killZones = killZones getVariable _mrkOrigen;
				_killZones append [_mrkDestino,_mrkDestino,_mrkDestino];
				killZones setVariable [_mrkOrigen,_killZones,true];
				};
			if ((_waves == 0) or (!(_mrkOrigen in mrkCSAT))) then
				{
				{_x doMove _posorigen} forEach _soldadosTotal;
				if (_waves == 0) then {[_mrkDestino,_mrkOrigen] call minefieldAAF};
				_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],format ["%1 Attack",_nombreEny],_mrkOrigen],getMarkerPos _mrkOrigen,"SUCCEEDED",10,true,true,"Defend"] call BIS_fnc_setTask;
				_tsk1 = ["AtaqueAAF1",_ladosTsk1,[format ["We are attacking an %2 from the %1. Help the operation if you can",_nombreorig,_nombreDest],format ["%1 Attack",_nombreEny],_mrkDestino],getMarkerPos _mrkDestino,"FAILED",10,true,true,"Attack"] call BIS_fnc_setTask;
				};
			};
		};
	};





//_tsk = ["AtaqueAAF",_ladosTsk,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_nombreorig,_nombreEny],"AAF Attack",_mrkOrigen],getMarkerPos _mrkOrigen,"FAILED",10,true,true,"Defend"] call BIS_fnc_setTask;
if (_esSDK) then
	{
	if (!(_mrkDestino in mrkSDK)) then
		{
		[-10,stavros] call playerScoreAdd;
		}
	else
		{
		{if (isPlayer _x) then {[10,_x] call playerScoreAdd}} forEach ([500,0,_posdestino,"GREENFORSpawn"] call distanceUnits);
		[5,stavros] call playerScoreAdd;
		};
	};
diag_log "Antistasi: Reached end of winning conditions. Starting despawn";
sleep 30;
_nul = [0,_tsk] spawn borrarTask;
_nul = [0,_tsk1] spawn borrarTask;

[_mrkOrigen,60] call addTimeForIdle;
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
//forcedSpawn = forcedSpawn - _forced; publicVariable "forcedSpawn";
forcedSpawn = forcedSpawn - [_mrkDestino]; publicVariable "forcedSpawn";
[3600] remoteExec ["timingCA",2];

{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x};
} forEach _vehiculos;
{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x; _soldadosTotal = _soldadosTotal - [_x]};
} forEach _soldadosTotal;
{
_veh = _x;
if (!([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)) then {deleteVehicle _x; _pilotos = _pilotos - [_x]};
} forEach _pilotos;

if (count _soldadosTotal > 0) then
	{
	{
	[_x] spawn
		{
		private ["_veh"];
		_veh = _this select 0;
		waitUntil {sleep 1; !([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)};
		deleteVehicle _veh;
		};
	} forEach _soldadosTotal;
	};

if (count _pilotos > 0) then
	{
	{
	[_x] spawn
		{
		private ["_veh"];
		_veh = _this select 0;
		waitUntil {sleep 1; !([distanciaSPWN,1,_veh,"GREENFORSpawn"] call distanceUnits) and (({_x distance _veh <= distanciaSPWN} count (allPlayers - HCArray)) == 0)};
		deleteVehicle _veh;
		};
	} forEach _pilotos;
	};
{deleteGroup _x} forEach _grupos;
diag_log "Antistasi: Despawn completed";