//=============================================================================
// Z1_LampFloorPenthouse.
//=============================================================================
class Z1_LampFloorPenthouse expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=76.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=76.000000
     LandSideCollisionHeight=6.000000
     PlayerViewOffset=(X=0.500000,Y=5.000000,Z=2.500000)
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Floor Lamp"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=42.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.phouselamp1'
     ScaleGlow=100.000000
}
