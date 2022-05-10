//=============================================================================
// G_VehicleSpawn_gen_limo.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_limo expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=187.000000,Y=-48.000000,Z=7.000000))
     MountOnSpawn(1)=(MountOrigin=(X=187.000000,Y=48.000000,Z=7.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-181.000000,Y=-43.000000,Z=7.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-181.000000,Y=43.000000,Z=7.000000))
     Mesh=DukeMesh'c_vehicles.gen_limo'
}
