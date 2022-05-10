//=============================================================================
// G_VehicleSpawn_semi1.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_semi1 expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=167.699997,Y=-35.400002))
     MountOnSpawn(1)=(MountOrigin=(X=167.699997,Y=35.400002))
     MountOnSpawn(2)=(MountOrigin=(X=-170.000000,Y=-38.200001,Z=-7.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-170.000000,Y=38.200001,Z=-7.000000))
     Mesh=DukeMesh'c_vehicles.semi1'
}
