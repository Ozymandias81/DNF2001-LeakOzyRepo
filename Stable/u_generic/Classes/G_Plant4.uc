//=============================================================================
// G_Plant4.
//=================================Created Feb 24th, 1999 - Stephen Cole
class G_Plant4 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Dirt1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(2)=Class'dnParticles.dnLeaves'
     FragType(3)=Class'dnParticles.dnLeaves'
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     ItemName="Plant"
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=40.000000
     CollisionHeight=18.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_generic.Plant4'
}
