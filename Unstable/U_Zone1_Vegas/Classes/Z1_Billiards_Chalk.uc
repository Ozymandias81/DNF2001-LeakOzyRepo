//=============================================================================
// Z1_Billiards_Chalk.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Billiards_Chalk expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke_Small1'
     SpawnOnHit=None
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=0.750000
     LandFrontCollisionHeight=0.600000
     LandSideCollisionRadius=0.750000
     LandSideCollisionHeight=0.600000
     Grabbable=True
     PlayerViewOffset=(X=1.000000,Y=-1.500000,Z=2.000000)
     BobDamping=0.975000
     ItemName="Pool Chalk"
     CollisionRadius=0.750000
     CollisionHeight=0.600000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.billiards_chalk'
}
