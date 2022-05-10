//=============================================================================
// Z5_FlyingDoor1.  Created by Keith 1/5/2000
//=============================================================================
class Z5_FlyingDoor1 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\Textures\computer.dtx

defaultproperties
{
     FragType(0)=None
     NumberFragPieces=0
     LodMode=LOD_Disabled
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_Projectile
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'computer.Abstract.SSdoor1'
     bUnlit=True
     LightType=LT_Steady
     LightBrightness=250
     LightRadius=64
     LightPeriod=32
     LightCone=128
     VolumeBrightness=64
}
