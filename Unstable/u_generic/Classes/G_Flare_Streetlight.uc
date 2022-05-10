//=============================================================================
// G_Flare_Streetlight.	ab
//=============================================================================
class G_Flare_Streetlight expands FlareLight;

#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
    LensFlares(0)=(FlareTexture=Texture't_generic.LensFlares.lensflare1RC',Offset=0.100000,Scale=1.000000,OriginScale=2.000000,InnerRadiusScale=2.000000,OuterRadiusScale=1.800000)
    LensFlares(1)=(FlareTexture=Texture't_generic.LensFlares.lensflare1RC',Offset=0.100000,Scale=1.000000,RotationFactor=0.100000,OriginScale=2.000000,InnerRadiusScale=1.000000)
    AffectMeshes=False
    LightBrightness=0
    LightHue=0
    LightRadius=0
}
