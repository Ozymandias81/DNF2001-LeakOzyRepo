//=============================================================================
// G_LightBeam.
//=============================================================================
// AllenB
class G_LightBeam expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     bTakeMomentum=False
     Physics=PHYS_MovingBrush
     LodMode=LOD_Disabled
     bDirectional=True
     Mesh=DukeMesh'c_generic.lightbeam1'
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=5.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
}
