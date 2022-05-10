//=============================================================================
// G_VehicleSpawn_gen_alscar.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_generic.dmx

class G_VehicleSpawn_gen_alscar expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=105.000000,Y=-36.000000,Z=1.500000))
     MountOnSpawn(1)=(MountOrigin=(X=105.000000,Y=36.000000,Z=1.500000))
     MountOnSpawn(2)=(MountOrigin=(X=-110.000000,Y=-37.000000,Z=4.250000))
     MountOnSpawn(3)=(MountOrigin=(X=-110.000000,Y=37.000000,Z=4.250000))
     Mesh=DukeMesh'c_vehicles.gen_alscar'
}
