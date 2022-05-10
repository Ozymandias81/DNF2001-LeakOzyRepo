//=============================================================================
// Z2_DamSign. 							November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_DamSign expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1_Small'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=18.000000
     LandFrontCollisionHeight=7.500000
     LandSideCollisionRadius=18.000000
     LandSideCollisionHeight=7.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=1.000000)
     BobDamping=0.900000
     ItemName="Sign"
     CollisionRadius=10.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.Damsign1sah'
}
