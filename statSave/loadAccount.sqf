if (!isDedicated) then
	{
	if (side player == buenos) then
		{
		["gogglesPlayer"] call fn_LoadStat;
		["vestPlayer"] call fn_LoadStat;
		["outfit"] call fn_LoadStat;
		["hat"] call fn_LoadStat;
		{player removeMagazine _x} forEach magazines player;
		{player removeWeaponGlobal _x} forEach weapons player;
		removeBackpackGlobal player;
		if ("ItemGPS" in (assignedItems player)) then {player unlinkItem "ItemGPS"};
		if ((!hayTFAR) and (!hayACRE) and ("ItemRadio" in (assignedItems player)) and (not("ItemRadio" in unlockedItems))) then {player unlinkItem "ItemRadio"};
		player setPos getMarkerPos "respawn_guerrila";
		if (isMultiplayer) then
			{
			if ([player] call isMember) then
				{
				["scorePlayer"] call fn_LoadStat;
				["rankPlayer"] call fn_LoadStat;
				};
			["dinero"] call fn_LoadStat;
			["personalGarage"] call fn_LoadStat;
			diag_log "Antistasi: MP Personal player stats loaded";
			}
		else
			{
			diag_log "Antistasi: SP Personal player stats loaded";
			};
		};
	};

if (!isServer) exitWith {};
statsLoaded = 0; publicVariable "statsLoaded";
//ADD STATS THAT NEED TO BE LOADED HERE.
petros allowdamage false;

["puestosFIA"] call fn_LoadStat; publicVariable "puestosFIA";
["mrkSDK"] call fn_LoadStat; mrkSDK = mrkSDK + puestosFIA; publicVariable "mrkSDK"; if (isMultiplayer) then {sleep 5};
["mrkNATO"] call fn_LoadStat;
["mrkCSAT"] call fn_LoadStat;
["destroyedCities"] call fn_LoadStat;
["minas"] call fn_LoadStat;
["cuentaCA"] call fn_LoadStat;
["antenas"] call fn_LoadStat;
["prestigeNATO"] call fn_LoadStat;
["prestigeCSAT"] call fn_LoadStat;
["hr"] call fn_LoadStat;/*
["armas"] call fn_LoadStat;
["municion"] call fn_LoadStat;
["items"] call fn_LoadStat;
["mochis"] call fn_LoadStat;*/
["fecha"] call fn_LoadStat;
["weather"] call fn_LoadStat;
["prestigeOPFOR"] call fn_LoadStat;
["prestigeBLUFOR"] call fn_LoadStat;
["resourcesFIA"] call fn_LoadStat;
["garrison"] call fn_LoadStat;
["skillFIA"] call fn_LoadStat;
["distanciaSPWN"] call fn_LoadStat;
["civPerc"] call fn_LoadStat;
["maxUnits"] call fn_LoadStat;
//["smallCAmrk"] call fn_LoadStat;
["miembros"] call fn_LoadStat;/*
["unlockedItems"] call fn_LoadStat;
["unlockedMagazines"] call fn_LoadStat;
["unlockedWeapons"] call fn_LoadStat;
["unlockedBackpacks"] call fn_LoadStat;*/
["vehInGarage"] call fn_LoadStat;
["destroyedBuildings"] call fn_LoadStat;
["idlebases"] call fn_LoadStat;
["idleassets"] call fn_LoadStat;
["killZones"] call fn_LoadStat;
["controlesSDK"] call fn_LoadStat;
waitUntil {!isNil "arsenalInit"};
["jna_dataList"] call fn_LoadStat;
//===========================================================================
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

unlockedWeapons = [];

{unlockedWeapons pushBack (_x select 0)} forEach (((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HANDGUN) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON)) select {_x select 1 == -1}); publicVariable "unlockedWeapons";
unlockedBackpacks = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BACKPACK) select {_x select 1 == -1}; publicVariable "unlockedBackpacks";
unlockedMagazines = ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL)) select {_x select 1 == -1}; publicVariable "unlockedMagazines";
unlockedOptics = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC) select {_x select 1 == -1}; publicVariable "unlockedOptics";
unlockedItems = (((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_VEST) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GOGGLES) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_MAP) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GPS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_COMPASS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_WATCH) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMACC) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_NVGS)) select {_x select 1 == -1}) + unlockedOptics; publicVariable "unlockedItems";


//unlockedRifles = unlockedweapons -  hguns -  mlaunchers - rlaunchers - ["Binocular","Laserdesignator","Rangefinder"] - srifles - mguns; publicVariable "unlockedRifles";
unlockedRifles = unlockedweapons select {_x in arifles}; publicVariable "unlockedRifles";
_marcadores = mrkSDK + mrkNATO + mrkCSAT;

{
if !(_x in mrkSDK) then
	{
	_posicion = getMarkerPos _x;
	_cercano = [_marcadores,_posicion] call BIS_fnc_nearestPosition;
	if (_cercano in mrkSDK) then
		{
		if (_x in mrkNATO) then {mrkNATO = mrkNATO - [_x]};
		if (_x in mrkCSAT) then {mrkCSAT = mrkCSAT - [_x]};
		mrkSDK pushBackUnique _x;
		}
	else
		{
		if (_cercano in mrkNATO) then {mrkNATO pushBackUnique _x} else {mrkCSAT pushBackUnique _x};
		};
	};
} forEach controles;

