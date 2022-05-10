//=============================================================================
// Z5_cornstalk.
//=============================================================================
class Z5_cornstalk expands Zone5_Area51;

//==============================March 18th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(1)=Class'dnParticles.dnLeaves'
     FragType(2)=Class'dnParticles.dnDebris_Dirt1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(4)=Class'dnParticles.dnLeaves'
     FragType(5)=Class'dnParticles.dnLeaves'
     FragType(6)=Class'dnParticles.dnLeaves'
     FragType(7)=Class'dnParticles.dnLeaves'
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     LodScale=20.000000
     LodOffset=300.000000
     Health=0
     ItemName="Corn Stalk"
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     bAlwaysRelevant=True
     CollisionHeight=32.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Style=STY_Masked
     Mesh=DukeMesh'c_zone5_area51.corn1'
}
