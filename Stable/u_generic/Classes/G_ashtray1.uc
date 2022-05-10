//=============================================================================
// G_ashtray1.
//=============================================================================
class G_ashtray1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     FragSkin=Texture'm_generic.ashtray1'
     NumberFragPieces=24
     FragBaseScale=0.300000
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=8.100000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=8.100000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     Health=20
     ItemName="Large Ashtray"
     CollisionRadius=11.000000
     CollisionHeight=17.100000
     Physics=PHYS_Falling
     Skin=Texture'm_generic.ashtray1'
     Mesh=DukeMesh'c_generic.ashtray1'
}
