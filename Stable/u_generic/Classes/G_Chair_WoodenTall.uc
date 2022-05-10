//=============================================================================
// G_Chair_WoodenTall.					January 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class G_Chair_WoodenTall expands G_Chair_Wooden;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     LandFrontCollisionRadius=44.000000
     LandSideCollisionRadius=44.000000
     PlayerViewOffset=(Z=3.000000)
     Mesh=DukeMesh'c_generic.wooden_chair1B'
     CollisionRadius=16.000000
     CollisionHeight=30.000000
}
