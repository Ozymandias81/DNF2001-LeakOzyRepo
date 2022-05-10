//=============================================================================
// G_VehicleHeadlight.
//=============================================================================
// AllenB

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

class G_VehicleHeadlight expands Generic;

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'U_Generic.G_VehicleHeadlight_Mesh')
     FragType(0)=None
     NumberFragPieces=0
     DestroyedSound=None
     LodMode=LOD_Disabled
     VisibilityRadius=16000.000000
     VisibilityHeight=16000.000000
     bTakeMomentum=False
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_MovingBrush
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture't_generic.lensflares.lensflare5RC'
     Mesh=DukeMesh'c_generic.lightbeam1'
     bUnlit=True
     bIgnoreBList=True
     DrawScale=0.750000
}
