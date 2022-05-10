//=============================================================================
// Z1_Ashtray_Cig.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Ashtray_Cig expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnCigaretteSmoke',SetMountOrigin=True,MountOrigin=(X=2.200000,Y=0.275000,Z=-1.250000),AppendToTag=Smoke,TakeParentTag=True)
     FragType(0)=Class'dnParticles.dnDebris_Smoke_Small1'
     SpawnOnHit=None
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_Easy
     bLandUpright=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=-0.500000,Z=0.500000)
     BobDamping=0.990000
     ItemName="Cigarette"
     CollisionRadius=3.000000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.ashtray2_cig1'
}
