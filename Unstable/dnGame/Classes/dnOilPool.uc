/*-----------------------------------------------------------------------------
	dnOilPool
-----------------------------------------------------------------------------*/
class dnOilPool extends dnBloodPool;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
	Decals(0)=Texture't_generic.GenOilSpill1'
	BloodSpread=10.0
    Behavior=DB_Normal
    MinSpawnDistance=2.0
    DrawScale=0.01
	LifeSpan=120.0
}
