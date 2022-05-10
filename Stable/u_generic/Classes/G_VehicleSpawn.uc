//=============================================================================
// G_VehicleSpawn.
//=============================================================================
// AllenB


#exec OBJ LOAD FILE=..\Sounds\RocketFX.dfx

class G_VehicleSpawn expands Generic;

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'U_Generic.G_Flare_Headlight',SetMountOrigin=True)
     MountOnSpawn(1)=(ActorClass=Class'U_Generic.G_Flare_Headlight',SetMountOrigin=True)
     MountOnSpawn(2)=(ActorClass=Class'U_Generic.G_VehicleTaillight',SetMountOrigin=True)
     MountOnSpawn(3)=(ActorClass=Class'U_Generic.G_VehicleTaillight',SetMountOrigin=True)
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnCars_RainMist')
     FragType(0)=None
     NumberFragPieces=0
     TriggerType=TT_PlayerProximity
     TriggerMountToDecoration=False
     DamageOtherOnTouch=1000
     DamageOtherOnPlayerTouch=1000
     DestroyedSound=None
     TriggeredSound=Sound'a_dukevoice.Mirror.DukeMirror2'
     bTumble=False
     LodScale=0.500000
     LodOffset=1000.000000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     bTakeMomentum=False
     LifeSpan=15.000000
     CollisionRadius=96.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Physics=PHYS_Projectile
     bBounce=False
     SoundRadius=96
     AmbientSound=Sound'RocketFX.Looping.RocketLoop'
}
