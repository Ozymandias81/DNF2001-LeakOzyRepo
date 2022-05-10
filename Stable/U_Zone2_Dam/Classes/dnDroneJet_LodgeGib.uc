//=============================================================================
// dnDroneJet_LodgeGib.            Created by Charlie Wiederhold April 14, 2000
//=============================================================================
class dnDroneJet_LodgeGib expands dnDecorationBigFrag;

// Large gib effect spawner.
// Does NOT do damage. 
// Designed for use with the lodge part of the Drone Jet.

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDroneJet_GibSmoke',SurviveDismount=True)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnDroneJet_GibFire')
     FragType(0)=None
     NumberFragPieces=0
     DamageOnHitWall=1000
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnWaterSpray_Effect1')
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnWaterSpray_Effect2')
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     bTakeMomentum=False
     Mesh=DukeMesh'c_vehicles.drone_pcs_lodge'
}
