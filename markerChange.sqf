if (!isServer) exitWith {};

private ["_winner","_marcador","_looser","_posicion","_other","_bandera","_banderas","_dist","_texto","_sides"];

_winner = _this select 0;
_marcador = _this select 1;
if ((_winner == "GREENFORSpawn") and (_marcador in aeropuertos) and (tierWar < 3)) exitWith {};
if (_marcador in markersChanging) exitWith {};
markersChanging pushBackUnique _marcador;
_posicion = getMarkerPos _marcador;
_looser = sideUnknown;
_sides = [buenos,malos,muyMalos];
_other = "";
_texto = "";

_bandera = objNull;
_size = [_marcador] call sizeMarker;

if ((!(_marcador in ciudades)) and (spawner getVariable _marcador != 2)) then
	{
	_banderas = nearestObjects [_posicion, ["FlagCarrier"], _size];
	_bandera = _banderas select 0;
	};
if (isNil "_bandera") then {_bandera = objNull};
//[_bandera,"remove"] remoteExec ["flagaction",0,_bandera];

if (_marcador in mrkSDK) then
	{
	_looser = buenos;
	mrkSDK = mrkSDK - [_marcador];
	publicVariable "mrkSDK";
	_texto = "Syndicat ";
	[] call tierCheck;
	}
else
	{
	if (_marcador in mrkNATO) then
		{
		_looser = malos;
		mrkNATO = mrkNATO - [_marcador];
		publicVariable "mrkNATO";
		_texto = "NATO ";
		}
	else
		{
		_looser = muyMalos;
		mrkCSAT = mrkCSAT - [_marcador];
		publicVariable "mrkCSAT";
		_texto = "CSAT ";
		};
	};
garrison setVariable [_marcador,[],true];
if (_winner == "GREENFORSpawn") then
	{
	mrkSDK pushBackUnique _marcador;
	publicVariable "mrkSDK";
	_winner = buenos;
	[_marcador,_looser] remoteExec ["patrolCA",HCattack];
	//sleep 15;
	[_marcador] remoteExec ["autoGarrison",HCattack];
	}
else
	{
	//garrison setVariable [_marcador,0,true];
	_soldados = [];
	{_soldados pushBack (typeOf _x)} forEach (allUnits select {(_x distance _posicion < (_size*3)) and (_x getVariable [_winner,false]) and (vehicle _x == _x)});
	if (_winner == "BLUFORspawn") then
		{
		mrkNATO pushBackUnique _marcador;
		publicVariable "mrkNATO";
		_winner = malos;
		}
	else
		{
		mrkCSAT pushBackUnique _marcador;
		publicVariable "mrkCSAT";
		_winner = muyMalos;
		};
	[_soldados,_winner,_marcador,0] spawn garrisonUpdate;
	};

_nul = [_marcador] call mrkUpdate;
_sides = _sides - [_winner,_looser];
_other = _sides select 0;
if (_marcador in aeropuertos) then
	{
	if (_winner == buenos) then
		{
		[0,10,_posicion] remoteExec ["citySupportChange",2]
		}
	else
		{
		server setVariable [_marcador,dateToNumber date,true];
		[_marcador,60] call addTimeForIdle;
		if (_winner == malos) then
			{
			[10,0,_posicion] remoteExec ["citySupportChange",2]
			}
		else
			{
			[-10,-10,_posicion] remoteExec ["citySupportChange",2]
			}
		};
	["TaskSucceeded", ["", "Airbase Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Airbase Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost an Airbase",_texto]]] remoteExec ["BIS_fnc_showNotification",_other];
	killZones setVariable [_marcador,[],true];
	};
if (_marcador in puestos) then
	{
	["TaskSucceeded", ["", "Outpost Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Outpost Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost an Outpost",_texto]]] remoteExec ["BIS_fnc_showNotification",_other];
	};
if (_marcador in puertos) then
	{
	["TaskSucceeded", ["", "Seaport Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Seaport Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Seaport",_texto]]] remoteExec ["BIS_fnc_showNotification",_other];
	};
if (_marcador in fabricas) then
	{
	["TaskSucceeded", ["", "Factory Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Factory Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Factory",_texto]]] remoteExec ["BIS_fnc_showNotification",_other];
	};
if (_marcador in recursos) then
	{
	["TaskSucceeded", ["", "Resource Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Resource Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Resource",_texto]]] remoteExec ["BIS_fnc_showNotification",_other];
	};

{_nul = [_marcador,_x] spawn deleteControles} forEach controles;
markersChanging = markersChanging - [_marcador];
if (_winner == buenos) then
	{
	[] call tierCheck;
	if (!isNull _bandera) then
		{
		[_bandera,"remove"] remoteExec ["flagaction",0,_bandera];
		[_bandera,"\A3\Data_F_exp\Flags\Flag_Synd_CO.paa"] remoteExec ["setFlagTexture",HCgarrisons];
		sleep 2;
		[_bandera,"unit"] remoteExec ["flagaction",[buenos,civilian],_bandera];
		[_bandera,"vehicle"] remoteExec ["flagaction",[buenos,civilian],_bandera];
		[_bandera,"garage"] remoteExec ["flagaction",[buenos,civilian],_bandera];
		if (_marcador in puertos) then {[_bandera,"seaport"] remoteExec ["flagaction",[buenos,civilian],_bandera]};
		};
	waitUntil {sleep 1; ((spawner getVariable _marcador == 2)) or ({((_x getVariable ["BLUFORSpawn",false]) or (_x getVariable ["OPFORSpawn",false])) and (not(vehicle _x isKindOf "Air")) and (alive _x) and (!captive _x) and (!fleeing _x) and (_x distance _posicion <= _size)} count allUnits > 3*({(alive _x) and (!captive _x) and (!fleeing _x) and (side _x == buenos) and (_x distance _posicion <= _size)} count allUnits))};
	if (spawner getVariable _marcador != 2) then
		{
		[_marcador,buenos] spawn zoneCheck;
		};
	}
else
	{
	if (!isNull _bandera) then
		{
		if (_looser == buenos) then
			{
			[_bandera,"remove"] remoteExec ["flagaction",0,_bandera];
			sleep 2;
			[_bandera,"take"] remoteExec ["flagaction",[buenos,civilian],_bandera];
			};
		if (_winner == malos) then
			{
			[_bandera,"\A3\Data_F\Flags\Flag_NATO_CO.paa"] remoteExec ["setFlagTexture",HCgarrisons];
			}
		else
			{
			[_bandera,"\A3\Data_F\Flags\Flag_CSAT_CO.paa"] remoteExec ["setFlagTexture",HCgarrisons];
			};
		};
	};
if ((_winner != buenos) and (_marcador in aeropuertos) and (_looser != buenos)) then
	{
	_cercanos = (puertos + puestos + recursos - mrkSDK) select {(getMarkerPos _x) distance _posicion < distanciaSPWN};
	if (_looser == malos) then  {_cercanos = _cercanos select {_x in mrkNATO}; _winner = "OPFORSpawn"} else {_cercanos = _cercanos select {_x in mrkCSAT}; _winner = "BLUFORSpawn"};
	{[_winner,_x] spawn markerChange; sleep 5} forEach _cercanos;
	};