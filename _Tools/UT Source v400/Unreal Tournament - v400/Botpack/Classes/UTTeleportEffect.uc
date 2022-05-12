//=============================================================================
// UTTeleportEffect.
//=============================================================================
class UTTeleportEffect extends PawnTeleportEffect;

#exec MESH IMPORT MESH=UTTeleEffect ANIVFILE=MODELS\tele2_a.3D DATAFILE=MODELS\tele2_d.3D
#exec MESH ORIGIN MESH=UTTeleEffect X=0 Y=0 Z=-200 YAW=64
#exec MESH SEQUENCE MESH=UTTeleEffect SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=UTTeleEffect  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=UTTeleEffect X=0.06 Y=0.06 Z=0.16
 
#exec OBJ LOAD FILE=textures\FlareFX.utx PACKAGE=Botpack.FlareFX

var bool bSpawnEffects;
var UTTeleEffect T1, T2;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		local rotator newrot;

		if ( !Level.bHighDetailMode )
		{
			bOwnerNoSee = true;
			Disable('Tick');
			return;
		}

		if ( Level.NetMode == NM_DedicatedServer )
		{
			Disable('Tick');
			return;
		}

		ScaleGlow = (Lifespan/Default.Lifespan);	
		LightBrightness = ScaleGlow*210.0;

		if ( !Level.bHighDetailMode )
		{
			LightRadius = 6;
			return;
		}

		if ( !bSpawnEffects )
		{
			bSpawnEffects = true;
			T1 = spawn(class'UTTeleeffect');
			newrot = Rotation;
			newRot.Yaw = Rand(65535);
			T2 = spawn(class'UTTeleeffect',,,location - vect(0,0,10), newRot);
		}
		else
		{
			if ( T1 != None )
				T1.ScaleGlow = ScaleGlow;
			if ( T2 != None )
				T2.ScaleGlow = ScaleGlow;
		}
	}
}

defaultproperties
{
	bUnlit=true
	bRandomFrame=true
    Texture=Texture'Botpack.FlareFX.UTFlare1'
	MultiSkins(0)=Texture'Botpack.FlareFX.UTFlare1'
	MultiSkins(1)=Texture'Botpack.FlareFX.UTFlare2'
	MultiSkins(2)=Texture'Botpack.FlareFX.UTFlare3'
	MultiSkins(3)=Texture'Botpack.FlareFX.UTFlare4'
	MultiSkins(4)=Texture'Botpack.FlareFX.UTFlare5'
	MultiSkins(5)=Texture'Botpack.FlareFX.UTFlare6'
	MultiSkins(6)=Texture'Botpack.FlareFX.UTFlare7'
	MultiSkins(7)=Texture'Botpack.FlareFX.UTFlare8'
	LightRadius=9
}
