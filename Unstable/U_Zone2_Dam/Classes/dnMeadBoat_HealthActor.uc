//=============================================================================
// dnMeadBoat_HealthActor. 				October 13th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMeadBoat_HealthActor expands dnMeadBoat;

defaultproperties
{
     FragType(0)=None
     DamageOnTrigger=5
     DestroyedEvent=GameOverMan_GameOver
     SpawnOnHit=None
     bSetFragSkin=False
     LodMode=LOD_Full
     Health=100
     WaterSplashClass=None
     DrawType=DT_Sprite
     Texture=Texture'hud_effects.ingame_hud.am_deserteagle'
     Mesh=None
}
