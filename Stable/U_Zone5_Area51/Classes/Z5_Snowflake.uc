//=============================================================================
// Z5_Snowflake.   Keith Schuler 2/2/2000
//=============================================================================
class Z5_Snowflake expands Z5_FlyingDoor1;

#exec OBJ LOAD FILE=..\Textures\computer.dtx

defaultproperties
{
     Texture=Texture'computer.Effects.snowflake1BC'
     bUnlit=False
     DrawScale=0.062500
     AffectMeshes=False
     LightType=LT_None
     LightBrightness=0
     LightRadius=0
     LightPeriod=0
     LightCone=0
}
