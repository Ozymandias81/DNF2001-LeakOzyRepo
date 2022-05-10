//=============================================================================
// TriggerSpawn_JetskiGuy. October 18th, 2000 - Charlie Wiederhold
//=============================================================================
class TriggerSpawn_JetskiGuy expands TriggerSpawn;

// Jetsky guys that are spawned inside drop ships.
// Very specific purpose.

defaultproperties
{
     actorType=Class'dnAI.AIJetski'
     ActorTag=Spawned_JetskiGuy
     newPhysics=PHYS_Falling
     AssignVelocity=True
     NewVelocity=(Y=448.000000)
}
