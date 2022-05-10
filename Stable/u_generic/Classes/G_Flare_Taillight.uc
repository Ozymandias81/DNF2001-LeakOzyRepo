//=============================================================================
// G_Flare_Taillight.	ab
//=============================================================================
class G_Flare_Taillight expands FlareLight;

#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
 
    LensFlares(0)=(FlareTexture=Texture't_generic.LensFlares.flare3sah',Scale=1.000000,DistanceScaleFactor=0.400000,UseCone=True)
    LensFlares(1)=(FlareTexture=Texture't_generic.beameffects.beam11aRC',Scale=1.000000,DistanceScaleFactor=-0.500000,OriginScale=1.500000,InnerRadiusScale=1.500000,OuterRadiusScale=1.500000,UseCone=True)
    LensFlares(2)=(FlareTexture=Texture't_generic.LensFlares.flare3sah',Scale=1.000000,RotationFactor=1.000000,DistanceScaleFactor=1.000000,OriginScale=1.000000,InnerRadiusScale=1.000000,OuterRadiusScale=1.000000,UseCone=True)
    LensFlares(3)=(FlareTexture=Texture't_generic.LensFlares.flare3sah',Scale=1.000000,UseCone=True)
    LensFlares(4)=(Offset=1.200000,Scale=1.000000,RotationFactor=2.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(5)=(FlareTexture=Texture't_generic.LensFlares.lensflare5RC',Scale=1.000000,RotationFactor=4.000000,OriginScale=3.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(6)=(FlareTexture=Texture't_generic.LensFlares.lensflare6RC',Offset=1.400000,Scale=1.000000,RotationFactor=1.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(7)=(FlareTexture=Texture't_generic.LensFlares.lensflare7RC',Offset=1.500000,Scale=1.000000,RotationFactor=-1.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(8)=(FlareTexture=Texture't_generic.LensFlares.redlensflare1BC',Offset=1.600000,Scale=1.000000,RotationFactor=-0.200000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(9)=(FlareTexture=Texture't_generic.LensFlares.subtle_flare6BC',Offset=1.700000,Scale=1.000000,RotationFactor=-10.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    InnerRadius=19.000000
    bStatic=False
    bGameRelevant=True
    bDynamicLight=True
    bMovable=True
    Physics=PHYS_MovingBrush
    bDirectional=True
    Skin=Texture't_generic.LensFlares.bluelensflare1B'
    AffectMeshes=False
    LightBrightness=0
    LightRadius=255
    LightCone=192

}
