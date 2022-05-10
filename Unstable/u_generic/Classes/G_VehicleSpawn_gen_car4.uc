//=============================================================================
// G_VehicleSpawn_gen_car4.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_car4 expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=126.000000,Y=-38.400002,Z=5.500000))
     MountOnSpawn(1)=(MountOrigin=(X=126.000000,Y=38.400002,Z=5.500000))
     MountOnSpawn(2)=(MountOrigin=(X=-133.000000,Y=-38.900002,Z=18.250000))
     MountOnSpawn(3)=(MountOrigin=(X=-133.000000,Y=38.900002,Z=18.250000))
     Mesh=DukeMesh'c_vehicles.gen_car4'
}
