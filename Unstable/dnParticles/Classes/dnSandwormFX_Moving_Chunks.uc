//=============================================================================
// dnSandwormFX_Moving_Chunks. 			  April 12th, 2001 - Charlie Wiederhold
//=============================================================================
class dnSandwormFX_Moving_Chunks expands dnSandwormFX;

// Dirt chunks flying up as the sandworm moves around

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=8
     Lifetime=0.750000
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000)
     Textures(0)=Texture't_generic.dirtparticle.dirtparticle2aR'
     Textures(1)=Texture't_generic.dirtparticle.dirtparticle2bR'
     DrawScaleVariance=0.250000
     StartDrawScale=0.325000
     EndDrawScale=0.325000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=8.000000
     UpdateWhenNotVisible=True
     Style=STY_Masked
}
