//=============================================================================
// G_Fire2.							Keith Schuler 5/10/99
//=============================================================================
class G_Fire2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\textures\m_FX.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     DestroyedSound=None
     bTakeMomentum=False
     Physics=PHYS_Falling
     Style=STY_Translucent
     Mesh=DukeMesh'c_FX.firegen1RC'
     bUnlit=True
     CollisionRadius=26.000000
     CollisionHeight=30.000000
     bBlockActors=False
     bBlockPlayers=False
     Health=0
}
