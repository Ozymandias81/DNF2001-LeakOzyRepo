//=============================================================================
// G_Urinal.
//=====================================
class G_Urinal expands G_Toilet;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
	 PissDuration(0)=2.5
	 PissDuration(1)=0.6
	 PissDuration(2)=0.3
	 PissDuration(3)=0.3
	 PissEvents=4
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(6)=Class'dnParticles.dnDebris_Sparks1'
     FragType(7)=Class'dnParticles.dnDebris_Metal1'
	 FragBaseScale=1.0
     IdleAnimations(0)=offloop
	 bUseTriggered=true
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Ceramic.ImpactCer02'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_Urinal_Broken')
     Mesh=DukeMesh'c_generic.urinal'
     ItemName="Urinal"
     CollisionRadius=12.500000
     CollisionHeight=32.000000
     bTakeMomentum=False
	 AnimSequence=offloop
	 PissSound=sound'a_dukevoice.DukeLeak.DNLeak07'
	 FlushSound=sound'a_generic.Water.Urinal1'
	 bToiletSeat=false
}
