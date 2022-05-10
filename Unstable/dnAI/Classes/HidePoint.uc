class HidePoint expands Info;

function bool Clear()
{
	local Pawn P;

	foreach radiusactors( class'Pawn', P, 96 )
	{
		if( P != None )
			return false;
	}
	return true;
}

DefaultProperties
{
	bHidden=true

}
