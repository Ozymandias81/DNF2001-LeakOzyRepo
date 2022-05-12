//=============================================================================
// SmokeColumn.
//=============================================================================
class SmokeColumn extends AnimSpriteEffect;

#exec OBJ LOAD FILE=textures\SmokeCol.utx PACKAGE=UNREALSHARE.SmokeColm

defaultproperties
{
     NumFrames=16
     Pause=0.070000
     i=1
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'UnrealShare.SmokeColm.sc_a00'
     DrawScale=1.300000
     bMeshCurvy=False
     LightType=LT_None
     bCorona=False
}
