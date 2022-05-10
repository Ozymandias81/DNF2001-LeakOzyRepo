class dnMutatorList expands UWindowListBoxItem;

var string MutatorName;
var string MutatorClass;

function int Compare( UWindowList T, UWindowList B )
{
	if( Caps( dnMutatorList( T ).MutatorName ) < Caps( dnMutatorList( B ).MutatorName ) )
		return -1;

	return 1;
}

// Call only on sentinel
function dnMutatorList FindMutator( string FindMutatorClass )
{
	local dnMutatorList I;

	for( I = dnMutatorList( Next ); I != None; I = dnMutatorList( I.Next ) )
	{
		if( I.MutatorClass ~= FindMutatorClass )
		{
			return I;
		}
	}
	return None;
}