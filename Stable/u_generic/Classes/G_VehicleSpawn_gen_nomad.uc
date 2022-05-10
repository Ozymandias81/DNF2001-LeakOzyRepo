//=============================================================================
// G_VehicleSpawn_gen_nomad.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_nomad expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=141.000000,Y=-32.000000,Z=9.000000))
     MountOnSpawn(1)=(MountOrigin=(X=141.000000,Y=32.000000,Z=9.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-139.000000,Y=-46.000000,Z=11.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-139.000000,Y=49.000000,Z=11.000000))
     Mesh=DukeMesh'c_vehicles.gen_nomad'
}
