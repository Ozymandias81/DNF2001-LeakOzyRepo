//=============================================================================
// G_Toilet_Broken.					  September 26th, 2000 - Charlie Wiederhold
//=============================================================================
class G_Toilet_Broken expands G_Toilet;

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
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True)
     DamageThreshold=0
     FragType(0)=Class'dnParticles.dnLeaves'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(5)=None
	 bUseTriggered=false
     TriggeredSequence=0
     TriggeredSound=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     PendingSequences(0)=(PlaySequence=None)
     CurrentPendingSequence=-1
     HealthPrefab=HEALTH_NeverBreak
     bSetFragSkin=False
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Toilet"
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     MultiSkins(2)=Texture'm_generic.burntbigskinRC'
     MultiSkins(3)=Texture'm_generic.burntbigskinRC'
}
