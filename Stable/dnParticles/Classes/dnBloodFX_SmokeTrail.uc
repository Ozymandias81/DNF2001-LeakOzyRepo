//=============================================================================
// dnBloodFX_SmokeTrail. 				   March 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_SmokeTrail expands dnBloodFX_BloodTrail;

// Trail of smoke that flies off of metal gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFireEffect_RobotGibFire',Mount=True)
     Textures(0)=Texture't_generic.Smoke.gensmoke4dRC'
     AlphaStart=1.000000
     AlphaEnd=1.000000
     SystemAlphaScaleVelocity=0.000000
     Style=STY_Modulated
}
