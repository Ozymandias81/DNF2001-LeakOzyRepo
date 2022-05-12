//=============================================================================
// Electricity.
//=============================================================================
class Electricity extends Effects;

#exec MESH IMPORT MESH=Electr ANIVFILE=MODELS\Electr_a.3D DATAFILE=MODELS\Electr_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Electr X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=Electr SEQ=All        STARTFRAME=0   NUMFRAMES=11
#exec MESH SEQUENCE MESH=Electr SEQ=ElectBurst STARTFRAME=0   NUMFRAMES=11
#exec OBJ LOAD FILE=Textures\fireeffect7.utx PACKAGE=UnrealShare.Effect7
#exec MESHMAP SCALE MESHMAP=Electr X=0.15 Y=0.15 Z=0.3 YAW=128 
#exec MESHMAP SETTEXTURE MESHMAP=Electr NUM=1 TEXTURE=UnrealShare.Effect7.MyTex16

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'ElectBurst', 0.6 );
		PlaySound (EffectSound1);	
	}	
}

simulated function AnimEnd()
{
	Destroy ();
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=UnrealShare.Electr
     bUnlit=True
     Physics=PHYS_None
     RemoteRole=ROLE_SimulatedProxy
	 LifeSpan=+2.0
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=200
     LightSaturation=255
     LightRadius=3
}
