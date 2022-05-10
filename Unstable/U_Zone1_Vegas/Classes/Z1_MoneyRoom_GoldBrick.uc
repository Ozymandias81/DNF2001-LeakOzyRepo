//=============================================================================
// Z1_MoneyRoom_GoldBrick. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MoneyRoom_GoldBrick expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=6.500000
     LandFrontCollisionHeight=3.000000
     LandSideCollisionRadius=6.500000
     LandSideCollisionHeight=3.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-1.750000,Z=1.500000)
     BobDamping=0.900000
     ItemName="Gold Brick"
     CollisionRadius=6.500000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.moneyr_goldbric'
}
