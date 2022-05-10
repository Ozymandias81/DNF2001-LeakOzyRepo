//=============================================================================
// G_Gas_Can.
//=====================================Created Feb 24th, 1999 - Stephen Cole
class G_Gas_Can expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(7)=Class'dnParticles.dnDebris_Metal1'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bLandForward=True
     bLandBackwards=True
     bLandUpright=True
     LandFrontCollisionRadius=36.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=36.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.750000,Y=-0.500000,Z=0.000000)
     ItemName="Gas Can"
     bFlammable=True
     CollisionHeight=19.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.gas_can'
}
