//=============================================================================
// Z3_Lantern3.							November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Lantern3 expands Z3_Lantern;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=None
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=None)
     LandFrontCollisionRadius=11.000000
     LandFrontCollisionHeight=4.000000
     LandSideCollisionRadius=11.000000
     LandSideCollisionHeight=4.000000
     CollisionHeight=11.000000
     Mesh=DukeMesh'c_zone3_canyon.Lantern3'
}
