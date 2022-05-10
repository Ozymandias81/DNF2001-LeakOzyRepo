/*-----------------------------------------------------------------------------
	RobotMasterChunk
-----------------------------------------------------------------------------*/
class RobotMasterChunk extends MasterCreatureChunk;

#exec OBJ LOAD File=..\Meshes\c_FX.dmx

DefaultProperties
{
	//     DrawScale=0.150000
	bSteelSkin=true
	TrailClass=class'dnParticles.dnBloodFX_SmokeTrail'
	Mesh=DukeMesh'c_FX.Gib_Heavyweptorso'
	bloodSplatClass=class'dngame.dnOilSplat'
}
