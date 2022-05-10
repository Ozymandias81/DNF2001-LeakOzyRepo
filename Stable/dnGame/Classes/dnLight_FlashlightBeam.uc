//=============================================================================
// dnLight_FlashlightBeam.
//=============================================================================
class dnLight_FlashlightBeam expands dnLight;

defaultproperties
{
     bStatic=False
     bNoDelete=False
     bMovable=True
     Physics=PHYS_MovingBrush
     bDirectional=True
     AffectMeshes=False
     LightEffect=LE_Spotlight
     LightBrightness=175
     LightHue=20
     LightSaturation=192
     LightRadius=56
     LightCone=48
     DestroyOnDismount=True
}
