//=============================================================================
// dnLight_ProtonMonitor. 				  March 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class dnLight_ProtonMonitor expands dnLight;

// Light that flickers near the beams on the Proton monitor

defaultproperties
{
     bStatic=False
     bHidden=False
     bNoDelete=False
     bMovable=True
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     Sprite=Texture'm_dnWeapon.weapon_efx.ShrinkHit1'
     Texture=Texture'm_dnWeapon.weapon_efx.ShrinkHit1'
     DrawScale=1.400000
     bUnlit=True
     LightType=LT_StringLight
     LightBrightness=229
     LightHue=69
     LightSaturation=81
     LightRadius=10
     LightPeriod=16
     LightStringLoop=True
     LightString=aapz
     DestroyOnDismount=True
}
