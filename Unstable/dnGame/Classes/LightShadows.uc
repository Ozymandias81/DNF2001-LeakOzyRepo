class LightShadows extends Light;

#exec OBJ LOAD FILE=..\Textures\dukeED_gfx.dtx

DefaultProperties
{
     AffectMeshes=true
     bActorShadows=true
     bAffectWorld=false
     Texture=texture'shadow_light'
}
