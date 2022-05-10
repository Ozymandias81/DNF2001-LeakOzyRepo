//=============================================================================
// dnElectricalBlast_A.
//=============================================================================
class dnElectricalBlast_A expands dnRocket;

defaultproperties
{
     TrailClass=Class'dnParticles.dnElectricalTrail_Sparks'
     AdditionalMountedActors(0)=(ActorClass=None)
     speed=500.000000
     MaxSpeed=900.000000
     Damage=20.000000
     MomentumTransfer=10000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Sprite=FireTexture'm_dnWeapon.ElectricalProj1_MW'
     Texture=FireTexture'm_dnWeapon.ElectricalProj1_MW'
     Skin=FireTexture'm_dnWeapon.ElectricalProj1_MW'
     Mesh=None
     DrawScale=0.600000
     LightEffect=LE_Shock
     LightHue=148
     LightSaturation=235
     AmbientSound=Sound'a_edf.Robot.EDFRobotEZapLp3'
}
