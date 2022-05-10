//=============================================================================
// G_SecurityCam1.
//=============================================================================
class G_SecurityCam1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     HealthPrefab=HEALTH_NeverBreak
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Broken Security Camera"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_generic.secrcam1B'
     DrawScale=2.000000
}
