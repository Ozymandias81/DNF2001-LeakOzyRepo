//=============================================================================
// dnDroneJet_EngineFire.          Created by Charlie Wiederhold April 16, 2000
//=============================================================================
class dnDroneJet_EngineFire expands dnVehicles;

// Engine Fire Class for default sized Drone Jets

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx

defaultproperties
{
     IdleAnimations(0)=jetfire_big
     LodMode=LOD_Disabled
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Style=STY_Translucent
     Mesh=DukeMesh'c_FX.fire_jet'
     bUnlit=True
     DrawScale=3.000000
     ScaleGlow=8.000000
}
