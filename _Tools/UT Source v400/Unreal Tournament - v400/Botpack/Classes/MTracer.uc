//=============================================================================
// MTracer.
//=============================================================================
class MTracer extends Projectile;

#exec MESH IMPORT MESH=MiniTrace ANIVFILE=MODELS\UT_Tracer_a.3d DATAFILE=MODELS\UT_Tracer_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniTrace X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=MiniTrace SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MiniTrace SEQ=UT_Tracer                STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP SCALE MESHMAP=MiniTrace X=0.3 Y=0.1 Z=0.2
#exec TEXTURE IMPORT NAME=JUT_Tracer_01 FILE=Models\UT_Tracer_01.PCX GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=MiniTrace NUM=1 TEXTURE=JUT_Tracer_01

simulated function PostBeginPlay()
{
	//log("Spawn"@self@"with role"@Role@"and netmode"@Level.netmode);
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
	if ( Level.bDropDetail )
		LightType = LT_None;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( Other!=Instigator )
		Destroy();
}

defaultproperties
{
     Damage=0.000000
     MomentumTransfer=0
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Effect1.FireEffect1u'
     Mesh=Mesh'Botpack.MiniTrace'
     DrawScale=0.800000
     AmbientGlow=187
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=30
     LightSaturation=69
     LightRadius=3
     bReplicateInstigator=false
	 speed=+4000.0
	 MaxSpeed=+4000.0
}
