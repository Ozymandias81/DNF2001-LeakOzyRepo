//=============================================================================
// G_VehicleSpawn_gen_car.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_car expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=107.000000,Y=-35.000000,Z=-1.010000))
     MountOnSpawn(1)=(MountOrigin=(X=107.000000,Y=35.000000,Z=-1.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-120.000000,Y=-37.000000,Z=3.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-120.000000,Y=37.000000,Z=3.000000))
     Mesh=DukeMesh'c_vehicles.gen_car'
}
