//=============================================================================
// dnMeadBoat. 							October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadBoat expands dnVehicles;

// Boat that Duke rides in on the Lake Mead map
// Stationary Boat

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     MountOnSpawn(0)=(SetMountOrigin=True,SetMountAngles=True)
     HealthPrefab=HEALTH_UseHealthVar
     LodMode=LOD_Disabled
     Health=10000
     bNotTargetable=True
     bEdShouldSnap=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_vehicles.MeadBoat'
     SoundVolume=92
     AmbientSound=Sound'a_transport.Watercraft.BoatMoveLp02'
}
