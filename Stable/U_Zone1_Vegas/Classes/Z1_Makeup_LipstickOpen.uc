//=============================================================================
// Z1_Makeup_LipstickOpen. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Makeup_LipstickOpen expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=3.000000
     LandFrontCollisionHeight=1.000000
     LandSideCollisionRadius=3.000000
     LandSideCollisionHeight=1.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.750000,Y=-1.550000,Z=2.250000)
     BobDamping=0.975000
     ItemName="Lipstick"
     CollisionRadius=3.000000
     CollisionHeight=2.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.makeup_lipSopen'
}
