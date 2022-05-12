//=============================================================================
// TranslocOutEffect.
//=============================================================================
class TranslocOutEffect extends Effects;

#exec TEXTURE IMPORT NAME=TPEffect FILE=MODELS\Teleport.PCX GROUP="Skins"

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
}

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if ( (Level.NetMode == NM_DedicatedServer) || !Level.bHighDetailMode )
		{
			Disable('Tick');
			return;
		}
		ScaleGlow = Lifespan;
		DrawScale = 0.1 + 0.2 * (Scaleglow);	
		LightBrightness = (ScaleGlow) * 210.0;
		if ( LifeSpan < 0.3 )
			SetPhysics(PHYS_Projectile);
	}
}

defaultproperties
{
	 Physics==PHYS_None
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
     AnimSequence=All
     DrawType=DT_Mesh
     Style=STY_Translucent
	 bMeshEnviromap=true
     DrawScale=0.600000
     bParticles=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=96
     LightRadius=6
     Texture=Texture'Botpack.TPEffect'
}
