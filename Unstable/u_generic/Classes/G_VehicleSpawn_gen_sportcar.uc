//=============================================================================
// G_VehicleSpawn_gen_sportcar.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_sportcar expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=124.000000,Y=-35.500000,Z=-11.000000))
     MountOnSpawn(1)=(MountOrigin=(X=124.000000,Y=35.500000,Z=-11.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-124.000000,Y=-41.000000,Z=7.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-124.000000,Y=41.000000,Z=7.000000))
     Mesh=DukeMesh'c_vehicles.gen_sportcar'
}
