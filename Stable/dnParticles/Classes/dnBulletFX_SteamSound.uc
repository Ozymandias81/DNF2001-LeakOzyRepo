//=============================================================================
// dnBulletFX_SteamSound. 			 January 5th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBulletFX_SteamSound expands dnBulletFX_PipeSteamSpawner;

#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     CreationSounds(0)=Sound'a_generic.SteamPipe.SteamLeak04a'
     CreationSounds(1)=Sound'a_generic.SteamPipe.SteamLeak12a'
     CreationSounds(2)=Sound'a_generic.SteamPipe.SteamLeak13a'
     Lifetime=4.000000
}
