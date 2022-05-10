//=============================================================================
// dnLight_FlashlightAmbient.
//=============================================================================
class dnLight_FlashlightAmbient expands dnLight;

#exec obj load file=..\meshes\c_zone3_canyon.dmx

defaultproperties
{
     bStatic=False
     bNoDelete=False
     bMovable=True
     Physics=PHYS_MovingBrush
     DrawScale=0.250000
     LightBrightness=24
     LightHue=20
     LightSaturation=192
     LightRadius=6
     LightCone=48
     DestroyOnDismount=True
}
