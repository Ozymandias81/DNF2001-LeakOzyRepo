//=============================================================================
// carFlash.
//=============================================================================
class CarFlash extends Effects;

simulated function PostBeginPlay()
{
	LoopAnim('Shoot', 0.7);
}
	
defaultproperties
{
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Botpack.Muzzy'
     Mesh=Mesh'Botpack.MuzzFlash3'
     DrawScale=0.10000
     bUnlit=True
     bParticles=True
     bMeshCurvy=False
     LightType=LT_None
     LightBrightness=255
     LightHue=39
     LightSaturation=204
     LightRadius=7
	 RemoteRole=ROLE_SimulatedProxy
	 bNetTemporary=false
	 AnimSequence=Shoot
}
