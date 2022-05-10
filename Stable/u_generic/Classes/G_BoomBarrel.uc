//=============================================================================
// G_BoomBarrel.                              October 20th, 2000 - Stephen Cole
//=============================================================================
class G_BoomBarrel expands G_Barrel;

// Decorative Explosive barrel. Uses dnBoomBarrel explosion class for high radius damage
// I don't get to use the word 'acuity' nearly enough.

#exec OBJ LOAD FILE=..\textures\airforcebase.dtx

defaultproperties
{
     DamageThreshold=1
     DamageFromImpactScaler=1.000000
     FragSkin=Texture'airforcebase.objects.cabflam1bRC'
     DamageOnTrigger=100
     DamageOnHitWall=100
     DamageOnHitWater=100
     DamageOnEMP=100
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnBoomBarrel')
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnDebrisMesh_BoomBarrel')
     HealthPrefab=HEALTH_Easy
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     MultiSkins(0)=Texture'm_generic.expbarrelBC'
     MultiSkins(1)=Texture'm_generic.expbarreltopBC'
}