{
if ((not(_x in mrkNATO)) and (not(_x in mrkSDK)) and (_x != "Synd_HQ") and (not(_x in mrkCSAT))) then {mrkNATO pushBack _x};
} forEach marcadores;

_marcadores = _marcadores + controles;
/*
{

if (_x in mrkSDK) then
	{
	private ["_mrkD"];
	if (_x != "Synd_HQ") then
		{
		_mrkD = format ["Dum%1",_x];
		_mrkD setMarkerColor colorBuenos;
		};
	if (_x in aeropuertos) then
		{
		_mrkD setMarkerText format ["SDK Airport: %1",count (garrison getVariable _x)];
		_mrkD setMarkerType "flag_FIA";
	    };
	if (_x in puestos) then
		{
		_mrkD setMarkerText format ["SDK Outpost: %1",count (garrison getVariable _x)];
		};
	if (_x in ciudades) then
		{
		if (_x in destroyedCities) then {[_x] call destroyCity};
		};
	if ((_x in recursos) or (_x in fabricas)) then
		{
		if (_x in recursos) then {_mrkD setMarkerText format ["Resource: %1",count (garrison getVariable _x)]} else {_mrkD setMarkerText format ["Factory: %1",count (garrison getVariable _x)]};
		if (_x in destroyedCities) then {[_x] call destroyCity};
		};
	if (_x in puertos) then
		{
		_mrkD setMarkerText format ["Sea Port: %1",count (garrison getVariable _x)];
		};
	if (_x in power) then
		{
		_mrkD setMarkerText format ["Power Plant: %1",count (garrison getVariable _x)];
		if (_x in destroyedCities) then {[_x] call destroyCity};
		};
	};

if (_x in mrkNATO) then
	{
	if (_x in destroyedCities) then {[_x] call destroyCity};
	};

} forEach _marcadores;
*/
{[_x] call mrkUpdate} forEach _marcadores;

{if (_x in destroyedCities) then {[_x] call destroyCity}} forEach ciudades;

{if (not (_x in _marcadores)) then {if (_x != "Synd_HQ") then {_marcadores pushBack _x; mrkNATO pushback _x} else {mrkNATO = mrkNATO - ["Synd_HQ"]; if (not("Synd_HQ" in mrkSDK)) then {mrkSDK = mrkSDK + ["Synd_HQ"]}}}} forEach marcadores;//por si actualizo zonas.

marcadores = _marcadores;
publicVariable "marcadores";
publicVariable "mrkNATO";
publicVariable "mrkSDK";
publicVariable "mrkCSAT";
["chopForest"] call fn_LoadStat;
["posHQ"] call fn_LoadStat;
["estaticas"] call fn_LoadStat;//tiene que ser el último para que el sleep del borrado del contenido no haga que despawneen

//call AAFassets;

if (isMultiplayer) then
	{
	{
	_jugador = _x;
	if (side _jugador == buenos) then
		{
		if ([_jugador] call isMember) then
			{
			{_jugador removeMagazine _x} forEach magazines _jugador;
			{_jugador removeWeaponGlobal _x} forEach weapons _jugador;
			removeBackpackGlobal _jugador;
			};
		_jugador setPos (getMarkerPos "respawn_guerrila");
		if (("ItemRadio" in unlockedItems) and (!hayTFAR)) then {_jugador linkItem "ItemRadio"};
		}
	} forEach playableUnits;
	}
else
	{
	{player removeMagazine _x} forEach magazines player;
	{player removeWeaponGlobal _x} forEach weapons player;
	removeBackpackGlobal player;
	player setPos (getMarkerPos "respawn_guerrila");
	if (("ItemRadio" in unlockedItems) and (!hayTFAR) and (!hayACRE)) then {player linkItem "ItemRadio"};
	};

//[] call arsenalManage;

/*
_aiSkillLimit = ({_x in mrkSDK} count (aeropuertos + puestos + recursos + puertos));
if (_aiSkillLimit < 2) then {_aiSkillLimit = 2};
if (_aiSkillLimit != aiSkillLimit) then {aiSkillLimit = _aiSkillLimit; publicVariable "aiSkillLimit"};
*/
tierWar = 1 + (floor (((2.5*({(_x in puestos) or (_x in recursos) or (_x in ciudades)} count mrkSDK)) + (5*({_x in puertos} count mrkSDK)) + (10*({_x in aeropuertos} count mrkSDK)))/10));
if (tierWar > 10) then {tierWar = 10};
publicVariable "tierWar";
/*
waitUntil {!(isNil "arsenalInit")};
{
private _index = _x call jn_fnc_arsenal_itemType;
[_index,_x,-1] call jn_fnc_arsenal_addItem;
}foreach (unlockeditems + unlockedweapons + unlockedMagazines + unlockedBackpacks);*/
[[petros,"hintCS","Persistent Savegame Loaded"],"commsMP"] call BIS_fnc_MP;
diag_log "Antistasi: Server sided Persistent Load done";

sleep 25;
["tasks"] call fn_LoadStat;

petros allowdamage true;
//END
//hint "Stats loaded";
