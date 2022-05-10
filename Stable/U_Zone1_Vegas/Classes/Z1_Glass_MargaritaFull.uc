//=============================================================================
// Z1_Glass_MargaritaFull. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Glass_MargaritaFull expands Z1_Glass_BeerMug;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     LandFrontCollisionRadius=5.000000
     LandFrontCollisionHeight=3.000000
     LandSideCollisionRadius=5.000000
     LandSideCollisionHeight=3.000000
     ItemName="Margarita"
     CollisionRadius=3.250000
     Mesh=DukeMesh'c_zone1_vegas.gls_magaritaful'
}
