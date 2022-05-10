//=============================================================================
// G_Paintcan.
//===========================================Created Feb 24th, 1999 - Stephen Cole
class G_Paintcan expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'U_Generic.dnDebris_WhitePaint'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=11.000000
     LandFrontCollisionHeight=5.500000
     LandSideCollisionRadius=11.000000
     LandSideCollisionHeight=5.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=-0.100000,Z=0.750000)
     ItemName="Paint Can"
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.paintcan2'
}
