//=============================================================================
// G_VehicleTaillight.
//=============================================================================
// AllenB

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

class G_VehicleTaillight expands Generic;

defaultproperties
{
     FragType(0)=None
     NumberFragPieces=0
     DestroyedSound=None
     bTakeMomentum=False
     Physics=PHYS_MovingBrush
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture't_generic.keypad.genkeylightred1'
     VisibilityRadius=16000.000000
     VisibilityHeight=16000.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
}
