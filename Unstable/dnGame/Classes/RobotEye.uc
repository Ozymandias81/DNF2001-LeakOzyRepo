/*-----------------------------------------------------------------------------
	RobotEye
	Author: Jess Crable
-----------------------------------------------------------------------------*/
class RobotEye expands Effects;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

function Tick( float DeltaTime )
{
	if ( ScaleGlow < 1.0 )
		ScaleGlow += 0.01;
	else if ( ScaleGlow >= 1.0 )
		Disable( 'Tick' );
}

defaultproperties
{
    DrawType=DT_Sprite;
	Texture=Texture't_generic.keypad.genkeylightred1';
	Style=STY_Translucent
	LodMode=LOD_Disabled
	CollisionRadius=0
	CollisionHeight=0
    DrawScale=0.25
	ScaleGlow=0.0
}
