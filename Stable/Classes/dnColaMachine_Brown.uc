//=============================================================================
// dnColaMachine_Brown.				   November 26th, 2000 - Charlie Wiederhold
//=============================================================================
class dnColaMachine_Brown expands dnIce;

// Stream of coke from the coke machine

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     TurnedOnSound=Sound'a_generic.SodaFountain.SodaFtnRun'
     TurnedOnSoundRadius=384.000000
     MaximumParticles=8
     Lifetime=0.750000
     InitialVelocity=(Z=-16.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=1.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.liquids.genliquidbrn1RC'
     Textures(1)=Texture't_generic.liquids.genliquidbrn2RC'
     Textures(2)=Texture't_generic.liquids.genliquidbrn3RC'
     DrawScaleVariance=0.020000
     StartDrawScale=0.060000
     EndDrawScale=0.060000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=2.500000
     Style=STY_Translucent
     DrawScale=0.125000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
