//=============================================================================
// DnProjectileSpawn_MeadTorpedo1.		October 17th, 2000 - Charlie Wiederhold
//=============================================================================
class DnProjectileSpawn_MeadTorpedo1 expands TriggerDnProjectileSpawn;

// Torpedos that are mounted to the planes in the Lake Mead map.
// Very specific purpose since they target the boat the player is in.

defaultproperties
{
     TargetVariance=(X=128.000000,Y=128.000000)
     actorType=Class'dnGame.dnHomingTorpedo'
     ActorTag=SpawnedTorpedo
     AssignAcceleration=True
     TargetActorName=DukeNukemBoatOLove
}
