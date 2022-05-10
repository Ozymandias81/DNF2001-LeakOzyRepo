//=============================================================================
// dnWaterFX.	Keith Schuler	Sept 29, 2000
//=============================================================================
class dnWaterFX expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

defaultproperties
{
     Enabled=False
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=40.000000
     CollisionHeight=1.000000
}
