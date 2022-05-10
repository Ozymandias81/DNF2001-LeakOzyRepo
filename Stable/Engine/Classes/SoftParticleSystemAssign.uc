//=============================================================================
// SoftParticleSystemAssign. (NJS)
// Assigns values to particle systems designated by event.
//=============================================================================
class SoftParticleSystemAssign expands ParticleSystem;


var (WhatToAssign) bool AssignEnabled;
var ()			   bool Enabled;	// Whether particle spawning is enabled.

var (WhatToAssign) bool AssignGroupID;
var ()			   int  GroupID;	// ID of the group this particle system belongs to.

var (WhatToAssign) bool AssignSpawnNumber;
var ()			   int  SpawnNumber;
var ()			   name SpawnNumberVariable;
	
function Trigger( actor Other, Pawn Instigator )
{
	local SoftParticleSystem P;

	foreach allactors(class'SoftParticleSystem',P,Event)
	{
		if(AssignEnabled)   P.Enabled=Enabled;
		if(AssignGroupID)   P.GroupID=GroupID;
		if(AssignSpawnNumber)
		{
			if(SpawnNumberVariable!='') SpawnNumber=GetVariableValue(SpawnNumberVariable,SpawnNumber);
			P.SpawnNumber=SpawnNumber;
		}
	}
}

defaultproperties
{
	 
}
