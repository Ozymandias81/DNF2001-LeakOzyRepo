class dnRespawnMarker expands RespawnMarker;

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\Textures\m_generic.dtx

var Texture StartSkin, MediumSkin, EndSkin;

function StateChanged()
{
	switch ( MyState )
	{
	case 0:
		Texture				= StartSkin;
		RotationRate		= Default.RotationRate;
		break;
	case 1:
		Texture				= MediumSkin;
		RotationRate.Yaw	*= 1.5;
		break;
	case 2:
		Texture				= EndSkin;
		RotationRate.Yaw	*= 1.5;
		break;
	default:
		break;
	}
}

defaultproperties
{
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=DukeMesh'c_fx.RespawnMarkerA'
	Texture=Texture'm_generic.balloonredRC'
	StartSkin=Texture'm_generic.balloonredRC'
	MediumSkin=Texture'm_generic.balloonyeloRC'
	EndSkin=Texture'm_generic.balloongreenRC'
	Physics=PHYS_MovingBrush
	RotationRate=(Yaw=24000)
	bFixedRotationDir=true
	CollisionHeight=1
	CollisionRadius=1
} 