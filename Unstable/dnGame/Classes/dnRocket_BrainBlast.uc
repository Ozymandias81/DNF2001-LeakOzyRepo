//=============================================================================
// dnRocket_BrainBlast. 				  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocket_BrainBlast expands dnRocket;

#exec OBJ LOAD FILE=..\Meshes\c_fx.dmx
#exec OBJ LOAD FILE=..\sounds\D3DSounds.dfx

function PostBeginPlay()
{
	PlayAnim('FireStart');
	Super.PostBeginPlay();
}

function AnimEnd()
{
	LoopAnim('FireLoop');
}

defaultproperties
{
     TrailClass=None
     AdditionalMountedActors(0)=(ActorClass=Class'dnParticles.dnBrainBlastFX_CenterGlow',MountOrigin=(Z=0.000000),MountAngles=(Yaw=0))
     ExplosionClass=Class'dnParticles.dnBrainBlastFX_ImpactSpawnerA'
     speed=600.000000
     MaxSpeed=900.000000
     MomentumTransfer=20000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     Mesh=DukeMesh'c_FX.BrainBlast'
     LightType=LT_StringLight
     LightEffect=LE_Disco
     LightBrightness=229
     LightHue=69
     LightSaturation=81
     LightRadius=4
     LightPeriod=16
     LightCone=128
     VolumeBrightness=64
     LightStringLoop=True
     LightStringRed=ettehnteet
     LightStringGreen=vvvvvvvvvv
     LightStringBlue=teetnhette
     AmbientSound=Sound'D3DSounds.Creatures.OctaIntro02'
}
