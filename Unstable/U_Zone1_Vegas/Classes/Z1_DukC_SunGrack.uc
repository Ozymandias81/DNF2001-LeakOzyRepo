//=============================================================================
// Z1_DukC_SunGrack.
// Keith Schuler 3/18/99 ======================================================
class Z1_DukC_SunGrack expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     PlayerViewOffset=(X=0.625000,Y=3.000000,Z=2.000000)
     BobDamping=0.850000
     ItemName="Sunglass Rack"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=11.000000
     CollisionHeight=40.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.DukC_SunGrack'
}
