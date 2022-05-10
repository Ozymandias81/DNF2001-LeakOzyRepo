//=============================================================================
// The light class.
//=============================================================================
class Light extends InfoActor
	native;

#exec Texture Import File=Textures\S_Light.pcx  Name=S_Light Mips=Off Flags=2

var(Lighting) bool		bAffectWorld;
var(Lighting) float		ProjectorNear;
var(Lighting) float		ProjectorFar;
var(Lighting) float		ProjectorFadeScale;

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=S_Light
     CollisionRadius=+00024.000000
     CollisionHeight=+00024.000000
     LightType=LT_Steady
     LightBrightness=64
     LightSaturation=255
     LightRadius=64
     LightPeriod=32
     LightCone=128
     VolumeBrightness=64
     VolumeRadius=0
	 bMovable=False

	 bAffectWorld=true
	 //ProjectorNear=150.0f
	 //ProjectorFar=850.0f
	 //ProjectorFadeScale=1.0f
	 ProjectorNear=110.0f
	 ProjectorFar=390.0f
	 ProjectorFadeScale=0.85f			// Post z-space compression
}
