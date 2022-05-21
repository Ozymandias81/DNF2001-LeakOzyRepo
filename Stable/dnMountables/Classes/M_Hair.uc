/*-----------------------------------------------------------------------------
	M_Hair
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M_Hair extends MountableDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
    MountType=MOUNT_MeshSurface
    MountMeshItem=hair
    Mesh=DukeMesh'c_characters.hair_long1'
    bShadowCast=False
}

/*
DNF2001 Hair Fix by Raziel
--------------------------
This is a community created patch that attempts to fix the hair clipping and visibility issues in the Duke Nukem Forever 2001 build.

While it should fix the visibility of hair on most characters, hair rendering was clearly a feature under heavy development and a number of rendering issues remain with this patch applied:
 * Hair polygons are not properly sorted back-to-front which causes artefacts within the hair when viewed from certain angles.
 * When multiple characters appear on screen that use the game's hair rendering code, the hair geometry itself often glitches out on the characters.
 * There are some noticeable lighting glitches affecting the E3 girl's hair in Slick Willy, I don't think this is a bug in the rendering code, more likely an issue caused by poor light placement in that level. This issue is actually fixed in the E3 variant of that level (the version with Gus in it): !z1l4_2-retex.dnf

Also note that the patch doesn't fix every single character in the game. Unreal Engine is an extremely flexible engine and it's possible to add any random actor to a level, change it's mesh to a hair mesh, then attach it to a character. So in practice, there's a lot of ways to add hair to a character and this patch doesn't address those edge cases. It will only apply the fix if the hair was created as an M_Hair actor or one of its subclasses like M_HairPhysics. If anyone wants to go through the levels and fix the hair of additional characters, simply switch out their current hair mesh actor with one derived from M_Hair.

The patch isn't perfect, but it's a big improvement over the unpatched version and hair should at least be visible for most characters with some minor graphical glitches.
*/

function PostBeginPlay()
{
	Super.PostBeginPlay();
	FixHairRendering();
}

function FixHairRendering()
{
	// Alpha blending settings
    Style=STY_Translucent;
	SrcBlend=BLEND_SRCALPHA;
	DstBlend=BLEND_INVSRCALPHA;
	Alpha=1.0;
	
	// Render settings
	bUseViewPortForZ=False;
	LodMode=LOD_Disabled;
	LODBias=0.0;
	
	// Lighting settings
	MaxDesiredActorLights=5;
	bShadowReceive=True;
	bShadowCast=False;
}