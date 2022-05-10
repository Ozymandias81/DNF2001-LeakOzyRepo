//=============================================================================
// dnWeaponFX.                    Created by Charlie Wiederhold August 30, 2000
//=============================================================================
class dnWeaponFX expands dnDecoration;

// Subclass to store all weapon FX related decorations
// This is the fire cone hanging out the back of the rocket

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx

defaultproperties
{
     FragType(0)=None
     IdleAnimations(0)=jetfire_big
     Physics=PHYS_MovingBrush
     LodMode=LOD_Disabled
     Style=STY_Translucent
     Mesh=DukeMesh'c_FX.fire_jet'
     DrawScale=0.370000
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     DestroyOnDismount=True
}
