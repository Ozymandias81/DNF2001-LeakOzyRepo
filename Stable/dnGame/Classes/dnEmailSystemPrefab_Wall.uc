/*-----------------------------------------------------------------------------
	dnEmailSystemPrefab_Wall
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnEmailSystemPrefab_Wall extends dnEmailSystem;

#exec OBJ LOAD FILE=..\Textures\smk8.dtx

defaultproperties
{
	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
    HealthPrefab=HEALTH_NeverBreak
	ItemName="ezMail Station"
	LodMode=LOD_Disabled
	Mesh=mesh'c_generic.ezmail_wall'
	MeshScreenIndex=1
	ScreenSurfaceIndex=-1
	SrcViewOffs=(X=0.0,Y=-15.0,Z=0.0)
	DstViewOffs=(X=0.0,Y=0.0,Z=0.0)
	ScreenCanvas=SmackerTexture'SMK8.emailsmack1KS'
	bPushable=false
	Grabbable=false
}