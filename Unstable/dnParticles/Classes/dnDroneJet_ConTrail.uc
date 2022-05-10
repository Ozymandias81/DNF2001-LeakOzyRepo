//=============================================================================
// dnDroneJet_ConTrail.                            Charlie Wiederhold 4/18/2000
//=============================================================================
class dnDroneJet_ConTrail expands dnMissileTrail;

// Con trail streamer for the wingtips of aircraft (Drone Jets)
// Does NOT do damage. 
// White and translucent for light backgrounds

defaultproperties
{
     Enabled=False
     Lifetime=3.000000
     InitialVelocity=(Y=256.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseLines=True
     Connected=True
     LineStartColor=(R=32,G=32,B=32)
     LineEndColor=(R=32,G=32,B=32)
     LineStartWidth=32.000000
     LineEndWidth=32.000000
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
