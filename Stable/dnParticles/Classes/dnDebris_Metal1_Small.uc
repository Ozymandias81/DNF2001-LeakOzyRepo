//=============================================================================
// dnDebris_Metal1_Small.			  September 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Metal1_Small expands dnDebris_Metal1;

// Subpiece of the metal debris spawner. Good chunk of metal.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=384.000000,Y=384.000000,Z=192.000000)
     StartDrawScale=0.100000
     EndDrawScale=0.100000
}
