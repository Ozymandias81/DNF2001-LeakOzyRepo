//=============================================================================
// dnCharacterFX_ProtonMonitor_JetB. 	  March 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_ProtonMonitor_JetB expands dnCharacterFX_ProtonMonitor_JetA;

// Jet for the Proton Monitor

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.100000
     MaximumParticles=65
     Lifetime=1.400000
     Apex=(Z=80.000000)
     StartDrawScale=0.550000
     EndDrawScale=0.360000
}
