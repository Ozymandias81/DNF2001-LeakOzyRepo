//=============================================================================
// dnExplosion2_Spawner1.          Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnExplosion2_Spawner1 expands dnExplosion2;

// Explosion effect spawner.
// Does NOT do damage. 
// Uses dnExplosion2_Effect1, dnExplosion2_Effect2.
// Large explosion for fast moving object.
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     CreationSound=Sound'a_impact.explosions.Expl118'
     CreationSoundRadius=16384.000000
     StartDrawScale=40.000000
     bBurning=True
}
