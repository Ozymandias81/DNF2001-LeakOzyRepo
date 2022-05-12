//=============================================================================
// redeemertrail.
//=============================================================================
class RedeemerTrail extends Effects;

#exec MESH IMPORT MESH=muzzRFF3 ANIVFILE=MODELS\muzzle2_a.3d DATAFILE=MODELS\muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzRFF3 MINVERTS=12 STRENGTH=0.7 ZDISP=800.0
#exec MESH ORIGIN MESH=muzzRFF3 X=0 Y=740 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=muzzRFF3 SEQ=All                      STARTFRAME=0 NUMFRAMES=3
#exec MESHMAP NEW   MESHMAP=muzzRFF3 MESH=muzzRFF3
#exec MESHMAP SCALE MESHMAP=muzzRFF3 X=0.04 Y=0.16 Z=0.08
#exec TEXTURE IMPORT NAME=MuzzyFlak FILE=MODELS\flakflash2.PCX GROUP=Skins

simulated function PreBeginPlay()
{
	loopanim('all',2.0);
}

defaultproperties
{
	 RemoteRole=ROLE_None
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     LifeSpan=35.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Sprite=Texture'Botpack.Skins.MuzzyFlak'
     Texture=Texture'Botpack.Skins.MuzzyFlak'
     Skin=Texture'Botpack.Skins.MuzzyFlak'
     Mesh=LodMesh'Botpack.muzzRFF3'
     DrawScale=0.60000
     ScaleGlow=0.700000
     bUnlit=True
     bParticles=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=30
     LightSaturation=0
     LightRadius=8
     Mass=30.000000
}
