//=============================================================================
// dnDebris_Cement1_Small.				November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Cement1_Small expands dnDebris_Cement1;

// Root of the cement debris spawners. Small chunks of white concrete stuff.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Lifetime=1.000000
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=384.000000,Y=384.000000,Z=192.000000)
     StartDrawScale=0.100000
     EndDrawScale=0.100000
}
