//=============================================================================
// dnJetPackFX_DirectBurn. 					June 9th, 2001 - Charlie Wiederhold
//=============================================================================
class dnJetPackFX_DirectBurn expands dnJetPackFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx

defaultproperties
{
	Enabled=False
	SpawnPeriod=0.050000
	RelativeLocation=True
	RelativeRotation=True
	InitialVelocity=(Z=32.000000)
	MaxVelocityVariance=(X=3.000000,Y=3.000000)
	UseZoneGravity=False
	UseZoneVelocity=False
	Textures(0)=Texture't_generic.Rain.genrain7RC'
	StartDrawScale=0.125000
	EndDrawScale=0.500000
	RotationVariance=65535.000000
	RotationVelocityMaxVariance=2.000000
	UpdateWhenNotVisible=True
	AlphaStart=0.000000
	AlphaMid=1.000000
	AlphaEnd=0.000000
	AlphaRampMid=0.750000
	bUseAlphaRamp=True
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	Style=STY_Translucent
	bUnlit=True
	TurnedOnSound=sound'a_transport.JetpackMove'
	TurnedOnPitchVariance=0.5
}
