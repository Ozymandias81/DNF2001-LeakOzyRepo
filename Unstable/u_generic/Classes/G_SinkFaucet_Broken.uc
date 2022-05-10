//=============================================================================
// G_SinkFaucet_Broken.				  September 26th, 2000 - Charlie Wiederhold
//=============================================================================
class G_SinkFaucet_Broken expands G_SinkFaucet;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(X=-2.000000,Z=6.000000))
     DamageThreshold=0
     FragType(0)=Class'dnParticles.dnLeaves'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     bSequenceToggle=False
     ToggleOnSequences(0)=(PlaySequence=None)
     ToggleOnSequences(1)=(PlaySequence=None,loop=False)
     ToggleOffSequences(0)=(PlaySequence=None)
     ToggleOffSequences(1)=(PlaySequence=None,loop=False)
     HealthPrefab=HEALTH_NeverBreak
     bSetFragSkin=False
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Faucet"
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     MultiSkins(2)=Texture'm_generic.burntbigskinRC'
     MultiSkins(3)=Texture'm_generic.burntbigskinRC'
}
