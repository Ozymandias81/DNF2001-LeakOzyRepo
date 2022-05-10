//=============================================================================
// G_VehicleSpawn_gen_pinto.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_pinto expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=118.000000,Y=-23.000000,Z=1.000000))
     MountOnSpawn(1)=(MountOrigin=(X=118.000000,Y=23.000000,Z=1.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-116.000000,Y=-32.000000,Z=-3.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-116.000000,Y=32.000000,Z=-3.000000))
     Mesh=DukeMesh'c_vehicles.gen_pinto'
}
