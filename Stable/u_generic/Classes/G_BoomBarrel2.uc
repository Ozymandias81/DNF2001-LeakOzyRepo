//=============================================================================
// G_BoomBarrel2.
//=============================================================================
class G_BoomBarrel2 expands G_BoomBarrel;

#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnGame.PowerPuzzle',SetMountOrigin=True,MountOrigin=(Z=21.000000),SetMountAngles=True,MountAngles=(Pitch=16384))
     SpawnOnDestroyed(1)=(SpawnClass=None)
     bTumble=False
     bLandForward=False
     bLandBackwards=False
     bLandLeft=False
     bLandRight=False
     bLandUpright=False
     bLandUpsideDown=False
     bPushable=False
     Grabbable=False
}
