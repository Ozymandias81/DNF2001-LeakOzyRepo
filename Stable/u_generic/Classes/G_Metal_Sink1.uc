//=============================================================================
// G_Metal_Sink1.
//==================================Created Feb 24th, 1999 - Stephen Cole
class G_Metal_Sink1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     bTakeMomentum=False
     HealthPrefab=HEALTH_NeverBreak
     Mesh=DukeMesh'c_generic.metalsink1'
     ItemName="Metal Sink"
     bNotTargetable=True
     CollisionRadius=42.000000
     CollisionHeight=8.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
}
