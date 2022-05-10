//=============================================================================
// G_Urinal_Broken.
//=============================================================================
class G_Urinal_Broken expands G_Urinal;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

function PostBeginPlay()
{
	Super(Generic).PostBeginPlay();
}

function Trigger( actor Other, pawn EventInstigator )
{
	Super(Generic).Trigger( Other, EventInstigator );
}

function AnimEnd()
{
	Super(Generic).AnimEnd();
}

function Tick(float Delta)
{
	Super(Generic).Tick( Delta );
}

function Destroyed()
{
	Super(Generic).Destroyed();
}

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(X=4.000000,Z=18.000000))
     DamageThreshold=0
     FragType(0)=Class'dnParticles.dnLeaves'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(5)=None
     FragType(6)=None
     FragType(7)=None
     IdleAnimations(0)=None
	 bUseTriggered=false
     TriggerRetriggerDelay=0.000000
     TriggerMountToDecoration=False
     TriggeredSequence=None
     TriggeredSound=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     bSetFragSkin=False
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Urinal"
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     MultiSkins(2)=Texture'm_generic.burntbigskinRC'
     MultiSkins(3)=Texture'm_generic.burntbigskinRC'
}
