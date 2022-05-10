//=============================================================================
// dnSandwormFX_Moving_Dust. 			  April 12th, 2001 - Charlie Wiederhold
//=============================================================================
class dnSandwormFX_Moving_Dust expands dnSandwormFX;

// Dust flying up as the sandworm moves around

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=0.750000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000)
     Textures(0)=Texture't_generic.dirtcloud.dirtcloud1aRC'
     Textures(1)=Texture't_generic.dirtcloud.dirtcloud1cRC'
     EndDrawScale=3.000000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=4.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
