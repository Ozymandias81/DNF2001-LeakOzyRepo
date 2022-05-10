//=============================================================================
// G_Flare_Headlight.	ab
//=============================================================================
class G_Flare_Headlight expands FlareLight;

#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
 
    LensFlares(0)=(FlareTexture=Texture't_generic.Glass.genglass3RC',Scale=1.000000,RotationFactor=1.000000,DistanceScaleFactor=0.500000,OriginScale=4.000000,InnerRadiusScale=2.000000,OuterRadiusScale=1.000000,UseCone=True)
    LensFlares(1)=(FlareTexture=Texture't_generic.LensFlares.corona1RC',Scale=1.000000,RotationFactor=1.000000,DistanceScaleFactor=-0.450000,UseCone=True)
    LensFlares(2)=(FlareTexture=Texture't_generic.LensFlares.bluelensflare1B',Scale=1.000000,RotationFactor=1.000000,DistanceScaleFactor=0.500000,OriginScale=2.000000,InnerRadiusScale=2.000000,OuterRadiusScale=1.000000,UseCone=True)
    LensFlares(3)=(FlareTexture=Texture't_generic.LensFlares.bluelensflare1B',Offset=0.100000,Scale=1.000000,RotationFactor=1.000000,DistanceScaleFactor=-0.400000,OriginScale=6.000000,InnerRadiusScale=2.000000,OuterRadiusScale=2.000000,UseCone=True)
    LensFlares(4)=(FlareTexture=Texture't_generic.LensFlares.lensflare10RC',Scale=1.000000,OriginScale=2.000000,InnerRadiusScale=2.000000,OuterRadiusScale=2.000000)
    LensFlares(5)=(Scale=1.000000,RotationFactor=4.000000,OriginScale=3.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(6)=(Offset=1.400000,Scale=1.000000,RotationFactor=1.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(7)=(Offset=1.500000,Scale=1.000000,RotationFactor=-1.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(8)=(Offset=1.600000,Scale=1.000000,RotationFactor=-0.200000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    LensFlares(9)=(Offset=1.700000,Scale=1.000000,RotationFactor=-10.000000,OriginScale=16.000000,InnerRadiusScale=4.000000,OuterRadiusScale=1.000000)
    InnerRadius=19.000000
    bStatic=False
    bGameRelevant=True
    bDynamicLight=True
    bMovable=True
    bDirectional=True
    Physics=PHYS_MovingBrush
    Skin=Texture't_generic.Glass.genglass3RC'
    AffectMeshes=False
    LightBrightness=0
    LightRadius=255
    LightCone=192

}
