//=============================================================================
// EnhancedRespawn.
//=============================================================================
class EnhancedRespawn expands Effects;

#exec AUDIO IMPORT FILE="Sounds\Pickups\item-respawn2.WAV" NAME="RespawnSound2" GROUP="Generic"

#exec MESH IMPORT MESH=TeleEffect2 ANIVFILE=MODELS\telepo_a.3D DATAFILE=MODELS\telepo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TeleEffect2 X=0 Y=0 Z=-200 YAW=0
#exec MESH SEQUENCE MESH=TeleEffect2 SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=TeleEffect2  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=TeleEffect2 X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=TeleEffect2 NUM=0 TEXTURE=DefaultTexture

simulated function BeginPlay()
{
	Super.BeginPlay();
	Playsound(EffectSound1);
	PlayAnim('All',0.8);
}

simulated function PostBeginPlay()
{
	local inventory Inv;

	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
	Playsound(EffectSound1);
	if ( Owner != None )
	{
		Inv = Inventory(Owner);
 		if ( Inv != None )
		{
			if ( Inv.PickupViewScale == 1.0 )
				Mesh = Inv.PickUpViewMesh;
			else
				Mesh = Owner.Mesh;
			if ( Inv.RespawnTime < 15 )
				LifeSpan = 0.5;
		}
		else
			Mesh = Owner.Mesh;
		Animframe = Owner.Animframe;
		Animsequence = Owner.Animsequence;
	}
}

auto state Explode
{
	simulated function Tick( float DeltaTime )
	{
		if ( Owner != None )
		{
			if ( Owner.LatentFloat > 1 ) //got picked up and put back to sleep
			{
				Destroy();
				Return;
			} 
			SetRotation(Owner.Rotation);
		}
		if ( Level.bDropDetail )
			LifeSpan -= DeltaTime;
		ScaleGlow = (Lifespan/Default.Lifespan);	
		LightBrightness = ScaleGlow*210.0;
		DrawScale = 0.03 + 0.77 * ScaleGlow;
	}

	simulated function AnimEnd()
	{
		RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
	 AnimSequence=All
	 bMeshEnviromap=true
	 bParticles=true
	 AmbientGlow=255
	 EffectSound1=RespawnSound2
     RemoteRole=ROLE_SimulatedProxy
	 Physics=PHYS_None
     LifeSpan=1.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=Texture'UnrealShare.DBEffect.de_A00'
     Texture=Texture'UnrealShare.DBEffect.de_A00'
     Mesh=Mesh'UnrealShare.TeleEffect2'
     DrawScale=1.10000
     bUnlit=True
	 bNetOptional=true
	 bNetTemporary=true
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=210
     LightHue=30
     LightSaturation=224
     LightRadius=6
}
