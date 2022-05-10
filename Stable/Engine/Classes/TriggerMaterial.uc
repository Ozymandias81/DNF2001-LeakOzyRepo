//=============================================================================
// TriggerMaterial. (NJS)
// Event is material name.
//=============================================================================
class TriggerMaterial expands Triggers;

var () bool    OnlyFirstSurface;
var () bool    TextureAssign;
var () texture TextureToAssign;
var () bool    UPanAssign;
var () int     NewUPan;
var () bool    VPanAssign;
var () int     NewVPan;

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;
	local int After;
	local int UPan,VPan;
	After=-1;
	
	while(true)
	{
		i=FindSurfaceByName(Event,After);
		if(i==-1) break;
		if(TextureAssign) SetSurfaceTexture(i,TextureToAssign);

		if(UPanAssign||VPanAssign)
		{
			UPan=GetSurfaceUPan(i);
			VPan=GetSurfaceVPan(i);

			if(UPanAssign) UPan=NewUPan;
			if(VPanAssign) VPan=NewVPan;
			SetSurfacePan(i,UPan,VPan);
		}
		After=i;
		if(OnlyFirstSurface) break;
	}
}

defaultproperties
{
	OnlyFirstSurface=True;
	TextureAssign=false;
}
