//=============================================================================
// G_VehicleSpawn_gen_car5.
//=============================================================================

#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx
#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx

class G_VehicleSpawn_gen_car5 expands G_VehicleSpawn;

defaultproperties
{
     MountOnSpawn(0)=(MountOrigin=(X=134.000000,Y=-44.000000,Z=-5.000000))
     MountOnSpawn(1)=(MountOrigin=(X=134.000000,Y=44.000000,Z=-5.000000))
     MountOnSpawn(2)=(MountOrigin=(X=-129.000000,Y=-43.000000,Z=11.000000))
     MountOnSpawn(3)=(MountOrigin=(X=-129.000000,Y=43.000000,Z=11.000000))
     Mesh=DukeMesh'c_vehicles.gen_car5'
}
