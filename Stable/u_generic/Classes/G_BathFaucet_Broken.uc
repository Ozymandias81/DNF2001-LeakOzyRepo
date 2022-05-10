//=============================================================================
// G_BathFaucet_Broken.				  September 26th, 2000 - Charlie Wiederhold
//=============================================================================
class G_BathFaucet_Broken expands G_BathFaucet;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(Y=8.000000,Z=-12.000000))
     HealOnTrigger=1
     SpawnOnDestroyed(0)=(SpawnClass=None)
     bSequenceToggle=False
     ToggleOnSequences(0)=(PlaySequence=None)
     ToggleOnSequences(1)=(PlaySequence=None)
     ToggleOffSequences(0)=(PlaySequence=None)
     ToggleOffSequences(1)=(PlaySequence=None)
     HealthPrefab=HEALTH_NeverBreak
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Faucet"
}
