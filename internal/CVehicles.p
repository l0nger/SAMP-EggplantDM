/*
	@file: /internal/CVehicles.p
	@author: 
		l0nger <l0nger.programmer@gmail.com>
		
	@licence: GPLv2
	
	(c) 2013-2014, <l0nger.programmer@gmail.com>
*/

#define thevehicle:: thevehicle_

#define VEHICLE_ENTER_NOBODY (0)
#define VEHICLE_ENTER_FRIENDS (1)
#define VEHICLE_ENTER_GANGMEMBERS (2)
#define VEHICLE_ENTER_ALL (3)

#define thevehicle_getDoorEnterType(%0) VehicleData[(%0)-1][evd_doorEnterType]
#define thevehicle_getOwner(%0) VehicleData[(%0)-1][evd_ownerID]
#define thevehicle_getProperties(%0) VehicleData[(%0)-1][evd_properties]

stock CVehicles_Init() {

}

stock CVehicles_Exit() {

}

stock thevehicle::create(modelid, owner=INVALID_PLAYER_ID, Float:x=0.0, Float:y=0.0, Float:z=1.0, Float:rot=90.0, color[2]) {
	if(modelid<=400) return false;
	
	new carid=CreateVehicle(modelid, x, y, z, rot, color[0], color[1], 3*60);
	VehicleData[carid-1][evd_carid]=carid;
	VehicleData[carid-1][evd_modelid]=modelid;
	VehicleData[carid-1][evd_pos][0]=x;
	VehicleData[carid-1][evd_pos][1]=y;
	VehicleData[carid-1][evd_pos][2]=z;
	VehicleData[carid-1][evd_pos][3]=rot;
	
	VehicleData[carid-1][evd_color]=color[0];
	VehicleData[carid-1][evd_color]=color[1];
	
	bit_set(VehicleData[carid-1][evd_properties], VEHICLE_DOOR_OPEN);
	
	if(owner==INVALID_PLAYER_ID) {
		bit_set(VehicleData[carid-1][evd_properties], VEHICLE_ISOWNED);
		VehicleData[carid-1][evd_ownerID]=INVALID_PLAYER_ID;
	} else {
		bit_set(VehicleData[carid-1][evd_properties], VEHICLE_ISOWNED);
		bit_set(VehicleData[carid-1][evd_properties], VEHICLE_DOOR_CLOSED); // zamykamy pojazd przed innymi osobnikami
		VehicleData[carid-1][evd_doorEnterType]=VEHICLE_ENTER_NOBODY;
		VehicleData[carid-1][evd_ownerID]=owner;
	}
	return true;
}
