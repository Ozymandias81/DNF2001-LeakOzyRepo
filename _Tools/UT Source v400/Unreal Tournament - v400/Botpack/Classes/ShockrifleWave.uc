//=============================================================================
// ShockrifleWave.
//=============================================================================
class ShockrifleWave extends Effects;

#exec MESH IMPORT MESH=ShockRWM ANIVFILE=MODELS\SW_a.3D DATAFILE=MODELS\SW_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=ShockRWM X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=ShockRWM SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockRWM SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockRWM SEQ=Implode   STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=ShocktT1 FILE=MODELS\shockw2.PCX  GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShockRWM X=1.0 Y=1.0 Z=2.0 
#exec MESHMAP SETTEXTURE MESHMAP=ShockRWM NUM=1 TEXTURE=ShocktT1

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if ( !Level.bHighDetailMode || Level.bDropDetail )
		LightType = LT_None;
}

simulated function Tick( float DeltaTime )
{
	local float ShockSize;

	ShockSize = 0.7/(ScaleGlow+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.300000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.ShockRWM'
     AmbientGlow=255
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=195
     LightSaturation=0
     LightRadius=6
}