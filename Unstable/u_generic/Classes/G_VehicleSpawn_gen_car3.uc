//=============================================================================
// G_VehicleSpawn_gen_car3.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_car3 expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=126.000000,Y=-38.000000,Z=-0.500000))
     MountOnSpawn(1)=(MountOrigin=(X=126.000000,Y=38.000000,Z=-0.500000))
     MountOnSpawn(2)=(MountOrigin=(X=-136.000000,Y=-39.799999,Z=10.250000))
     MountOnSpawn(3)=(MountOrigin=(X=-136.000000,Y=39.799999,Z=10.250000))
     Mesh=DukeMesh'c_vehicles.gen_car3'
}
