//=============================================================================
// dnDebris_Smoke_Small1. 			  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Smoke_Small1 expands dnDebris_Smoke;

// Small puff of white smoke.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     InitialVelocity=(Z=12.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     DrawScaleVariance=0.125000
     StartDrawScale=0.250000
     EndDrawScale=0.625000
}
