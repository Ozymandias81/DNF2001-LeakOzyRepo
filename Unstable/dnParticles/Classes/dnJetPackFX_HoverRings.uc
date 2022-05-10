//=============================================================================
// dnJetPackFX_HoverRings. 					June 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnJetPackFX_HoverRings expands dnJetPackFX;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\afbproship.dtx
#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnJetPackFX_HoverHaze',TakeParentTag=True,Mount=True)
     AdditionalSpawn(1)=(AppendToTag=Hover)
     Lifetime=0.500000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=32.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'afbproship.WMD.attack_2tw'
     StartDrawScale=0.125000
     EndDrawScale=0.012500
     RotationInitial3d=(Pitch=16384)
     UpdateWhenNotVisible=True
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=Texture'afbproship.WMD.attack_2atw'
     Mesh=DukeMesh'c_zone1_vegas.slsignon'
     bUnlit=True
}
