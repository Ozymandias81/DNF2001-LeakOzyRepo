//=============================================================================
// G_BoomBarrelToss.
//=============================================================================
class G_BoomBarrelToss expands G_BoomBarrel2;

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None,SetMountOrigin=False,SetMountAngles=False)
     DamageThreshold=2
     DamageFromImpactScaler=0.000000
     DamageToImpactScaler=0.000000
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(7)=None
     TriggerType=TT_Shoot
     DamageOnHitWall=0
     DamageOnHitWater=0
     DestroyedSound=Sound'a_impact.explosions.EXPL005'
     HitWallSound=Sound'a_impact.metal.ImpactMtl138'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnConcussion1_Damage')
     bTumble=True
     MassPrefab=MASS_Medium
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     AmbientSound=Sound'a_ambient.RoomTone.RoomToneLp09'
}
