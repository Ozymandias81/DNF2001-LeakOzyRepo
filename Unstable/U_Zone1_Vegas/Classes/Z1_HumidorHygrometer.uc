//=============================================================================
// Z1_HumidorHygrometer.							Keith Schuler 5/21/99
//=============================================================================
class Z1_HumidorHygrometer expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(6)=Class'dnParticles.dnDebris_Smoke'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=-0.250000,Z=0.000000)
     BobDamping=0.900000
     ItemName="Hygrometer"
     bTakeMomentum=False
     bFlammable=True
     bIgnitable=True
     CollisionRadius=8.000000
     CollisionHeight=8.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.humameter'
}
