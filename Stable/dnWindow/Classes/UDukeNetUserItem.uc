//=============================================================================
// 
// FILE:			UDukeNetUserItem.uc
// 
// DESCRIPTION:		Item for UserListBox
// 
//==========================================================================
class UDukeNetUserItem expands UWindowListBoxItem;

var     string      strName;
var()   color       colorIdentifier;
var()   color       colorData;

function int Compare( UWindowList T, UWindowList B )
{
	local string strT, strB;

	strT = Caps( UDukeNetUserItem( T ).strName );
	strB = Caps( UDukeNetUserItem( B ).strName ); 

	if ( strT == strB )
		return 0;

	if ( strT < strB )
		return -1;

	return 1;
}

function SetUsersColor( INT iColorKey )
{
	local float     fHue;
	local float     fSat;
	local float     f, m, n;
	local Vector    vecHSV;
	local INT       i;
	local float     v;

	v = 1.0f;	//always 100% lumin?

	//convert iColorKey to HSV, then cycle through Hues evenly, 
	//	(this assumes that after 12 user color groups, and 10 saturation
	//	 levels of each of these color groups, nobody will notice the difference anyway)

	/* Hue is divided among six main colors around a wheel,
	
	 Red       0
     Yellow   60
     Green   120
     Cyan    180
     Blue    240
     Magenta 300

	 with other sub-colors like Orange at 30 degrees, so for even distribution of
	 12 main colors, need hue to cycle every 12th user
	*/

	// 95% of hue is (# mod 12) / 12
	//  5% of hue from # of loops around color wheel, round-robin every 10th person	
	fHue = ( ( iColorKey % 12 ) / 12.0f ) * 0.95f + 
		   ( ( iColorKey / 12 ) % 10 )    * 0.05f;
	
    fHue *= 6.0f;		

	// 0.75 base  
	// 0.25 * cos(# loops around color wheel * (slightly more than PI/2 so different for each # loops))
	fSat = 0.75f + cos( ( iColorKey / 12 ) * Pi * 0.55 ) * 0.25f;		
//	Log("TIM: Hue=" $ fHue $ ", Sat=" $ fSat);
	
	i = INT( fHue );
	f = fHue - i;
	if ( ( i & 1 ) == 0 )
		f = 1.0f - f;

	m = v * ( 1.0f - fSat );
	n = v * ( 1.0f - fSat*f );

	switch( i ) 
    {
		case 0: 
		case 6:  vecHSV.x = v; vecHSV.y = n; vecHSV.z = m;	break;
		case 1:  vecHSV.x = n; vecHSV.y = v; vecHSV.z = m;	break; 
		case 2:  vecHSV.x = m; vecHSV.y = v; vecHSV.z = n;	break; 
		case 3:  vecHSV.x = m; vecHSV.y = n; vecHSV.z = v;	break; 
		case 4:  vecHSV.x = n; vecHSV.y = m; vecHSV.z = v;	break; 
		case 5:  vecHSV.x = v; vecHSV.y = m; vecHSV.z = n;	break; 
		default: //vecHSV.x = 0; vecHSV.y = 0; vecHSV.z = 0;	
	        break; 
	}

	colorIdentifier.R = vecHSV.x * 255;
	colorIdentifier.G = vecHSV.y * 255;
	colorIdentifier.B = vecHSV.z * 255;

	//change v = 0.75, and recalc the data color
	v = 0.75f;
	switch( i )
    {
		case 0: 
		case 5:  
		case 6:  vecHSV.x = v; vecHSV.y *= v; vecHSV.z *= v;	break;
		case 1:  
		case 2:  vecHSV.x *= v; vecHSV.y = v; vecHSV.z *= v;	break; 
		case 3:   
		case 4:  vecHSV.x *= v; vecHSV.y *= v; vecHSV.z = v;	break; 
		default: //vecHSV.x = 0; vecHSV.y = 0; vecHSV.z = 0;	
				 break; 
	}
	
	colorData.R = vecHSV.x * 255;
	colorData.G = vecHSV.y * 255;
	colorData.B = vecHSV.z * 255;
	
/*	Log("TIM: iColorKey#" $ iColorKey $ 
		" translated to R=" $ colorIdentifier.R $
		" G=" $ colorIdentifier.G $
		" B=" $ colorIdentifier.B 
	);
	Log("TIM: colorData translated to" $ 
		" R=" $ colorData.R $
		" G=" $ colorData.G $
		" B=" $ colorData.B 
	);
*/
}

defaultproperties
{
    colorIdentifier=(G=255,B=128)
    colorData=(R=10,G=245,B=128)
}
