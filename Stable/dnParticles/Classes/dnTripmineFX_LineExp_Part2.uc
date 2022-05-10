//=============================================================================
// dnTripmineFX_LineExp_Part2.       Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_LineExp_Part2 expands dnTripmineFX_LineExp;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the line explosion effect, part 2!!!
// This does not spawn Natalie Portman or Britney Spears though. I tried.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     bIgnoreBList=True
     PrimeCount=8
     StartDrawScale=1.500000
     EndDrawScale=3.000000
     CollisionRadius=0.000000
}
