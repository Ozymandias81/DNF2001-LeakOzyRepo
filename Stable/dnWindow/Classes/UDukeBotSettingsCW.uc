class UDukeBotSettingsCW expands UDukePageWindow;

var UDukeCreateMultiCW  myParent;

function Created()
{
    Super.Created();

    myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );

	if ( myParent == None )
    {
		Log( "Error: UDukeBotSettingsCW without UDukeCreateMultiCW parent." );
    }
}

function BeforePaint( Canvas C, float X, float Y )
{
    Super.BeforePaint( C, X, Y );
}

function Notify( UWindowDialogControl C, byte E )
{
    Super.Notify( C, E );
}

defaultproperties
{
    bBuildDefaultButtons=false
    bNoScanLines=true
    bNoClientTexture=true
}